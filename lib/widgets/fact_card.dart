import 'package:flutter/material.dart';

import '../data/boxing_facts.dart';
import '../models/boxing_fact.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

/// One piece of boxing history as a raised card under a "DID YOU KNOW" eyebrow.
class FactCard extends StatelessWidget {
  const FactCard({required this.fact, this.cycles = false, super.key});

  final BoxingFact fact;

  /// Whether a tap swaps the fact for the next one in the rotation.
  final bool cycles;

  @override
  Widget build(BuildContext context) {
    if (cycles) {
      return _CyclingFactCard(first: fact);
    }
    return _FactBody(fact: fact);
  }
}

/// Holds the fact on show so a tap can move on to the next one.
class _CyclingFactCard extends StatefulWidget {
  const _CyclingFactCard({required this.first});

  final BoxingFact first;

  @override
  State<_CyclingFactCard> createState() => _CyclingFactCardState();
}

class _CyclingFactCardState extends State<_CyclingFactCard> {
  late BoxingFact _fact = widget.first;

  @override
  void didUpdateWidget(_CyclingFactCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.first != oldWidget.first) {
      _fact = widget.first;
    }
  }

  void _next() => setState(() => _fact = factAfter(_fact));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _next,
      behavior: HitTestBehavior.opaque,
      child: AnimatedSwitcher(
        duration: AppMotion.of(context, AppMotion.base),
        child: _FactBody(
          key: ValueKey<String>(_fact.text),
          fact: _fact,
          showHint: true,
        ),
      ),
    );
  }
}

class _FactBody extends StatelessWidget {
  const _FactBody({required this.fact, this.showHint = false, super.key});

  final BoxingFact fact;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DID YOU KNOW · ${fact.subject.toUpperCase()}',
            style: AppTheme.label,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(fact.text, style: AppTheme.body),
          if (showHint) ...[
            const SizedBox(height: AppTheme.spaceSm),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('Tap for another', style: AppTheme.caption),
            ),
          ],
        ],
      ),
    );
  }
}
