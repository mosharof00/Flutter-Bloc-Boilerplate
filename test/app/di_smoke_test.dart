import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/app/di/app_container.dart';
import 'package:enterprise_mvvm/app/di/injection.dart';
import 'package:enterprise_mvvm/app/roles/role_context.dart';
import 'package:enterprise_mvvm/core/access/access_policy.dart';
import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:enterprise_mvvm/core/network/auth_events.dart';
import 'package:enterprise_mvvm/core/network/dio_client.dart';
import 'package:enterprise_mvvm/core/services/analytics_service.dart';
import 'package:enterprise_mvvm/core/services/app_logger.dart';
import 'package:enterprise_mvvm/core/services/connectivity_service.dart';
import 'package:enterprise_mvvm/core/services/crash_reporter.dart';
import 'package:enterprise_mvvm/core/services/feature_flags.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/session/session_repository.dart';
import 'package:enterprise_mvvm/core/session/session_user.dart';
import 'package:enterprise_mvvm/core/storage/preferences_store.dart';
import 'package:enterprise_mvvm/core/storage/secure_store.dart';
import 'package:enterprise_mvvm/core/storage/token_store.dart';
import 'package:enterprise_mvvm/core/theme/locale_cubit.dart';
import 'package:enterprise_mvvm/core/theme/theme_cubit.dart';
import 'package:enterprise_mvvm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:enterprise_mvvm/features/auth/data/services/auth_api_service.dart';
import 'package:enterprise_mvvm/features/auth/data/services/auth_api_service_impl.dart';
import 'package:enterprise_mvvm/features/auth/data/services/auth_local_service.dart';
import 'package:enterprise_mvvm/features/auth/data/services/fake_auth_api_service.dart';
import 'package:enterprise_mvvm/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  for (final flavor in AppFlavor.values) {
    test('resolves every $flavor registration', () async {
      final container = await buildContainer(
        AppConfig(
          flavor: flavor,
          baseUrl: 'https://example.test',
          enableHttpLogs: flavor != AppFlavor.prod,
        ),
      );
      final getIt = container.getIt;
      expect(getIt<AppConfig>().flavor, flavor);
      expect(getIt<AppLogger>(), isNotNull);
      expect(getIt<CrashReporter>(), isA<CrashReporter>());
      expect(getIt<AnalyticsService>(), isA<AnalyticsService>());
      expect(getIt<ConnectivityService>(), isA<ConnectivityService>());
      expect(getIt<FeatureFlags>(), isA<FeatureFlags>());
      expect(getIt<AuthEvents>(), isA<AuthEvents>());
      expect(getIt<AccessPolicy>(), isA<AccessPolicy>());
      expect(getIt<SecureStore>(), isA<SecureStore>());
      expect(getIt<PreferencesStore>(), isA<PreferencesStore>());
      expect(getIt<TokenStore>(), isA<TokenStore>());
      expect(getIt<Dio>(), isA<Dio>());
      expect(getIt<Dio>(instanceName: DioNames.refresh), isA<Dio>());
      expect(getIt<AuthApiService>(), isA<AuthApiService>());
      expect(getIt<AuthLocalService>(), isA<AuthLocalService>());
      expect(getIt<ThemeCubit>(), isA<ThemeCubit>());
      expect(getIt<LocaleCubit>(), isA<LocaleCubit>());

      final auth = getIt<AuthRepository>();
      final session = getIt<SessionRepository>();
      expect(auth, same(session));
      expect(auth, isA<AuthRepositoryImpl>());
      if (flavor == AppFlavor.dev) {
        expect(getIt<AuthApiService>(), isA<FakeAuthApiService>());
      } else {
        expect(getIt<AuthApiService>(), isA<AuthApiServiceImpl>());
      }

      container.openSessionScope(
        const SessionAuthenticated(
          activeRole: AppRole.member,
          user: SessionUser(
            id: 'user-1',
            displayName: 'Ada',
            roles: <AppRole>{AppRole.member, AppRole.admin},
          ),
        ),
      );
      expect(getIt<SessionContext>().userId, 'user-1');
      await container.openRoleScope(AppRole.member);
      expect(getIt<RoleContext>().role, AppRole.member);
      await container.openRoleScope(AppRole.admin);
      expect(getIt<RoleContext>().role, AppRole.admin);
      await container.closeSessionScope();
      expect(getIt.hasScope(AppContainer.sessionScopeName), isFalse);
      expect(getIt.hasScope(AppContainer.roleScopeName), isFalse);
      await getIt<ThemeCubit>().close();
      await getIt<LocaleCubit>().close();
    });
  }
}
