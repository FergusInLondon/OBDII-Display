import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/obd_provider.dart';
import '../../config/dashboard_config.dart';
import '../../obd/pid/pid.dart';
import '../theme/app_theme.dart';

class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Configuration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionLabel(context, 'LAYOUT'),
          const SizedBox(height: 12),
          _buildLayoutPicker(context, ref, profile),
          const SizedBox(height: 24),
          _buildSectionLabel(context, 'PRIMARY GAUGES'),
          const SizedBox(height: 12),
          _buildGaugeSlots(context, ref, profile),
          const SizedBox(height: 24),
          _buildSectionLabel(context, 'PID STRIP'),
          const SizedBox(height: 12),
          _buildStripSlots(context, ref, profile),
          const SizedBox(height: 24),
          _buildSectionLabel(context, 'BEHAVIOUR'),
          _buildToggleRow('Threshold alerts', 'Warn when values exceed ranges', true),
          _buildToggleRow('Keep screen on', 'Prevent display sleep', true),
          _buildToggleRow('Log to file', 'Record session data as CSV', false),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2),
    );
  }

  Widget _buildLayoutPicker(BuildContext context, WidgetRef ref, DashboardProfile profile) {
    return Row(
      children: [
        _LayoutOption(
          label: 'SINGLE',
          selected: profile.layout == DashboardLayout.single,
          onTap: () => _updateLayout(ref, profile, DashboardLayout.single),
        ),
        const SizedBox(width: 10),
        _LayoutOption(
          label: 'DUAL',
          selected: profile.layout == DashboardLayout.dual,
          onTap: () => _updateLayout(ref, profile, DashboardLayout.dual),
        ),
        const SizedBox(width: 10),
        _LayoutOption(
          label: 'FOCUS',
          selected: profile.layout == DashboardLayout.focus,
          onTap: () => _updateLayout(ref, profile, DashboardLayout.focus),
        ),
      ],
    );
  }

  void _updateLayout(WidgetRef ref, DashboardProfile profile, DashboardLayout layout) {
    ref.read(activeProfileProvider.notifier).updateProfile(
      DashboardProfile(
        id: profile.id,
        name: profile.name,
        layout: layout,
        primaryGauge: profile.primaryGauge,
        secondaryGauge: profile.secondaryGauge,
        stripSlots: profile.stripSlots,
      ),
    );
  }

  Widget _buildGaugeSlots(BuildContext context, WidgetRef ref, DashboardProfile profile) {
    return Column(
      children: [
        _SlotCard(
          role: 'PRIMARY',
          pid: profile.primaryGauge,
          onTap: () {},
        ),
        if (profile.layout != DashboardLayout.single) ...[
          const SizedBox(height: 8),
          _SlotCard(
            role: 'SECONDARY',
            pid: profile.secondaryGauge ?? Pid.speed,
            onTap: () {},
          ),
        ],
      ],
    );
  }

  Widget _buildStripSlots(BuildContext context, WidgetRef ref, DashboardProfile profile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 3,
      children: profile.stripSlots.map((pid) => _StripSlot(pid: pid)).toList(),
    );
  }

  Widget _buildToggleRow(String title, String desc, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13)),
              Text(desc, style: const TextStyle(fontSize: 11, color: AppTheme.mutedTextColor)),
            ],
          ),
          Switch(value: value, onChanged: (_) {}, activeColor: AppTheme.primaryColor),
        ],
      ),
    );
  }
}

class _LayoutOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LayoutOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            border: Border.all(color: selected ? AppTheme.primaryColor : Colors.white.withOpacity(0.1), width: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 10, color: selected ? AppTheme.primaryColor : AppTheme.mutedTextColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final String role;
  final Pid pid;
  final VoidCallback onTap;

  const _SlotCard({required this.role, required this.pid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final def = pidRegistry[pid]!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15), width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.speed, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
                  Text(def.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.mutedTextColor, size: 16),
          ],
        ),
      ),
    );
  }
}

class _StripSlot extends StatelessWidget {
  final Pid pid;

  const _StripSlot({required this.pid});

  @override
  Widget build(BuildContext context) {
    final def = pidRegistry[pid]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(def.name, style: const TextStyle(fontSize: 12, color: Colors.white60)),
          const Icon(Icons.edit, size: 12, color: AppTheme.mutedTextColor),
        ],
      ),
    );
  }
}
