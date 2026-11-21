import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/features/profile/domain/models/profile.dart';

abstract interface class ProfileRepository {
  Future<Result<List<Profile>>> fetch();
}
