import 'package:enterprise_mvvm/app/app_dependencies.dart';
import 'package:enterprise_mvvm/core/access/access_policy.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:enterprise_mvvm/core/services/connectivity_service.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/storage/preferences_store.dart';
import 'package:enterprise_mvvm/core/theme/locale_cubit.dart';
import 'package:enterprise_mvvm/core/theme/theme_cubit.dart';
import 'package:enterprise_mvvm/features/auth/ui/login/login_screen.dart';
import 'package:enterprise_mvvm/features/auth/ui/login/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_product_repository.dart';
import '../../fakes/fake_session_repository.dart';
import '../../support/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows a failure when the password is wrong', (
    WidgetTester tester,
  ) async {
    final preferences = PreferencesStore.memory();
    final viewModel = LoginViewModel(FakeAuthRepository());
    await tester.pumpWidget(
      buildTestApp(
        dependencies: _dependencies(preferences),
        child: LoginScreen(viewModel: viewModel),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('login_email')),
      'user@demo.com',
    );
    await tester.enterText(find.byKey(const Key('login_password')), 'nope');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('login_error')), findsOneWidget);
    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    await viewModel.close();
  });
}

AppDependencies _dependencies(PreferencesStore preferences) {
  return AppDependencies(
    config: const AppConfig(
      flavor: AppFlavor.dev,
      baseUrl: 'https://example.test',
      enableHttpLogs: false,
    ),
    authRepository: FakeAuthRepository(),
    sessionRepository: FakeSessionRepository(const SessionUnknown()),
    productRepository: FakeProductRepository(),
    themeCubit: ThemeCubit(preferences),
    localeCubit: LocaleCubit(preferences),
    connectivity: const DefaultConnectivityService(),
    accessPolicy: const AccessPolicy(),
  );
}
