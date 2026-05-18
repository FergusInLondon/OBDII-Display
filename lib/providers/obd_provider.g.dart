// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'obd_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$elm327ControllerHash() => r'a48cf445264c99a143f793574f9e76ea2c1254ae';

/// See also [elm327Controller].
@ProviderFor(elm327Controller)
final elm327ControllerProvider = Provider<Elm327Controller>.internal(
  elm327Controller,
  name: r'elm327ControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$elm327ControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef Elm327ControllerRef = ProviderRef<Elm327Controller>;
String _$obdServiceHash() => r'127572a228d843b4caff5180ac72422f74af93d3';

/// See also [obdService].
@ProviderFor(obdService)
final obdServiceProvider = Provider<ObdService>.internal(
  obdService,
  name: r'obdServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$obdServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ObdServiceRef = ProviderRef<ObdService>;
String _$obdSnapshotHash() => r'0455582bd8418355cb624d6bcb9a6941df4d4921';

/// See also [obdSnapshot].
@ProviderFor(obdSnapshot)
final obdSnapshotProvider =
    AutoDisposeStreamProvider<Map<Pid, double>>.internal(
  obdSnapshot,
  name: r'obdSnapshotProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$obdSnapshotHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ObdSnapshotRef = AutoDisposeStreamProviderRef<Map<Pid, double>>;
String _$transportStateNotifierHash() =>
    r'd041e7809175f4b00a10e9568396deae902eaee4';

/// See also [TransportStateNotifier].
@ProviderFor(TransportStateNotifier)
final transportStateNotifierProvider =
    NotifierProvider<TransportStateNotifier, Transport?>.internal(
  TransportStateNotifier.new,
  name: r'transportStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transportStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransportStateNotifier = Notifier<Transport?>;
String _$activeProfileHash() => r'1ee86bbf962b7c46836a90564e6703652f949449';

/// See also [ActiveProfile].
@ProviderFor(ActiveProfile)
final activeProfileProvider =
    NotifierProvider<ActiveProfile, DashboardProfile>.internal(
  ActiveProfile.new,
  name: r'activeProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveProfile = Notifier<DashboardProfile>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
