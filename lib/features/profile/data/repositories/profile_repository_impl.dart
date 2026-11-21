import 'package:enterprise_mvvm/core/error/app_exception.dart';
import 'package:enterprise_mvvm/core/error/failure.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/features/profile/data/dto/profile_dto.dart';
import 'package:enterprise_mvvm/features/profile/data/dto/profile_mapper.dart';
import 'package:enterprise_mvvm/features/profile/data/services/profile_api_service.dart';
import 'package:enterprise_mvvm/features/profile/domain/models/profile.dart';
import 'package:enterprise_mvvm/features/profile/domain/repositories/profile_repository.dart';

final class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._api);

  final ProfileApiService _api;

  @override
  Future<Result<List<Profile>>> fetch() async {
    try {
      final dtos = await _api.fetch();
      return Success<List<Profile>>(
        dtos.map((ProfileDto dto) => dto.toDomain()).toList(),
      );
    } on NetworkException {
      return const Err<List<Profile>>(NetworkFailure());
    } on UnauthorizedException {
      return const Err<List<Profile>>(UnauthorizedFailure());
    } on AppException {
      return const Err<List<Profile>>(UnknownFailure());
    }
  }
}
