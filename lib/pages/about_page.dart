import 'package:flutter/material.dart';

import '../data/app_identity.dart';
import '../data/legends.dart';
import '../data/wall_photos.dart';
import '../theme/app_theme.dart';
import '../utils/external_links.dart';
import '../widgets/settle_in.dart';

/// Who made Boxer OS, the licence it ships under, its privacy stance and credits.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const List<Widget> _blocks = [
    _Identity(),
    _MadeBy(),
    _License(),
    _Privacy(),
    _Credits(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        itemCount: _blocks.length,
        itemBuilder: (context, index) => SettleIn(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spaceXl),
            child: _blocks[index],
          ),
        ),
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity();

  static const double _logoSize = 96;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              child: Image.asset(
                AppIdentity.logoAsset,
                width: _logoSize,
                height: _logoSize,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text('BOXER OS', style: AppTheme.displayLarge),
                  ),
                  Text(
                    AppIdentity.tagline.toUpperCase(),
                    style: AppTheme.label,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        const Text('Version ${AppTheme.appVersion}', style: AppTheme.caption),
      ],
    );
  }
}

class _MadeBy extends StatelessWidget {
  const _MadeBy();

  @override
  Widget build(BuildContext context) {
    return const _Block(
      eyebrow: 'MADE BY',
      children: [
        Text(AppIdentity.developer, style: AppTheme.title),
        SizedBox(height: AppTheme.spaceXs),
        Text(AppIdentity.brand, style: AppTheme.bodyMuted),
        SizedBox(height: AppTheme.spaceMd),
        Text(
          '${AppIdentity.copyright}. All rights reserved for commercial use.',
          style: AppTheme.caption,
        ),
      ],
    );
  }
}

class _License extends StatelessWidget {
  const _License();

  @override
  Widget build(BuildContext context) {
    return const _Block(
      eyebrow: 'LICENSE',
      children: [
        Text(AppIdentity.licenseName, style: AppTheme.body),
        SizedBox(height: AppTheme.spaceSm),
        Text(
          'You may copy, change and share Boxer OS for any noncommercial '
          'purpose as long as you keep the license notice and credit the '
          'author. Commercial use needs written permission.',
          style: AppTheme.bodyMuted,
        ),
        SizedBox(height: AppTheme.spaceMd),
        _LinkRow(label: 'Read the license', url: AppIdentity.licenseUrl),
        _LinkRow(label: 'Source code on GitHub', url: AppIdentity.sourceUrl),
      ],
    );
  }
}

class _Privacy extends StatelessWidget {
  const _Privacy();

  @override
  Widget build(BuildContext context) {
    return const _Block(
      eyebrow: 'PRIVACY',
      children: [
        Text(
          'Boxer OS keeps everything on your phone. No account, no analytics, '
          'nothing sent anywhere.',
          style: AppTheme.bodyMuted,
        ),
        SizedBox(height: AppTheme.spaceMd),
        _LinkRow(label: 'Privacy policy', url: AppIdentity.privacyPolicyUrl),
        _LinkRow(label: 'Contact', url: AppIdentity.contactUrl),
      ],
    );
  }
}

class _Credits extends StatelessWidget {
  const _Credits();

  @override
  Widget build(BuildContext context) {
    return _Block(
      eyebrow: 'CREDITS',
      children: [
        const Text(
          'Bebas Neue and Inter, SIL Open Font License.',
          style: AppTheme.bodyMuted,
        ),
        const SizedBox(height: AppTheme.spaceMd),
        for (final legend in legends)
          _CreditLine(
            text:
                '${legend.name}: ${legend.credit.author}, '
                '${legend.credit.license}',
            source: legend.credit.source,
          ),
        const SizedBox(height: AppTheme.spaceMd),
        for (final legend in legends)
          for (var index = 0; index < legend.gallery.length; index++)
            _CreditLine(
              text:
                  '${legend.name}, archive ${index + 1}: '
                  '${legend.gallery[index].credit.author}, '
                  '${legend.gallery[index].credit.license}',
              source: legend.gallery[index].credit.source,
            ),
        const SizedBox(height: AppTheme.spaceMd),
        for (final photo in wallPhotos)
          _CreditLine(
            text:
                'Gym Wall, ${photo.id}: ${photo.credit.author}, '
                '${photo.credit.license}',
            source: photo.credit.source,
          ),
      ],
    );
  }
}

/// One credit, tappable through to the file page the photo came from.
class _CreditLine extends StatelessWidget {
  const _CreditLine({required this.text, required this.source});

  final String text;
  final String source;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        openExternal(source);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spaceXs),
        child: Text(text, style: AppTheme.caption),
      ),
    );
  }
}

/// A tappable row that hands its url to the browser, or says it could not.
class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.url});

  static const String _failedMessage = 'Could not open the link.';

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _open(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppTheme.minTapTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMd,
                vertical: AppTheme.spaceSm,
              ),
              child: Row(
                children: [
                  Expanded(child: Text(label, style: AppTheme.body)),
                  const SizedBox(width: AppTheme.spaceMd),
                  const Icon(
                    Icons.open_in_new_rounded,
                    color: AppTheme.chalkFaint,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await openExternal(url);
    if (!opened) {
      messenger.showSnackBar(const SnackBar(content: Text(_failedMessage)));
    }
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.eyebrow, required this.children});

  final String eyebrow;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow, style: AppTheme.label),
        const SizedBox(height: AppTheme.spaceMd),
        ...children,
      ],
    );
  }
}
