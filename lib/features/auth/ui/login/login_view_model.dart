import 'package:enterprise_mvvm/core/ui/view_model/base_view_model.dart';
import 'package:enterprise_mvvm/features/auth/domain/models/user.dart';
import 'package:enterprise_mvvm/features/auth/domain/repositories/auth_repository.dart';
import 'package:enterprise_mvvm/features/auth/ui/login/login_state.dart';

final class LoginViewModel extends BaseViewModel<LoginState> {
  LoginViewModel(this._repository) : super(const LoginInitial());

  final AuthRepository _repository;

  Future<void> submit({required String email, required String password}) {
    return run<User>(
      action: () => _repository.login(email: email, password: password),
      onLoading: () => const LoginLoading(),
      onSuccess: (User user) => const LoginSuccess(),
      onFailure: LoginFailure.new,
    );
  }
}
