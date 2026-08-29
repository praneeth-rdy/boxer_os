import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workout.dart';
import '../pages/session_page.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';

/// Starts [workout] on the session engine and opens the session screen.
Future<void> startSession(BuildContext context, Workout workout) {
  final settings = context.read<SettingsProvider>();
  final session = context.read<SessionProvider>();
  session.start(
    workout,
    stance: settings.stance,
    difficulty: workout.difficulty,
  );
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const SessionPage(),
    ),
  );
}
