// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'products_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProductsFilters {
  bool get promotionOnly => throw _privateConstructorUsedError;
  bool get favoritesOnly => throw _privateConstructorUsedError;
  int? get minPrice => throw _privateConstructorUsedError;
  int? get maxPrice => throw _privateConstructorUsedError;
  Set<Tag>? get tags => throw _privateConstructorUsedError;
  Set<Tag> get selectedTags => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProductsFiltersCopyWith<ProductsFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductsFiltersCopyWith<$Res> {
  factory $ProductsFiltersCopyWith(
          ProductsFilters value, $Res Function(ProductsFilters) then) =
      _$ProductsFiltersCopyWithImpl<$Res, ProductsFilters>;
  @useResult
  $Res call(
      {bool promotionOnly,
      bool favoritesOnly,
      int? minPrice,
      int? maxPrice,
      Set<Tag>? tags,
      Set<Tag> selectedTags});
}

/// @nodoc
class _$ProductsFiltersCopyWithImpl<$Res, $Val extends ProductsFilters>
    implements $ProductsFiltersCopyWith<$Res> {
  _$ProductsFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? promotionOnly = null,
    Object? favoritesOnly = null,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? tags = freezed,
    Object? selectedTags = null,
  }) {
    return _then(_value.copyWith(
      promotionOnly: null == promotionOnly
          ? _value.promotionOnly
          : promotionOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      favoritesOnly: null == favoritesOnly
          ? _value.favoritesOnly
          : favoritesOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Set<Tag>?,
      selectedTags: null == selectedTags
          ? _value.selectedTags
          : selectedTags // ignore: cast_nullable_to_non_nullable
              as Set<Tag>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductsFiltersImplCopyWith<$Res>
    implements $ProductsFiltersCopyWith<$Res> {
  factory _$$ProductsFiltersImplCopyWith(_$ProductsFiltersImpl value,
          $Res Function(_$ProductsFiltersImpl) then) =
      __$$ProductsFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool promotionOnly,
      bool favoritesOnly,
      int? minPrice,
      int? maxPrice,
      Set<Tag>? tags,
      Set<Tag> selectedTags});
}

/// @nodoc
class __$$ProductsFiltersImplCopyWithImpl<$Res>
    extends _$ProductsFiltersCopyWithImpl<$Res, _$ProductsFiltersImpl>
    implements _$$ProductsFiltersImplCopyWith<$Res> {
  __$$ProductsFiltersImplCopyWithImpl(
      _$ProductsFiltersImpl _value, $Res Function(_$ProductsFiltersImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? promotionOnly = null,
    Object? favoritesOnly = null,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? tags = freezed,
    Object? selectedTags = null,
  }) {
    return _then(_$ProductsFiltersImpl(
      promotionOnly: null == promotionOnly
          ? _value.promotionOnly
          : promotionOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      favoritesOnly: null == favoritesOnly
          ? _value.favoritesOnly
          : favoritesOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as Set<Tag>?,
      selectedTags: null == selectedTags
          ? _value._selectedTags
          : selectedTags // ignore: cast_nullable_to_non_nullable
              as Set<Tag>,
    ));
  }
}

/// @nodoc

class _$ProductsFiltersImpl extends _ProductsFilters {
  const _$ProductsFiltersImpl(
      {required this.promotionOnly,
      required this.favoritesOnly,
      required this.minPrice,
      required this.maxPrice,
      required final Set<Tag>? tags,
      required final Set<Tag> selectedTags})
      : _tags = tags,
        _selectedTags = selectedTags,
        super._();

  @override
  final bool promotionOnly;
  @override
  final bool favoritesOnly;
  @override
  final int? minPrice;
  @override
  final int? maxPrice;
  final Set<Tag>? _tags;
  @override
  Set<Tag>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableSetView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(value);
  }

  final Set<Tag> _selectedTags;
  @override
  Set<Tag> get selectedTags {
    if (_selectedTags is EqualUnmodifiableSetView) return _selectedTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedTags);
  }

  @override
  String toString() {
    return 'ProductsFilters(promotionOnly: $promotionOnly, favoritesOnly: $favoritesOnly, minPrice: $minPrice, maxPrice: $maxPrice, tags: $tags, selectedTags: $selectedTags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductsFiltersImpl &&
            (identical(other.promotionOnly, promotionOnly) ||
                other.promotionOnly == promotionOnly) &&
            (identical(other.favoritesOnly, favoritesOnly) ||
                other.favoritesOnly == favoritesOnly) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._selectedTags, _selectedTags));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      promotionOnly,
      favoritesOnly,
      minPrice,
      maxPrice,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_selectedTags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductsFiltersImplCopyWith<_$ProductsFiltersImpl> get copyWith =>
      __$$ProductsFiltersImplCopyWithImpl<_$ProductsFiltersImpl>(
          this, _$identity);
}

abstract class _ProductsFilters extends ProductsFilters {
  const factory _ProductsFilters(
      {required final bool promotionOnly,
      required final bool favoritesOnly,
      required final int? minPrice,
      required final int? maxPrice,
      required final Set<Tag>? tags,
      required final Set<Tag> selectedTags}) = _$ProductsFiltersImpl;
  const _ProductsFilters._() : super._();

  @override
  bool get promotionOnly;
  @override
  bool get favoritesOnly;
  @override
  int? get minPrice;
  @override
  int? get maxPrice;
  @override
  Set<Tag>? get tags;
  @override
  Set<Tag> get selectedTags;
  @override
  @JsonKey(ignore: true)
  _$$ProductsFiltersImplCopyWith<_$ProductsFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
