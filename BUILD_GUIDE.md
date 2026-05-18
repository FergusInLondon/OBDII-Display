# OBD-II Mobile App - Build & Deployment Guide

## Prerequisites

- **Flutter SDK**: Latest stable version.
- **Dart SDK**: Included with Flutter.
- **Android Studio / Xcode**: For platform-specific builds.
- **Permissions**: The app requires Bluetooth and Location permissions (for BLE scanning).

## Project Structure

- `lib/transport/`: Handles communication with OBD-II adapters (BLE, SPP, Mock).
- `lib/elm327/`: ELM327 command state machine and parsing.
- `lib/obd/`: OBD-II PID definitions, decoding, and service logic.
- `lib/ui/`: All Flutter widgets and screens, following the provided mockups.
- `lib/providers/`: Riverpod providers for state management.

## Getting Started

1.  **Clone the repository**.
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Generate code**:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the app**:
    ```bash
    flutter run
    ```

## Mock Mode

For development without hardware, the app defaults to `MockTransport`.
- In `ScanScreen`, click **"CONNECT TO MOCK ADAPTER"**.
- The app will simulate real-time OBD-II data (RPM, Speed, etc.) and even a mock DTC (P0171).

## Deployment

### Android
1. Update `android/app/build.gradle` with your signing configuration.
2. Build the APK:
   ```bash
   flutter build apk --release
   ```

### iOS
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Configure your development team and bundle identifier.
3. Build the Archive or run on a physical device.

## Supported Adapters
- **Vgate iCar Pro 2S** (BLE & Classic BT)
- Generic ELM327 Bluetooth adapters
- Nordic UART-compatible BLE adapters
