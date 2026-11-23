import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarot_squared/artwork.dart';
import 'package:tarot_squared/fool/puzzle_definition.dart';
import 'package:tarot_squared/main.dart' as app;

import '../test/app_test.dart'
    show dragStroke, english, portuguese, previewTarget, targetSemantics;
import '../test/fool_deal_test.dart'
    show
        cells,
        dockReplay,
        dockSize,
        guidedRoutes,
        highWaterSize,
        lampReplay,
        lampSize,
        marketDayReplay,
        marketDaySize,
        marketSize,
        millReplay,
        parReplay,
        westFareReplay;

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

  testWidgets(
    'plays the first five puzzles and persists the Market Day unlock',
    (tester) async {
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
      expect(find.text(english.moon.toUpperCase()), findsOneWidget);
      await screenshot(tester, 'tarot-squared-home');

      await tester.tap(find.byTooltip(english.settings));
      await tester.pumpAndSettle();
      await screenshot(tester, 'tarot-squared-language');
      await tester.tap(find.text('Português'));
      await tester.pumpAndSettle();
      expect(find.text(portuguese.play), findsOneWidget);
      expect(await preferences.getString('language'), 'pt');
      await tester.pumpWidget(const SizedBox.shrink());
      await app.main();
      await tester.pumpAndSettle();
      expect(find.text(portuguese.play), findsOneWidget);

      await tester.tap(find.byTooltip(portuguese.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(english.play));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('campaign-path')), findsOneWidget);
      await screenshot(tester, 'tarot-squared-campaign-path');
      await tester.tap(find.byKey(const Key('phase-001')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('phase-preview')), findsOneWidget);
      expect(
        previewTarget(english, english.trailMarker, english.wands, 30),
        findsOneWidget,
      );
      await screenshot(tester, 'tarot-squared-phase-fools-step');
      await tester.tap(find.text(english.play));
      await tester.pumpAndSettle();
      expect(find.text(english.foolsStepObjective), findsOneWidget);
      expect(find.text(english.puzzleIndex(1)), findsOneWidget);
      expect(find.bySemanticsLabel(english.wands), findsOneWidget);
      final markerValue = find.byKey(const Key('target-value-E4'));
      expect(
        tester.widget<Text>(markerValue).data,
        english.targetProgress(0, 30),
      );
      await screenshot(tester, 'tarot-squared-tutorial');
      for (final route in guidedRoutes) {
        await dragStroke(tester, route);
      }
      expect(find.bySemanticsLabel(english.wands), findsOneWidget);
      expect(
        tester.widget<Text>(markerValue).data,
        english.targetProgress(6, 30),
      );
      expect(find.text(english.puzzleIndex(19)), findsOneWidget);
      await screenshot(tester, 'tarot-squared-handoff');
      for (final (route, _) in parReplay) {
        await dragStroke(tester, route);
      }
      expect(find.text(english.clear), findsOneWidget);
      expect(
        tester.widget<Text>(markerValue).data,
        english.targetProgress(30, 30),
      );
      await screenshot(tester, 'tarot-squared-complete');

      await tester.tap(find.text(english.nextPuzzle));
      await tester.pumpAndSettle();
      expect(
        previewTarget(english, english.quayLamp, english.cups, 44),
        findsOneWidget,
      );
      await screenshot(tester, 'tarot-squared-phase-lamplighter');
      await tester.tap(find.text(english.play));
      await tester.pumpAndSettle();
      final lampValue = find.byKey(const Key('target-value-C3'));
      final hint = find.text(
        english.targetFadingHint(english.quayLamp, english.lightGoal(1)),
      );
      expect(find.text(english.lamplighterTitle), findsOneWidget);
      expect(find.text(english.puzzleIndex(2)), findsOneWidget);
      expect(find.bySemanticsLabel(english.cups), findsOneWidget);
      expect(find.text(english.lamplighterObjective), findsOneWidget);
      expect(
        tester.widget<Text>(lampValue).data,
        english.targetProgress(0, 44),
      );
      expect(hint, findsNothing);
      await screenshot(tester, 'tarot-squared-lamplighter');
      for (final (index, (route, light)) in lampReplay.indexed) {
        final captureDim = capture && index == 1;
        await dragStroke(tester, route, size: lampSize, settle: !captureDim);
        if (captureDim) {
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 70));
          await screenshot(tester, 'tarot-squared-lamplighter-dimming');
          await tester.pumpAndSettle();
        }
        expect(
          tester.widget<Text>(lampValue).data,
          english.targetProgress(light, 44),
          reason: route,
        );
        if (index == 0) {
          await screenshot(tester, 'tarot-squared-lamplighter-first-light');
        }
        if (index == 1) {
          expect(find.text('−1'), findsNothing);
          expect(hint, findsOneWidget);
          await screenshot(tester, 'tarot-squared-lamplighter-fading');
          final grid = tester.getRect(find.byKey(const Key('fool-grid')));
          final cell = cells(lampReplay[index + 1].$1, size: lampSize).first;
          final gesture = await tester.startGesture(
            grid.topLeft +
                Offset(
                  (lampSize.columnOf(cell) + .5) *
                      grid.width /
                      lampSize.columns,
                  (lampSize.rowOf(cell) + .5) * grid.height / lampSize.rows,
                ),
          );
          await tester.pump();
          expect(hint, findsNothing);
          await gesture.cancel();
          await tester.pumpAndSettle();
        }
      }
      expect(find.text(english.clear), findsOneWidget);
      await screenshot(tester, 'tarot-squared-lamplighter-complete');
      expect(await preferences.getString('unlockedPuzzle'), '003');
      await tester.tap(find.text(english.nextPuzzle));
      await tester.pumpAndSettle();
      expect(find.text(english.highWaterTitle), findsOneWidget);
      expect(
        previewTarget(english, english.millInlet, english.cups, 32),
        findsOneWidget,
      );
      await tester.tap(find.text(english.play));
      await tester.pumpAndSettle();
      final grid = tester.getRect(find.byKey(const Key('fool-grid')));
      final screen = tester.getRect(find.byType(app.TarotSquaredApp));
      expect(grid.width / grid.height, closeTo(6 / 7, .0001));
      expect(screen.contains(grid.bottomRight), isTrue);
      expect(find.text(english.puzzleIndex(3)), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          targetSemantics(english, 'B5', english.millInlet, 0, 32),
        ),
        findsOneWidget,
      );
      await screenshot(tester, 'tarot-squared-high-water');
      final inlet = find.byKey(const Key('target-value-B5'));
      for (final (trace, water) in millReplay) {
        await dragStroke(tester, trace, size: highWaterSize);
        expect(
          tester.widget<Text>(inlet).data,
          english.targetProgress(water, 32),
          reason: trace,
        );
        if (water == 4) {
          await screenshot(tester, 'tarot-squared-mill-first-water');
        }
      }
      expect(find.text(english.clear), findsOneWidget);
      await screenshot(tester, 'tarot-squared-high-water-complete');
      expect(await preferences.getString('unlockedPuzzle'), '004');
      await tester.tap(find.text(english.nextPuzzle));
      await tester.pumpAndSettle();
      expect(find.text(english.mooringTitle), findsOneWidget);
      for (final cord in [english.bowCord, english.sternCord]) {
        expect(
          previewTarget(english, cord, english.swords, 24),
          findsOneWidget,
        );
      }
      await screenshot(tester, 'tarot-squared-phase-the-mooring');
      expect(find.text(english.moveLimit(26)), findsOneWidget);
      await tester.tap(find.text(english.play));
      await tester.pumpAndSettle();
      final dock = tester.getRect(find.byKey(const Key('fool-grid')));
      expect(dock.width / dock.height, closeTo(7 / 6, .0001));
      expect(find.text(english.puzzleIndex(4)), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          targetSemantics(english, 'C3', english.bowCord, 0, 24),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          targetSemantics(english, 'E5', english.sternCord, 0, 24),
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp(r'^(A1|G1),')), findsNothing);
      await screenshot(tester, 'tarot-squared-the-mooring');
      final bow = find.byKey(const Key('target-value-C3'));
      final stern = find.byKey(const Key('target-value-E5'));
      for (final (step, (trace, bowCut, sternCut)) in dockReplay.indexed) {
        expect(find.text(english.clear), findsNothing);
        await dragStroke(tester, trace, size: dockSize);
        expect(
          tester.widget<Text>(bow).data,
          english.targetProgress(bowCut, 24),
          reason: trace,
        );
        expect(
          tester.widget<Text>(stern).data,
          english.targetProgress(sternCut, 24),
          reason: trace,
        );
        if (step == 0) {
          expect(find.text(english.linkMovesRemaining(2)), findsOneWidget);
          expect(
            find.text(english.guideLinkedAim(english.swords, 2)),
            findsOneWidget,
          );
          await screenshot(tester, 'tarot-squared-mooring-link');
        } else if (step == 1) {
          expect(find.text(english.linkMovesRemaining(1)), findsOneWidget);
          expect(find.byKey(const Key('fool-help-bubble')), findsNothing);
          await screenshot(tester, 'tarot-squared-mooring-shared-cut');
        } else if (step == 2) {
          expect(find.text(english.linkMovesRemaining(1)), findsNothing);
        }
      }
      expect(find.text(english.clear), findsOneWidget);
      await screenshot(tester, 'tarot-squared-the-mooring-complete');
      expect(await preferences.getString('unlockedPuzzle'), '005');
      await tester.tap(find.text(english.nextPuzzle));
      await tester.pumpAndSettle();
      expect(find.text(english.ferrymansFareTitle), findsOneWidget);
      for (final pan in [english.westPan, english.eastPan]) {
        expect(previewTarget(english, pan, english.coins, 24), findsOneWidget);
      }
      expect(find.text(english.moveLimit(25)), findsOneWidget);
      await tester.tap(find.text(english.play));
      await tester.pumpAndSettle();
      final market = tester.getRect(find.byKey(const Key('fool-grid')));
      expect(market.width / market.height, closeTo(1, .0001));
      expect(screen.contains(market.bottomRight), isTrue);
      expect(
        find.bySemanticsLabel(
          targetSemantics(english, 'C4', english.westPan, 0, 24),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          targetSemantics(english, 'F4', english.eastPan, 0, 24),
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp(r'^(B1|G1),')), findsNothing);
      await screenshot(tester, 'tarot-squared-ferrymans-fare');
      final west = find.byKey(const Key('target-value-C4'));
      final east = find.byKey(const Key('target-value-F4'));
      for (final (step, (trace, westCoins, eastCoins))
          in westFareReplay.indexed) {
        expect(find.text(english.clear), findsNothing);
        await dragStroke(tester, trace, size: marketSize);
        expect(
          tester.widget<Text>(west).data,
          english.targetProgress(westCoins, 24),
          reason: trace,
        );
        expect(
          tester.widget<Text>(east).data,
          english.targetProgress(eastCoins, 24),
          reason: trace,
        );
        if (step == 8) {
          await screenshot(tester, 'tarot-squared-ferrymans-fare-tipped');
        }
      }
      expect(find.text(english.clear), findsOneWidget);
      await screenshot(tester, 'tarot-squared-ferrymans-fare-complete');
      expect(await preferences.getString('unlockedPuzzle'), '006');
      await tester.tap(find.text(english.nextPuzzle));
      await tester.pumpAndSettle();
      expect(find.text(english.marketDayStory), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text(english.play));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('phase-002')), findsOneWidget);
      expect(find.byKey(const Key('phase-001')), findsOneWidget);
      final marketPhase = find.byKey(const Key('phase-006'));
      await tester.ensureVisible(marketPhase);
      await tester.tap(marketPhase);
      await tester.pumpAndSettle();
      expect(find.text(english.marketDayTitle), findsOneWidget);
      expect(find.text(english.play), findsOneWidget);
    },
  );

  testWidgets('opens the bread stall and clears Market Day', (tester) async {
    final source = await rootBundle.loadString(PuzzleCatalog.assetPath);
    await tester.pumpWidget(
      app.TarotSquaredApp(
        catalog: PuzzleCatalog.parse(source),
        artwork: await Artwork.load(),
        initialLanguage: 'pt',
        unlockedPuzzle: '006',
      ),
    );
    await tester.pumpAndSettle();
    final play = find.text(portuguese.play);
    await tester.tap(play);
    await tester.pumpAndSettle();
    final coinBadge = find.byKey(const Key('phase-suit-006-coin'));
    await tester.ensureVisible(coinBadge);
    final singleBadge = find.byKey(const Key('phase-suit-005-coin'));
    expect(tester.getSize(coinBadge), tester.getSize(singleBadge));
    expect(find.byKey(const Key('phase-suit-006-wand')), findsOneWidget);
    expect(find.byKey(const Key('phase-suit-006-cup')), findsOneWidget);
    await screenshot(tester, 'tarot-squared-market-day-path');
    await tester.tapAt(tester.getCenter(coinBadge));
    await tester.pumpAndSettle();
    expect(find.text(portuguese.marketDayStory), findsOneWidget);
    await screenshot(tester, 'tarot-squared-market-day-preview');
    await tester.ensureVisible(play);
    await tester.tap(play);
    await tester.pumpAndSettle();
    final panel = find.byKey(const Key('fool-suit-panel'));
    expect(find.byKey(const Key('puzzle-suit-ring')), findsOneWidget);
    for (final (suit, name) in [
      ('wand', portuguese.wands),
      ('cup', portuguese.cups),
      ('coin', portuguese.coins),
    ]) {
      expect(
        find.descendant(
          of: panel,
          matching: find.byKey(Key('puzzle-suit-$suit')),
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(name), findsOneWidget);
    }
    await screenshot(tester, 'tarot-squared-market-day-board');
    for (final (step, (trace, light, water, coins))
        in marketDayReplay.indexed) {
      await dragStroke(tester, trace, size: marketDaySize);
      for (final (cell, progress) in [
        ('C3', light),
        ('F3', water),
        ('C6', coins),
      ]) {
        final counter = find.byKey(Key('target-value-$cell'));
        expect(
          tester.widget<Text>(counter).data,
          portuguese.targetProgress(progress, 6),
          reason: trace,
        );
      }
      if (step == 1) await screenshot(tester, 'tarot-squared-market-day-work');
    }
    expect(find.text(portuguese.marketDayClear), findsOneWidget);
    await screenshot(tester, 'tarot-squared-market-day-complete');
  });
}
