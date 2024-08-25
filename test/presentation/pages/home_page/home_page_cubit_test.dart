import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_recruitment_task/models/get_products_page.dart';
import 'package:flutter_recruitment_task/models/products_filters.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/home_cubit.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late HomeCubit homeCubit;
  late MockProductsRepository mockProductsRepository;

  setUp(() {
    mockProductsRepository = MockProductsRepository();
    homeCubit = HomeCubit(mockProductsRepository);
  });

  tearDown(() {
    homeCubit.close();
  });

  const sampleProduct = Product(
    id: '123',
    name: 'Sample Product',
    mainImage: 'http://example.com/image.png',
    description: 'Sample Description',
    available: true,
    isFavorite: false,
    isBlurred: false,
    sellerId: 'seller123',
    tags: [
      Tag(tag: 'sale', label: 'Sale', color: '#FF0000', labelColor: '#FFFFFF')
    ],
    offer: Offer(
      skuId: 'sku123',
      sellerId: 'seller123',
      sellerName: 'Sample Seller',
      subtitle: 'Sample Subtitle',
      isSponsored: false,
      isBest: false,
      regularPrice: Price(amount: 100.0, currency: 'USD'),
      promotionalPrice: Price(amount: 80.0, currency: 'USD'),
      normalizedPrice: NormalizedPrice(
          amount: 100.0, currency: 'USD', unitLabel: 'per unit'),
      promotionalNormalizedPrice:
          NormalizedPrice(amount: 80.0, currency: 'USD', unitLabel: 'per unit'),
      omnibusPrice: null,
      omnibusLabel: null,
      tags: null,
    ),
  );

  const sampleFirstProductsPage = ProductsPage(
    totalPages: 2,
    pageNumber: 1,
    pageSize: 10,
    products: [sampleProduct],
  );

  const sampleSecondProductsPage = ProductsPage(
    totalPages: 2,
    pageNumber: 2,
    pageSize: 10,
    products: [sampleProduct],
  );

  final defaultFilters =
      ProductsFilters.initial().copyWith(maxPrice: 80, tags: {
    const Tag(
        tag: 'sale', label: 'Sale', color: '#FF0000', labelColor: '#FFFFFF'),
  });

  test('initial state is Loading', () {
    expect(homeCubit.state, equals(const Loading()));
  });

  blocTest<HomeCubit, HomeState>(
    'when init is called, then it should fetch filters, check for scrollToProductId, and fetch the next page',
    build: () {
      when(() => mockProductsRepository.getProductsPage(
            const GetProductsPage(pageNumber: 1),
          )).thenAnswer((_) async => sampleFirstProductsPage);
      return homeCubit;
    },
    act: (cubit) => cubit.init(scrollToProductId: null),
    expect: () => [
      Loaded(
        products: sampleFirstProductsPage.products,
        hasReachedMax: false,
        defaultFilters: defaultFilters,
        currentFilters: defaultFilters,
      ),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'when applyFilters is called, then it should emit Loaded state with default filters and changed currentFilters',
    build: () {
      when(() => mockProductsRepository.getProductsPage(
            const GetProductsPage(pageNumber: 1),
          )).thenAnswer((_) async => sampleFirstProductsPage);
      return homeCubit;
    },
    act: (cubit) async {
      await cubit.init(scrollToProductId: null);
      cubit.applyFilters(
        defaultFilters.copyWith(
          promotionOnly: true,
        ),
      );
    },
    expect: () => [
      Loaded(
        products: sampleFirstProductsPage.products,
        hasReachedMax: false,
        defaultFilters: defaultFilters,
        currentFilters: defaultFilters,
      ),
      const Loading(),
      Loaded(
        products: sampleFirstProductsPage.products,
        hasReachedMax: false,
        defaultFilters: defaultFilters,
        currentFilters: defaultFilters.copyWith(
          promotionOnly: true,
        ),
      ),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'when findProductById is called with an existing product id, then it emits LoadedWithIdFound if product is found',
    build: () {
      when(() => mockProductsRepository
              .getProductsPage(const GetProductsPage(pageNumber: 1)))
          .thenAnswer((_) async => sampleFirstProductsPage);
      return homeCubit;
    },
    act: (cubit) {
      cubit.init(scrollToProductId: '123');
    },
    expect: () => [
      LoadedWithIdFound(
        products: sampleFirstProductsPage.products,
        hasReachedMax: false,
        defaultFilters: defaultFilters,
        currentFilters: defaultFilters,
        indexOfFoundProduct: 0,
      )
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'when findProductById is called with a non-existing product id, then it emits LoadedWithNoIdFound if product is not found',
    build: () {
      when(() => mockProductsRepository
              .getProductsPage(const GetProductsPage(pageNumber: 1)))
          .thenAnswer((_) async => sampleFirstProductsPage);
      when(() => mockProductsRepository
              .getProductsPage(const GetProductsPage(pageNumber: 2)))
          .thenAnswer((_) async => sampleSecondProductsPage);
      return homeCubit;
    },
    act: (cubit) {
      cubit.init(scrollToProductId: 'non_existing_id');
    },
    expect: () => [
      LoadedWithNoIdFound(
        products: [
          ...sampleFirstProductsPage.products,
          ...sampleSecondProductsPage.products
        ],
        hasReachedMax: true,
        defaultFilters: defaultFilters,
        currentFilters: defaultFilters,
        notFoundProductId: 'non_existing_id',
      )
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'when getNextPage is called, then it fetches the next page and emits Loaded state',
    build: () {
      when(() => mockProductsRepository.getProductsPage(
            const GetProductsPage(pageNumber: 1),
          )).thenAnswer((_) async => sampleFirstProductsPage);
      when(() => mockProductsRepository.getProductsPage(
            const GetProductsPage(pageNumber: 2),
          )).thenAnswer((_) async => sampleSecondProductsPage);
      return homeCubit;
    },
    act: (cubit) async {
      await cubit.init(scrollToProductId: null);
      cubit.getNextPage();
    },
    expect: () => [
      Loaded(
        products: sampleFirstProductsPage.products,
        hasReachedMax: false,
        defaultFilters: defaultFilters,
        currentFilters: defaultFilters,
      ),
      Loaded(
        products: [
          ...sampleFirstProductsPage.products,
          ...sampleSecondProductsPage.products
        ],
        hasReachedMax: true,
        defaultFilters: defaultFilters,
        currentFilters: defaultFilters,
      ),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'when scrollToProductPerformed is called, then it emits Loaded state with current state',
    build: () {
      when(() => mockProductsRepository.getProductsPage(
            const GetProductsPage(pageNumber: 1),
          )).thenAnswer((_) async => sampleFirstProductsPage);
      when(() => mockProductsRepository.getProductsPage(
            const GetProductsPage(pageNumber: 2),
          )).thenAnswer((_) async => sampleSecondProductsPage);
      return homeCubit;
    },
    act: (cubit) async {
      await cubit.init(scrollToProductId: null);
      await cubit.getNextPage();
      await cubit.findProductById(sampleProduct.id);
      cubit.scrollToProductPerformed();
    },
    expect: () => [
      Loaded(
        products: sampleFirstProductsPage.products,
        hasReachedMax: false,
        defaultFilters: defaultFilters,
        currentFilters: defaultFilters,
      ),
      Loaded(
        products: [
          ...sampleFirstProductsPage.products,
          ...sampleSecondProductsPage.products
        ],
        hasReachedMax: true,
        defaultFilters: defaultFilters,
        currentFilters: defaultFilters,
      ),
      LoadedWithIdFound(
        products: [
          ...sampleFirstProductsPage.products,
          ...sampleSecondProductsPage.products
        ],
        hasReachedMax: true,
        defaultFilters: defaultFilters,
        currentFilters: defaultFilters,
        indexOfFoundProduct: 0,
      ),
      Loaded(
        products: [
          ...sampleFirstProductsPage.products,
          ...sampleSecondProductsPage.products
        ],
        hasReachedMax: true,
        defaultFilters: defaultFilters,
        currentFilters: defaultFilters,
      )
    ],
  );
}
