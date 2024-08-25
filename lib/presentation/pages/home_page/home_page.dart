import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/models/products_filters.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/filters_page/filters_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/home_cubit.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';
import 'package:flutter_recruitment_task/presentation/widgets/page_loader.dart';
import 'package:flutter_recruitment_task/repositories/products_repository.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

const _mainPadding = EdgeInsets.all(16.0);

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.scrollToProductId,
    required this.productsRepository,
  });

  final String? scrollToProductId;
  final ProductsRepository productsRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return HomeCubit(productsRepository)
          ..init(
            scrollToProductId: scrollToProductId,
          );
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const BigText('Products'),
              actions: [
                if (state case Loaded _)
                  _FiltersButton(
                    isFiltersActive: state.areFiltersActive,
                    currentFilters: state.currentFilters!,
                    defaultFilters: state.defaultFilters!,
                  ),
              ],
            ),
            body: Padding(
              padding: _mainPadding,
              child: switch (state) {
                Error() => BigText('Error: ${state.error}'),
                Loading() => const PageLoader(),
                Loaded() => _LoadedWidget(state: state),
              },
            ),
          );
        },
      ),
    );
  }
}

class _LoadedWidget extends StatefulWidget {
  const _LoadedWidget({
    required this.state,
  });

  final Loaded state;

  @override
  State<_LoadedWidget> createState() => _LoadedWidgetState();
}

class _LoadedWidgetState extends State<_LoadedWidget> {
  late ScrollController scrollController;
  late SliverObserverController observerController;

  BuildContext? _sliverListCtx;

  Future<void> scrollToProduct(int index) {
    return observerController.animateTo(
      index: index,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      sliverContext: _sliverListCtx,
    );
  }

  void showNoProductFoundSnackbar(String productId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Product with given id ($productId) not found :/'),
      ),
    );
  }

  @override
  void initState() {
    scrollController = ScrollController();
    observerController = SliverObserverController(
      controller: scrollController,
    );

    switch (widget.state) {
      case LoadedWithIdFound state:
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await scrollToProduct(state.indexOfFoundProduct);
          if (mounted) {
            context.read<HomeCubit>().scrollToProductPerformed();
          }
        });
      case LoadedWithNoIdFound state:
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          showNoProductFoundSnackbar(
            state.notFoundProductId,
          );
        });
    }
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollToProductWillBePerformed = widget.state is LoadedWithIdFound;
    final showNextPageButton = !widget.state.hasReachedMax;

    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) => current is LoadedWithIdFound,
      listener: (context, state) async {
        final loadedWithIdFoundState = state as LoadedWithIdFound;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await scrollToProduct(loadedWithIdFoundState.indexOfFoundProduct);
          if (context.mounted) {
            context.read<HomeCubit>().scrollToProductPerformed();
          }
        });
      },
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) => current is LoadedWithNoIdFound,
        listener: (context, state) {
          final loadedWithNoIdFoundState = state as LoadedWithNoIdFound;
          showNoProductFoundSnackbar(
              loadedWithNoIdFoundState.notFoundProductId);
        },
        child: NotificationListener<SliverItemContextNotification>(
          onNotification: (notification) {
            _sliverListCtx ??= notification.sliverItemContext;
            return true;
          },
          child: SliverViewObserver(
            controller: observerController,
            child: CustomScrollView(
              cacheExtent:
                  scrollToProductWillBePerformed ? double.maxFinite : null,
              controller: scrollController,
              slivers: [
                _ProductsSliverList(state: widget.state),
                if (showNextPageButton) const _GetNextPageButton(),
              ],
            ),
            sliverContexts: () => [
              if (_sliverListCtx != null) _sliverListCtx!,
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductsSliverList extends StatelessWidget {
  const _ProductsSliverList({required this.state});

  final Loaded state;

  @override
  Widget build(BuildContext context) {
    final products = state.products;
    return SliverList.separated(
      itemCount: products.length,
      itemBuilder: (itemContext, index) {
        SliverItemContextNotification(
          sliverItemContext: itemContext,
        ).dispatch(context);
        return _ProductCard(products[index]);
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}

class SliverItemContextNotification extends Notification {
  SliverItemContextNotification({
    required this.sliverItemContext,
  });

  final BuildContext sliverItemContext;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BigText(product.name),
          _Tags(product: product),
          Text('Price: ${product.currentPrice.amount}'),
        ],
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags({
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: product.tags.map(_TagWidget.new).toList(),
    );
  }
}

class _TagWidget extends StatefulWidget {
  const _TagWidget(this.tag);

  final Tag tag;

  @override
  State<_TagWidget> createState() => _TagWidgetState();
}

class _TagWidgetState extends State<_TagWidget>
    with AutomaticKeepAliveClientMixin {
  late Color color;

  @override
  void initState() {
    const possibleColors = Colors.primaries;
    color = possibleColors[Random().nextInt(possibleColors.length)];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Chip(
        color: MaterialStateProperty.all(color),
        label: Text(widget.tag.label),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _GetNextPageButton extends StatelessWidget {
  const _GetNextPageButton();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: TextButton(
        onPressed: context.read<HomeCubit>().getNextPage,
        child: const BigText('Get next page'),
      ),
    );
  }
}

class _FiltersButton extends StatelessWidget {
  const _FiltersButton({
    required this.currentFilters,
    required this.defaultFilters,
    required this.isFiltersActive,
  });

  final ProductsFilters currentFilters;
  final ProductsFilters defaultFilters;
  final bool isFiltersActive;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFiltersActive ? Icons.filter_alt_outlined : Icons.filter_alt_off,
      ),
      tooltip: 'Filters',
      onPressed: () async {
        final filters = await Navigator.push<ProductsFilters?>(
          context,
          MaterialPageRoute(
            builder: (context) => FiltersPage(
              defaultFilters: defaultFilters,
              currentFilters: currentFilters,
            ),
          ),
        );
        if (context.mounted && filters != null) {
          context.read<HomeCubit>().applyFilters(filters);
        }
      },
    );
  }
}
