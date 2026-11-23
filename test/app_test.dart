import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show FilledButton;
import 'package:tarot_squared/artwork.dart';
import 'package:tarot_squared/design_tokens.dart';
import 'package:tarot_squared/fool/puzzle_deal.dart';
import 'package:tarot_squared/fool/stroke.dart';
import 'package:tarot_squared/fool/tableau_art.dart';
import 'package:tarot_squared/l10n/generated/app_localizations.dart';
import 'package:tarot_squared/main.dart';

import 'fool_deal_test.dart'
    show
        catalog,
        cells,
        foolsStep,
        guidedRoutes,
        lampReplay,
        lampSize,
        marketDayReplay,
        marketDaySize,
        marketDayVariant,
        marketSize,
        openingSize,
        tallCatalog,
        wideCatalog;

final english = lookupAppLocalizations(const Locale('en'));
final portuguese = lookupAppLocalizations(const Locale('pt'));
final spanish = lookupAppLocalizations(const Locale('es'));

Finder previewTarget(
  AppLocalizations strings,
  String target,
  String suit,
  int quota,
) => find.bySemanticsLabel(
  strings.labelWithDetail(target, strings.suitAndQuota(suit, quota)),
);

String targetSemantics(
  AppLocalizations strings,
  String cell,
  String name,
  int current,
  int quota, {
  String? suit,
}) {
  final progress = strings.namedTargetProgress(
    name,
    strings.targetProgress(current, quota),
  );
  return strings.labelWithDetail(
    cell,
    suit == null ? progress : strings.labelWithDetail(progress, suit),
  );
}

Future<void> dragStroke(
  WidgetTester tester,
  String route, {
  bool settle = true,
  BoardSize size = openingSize,
}) async {
  final board = tester.getRect(find.byKey(const Key('fool-grid')));
  final pitch = board.width / size.columns;
  final points = cells(route, size: size).map(
    (index) =>
        board.topLeft +
        Offset(
          (size.columnOf(index) + .5) * pitch,
          (size.rowOf(index) + .5) * pitch,
        ),
  );
  final gesture = await tester.startGesture(points.first);
  for (final point in points.skip(1)) {
    await gesture.moveTo(point);
    await tester.pump();
  }
  await gesture.up();
  if (settle) await tester.pumpAndSettle();
}

Future<void> openPhase(
  WidgetTester tester,
  String id, {
  AppLocalizations? strings,
}) async {
  final play = find.text((strings ?? english).play);
  await tester.tap(play);
  await tester.pumpAndSettle();
  final phase = find.byKey(Key('phase-$id'));
  await tester.ensureVisible(phase);
  await tester.tap(phase);
  await tester.pumpAndSettle();
  await tester.ensureVisible(play);
  await tester.tap(play);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Artwork artwork;
  late String catalogSource;
  setUpAll(() async {
    artwork = await Artwork.load();
    catalogSource = await rootBundle.loadString(PuzzleCatalog.assetPath);
  });

  void expectEvenOrbit(List<Offset> offsets, double radius) {
    final spacing = 2 * radius * math.sin(math.pi / offsets.length);
    for (final (index, offset) in offsets.indexed) {
      expect(offset.distance, closeTo(radius, .01));
      final next = offsets[(index + 1) % offsets.length];
      expect((offset - next).distance, closeTo(spacing, .01));
    }
  }

  testWidgets('tall and wide boards draw and accept edge traces', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final (rectangular, route, marker, light) in [
      (tallCatalog, 'D7 E7', 'F7', 2),
      (wideCatalog, 'F1 G1', 'H1', 2),
    ]) {
      final size = rectangular.puzzles.single.size;
      await tester.pumpWidget(
        TarotSquaredApp(
          key: ValueKey(marker),
          catalog: rectangular,
          artwork: artwork,
          initialLanguage: 'en',
        ),
      );
      await openPhase(tester, '002');
      final grid = tester.getRect(find.byKey(const Key('fool-grid')));
      expect(grid.width / grid.height, closeTo(size.aspectRatio, .0001));
      expect(grid.top, greaterThan(0));
      expect(grid.bottom, lessThan(640));
      expect(
        find.bySemanticsLabel(
          targetSemantics(english, marker, english.quayLamp, 0, 44),
        ),
        findsOneWidget,
      );
      await dragStroke(tester, route, size: size);
      expect(find.bySemanticsLabel(english.movesRemaining(24)), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          targetSemantics(english, marker, english.quayLamp, light, 44),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('campaign phases climb upward and open closable previews', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TarotSquaredApp(
        catalog: catalog,
        artwork: artwork,
        initialLanguage: 'en',
      ),
    );
    await tester.tap(find.text(english.play));
    await tester.pumpAndSettle();

    final first = find.byKey(const Key('phase-001'));
    final next = find.byKey(const Key('phase-002'));
    expect(find.text(english.foolsStepTitle), findsNothing);
    expect(find.text(english.lamplighterTitle), findsNothing);
    expect(
      find.bySemanticsLabel(
        english.labelWithDetail(
          english.phaseLabel(2, english.lamplighterTitle),
          english.cups,
        ),
      ),
      findsOneWidget,
    );
    final firstMarker = find.byKey(const Key('phase-medallion-001'));
    final nextMarker = find.byKey(const Key('phase-medallion-002'));
    final delta = tester.getCenter(firstMarker) - tester.getCenter(nextMarker);
    final viewport = tester.getRect(find.byType(SingleChildScrollView));
    expect(viewport.bottom - tester.getCenter(firstMarker).dy, 106);
    expect(delta.dy, 80);
    expect(delta.dx.abs(), 18);
    expect(tester.getSize(firstMarker), const Size.square(46));
    expect(tester.getSize(first).height, greaterThanOrEqualTo(44));
    expect(tester.getRect(first).overlaps(tester.getRect(next)), isFalse);
    for (final (id, number, suit) in [
      ('001', english.puzzleIndex(1), Suit.wand),
      ('002', english.puzzleIndex(2), Suit.cup),
      ('003', english.puzzleIndex(3), Suit.cup),
    ]) {
      final marker = find.byKey(Key('phase-medallion-$id'));
      final badge = tester.getRect(
        find.byKey(Key('phase-suit-$id-${suit.name}')),
      );
      final markerRect = tester.getRect(marker);
      final label = find.descendant(of: marker, matching: find.text(number));
      expect(tester.widget<Text>(label).style?.fontSize, 24);
      expect(markerRect.overlaps(badge), isTrue);
      expect(badge.center.dx, greaterThan(markerRect.right));
    }
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.text(english.lamplighterTitle), findsOneWidget);
    expect(find.byKey(const Key('phase-illustration')), findsOneWidget);
    expect(find.text(english.lamplighterObjective), findsOneWidget);
    expect(
      previewTarget(english, english.quayLamp, english.cups, 44),
      findsOneWidget,
    );
    expect(find.text(english.moveLimit(22)), findsOneWidget);
    expect(find.text(english.normalDifficulty), findsOneWidget);
    final locked = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, english.lockedPhase),
    );
    expect(locked.onPressed, isNull);
    await tester.tap(find.byTooltip(english.close));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('phase-003')));
    await tester.pumpAndSettle();
    expect(find.text(english.highWaterTitle), findsOneWidget);
    expect(
      previewTarget(english, english.millInlet, english.cups, 32),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, english.lockedPhase),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byTooltip(english.close));
    await tester.pumpAndSettle();

    await tester.tap(first);
    await tester.pumpAndSettle();
    expect(find.text(english.foolsStepTitle), findsOneWidget);
    expect(
      previewTarget(english, english.trailMarker, english.wands, 30),
      findsOneWidget,
    );
    await tester.tap(find.text(english.play));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fool-grid')), findsOneWidget);
    expect(find.text(english.puzzleIndex(1)), findsOneWidget);
    expect(find.bySemanticsLabel(english.puzzleNumber(1)), findsOneWidget);
    await tester.tap(find.byTooltip(english.campaignPath));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('campaign-path')), findsOneWidget);
  });

  testWidgets('shows the Cups suit and a brief, nonnumeric fading cue', (
    tester,
  ) async {
    await tester.pumpWidget(
      TarotSquaredApp(
        catalog: catalog,
        artwork: artwork,
        initialLanguage: 'en',
        unlockedPuzzle: '002',
      ),
    );
    await openPhase(tester, '002');
    expect(find.text(english.puzzleIndex(2)), findsOneWidget);
    expect(find.bySemanticsLabel(english.puzzleNumber(2)), findsOneWidget);
    expect(find.text(english.lamplighterObjective), findsOneWidget);
    expect(find.bySemanticsLabel(english.cups), findsOneWidget);
    expect(find.bySemanticsLabel(english.wands), findsNothing);
    final paint = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is TableauPainter,
    );
    TableauPainter painter() =>
        tester.widget<CustomPaint>(paint).painter! as TableauPainter;
    final quay = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is QuayPainter,
    );
    double sceneLight() =>
        (tester.widget<CustomPaint>(quay).painter! as QuayPainter).light;
    final hint = find.text(
      english.targetFadingHint(english.quayLamp, english.lightGoal(1)),
    );

    expect(sceneLight(), 0);
    await dragStroke(tester, lampReplay[0].$1, size: lampSize, settle: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(sceneLight(), inExclusiveRange(0, 4 / 44));
    await tester.pumpAndSettle();
    expect(sceneLight(), 4 / 44);
    expect(painter().progress[lampSize.parseCell('C3')], 4 / 44);
    expect(painter().fadeProgress, 1);
    await dragStroke(tester, lampReplay[1].$1, size: lampSize, settle: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    expect(painter().fadeProgress, inExclusiveRange(0, 1));
    expect(
      painter().progress[lampSize.parseCell('C3')],
      inExclusiveRange(3 / 44, 4 / 44),
    );
    expect(sceneLight(), painter().progress[lampSize.parseCell('C3')]);
    await tester.pumpAndSettle();
    expect(painter().fadeProgress, 1);
    expect(painter().progress[lampSize.parseCell('C3')], 3 / 44);
    expect(sceneLight(), 3 / 44);
    expect(hint, findsOneWidget);
    expect(find.text('−1'), findsNothing);
  });

  testWidgets('changes language and opens the localized first puzzle', (
    tester,
  ) async {
    final saved = <String>[];
    await tester.pumpWidget(
      TarotSquaredApp(
        catalog: catalog,
        artwork: artwork,
        initialLanguage: 'en',
        saveLanguage: (code) async => saved.add(code),
      ),
    );
    expect(find.bySemanticsLabel(english.appTitle), findsWidgets);
    expect(find.text(english.moon.toUpperCase()), findsOneWidget);
    await tester.tap(find.byTooltip(english.settings));
    await tester.pumpAndSettle();
    expect(find.text(english.language), findsOneWidget);
    await tester.tap(find.text('Português'));
    await tester.pumpAndSettle();
    expect(find.text(portuguese.play), findsOneWidget);
    expect(find.text(portuguese.moon.toUpperCase()), findsOneWidget);
    await tester.tap(find.byTooltip(portuguese.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.text(spanish.play), findsOneWidget);
    expect(saved, ['pt', 'es']);
    await openPhase(tester, '001', strings: spanish);
    expect(find.text(spanish.puzzleIndex(1)), findsOneWidget);
    expect(find.bySemanticsLabel(spanish.puzzleNumber(1)), findsOneWidget);
    expect(find.text(spanish.foolsStepTitle), findsWidgets);
    expect(find.text(spanish.foolsStepObjective), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        targetSemantics(spanish, 'E4', spanish.trailMarker, 0, 30),
      ),
      findsOneWidget,
    );
    expect(find.text(spanish.guideMatch), findsOneWidget);
    expect(find.bySemanticsLabel(spanish.wands), findsOneWidget);
    expect(find.text('Pista'), findsNothing);
    expect(find.text('Reiniciar'), findsNothing);
  });

  testWidgets('localizes each mooring cord and its progress', (tester) async {
    await tester.pumpWidget(
      TarotSquaredApp(
        catalog: catalog,
        artwork: artwork,
        initialLanguage: 'pt',
        unlockedPuzzle: '004',
      ),
    );
    await openPhase(tester, '004', strings: portuguese);
    expect(find.text(portuguese.mooringTitle), findsOneWidget);
    expect(find.text(portuguese.mooringObjective), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        targetSemantics(portuguese, 'C3', portuguese.bowCord, 0, 24),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        targetSemantics(portuguese, 'E5', portuguese.sternCord, 0, 24),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the market fits a compact phone and names both pans', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TarotSquaredApp(
        catalog: catalog,
        artwork: artwork,
        initialLanguage: 'pt',
        unlockedPuzzle: '005',
      ),
    );
    await openPhase(tester, '005', strings: portuguese);
    expect(find.text(portuguese.ferrymansFareTitle), findsOneWidget);
    expect(find.text(portuguese.ferrymansFareObjective), findsOneWidget);
    final bounds = tester.getRect(find.byKey(const Key('fool-grid')));
    expect(bounds.width, closeTo(bounds.height, .01));
    expect(bounds.bottom, lessThan(640));
    await dragStroke(tester, 'D4 E4', size: marketSize);
    expect(
      find.bySemanticsLabel(
        targetSemantics(portuguese, 'C4', portuguese.westPan, 0, 24),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        targetSemantics(portuguese, 'F4', portuguese.eastPan, 2, 24),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'Market Day shows its story and scoring suits on the path and board',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        TarotSquaredApp(
          catalog: catalog,
          artwork: artwork,
          initialLanguage: 'es',
          unlockedPuzzle: '006',
        ),
      );
      final play = find.text(spanish.play);
      await tester.tap(play);
      await tester.pumpAndSettle();
      final pathBadges = [
        for (final suit in [Suit.wand, Suit.cup, Suit.coin])
          find.byKey(Key('phase-suit-006-${suit.name}')),
      ];
      final marketPhase = find.byKey(const Key('phase-006'));
      await tester.ensureVisible(marketPhase);
      final phase = tester.getRect(marketPhase);
      final preceding = tester.getRect(find.byKey(const Key('phase-005')));
      expect(phase.overlaps(preceding), isFalse);
      final singleBadge = tester.getRect(
        find.byKey(const Key('phase-suit-005-coin')),
      );
      final singleMedallion = tester.getCenter(
        find.byKey(const Key('phase-medallion-005')),
      );
      final badgeRadius = (singleBadge.center - singleMedallion).distance;
      final medallion = tester.getRect(
        find.byKey(const Key('phase-medallion-006')),
      );
      for (final badge in pathBadges) {
        final badgeRect = tester.getRect(badge);
        expect(badgeRect.size, singleBadge.size);
        expect(phase.contains(badgeRect.center), isTrue);
        expect(
          (badgeRect.center - medallion.center).distance,
          lessThanOrEqualTo((medallion.width + badgeRect.width) / 2),
        );
      }
      expectEvenOrbit(
        pathBadges
            .map((badge) => tester.getCenter(badge) - medallion.center)
            .toList(),
        badgeRadius,
      );
      await tester.tapAt(tester.getCenter(pathBadges.last));
      await tester.pumpAndSettle();
      expect(find.text(spanish.marketDayStory), findsOneWidget);
      expect(find.text(spanish.marketDayObjective), findsOneWidget);
      final counts = <Offset>[];
      for (final (suit, name, target) in [
        (Suit.wand, spanish.wands, spanish.marketLamp),
        (Suit.cup, spanish.cups, spanish.marketInlet),
        (Suit.coin, spanish.coins, spanish.paymentPan),
      ]) {
        final tile = previewTarget(spanish, target, name, 6);
        final count = find.descendant(of: tile, matching: find.text('6'));
        final symbol = find.descendant(
          of: tile,
          matching: find.byWidgetPredicate(
            (widget) => widget is CustomPaint && widget.painter is SuitPainter,
          ),
        );
        expect(tile, findsOneWidget);
        expect(count, findsOneWidget);
        expect(
          tester.widget<CustomPaint>(symbol).painter,
          isA<SuitPainter>().having((painter) => painter.suits, 'suits', {
            suit,
          }),
        );
        counts.add(tester.getCenter(count));
      }
      expect(counts.map((count) => count.dy).toSet(), hasLength(1));
      expect(counts[0].dx, lessThan(counts[1].dx));
      expect(counts[1].dx, lessThan(counts[2].dx));
      expect(find.textContaining(spanish.waterGoal(6)), findsNothing);
      await tester.ensureVisible(play);
      await tester.tap(play);
      await tester.pumpAndSettle();
      expect(find.text(spanish.marketDayObjective), findsOneWidget);
      final panel = find.byKey(const Key('fool-suit-panel'));
      final symbols = <Rect>[];
      for (final (suit, name) in [
        (Suit.wand, spanish.wands),
        (Suit.cup, spanish.cups),
        (Suit.coin, spanish.coins),
      ]) {
        final badge = find.byKey(Key('puzzle-suit-${suit.name}'));
        expect(find.descendant(of: panel, matching: badge), findsOneWidget);
        expect(find.bySemanticsLabel(name), findsOneWidget);
        symbols.add(tester.getRect(badge));
      }
      final box = tester.getRect(panel);
      final ring = tester.getRect(find.byKey(const Key('puzzle-suit-ring')));
      expect(ring.center, box.center);
      expect(ring.width, closeTo(box.width * .56, .01));
      expect(symbols.first.center.dx, closeTo(box.center.dx, .01));
      expect(symbols.first.center.dy, closeTo(ring.top, .01));
      expectEvenOrbit(
        symbols.map((symbol) => symbol.center - box.center).toList(),
        box.width * .28,
      );
      final grid = tester.getRect(find.byKey(const Key('fool-grid')));
      expect(tester.getRect(panel).bottom, lessThan(grid.top));
      expect(grid.bottom, lessThan(640));
      await dragStroke(tester, 'E3 D3', size: marketDaySize);
      await dragStroke(tester, 'D3 E3', size: marketDaySize);
      expect(
        find.bySemanticsLabel(
          targetSemantics(
            spanish,
            'C3',
            spanish.marketLamp,
            2,
            6,
            suit: spanish.wands,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          targetSemantics(
            spanish,
            'F3',
            spanish.marketInlet,
            2,
            6,
            suit: spanish.cups,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          targetSemantics(
            spanish,
            'C6',
            spanish.paymentPan,
            0,
            6,
            suit: spanish.coins,
          ),
        ),
        findsOneWidget,
      );
      final stall = find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is BreadStallPainter,
      );
      BreadStallPainter painter() =>
          tester.widget<CustomPaint>(stall).painter! as BreadStallPainter;
      expect(painter().light, closeTo(2 / 6, .01));
      expect(painter().water, closeTo(2 / 6, .01));
      expect(painter().motion, 0);
      for (final (trace, _, _, _) in marketDayReplay.skip(2)) {
        await dragStroke(tester, trace, size: marketDaySize);
      }
      expect(painter().motion, 1);
      expect(find.text(spanish.marketDayClear), findsOneWidget);
    },
  );

  testWidgets('two and four scoring suits form evenly spaced circles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final (count, suits) in [
      (2, [Suit.wand, Suit.cup]),
      (4, [Suit.wand, Suit.cup, Suit.coin, Suit.sword]),
    ]) {
      await tester.pumpWidget(
        TarotSquaredApp(
          key: ValueKey(count),
          catalog: marketDayVariant(catalogSource, suitCount: count),
          artwork: artwork,
          initialLanguage: 'en',
        ),
      );
      final play = find.text(english.play);
      await tester.tap(play);
      await tester.pumpAndSettle();
      final phase = tester.getRect(find.byKey(const Key('phase-006')));
      final center = tester.getCenter(
        find.byKey(const Key('phase-medallion-006')),
      );
      final badges = [
        for (final suit in suits)
          find.byKey(Key('phase-suit-006-${suit.name}')),
      ];
      final offsets = badges
          .map((badge) => tester.getCenter(badge) - center)
          .toList();
      expect(
        offsets.every((offset) => phase.contains(center + offset)),
        isTrue,
      );
      expectEvenOrbit(offsets, CampaignStyle.suitBadgeRadius);
      await tester.tapAt(tester.getCenter(badges.last));
      await tester.pumpAndSettle();
      await tester.ensureVisible(play);
      await tester.tap(play);
      await tester.pumpAndSettle();
      final panel = tester.getRect(find.byKey(const Key('fool-suit-panel')));
      final ring = tester.getRect(find.byKey(const Key('puzzle-suit-ring')));
      final symbols = [
        for (final suit in suits)
          tester.getRect(find.byKey(Key('puzzle-suit-${suit.name}'))),
      ];
      expectEvenOrbit(
        symbols.map((symbol) => symbol.center - panel.center).toList(),
        panel.width * .28,
      );
      expect(symbols.first.center.dx, closeTo(panel.center.dx, .01));
      expect(symbols.first.center.dy, closeTo(ring.top, .01));
    }
  });

  testWidgets('touch traces teach and only offer retry after failure', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TarotSquaredApp(
        catalog: catalog,
        artwork: artwork,
        initialLanguage: 'en',
      ),
    );
    await openPhase(tester, '001');
    expect(find.text(english.puzzleIndex(25)), findsOneWidget);
    expect(find.text(english.foolsStepObjective), findsOneWidget);
    final helpBubble = find.byKey(const Key('fool-help-bubble'));
    expect(helpBubble, findsOneWidget);
    expect(find.text(english.guideMatch), findsOneWidget);
    final headerRule = tester.getRect(
      find.byKey(const Key('fool-header-rule')),
    );
    expect(headerRule.left, 0);
    expect(headerRule.right, 360);
    final suit = find.bySemanticsLabel(english.wands);
    expect(suit, findsOneWidget);
    final ridge = tester.getRect(find.byKey(const Key('fool-ridge')));
    final suitPanel = tester.getRect(find.byKey(const Key('fool-suit-panel')));
    expect(find.byKey(const Key('puzzle-suit-ring')), findsNothing);
    final grid = tester.getRect(find.byKey(const Key('fool-grid')));
    expect(grid.contains(tester.getTopLeft(helpBubble)), isTrue);
    expect(grid.contains(tester.getBottomRight(helpBubble)), isTrue);
    final touch = await tester.startGesture(tester.getCenter(helpBubble));
    await tester.pump();
    expect(helpBubble, findsNothing);
    await touch.cancel();
    await tester.pumpAndSettle();
    expect(helpBubble, findsOneWidget);
    expect(suitPanel.top, moreOrLessEquals(ridge.top));
    expect(suitPanel.bottom, moreOrLessEquals(ridge.bottom));
    expect(suitPanel.width, moreOrLessEquals(suitPanel.height));
    expect(ridge.left, moreOrLessEquals(grid.left));
    expect(suitPanel.right, moreOrLessEquals(grid.right));
    expect(tester.getCenter(suit).dx, greaterThan(ridge.right));
    expect(
      tester.getCenter(suit).dy,
      inInclusiveRange(ridge.top, ridge.bottom),
    );
    expect(find.text('Moves'), findsNothing);
    final moves = find.bySemanticsLabel(english.movesRemaining(25));
    expect(tester.getBottomLeft(moves).dy, lessThan(ridge.top));
    expect(tester.getSize(moves), const Size.square(50));
    final headerTop = tester.getTopLeft(find.text(english.foolsStepTitle)).dy;
    final headerBottom = tester
        .getBottomLeft(find.text(english.foolsStepObjective))
        .dy;
    expect(
      tester.getCenter(moves).dy,
      moreOrLessEquals((headerTop + headerBottom) / 2),
    );
    expect(
      tester.getCenter(moves).dx,
      moreOrLessEquals(tester.getCenter(suit).dx),
    );
    final markerValue = find.byKey(const Key('target-value-E4'));
    final ridgePaint = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is RidgePainter,
    );
    double ridgeLight() =>
        (tester.widget<CustomPaint>(ridgePaint).painter! as RidgePainter).light;
    expect(ridgeLight(), 0);
    expect(
      tester.widget<Text>(markerValue).data,
      english.targetProgress(0, 30),
    );
    expect(find.text(english.targetProgress(0, 30)), findsOneWidget);
    expect(grid.top - ridge.bottom, greaterThanOrEqualTo(10));
    await dragStroke(tester, 'A2 B2');
    expect(find.text(english.puzzleIndex(25)), findsOneWidget);
    await dragStroke(tester, 'C1 D1 C1 C2');
    for (var step = 1; step < guidedRoutes.length; step++) {
      expect(helpBubble, findsOneWidget);
      if (step == 1) {
        expect(find.text(english.guideSquare), findsOneWidget);
      } else if (step == 2) {
        expect(find.text(english.guideRectangle), findsOneWidget);
      } else if (step == 3) {
        expect(
          find.text(
            english.guideWithGains(
              english.guideEnclose(english.wands),
              english.targetGain(english.trailMarker, english.lightGoal(4)),
            ),
          ),
          findsOneWidget,
        );
      } else if (step == 4) {
        expect(
          tester.widget<Text>(markerValue).data,
          english.targetProgress(4, 30),
        );
        expect(
          find.text(
            english.guideWithGains(
              english.guideAim(english.wands),
              english.targetGain(english.trailMarker, english.lightGoal(2)),
            ),
          ),
          findsOneWidget,
        );
      } else if (step == 5) {
        expect(
          tester.widget<Text>(markerValue).data,
          english.targetProgress(6, 30),
        );
        expect(find.text(english.guideWildcard), findsOneWidget);
      }
      await dragStroke(tester, guidedRoutes[step], settle: step != 3);
      if (step == 3) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expect(ridgeLight(), inExclusiveRange(0, 4 / 30));
        await tester.pumpAndSettle();
        expect(ridgeLight(), 4 / 30);
      }
    }
    expect(helpBubble, findsNothing);
    expect(suit, findsOneWidget);
    expect(
      tester.widget<Text>(markerValue).data,
      english.targetProgress(6, 30),
    );
    expect(find.text(english.puzzleIndex(19)), findsOneWidget);
    expect(find.text(english.retry), findsNothing);
    expect(find.text('Hint'), findsNothing);
    expect(find.text('Restart'), findsNothing);

    final replay = PuzzleDeal(foolsStep);
    for (final route in guidedRoutes) {
      replay.play(cells(route));
    }
    final size = foolsStep.size;
    while (!replay.finished) {
      final setup = [
        for (var cell = 0; cell < size.cellCount; cell++)
          for (final next in size.neighbours(cell))
            if (replay.inspect([cell, next])?.totalGain == 0) [cell, next],
      ].first;
      replay.play(setup);
      final route = setup.map(size.cellLabel).join(' ');
      await dragStroke(tester, route);
    }
    expect(replay.lost, isTrue);
    expect(find.text(english.puzzleIndex(0)), findsOneWidget);
    await tester.tap(find.text(english.retry));
    await tester.pumpAndSettle();
    expect(find.text(english.puzzleIndex(25)), findsOneWidget);
    expect(
      tester.widget<Text>(markerValue).data,
      english.targetProgress(0, 30),
    );
    expect(find.text(english.retry), findsNothing);
  });
}
