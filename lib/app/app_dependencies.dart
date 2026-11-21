import 'package:enterprise_mvvm/core/access/access_policy.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/services/connectivity_service.dart';
import 'package:enterprise_mvvm/core/session/session_repository.dart';
import 'package:enterprise_mvvm/core/theme/locale_cubit.dart';
import 'package:enterprise_mvvm/core/theme/theme_cubit.dart';
import 'package:enterprise_mvvm/features/auth/domain/repositories/auth_repository.dart';
import 'package:enterprise_mvvm/features/products/domain/repositories/product_repository.dart';

final class AppDependencies {
  const AppDependencies({
    required this.config,
    required this.authRepository,
    required this.sessionRepository,
    required this.productRepository,
    required this.themeCubit,
    required this.localeCubit,
    required this.connectivity,
    required this.accessPolicy,
  });

  final AppConfig config;
  final AuthRepository authRepository;
  final SessionRepository sessionRepository;
  final ProductRepository productRepository;
  final ThemeCubit themeCubit;
  final LocaleCubit localeCubit;
  final ConnectivityService connectivity;
  final AccessPolicy accessPolicy;
}
