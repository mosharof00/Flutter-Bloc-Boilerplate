import 'package:enterprise_mvvm/app/app_dependencies.dart';
import 'package:enterprise_mvvm/core/access/access_policy.dart';
import 'package:enterprise_mvvm/core/config/app_config.dart';
import 'package:enterprise_mvvm/core/config/app_flavor.dart';
import 'package:enterprise_mvvm/core/result/result.dart';
import 'package:enterprise_mvvm/core/services/connectivity_service.dart';
import 'package:enterprise_mvvm/core/session/session.dart';
import 'package:enterprise_mvvm/core/storage/preferences_store.dart';
import 'package:enterprise_mvvm/core/theme/locale_cubit.dart';
import 'package:enterprise_mvvm/core/theme/theme_cubit.dart';
import 'package:enterprise_mvvm/features/products/domain/models/product.dart';
import 'package:enterprise_mvvm/features/products/domain/repositories/product_repository.dart';
import 'package:enterprise_mvvm/features/products/ui/products/products_screen.dart';
import 'package:enterprise_mvvm/features/products/ui/products/products_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_session_repository.dart';
import '../../support/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('loads the first page and fetches more on scroll', (
    WidgetTester tester,
  ) async {
    final preferences = PreferencesStore.memory();
    final repository = _PagingProductRepository();
    final viewModel = ProductsViewModel(repository);
    await tester.pumpWidget(
      buildTestApp(
        dependencies: AppDependencies(
          config: const AppConfig(
            flavor: AppFlavor.dev,
            baseUrl: 'https://example.test',
            enableHttpLogs: false,
          ),
          authRepository: FakeAuthRepository(),
          sessionRepository: FakeSessionRepository(const SessionUnknown()),
          productRepository: repository,
          themeCubit: ThemeCubit(preferences),
          localeCubit: LocaleCubit(preferences),
          connectivity: const DefaultConnectivityService(),
          accessPolicy: const AccessPolicy(),
        ),
        child: ProductsScreen(viewModel: viewModel),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Notebook'), findsOneWidget);
    expect(find.text('Chair'), findsNothing);

    await tester.drag(find.byType(Scrollable), const Offset(0, -4000));
    await tester.pump();
    await tester.pump();
    expect(find.text('Chair'), findsOneWidget);
    await viewModel.close();
  });
}

final class _PagingProductRepository implements ProductRepository {
  static const pageOne = <Product>[
    Product(id: 1, title: 'Notebook', price: 12.5),
    Product(id: 2, title: 'Desk lamp', price: 24),
    Product(id: 3, title: 'Ceramic mug', price: 8.75),
    Product(id: 4, title: 'Backpack', price: 46),
    Product(id: 5, title: 'Keyboard', price: 79),
    Product(id: 6, title: 'Headphones', price: 59.5),
    Product(id: 7, title: 'Water bottle', price: 15),
    Product(id: 8, title: 'Notebook stand', price: 32),
    Product(id: 9, title: 'Pen set', price: 6.25),
    Product(id: 10, title: 'Monitor', price: 220),
  ];

  static const pageTwo = <Product>[
    Product(id: 11, title: 'Chair', price: 140),
    Product(id: 12, title: 'Plant', price: 18),
  ];

  @override
  Future<Result<ProductPage>> fetch({required int page}) async {
    if (page == 1) {
      return const Success<ProductPage>(
        ProductPage(items: pageOne, hasMore: true),
      );
    }
    return const Success<ProductPage>(
      ProductPage(items: pageTwo, hasMore: false),
    );
  }
}
