import 'package:enterprise_mvvm/app/di/injection.dart';
import 'package:enterprise_mvvm/app/roles/user/user_shell.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/storage/preferences_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const config = AppConfig(
    flavor: AppFlavor.dev,
    baseUrl: 'https://example.test',
    enableHttpLogs: false,
  );

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  testWidgets('a user with both roles can switch and log out', (
    WidgetTester tester,
  ) async {
    final container = await buildContainer(
      config,
      preferencesStore: PreferencesStore.memory(),
    );
    await container.dependencies.authRepository.login(
      email: 'both@demo.com',
      password: '123456',
    );
    await tester.pumpWidget(
      buildTestApp(
        dependencies: container.dependencies,
        child: const UserShell(),
      ),
    );
    await tester.pump();

    expect(find.text('Signed in as Both Demo'), findsOneWidget);
    expect(find.text('Active role: User'), findsOneWidget);
    await tester.tap(find.byKey(const Key('role_switch')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Active role: Admin'), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme_toggle')));
    await tester.pump();
    expect(container.dependencies.themeCubit.state, ThemeMode.dark);

    await tester.tap(find.byKey(const Key('locale_toggle')));
    await tester.pump();
    expect(container.dependencies.localeCubit.state.languageCode, 'bn');

    await tester.tap(find.byKey(const Key('logout')));
    await tester.pump();
    await tester.pump();
    expect(
      container.dependencies.sessionRepository.current,
      isA<SessionUnauthenticated>(),
    );
    await container.dependencies.themeCubit.close();
    await container.dependencies.localeCubit.close();
  });

  testWidgets('a user can open products and profile tabs', (
    WidgetTester tester,
  ) async {
    final container = await buildContainer(
      config,
      preferencesStore: PreferencesStore.memory(),
    );
    await container.dependencies.authRepository.login(
      email: 'user@demo.com',
      password: '123456',
    );
    await tester.pumpWidget(
      buildTestApp(
        dependencies: container.dependencies,
        child: const UserShell(),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('role_switch')), findsNothing);
    expect(find.text('Signed in as User Demo'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_products')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Products'), findsWidgets);

    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Profile'), findsWidgets);
    expect(find.byKey(const Key('profile_display_name')), findsOneWidget);
    expect(find.text('User Demo'), findsOneWidget);

    await container.dependencies.themeCubit.close();
    await container.dependencies.localeCubit.close();
  });
}
