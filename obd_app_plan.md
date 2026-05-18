# OBD-II Mobile App — Development Plan

## Overview

A cross-platform (Android/iOS) OBD-II diagnostic and dashboard application built in Flutter,
targeting the Vgate iCar Pro 2S adapter via BLE. The app provides a configurable, instrument-
cluster-style dashboard with live PID data, DTC reading/clearing, and session logging.

Open source. Designed as a clean, modern alternative to existing tools.

---

## Technical Constraints

| Concern | Decision |
|---|---|
| Min Android API | 26 (Android 8.0) |
| Min iOS | 13.0 |
| BLE transport | Primary; adapter pattern allows SPP fallback |
| State management | Riverpod; `Map<Pid, double>` snapshot per poll cycle |
| Config persistence | `shared_preferences` |
| Language | Dart / Flutter |
| Adapter | Vgate iCar Pro 2S (BT 5.3 dual-mode; BLE for both platforms) |

---

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.x       # State management
  flutter_blue_plus: ^1.x      # BLE transport
  shared_preferences: ^2.x     # Config persistence
  go_router: ^13.x             # Navigation
  google_fonts: ^6.x           # DM Mono + Syne
  permission_handler: ^11.x    # Runtime BLE/location permissions

dev_dependencies:
  riverpod_generator: ^2.x     # Code gen for providers
  build_runner: ^2.x
  flutter_lints: ^3.x
```

---

## Project Structure

```
lib/
├── main.dart
├── app.dart                        # GoRouter setup, app shell
│
├── transport/
│   ├── transport.dart              # Abstract Transport interface
│   ├── ble_transport.dart          # flutter_blue_plus implementation
│   └── mock_transport.dart         # Deterministic fake for UI dev/testing
│
├── elm327/
│   ├── elm327_controller.dart      # AT command state machine
│   ├── at_command.dart             # Command definitions + response parsing
│   └── protocol.dart               # Detected protocol enum + negotiation
│
├── obd/
│   ├── obd_service.dart            # Polling loop, exposes snapshot stream
│   ├── pid/
│   │   ├── pid.dart                # Pid enum
│   │   ├── pid_registry.dart       # PID → {mode, id, formula, unit, range}
│   │   └── pid_decoder.dart        # Raw byte → double per PID
│   ├── dtc/
│   │   ├── dtc.dart                # DTC model (code, system, description)
│   │   └── dtc_service.dart        # Mode 03/04 request/response
│   └── session/
│       ├── session_logger.dart     # CSV logging
│       └── session_model.dart      # Timestamped snapshot model
│
├── config/
│   ├── dashboard_config.dart       # Layout + slot assignments model
│   ├── config_repository.dart      # shared_preferences read/write
│   └── default_configs.dart        # Sensible defaults
│
├── providers/
│   ├── transport_provider.dart     # Transport singleton
│   ├── elm327_provider.dart        # ELM327Controller provider
│   ├── obd_provider.dart           # Snapshot StreamProvider<Map<Pid, double>>
│   ├── dtc_provider.dart           # FutureProvider<List<Dtc>>
│   └── config_provider.dart        # StateNotifierProvider<DashboardConfig>
│
└── ui/
    ├── screens/
    │   ├── scan_screen.dart         # BLE device scan + connect
    │   ├── dashboard_screen.dart    # Main instrument cluster
    │   ├── dtc_screen.dart          # DTC list + clear
    │   ├── sensors_screen.dart      # Full PID table (all supported)
    │   └── config_screen.dart       # Layout picker + slot assignment
    ├── widgets/
    │   ├── arc_gauge.dart           # CustomPainter arc gauge
    │   ├── pid_tile.dart            # Strip tile widget
    │   ├── dtc_banner.dart          # Inline DTC alert bar
    │   ├── connection_bar.dart      # Status bar (protocol, voltage, poll Hz)
    │   └── pid_picker_sheet.dart    # Bottom sheet PID selector
    └── theme/
        ├── app_theme.dart           # ThemeData, colour constants
        └── typography.dart          # Text styles (DM Mono + Syne)
```

---

## Architecture

### Transport Layer

```
abstract interface class Transport {
  Future<void> connect();
  Future<void> write(List<int> data);
  Stream<List<int>> get rx;
  Future<void> disconnect();
  Stream<TransportState> get state;
}
```

`BleTransport` wraps `flutter_blue_plus`. Scans for `Android-Vlink`, connects, discovers
the iCar 2S GATT service, and wires the notify characteristic to `rx` and the write
characteristic to `write()`.

`MockTransport` replays canned ELM327 responses deterministically — used for UI development
and integration tests without hardware.

The `Transport` is injected via Riverpod; swapping implementations requires no changes
above the transport layer.

---

### ELM327 State Machine

Initialisation sequence on connection (sequential AT commands, each awaiting response):

```
ATZ       → reset, await "ELM327 v..."
ATE0      → echo off
ATL0      → linefeeds off
ATS0      → spaces off
ATH1      → headers on  (needed to parse multi-ECU responses)
ATAT1     → adaptive timing
ATSP0     → auto protocol detection
0100      → probe Mode 01 / PID 0x00 (triggers protocol lock + returns supported bitmap)
```

After init, the controller is in `ready` state. The OBD service then drives it via
`Future<List<int>> request(String command)`.

State machine states: `disconnected → initialising → ready → error`

Timeout and retry logic sits inside the state machine; the OBD service never sees
raw transport failures.

---

### OBD Service & Polling

The service maintains a **priority queue** of PIDs to poll, ordered by requested frequency.
Each tick it dequeues the next PID, issues the request, decodes the response, and emits
an updated `Map<Pid, double>` snapshot.

```
StreamProvider<Map<Pid, double>>  →  rebuilt each poll cycle (~8 Hz target)
```

Only PIDs present in the active dashboard config are polled — no polling overhead for
unmapped slots.

Supported PID set is determined at connect time by walking the Mode 01 bitmap chain
(0x00, 0x20, 0x40, 0x60) and stored as `Set<Pid>` in a provider. The config screen
filters the picker to only show supported PIDs.

---

### PID Registry

Each entry defines:

```dart
class PidDefinition {
  final Pid pid;
  final int mode;       // 0x01 for live data
  final int id;         // e.g. 0x0C for RPM
  final String name;
  final String unit;
  final double min;
  final double max;
  final double Function(List<int> bytes) decode;
}
```

Formulae are SAE J1979-defined. Examples:

```dart
Pid.rpm:      (b) => ((b[0] * 256) + b[1]) / 4.0,
Pid.speed:    (b) => b[0].toDouble(),
Pid.coolant:  (b) => b[0] - 40.0,
Pid.throttle: (b) => b[0] * 100.0 / 255.0,
Pid.maf:      (b) => ((b[0] * 256) + b[1]) / 100.0,
Pid.fuelTrim: (b) => (b[0] - 128.0) * 100.0 / 128.0,
```

---

### Dashboard Config Model

```dart
enum Layout { single, dual, focus }

class DashboardConfig {
  final Layout layout;
  final Pid primaryGauge;
  final Pid? secondaryGauge;       // null when layout == single
  final List<Pid> stripSlots;      // fixed length 6
  final bool thresholdAlerts;
  final bool keepScreenOn;
  final bool logToFile;
}
```

Serialised to/from JSON via `shared_preferences`. `ConfigRepository` exposes
`load()` / `save(DashboardConfig)`. A `StateNotifierProvider` wraps this with live
update support — changing a slot assignment reflects immediately in the dashboard
without reconnecting.

Multiple named profiles are a natural extension (v2 scope).

---

## Implementation Phases

### Phase 1 — Transport + ELM327

Deliverables:
- `Transport` interface + `BleTransport` implementation
- `MockTransport` for development
- GATT characteristic discovery for iCar 2S (requires enumeration with nRF Connect
  to obtain service/characteristic UUIDs before implementation)
- ELM327 `AT` init sequence state machine
- `ScanScreen` — BLE device list, connect/disconnect

Acceptance: app connects to iCar 2S, completes init sequence, reaches `ready` state.
Mock transport produces identical state transitions without hardware.

---

### Phase 2 — OBD Service + PID Registry

Deliverables:
- `PidRegistry` with full SAE J1979 standard PID set (Mode 01)
- Supported PID bitmap enumeration (0x00 / 0x20 / 0x40 / 0x60 chain)
- `ObdService` polling loop
- `StreamProvider<Map<Pid, double>>` snapshot
- `SensorsScreen` — raw table of all supported PIDs with live values (debug/validation UI)

Acceptance: polling loop runs at ≥5 Hz for a 4-PID config against real hardware,
with correct decoded values cross-checked against a known-good app (e.g. Car Scanner).

---

### Phase 3 — DTC Support

Deliverables:
- Mode 03 (stored) and Mode 07 (pending) DTC request/response parsing
- Mode 04 (clear) with confirmation dialog
- DTC description lookup (SAE generic codes embedded; manufacturer codes flagged as unknown)
- `DtcScreen`
- `DtcBanner` widget on dashboard

Acceptance: reads and displays stored DTCs, clears successfully, banner appears/disappears
correctly.

---

### Phase 4 — Dashboard UI

Deliverables:
- `ArcGauge` CustomPainter with animated value transitions
- `PidTile` strip widget with threshold colouring
- `ConnectionBar` (protocol, voltage, poll Hz)
- `DashboardScreen` — assembles layout from active `DashboardConfig`
- Layout switching (single / dual / focus) driven by config

Acceptance: dashboard renders correctly for all three layouts, values animate smoothly,
threshold colouring triggers correctly.

---

### Phase 5 — Configuration

Deliverables:
- `ConfigScreen` — layout picker + gauge slot assignment + strip slot assignment + toggles
- `PidPickerSheet` — bottom sheet filtered to supported PIDs
- `ConfigRepository` persistence
- Config changes reflect live in dashboard without reconnect

Acceptance: user can reconfigure layout and all slots, config persists across app restarts.

---

### Phase 6 — Session Logging

Deliverables:
- CSV session logger (timestamped snapshots, one row per poll cycle)
- File saved to app documents directory
- Share sheet integration for export

Acceptance: log file is valid CSV, importable into a spreadsheet or Python/pandas without
preprocessing.

---

## Key Open Questions (Pre-implementation)

**GATT UUIDs for iCar 2S**
Must be enumerated empirically before Phase 1 can be completed. Use nRF Connect on
Android, connect to `Android-Vlink`, and record:
- Service UUID
- Write characteristic UUID
- Notify characteristic UUID

These are likely shared with other Vgate BLE adapters and may be documented in open-source
projects (`OBD2-Swift`, `python-obd`) — worth cross-referencing to avoid needing hardware
immediately.

**iCar 2S BLE protocol framing**
Standard ELM327 AT commands over BLE may use a simple GATT write-per-command model, or
may wrap in a lightweight framing layer (some adapters add a 4-byte header). Needs
verification against the adapter with `ATZ` and raw response inspection.

**Redline / range metadata**
PID min/max in the registry are SAE-specified where defined. Vehicle-specific ranges
(e.g. actual redline RPM) are not queryable via OBD-II — either hardcoded as sensible
defaults or user-configurable per profile.

---

## Out of Scope (v1)

- UDS / manufacturer-specific PIDs beyond SAE J1979
- Raw CAN sniffing / DBC decoding
- Classic BT SPP transport
- Named dashboard profiles
- Android Auto / CarPlay integration
- OBD-II Mode 06 (non-continuous monitor tests)
