import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/data/app_identity.dart';
import 'package:boxer_os/data/legends.dart';
import 'package:boxer_os/pages/about_page.dart';
import 'package:boxer_os/theme/app_theme.dart';
import 'package:boxer_os/utils/external_links.dart' as external_links;

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const MaterialApp(home: AboutPage()));
  await tester.pumpAndSettle();
}

void main() {
  final originalLauncher = external_links.launcher;

  tearDown(() {
    external_links.launcher = originalLauncher;
  });

  testWidgets('renders identity, made by, license and privacy sections', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('BOXER OS'), findsOneWidget);
    expect(find.text('Version ${AppTheme.appVersion}'), findsOneWidget);

    expect(find.text('MADE BY'), findsOneWidget);
    expect(find.text(AppIdentity.developer), findsOneWidget);
    expect(find.text(AppIdentity.brand), findsOneWidget);
    expect(
      find.text(
        '${AppIdentity.copyright}. All rights reserved for commercial use.',
      ),
      findsOneWidget,
    );

    expect(find.text('LICENSE'), findsOneWidget);
    expect(find.text(AppIdentity.licenseName), findsOneWidget);
    expect(find.text('Read the license'), findsOneWidget);
    expect(find.text('Source code on GitHub'), findsOneWidget);

    expect(find.text('PRIVACY'), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
  });

  testWidgets('renders a credit line for every legend', (tester) async {
    await _pump(tester);

    expect(find.text('CREDITS'), findsOneWidget);
    for (final legend in legends) {
      expect(
        find.text(
          '${legend.name}: ${legend.credit.author}, ${legend.credit.license}',
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('tapping "Read the license" opens the license url', (
    tester,
  ) async {
    final requested = <String>[];
    external_links.launcher = (url) async {
      requested.add(url);
      return true;
    };
    await _pump(tester);

    await tester.tap(find.text('Read the license'));
    await tester.pumpAndSettle();

    expect(requested, [AppIdentity.licenseUrl]);
  });

  testWidgets('tapping "Source code on GitHub" opens the source url', (
    tester,
  ) async {
    final requested = <String>[];
    external_links.launcher = (url) async {
      requested.add(url);
      return true;
    };
    await _pump(tester);

    await tester.tap(find.text('Source code on GitHub'));
    await tester.pumpAndSettle();

    expect(requested, [AppIdentity.sourceUrl]);
  });

  testWidgets('tapping "Privacy policy" opens the privacy policy url', (
    tester,
  ) async {
    final requested = <String>[];
    external_links.launcher = (url) async {
      requested.add(url);
      return true;
    };
    await _pump(tester);

    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();

    expect(requested, [AppIdentity.privacyPolicyUrl]);
  });

  testWidgets('tapping "Contact" opens a mailto link', (tester) async {
    final requested = <String>[];
    external_links.launcher = (url) async {
      requested.add(url);
      return true;
    };
    await _pump(tester);

    await tester.tap(find.text('Contact'));
    await tester.pumpAndSettle();

    expect(requested, [AppIdentity.contactUrl]);
  });

  testWidgets('tapping a credit line opens its photo source', (tester) async {
    final requested = <String>[];
    external_links.launcher = (url) async {
      requested.add(url);
      return true;
    };
    await _pump(tester);

    final firstLegend = legends.first;
    await tester.tap(
      find.text(
        '${firstLegend.name}: ${firstLegend.credit.author}, '
        '${firstLegend.credit.license}',
      ),
    );
    await tester.pumpAndSettle();

    expect(requested, [firstLegend.credit.source]);
  });

  testWidgets('a failed link shows the could not open snackbar', (
    tester,
  ) async {
    external_links.launcher = (url) async => false;
    await _pump(tester);

    await tester.tap(find.text('Read the license'));
    await tester.pumpAndSettle();

    expect(find.text('Could not open the link.'), findsOneWidget);
  });

  testWidgets('a successful link shows no snackbar', (tester) async {
    external_links.launcher = (url) async => true;
    await _pump(tester);

    await tester.tap(find.text('Read the license'));
    await tester.pumpAndSettle();

    expect(find.text('Could not open the link.'), findsNothing);
  });
}
