import 'package:enterprise_mvvm/core/network/auth_tokens.dart';

abstract interface class TokenRefresher {
  Future<AuthTokens> refresh(String refreshToken);
}
