import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_recruitment_task/models/products_filters.dart';
import 'package:flutter_recruitment_task/presentation/pages/filters_page/filters_content.dart';
import 'package:flutter_recruitment_task/presentation/pages/filters_page/filters_cubit.dart';
import 'package:flutter_recruitment_task/presentation/widgets/big_text.dart';
import 'package:flutter_recruitment_task/presentation/widgets/page_loader.dart';

const _mainPadding = EdgeInsets.all(16.0);

class FiltersPage extends StatelessWidget {
  const FiltersPage({
    super.key,
    required this.defaultFilters,
    required this.currentFilters,
  });

  final ProductsFilters defaultFilters;
  final ProductsFilters currentFilters;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FiltersCubit()
        ..init(
          defaultFilters: defaultFilters,
          currentFilters: currentFilters,
        ),
      child: Scaffold(
        appBar: AppBar(
          title: const BigText('Filters'),
        ),
        body: Padding(
          padding: _mainPadding,
          child: BlocListener<FiltersCubit, FiltersState>(
            listenWhen: (previous, current) => current is ApplyFilters,
            listener: (context, state) {
              final applyFiltersState = state as ApplyFilters;
              Navigator.of(context).pop(
                applyFiltersState.currentFilters,
              );
            },
            child: BlocBuilder<FiltersCubit, FiltersState>(
              builder: (context, state) {
                return switch (state) {
                  Loading() => const PageLoader(),
                  Loaded() => FiltersContent(state: state),
                };
              },
            ),
          ),
        ),
      ),
    );
  }
}
