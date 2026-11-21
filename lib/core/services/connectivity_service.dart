abstract interface class ConnectivityService {
  bool get isOnline;

  Stream<bool> get onStatusChanged;
}

final class DefaultConnectivityService implements ConnectivityService {
  const DefaultConnectivityService();

  @override
  bool get isOnline => true;

  @override
  Stream<bool> get onStatusChanged => const Stream<bool>.empty();
}
