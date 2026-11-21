import 'package:enterprise_mvvm/core/ui/view_model/base_view_model.dart';
import 'package:enterprise_mvvm/core/ui/view_model/view_state.dart';
import 'package:enterprise_mvvm/features/profile/domain/models/profile.dart';
import 'package:enterprise_mvvm/features/profile/domain/repositories/profile_repository.dart';

final class ProfileViewModel extends BaseViewModel<ViewState<List<Profile>>> {
  ProfileViewModel(this._repository) : super(const ViewIdle<List<Profile>>());

  final ProfileRepository _repository;

  Future<void> load() {
    return run<List<Profile>>(
      action: _repository.fetch,
      onLoading: () => const ViewLoading<List<Profile>>(),
      onSuccess: ViewSuccess<List<Profile>>.new,
      onFailure: ViewFailure<List<Profile>>.new,
    );
  }
}
