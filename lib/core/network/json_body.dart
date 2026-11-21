import 'package:enterprise_mvvm/core/error/app_exception.dart';

Map<String, dynamic> asJsonMap(Object? data) {
  if (data is Map<String, dynamic>) {
    return data;
  }
  if (data is Map<dynamic, dynamic>) {
    final mapped = <String, dynamic>{};
    for (final MapEntry<dynamic, dynamic> entry in data.entries) {
      mapped['${entry.key}'] = entry.value;
    }
    return mapped;
  }
  throw const UnknownException();
}
