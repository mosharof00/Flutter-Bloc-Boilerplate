import 'package:bloc_test/bloc_test.dart';
import 'package:enterprise_mvvm/core/ui/view_model/view_state.dart';
import 'package:enterprise_mvvm/features/profile/domain/models/profile.dart';
import 'package:enterprise_mvvm/features/profile/ui/profile/profile_view_model.dart';

import '../../fakes/fake_profile_repository.dart';

void main() {
  blocTest<ProfileViewModel, ViewState<List<Profile>>>(
    'load emits loading then an empty success',
    build: () => ProfileViewModel(FakeProfileRepository()),
    act: (ProfileViewModel viewModel) => viewModel.load(),
    expect: () => const <ViewState<List<Profile>>>[
      ViewLoading<List<Profile>>(),
      ViewSuccess<List<Profile>>(<Profile>[]),
    ],
  );
}
