import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obd_app/car/car_pid_channel.dart';
import 'package:obd_app/obd/pid/pid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.example.obd_app/car_pids');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('formats values with units, rounding large values and keeping 1dp for small ones', () async {
    await CarPidChannel.instance.sendSnapshot({
      Pid.rpm: 2834.567,
      Pid.coolant: 91.2,
      Pid.speed: 108.9,
    });

    expect(calls, hasLength(1));
    expect(calls.single.method, 'updatePids');

    final payload = calls.single.arguments as Map;
    expect(payload['Engine RPM'], '2835 rpm');
    expect(payload['Coolant Temp'], '91.2 °C');
    expect(payload['Vehicle Speed'], '109 km/h');
  });

  test('skips PIDs with no registry definition', () async {
    // Pid.voltage has an enum value but no PidDefinition in pidRegistry.
    await CarPidChannel.instance.sendSnapshot({
      Pid.rpm: 1000,
      Pid.voltage: 12.6,
    });

    final payload = calls.single.arguments as Map;
    expect(payload.keys, ['Engine RPM']);
  });

  test('does not invoke the channel for an empty snapshot', () async {
    await CarPidChannel.instance.sendSnapshot({});

    expect(calls, isEmpty);
  });
}
