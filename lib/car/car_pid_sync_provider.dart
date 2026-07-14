import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../obd/pid/pid.dart';
import '../providers/obd_provider.dart';
import 'car_pid_channel.dart';

/// Watch this provider once from the app root to keep it alive for the app's
/// lifetime. It mirrors whatever PIDs the active profile currently displays
/// on the phone dashboard out to the Android Auto/Automotive car screen.
final carPidSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<Map<Pid, double>>>(obdSnapshotProvider, (previous, next) {
    final snapshot = next.valueOrNull;
    if (snapshot == null) return;

    final profile = ref.read(activeProfileProvider);
    final visiblePids = <Pid>{
      profile.primaryGauge,
      if (profile.secondaryGauge != null) profile.secondaryGauge!,
      ...profile.stripSlots,
    };

    final filtered = <Pid, double>{
      for (final entry in snapshot.entries)
        if (visiblePids.contains(entry.key)) entry.key: entry.value,
    };

    CarPidChannel.instance.sendSnapshot(filtered);
  });
});
