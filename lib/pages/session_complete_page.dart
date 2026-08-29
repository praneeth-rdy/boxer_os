import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/boxing_facts.dart';
import '../data/quotes.dart';
import '../models/session_record.dart';
import '../models/stance.dart';
import '../models/training_type.dart';
import '../providers/history_provider.dart';
import '../providers/session_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/count_up_text.dart';
import '../widgets/fact_card.dart';
import '../widgets/journal_field.dart';
import '../widgets/pill_button.dart';
import '../widgets/quote_card.dart';
import '../widgets/rating_input.dart';
import '../widgets/settle_in.dart';

const double _actionHeight = 56;

/// The notes sheet for the session that just finished or was ended early.
class SessionCompletePage extends StatefulWidget {
  const SessionCompletePage({super.key});

  @override
  State<SessionCompletePage> createState() => _SessionCompletePageState();
}

class _SessionCompletePageState extends State<SessionCompletePage> {
  final TextEditingController _whatWorked = TextEditingController();
  final TextEditingController _whatNeedsWork = TextEditingController();
  final TextEditingController _opponent = TextEditingController();

  // Snapshot: reset() clears the record while this page is still on screen.
  late final SessionRecord? _record;
  int? _rating;
  Stance _opponentStance = Stance.orthodox;

  @override
  void initState() {
    super.initState();
    _record = context.read<SessionProvider>().record;
  }

  @override
  void dispose() {
    _whatWorked.dispose();
    _whatNeedsWork.dispose();
    _opponent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final record = _record;
    final isLoggable = record != null && _isLoggable(record);

    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: record == null
              ? const Align(
                  alignment: Alignment.topLeft,
                  child: Text('No session', style: AppTheme.displayLarge),
                )
              : isLoggable
              ? _notes(record)
              : const Align(
                  alignment: Alignment.topLeft,
                  child: Text('Nothing to log', style: AppTheme.bodyMuted),
                ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: isLoggable
              ? PillButton(
                  label: 'Save',
                  height: _actionHeight,
                  onPressed: _save,
                )
              : PillButton(
                  label: 'Done',
                  height: _actionHeight,
                  onPressed: _discard,
                ),
        ),
      ),
    );
  }

  /// A session with no round and under a minute of work has nothing worth logging.
  static bool _isLoggable(SessionRecord record) =>
      record.roundsCompleted > 0 || record.durationSeconds >= 60;

  Widget _notes(SessionRecord record) {
    return ListView(
      children: [
        SettleIn(
          child: Text(
            record.completed ? 'SESSION COMPLETE' : 'SESSION ENDED',
            style: AppTheme.label,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        SettleIn(child: Text(record.workoutName, style: AppTheme.displayLarge)),
        const SizedBox(height: AppTheme.spaceXl),
        SettleIn(
          index: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatCell(
                value: CountUpText(
                  value: record.roundsCompleted,
                  suffix: '/${record.roundsPlanned}',
                  style: AppTheme.displayMedium,
                ),
                label: 'Rounds',
              ),
              _StatCell(
                value: CountUpText(
                  value: record.workMinutes,
                  style: AppTheme.displayMedium,
                ),
                label: 'Minutes',
              ),
              _StatCell(
                value: Text(
                  record.type.label,
                  maxLines: 1,
                  style: AppTheme.displayMedium,
                ),
                label: 'Type',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spaceXl),
        SettleIn(
          index: 2,
          child: QuoteCard(quote: quoteForSession(record.id), compact: true),
        ),
        const SizedBox(height: AppTheme.spaceXl),
        SettleIn(
          index: 3,
          child: RatingInput(
            value: _rating,
            onChanged: (rating) => setState(() => _rating = rating),
          ),
        ),
        const SizedBox(height: AppTheme.spaceLg),
        SettleIn(
          index: 4,
          child: JournalField(
            label: 'What worked',
            controller: _whatWorked,
            hint: 'Sharp jab, good distance',
          ),
        ),
        const SizedBox(height: AppTheme.spaceLg),
        SettleIn(
          index: 5,
          child: JournalField(
            label: 'What needs work',
            controller: _whatNeedsWork,
            hint: 'Hands dropping when tired',
          ),
        ),
        if (record.type == TrainingType.sparring) ...[
          const SizedBox(height: AppTheme.spaceLg),
          JournalField(
            label: 'Opponent',
            controller: _opponent,
            hint: 'Who you sparred',
            maxLines: 1,
          ),
          const SizedBox(height: AppTheme.spaceLg),
          const Text('OPPONENT STANCE', style: AppTheme.label),
          const SizedBox(height: AppTheme.spaceSm),
          SegmentedButton<Stance>(
            segments: [
              for (final stance in Stance.values)
                ButtonSegment(value: stance, label: Text(stance.label)),
            ],
            selected: {_opponentStance},
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                setState(() => _opponentStance = selection.first),
          ),
        ],
        const SizedBox(height: AppTheme.spaceXl),
        SettleIn(index: 6, child: FactCard(fact: factForSession(record.id))),
      ],
    );
  }

  Future<void> _save() async {
    final record = _record;
    if (record == null) {
      return;
    }
    final navigator = Navigator.of(context);
    final session = context.read<SessionProvider>();
    final history = context.read<HistoryProvider>();
    final isSparring = record.type == TrainingType.sparring;
    await history.addSession(
      record.copyWith(
        rating: _rating,
        whatWorked: _entered(_whatWorked),
        whatNeedsWork: _entered(_whatNeedsWork),
        opponent: isSparring ? _entered(_opponent) : null,
        opponentStance: isSparring ? _opponentStance : null,
      ),
    );
    session.reset();
    navigator.popUntil((route) => route.isFirst);
  }

  void _discard() {
    context.read<SessionProvider>().reset();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static String? _entered(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final Widget value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: value,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(label.toUpperCase(), style: AppTheme.label),
        ],
      ),
    );
  }
}
