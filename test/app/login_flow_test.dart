import 'package:enterprise_mvvm/app/bootstrap.dart';
import 'package:enterprise_mvvm/app/di/injection.dart';
import 'package:enterprise_mvvm/app/router/app_routes.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dev login opens the member shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    final container = await buildContainer(
      const AppConfig(
        flavor: AppFlavor.dev,
        baseUrl: 'https://example.test',
        enableHttpLogs: false,
      ),
    );
    await tester.pumpWidget(startApp(container));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_email')), findsOneWidget);
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('login_email')),
      'member@demo.com',
    );
    await tester.enterText(find.byKey(const Key('login_password')), '123456');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Signed in as Member Demo'), findsOneWidget);
    expect(find.text('Active role: Member'), findsOneWidget);
    expect(find.byKey(const Key('role_switch')), findsNothing);
    expect(container.dependencies.sessionRepository.current, isNotNull);
    await container.dependencies.themeCubit.close();
    await container.dependencies.localeCubit.close();
  });

  test('router remembers an admin destination', () {
    expect(AppRoutes.adminHome, '/admin');
  });
}
