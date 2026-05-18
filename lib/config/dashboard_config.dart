import 'dart:convert';
import '../obd/pid/pid.dart';

enum DashboardLayout { single, dual, focus }

class DashboardProfile {
  final String id;
  final String name;
  final DashboardLayout layout;
  final Pid primaryGauge;
  final Pid? secondaryGauge;
  final List<Pid> stripSlots;

  DashboardProfile({
    required this.id,
    required this.name,
    this.layout = DashboardLayout.dual,
    this.primaryGauge = Pid.rpm,
    this.secondaryGauge = Pid.speed,
    required this.stripSlots,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'layout': layout.name,
    'primaryGauge': primaryGauge.name,
    'secondaryGauge': secondaryGauge?.name,
    'stripSlots': stripSlots.map((e) => e.name).toList(),
  };

  factory DashboardProfile.fromJson(Map<String, dynamic> json) {
    return DashboardProfile(
      id: json['id'],
      name: json['name'],
      layout: DashboardLayout.values.byName(json['layout']),
      primaryGauge: Pid.values.byName(json['primaryGauge']),
      secondaryGauge: json['secondaryGauge'] != null ? Pid.values.byName(json['secondaryGauge']) : null,
      stripSlots: (json['stripSlots'] as List).map((e) => Pid.values.byName(e)).toList(),
    );
  }

  static DashboardProfile defaultProfile() => DashboardProfile(
    id: 'default',
    name: 'Default Profile',
    stripSlots: [Pid.coolant, Pid.throttle, Pid.load, Pid.iat, Pid.maf, Pid.fuelTrimST],
  );
}
