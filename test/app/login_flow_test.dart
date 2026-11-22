import 'package:enterprise_mvvm/app/bootstrap.dart';
import 'package:enterprise_mvvm/app/di/injection.dart';
import 'package:enterprise_mvvm/app/router/app_routes.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:enterprise_mvvm/core/storage/preferences_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  testWidgets('dev login opens the user shell', (WidgetTester tester) async {
    final container = await buildContainer(
      const AppConfig(
        flavor: AppFlavor.dev,
        baseUrl: 'https://example.test',
        enableHttpLogs: false,
      ),
      preferencesStore: PreferencesStore.memory(),
    );
    await tester.pumpWidget(startApp(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const Key('login_email')), findsOneWidget);
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('login_email')),
      'user@demo.com',
    );
    await tester.enterText(find.byKey(const Key('login_password')), '123456');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Signed in as User Demo'), findsOneWidget);
    expect(find.text('Active role: User'), findsOneWidget);
  });

  test('router remembers an admin destination', () {
    expect(AppRoutes.adminHome, '/admin');
  });
}
