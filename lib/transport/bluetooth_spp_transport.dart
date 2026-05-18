import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as spp;
import 'transport.dart';

class BluetoothSppTransport implements Transport {
  final spp.BluetoothDevice device;
  spp.BluetoothConnection? _connection;

  final _stateController = StreamController<TransportState>.broadcast();
  final _rxController = StreamController<List<int>>.broadcast();
  TransportState _state = TransportState.disconnected;

  BluetoothSppTransport(this.device) {
    _stateController.add(_state);
  }

  @override
  Future<void> connect() async {
    _updateState(TransportState.connecting);
    try {
      _connection = await spp.BluetoothConnection.toAddress(device.address);
      _updateState(TransportState.connected);

      _connection!.input?.listen((Uint8List data) {
        _rxController.add(data);
      }).onDone(() {
        _updateState(TransportState.disconnected);
      });
    } catch (e) {
      _updateState(TransportState.disconnected);
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
    _updateState(TransportState.disconnected);
  }

  @override
  Stream<List<int>> get rx => _rxController.stream;

  @override
  Stream<TransportState> get state => _stateController.stream;

  @override
  TransportState get currentState => _state;

  @override
  Future<void> write(List<int> data) async {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList(data));
      await _connection!.output.allSent;
    }
  }

  void _updateState(TransportState newState) {
    _state = newState;
    _stateController.add(_state);
  }
}
