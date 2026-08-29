import 'package:flutter/material.dart';

import '../models/milestone.dart';
import '../models/reaction_format.dart';
import '../models/reaction_result.dart';
import '../models/training_type.dart';
import 'training_stats.dart';

const int _fastReactionMillis = 250;

/// The types "Full arsenal" asks for; the remaining types are optional extras.
const List<TrainingType> _arsenalTypes = [
  TrainingType.shadowBoxing,
  TrainingType.heavyBag,
  TrainingType.footwork,
  TrainingType.conditioning,
  TrainingType.sparring,
];

/// Every badge, always in the same order, with `achieved` set from the history.
List<Milestone> computeMilestones(
  TrainingStats stats,
  List<ReactionResult> reactions,
) {
  return [
    Milestone(
      id: 'first_session',
      title: 'First bell',
      description: 'Finish your first session',
      icon: Icons.notifications_active_rounded,
      achieved: stats.totalSessions >= 1,
    ),
    Milestone(
      id: 'ten_sessions',
      title: 'Ten sessions',
      description: 'Train ten times',
      icon: Icons.repeat_rounded,
      achieved: stats.totalSessions >= 10,
    ),
    Milestone(
      id: 'hundred_rounds',
      title: '100 rounds',
      description: 'Box a hundred rounds',
      icon: Icons.sports_mma_rounded,
      achieved: stats.totalRounds >= 100,
    ),
    Milestone(
      id: 'five_hundred_rounds',
      title: '500 rounds',
      description: 'Box five hundred rounds',
      icon: Icons.military_tech_rounded,
      achieved: stats.totalRounds >= 500,
    ),
    Milestone(
      id: 'streak_seven',
      title: '7-day streak',
      description: 'Train seven days in a row',
      icon: Icons.local_fire_department_rounded,
      achieved: stats.streakDays >= 7,
    ),
    Milestone(
      id: 'reaction_250',
      title: 'Under 250 ms',
      description: 'Land a reaction under 250 ms',
      icon: Icons.bolt_rounded,
      achieved: reactions.any(_isFast),
    ),
    Milestone(
      id: 'all_types',
      title: 'Full arsenal',
      description: 'Train every core type',
      icon: Icons.grid_view_rounded,
      achieved: _arsenalTypes.every(stats.lastTrainedByType.containsKey),
    ),
    Milestone(
      id: 'endurance_first',
      title: 'Went the minute',
      description: 'Finish an endurance reaction run',
      icon: Icons.timer_rounded,
      achieved: reactions.any(
        (result) => result.format == ReactionFormat.endurance,
      ),
    ),
  ];
}

bool _isFast(ReactionResult result) {
  final best = result.bestMillis;
  return best != null && best < _fastReactionMillis;
}
