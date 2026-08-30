import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A poster seen as it would look on this phone: the child scaled into a
/// bezel that keeps the device's own aspect ratio.
class PhonePreview extends StatelessWidget {
  const PhonePreview({required this.child, super.key});

  static const double _bezel = 3;
  static const double _radius = AppTheme.radiusLg * 2;
  static const double _holeFraction = 0.04;
  static const double _holeInsetFraction = 0.025;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    return AspectRatio(
      aspectRatio: screen.width / screen.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surfaceRaised,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: AppTheme.line, width: _bezel),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              fit: StackFit.expand,
              children: [
                FittedBox(fit: BoxFit.cover, child: child),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: constraints.maxWidth * _holeInsetFraction,
                    ),
                    child: SizedBox.square(
                      dimension: constraints.maxWidth * _holeFraction,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppTheme.ink,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
