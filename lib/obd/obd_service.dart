import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../elm327/elm327_controller.dart';
import 'pid/pid.dart';

class ObdService {
  final Elm327Controller elm;
  final _snapshotController = StreamController<Map<Pid, double>>.broadcast();
  Timer? _pollingTimer;
  Set<Pid> _activePids = {};
  final Set<Pid> _supportedPids = {};

  ObdService(this.elm);

  Stream<Map<Pid, double>> get snapshotStream => _snapshotController.stream;
  Set<Pid> get supportedPids => _supportedPids;

  Future<void> discoverSupportedPids() async {
    final response = await elm.sendCommand('0100');
    _parseSupportedPids(response, 0x00);
    // Could also check 0120, 0140 etc.
  }

  void _parseSupportedPids(String response, int offset) {
    // Basic implementation: 41 00 BE 3E A8 11
    final parts = response.split(' ');
    if (parts.length < 6 || parts[0] != '41') return;

    // Convert 4 hex bytes to 32-bit int
    int mask = 0;
    for (int i = 2; i < 6; i++) {
      mask = (mask << 8) | int.parse(parts[i], radix: 16);
    }

    for (int i = 0; i < 31; i++) {
      if ((mask & (0x80000000 >> i)) != 0) {
        final pidId = offset + i + 1;
        final pid = pidRegistry.values.firstWhere(
          (p) => p.mode == 0x01 && p.id == pidId,
          orElse: () => PidDefinition(pid: Pid.speed, mode: 0, id: 0, name: '', unit: '', min: 0, max: 0, decode: (b) => 0),
        ).pid;
        if (pidId != 0) _supportedPids.add(pid);
      }
    }
  }

  void startPolling(List<Pid> pids, {Duration interval = const Duration(milliseconds: 200)}) {
    _activePids = pids.toSet();
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) => _poll());
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  Future<void> _poll() async {
    if (elm.currentStatus != Elm327Status.ready) return;

    final Map<Pid, double> results = {};
    for (final pid in _activePids) {
      final def = pidRegistry[pid];
      if (def == null) continue;

      try {
        final resp = await elm.sendCommand(def.command);
        final value = _decodeResponse(resp, def);
        if (value != null) {
          results[pid] = value;
        }
      } catch (e) {
        // Log or handle error
      }
    }
    if (results.isNotEmpty) {
      _snapshotController.add(results);
    }
  }

  double? _decodeResponse(String response, PidDefinition def) {
    // Example: 41 0C 0B 12
    final parts = response.split(' ');
    if (parts.length < 3 || parts[0] != '41') return null;

    final bytes = parts.sublist(2).map((s) => int.parse(s, radix: 16)).toList();
    return def.decode(bytes);
  }
}
