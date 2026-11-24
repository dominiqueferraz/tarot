import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarot_squared/artwork.dart';
import 'package:tarot_squared/fool/puzzle_deal.dart';
import 'package:tarot_squared/lives_indicator.dart';
import 'package:tarot_squared/main.dart' as app;

import '../test/app_test.dart'
    show dragStroke, english, portuguese, previewTarget, targetSemantics;
import '../test/fool_deal_test.dart'
    show
        brokenRoadReplay,
        cells,
        dockReplay,
        dockSize,
        fairSplitReplay,
        fromBehindReplay,
        guidedRoutes,
        highWaterSize,
        lampReplay,
        lampSize,
        marketDayReplay,
        marketDaySize,
        marketSize,
        millReplay,
        nightFishingReplay,
        parReplay,
        partnerReplay,
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
    'plays the first five puzzles, persists Market Day, and restores a life',
    (tester) async {
      final preferences = SharedPreferencesAsync();
      final original = await preferences.getString('language');
      final previousUnlock = await preferences.getString('unlockedPuzzle');
      final previousLives = await preferences.getStringList('lives');
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
      addTearDown(
        () => previousLives == null
            ? preferences.remove('lives')
            : preferences.setStringList('lives', previousLives),
      );
      final nextLife = DateTime.now().add(const Duration(minutes: 15));
      final deadline = '${nextLife.millisecondsSinceEpoch}';
      final initialLives = ['v2', deadline, deadline, deadline];
      await preferences.remove('unlockedPuzzle');
      await preferences.setString('language', 'en');
      await preferences.setStringList('lives', initialLives);
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
      expect(find.text(english.nextPuzzle), findsOneWidget);
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
      expect(find.text(english.nextPuzzle), findsOneWidget);
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
      expect(find.text(english.nextPuzzle), findsOneWidget);
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
      for (final cell in ['A1', 'G1', 'A6', 'G6']) {
        expect(
          find.bySemanticsLabel(english.labelWithDetail(cell, english.wall)),
          findsOneWidget,
        );
      }
      await screenshot(tester, 'tarot-squared-the-mooring');
      final bow = find.byKey(const Key('target-value-C3'));
      final stern = find.byKey(const Key('target-value-E5'));
      for (final (step, (trace, bowCut, sternCut)) in dockReplay.indexed) {
        expect(find.text(english.nextPuzzle), findsNothing);
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
      expect(find.text(english.nextPuzzle), findsOneWidget);
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
      for (final cell in ['B1', 'G1']) {
        expect(
          find.bySemanticsLabel(english.labelWithDetail(cell, english.wall)),
          findsOneWidget,
        );
      }
      await screenshot(tester, 'tarot-squared-ferrymans-fare');
      final west = find.byKey(const Key('target-value-C4'));
      final east = find.byKey(const Key('target-value-F4'));
      for (final (step, (trace, westCoins, eastCoins))
          in westFareReplay.indexed) {
        expect(find.text(english.nextPuzzle), findsNothing);
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
      expect(find.text(english.nextPuzzle), findsOneWidget);
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
      expect(
        find.bySemanticsLabel(
          RegExp(RegExp.escape(english.livesRemaining(2, 5))),
        ),
        findsOneWidget,
      );
      expect(await preferences.getStringList('lives'), initialLives);

      await tester.tap(find.byTooltip(english.close));
      await tester.pumpAndSettle();
      final lampPhase = find.byKey(const Key('phase-002'));
      final play = find.text(english.play);

      Future<void> enterLamplighter() async {
        await tester.ensureVisible(lampPhase);
        await tester.tap(lampPhase);
        await tester.pumpAndSettle();
        await tester.ensureVisible(play);
        await tester.tap(play);
        await tester.pumpAndSettle();
      }

      await screenshot(tester, 'tarot-hearts-campaign');
      await tester.tap(find.byType(LivesIndicator));
      await tester.pumpAndSettle();
      await screenshot(tester, 'tarot-hearts-lives-dialog');
      await tester.tap(find.text(english.close));
      await tester.pumpAndSettle();
      await enterLamplighter();
      await tester.tap(find.byTooltip(english.returnToPath));
      await tester.pumpAndSettle();
      expect(find.text(english.leavePuzzleWarning), findsOneWidget);
      expect(find.byType(LifeStatus), findsOneWidget);
      await screenshot(tester, 'tarot-hearts-confirm-exit');
      await tester.tap(find.text(english.keepPlaying));
      await tester.pumpAndSettle();
      expect(await preferences.getStringList('lives'), initialLives);
      await tester.tap(find.byTooltip(english.returnToPath));
      await tester.pumpAndSettle();
      await tester.tap(find.text(english.returnToPath));
      await tester.pumpAndSettle();
      final afterExit = (await preferences.getStringList('lives'))!;
      expect(afterExit, hasLength(5));
      expect(afterExit.take(4), initialLives);
      await enterLamplighter();
      expect(find.byType(LifeStatus), findsNothing);
      await screenshot(tester, 'tarot-hearts-playing');

      final source = await rootBundle.loadString(PuzzleCatalog.assetPath);
      final lamp = PuzzleCatalog.parse(source).puzzles[1];
      final replay = PuzzleDeal(lamp);
      final size = lamp.size;
      while (!replay.finished) {
        final stroke = [
          for (var cell = 0; cell < size.cellCount; cell++)
            for (final next in size.neighbours(cell))
              if (replay.inspect([cell, next])?.totalGain == 0) [cell, next],
        ].first;
        replay.play(stroke);
        await dragStroke(
          tester,
          stroke.map(size.cellLabel).join(' '),
          size: size,
        );
      }
      expect(find.textContaining(english.noLivesLeft), findsOneWidget);
      expect(find.byType(LifeStatus), findsOneWidget);
      expect(find.text(english.retry), findsNothing);
      final afterLoss = (await preferences.getStringList('lives'))!;
      expect(afterLoss, hasLength(6));
      expect(afterLoss.take(5), afterExit);
      await screenshot(tester, 'tarot-hearts-failed-deal');

      await tester.pumpWidget(const SizedBox.shrink());
      await app.main();
      await tester.pumpAndSettle();
      await tester.tap(play);
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(
          RegExp(RegExp.escape(english.livesRemaining(0, 5))),
        ),
        findsOneWidget,
      );
      await tester.ensureVisible(lampPhase);
      await tester.tap(lampPhase);
      await tester.pumpAndSettle();
      expect(find.text(english.noLivesLeft), findsOneWidget);
      await screenshot(tester, 'tarot-hearts-out-of-lives');

      await tester.pumpWidget(const SizedBox.shrink());
      final elapsed = DateTime.now().subtract(const Duration(minutes: 1));
      await preferences.setStringList('lives', [
        'v2',
        '${elapsed.millisecondsSinceEpoch}',
        ...afterLoss.skip(2),
      ]);
      await app.main();
      await tester.pumpAndSettle();
      await tester.tap(play);
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(
          RegExp(RegExp.escape(english.livesRemaining(1, 5))),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('clears levels 006 through 011', (tester) async {
    final source = await rootBundle.loadString(PuzzleCatalog.assetPath);
    final catalog = PuzzleCatalog.parse(source);
    final split = catalog.puzzles.singleWhere((puzzle) => puzzle.id == '007');
    await tester.pumpWidget(
      app.TarotSquaredApp(
        catalog: catalog,
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
    expect(find.text(portuguese.nextPuzzle), findsOneWidget);
    await screenshot(tester, 'tarot-squared-market-day-complete');

    await tester.tap(find.text(portuguese.nextPuzzle));
    await tester.pumpAndSettle();
    expect(find.text(portuguese.fairSplitTitle), findsOneWidget);
    expect(
      previewTarget(portuguese, portuguese.westFloat, portuguese.cups, 44),
      findsOneWidget,
    );
    expect(
      previewTarget(portuguese, portuguese.eastFloat, portuguese.cups, 50),
      findsOneWidget,
    );
    await screenshot(tester, 'tarot-squared-fair-split-preview');
    await tester.ensureVisible(play);
    await tester.tap(play);
    await tester.pumpAndSettle();
    final retry = find.text(portuguese.retry);
    final west = find.byKey(const Key('target-value-B3'));
    final east = find.byKey(const Key('target-value-E6'));
    expect(retry, findsNothing);
    await screenshot(tester, 'tarot-squared-fair-split-board');
    for (final (step, (trace, westAmount, eastAmount))
        in fairSplitReplay.indexed) {
      await dragStroke(tester, trace, size: split.size);
      expect(
        tester.widget<Text>(west).data,
        portuguese.targetProgress(westAmount, 44),
      );
      expect(
        tester.widget<Text>(east).data,
        portuguese.targetProgress(eastAmount, 50),
      );
      if (step == fairSplitReplay.length - 2) {
        expect(find.text(portuguese.fillTogetherHint), findsOneWidget);
        expect(retry, findsNothing);
        await screenshot(tester, 'tarot-squared-fair-split-spill');
      }
    }
    expect(find.text(portuguese.fillTogetherHint), findsNothing);
    expect(find.bySemanticsLabel(portuguese.starRating(3)), findsOneWidget);
    await screenshot(tester, 'tarot-squared-fair-split-complete');

    await tester.tap(find.text(portuguese.nextPuzzle));
    await tester.pumpAndSettle();
    expect(find.text(portuguese.fromBehindTitle), findsOneWidget);
    expect(find.text(portuguese.moveLimit(18)), findsOneWidget);
    await tester.ensureVisible(play);
    await tester.tap(play);
    await tester.pumpAndSettle();
    final lamp = find.byKey(const Key('target-value-D4'));
    expect(find.byKey(const Key('arrival-ribbons')), findsNothing);
    expect(find.text(portuguese.fromBehindObjective), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        portuguese.labelWithDetail(
          'D4',
          portuguese.labelWithDetail(
            portuguese.namedTargetProgress(
              portuguese.westFacingLamp,
              portuguese.targetProgress(0, 32),
            ),
            portuguese.aimRight,
          ),
        ),
      ),
      findsOneWidget,
    );
    await screenshot(tester, 'tarot-squared-from-behind-board');
    for (final (trace, light) in fromBehindReplay) {
      await dragStroke(tester, trace);
      expect(
        tester.widget<Text>(lamp).data,
        portuguese.targetProgress(light, 32),
      );
    }
    expect(find.bySemanticsLabel(portuguese.starRating(3)), findsOneWidget);
    await screenshot(tester, 'tarot-squared-from-behind-complete');

    await tester.tap(find.text(portuguese.nextPuzzle));
    await tester.pumpAndSettle();
    expect(find.text(portuguese.keepMeAPartnerTitle), findsOneWidget);
    expect(find.text(portuguese.keepMeAPartnerStory), findsOneWidget);
    expect(
      previewTarget(portuguese, portuguese.landingBasin, portuguese.cups, 30),
      findsOneWidget,
    );
    await tester.ensureVisible(play);
    await tester.tap(play);
    await tester.pumpAndSettle();
    final partner = catalog.puzzles.singleWhere((puzzle) => puzzle.id == '009');
    final basin = find.byKey(const Key('target-value-D7'));
    expect(find.text(portuguese.keepMeAPartnerObjective), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        targetSemantics(portuguese, 'D7', portuguese.landingBasin, 0, 30),
      ),
      findsOneWidget,
    );
    await screenshot(tester, 'tarot-squared-landing-basin-opening');
    for (final (trace, water) in partnerReplay) {
      await dragStroke(tester, trace, size: partner.size);
      expect(
        tester.widget<Text>(basin).data,
        portuguese.targetProgress(water, 30),
        reason: trace,
      );
    }
    expect(find.text(portuguese.nextPuzzle), findsOneWidget);
    expect(find.bySemanticsLabel(portuguese.starRating(3)), findsOneWidget);
    await screenshot(tester, 'tarot-squared-landing-basin-complete');

    await tester.tap(find.text(portuguese.nextPuzzle));
    await tester.pumpAndSettle();
    expect(find.text(portuguese.nightFishingTitle), findsOneWidget);
    expect(find.text(portuguese.nightFishingStory), findsOneWidget);
    expect(
      previewTarget(portuguese, portuguese.harbourLamp, portuguese.wands, 6),
      findsOneWidget,
    );
    expect(
      previewTarget(portuguese, portuguese.mooringCord, portuguese.swords, 6),
      findsOneWidget,
    );
    await screenshot(tester, 'tarot-squared-night-fishing-preview');
    await tester.ensureVisible(play);
    await tester.tap(play);
    await tester.pumpAndSettle();
    final night = catalog.puzzles.singleWhere((puzzle) => puzzle.id == '010');
    final harbour = find.byKey(const Key('target-value-C5'));
    final mooring = find.byKey(const Key('target-value-F5'));
    expect(find.text(portuguese.nightFishingObjective), findsOneWidget);
    await screenshot(tester, 'tarot-squared-night-fishing-opening');
    for (final (index, (trace, light, cut)) in nightFishingReplay.indexed) {
      await dragStroke(tester, trace, size: night.size);
      expect(
        tester.widget<Text>(harbour).data,
        portuguese.targetProgress(light, 6),
        reason: trace,
      );
      expect(
        tester.widget<Text>(mooring).data,
        portuguese.targetProgress(cut, 6),
        reason: trace,
      );
      if (index == 0) {
        await screenshot(tester, 'tarot-squared-night-fishing-setup');
      }
    }
    expect(find.text(portuguese.viewFoolJourney), findsOneWidget);
    expect(
      find.bySemanticsLabel(portuguese.journeyFragmentFound),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(portuguese.starRating(3)), findsOneWidget);
    await screenshot(tester, 'tarot-squared-night-fishing-complete');
    await tester.tap(find.text(portuguese.viewFoolJourney));
    await tester.pumpAndSettle();
    expect(find.text(portuguese.foolFragments(10, 10)), findsOneWidget);
    await screenshot(tester, 'tarot-squared-fool-journey');
    await tester.tap(find.text(portuguese.close));
    await tester.pumpAndSettle();
    expect(find.text(portuguese.brokenRoadTitle), findsOneWidget);
    expect(find.text(portuguese.brokenRoadStory), findsOneWidget);
    await tester.ensureVisible(play);
    await tester.tap(play);
    await tester.pumpAndSettle();
    final bell = find.byKey(const Key('target-value-E4'));
    expect(find.text(portuguese.brokenRoadObjective), findsOneWidget);
    expect(find.byKey(const Key('broken-road-scene')), findsOneWidget);
    expect(find.byKey(const Key('arrival-ribbons')), findsNothing);
    expect(
      find.bySemanticsLabel(
        portuguese.labelWithDetail('C2', portuguese.roadGap),
      ),
      findsOneWidget,
    );
    await screenshot(tester, 'tarot-squared-broken-road-opening');
    await dragStroke(tester, 'B1 E1 E4 B4 B1');
    expect(
      find.bySemanticsLabel(portuguese.movesRemaining(14)),
      findsOneWidget,
    );
    expect(tester.widget<Text>(bell).data, portuguese.targetProgress(0, 11));
    for (final (trace, total) in brokenRoadReplay) {
      await dragStroke(tester, trace);
      expect(
        tester.widget<Text>(bell).data,
        portuguese.targetProgress(total, 11),
      );
    }
    expect(find.bySemanticsLabel(portuguese.starRating(3)), findsOneWidget);
    expect(find.text(portuguese.continueJourney), findsOneWidget);
    await screenshot(tester, 'tarot-squared-broken-road-complete');
  });
}
