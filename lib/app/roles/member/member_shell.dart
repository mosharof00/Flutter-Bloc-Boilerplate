import 'dart:async';

import 'package:enterprise_mvvm/app/app_scope.dart';
import 'package:enterprise_mvvm/app/roles/member/member_home_screen.dart';
import 'package:enterprise_mvvm/app/roles/member/member_home_view_model.dart';
import 'package:enterprise_mvvm/core/theme/app_tokens.dart';
import 'package:enterprise_mvvm/core/ui/widgets/app_svg_icon.dart';
import 'package:enterprise_mvvm/features/products/ui/products/products_screen.dart';
import 'package:enterprise_mvvm/features/products/ui/products/products_view_model.dart';
import 'package:enterprise_mvvm/gen/assets.gen.dart';
import 'package:enterprise_mvvm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

/// The default shell. One role, two places: the signed-in home and the
/// product catalog. A second role is a separate shell added with new_role.
class MemberShell extends StatefulWidget {
  const MemberShell({super.key});

  @override
  State<MemberShell> createState() => _MemberShellState();
}

class _MemberShellState extends State<MemberShell> {
  MemberHomeViewModel? _session;
  ProductsViewModel? _products;
  var _index = 0;
  var _productsReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dependencies = AppScope.of(context);
    _session ??= MemberHomeViewModel(
      sessionRepository: dependencies.sessionRepository,
      authRepository: dependencies.authRepository,
    );
    _products ??= ProductsViewModel(dependencies.productRepository);
  }

  @override
  void dispose() {
    final session = _session;
    final products = _products;
    if (session != null) {
      unawaited(session.close());
    }
    if (products != null) {
      unawaited(products.close());
    }
    super.dispose();
  }

  void _select(int index) {
    setState(() {
      _index = index;
      if (index == 1) {
        _productsReady = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final products = _products;
    if (session == null || products == null) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          MemberHomeScreen(viewModel: session),
          _productsReady
              ? ProductsScreen(viewModel: products)
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: _MemberNav(
        index: _index,
        homeLabel: l10n.homeTitle,
        productsLabel: l10n.productsTitle,
        onSelected: _select,
      ),
    );
  }
}

class _MemberNav extends StatelessWidget {
  const _MemberNav({
    required this.index,
    required this.homeLabel,
    required this.productsLabel,
    required this.onSelected,
  });

  final int index;
  final String homeLabel;
  final String productsLabel;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tabs = <({String outline, String fill, String label, Key key})>[
      (
        outline: Assets.icons.homeIcon,
        fill: Assets.icons.homeFillIcon,
        label: homeLabel,
        key: const Key('nav_home'),
      ),
      (
        outline: Assets.icons.blockIcon,
        fill: Assets.icons.blockFillIcon,
        label: productsLabel,
        key: const Key('nav_products'),
      ),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: GNav(
            selectedIndex: index,
            onTabChange: onSelected,
            haptic: false,
            backgroundColor: scheme.surface,
            color: AppPalette.hint,
            activeColor: scheme.onPrimary,
            tabBackgroundColor: scheme.primary,
            gap: AppSpacing.sm,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + AppSpacing.xs,
            ),
            duration: const Duration(milliseconds: 300),
            tabs: <GButton>[
              for (final (tabIndex, tab) in tabs.indexed)
                GButton(
                  key: tab.key,
                  icon: Icons.circle,
                  text: tab.label,
                  leading: AppSvgIcon(
                    index == tabIndex ? tab.fill : tab.outline,
                    size: 20,
                    color: index == tabIndex
                        ? scheme.onPrimary
                        : AppPalette.hint,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
