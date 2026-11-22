import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show FilledButton;
import 'package:tarot/artwork.dart';
import 'package:tarot/fool/puzzle_deal.dart';
import 'package:tarot/fool/stroke.dart';
import 'package:tarot/fool/tableau_art.dart';
import 'package:tarot/main.dart';

import 'fool_deal_test.dart'
    show catalog, cells, foolsStep, guidedRoutes, lampReplay;

Future<void> dragStroke(
  WidgetTester tester,
  String route, {
  bool settle = true,
}) async {
  final board = tester.getRect(find.byKey(const Key('fool-grid')));
  final pitch = board.width / 6;
  final points = cells(route).map(
    (index) =>
        board.topLeft +
        Offset((index % 6 + .5) * pitch, (index ~/ 6 + .5) * pitch),
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
  String playLabel = 'Play',
}) async {
  await tester.tap(find.text(playLabel));
  await tester.pumpAndSettle();
  final phase = find.byKey(Key('phase-$id'));
  await tester.ensureVisible(phase);
  await tester.tap(phase);
  await tester.pumpAndSettle();
  await tester.tap(find.text(playLabel));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Artwork artwork;
  setUpAll(() async => artwork = await Artwork.load());
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
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    final first = find.byKey(const Key('phase-001'));
    final next = find.byKey(const Key('phase-002'));
    expect(find.text('The Fool’s Step'), findsNothing);
    expect(find.text('Lamplighter'), findsNothing);
    expect(find.bySemanticsLabel('Phase 2, Lamplighter, Cups'), findsOneWidget);
    final firstMarker = find.byKey(const Key('phase-medallion-001'));
    final nextMarker = find.byKey(const Key('phase-medallion-002'));
    final delta = tester.getCenter(firstMarker) - tester.getCenter(nextMarker);
    final viewport = tester.getRect(find.byType(SingleChildScrollView));
    expect(viewport.bottom - tester.getCenter(firstMarker).dy, 106);
    expect(delta.dy, 64);
    expect(delta.dx.abs(), 18);
    expect(tester.getSize(firstMarker), const Size.square(42));
    expect(tester.getSize(first).height, greaterThanOrEqualTo(44));
    expect(tester.getRect(first).overlaps(tester.getRect(next)), isFalse);
    for (final (id, number) in [('001', '1'), ('002', '2')]) {
      final marker = find.byKey(Key('phase-medallion-$id'));
      final badge = tester.getRect(find.byKey(Key('phase-suit-$id')));
      final markerRect = tester.getRect(marker);
      expect(
        find.descendant(of: marker, matching: find.text(number)),
        findsOneWidget,
      );
      expect(markerRect.overlaps(badge), isTrue);
      expect(badge.center.dx, greaterThan(markerRect.right));
    }
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.text('Lamplighter'), findsOneWidget);
    expect(find.byKey(const Key('phase-illustration')), findsOneWidget);
    expect(find.text('Fuel the quay lamp'), findsOneWidget);
    expect(find.text('Cups · 44 light'), findsOneWidget);
    expect(find.text('25 moves'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    final locked = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Locked'),
    );
    expect(locked.onPressed, isNull);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await tester.tap(first);
    await tester.pumpAndSettle();
    expect(find.text('The Fool’s Step'), findsOneWidget);
    expect(find.text('Wands · 30 light'), findsOneWidget);
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fool-grid')), findsOneWidget);
    await tester.tap(find.byTooltip('Path'));
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
    expect(find.text('Fuel the quay lamp'), findsOneWidget);
    expect(find.bySemanticsLabel('Cups'), findsOneWidget);
    expect(find.bySemanticsLabel('Wands'), findsNothing);
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
      'The lamp loses 1 light on moves that don’t feed it.',
    );

    expect(sceneLight(), 0);
    await dragStroke(tester, lampReplay[0].$1, settle: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(sceneLight(), inExclusiveRange(0, 4 / 44));
    await tester.pumpAndSettle();
    expect(sceneLight(), 4 / 44);
    expect(painter().light, 4 / 44);
    expect(painter().fadeProgress, 1);
    await dragStroke(tester, lampReplay[1].$1, settle: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    expect(painter().fadeProgress, inExclusiveRange(0, 1));
    expect(painter().light, inExclusiveRange(3 / 44, 4 / 44));
    expect(sceneLight(), painter().light);
    await tester.pumpAndSettle();
    expect(painter().fadeProgress, 1);
    expect(painter().light, 3 / 44);
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
    expect(find.bySemanticsLabel('Tarot Squared'), findsWidgets);
    expect(find.text('THE MOON'), findsOneWidget);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    await tester.tap(find.text('Português'));
    await tester.pumpAndSettle();
    expect(find.text('Jogar'), findsOneWidget);
    expect(find.text('A LUA'), findsOneWidget);
    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.text('Jugar'), findsOneWidget);
    expect(saved, ['pt', 'es']);
    await openPhase(tester, '001', playLabel: 'Jugar');
    expect(find.text('El paso del Loco'), findsWidgets);
    expect(find.text('Enciende la marca del sendero'), findsOneWidget);
    expect(
      find.text('Une piezas del mismo palo para eliminarlas.'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Bastos'), findsOneWidget);
    expect(find.text('Pista'), findsNothing);
    expect(find.text('Reiniciar'), findsNothing);
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
    expect(find.text('25'), findsOneWidget);
    expect(find.text('Light the trail marker'), findsOneWidget);
    final helpBubble = find.byKey(const Key('fool-help-bubble'));
    expect(helpBubble, findsOneWidget);
    expect(
      find.text('Trace matching pieces of any suit to clear them.'),
      findsOneWidget,
    );
    final headerRule = tester.getRect(
      find.byKey(const Key('fool-header-rule')),
    );
    expect(headerRule.left, 0);
    expect(headerRule.right, 360);
    final suit = find.bySemanticsLabel('Wands');
    expect(suit, findsOneWidget);
    final ridge = tester.getRect(find.byKey(const Key('fool-ridge')));
    final suitPanel = tester.getRect(find.byKey(const Key('fool-suit-panel')));
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
    final moves = find.bySemanticsLabel('25 moves left');
    expect(tester.getBottomLeft(moves).dy, lessThan(ridge.top));
    expect(tester.getSize(moves), const Size.square(50));
    final headerTop = tester.getTopLeft(find.text('The Fool’s Step')).dy;
    final headerBottom = tester
        .getBottomLeft(find.text('Light the trail marker'))
        .dy;
    expect(
      tester.getCenter(moves).dy,
      moreOrLessEquals((headerTop + headerBottom) / 2),
    );
    expect(
      tester.getCenter(moves).dx,
      moreOrLessEquals(tester.getCenter(suit).dx),
    );
    final markerValue = find.byKey(const Key('trail-marker-value'));
    final ridgePaint = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is RidgePainter,
    );
    double ridgeLight() =>
        (tester.widget<CustomPaint>(ridgePaint).painter! as RidgePainter).light;
    expect(ridgeLight(), 0);
    expect(tester.widget<Text>(markerValue).data, '0/30');
    expect(find.text('0/30'), findsOneWidget);
    expect(grid.top - ridge.bottom, greaterThanOrEqualTo(10));
    await dragStroke(tester, 'A2 B2');
    expect(find.text('25'), findsOneWidget);
    await dragStroke(
      tester,
      'C1 D1 C1 C2',
    ); // Return to the origin and switch direction.
    for (var step = 1; step < guidedRoutes.length; step++) {
      expect(helpBubble, findsOneWidget);
      if (step == 1) {
        expect(
          find.text('Four matching corners clear every suit in the square.'),
          findsOneWidget,
        );
      } else if (step == 2) {
        expect(
          find.text(
            'A rectangle clears every suit inside and along its sides.',
          ),
          findsOneWidget,
        );
      } else if (step == 3) {
        expect(
          find.text(
            'Clear every suit. Enclosing this marker with Wands adds +4 light.',
          ),
          findsOneWidget,
        );
      } else if (step == 4) {
        expect(tester.widget<Text>(markerValue).data, '4/30');
        expect(
          find.text(
            'The last step sets the direction. Wands send +2 light into the marker.',
          ),
          findsOneWidget,
        );
      } else if (step == 5) {
        expect(tester.widget<Text>(markerValue).data, '6/30');
        expect(
          find.text(
            'The marker matches any suit at a corner. Here it completes a Coin square.',
          ),
          findsOneWidget,
        );
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
    expect(tester.widget<Text>(markerValue).data, '6/30');
    expect(find.text('19'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
    expect(find.text('Hint'), findsNothing);
    expect(find.text('Restart'), findsNothing);

    final replay = PuzzleDeal(foolsStep);
    for (final route in guidedRoutes) {
      replay.play(cells(route));
    }
    while (!replay.finished) {
      final setup = [
        for (var cell = 0; cell < cellCount; cell++)
          for (final next in neighbours(cell))
            if (replay.inspect([cell, next])?.light == 0) [cell, next],
      ].first;
      replay.play(setup);
      final route = setup
          .map(
            (cell) =>
                '${String.fromCharCode(65 + columnOf(cell))}${rowOf(cell) + 1}',
          )
          .join(' ');
      await dragStroke(tester, route);
    }
    expect(replay.lost, isTrue);
    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('25'), findsOneWidget);
    expect(tester.widget<Text>(markerValue).data, '0/30');
    expect(find.text('Try again'), findsNothing);
  });
}
