import 'package:enterprise_mvvm/app/di/register_auth.dart';
import 'package:enterprise_mvvm/app/di/register_products.dart';
import 'package:get_it/get_it.dart';

// GENERATOR: feature-imports

void registerFeatures(GetIt getIt) {
  registerAuth(getIt);
  registerProducts(getIt);
  // GENERATOR: feature-registrations
}
