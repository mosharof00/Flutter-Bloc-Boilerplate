import 'dart:async';

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

class _Catalog extends StatelessWidget {
  const _Catalog({required this.state, required this.viewModel});

  final PaginatedReady<Product> state;
  final ProductsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (state.items.isEmpty) {
      return const EmptyView();
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: RefreshIndicator(
            onRefresh: viewModel.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.items.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) =>
                  ProductCard(product: state.items[index]),
            ),
          ),
        ),
        _PageFooter(state: state, viewModel: viewModel),
      ],
    );
  }
}

class _PageFooter extends StatelessWidget {
  const _PageFooter({required this.state, required this.viewModel});

  final PaginatedReady<Product> state;
  final ProductsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!state.hasMore) {
      return const SizedBox(height: AppSpacing.md);
    }
    return Center(
      child: TextButton(
        key: const Key('products_load_more'),
        onPressed: () => unawaited(viewModel.loadMore()),
        child: Text(AppLocalizations.of(context).loadMore),
      ),
    );
  }
}
