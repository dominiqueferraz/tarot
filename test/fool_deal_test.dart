import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_squared/fool/puzzle_deal.dart';
import 'package:tarot_squared/fool/stroke.dart';

final catalog = PuzzleCatalog.parse(
  File(PuzzleCatalog.assetPath).readAsStringSync(),
);
final foolsStep = catalog.puzzles.first;
final lamplighter = catalog.puzzles[1];
final highWater = catalog.puzzles[2];
final mooring = catalog.puzzles[3];
const openingSize = BoardSize(6, 6);
const lampSize = BoardSize(5, 6);
const highWaterSize = BoardSize(6, 7);
const dockSize = BoardSize(7, 6);

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
  ('C1 B1 B2 A2 A3 B3', 9),
  ('E2 E3 D3', 12),
  ('A1 C1 C4 A4 A1', 11),
  ('A1 C1 C3 A3 A1', 17),
  ('A3 C3 C5 A5 A3', 21),
  ('E1 E2 D2 D1 C1 C2', 27),
  ('B1 C1 C3 B3 B1', 32),
  ('B1 C1 C3 B3 B1', 36),
  ('B3 D3 D5 B5 B3', 35),
  ('D4 D3 D2 D1 C1 C2', 41),
  ('D1 C1 C2', 44),
];

const millReplay = [
  ('C6 C7', 0),
  ('A4 C4 C7 A7 A4', 4),
  ('B1 F1 F6 B6 B1', 8),
  ('B2 E2 E5 B5 B2', 17),
  ('B3 F3 F5 B5 B3', 27),
  ('B4 F4 F6 B6 B4', 31),
  ('E2 E3 D3 D4 D5 C5', 32),
];

const dockReplay = [
  ('C3 E3 E5 C5 C3', 5, 5),
  ('C1 C2', 7, 7),
  ('G5 F5', 9, 9),
  ('B2 E2 E5 B5 B2', 13, 19),
  ('C3 F3 F6 C6 C3', 23, 23),
  ('C2 E2 E6 C6 C2', 24, 24),
];

List<int> cells(String route, {BoardSize size = openingSize}) =>
    route.split(' ').map(size.parseCell).toList();

PuzzleCatalog rectangularCatalog(List<String> board, String targetCell) {
  final data = jsonDecode(
    File(PuzzleCatalog.assetPath).readAsStringSync(),
  ) as Map<String, Object?>;
  final lamp = (data['puzzles'] as List<Object?>)[1] as Map<String, Object?>;
  data['puzzles'] = [
    {
      ...lamp,
      'board': board,
      'moves': 25,
      'target': {
        'cell': targetCell,
        'suit': 'C',
        'light': 44,
        'fade': 1,
        'label': 'quayLamp',
      },
    },
  ];
  return PuzzleCatalog.parse(jsonEncode(data));
}

const tallBoard = [
  'WSOCSO',
  'CCWCCW',
  'CCSSCO',
  'OCOCSC',
  'CWCCWC',
  'SCCOWC',
  'CCCCCL',
];
final tallCatalog = rectangularCatalog(tallBoard, 'F7');

final wideCatalog = rectangularCatalog([
  'WSOCCCCL',
  'CCWCCWCC',
  'CCSSCOCW',
  'OCOCSCCC',
], 'H1');

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
  test('rectangular deals use both edges for aim, rectangles and refill', () {
    final puzzle = tallCatalog.puzzles.single;
    final deal = PuzzleDeal(puzzle);
    final size = puzzle.size;
    expect((size.columns, size.rows), (6, 7));
    List<int> route(String value) => cells(value, size: size);

    expect(deal.inspect(route('D7 E7'))?.light, 2);
    expect(deal.inspect(route('F6 A7')), isNull);
    expect(() => size.parseCell('G7'), throwsFormatException);
    expect(() => size.parseCell('F8'), throwsFormatException);
    final turn = deal.play(route('C5 F5 F7 C7 C5'))!;
    expect(turn.stroke.isRectangle, isTrue);
    expect(turn.stroke.cleared, hasLength(11));
    expect(deal.light, 8);
    expect(deal.board.where((suit) => suit == null), hasLength(1));
    expect(deal.board[puzzle.marker], isNull);
    expect(
      turn.falls.where((fall) => fall.fromRow < 0).map((fall) => fall.column),
      unorderedEquals([2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5]),
    );

    final wide = PuzzleDeal(wideCatalog.puzzles.single);
    expect((wide.puzzle.size.columns, wide.puzzle.size.rows), (8, 4));
    expect(
      wide.inspect(cells('G4 H4', size: wide.puzzle.size))?.cleared,
      hasLength(2),
    );
  });

  test('board coordinates can use multiple letters and digits', () {
    final wide = 'C' * 27;
    final catalog = rectangularCatalog([
      ...List.filled(9, wide),
      '${'C' * 26}L',
    ], 'AA10');
    final puzzle = catalog.puzzles.single;
    expect(puzzle.marker, 269);
    expect(puzzle.size.cellLabel(puzzle.marker), 'AA10');
    expect(
      PuzzleDeal(puzzle).inspect(cells('Y10 Z10', size: puzzle.size))?.light,
      2,
    );

    expect(() => rectangularCatalog([], 'A1'), throwsFormatException);
    expect(() => rectangularCatalog(['LC', 'C'], 'A1'), throwsFormatException);
    expect(() => rectangularCatalog(['LC'], 'C1'), throwsFormatException);
  });

  test('validates and replays every authored guide', () {
    expect(catalog.next(foolsStep), lamplighter);
    expect(catalog.next(lamplighter), highWater);
    expect(catalog.next(highWater), mooring);
    expect(catalog.next(mooring), isNull);
    expect(catalog.unlockedIndex('002'), 1);
    expect(catalog.unlockedIndex('003'), 2);
    expect(catalog.unlockedIndex('004'), 3);
    expect(catalog.puzzles.map((puzzle) => puzzle.limit), [25, 22, 18, 26]);
    expect(
      catalog.puzzles.map((puzzle) => (puzzle.size.columns, puzzle.size.rows)),
      [(6, 6), (5, 6), (6, 7), (7, 6)],
    );
    expect(catalog.unlockedIndex('missing'), 0);
    for (final puzzle in catalog.puzzles) {
      final deal = PuzzleDeal(puzzle);
      for (final step in puzzle.guide) {
        final turn = deal.play(step.path);
        expect(turn, isNotNull, reason: 'Puzzle ${puzzle.id}: ${step.path}');
        for (var column = 0; column < puzzle.size.columns; column++) {
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

  test('High Water builds the inlet rectangle from visible Cups', () {
    final deal = PuzzleDeal(highWater);
    final size = highWater.size;
    List<int> route(String value) => cells(value, size: size);

    expect((size.columns, size.rows), (6, 7));
    expect(size.cellLabel(highWater.marker), 'B5');
    expect(highWater.limit, 18);
    expect(deal.guide, isNull);
    expect(deal.inspect(route('A6 A7 B7 B6'))?.light, 4);
    expect(deal.inspect(route('D4 D5 C5'))?.light, 3);
    expect(deal.inspect(route(millReplay[1].$1)), isNull);

    final setup = deal.play(route(millReplay[0].$1))!;
    expect(deal.light, 0);
    expect(
      setup.falls
          .where(
            (fall) =>
                fall.column == 2 && fall.fromRow >= 0 && fall.suit == Suit.cup,
          )
          .map((fall) => (fall.fromRow, fall.toRow)),
      unorderedEquals([(1, 3), (4, 6)]),
    );
    final expectedClear = deal.inspect(route(millReplay[1].$1))!;
    expect(expectedClear.cleared, hasLength(11));
    expect(expectedClear.light, 4);
    for (final (trace, water) in millReplay.skip(1)) {
      expect(deal.play(route(trace)), isNotNull, reason: trace);
      expect(deal.light, water, reason: trace);
      expect(deal.board[highWater.marker], isNull);
    }
    expect(deal.won, isTrue);
    expect(deal.stars, 3);

    final missed = PuzzleDeal(highWater);
    expect(missed.play(route('B6 B7'))?.stroke.light, 0);
    while (!missed.finished) {
      final misses = [
        for (var cell = 0; cell < size.cellCount; cell++)
          for (final next in size.neighbours(cell))
            if (missed.inspect([cell, next])?.light == 0) [cell, next],
      ];
      final move = misses.firstWhere(
        (path) => missed.board[path.first] == Suit.cup,
        orElse: () => misses.first,
      );
      missed.play(move);
    }
    expect(missed.lost, isTrue);
    expect(missed.movesLeft, 0);
  });

  test('The Mooring links scoring corners and spends two paid turns', () {
    final deal = PuzzleDeal(mooring);
    final bow = dockSize.parseCell('C3');
    final stern = dockSize.parseCell('E5');
    final masked = cells('A1 G1', size: dockSize);
    List<int> route(String trace) => cells(trace, size: dockSize);

    expect(mooring.targets.keys, [bow, stern]);
    expect(mooring.masked, unorderedEquals(masked));
    expect(deal.inspect(route('E3 D3'))?.gains, {bow: 2});
    expect(deal.inspect(route('G5 F5'))?.gains, {stern: 2});
    expect(deal.inspect(route('B2 E2 E5 B5 B2'))!.linkedTargets, isEmpty);
    expect(deal.inspect(route(dockReplay.first.$1))!.linkedTargets, {
      bow,
      stern,
    });

    for (final (trace, bowCut, sternCut) in dockReplay) {
      expect(deal.won, isFalse);
      final turn = deal.play(route(trace))!;
      expect(deal.progressAt(bow), bowCut, reason: trace);
      expect(deal.progressAt(stern), sternCut, reason: trace);
      if (deal.moves == 1) {
        expect(deal.link?.cells, {bow, stern});
        expect(deal.link?.movesLeft, 2);
        expect(deal.play(route('C2 C1')), isNull);
        expect(deal.link?.movesLeft, 2);
        final maskedCorner = route('A1 C1 C4 A4 A1');
        expect(
          maskedCorner.skip(1).take(3).map((cell) => deal.board[cell]),
          everyElement(Suit.sword),
        );
        expect(deal.inspect(maskedCorner), isNull);
      }
      if (deal.moves == 2) {
        expect(deal.link?.movesLeft, 1);
        expect(turn.stroke.gains, {bow: 2, stern: 2});
        expect(deal.guide, isNull);
      }
      if (deal.moves == 3) {
        expect(deal.link, isNull);
        expect(turn.stroke.gains, {bow: 2, stern: 2});
        expect(deal.inspect(route('G5 F5'))?.gains, {stern: 2});
      }
      for (final cell in [...masked, bow, stern]) {
        expect(deal.board[cell], isNull);
        expect(
          turn.falls.any(
            (fall) => dockSize.cellAt(fall.column, fall.toRow) == cell,
          ),
          isFalse,
        );
      }
    }
    expect(deal.won, isTrue);
  });

  test('an ordinary miss spends the last turn of a link', () {
    final deal = PuzzleDeal(mooring);
    List<int> route(String trace) => cells(trace, size: dockSize);
    for (final (trace, _, _) in dockReplay.take(2)) {
      expect(deal.play(route(trace)), isNotNull);
    }
    expect(deal.link?.movesLeft, 1);
    final turn = deal.play(route('A4 B4'))!;
    expect(turn.stroke.gains, isEmpty);
    expect(deal.link, isNull);
    expect(deal.progressAt(dockSize.parseCell('E5')), 7);
  });

  test('Lamplighter uses shared scoring and fades only on paid misses', () {
    final route = PuzzleDeal(lamplighter);
    final repeat = PuzzleDeal(lamplighter);
    final unlit = PuzzleDeal(lamplighter);
    expect(foolsStep.scoringSuit, Suit.wand);
    expect(lamplighter.scoringSuit, Suit.cup);
    expect(route.board[cells('A3', size: lampSize).single], Suit.cup);
    expect(route.inspect(cells('A3 B3', size: lampSize))?.light, 2);
    expect(route.inspect(cells('B3 A3', size: lampSize))?.light, 0);
    final enclosure = route.inspect(
      cells(lampReplay.first.$1, size: lampSize),
    )!;
    expect(enclosure.light, 4);
    expect(
      enclosure.cleared.map((cell) => route.board[cell]).toSet(),
      unorderedEquals(Suit.values),
    );
    expect(unlit.play(cells('D1 D2', size: lampSize)), isNotNull);
    expect(unlit.light, 0);
    expect(unlit.faded, 0);
    expect(route.guide, isNull);
    for (final (trace, light) in lampReplay) {
      final before = route.light;
      final turn = route.play(cells(trace, size: lampSize));
      expect(turn, isNotNull, reason: trace);
      expect(route.light, light, reason: trace);
      expect(route.faded, before > light ? 1 : 0, reason: trace);
      if (!turn!.stroke.isRectangle && turn.stroke.light > 0) {
        expect(turn.stroke.light, turn.stroke.path.length);
      }
      expect(route.board[lamplighter.marker], isNull);
      expect(repeat.play(cells(trace, size: lampSize)), isNotNull);
      expect(repeat.board, route.board);
      expect(repeat.light, route.light);
    }
    expect(route.won, isTrue);
    expect(route.stars, 3);
    expect(route.moves, lampReplay.length);
  });

  test('keeps E4 fixed from the start and matches the authored handoff', () {
    final deal = PuzzleDeal(foolsStep);
    expect(deal.board[foolsStep.marker], isNull);
    expect(deal.light, 0);
    expect(deal.play(cells('D1 C1')), isNull);
    expect(deal.movesLeft, 25);
    expect(deal.play(cells('C2 C1')), isNotNull);
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
    expect(deal.play(cells('E3 E2')), isNull);
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
