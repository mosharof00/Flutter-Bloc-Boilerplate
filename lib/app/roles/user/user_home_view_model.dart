import 'package:enterprise_mvvm/features/auth/ui/session/session_view_model.dart';

final class UserHomeViewModel extends SessionViewModel {
  UserHomeViewModel({
    required super.sessionRepository,
    required super.authRepository,
  });
}
