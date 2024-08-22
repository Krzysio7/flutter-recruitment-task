import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';

sealed class HomeState {
  const HomeState();
}

class Loading extends HomeState {
  const Loading();
}

class Loaded extends HomeState {
  const Loaded({
    required this.pages,
  });

  final List<ProductsPage> pages;

  bool get hasReachedMax {
    final lastPage = pages.lastOrNull;
    return lastPage?.totalPages == lastPage?.pageNumber;
  }
}

class LoadedWithIdFound extends Loaded {
  const LoadedWithIdFound({
    required this.pages,
    required this.indexOfFoundProduct,
  }) : super(
          pages: pages,
        );

  final List<ProductsPage> pages;
  final int indexOfFoundProduct;
}

class LoadedWithNoIdFound extends Loaded {
  const LoadedWithNoIdFound({
    required this.pages,
    required this.notFoundProductId,
  }) : super(
          pages: pages,
        );

  final List<ProductsPage> pages;
  final String notFoundProductId;
}

class Error extends HomeState {
  const Error({required this.error});

  final dynamic error;
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._productsRepository) : super(const Loading());

  final ProductsRepository _productsRepository;
  final List<ProductsPage> _pages = [];
  var _param = GetProductsPage(pageNumber: 1);

  Future<void> getNextPage() async {
    try {
      final totalPages = _pages.lastOrNull?.totalPages;
      if (totalPages != null && _param.pageNumber > totalPages) return;
      final newPage = await _productsRepository.getProductsPage(_param);
      _param = _param.increasePageNumber();
      _pages.add(newPage);
      emit(Loaded(pages: _pages));
    } catch (e) {
      emit(Error(error: e));
    }
  }

  FutureOr<void> findProductById(String id) async {
    final currentStateProductWithIndex =
        findProductWithIndexByIdInCurrentState(id);
    final productFound = currentStateProductWithIndex != null;
    if (productFound) {
      emit(
        LoadedWithIdFound(
          pages: _pages,
          indexOfFoundProduct: currentStateProductWithIndex.index,
        ),
      );
    } else {
      await fetchUntilIdFound(id);
    }
  }

  Future<void> fetchUntilIdFound(String id) async {
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
              findProductWithIndexByIdInCurrentState(id);
          emit(LoadedWithIdFound(
            pages: _pages,
            indexOfFoundProduct: currentStateProductWithIndex!.index,
          ));
          break;
        }

        if (_param.pageNumber > newPage.totalPages) {
          emit(LoadedWithNoIdFound(
            pages: _pages,
            notFoundProductId: id,
          ));
          break;
        }
      }
    } catch (e) {
      emit(Error(error: e));
    }
  }

  void scrollToProductPerformed() {
    emit(
      Loaded(pages: _pages),
    );
  }

  ({int index, Product product})? findProductWithIndexByIdInCurrentState(
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
