import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A labelled multi-line note field for the training journal.
class JournalField extends StatelessWidget {
  const JournalField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 3,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label.toUpperCase(), style: AppTheme.label),
        const SizedBox(height: AppTheme.spaceSm),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTheme.body,
          cursorColor: AppTheme.accent,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
