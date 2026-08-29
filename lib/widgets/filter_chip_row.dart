import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Horizontally scrolling choice chips over [values], led by an "All" chip
/// that clears the filter.
class FilterChipRow<T> extends StatelessWidget {
  const FilterChipRow({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
    this.allLabel = 'All',
    super.key,
  });

  final List<T> values;
  final T? selected;
  final String Function(T) label;
  final ValueChanged<T?> onSelected;
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: Text(allLabel),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final value in values) ...[
            const SizedBox(width: AppTheme.spaceSm),
            ChoiceChip(
              label: Text(label(value)),
              selected: value == selected,
              onSelected: (_) => onSelected(value),
            ),
          ],
        ],
      ),
    );
  }
}
