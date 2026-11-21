import 'dart:async';

/// Signals emitted by the network layer. Features listen; the network layer
/// never imports a repository or a view model.
final class AuthEvents {
  final StreamController<void> _expired = StreamController<void>.broadcast();

  Stream<void> get sessionExpired => _expired.stream;

  void notifySessionExpired() {
    if (!_expired.isClosed) {
      _expired.add(null);
    }
  }

  Future<void> dispose() => _expired.close();
}
