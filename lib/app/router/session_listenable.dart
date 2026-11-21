import 'dart:async';

import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/session/session_repository.dart';
import 'package:flutter/foundation.dart';

final class SessionListenable extends ChangeNotifier {
  SessionListenable(this._repository) {
    _subscription = _repository.session.listen((Session _) {
      notifyListeners();
    });
  }

  final SessionRepository _repository;
  late final StreamSubscription<Session> _subscription;

  Session get session => _repository.current;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
