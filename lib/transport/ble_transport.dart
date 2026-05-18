import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'transport.dart';

class BleTransport implements Transport {
  final BluetoothDevice device;
  BluetoothCharacteristic? _writeChar;
  BluetoothCharacteristic? _notifyChar;
  StreamSubscription? _notifySub;

  final _stateController = StreamController<TransportState>.broadcast();
  final _rxController = StreamController<List<int>>.broadcast();
  TransportState _state = TransportState.disconnected;

  // Vgate iCar Pro / Nordic UART UUIDs
  static const String serviceUuid = "ffe0";
  static const String charUuid = "ffe1";
  static const String uartServiceUuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const String uartRxUuid = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"; // App writes to RX
  static const String uartTxUuid = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"; // App reads from TX

  BleTransport(this.device) {
    _stateController.add(_state);
    device.connectionState.listen((s) {
      if (s == BluetoothConnectionState.connected) {
        _updateState(TransportState.connected);
      } else if (s == BluetoothConnectionState.disconnected) {
        _updateState(TransportState.disconnected);
      }
    });
  }

  @override
  Future<void> connect() async {
    _updateState(TransportState.connecting);
    try {
      await device.connect();
      final services = await device.discoverServices();

      for (var s in services) {
        if (s.uuid.toString().toLowerCase().contains(serviceUuid)) {
          for (var c in s.characteristics) {
            if (c.uuid.toString().toLowerCase().contains(charUuid)) {
              _writeChar = c;
              _notifyChar = c;
            }
          }
        } else if (s.uuid.toString().toLowerCase() == uartServiceUuid) {
          for (var c in s.characteristics) {
            if (c.uuid.toString().toLowerCase() == uartRxUuid) _writeChar = c;
            if (c.uuid.toString().toLowerCase() == uartTxUuid) _notifyChar = c;
          }
        }
      }

      if (_notifyChar != null) {
        await _notifyChar!.setNotifyValue(true);
        _notifySub = _notifyChar!.lastValueStream.listen((value) {
          if (value.isNotEmpty) {
            _rxController.add(value);
          }
        });
      }
    } catch (e) {
      _updateState(TransportState.disconnected);
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    await _notifySub?.cancel();
    await device.disconnect();
  }

  @override
  Stream<List<int>> get rx => _rxController.stream;

  @override
  Stream<TransportState> get state => _stateController.stream;

  @override
  TransportState get currentState => _state;

  @override
  Future<void> write(List<int> data) async {
    if (_writeChar != null) {
      await _writeChar!.write(data, withoutResponse: false);
    }
  }

  void _updateState(TransportState newState) {
    _state = newState;
    _stateController.add(_state);
  }
}
