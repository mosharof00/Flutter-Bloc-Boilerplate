import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/features/profile/domain/models/profile.dart';
import 'package:enterprise_mvvm/features/profile/domain/repositories/profile_repository.dart';

final class FakeProfileRepository implements ProfileRepository {
  @override
  Future<Result<List<Profile>>> fetch() async {
    return const Success<List<Profile>>(<Profile>[]);
  }
}
