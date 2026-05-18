import 'dart:async';
import 'dart:convert';
import '../transport/transport.dart';

enum Elm327Status {
  disconnected,
  initialising,
  ready,
  error,
}

class Elm327Controller {
  final Transport transport;
  Elm327Status _status = Elm327Status.disconnected;
  final _statusController = StreamController<Elm327Status>.broadcast();

  Completer<String>? _responseCompleter;
  final StringBuffer _rxBuffer = StringBuffer();

  Elm327Controller(this.transport) {
    transport.rx.listen(_onDataReceived);
    _statusController.add(_status);
  }

  Stream<Elm327Status> get status => _statusController.stream;
  Elm327Status get currentStatus => _status;

  void _onDataReceived(List<int> data) {
    final s = utf8.decode(data);
    _rxBuffer.write(s);
    if (s.contains('>')) {
      final fullResponse = _rxBuffer.toString();
      _rxBuffer.clear();
      _responseCompleter?.complete(fullResponse.replaceAll('>', '').trim());
      _responseCompleter = null;
    }
  }

  Future<String> sendCommand(String command, {Duration timeout = const Duration(seconds: 2)}) async {
    if (_responseCompleter != null) {
      throw Exception('Already awaiting response');
    }
    _responseCompleter = Completer<String>();
    await transport.write(utf8.encode('$command\r'));
    return _responseCompleter!.future.timeout(timeout);
  }

  Future<void> initialize() async {
    _updateStatus(Elm327Status.initialising);
    try {
      await sendCommand('ATZ');
      await sendCommand('ATE0');
      await sendCommand('ATL0');
      await sendCommand('ATS0');
      await sendCommand('ATH1');
      await sendCommand('ATAT1');
      await sendCommand('ATSP0');
      _updateStatus(Elm327Status.ready);
    } catch (e) {
      _updateStatus(Elm327Status.error);
      rethrow;
    }
  }

  void _updateStatus(Elm327Status newStatus) {
    _status = newStatus;
    _statusController.add(_status);
  }
}
