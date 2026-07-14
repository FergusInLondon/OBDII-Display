import 'package:flutter/services.dart';
import '../obd/pid/pid.dart';

/// Forwards PID readings to the native Android Car App Library screen
/// (see android/.../car/PidDashboardScreen.kt). No-ops on platforms/hosts
/// without a car screen attached.
class CarPidChannel {
  CarPidChannel._();
  static final CarPidChannel instance = CarPidChannel._();

  static const MethodChannel _channel = MethodChannel('com.example.obd_app/car_pids');

  Future<void> sendSnapshot(Map<Pid, double> snapshot) async {
    final payload = <String, String>{
      for (final entry in snapshot.entries)
        if (pidRegistry[entry.key] case final def?) def.name: _format(entry.value, def.unit),
    };
    if (payload.isEmpty) return;

    try {
      await _channel.invokeMethod('updatePids', payload);
    } on MissingPluginException {
      // No Android host for the channel (iOS/desktop, or car screen not open) - ignore.
    } on PlatformException {
      // Best-effort push; failures here shouldn't affect the phone dashboard.
    }
  }

  String _format(double value, String unit) {
    final rounded = value.abs() >= 100 ? value.round().toString() : value.toStringAsFixed(1);
    return unit.isEmpty ? rounded : '$rounded $unit';
  }
}
