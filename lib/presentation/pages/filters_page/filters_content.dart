import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_recruitment_task/models/products_page.dart';
import 'package:flutter_recruitment_task/presentation/pages/filters_page/filters_cubit.dart';

class FiltersContent extends StatelessWidget {
  const FiltersContent({
    super.key,
    required this.state,
  });

  final Loaded state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Switch(
                  label: 'Promotion only',
                  isSelected: state.currentFilters.promotionOnly,
                  onChanged: context.read<FiltersCubit>().changePromotionOnly,
                ),
                _Switch(
                  label: 'Favorites only',
                  isSelected: state.currentFilters.favoritesOnly,
                  onChanged: context.read<FiltersCubit>().changeFavoritesOnly,
                ),
                const _PriceFilter(),
                if (state.currentFilters.tags != null)
                  _TagFilters(
                    selectedTags: state.currentFilters.selectedTags,
                    tags: state.currentFilters.tags!,
                  ),
              ],
            ),
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ClearButton(),
            _ApplyFiltersButton(),
          ],
        )
      ],
    );
  }
}

class _PriceFilter extends HookWidget {
  const _PriceFilter();

  @override
  Widget build(BuildContext context) {
    final loadedState = context.watch<FiltersCubit>().state as Loaded;

    final minPriceTec = useTextEditingController(
      text: loadedState.currentFilters.minPrice?.toString() ?? '',
    );
    final maxPriceTec = useTextEditingController(
      text: loadedState.currentFilters.maxPrice?.toString() ?? '',
    );

    return _FilterSection(
      label: 'Price',
      child: Row(
        children: [
          Expanded(
            child: _NumberTextField(
              controller: minPriceTec,
              onUnfocus: () {
                minPriceTec.text =
                    (context.read<FiltersCubit>().state as Loaded)
                            .currentFilters
                            .minPrice
                            ?.toString() ??
                        '';
              },
              onChanged: (value) {
                final newValue = int.tryParse(value);
                context.read<FiltersCubit>().changeMinPrice(
                      newValue,
                    );
              },
            ),
          ),
          const Text(' - '),
          Expanded(
            child: _NumberTextField(
              controller: maxPriceTec,
              onUnfocus: () {
                maxPriceTec.text =
                    (context.read<FiltersCubit>().state as Loaded)
                            .currentFilters
                            .maxPrice
                            ?.toString() ??
                        '';
              },
              onChanged: (value) {
                final newValue = int.tryParse(value);
                context.read<FiltersCubit>().changeMaxPrice(
                      newValue,
                    );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('PLN'),
          ),
        ],
      ),
    );
  }
}

class _TagFilters extends StatelessWidget {
  const _TagFilters({
    required this.tags,
    required this.selectedTags,
  });

  final Set<Tag> tags;
  final Set<Tag> selectedTags;

  @override
  Widget build(BuildContext context) {
    return _FilterSection(
      label: 'Tags',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...tags.map<Widget>(
            (Tag tag) {
              return FilterChip(
                label: Text(tag.label),
                selected: selectedTags.contains(tag),
                onSelected: (bool selected) {
                  if (selected) {
                    context.read<FiltersCubit>().addTag(tag);
                  } else {
                    context.read<FiltersCubit>().removeTag(tag);
                  }
                },
              );
            },
          )
        ],
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({
    required this.isSelected,
    required this.label,
    required this.onChanged,
  });

  final bool isSelected;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      value: isSelected,
      onChanged: (value) => onChanged(
        value,
      ),
    );
  }
}

class _NumberTextField extends HookWidget {
  const _NumberTextField({
    required this.controller,
    required this.onChanged,
    this.onUnfocus,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onUnfocus;

  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();

    useEffect(
      () {
        void onFocusChange() {
          if (!focusNode.hasFocus) {
            onUnfocus?.call();
          }
        }

        focusNode.addListener(onFocusChange);
        return () => focusNode..removeListener(onFocusChange);
      },
      [],
    );

    return TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onTapOutside: (_) => focusNode.unfocus(),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton();

  @override
  Widget build(BuildContext context) {
    final filtersState = context.watch<FiltersCubit>().state as Loaded;
    final buttonEnabled = filtersState.filtersChanged;

    return OutlinedButton(
      onPressed:
          buttonEnabled ? () => context.read<FiltersCubit>().reset() : null,
      child: const Text('Clear'),
    );
  }
}

class _ApplyFiltersButton extends StatelessWidget {
  const _ApplyFiltersButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: context.read<FiltersCubit>().applyFilters,
      child: const Text('Apply'),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.child,
    required this.label,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(label),
        ),
        child,
      ],
    );
  }
}
