import 'package:flutter_test/flutter_test.dart';
import 'package:obd_app/obd/pid/pid.dart';

void main() {
  test('RPM Decoder', () {
    final def = pidRegistry[Pid.rpm]!;
    final bytes = [0x0B, 0x12]; // (2834 * 4) = 11336 = 0x2C48... wait
    // ( (0x0B * 256) + 0x12 ) / 4 = (2816 + 18) / 4 = 2834 / 4 = 708.5
    expect(def.decode(bytes), 708.5);
  });

  test('Speed Decoder', () {
    final def = pidRegistry[Pid.speed]!;
    final bytes = [0x32]; // 50 km/h
    expect(def.decode(bytes), 50.0);
  });
}
