import 'dart:async';

import 'package:enterprise_mvvm/core/error/failure_message.dart';
import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/core/ui/view_model/paginated_view_model.dart';
import 'package:enterprise_mvvm/core/ui/widgets/empty_view.dart';
import 'package:enterprise_mvvm/core/ui/widgets/error_view.dart';
import 'package:enterprise_mvvm/core/ui/widgets/gradient_scaffold.dart';
import 'package:enterprise_mvvm/core/ui/widgets/shimmer_list.dart';
import 'package:enterprise_mvvm/features/products/domain/models/product.dart';
import 'package:enterprise_mvvm/features/products/ui/products/product_card.dart';
import 'package:enterprise_mvvm/features/products/ui/products/products_view_model.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({required this.viewModel, super.key});

  final ProductsViewModel viewModel;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.viewModel.refresh());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GradientScaffold(
      appBar: AppBar(title: Text(l10n.productsTitle)),
      body: BlocBuilder<ProductsViewModel, PaginatedState<Product>>(
        bloc: widget.viewModel,
        builder: (BuildContext context, PaginatedState<Product> state) {
          return switch (state) {
            PaginatedIdle<Product>() ||
            PaginatedLoading<Product>() => const ShimmerList(),
            PaginatedFailure<Product>(:final failure) => ErrorView(
              failure: failure,
              onRetry: widget.viewModel.refresh,
            ),
            PaginatedReady<Product>() => _Catalog(
              state: state,
              viewModel: widget.viewModel,
            ),
          };
        },
      ),
    );
  }
}

class _Catalog extends StatefulWidget {
  const _Catalog({required this.state, required this.viewModel});

  final PaginatedReady<Product> state;
  final ProductsViewModel viewModel;

  @override
  State<_Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<_Catalog> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) {
      return;
    }
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      unawaited(widget.viewModel.loadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.items.isEmpty) {
      return const EmptyView();
    }
    final l10n = AppLocalizations.of(context);
    final footerCount = state.isLoadingMore || state.loadMoreFailure != null
        ? 1
        : 0;
    return RefreshIndicator(
      onRefresh: widget.viewModel.refresh,
      child: ListView.separated(
        controller: _controller,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: state.items.length + footerCount,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          if (index >= state.items.length) {
            if (state.loadMoreFailure != null) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: <Widget>[
                    Text(
                      failureMessage(l10n, state.loadMoreFailure!),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      key: const Key('products_retry_more'),
                      onPressed: () => unawaited(widget.viewModel.loadMore()),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: CircularProgressIndicator(
                  key: Key('products_loading_more'),
                ),
              ),
            );
          }
          return ProductCard(product: state.items[index]);
        },
      ),
    );
  }
}
