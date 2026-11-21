import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/access/permission.dart';
import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/core/network/auth_events.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/storage/preferences_store.dart';
import 'package:enterprise_mvvm/core/storage/storage_keys.dart';
import 'package:enterprise_mvvm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:enterprise_mvvm/features/auth/data/services/auth_local_service.dart';
import 'package:enterprise_mvvm/features/auth/data/services/fake_auth_api_service.dart';
import 'package:enterprise_mvvm/features/auth/domain/models/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fakes/memory_secure_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MemorySecureStore secure;
  late PreferencesStore preferences;
  late AuthEvents events;
  late AuthRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    secure = MemorySecureStore();
    preferences = PreferencesStore(await SharedPreferences.getInstance());
    events = AuthEvents();
    repository = _repository(secure, preferences, events);
  });

  tearDown(() async {
    await repository.dispose();
    await events.dispose();
  });

  test('rejects empty and invalid credentials', () async {
    final empty = await repository.login(email: '  ', password: '');
    expect(
      empty.fold<Failure?>(
        onSuccess: (_) => null,
        onFailure: (failure) => failure,
      ),
      isA<ValidationFailure>(),
    );

    final invalid = await repository.login(
      email: 'user@demo.com',
      password: 'nope',
    );
    expect(
      invalid.fold<Failure?>(
        onSuccess: (_) => null,
        onFailure: (failure) => failure,
      ),
      isA<InvalidCredentialsFailure>(),
    );
    expect(repository.current, isA<SessionUnknown>());
  });

  test('login restores the persisted active role', () async {
    await repository.login(email: 'both@demo.com', password: '123456');
    await repository.switchRole(AppRole.admin);
    expect(preferences.read(StorageKeys.activeRole), AppRole.admin.name);

    final restoredEvents = AuthEvents();
    final restored = _repository(secure, preferences, restoredEvents);
    final session = await restored.restore();
    expect(
      session.fold<Session?>(
        onSuccess: (value) => value,
        onFailure: (_) => null,
      ),
      isA<SessionAuthenticated>().having(
        (SessionAuthenticated value) => value.activeRole,
        'activeRole',
        AppRole.admin,
      ),
    );
    await restored.dispose();
    await restoredEvents.dispose();
  });

  test('switchRole rejects a role the user does not have', () async {
    await repository.login(email: 'user@demo.com', password: '123456');
    final result = await repository.switchRole(AppRole.admin);
    expect(
      result.fold<Failure?>(
        onSuccess: (_) => null,
        onFailure: (failure) => failure,
      ),
      isA<ForbiddenFailure>(),
    );
    expect(
      (repository.current as SessionAuthenticated).activeRole,
      AppRole.user,
    );
  });

  test(
    'server permissions are stored as given, including an empty set',
    () async {
      final result = await repository.login(
        email: 'limited@demo.com',
        password: '123456',
      );
      final user = result.fold<User?>(
        onSuccess: (value) => value,
        onFailure: (_) => null,
      );
      expect(user?.permissions, <Permission>{});
    },
  );

  test('sessionExpired clears the session', () async {
    await repository.login(email: 'user@demo.com', password: '123456');
    final expired = repository.session.first;
    events.notifySessionExpired();
    await expired;
    expect(repository.current, isA<SessionUnauthenticated>());
    expect(secure.values, isEmpty);
  });

  test('logout clears storage', () async {
    await repository.login(email: 'admin@demo.com', password: '123456');
    await repository.logout();
    expect(repository.current, isA<SessionUnauthenticated>());
    expect(secure.values, isEmpty);
  });

  test('fake api simulates token expiry and refresh', () async {
    final api = FakeAuthApiService(flavor: AppFlavor.dev);
    final login = await api.login(email: 'user@demo.com', password: '123456');
    expect(api.me(accessToken: login.accessToken), throwsA(isA<Exception>()));
    final refreshed = await api.refresh(refreshToken: login.refreshToken);
    final user = await api.me(accessToken: refreshed.accessToken);
    expect(user.email, 'user@demo.com');
  });

  test('fake api is rejected for prod', () {
    expect(() => FakeAuthApiService(flavor: AppFlavor.prod), throwsA(anything));
  });
}

AuthRepositoryImpl _repository(
  MemorySecureStore secure,
  PreferencesStore preferences,
  AuthEvents events,
) {
  return AuthRepositoryImpl(
    api: FakeAuthApiService(flavor: AppFlavor.dev),
    local: AuthLocalService(secure: secure, preferences: preferences),
    authEvents: events,
  );
}
