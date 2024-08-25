import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_filters.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

class Loaded extends HomeState {
  const Loaded({
    required this.products,
    required this.hasReachedMax,
    required this.defaultFilters,
    required this.currentFilters,
  });

  final List<Product> products;
  final ProductsFilters? currentFilters;
  final ProductsFilters? defaultFilters;
  final bool hasReachedMax;

  bool get areFiltersActive => defaultFilters != currentFilters;

  @override
  List<Object?> get props => [
        products,
        currentFilters,
        defaultFilters,
        hasReachedMax,
      ];
}

class LoadedWithIdFound extends Loaded {
  const LoadedWithIdFound({
    required super.products,
    required super.hasReachedMax,
    required super.defaultFilters,
    required super.currentFilters,
    required this.indexOfFoundProduct,
  });

  final int indexOfFoundProduct;
}

class LoadedWithNoIdFound extends Loaded {
  const LoadedWithNoIdFound({
    required super.products,
    required super.currentFilters,
    required super.defaultFilters,
    required super.hasReachedMax,
    required this.notFoundProductId,
  });

  final String notFoundProductId;
}

class Loading extends HomeState {
  const Loading();

  @override
  List<Object?> get props => [];
}

class Error extends HomeState {
  final dynamic error;

  const Error({required this.error});

  @override
  List<Object?> get props => [];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._productsRepository) : super(const Loading());

  final ProductsRepository _productsRepository;
  final List<ProductsPage> _pages = [];

  ProductsFilters? _currentFilters;
  ProductsFilters? _initialFilters;

  var _param = const GetProductsPage(pageNumber: 1);

  Future<void> init({
    required String? scrollToProductId,
  }) async {
    await _fetchFilters();
    if (scrollToProductId != null) {
      await findProductById(scrollToProductId);
    } else {
      await getNextPage();
    }
  }

  void applyFilters(ProductsFilters filters) {
    emit(const Loading());
    _currentFilters = filters;
    _resetPagesData();
    getNextPage();
  }

  Future<void> findProductById(String id) async {
    final currentStateProductWithIndex =
        _findProductWithIndexByIdInCurrentState(id);
    final productFound = currentStateProductWithIndex != null;

    if (productFound) {
      emit(
        LoadedWithIdFound(
          products: _pages.allProducts,
          indexOfFoundProduct: currentStateProductWithIndex.index,
          hasReachedMax: _hasReachedMax,
          defaultFilters: _initialFilters,
          currentFilters: _currentFilters,
        ),
      );
    } else {
      await _fetchUntilIdFound(id);
    }
  }

  Future<void> getNextPage() async {
    try {
      final totalPages = _pages.lastOrNull?.totalPages;
      if (totalPages != null && _param.pageNumber > totalPages) return;
      final newPage = await _productsRepository.getProductsPage(_param);
      _param = _param.increasePageNumber();
      _pages.add(newPage);

      emit(
        Loaded(
          products: _filterProductsIfNeed(_pages.allProducts),
          currentFilters: _currentFilters,
          hasReachedMax: _hasReachedMax,
          defaultFilters: _initialFilters,
        ),
      );
    } catch (e) {
      emit(Error(error: e));
    }
  }

  void scrollToProductPerformed() {
    emit(
      Loaded(
        products: _pages.allProducts,
        currentFilters: _currentFilters,
        hasReachedMax: _hasReachedMax,
        defaultFilters: _initialFilters,
      ),
    );
  }

  Future<void> _fetchFilters() async {
    var param = const GetProductsPage(pageNumber: 1);
    final List<ProductsPage> pages = [];
    int? totalPages;

    while ((totalPages != null && totalPages < param.pageNumber) ||
        totalPages == null) {
      final newPage = await _productsRepository.getProductsPage(param);
      param = param.increasePageNumber();
      pages.add(newPage);
      totalPages = pages.lastOrNull?.totalPages;
    }

    final initialFilters = ProductsFilters.initial().copyWith(
      maxPrice: pages.largestPrice,
      tags: pages.uniqueTags,
    );

    _initialFilters = initialFilters;
    _currentFilters = _initialFilters;
  }

  void _resetPagesData() {
    _pages.clear();
    _param = _param.reset();
  }

  Future<void> _fetchUntilIdFound(String id) async {
    try {
      while (true) {
        final newPage = await _productsRepository.getProductsPage(_param);
        _param = _param.increasePageNumber();
        _pages.add(newPage);

        final productFound = newPage.products.firstWhereOrNull(
          (product) => product.id == id,
        );

        if (productFound != null) {
          final currentStateProductWithIndex =
              _findProductWithIndexByIdInCurrentState(id);

          emit(LoadedWithIdFound(
            products: _pages.allProducts,
            indexOfFoundProduct: currentStateProductWithIndex!.index,
            hasReachedMax: _hasReachedMax,
            defaultFilters: _initialFilters,
            currentFilters: _currentFilters,
          ));
          break;
        }

        if (_param.pageNumber > newPage.totalPages) {
          emit(LoadedWithNoIdFound(
            products: _pages.allProducts,
            notFoundProductId: id,
            hasReachedMax: _hasReachedMax,
            defaultFilters: _initialFilters,
            currentFilters: _currentFilters,
          ));
          break;
        }
      }
    } catch (e) {
      emit(Error(error: e));
    }
  }

  List<Product> _filterProducts(List<Product> products) {
    final filterPromotionOnly = _currentFilters?.promotionOnly ?? false;
    final filterFavoritesOnly = _currentFilters?.favoritesOnly ?? false;
    final filterMinPrice = _currentFilters?.minPrice != null;
    final filterMaxPrice = _currentFilters?.maxPrice != null;
    final filterByTags = _currentFilters?.selectedTags.isNotEmpty ?? false;

    Iterable<Product> filteredProducts = products;

    if (filterPromotionOnly) {
      filteredProducts = filteredProducts.where(
        (product) => product.onPromotion == _currentFilters!.promotionOnly,
      );
    }

    if (filterFavoritesOnly) {
      filteredProducts = filteredProducts.where(
        (product) => product.isFavorite == _currentFilters!.favoritesOnly,
      );
    }

    if (filterMinPrice) {
      filteredProducts = filteredProducts.where(
        (product) => product.currentPrice.amount >= _currentFilters!.minPrice!,
      );
    }

    if (filterMaxPrice) {
      filteredProducts = filteredProducts.where(
        (product) => product.currentPrice.amount <= _currentFilters!.maxPrice!,
      );
    }

    if (filterByTags) {
      filteredProducts = filteredProducts.where(
        (product) =>
            product.tags.toSet().containsAll(_currentFilters!.selectedTags),
      );
    }

    return filteredProducts.toList();
  }

  List<Product> _filterProductsIfNeed(List<Product> products) {
    if (_currentFilters != null) {
      return _filterProducts(products);
    }

    return products;
  }

  bool get _hasReachedMax {
    final lastPage = _pages.lastOrNull;

    return lastPage != null && lastPage.totalPages == lastPage.pageNumber;
  }

  ({int index, Product product})? _findProductWithIndexByIdInCurrentState(
      String id) {
    final productWithIndex = _pages
        .map((page) => page.products)
        .expand((product) => product)
        .indexed
        .firstWhereOrNull(
          (productWithIndex) => productWithIndex.$2.id == id,
        );

    return productWithIndex != null
        ? (index: productWithIndex.$1, product: productWithIndex.$2)
        : null;
  }
}

extension ProductsPagesX on List<ProductsPage> {
  List<Product> get allProducts =>
      map((page) => page.products).expand((product) => product).toList();

  int get largestPrice {
    double maxPrice = 0.0;

    for (Product product in allProducts) {
      double currentPrice = product.currentPrice.amount;

      if (currentPrice > maxPrice) {
        maxPrice = currentPrice;
      }
    }

    return maxPrice.ceil();
  }

  Set<Tag> get uniqueTags {
    final Set<Tag> uniqueTags = {};

    for (Product product in allProducts) {
      uniqueTags.addAll(product.tags);
    }

    return uniqueTags;
  }
}
