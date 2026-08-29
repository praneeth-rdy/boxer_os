import 'package:flutter/material.dart';

/// One progress badge and whether the boxer has earned it.
class Milestone {
  const Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.achieved,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool achieved;
}
