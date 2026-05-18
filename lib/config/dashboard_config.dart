import '../obd/pid/pid.dart';

enum DashboardLayout { single, dual, focus }

class DashboardProfile {
  final String id;
  final String name;
  final DashboardLayout layout;
  final Pid primaryGauge;
  final Pid? secondaryGauge;
  final List<Pid> stripSlots;
  final bool thresholdAlerts;
  final bool keepScreenOn;
  final bool logToFile;

  DashboardProfile({
    required this.id,
    required this.name,
    this.layout = DashboardLayout.dual,
    this.primaryGauge = Pid.rpm,
    this.secondaryGauge = Pid.speed,
    required this.stripSlots,
    this.thresholdAlerts = true,
    this.keepScreenOn = true,
    this.logToFile = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'layout': layout.name,
    'primaryGauge': primaryGauge.name,
    'secondaryGauge': secondaryGauge?.name,
    'stripSlots': stripSlots.map((e) => e.name).toList(),
    'thresholdAlerts': thresholdAlerts,
    'keepScreenOn': keepScreenOn,
    'logToFile': logToFile,
  };

  factory DashboardProfile.fromJson(Map<String, dynamic> json) {
    return DashboardProfile(
      id: json['id'],
      name: json['name'],
      layout: DashboardLayout.values.byName(json['layout']),
      primaryGauge: Pid.values.byName(json['primaryGauge']),
      secondaryGauge: json['secondaryGauge'] != null ? Pid.values.byName(json['secondaryGauge']) : null,
      stripSlots: (json['stripSlots'] as List).map((e) => Pid.values.byName(e as String)).toList(),
      thresholdAlerts: json['thresholdAlerts'] as bool? ?? true,
      keepScreenOn: json['keepScreenOn'] as bool? ?? true,
      logToFile: json['logToFile'] as bool? ?? false,
    );
  }

  DashboardProfile copyWith({
    String? id,
    String? name,
    DashboardLayout? layout,
    Pid? primaryGauge,
    Pid? secondaryGauge,
    List<Pid>? stripSlots,
    bool? thresholdAlerts,
    bool? keepScreenOn,
    bool? logToFile,
  }) => DashboardProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    layout: layout ?? this.layout,
    primaryGauge: primaryGauge ?? this.primaryGauge,
    secondaryGauge: secondaryGauge ?? this.secondaryGauge,
    stripSlots: stripSlots ?? this.stripSlots,
    thresholdAlerts: thresholdAlerts ?? this.thresholdAlerts,
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    logToFile: logToFile ?? this.logToFile,
  );

  static DashboardProfile defaultProfile() => DashboardProfile(
    id: 'default',
    name: 'Default Profile',
    stripSlots: [Pid.coolant, Pid.throttle, Pid.load, Pid.iat, Pid.maf, Pid.fuelTrimST],
  );
}
