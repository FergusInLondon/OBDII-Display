import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/obd_provider.dart';
import '../../config/dashboard_config.dart';
import '../../obd/pid/pid.dart';
import '../widgets/arc_gauge.dart';
import '../widgets/pid_tile.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileProvider);
    final snapshot = ref.watch(obdSnapshotProvider).value ?? {};

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusBar(context, ref),
            Expanded(
              child: _buildMainGauges(context, profile, snapshot),
            ),
            _buildPidStrip(context, profile, snapshot),
            _buildDtcBanner(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.primaryColor, blurRadius: 4)],
                ),
              ),
              const SizedBox(width: 10),
              Text('CONNECTED', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white.withOpacity(0.5))),
            ],
          ),
          Row(
            children: [
              _buildStatChip('VOLT', '12.4 V'),
              const SizedBox(width: 16),
              _buildStatChip('POLL', '8 Hz'),
              const SizedBox(width: 16),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.settings, size: 18, color: AppTheme.mutedTextColor),
                onPressed: () => context.push('/config'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Row(
      children: [
        Text('$label ', style: GoogleFonts.dmMono(fontSize: 11, color: AppTheme.mutedTextColor)),
        Text(value, style: GoogleFonts.dmMono(fontSize: 11, color: Colors.white.withOpacity(0.75))),
      ],
    );
  }

  Widget _buildMainGauges(BuildContext context, DashboardProfile profile, Map<Pid, double> snapshot) {
    if (profile.layout == DashboardLayout.single) {
      return Center(
        child: ArcGauge(
          value: snapshot[profile.primaryGauge] ?? 0,
          min: pidRegistry[profile.primaryGauge]!.min,
          max: pidRegistry[profile.primaryGauge]!.max,
          unit: pidRegistry[profile.primaryGauge]!.unit,
          subLabel: pidRegistry[profile.primaryGauge]!.name,
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Center(
            child: ArcGauge(
              value: snapshot[profile.primaryGauge] ?? 0,
              min: pidRegistry[profile.primaryGauge]!.min,
              max: pidRegistry[profile.primaryGauge]!.max,
              unit: pidRegistry[profile.primaryGauge]!.unit,
              subLabel: pidRegistry[profile.primaryGauge]!.name,
            ),
          ),
        ),
        Container(width: 0.5, color: Colors.white.withOpacity(0.08)),
        Expanded(
          child: Center(
            child: ArcGauge(
              value: snapshot[profile.secondaryGauge ?? Pid.speed] ?? 0,
              min: pidRegistry[profile.secondaryGauge ?? Pid.speed]!.min,
              max: pidRegistry[profile.secondaryGauge ?? Pid.speed]!.max,
              unit: pidRegistry[profile.secondaryGauge ?? Pid.speed]!.unit,
              subLabel: pidRegistry[profile.secondaryGauge ?? Pid.speed]!.name,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPidStrip(BuildContext context, DashboardProfile profile, Map<Pid, double> snapshot) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: profile.stripSlots.length,
        itemBuilder: (context, index) {
          final pid = profile.stripSlots[index];
          return PidTile(
            pid: pid,
            value: snapshot[pid] ?? 0,
            active: index == 0,
          );
        },
      ),
    );
  }

  Widget _buildDtcBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppTheme.errorColor.withOpacity(0.08),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.errorColor, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text('P0171', style: GoogleFonts.dmMono(color: AppTheme.errorColor, fontSize: 12)),
          const SizedBox(width: 10),
          Text('System too lean (bank 1)', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
          const Spacer(),
          Text('CLEAR', style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 11, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
