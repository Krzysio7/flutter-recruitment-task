import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'products_filters.freezed.dart';

@freezed
class ProductsFilters with _$ProductsFilters {
  const factory ProductsFilters({
    required bool promotionOnly,
    required bool favoritesOnly,
    required int? minPrice,
    required int? maxPrice,
    required Set<Tag>? tags,
    required Set<Tag> selectedTags,
  }) = _ProductsFilters;

  const ProductsFilters._();

  factory ProductsFilters.initial() => const ProductsFilters(
        promotionOnly: false,
        favoritesOnly: false,
        maxPrice: null,
        minPrice: null,
        tags: null,
        selectedTags: {},
      );

  ProductsFilters addSelectedTag(Tag tag) {
    return copyWith(
      selectedTags: selectedTags.toSet()..add(tag),
    );
  }

  ProductsFilters removeSelectedTag(Tag tag) {
    return copyWith(
      selectedTags: selectedTags.toSet()..remove(tag),
    );
  }
}
