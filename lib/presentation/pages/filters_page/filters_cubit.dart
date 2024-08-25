import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/models/products_filters.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';

sealed class FiltersState {
  const FiltersState();
}

class Loading extends FiltersState {
  const Loading();
}

class ApplyFilters extends Loaded {
  const ApplyFilters({
    required super.currentFilters,
    required super.filtersChanged,
  });
}

class Loaded extends FiltersState {
  const Loaded({
    required this.currentFilters,
    required this.filtersChanged,
  });

  final ProductsFilters currentFilters;
  final bool filtersChanged;
}

class FiltersCubit extends Cubit<FiltersState> {
  FiltersCubit() : super(const Loading());

  late ProductsFilters _defaultFilters;

  void init({
    required ProductsFilters defaultFilters,
    required ProductsFilters currentFilters,
  }) {
    _defaultFilters = defaultFilters;
    emit(
      Loaded(
        currentFilters: currentFilters,
        filtersChanged: defaultFilters != currentFilters,
      ),
    );
  }

  void changePromotionOnly(bool value) {
    final currentStateFilters = state as Loaded;
    final newFilters = currentStateFilters.currentFilters.copyWith(
      promotionOnly: value,
    );
    emit(
      Loaded(
        currentFilters: newFilters,
        filtersChanged: newFilters != _defaultFilters,
      ),
    );
  }

  void changeFavoritesOnly(bool value) {
    final currentStateFilters = state as Loaded;
    final newFilters = currentStateFilters.currentFilters.copyWith(
      favoritesOnly: value,
    );
    emit(
      Loaded(
        currentFilters: newFilters,
        filtersChanged: newFilters != _defaultFilters,
      ),
    );
  }

  void changeMinPrice(int? minPrice) {
    final currentStateFilters = state as Loaded;
    final newFilters = currentStateFilters.currentFilters.copyWith(
      minPrice: minPrice ?? _defaultFilters.minPrice,
    );
    emit(
      Loaded(
        currentFilters: newFilters,
        filtersChanged: newFilters != _defaultFilters,
      ),
    );
  }

  void changeMaxPrice(int? maxPrice) {
    final currentStateFilters = state as Loaded;
    final newFilters = currentStateFilters.currentFilters.copyWith(
      maxPrice: maxPrice ?? _defaultFilters.maxPrice,
    );
    emit(
      Loaded(
        currentFilters: newFilters,
        filtersChanged: newFilters != _defaultFilters,
      ),
    );
  }

  void addTag(Tag tag) {
    final currentStateFilters = state as Loaded;
    final newFilters = currentStateFilters.currentFilters.addSelectedTag(tag);
    emit(
      Loaded(
        currentFilters: newFilters,
        filtersChanged: newFilters != _defaultFilters,
      ),
    );
  }

  void removeTag(Tag tag) {
    final currentStateFilters = state as Loaded;
    final newFilters =
        currentStateFilters.currentFilters.removeSelectedTag(tag);
    emit(
      Loaded(
        currentFilters: newFilters,
        filtersChanged: newFilters != _defaultFilters,
      ),
    );
  }

  void applyFilters() {
    final loadedState = state as Loaded;
    emit(
      ApplyFilters(
        currentFilters: loadedState.currentFilters,
        filtersChanged: loadedState.filtersChanged,
      ),
    );
  }

  void reset() {
    emit(
      ApplyFilters(
        currentFilters: _defaultFilters,
        filtersChanged: false,
      ),
    );
  }
}
