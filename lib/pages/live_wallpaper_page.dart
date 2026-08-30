import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/posters.dart';
import '../models/poster.dart';
import '../providers/wall_provider.dart';
import '../services/wallpaper_service.dart';
import '../theme/app_theme.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/phone_preview.dart';
import '../widgets/pill_button.dart';
import '../widgets/poster_canvas.dart';
import '../widgets/poster_renderer.dart';
import '../widgets/section_header.dart';

const List<PosterKind> _filters = [
  PosterKind.tagline,
  PosterKind.legend,
  PosterKind.moment,
  PosterKind.inspiration,
  PosterKind.quote,
];

const int _columns = 2;
const double _renderButtonHeight = 56;
const double _secondsPerPoster = 1.2;
const String _explanation =
    'Boxer OS renders your posters once. On the system screen that opens, tap '
    'Apply or Set wallpaper, then choose Lock screen, Home screen or both. '
    'From then on Android shows the next poster every time the screen wakes.';
const String _applyHint = 'Choose where to apply it on the next screen';

/// Picks the posters the live wallpaper cycles through and renders them.
class LiveWallpaperPage extends StatefulWidget {
  const LiveWallpaperPage({super.key});

  @override
  State<LiveWallpaperPage> createState() => _LiveWallpaperPageState();
}

class _LiveWallpaperPageState extends State<LiveWallpaperPage>
    with WidgetsBindingObserver {
  final List<Poster> _posters = posters();
  final GlobalKey<PosterRendererState> _rendererKey = GlobalKey();
  PosterKind? _kind;
  bool _isLiveActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final wall = context.watch<WallProvider>();
    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: screen.width,
            height: screen.height,
            child: PosterRenderer(key: _rendererKey),
          ),
          Positioned.fill(
            child: ColoredBox(
              color: AppTheme.ink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spaceLg,
                            ),
                            child: _Header(
                              wall: wall,
                              isLiveActive: _isLiveActive,
                              kind: _kind,
                              onKind: (kind) => setState(() => _kind = kind),
                            ),
                          ),
                        ),
                        if (wall.shuffleAll)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _EverythingNote(count: _posters.length),
                          )
                        else
                          _grid(wall, screen),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceLg),
                    child: _Footer(
                      wall: wall,
                      onRender: _renderAndSet,
                      onCancel: wall.cancelRender,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(WallProvider wall, Size screen) {
    final shown = _kind == null
        ? _posters
        : _posters.where((poster) => poster.kind == _kind).toList();
    return SliverPadding(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _columns,
          mainAxisSpacing: AppTheme.spaceMd,
          crossAxisSpacing: AppTheme.spaceMd,
          childAspectRatio: screen.width / screen.height,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _SelectableCell(
            poster: shown[index],
            isSelected: wall.selectedIds.contains(shown[index].id),
            onTap: () => wall.toggle(shown[index].id),
          ),
          childCount: shown.length,
        ),
      ),
    );
  }

  Future<void> _refreshStatus() async {
    final isActive = await context.read<WallpaperService>().isLiveActive();
    if (!mounted) {
      return;
    }
    setState(() => _isLiveActive = isActive);
  }

  Future<void> _renderAndSet() async {
    final renderer = _rendererKey.currentState;
    if (renderer == null) {
      return;
    }
    final wall = context.read<WallProvider>();
    final service = context.read<WallpaperService>();
    final messenger = ScaffoldMessenger.of(context);
    final isReady = await wall.applyRotation(renderer.render, service);
    if (!mounted) {
      return;
    }
    if (isReady) {
      messenger.showSnackBar(const SnackBar(content: Text(_applyHint)));
      await service.openLivePicker();
      return;
    }
    final failure = wall.error;
    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure)));
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.wall,
    required this.isLiveActive,
    required this.kind,
    required this.onKind,
  });

  final WallProvider wall;
  final bool isLiveActive;
  final PosterKind? kind;
  final ValueChanged<PosterKind?> onKind;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live wallpaper: ${isLiveActive ? 'on' : 'off'}',
          style: AppTheme.label.copyWith(
            color: isLiveActive ? AppTheme.rest : AppTheme.chalkMuted,
          ),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        const SectionHeader(
          title: 'Live wallpaper',
          eyebrow: 'A NEW POSTER EVERY TIME THE SCREEN WAKES',
        ),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Everything')),
            ButtonSegment(value: false, label: Text('Pick a few')),
          ],
          selected: {wall.shuffleAll},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              wall.setShuffleAll(selection.first),
        ),
        if (!wall.shuffleAll) ...[
          const SizedBox(height: AppTheme.spaceMd),
          FilterChipRow<PosterKind>(
            values: _filters,
            selected: kind,
            label: (value) => value.label,
            onSelected: onKind,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text('${wall.selectedIds.length} selected', style: AppTheme.label),
        ],
      ],
    );
  }
}

class _EverythingNote extends StatelessWidget {
  const _EverythingNote({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Text(
          'All $count posters, in a random order.',
          style: AppTheme.bodyMuted,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.wall,
    required this.onRender,
    required this.onCancel,
  });

  final WallProvider wall;
  final VoidCallback onRender;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final count = wall.rotation.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(_explanation, style: AppTheme.bodyMuted),
        const SizedBox(height: AppTheme.spaceMd),
        if (wall.isRendering) ...[
          _RenderProgress(done: wall.renderedCount, total: wall.renderTotal),
          const SizedBox(height: AppTheme.spaceMd),
          PillButton(
            label: 'Cancel',
            style: PillStyle.ghost,
            onPressed: onCancel,
          ),
        ] else ...[
          Text(_estimate(count), style: AppTheme.caption),
          const SizedBox(height: AppTheme.spaceSm),
          PillButton(
            label: 'Render and set',
            height: _renderButtonHeight,
            onPressed: count == 0 ? null : onRender,
          ),
        ],
      ],
    );
  }

  static String _estimate(int count) {
    if (count == 0) {
      return 'Pick at least one poster.';
    }
    final minutes = (count * _secondsPerPoster / Duration.secondsPerMinute)
        .ceil();
    return minutes == 1 ? 'About 1 minute' : 'About $minutes minutes';
  }
}

class _RenderProgress extends StatelessWidget {
  const _RenderProgress({required this.done, required this.total});

  static const double _barHeight = 6;

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          child: LinearProgressIndicator(
            value: total == 0 ? null : done / total,
            minHeight: _barHeight,
            backgroundColor: AppTheme.line,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Text('$done of $total rendered', style: AppTheme.caption),
      ],
    );
  }
}

class _SelectableCell extends StatelessWidget {
  const _SelectableCell({
    required this.poster,
    required this.isSelected,
    required this.onTap,
  });

  static const double _check = 28;
  static const double _checkIcon = 18;
  static const double _unselectedAlpha = 0.5;

  final Poster poster;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          PhonePreview(
            child: PosterCanvas(
              poster: poster,
              size: MediaQuery.sizeOf(context),
            ),
          ),
          Positioned(
            top: AppTheme.spaceSm,
            right: AppTheme.spaceSm,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppTheme.accent
                    : AppTheme.ink.withValues(alpha: _unselectedAlpha),
                border: Border.all(
                  color: isSelected ? AppTheme.accent : AppTheme.chalk,
                  width: AppTheme.hairline,
                ),
              ),
              child: SizedBox.square(
                dimension: _check,
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: _checkIcon,
                        color: AppTheme.onAccent,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
