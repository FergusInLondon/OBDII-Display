import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'transport.dart';

class MockTransport implements Transport {
  final _stateController = StreamController<TransportState>.broadcast();
  final _rxController = StreamController<List<int>>.broadcast();
  TransportState _state = TransportState.disconnected;

  MockTransport() {
    _stateController.add(_state);
  }

  @override
  Future<void> connect() async {
    _updateState(TransportState.connecting);
    await Future.delayed(const Duration(milliseconds: 500));
    _updateState(TransportState.connected);
  }

  @override
  Future<void> disconnect() async {
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
    if (_state != TransportState.connected) return;

    final command = utf8.decode(data).trim().toUpperCase();
    String response = '';

    if (command.startsWith('AT')) {
      response = _handleAtCommand(command);
    } else {
      response = _handleObdCommand(command);
    }

    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 50));
    _rxController.add(utf8.encode('$response\r>'));
  }

  String _handleAtCommand(String command) {
    switch (command) {
      case 'ATZ':
        return 'ELM327 v2.1';
      case 'ATE0':
      case 'ATL0':
      case 'ATS0':
      case 'ATH1':
      case 'ATAT1':
      case 'ATSP0':
        return 'OK';
      case 'ATRV':
        return '${(12 + Random().nextDouble() * 2).toStringAsFixed(1)}V';
      case 'ATDP':
        return 'ISO 15765-4 (CAN 11/500)';
      default:
        return 'OK';
    }
  }

  String _handleObdCommand(String command) {
    if (command == '0100') {
      return '41 00 BE 3E A8 11'; // Supported PIDs 01-20
    }
    if (command == '0120') {
      return '41 20 80 00 00 01'; // Supported PIDs 21-40
    }

    // Mode 01 PIDs
    if (command.startsWith('01')) {
      final pid = command.substring(2);
      switch (pid) {
        case '0C': // RPM
          final rpm = 800 + Random().nextInt(5000);
          final val = (rpm * 4).toInt();
          return '41 0C ${(val >> 8).toRadixString(16).padLeft(2, '0')} ${(val & 0xFF).toRadixString(16).padLeft(2, '0')}';
        case '0D': // Speed
          final speed = 40 + Random().nextInt(60);
          return '41 0D ${speed.toRadixString(16).padLeft(2, '0')}';
        case '05': // Coolant
          return '41 05 7F'; // 127 - 40 = 87C
        case '11': // Throttle
          return '41 11 66'; // 102/255 = 40%
        case '04': // Load
          return '41 04 80'; // 128/255 = 50%
        case '0F': // IAT
          return '41 0F 4B'; // 75 - 40 = 35C
        case '10': // MAF
          return '41 10 03 20'; // 800 / 100 = 8.0 g/s
        case '06': // STFT
          return '41 06 88'; // (136-128)*100/128 = 6.25%
        default:
          return '41 $pid 00';
      }
    }

    if (command == '03') {
      return '43 01 71 00 00 00 00'; // P0171
    }

    if (command == '07') {
      return '47 00'; // No pending codes
    }

    if (command == '04') {
      return '44 OK';
    }

    return 'NO DATA';
  }

  void _updateState(TransportState newState) {
    _state = newState;
    _stateController.add(_state);
  }
}
