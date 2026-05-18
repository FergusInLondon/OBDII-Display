import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../transport/transport.dart';
import '../transport/mock_transport.dart';
import '../elm327/elm327_controller.dart';
import '../obd/obd_service.dart';
import '../obd/pid/pid.dart';
import '../config/dashboard_config.dart';

part 'obd_provider.g.dart';

@Riverpod(keepAlive: true)
class TransportStateNotifier extends _$TransportStateNotifier {
  @override
  Transport? build() => MockTransport();

  void setTransport(Transport transport) {
    state = transport;
  }
}

@Riverpod(keepAlive: true)
Elm327Controller elm327Controller(Elm327ControllerRef ref) {
  final transport = ref.watch(transportStateNotifierProvider);
  if (transport == null) throw Exception('No transport selected');
  return Elm327Controller(transport);
}

@Riverpod(keepAlive: true)
ObdService obdService(ObdServiceRef ref) {
  final elm = ref.watch(elm327ControllerProvider);
  return ObdService(elm);
}

@riverpod
Stream<Map<Pid, double>> obdSnapshot(ObdSnapshotRef ref) {
  final service = ref.watch(obdServiceProvider);
  return service.snapshotStream;
}

@Riverpod(keepAlive: true)
class ActiveProfile extends _$ActiveProfile {
  @override
  DashboardProfile build() => DashboardProfile.defaultProfile();

  void updateProfile(DashboardProfile profile) {
    state = profile;
  }
}
