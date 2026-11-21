import 'package:enterprise_mvvm/core/network/auth_tokens.dart';
import 'package:enterprise_mvvm/core/network/token_refresher.dart';
import 'package:enterprise_mvvm/features/auth/data/services/auth_api_service.dart';

final class ApiTokenRefresher implements TokenRefresher {
  ApiTokenRefresher(this._api);

  final AuthApiService _api;

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    final response = await _api.refresh(refreshToken: refreshToken);
    return AuthTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }
}
