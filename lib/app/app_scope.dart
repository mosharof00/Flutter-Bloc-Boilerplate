import 'package:enterprise_mvvm/app/app_dependencies.dart';
import 'package:flutter/widgets.dart';

final class AppScope extends InheritedWidget {
  const AppScope({required this.dependencies, required super.child, super.key});

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null) {
      throw StateError('AppScope is not in the widget tree.');
    }
    return scope.dependencies;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return oldWidget.dependencies != dependencies;
  }
}
