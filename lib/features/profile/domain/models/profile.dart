import 'package:equatable/equatable.dart';

final class Profile with Equatable {
  const Profile({required this.id, required this.title});

  final String id;
  final String title;

  @override
  List<Object?> get props => <Object?>[id, title];
}
