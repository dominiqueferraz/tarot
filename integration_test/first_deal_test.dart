import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarot/main.dart' as app;

import '../test/app_test.dart' show dragStroke;
import '../test/fool_deal_test.dart'
    show cells, guidedRoutes, lampReplay, parReplay;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
  const capture = bool.fromEnvironment('CAPTURE_TAROT_UI');

  Future<void> screenshot(WidgetTester tester, String name) async {
    if (!capture) return;
    await tester.pump();
    await tester.pump();
    await binding.takeScreenshot(name);
  }

  testWidgets('plays both puzzles and persists the language and unlock', (
    tester,
  ) async {
    final preferences = SharedPreferencesAsync();
    final original = await preferences.getString('language');
    final previousUnlock = await preferences.getString('unlockedPuzzle');
    addTearDown(
      () => original == null
          ? preferences.remove('language')
          : preferences.setString('language', original),
    );
    addTearDown(
      () => previousUnlock == null
          ? preferences.remove('unlockedPuzzle')
          : preferences.setString('unlockedPuzzle', previousUnlock),
    );
    await preferences.remove('unlockedPuzzle');
    await preferences.setString('language', 'en');
    await app.main();
    await tester.pumpAndSettle();
    expect(find.text('THE MOON'), findsOneWidget);
    await screenshot(tester, 'tarot-squared-home');

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await screenshot(tester, 'tarot-squared-language');
    await tester.tap(find.text('Português'));
    await tester.pumpAndSettle();
    expect(find.text('Jogar'), findsOneWidget);
    expect(await preferences.getString('language'), 'pt');
    await tester.pumpWidget(const SizedBox.shrink());
    await app.main();
    await tester.pumpAndSettle();
    expect(find.text('Jogar'), findsOneWidget);

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('campaign-path')), findsOneWidget);
    await screenshot(tester, 'tarot-squared-campaign-path');
    await tester.tap(find.byKey(const Key('phase-001')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('phase-preview')), findsOneWidget);
    expect(find.text('Wands · 30 light'), findsOneWidget);
    await screenshot(tester, 'tarot-squared-phase-fools-step');
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.text('Light the trail marker'), findsOneWidget);
    expect(find.bySemanticsLabel('Wands'), findsOneWidget);
    final markerValue = find.byKey(const Key('trail-marker-value'));
    expect(tester.widget<Text>(markerValue).data, '0/30');
    await screenshot(tester, 'tarot-squared-tutorial');
    for (final route in guidedRoutes) {
      await dragStroke(tester, route);
    }
    expect(find.bySemanticsLabel('Wands'), findsOneWidget);
    expect(tester.widget<Text>(markerValue).data, '6/30');
    expect(find.text('19'), findsOneWidget);
    await screenshot(tester, 'tarot-squared-handoff');
    for (final (route, _) in parReplay) {
      await dragStroke(tester, route);
    }
    expect(find.text('Deal complete'), findsOneWidget);
    expect(tester.widget<Text>(markerValue).data, '30/30');
    await screenshot(tester, 'tarot-squared-complete');

    await tester.tap(find.text('Next puzzle'));
    await tester.pumpAndSettle();
    expect(find.text('Cups · 44 light'), findsOneWidget);
    await screenshot(tester, 'tarot-squared-phase-lamplighter');
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    final lampValue = find.byKey(const Key('quay-lamp-value'));
    final hint = find.text(
      'The lamp loses 1 light on moves that don’t feed it.',
    );
    expect(find.text('Lamplighter'), findsOneWidget);
    expect(find.bySemanticsLabel('Cups'), findsOneWidget);
    expect(find.text('Fuel the quay lamp'), findsOneWidget);
    expect(tester.widget<Text>(lampValue).data, '0/44');
    expect(hint, findsNothing);
    await screenshot(tester, 'tarot-squared-lamplighter');
    for (final (index, (route, light)) in lampReplay.indexed) {
      final captureDim = capture && index == 1;
      await dragStroke(tester, route, settle: !captureDim);
      if (captureDim) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 70));
        await screenshot(tester, 'tarot-squared-lamplighter-dimming');
        await tester.pumpAndSettle();
      }
      expect(tester.widget<Text>(lampValue).data, '$light/44', reason: route);
      if (index == 0) {
        await screenshot(tester, 'tarot-squared-lamplighter-first-light');
      }
      if (index == 1) {
        expect(find.text('−1'), findsNothing);
        expect(hint, findsOneWidget);
        await screenshot(tester, 'tarot-squared-lamplighter-fading');
        final grid = tester.getRect(find.byKey(const Key('fool-grid')));
        final cell = cells(lampReplay[index + 1].$1).first;
        final gesture = await tester.startGesture(
          grid.topLeft +
              Offset(
                (cell % 6 + .5) * grid.width / 6,
                (cell ~/ 6 + .5) * grid.height / 6,
              ),
        );
        await tester.pump();
        expect(hint, findsNothing);
        await gesture.cancel();
        await tester.pumpAndSettle();
      }
    }
    expect(find.text('Deal complete'), findsOneWidget);
    await screenshot(tester, 'tarot-squared-lamplighter-complete');
    expect(await preferences.getString('unlockedPuzzle'), '002');
    await tester.pumpWidget(const SizedBox.shrink());
    await app.main();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('phase-002')), findsOneWidget);
    expect(find.byKey(const Key('phase-001')), findsOneWidget);
    await tester.tap(find.byKey(const Key('phase-002')));
    await tester.pumpAndSettle();
    expect(find.text('Lamplighter'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });
}
