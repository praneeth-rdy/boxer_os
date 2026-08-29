import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/difficulty.dart';
import '../models/stance.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';
import '../widgets/journal_field.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_header.dart';
import 'onboarding_page.dart';

/// Stance, level, cue toggles, the clear-history action and the version.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        children: const [
          SectionHeader(title: 'Settings', eyebrow: 'FIGHTER PROFILE'),
          Padding(
            padding: EdgeInsets.only(bottom: AppTheme.spaceXl),
            child: _FighterNameField(),
          ),
          _Section(eyebrow: 'STANCE', child: _StancePicker()),
          _Section(eyebrow: 'LEVEL', child: _LevelPicker()),
          _Section(eyebrow: 'CUES', child: _CueSwitches()),
          _Section(eyebrow: 'REMINDERS', child: _ReminderControls()),
          _Section(eyebrow: 'DATA', child: _DataActions()),
          _Section(eyebrow: 'ABOUT', child: _About()),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.eyebrow, required this.child});

  final String eyebrow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: AppTheme.label),
          const SizedBox(height: AppTheme.spaceMd),
          child,
        ],
      ),
    );
  }
}

class _StancePicker extends StatelessWidget {
  const _StancePicker();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return SegmentedButton<Stance>(
      segments: [
        for (final stance in Stance.values)
          ButtonSegment(value: stance, label: Text(stance.label)),
      ],
      selected: {settings.stance},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => settings.setStance(selection.first),
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return SegmentedButton<Difficulty>(
      segments: [
        for (final level in Difficulty.values)
          ButtonSegment(
            value: level,
            label: Text(
              level.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      selected: {settings.difficulty},
      showSelectedIcon: false,
      onSelectionChanged: (selection) =>
          settings.setDifficulty(selection.first),
    );
  }
}

class _CueSwitches extends StatelessWidget {
  const _CueSwitches();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Column(
      children: [
        _CueSwitch(
          title: 'Sound',
          subtitle: 'Bells and beeps',
          value: settings.soundEnabled,
          onChanged: settings.setSoundEnabled,
        ),
        _CueSwitch(
          title: 'Haptics',
          subtitle: 'Buzz on round changes',
          value: settings.hapticsEnabled,
          onChanged: settings.setHapticsEnabled,
        ),
        _CueSwitch(
          title: 'Voice',
          subtitle: 'Spoken cues and combinations',
          value: settings.voiceEnabled,
          onChanged: settings.setVoiceEnabled,
        ),
        _CueSwitch(
          title: 'Keep screen on during sessions',
          subtitle: 'Uses more battery',
          value: settings.keepScreenOn,
          onChanged: settings.setKeepScreenOn,
        ),
        const SizedBox(height: AppTheme.spaceMd),
        _TestVoiceAction(isEnabled: settings.voiceEnabled),
      ],
    );
  }
}

class _TestVoiceAction extends StatelessWidget {
  const _TestVoiceAction({required this.isEnabled});

  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final voice = context.read<VoiceService>();
    final name = voice.voiceName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PillButton(
          label: 'Test voice',
          style: PillStyle.ghost,
          onPressed: isEnabled ? voice.sayTest : null,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Text('Voice: ${name ?? 'system default'}', style: AppTheme.caption),
      ],
    );
  }
}

class _ReminderControls extends StatelessWidget {
  const _ReminderControls();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Column(
      children: [
        _PermissionSwitch(
          title: 'Daily reminder',
          subtitle: 'A nudge at the time you pick',
          isOn: settings.reminderEnabled,
          apply: settings.setReminderEnabled,
        ),
        _ReminderTimeRow(
          isEnabled: settings.reminderEnabled,
          time: TimeOfDay(
            hour: settings.reminderHour,
            minute: settings.reminderMinute,
          ),
        ),
        _PermissionSwitch(
          title: 'Streak nudge',
          subtitle: "8 pm, only on days you haven't trained",
          isOn: settings.streakNudgeEnabled,
          apply: settings.setStreakNudgeEnabled,
        ),
      ],
    );
  }
}

/// A reminder switch that only goes on once Android has granted the permission.
class _PermissionSwitch extends StatelessWidget {
  const _PermissionSwitch({
    required this.title,
    required this.subtitle,
    required this.isOn,
    required this.apply,
  });

  static const String _deniedMessage =
      'Notifications are off for Boxer OS in Android settings.';

  final String title;
  final String subtitle;
  final bool isOn;
  final Future<void> Function(bool enabled) apply;

  @override
  Widget build(BuildContext context) {
    return _CueSwitch(
      title: title,
      subtitle: subtitle,
      value: isOn,
      onChanged: (enabled) => _toggle(context, enabled),
    );
  }

  Future<void> _toggle(BuildContext context, bool enabled) async {
    if (!enabled) {
      await apply(false);
      return;
    }
    final granted = await context
        .read<NotificationService>()
        .requestPermission();
    if (granted) {
      // The grant stands even if Settings was left while the dialog was up.
      await apply(true);
      return;
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(_deniedMessage)));
  }
}

class _ReminderTimeRow extends StatelessWidget {
  const _ReminderTimeRow({required this.isEnabled, required this.time});

  final bool isEnabled;
  final TimeOfDay time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
      child: Row(
        children: [
          const Expanded(child: Text('Time', style: AppTheme.body)),
          Text(
            time.format(context),
            style: AppTheme.displaySmall.copyWith(
              color: isEnabled ? AppTheme.chalk : AppTheme.chalkFaint,
            ),
          ),
          const SizedBox(width: AppTheme.spaceSm),
          IconButton(
            onPressed: isEnabled ? () => _pickTime(context) : null,
            constraints: const BoxConstraints(
              minWidth: AppTheme.minTapTarget,
              minHeight: AppTheme.minTapTarget,
            ),
            color: AppTheme.chalk,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Change reminder time',
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final picked = await showTimePicker(context: context, initialTime: time);
    if (picked == null) {
      return;
    }
    await settings.setReminderTime(picked.hour, picked.minute);
  }
}

class _CueSwitch extends StatelessWidget {
  const _CueSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTheme.body),
      subtitle: Text(subtitle, style: AppTheme.caption),
    );
  }
}

class _FighterNameField extends StatefulWidget {
  const _FighterNameField();

  @override
  State<_FighterNameField> createState() => _FighterNameFieldState();
}

class _FighterNameFieldState extends State<_FighterNameField> {
  final TextEditingController _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.text = context.read<SettingsProvider>().fighterName;
    _name.addListener(_store);
  }

  @override
  void dispose() {
    _name.removeListener(_store);
    _name.dispose();
    super.dispose();
  }

  void _store() {
    final settings = context.read<SettingsProvider>();
    if (_name.text.trim() != settings.fighterName) {
      settings.setFighterName(_name.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JournalField(
      label: 'Fighter name',
      controller: _name,
      hint: 'How Home greets you',
      maxLines: 1,
    );
  }
}

class _DataActions extends StatelessWidget {
  const _DataActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PillButton(
          label: 'Show onboarding again',
          style: PillStyle.ghost,
          onPressed: () => _restartOnboarding(context),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        const _ClearHistoryAction(),
      ],
    );
  }

  void _restartOnboarding(BuildContext context) {
    context.read<SettingsProvider>().setOnboardingDone(false);
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const OnboardingPage()));
  }
}

class _ClearHistoryAction extends StatelessWidget {
  const _ClearHistoryAction();

  @override
  Widget build(BuildContext context) {
    return PillButton(
      label: 'Clear history',
      style: PillStyle.outlined,
      onPressed: () => _confirmClear(context),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final history = context.read<HistoryProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceRaised,
        title: const Text('Clear history?', style: AppTheme.titleLarge),
        content: const Text(
          'Delete all sessions and reaction results? This cannot be undone.',
          style: AppTheme.bodyMuted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await history.clearAll();
  }
}

class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Boxer OS ${AppTheme.appVersion}', style: AppTheme.body),
        SizedBox(height: AppTheme.spaceXs),
        Text(
          'Local-first. Nothing leaves your phone.',
          style: AppTheme.bodyMuted,
        ),
      ],
    );
  }
}
