import 'dart:async';

enum TransportState {
  disconnected,
  connecting,
  connected,
}

abstract interface class Transport {
  Future<void> connect();
  Future<void> write(List<int> data);
  Stream<List<int>> get rx;
  Future<void> disconnect();
  Stream<TransportState> get state;
  TransportState get currentState;
}
