enum Pid {
  rpm,
  speed,
  coolant,
  throttle,
  load,
  iat,
  maf,
  fuelTrimST,
  fuelTrimLT,
  voltage,
  fuelPressure,
  barometric,
  timingAdvance,
  egr,
  catalystTemp,
  supportedPids0120,
  supportedPids2140,
}

class PidDefinition {
  final Pid pid;
  final int mode;
  final int id;
  final String name;
  final String unit;
  final double min;
  final double max;
  final double Function(List<int> bytes) decode;

  const PidDefinition({
    required this.pid,
    required this.mode,
    required this.id,
    required this.name,
    required this.unit,
    required this.min,
    required this.max,
    required this.decode,
  });

  String get command => '${mode.toRadixString(16).padLeft(2, '0')}${id.toRadixString(16).padLeft(2, '0')}';
}

final Map<Pid, PidDefinition> pidRegistry = {
  Pid.rpm: PidDefinition(
    pid: Pid.rpm,
    mode: 0x01,
    id: 0x0C,
    name: 'Engine RPM',
    unit: 'rpm',
    min: 0,
    max: 8000,
    decode: (b) => ((b[0] * 256) + b[1]) / 4.0,
  ),
  Pid.speed: PidDefinition(
    pid: Pid.speed,
    mode: 0x01,
    id: 0x0D,
    name: 'Vehicle Speed',
    unit: 'km/h',
    min: 0,
    max: 255,
    decode: (b) => b[0].toDouble(),
  ),
  Pid.coolant: PidDefinition(
    pid: Pid.coolant,
    mode: 0x01,
    id: 0x05,
    name: 'Coolant Temp',
    unit: '°C',
    min: -40,
    max: 215,
    decode: (b) => b[0].toDouble() - 40.0,
  ),
  Pid.throttle: PidDefinition(
    pid: Pid.throttle,
    mode: 0x01,
    id: 0x11,
    name: 'Throttle Position',
    unit: '%',
    min: 0,
    max: 100,
    decode: (b) => b[0] * 100.0 / 255.0,
  ),
  Pid.load: PidDefinition(
    pid: Pid.load,
    mode: 0x01,
    id: 0x04,
    name: 'Engine Load',
    unit: '%',
    min: 0,
    max: 100,
    decode: (b) => b[0] * 100.0 / 255.0,
  ),
  Pid.iat: PidDefinition(
    pid: Pid.iat,
    mode: 0x01,
    id: 0x0F,
    name: 'Intake Air Temp',
    unit: '°C',
    min: -40,
    max: 215,
    decode: (b) => b[0].toDouble() - 40.0,
  ),
  Pid.maf: PidDefinition(
    pid: Pid.maf,
    mode: 0x01,
    id: 0x10,
    name: 'MAF Air Flow',
    unit: 'g/s',
    min: 0,
    max: 655.35,
    decode: (b) => ((b[0] * 256) + b[1]) / 100.0,
  ),
  Pid.fuelTrimST: PidDefinition(
    pid: Pid.fuelTrimST,
    mode: 0x01,
    id: 0x06,
    name: 'Short Term Fuel Trim',
    unit: '%',
    min: -100,
    max: 99.2,
    decode: (b) => (b[0] - 128.0) * 100.0 / 128.0,
  ),
  Pid.fuelTrimLT: PidDefinition(
    pid: Pid.fuelTrimLT,
    mode: 0x01,
    id: 0x07,
    name: 'Long Term Fuel Trim',
    unit: '%',
    min: -100,
    max: 99.2,
    decode: (b) => (b[0] - 128.0) * 100.0 / 128.0,
  ),
  Pid.timingAdvance: PidDefinition(
    pid: Pid.timingAdvance,
    mode: 0x01,
    id: 0x0E,
    name: 'Timing Advance',
    unit: '°',
    min: -64,
    max: 63.5,
    decode: (b) => (b[0] / 2.0) - 64.0,
  ),
};
