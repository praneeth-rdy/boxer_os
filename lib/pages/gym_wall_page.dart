import 'package:flutter/material.dart';

import '../data/posters.dart';
import '../models/poster.dart';
import '../theme/app_theme.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/phone_preview.dart';
import '../widgets/pill_button.dart';
import '../widgets/poster_canvas.dart';
import '../widgets/section_header.dart';
import '../widgets/settle_in.dart';
import 'live_wallpaper_page.dart';
import 'poster_page.dart';

const List<PosterKind> _filters = [
  PosterKind.tagline,
  PosterKind.legend,
  PosterKind.moment,
  PosterKind.inspiration,
  PosterKind.quote,
];

const int _columns = 2;

/// The Gym Wall: every poster as a phone-shaped thumbnail, filtered by kind.
class GymWallPage extends StatefulWidget {
  const GymWallPage({super.key});

  @override
  State<GymWallPage> createState() => _GymWallPageState();
}

class _GymWallPageState extends State<GymWallPage> {
  final List<Poster> _posters = posters();
  PosterKind? _kind;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final shown = _kind == null
        ? _posters
        : _posters.where((poster) => poster.kind == _kind).toList();
    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
            child: SettleIn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Gym Wall', eyebrow: 'WALLPAPERS'),
                  const Text(
                    'Posters in the Boxer OS style for your home and lock '
                    'screen.',
                    style: AppTheme.bodyMuted,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  PillButton(
                    label: 'Live wallpaper',
                    style: PillStyle.outlined,
                    icon: Icons.wallpaper,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LiveWallpaperPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                  FilterChipRow<PosterKind>(
                    values: _filters,
                    selected: _kind,
                    label: (kind) => kind.label,
                    onSelected: (kind) => setState(() => _kind = kind),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _columns,
                mainAxisSpacing: AppTheme.spaceMd,
                crossAxisSpacing: AppTheme.spaceMd,
                childAspectRatio: screen.width / screen.height,
              ),
              itemCount: shown.length,
              itemBuilder: (context, index) =>
                  _PosterCell(poster: shown[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterCell extends StatelessWidget {
  const _PosterCell({required this.poster});

  final Poster poster;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => PosterPage(poster: poster)),
      ),
      child: PhonePreview(
        child: PosterCanvas(poster: poster, size: MediaQuery.sizeOf(context)),
      ),
    );
  }
}
