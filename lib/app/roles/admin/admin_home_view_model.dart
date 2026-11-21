import 'package:enterprise_mvvm/features/auth/ui/session/session_view_model.dart';

final class AdminHomeViewModel extends SessionViewModel {
  AdminHomeViewModel({
    required super.sessionRepository,
    required super.authRepository,
  });
}
