import 'package:dio/dio.dart';
import 'package:enterprise_mvvm/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:enterprise_mvvm/features/profile/data/services/profile_api_service.dart';
import 'package:enterprise_mvvm/features/profile/domain/repositories/profile_repository.dart';
import 'package:get_it/get_it.dart';

void registerProfile(GetIt getIt) {
  getIt.registerLazySingleton<ProfileApiService>(
    () => ProfileApiServiceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileApiService>()),
  );
}
