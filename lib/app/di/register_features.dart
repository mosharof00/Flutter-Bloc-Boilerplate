import 'package:enterprise_mvvm/app/di/register_auth.dart';
import 'package:enterprise_mvvm/app/di/register_profile.dart';
import 'package:get_it/get_it.dart';

// GENERATOR: feature-imports

void registerFeatures(GetIt getIt) {
  registerAuth(getIt);
  registerProfile(getIt);
  // GENERATOR: feature-registrations
}
