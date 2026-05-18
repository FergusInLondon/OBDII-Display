import 'package:flutter/material.dart';
import '../../obd/pid/pid.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class PidTile extends StatelessWidget {
  final Pid pid;
  final double value;
  final bool active;

  const PidTile({
    super.key,
    required this.pid,
    required this.value,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final def = pidRegistry[pid]!;

    Color valColor = AppTheme.textColor;
    if (value > def.max * 0.9) {
      valColor = AppTheme.errorColor;
    } else if (value > def.max * 0.8) {
      valColor = AppTheme.warningColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: active ? Colors.white.withOpacity(0.05) : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: active ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            def.name.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value.toStringAsFixed(pid == Pid.maf ? 1 : 0),
                style: GoogleFonts.dmMono(
                  fontSize: 20,
                  color: valColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                def.unit,
                style: GoogleFonts.dmMono(
                  fontSize: 10,
                  color: AppTheme.mutedTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
