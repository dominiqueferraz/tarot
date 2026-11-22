import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tarot/fool/puzzle_deal.dart';
import 'package:tarot/fool/stroke.dart';

final catalog = PuzzleCatalog.parse(
  File(PuzzleCatalog.assetPath).readAsStringSync(),
);
final foolsStep = catalog.puzzles.first;
final lamplighter = catalog.puzzles[1];

const guidedRoutes = [
  'C1 C2',
  'D1 F1 F3 D3 D1',
  'A2 D2 D4 A4 A2',
  'D2 F2 F5 D5 D2',
  'E2 E3',
  'E3 F3 F4 E4 E3',
];

const parReplay = [
  ('A5 A6', 6),
  ('B4 C4', 6),
  ('A3 A2 B2 C2 C3 D3 D2 D1 E1 E2 E3', 17),
  ('D2 E2 E5 D5 D2', 21),
  ('C1 E1 E4 C4 C1', 25),
  ('A1 B1', 25),
  ('B3 E3 E4 B4 B3', 25),
  ('B1 E1 E4 B4 B1', 30),
];

const lampReplay = [
  ('B2 D2 D4 B4 B2', 4),
  ('B1 C1', 3),
  ('D1 C1 B1 B2 A2 A3 B3', 10),
  ('E3 D3', 12),
  ('D1 E1', 11),
  ('D2 D3', 10),
  ('A2 C2 C4 A4 A2', 9),
  ('A3 C3 C5 A5 A3', 12),
  ('B1 C1 C6 B6 B1', 16),
  ('C6 C5 B5 B4 C4 D4 D3 D2 D1 C1 C2', 27),
  ('C6 C5 C4', 30),
  ('C1 E1 E3 C3 C1', 34),
  ('D2 E2 E1 D1 C1 C2', 40),
  ('C5 C4', 42),
  ('C5 C4', 44),
];

List<int> cells(String route) => [
  for (final token in route.split(' '))
    cellAt(token.codeUnitAt(0) - 65, int.parse(token[1]) - 1)!,
];

String layout(PuzzleDeal deal) => [
  for (final suit in deal.board)
    switch (suit) {
      Suit.wand => 'W',
      Suit.cup => 'C',
      Suit.sword => 'S',
      Suit.coin => 'O',
      null => 'L',
    },
].join();

void main() {
  test('validates and replays every authored guide', () {
    expect(catalog.next(foolsStep), lamplighter);
    expect(catalog.next(lamplighter), isNull);
    expect(catalog.unlockedIndex('002'), 1);
    expect(catalog.unlockedIndex('missing'), 0);
    for (final puzzle in catalog.puzzles) {
      final deal = PuzzleDeal(puzzle);
      for (final step in puzzle.guide) {
        final turn = deal.play(step.path);
        expect(turn, isNotNull, reason: 'Puzzle ${puzzle.id}: ${step.path}');
        for (var column = 0; column < boardSide; column++) {
          final arrivals = turn!.falls.where(
            (tile) => tile.column == column && tile.fromRow < 0,
          );
          expect(
            arrivals.map((tile) => tile.suit),
            orderedEquals(step.arrivals[column]),
          );
        }
      }
    }
  });

  test('Lamplighter uses shared scoring and fades only on paid misses', () {
    final route = PuzzleDeal(lamplighter);
    final repeat = PuzzleDeal(lamplighter);
    final unlit = PuzzleDeal(lamplighter);
    expect(foolsStep.scoringSuit, Suit.wand);
    expect(lamplighter.scoringSuit, Suit.cup);
    expect(route.board[cells('A3').single], Suit.cup);
    expect(route.inspect(cells('A3 B3'))?.light, 2);
    expect(route.inspect(cells('B3 A3'))?.light, 0);
    final enclosure = route.inspect(cells(lampReplay.first.$1))!;
    expect(enclosure.light, 4);
    expect(
      enclosure.cleared.map((cell) => route.board[cell]).toSet(),
      unorderedEquals(Suit.values),
    );
    expect(unlit.play(cells('D1 D2')), isNotNull);
    expect(unlit.light, 0);
    expect(unlit.faded, 0);
    expect(route.guide, isNull);
    for (final (trace, light) in lampReplay) {
      final before = route.light;
      final turn = route.play(cells(trace));
      expect(turn, isNotNull, reason: trace);
      expect(route.light, light, reason: trace);
      expect(route.faded, before > light ? 1 : 0, reason: trace);
      if (!turn!.stroke.isRectangle && turn.stroke.light > 0) {
        expect(turn.stroke.light, turn.stroke.path.length);
      }
      expect(route.board[lamplighter.marker], isNull);
      expect(repeat.play(cells(trace)), isNotNull);
      expect(repeat.board, route.board);
      expect(repeat.light, route.light);
    }
    expect(route.won, isTrue);
    expect(route.stars, 3);
    expect(route.moves, 15);
  });

  test('keeps E4 fixed from the start and matches the authored handoff', () {
    final deal = PuzzleDeal(foolsStep);
    expect(deal.board[foolsStep.marker], isNull);
    expect(deal.light, 0);
    expect(deal.play(cells('D1 C1')), isNull);
    expect(deal.movesLeft, 25);
    expect(deal.play(cells('C2 C1')), isNotNull); // Reverse the pair.
    final square = deal.play(cells(guidedRoutes[1]))!.stroke;
    expect(square.isRectangle, isTrue);
    expect(square.light, 0);
    expect(square.cleared, hasLength(9));
    expect(deal.board[foolsStep.marker], isNull);
    final cup = cells('C3').single;
    expect(deal.board[cup], Suit.cup);
    final cupTurn = deal.play(cells('B2 A2 A3 A4 D4 D2 C2 B2'))!;
    final clear = cupTurn.stroke;
    expect(clear.isRectangle, isTrue);
    expect(clear.path, isNot(contains(cup)));
    expect(
      clear.cleared,
      unorderedEquals(cells('A2 B2 C2 D2 A3 B3 C3 D3 A4 B4 C4 D4')),
    );
    expect(
      clear.cleared.map((cell) => cupTurn.before[cell]).toSet(),
      unorderedEquals(Suit.values),
    );
    expect(deal.board[foolsStep.marker], isNull);
    expect(
      layout(deal),
      'WWWWWO CCWWWW SCWSWO SSSSLO WSSWWW WWSSCC'.replaceAll(' ', ''),
    );
    final enclosure = deal.play(cells(guidedRoutes[3]))!;
    expect(
      enclosure.stroke.cleared,
      unorderedEquals(cells('D2 E2 F2 D3 E3 F3 D4 F4 D5 E5 F5')),
    );
    expect(enclosure.before[cells('F3').single], Suit.coin);
    expect(enclosure.before[cells('D4').single], Suit.sword);
    expect(enclosure.falls.where((tile) => tile.fromRow < 0), hasLength(11));
    expect(enclosure.stroke.light, 4);
    expect(deal.light, 4);
    expect(deal.play(cells('E3 E2')), isNull); // This stroke must face E4.
    expect(deal.play(cells(guidedRoutes[4]))?.stroke.light, 2);
    expect(deal.light, 6);
    expect(deal.guide?.cue, GuideCue.wildcard);
    final wildcard = deal.play(cells(guidedRoutes[5]))!.stroke;
    expect(wildcard.isRectangle, isTrue);
    expect(wildcard.path, contains(foolsStep.marker));
    expect(wildcard.cleared, unorderedEquals(cells('E3 F3 F4')));
    expect(wildcard.light, 0);
    expect(deal.guide, isNull);
    expect(deal.movesLeft, 19);
    expect(deal.light, 6);
    expect(
      layout(deal),
      'WWWWW OCCWWWO SCWWWO SSSWLO WSSWWO WWSSCC'.replaceAll(' ', ''),
    );
  });

  test(
    'both recorded free-play solutions retain their progress and ratings',
    () {
      final par = PuzzleDeal(foolsStep);
      final other = PuzzleDeal(foolsStep);
      for (final route in guidedRoutes) {
        expect(par.play(cells(route)), isNotNull);
        expect(other.play(cells(route)), isNotNull);
      }
      const otherReplay = [
        ('E5 D5 D4 D3 D2 D1 E1 E2 E3', 15),
        ('B4 C4 C5 B5 B4', 15),
        ('B4 B5', 15),
        ('A5 A6 B6 B5 B4 C4 D4', 22),
        ('A5 B5', 22),
        ('A3 E3 E4 A4 A3', 27),
        ('C6 D6', 27),
        ('D2 E2', 27),
        ('D1 E1 E4 D4 D1', 30),
      ];
      for (final (deal, replay) in [(par, parReplay), (other, otherReplay)]) {
        for (final (route, light) in replay) {
          expect(deal.play(cells(route)), isNotNull, reason: route);
          expect(deal.light, light, reason: route);
          expect(deal.board[foolsStep.marker], isNull);
        }
        expect(deal.won, isTrue);
        expect(deal.demonstration, isNull);
      }
      expect(par.moves, 14);
      expect(other.moves, 15);
      expect(par.stars, 3);
      expect(other.stars, 2);
    },
  );

  test('rectangle scoring keeps the target fixed and respects its suit', () {
    final deal = PuzzleDeal(foolsStep);
    for (final route in guidedRoutes) {
      deal.play(cells(route));
    }
    final wandSquare = deal.inspect(cells('C1 D1 E1 E2 E3 D3 C3 C2 C1'))!;
    expect(wandSquare.isRectangle, isTrue);
    expect(wandSquare.cleared, hasLength(9));
    expect(wandSquare.light, 0);
    final edge = deal.inspect(cells('D1 E1 E5 D5 D1'))!;
    expect(edge.light, 4);
    final corner = deal.inspect(cells('D1 E1 E4 D4 D1'))!;
    expect(corner.light, 7);
    expect(corner.cleared, isNot(contains(foolsStep.marker)));
    expect(deal.play(cells('D1 E1')), isNotNull);
    final coin = deal.inspect(cells('E1 F1 F4 E4 E1'))!;
    expect(coin.light, 0);
    expect(coin.cleared, containsAll(cells('F3 F4')));
    expect(coin.cleared, isNot(contains(foolsStep.marker)));
    expect(deal.inspect(cells('C1 E3 C5 A3 C1')), isNull);
    expect(deal.inspect(cells('E4 F3 F5 E4')), isNull);
    expect(deal.inspect(cells('E1 F1 E2 F2 E1')), isNull);
  });
}
