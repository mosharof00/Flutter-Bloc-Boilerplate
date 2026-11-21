import 'dart:async';

import 'package:enterprise_mvvm/core/ui/view_model/base_view_model.dart';
import 'package:flutter/widgets.dart';

/// Creates a view model for a route and closes it when the route is removed.
class ViewModelHost<VM extends BaseViewModel<S>, S> extends StatefulWidget {
  const ViewModelHost({super.key, required this.create, required this.builder});

  final VM Function() create;
  final Widget Function(VM viewModel) builder;

  @override
  State<ViewModelHost<VM, S>> createState() => _ViewModelHostState<VM, S>();
}

class _ViewModelHostState<VM extends BaseViewModel<S>, S>
    extends State<ViewModelHost<VM, S>> {
  late final VM _viewModel = widget.create();

  @override
  void dispose() {
    unawaited(_viewModel.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_viewModel);
}
