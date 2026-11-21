import 'package:enterprise_mvvm/core/access/app_role.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/session/session_user.dart';
import 'package:enterprise_mvvm/features/auth/domain/models/user.dart';
import 'package:enterprise_mvvm/features/auth/ui/session/session_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_session_repository.dart';

void main() {
  const user = SessionUser(
    id: '1',
    displayName: 'Both Demo',
    roles: <AppRole>{AppRole.user, AppRole.admin},
  );

  test('switchRole and logout follow the repositories', () async {
    final session = FakeSessionRepository(
      const SessionAuthenticated(user: user, activeRole: AppRole.user),
    );
    final auth = FakeAuthRepository(
      loginResult: const Success<User>(
        User(
          id: '1',
          email: 'both@demo.com',
          displayName: 'Both Demo',
          roles: <AppRole>{AppRole.user, AppRole.admin},
        ),
      ),
    );
    final viewModel = SessionViewModel(
      sessionRepository: session,
      authRepository: auth,
    );

    await viewModel.switchRole(AppRole.admin);
    expect(
      viewModel.state,
      isA<SessionAuthenticated>().having(
        (SessionAuthenticated value) => value.activeRole,
        'activeRole',
        AppRole.admin,
      ),
    );

    await viewModel.logout();
    expect(auth.logoutCalls, 1);
    await viewModel.close();
    await session.dispose();
  });
}
