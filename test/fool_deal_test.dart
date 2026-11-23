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
final ferrymansFare = catalog.puzzles[4];
final marketDay = catalog.puzzles[5];
final fairSplit = catalog.puzzles[6];
final fromBehind = catalog.puzzles[7];
final keepMeAPartner = catalog.puzzles[8];
final nightFishing = catalog.puzzles[9];
const openingSize = BoardSize(6, 6);
const lampSize = BoardSize(5, 6);
const highWaterSize = BoardSize(6, 7);
const dockSize = BoardSize(7, 6);
const marketSize = BoardSize(8, 8);

const nightFishingReplay = [
  ('E5 D5', 2, 0),
  ('D5 E5', 2, 2),
  ('H5 G5', 2, 4),
  ('B8 C8 C7 C6', 6, 4),
  ('G7 F7', 6, 4),
  ('G6 G5', 6, 4),
  ('C6 B6', 6, 4),
  ('F3 F2 G2 G1 F1 E1', 6, 4),
  ('F1 F2 F3 F4', 6, 6),
];

const partnerReplay = [
  ('B6 C6', 0),
  ('B7 C7', 0),
  ('A7 B7 C7', 3),
  ('F7 G7', 3),
  ('D2 F2 F7 D7 D2', 13),
  ('D1 F1 F7 D7 D1', 26),
  ('G6 G7 F7 E7', 30),
];

const fromBehindReplay = [
  ('B5 B6', 0),
  ('F3 F4 E4 E3 D3 C3 B3 B4 C4', 9),
  ('C4 C5', 9),
  ('B4 C4', 11),
  ('A4 D4 D6 A6 A4', 11),
  ('C3 B3 B4 C4', 15),
  ('B2 F2 F5 B5 B2', 15),
  ('C5 C6 B6 B5 B4 C4', 21),
  ('B5 C5', 21),
  ('D3 C3 B3 B4 C4', 26),
  ('B4 E4 E6 B6 B4', 26),
  ('C3 B3 B4 C4', 30),
  ('B6 C6', 30),
  ('B4 C4', 32),
];

const _fromBehindRectangleSetup = [
  ('D3 E3 E4', 0),
  ('A2 E2 E5 A5 A2', 0),
  ('B4 C4', 2),
  ('B4 E4 E6 B6 B4', 2),
  ('F4 F3 E3 D3 C3 B3 B4 C4', 10),
  ('B2 F2 F5 B5 B2', 10),
  ('C5 C6 B6 B5 B4 C4', 16),
  ('A5 D5 D6 A6 A5', 16),
  ('E5 D5 C5 B5 B4 C4', 22),
  ('A4 F4 F6 A6 A4', 22),
  ('C5 B5 B4 C4', 26),
  ('A3 B3', 26),
  ('C1 C2 B2 B3 B4 C4', 32),
];

const _fromBehindRecovery = [
  ('F4 E4', 0),
  ('D3 C3 C4', 0),
  ('B3 E3 E6 B6 B3', 0),
  ('C6 B6 B5 B4 C4', 5),
  ('A4 B4', 5),
  ('C3 B3 B4 C4', 9),
  ('B4 D4 D6 B6 B4', 9),
  ('D3 C3 B3 B4 C4', 14),
  ('B3 C3 C6 B6 B3', 14),
  ('C5 B5 B4 C4', 18),
  ('B4 C4', 20),
  ('A2 E2 E6 A6 A2', 20),
  ('A1 D1 D4 A4 A1', 20),
  ('C5 B5 B4 C4', 24),
  ('B3 B4 C4', 27),
  ('A3 C3 C6 A6 A3', 27),
  ('B5 B4 C4', 30),
  ('B4 C4', 32),
];

const westFareReplay = [
  ('E4 D4', 2, 0),
  ('A3 H3 H7 A7 A3', 6, 4),
  ('B6 C6 C5', 9, 4),
  ('D3 G3 G7 D7 D3', 9, 4),
  ('F6 F5', 9, 6),
  ('B3 D3 D8 B8 B3', 9, 6),
  ('D8 E8 E7 D7 D6 C6 C5', 16, 6),
  ('E1 H1 H7 E7 E1', 16, 10),
  ('C1 H1 H4 C4 C1', 24, 14),
  ('E6 D6 D5 D4 E4', 24, 19),
  ('A3 C3 C4 A4 A3', 24, 19),
  ('A1 H1 H5 A5 A1', 24, 19),
  ('B3 H3 H5 B5 B3', 24, 23),
  ('F3 G3 G4 F4 F3', 24, 24),
];

const eastFareReplay = [
  ('D4 E4', 0, 2),
  ('A3 H3 H7 A7 A3', 4, 6),
  ('C6 C5', 6, 6),
  ('D4 F4 F6 D6 D4', 6, 6),
  ('B4 F4 F6 B6 B4', 10, 10),
  ('C1 H1 H8 C8 C1', 14, 14),
  ('G3 G2 F2 F3', 14, 18),
  ('C1 F1 F4 C4 C1', 14, 18),
  ('E2 F2 F3', 14, 21),
  ('C4 H4 H6 C6 C4', 14, 21),
  ('A4 G4 G6 A6 A4', 14, 21),
  ('C5 H5 H7 C7 C5', 14, 21),
  ('C1 H1 H4 C4 C1', 21, 24),
  ('E5 E4 D4', 24, 24),
];

const _fareRecovery = [
  ('A2 A3', 0, 0),
  ('E4 D4', 2, 0),
  ('C3 H3 H8 C8 C3', 6, 4),
  ('B4 H4 H5 B5 B4', 10, 8),
  ('C3 H3 H6 C6 C3', 14, 12),
  ('A4 E4 E8 A8 A4', 14, 12),
  ('A4 B4', 16, 12),
  ('A2 F2 F8 A8 A2', 16, 12),
  ('A1 F1 F7 A7 A1', 16, 12),
  ('A3 D3 D7 A7 A3', 20, 12),
  ('B2 F2 F5 B5 B2', 20, 12),
  ('C4 E4 E5 C5 C4', 24, 12),
  ('E1 F1 F6 E6 E1', 24, 12),
  ('F6 F5', 24, 14),
  ('D1 H1 H5 D5 D1', 24, 14),
  ('C7 D7 D6 D5 D4 E4', 24, 20),
  ('A2 H2 H6 A6 A2', 24, 20),
  ('E4 H4 H8 E8 E4', 24, 24),
];

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

PuzzleCatalog rectangularCatalog(
  List<String> board,
  String targetCell, {
  List<String>? ribbons,
}) {
  final data = jsonDecode(
    File(PuzzleCatalog.assetPath).readAsStringSync(),
  ) as Map<String, Object?>;
  final lamp = (data['puzzles'] as List<Object?>)[1] as Map<String, Object?>;
  data['puzzles'] = [
    {
      ...lamp,
      'board': board,
      'moves': 25,
      if (ribbons != null) 'refill': {'type': 'ribbons', 'columns': ribbons},
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

const marketDaySize = BoardSize(7, 7);

const marketDayReplay = [
  ('E3 D3', 2, 0, 0),
  ('D3 E3', 2, 2, 0),
  ('C1 E1 E6 C6 C1', 2, 2, 6),
  ('B1 E1 E6 B6 B1', 6, 2, 6),
  ('B3 G3 G6 B6 B3', 6, 6, 6),
];

const fairSplitReplay = [
  ('B2 E2 E6 B6 B2', 4, 7),
  ('B3 F3 F6 B6 B3', 10, 11),
  ('B3 E3 E6 B6 B3', 17, 18),
  ('B3 E3 E6 B6 B3', 22, 23),
  ('D2 D3 D4 C4', 22, 23),
  ('E2 D2 D3 D4 C4 C5 B5 B4', 30, 31),
  ('C4 D4 D5 E5', 30, 31),
  ('B3 E3 E6 B6 B3', 37, 38),
  ('B1 F1 F5 B5 B1', 37, 38),
  ('D4 E4 E5', 40, 41),
  ('B3 G3 G7 B7 B3', 40, 41),
  ('B3 E3 E7 B7 B3', 43, 45),
  ('B1 E1 E6 B6 B1', 44, 50),
];

const _fairSplitLinkedReplay = [
  'B2 E2 E6 B6 B2',
  'B3 F3 F6 B6 B3',
  'B3 E3 E6 B6 B3',
  'B1 E1 E6 B6 B1',
  'D4 D3 C3',
  'A3 E3 E6 A6 A3',
  'B2 E2 E6 B6 B2',
  'F1 E1 D1 D2 C2 C3',
  'B3 E3 E6 B6 B3',
  'B3 E3 E6 B6 B3',
  'B3 C3 C7 B7 B3',
  'D7 C7 C6 C5 B5 B4',
];

const _fairSplitEastReplay = [
  'G6 F6',
  'B3 E3 E6 B6 B3',
  'A4 B4',
  'B2 E2 E6 B6 B2',
  'B3 E3 E6 B6 B3',
  'B3 E3 E6 B6 B3',
  'B6 B5 B4',
  'D5 E5 F5',
  'B3 E3 E6 B6 B3',
  'B2 E2 E6 B6 B2',
  'B3 E3 E6 B6 B3',
  'E4 E5 D5 C5 C6',
  'B1 F1 F4 B4 B1',
  'B3 F3 F6 B6 B3',
];

PuzzleCatalog marketDayVariant(
  String source, {
  bool links = false,
  int suitCount = 3,
}) {
  final data = jsonDecode(source) as Map<String, Object?>;
  final entries = (data['puzzles'] as List<Object?>)
      .cast<Map<String, Object?>>();
  final market = entries.singleWhere((puzzle) => puzzle['id'] == '006');
  final board = (market['board'] as List<Object?>).cast<String>();
  final targets = (market['targets'] as List<Object?>)
      .cast<Map<String, Object?>>();
  data['puzzles'] = [
    {
      ...market,
      'board': [
        ...board.take(4),
        suitCount == 4 ? 'WCOCSOL' : board[4],
        suitCount == 2 ? 'OWCOOWC' : board[5],
        board[6],
      ],
      'targets': [
        ...targets.take(suitCount),
        if (suitCount == 4)
          {
            'cell': 'G5',
            'suit': 'S',
            'quota': 6,
            'label': 'bowCord',
            'kind': 'cord',
          },
      ],
      'linksTargets': links,
    },
  ];
  return PuzzleCatalog.parse(jsonEncode(data));
}

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
  test('refill keeps a jammed ribbon board playable until moves run out', () {
    for (final (board, target, ribbons, route) in [
      (['WWL'], 'C1', ['C', 'S', 'O'], 'A1 B1'),
      (['W.L', '...', 'W.W'], 'C1', ['CO', 'W', 'S'], 'A1 C1 C3 A3 A1'),
    ]) {
      final puzzle = rectangularCatalog(
        board,
        target,
        ribbons: ribbons,
      ).puzzles.single;
      final deal = PuzzleDeal(puzzle);
      final stroke = cells(route, size: puzzle.size);
      for (var move = 1; move <= puzzle.limit; move++) {
        final turn = deal.play(stroke);
        expect(turn, isNotNull, reason: '$route on move $move');
        expect(deal.finished, move == puzzle.limit);
        for (final fall in turn!.falls) {
          final cell = fall.toRow * puzzle.size.columns + fall.column;
          expect(deal.board[cell], fall.suit);
        }
      }
      expect(deal.lost, isTrue);
    }
  });

  test('every campaign deal can finish without an early loss', () {
    for (final puzzle in catalog.puzzles) {
      final deal = PuzzleDeal(puzzle);
      final size = puzzle.size;
      while (!deal.finished) {
        final guide = deal.guide;
        if (guide != null) {
          expect(deal.play(guide.path), isNotNull, reason: puzzle.id);
          continue;
        }
        final strokes = [
          for (var cell = 0; cell < size.cellCount; cell++)
            for (final next in size.neighbours(cell))
              ?deal.inspect([cell, next]),
        ];
        expect(
          strokes,
          isNotEmpty,
          reason: '${puzzle.id} at move ${deal.moves}',
        );
        strokes.sort((a, b) => a.totalGain.compareTo(b.totalGain));
        expect(deal.play(strokes.first.path), isNotNull, reason: puzzle.id);
      }
      expect(deal.lost, isTrue, reason: puzzle.id);
      expect(deal.moves, puzzle.limit, reason: puzzle.id);
    }
  });

  test('The Fair Split recovers from a spill and fills both on one stroke', () {
    final deal = PuzzleDeal(fairSplit);
    final west = fairSplit.size.parseCell('B3');
    final east = fairSplit.size.parseCell('E6');
    for (final (path, westAmount, eastAmount) in fairSplitReplay) {
      expect(deal.finished, isFalse, reason: path);
      final turn = deal.play(cells(path, size: fairSplit.size));
      expect(turn, isNotNull, reason: path);
      expect(
        [deal.progressAt(west), deal.progressAt(east)],
        [westAmount, eastAmount],
        reason: path,
      );
      if (path == fairSplitReplay[fairSplitReplay.length - 2].$1) {
        expect(turn!.stroke.gains[west], 9);
        expect(deal.spilledCell, west);
        expect(deal.movesLeft, 12);
        expect(deal.board, isNot(turn.before));
        expect(deal.won, isFalse);
        expect(deal.lost, isFalse);
      }
    }
    expect(deal.spilledCell, isNull);
    expect(deal.won, isTrue);
    expect(deal.stars, 3);
  });

  test('The Fair Split supports a linked finish and an east-first route', () {
    for (final replay in [_fairSplitLinkedReplay, _fairSplitEastReplay]) {
      final deal = PuzzleDeal(fairSplit);
      for (final path in replay.take(replay.length - 1)) {
        expect(deal.play(cells(path, size: fairSplit.size)), isNotNull);
      }
      expect(deal.won, isFalse);
      final link = deal.link;
      final finish = deal.play(cells(replay.last, size: fairSplit.size))!;
      expect(finish.stroke.gains.keys, unorderedEquals(fairSplit.targets.keys));
      expect(finish.stroke.isRectangle, replay == _fairSplitEastReplay);
      if (replay == _fairSplitLinkedReplay) {
        expect(link?.movesLeft, 1);
      }
      expect(deal.won, isTrue);
    }
  });

  test('The Fair Split cannot bank the two final fills separately', () {
    final config = jsonDecode(
      File(PuzzleCatalog.assetPath).readAsStringSync(),
    ) as Map<String, Object?>;
    final entry = (config['puzzles'] as List).cast<Map>().singleWhere(
      (puzzle) => puzzle['id'] == fairSplit.id,
    );
    for (final target in entry['targets'] as List) {
      (target as Map)['quota'] = 2;
    }
    entry['moves'] = 2;
    entry['par'] = 2;
    final puzzle = PuzzleCatalog.parse(jsonEncode(config)).puzzles
        .singleWhere((definition) => definition.id == fairSplit.id);
    final deal = PuzzleDeal(puzzle);
    final west = puzzle.size.parseCell('B3');
    final east = puzzle.size.parseCell('E6');
    expect(deal.play(cells('B1 B2', size: puzzle.size))?.stroke.gains, {
      west: 2,
    });
    expect(deal.spilledCell, west);
    expect(deal.progressAt(west), 1);
    expect(deal.lost, isFalse);
    expect(deal.play(cells('G6 F6', size: puzzle.size))?.stroke.gains, {
      east: 2,
    });
    expect(deal.spilledCell, east);
    expect(deal.progressAt(east), 1);
    expect(deal.progressAt(west), 1);
    expect(deal.lost, isTrue);
  });

  test('The Fair Split uses all 24 moves on a losing attempt', () {
    final deal = PuzzleDeal(fairSplit);
    final size = fairSplit.size;
    final pairs = [
      for (var cell = 0; cell < size.cellCount; cell++)
        for (final next in size.neighbours(cell)) [cell, next],
    ];
    for (var left = 24; left > 0; left--) {
      expect(deal.finished, isFalse);
      expect(deal.movesLeft, left);
      final miss = pairs.firstWhere(
        (pair) => deal.inspect(pair)?.gains.isEmpty ?? false,
      );
      expect(deal.play(miss), isNotNull);
    }
    expect(deal.movesLeft, 0);
    expect(deal.won, isFalse);
    expect(deal.lost, isTrue);
  });

  test('mixed targets score independently even on the same square', () {
    final source = File(PuzzleCatalog.assetPath).readAsStringSync();
    final puzzle = marketDayVariant(source, links: true).puzzles.single;
    final lamp = marketDaySize.parseCell('C3');
    final inlet = marketDaySize.parseCell('F3');
    final pan = marketDaySize.parseCell('C6');
    final deal = PuzzleDeal(puzzle);
    List<int> route(String path) => cells(path, size: marketDaySize);

    expect(puzzle.scoringSuits, {Suit.wand, Suit.cup, Suit.coin});
    expect(deal.inspect(route('F5 F4'))?.gains, isEmpty);
    expect(deal.inspect(route('E6 D6'))?.gains, {pan: 2});
    final square = deal.inspect(route('C3 F3 F6 C6 C3'))!;
    expect(square.suit, Suit.wand);
    expect(square.gains.keys, [lamp]);
    expect(square.linkedTargets, isEmpty);
    expect(square.cleared.intersection({lamp, inlet, pan}), isEmpty);
    for (final (path, light, water, coins) in marketDayReplay) {
      expect(deal.won, isFalse);
      expect(deal.play(route(path)), isNotNull, reason: path);
      expect(
        [deal.progressAt(lamp), deal.progressAt(inlet), deal.progressAt(pan)],
        [light, water, coins],
        reason: path,
      );
    }
    expect(deal.won, isTrue);
  });

  test(
    'Market Day opens the stall after either setup and a missed opening',
    () {
      for (final replay in [
        marketDayReplay.map((move) => move.$1),
        [
          'E6 D6',
          'D1 G1 G6 D6 D1',
          'C3 F3 F6 C6 C3',
          'C3 F3 F6 C6 C3',
          'C3 G3 G6 C6 C3',
        ],
        [
          'D2 E2',
          'C1 E1 E6 C6 C1',
          'C3 G3 G6 C6 C3',
          'C3 G3 G6 C6 C3',
          'C3 F3 F6 C6 C3',
        ],
      ]) {
        final deal = PuzzleDeal(marketDay);
        for (final route in replay) {
          expect(
            deal.play(cells(route, size: marketDay.size)),
            isNotNull,
            reason: route,
          );
        }
        expect(deal.won, isTrue);
        expect(deal.moves, 5);
      }
    },
  );

  test('rectangular deals use both edges for aim, rectangles and refill', () {
    final puzzle = tallCatalog.puzzles.single;
    final deal = PuzzleDeal(puzzle);
    final size = puzzle.size;
    expect((size.columns, size.rows), (6, 7));
    List<int> route(String value) => cells(value, size: size);

    expect(deal.inspect(route('D7 E7'))?.totalGain, 2);
    expect(deal.inspect(route('F6 A7')), isNull);
    expect(() => size.parseCell('G7'), throwsFormatException);
    expect(() => size.parseCell('F8'), throwsFormatException);
    final turn = deal.play(route('C5 F5 F7 C7 C5'))!;
    expect(turn.stroke.isRectangle, isTrue);
    expect(turn.stroke.cleared, hasLength(11));
    expect(deal.progressAt(deal.puzzle.targets.keys.single), 8);
    expect(deal.board.where((suit) => suit == null), hasLength(1));
    expect(deal.board[puzzle.targets.keys.single], isNull);
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
    expect(puzzle.targets.keys.single, 269);
    expect(puzzle.size.cellLabel(puzzle.targets.keys.single), 'AA10');
    expect(
      PuzzleDeal(puzzle)
          .inspect(cells('Y10 Z10', size: puzzle.size))
          ?.totalGain,
      2,
    );

    expect(() => rectangularCatalog([], 'A1'), throwsFormatException);
    expect(() => rectangularCatalog(['LC', 'C'], 'A1'), throwsFormatException);
    expect(() => rectangularCatalog(['LC'], 'C1'), throwsFormatException);
  });

  test('From Behind only scores eastbound hits and advances each ribbon', () {
    final deal = PuzzleDeal(fromBehind);
    final lamp = openingSize.parseCell('D4');
    final wrongWay = deal.inspect(cells('F4 E4'))!;
    expect(wrongWay.suit, Suit.wand);
    expect(openingSize.aimOf(wrongWay.path), lamp);
    expect(wrongWay.totalGain, 0);
    final rectangle = deal.inspect(cells('C3 E3 E4 C4 C3'))!;
    expect(rectangle.isRectangle, isTrue);
    expect(rectangle.totalGain, 0);
    expect(deal.upcomingArrivals(1).take(3), [
      Suit.wand,
      Suit.sword,
      Suit.wand,
    ]);
    expect(deal.play(cells('B5 B6')), isNotNull);
    expect(deal.upcomingArrivals(1).take(3), [Suit.wand, Suit.cup, Suit.wand]);
    expect(deal.upcomingArrivals(0).take(3), [Suit.coin, Suit.cup, Suit.coin]);
    expect(deal.inspect(cells(fromBehindReplay[1].$1))?.gains, {lamp: 9});
  });

  test('From Behind clears by two setups and recovers on the last move', () {
    final lamp = openingSize.parseCell('D4');
    for (final route in [
      fromBehindReplay,
      _fromBehindRectangleSetup,
      _fromBehindRecovery,
    ]) {
      final deal = PuzzleDeal(fromBehind);
      for (final (trace, light) in route) {
        expect(deal.play(cells(trace)), isNotNull, reason: trace);
        expect(deal.progressAt(lamp), light, reason: trace);
      }
      expect(deal.won, isTrue);
      expect(deal.movesLeft, fromBehind.limit - route.length);
    }
  });

  test('From Behind loses after spending all moves on poor setup', () {
    final deal = PuzzleDeal(fromBehind);
    const route = [
      'B1 B2',
      'A3 B3',
      'B3 C3',
      'C2 D2',
      'C1 D1',
      'C1 C2',
      'D1 E1',
      'D1 D2',
      'E1 F1',
      'F1 F2',
      'D2 D3',
      'E2 F2',
      'E2 E3',
      'E1 F1',
      'C3 D3',
      'C1 C2',
      'D2 E2',
      'C1 D1',
    ];
    for (final trace in route) {
      expect(deal.play(cells(trace))?.stroke.totalGain, 0, reason: trace);
    }
    expect(deal.movesLeft, 0);
    expect(deal.lost, isTrue);
  });

  test(
    'Keep Me a Partner fills the basin from either side and after a miss',
    () {
      final size = keepMeAPartner.size;
      final basin = size.parseCell('D7');
      for (final route in [
        partnerReplay,
        const [
          ('E7 F7', 0),
          ('F7 E7', 2),
          ('D4 F4 F7 D7 D4', 8),
          ('D3 F3 F7 D7 D3', 13),
          ('B5 C5 D5 D6', 17),
          ('D1 E1 E7 D7 D1', 27),
          ('D4 D5 D6', 30),
        ],
        const [
          ('A1 B1', 0),
          ('B6 C6', 0),
          ('B7 C7', 0),
          ('A7 B7 C7', 3),
          ('E7 F7 G7', 3),
          ('D2 F2 F7 D7 D2', 13),
          ('D2 F2 F7 D7 D2', 21),
          ('D3 F3 F7 D7 D3', 29),
          ('E6 E5 D5 D6', 30),
        ],
      ]) {
        final deal = PuzzleDeal(keepMeAPartner);
        var receivedCups = false;
        for (final (path, water) in route) {
          final turn = deal.play(cells(path, size: size));
          expect(turn, isNotNull, reason: path);
          expect(deal.progressAt(basin), water, reason: path);
          receivedCups |= turn!.falls.any(
            (fall) => fall.suit == Suit.cup && fall.fromRow < 0,
          );
        }
        expect(receivedCups, isTrue);
        expect(deal.won, isTrue);
        expect(deal.board[basin], isNull);
        expect(deal.board, contains(Suit.cup));
      }
    },
  );

  test('Keep Me a Partner loses when the basin is short at the limit', () {
    final deal = PuzzleDeal(keepMeAPartner);
    final size = keepMeAPartner.size;
    const route = [
      'E7 F7',
      'F7 E7',
      'A1 B1',
      'B1 C1',
      'A1 B1',
      'A1 B1',
      'A1 B1',
      'A1 B1',
      'A1 A2',
      'A1 B1',
      'A1 B1',
      'A1 A2',
      'A1 B1',
      'A1 A2',
    ];
    for (final trace in route) {
      expect(deal.play(cells(trace, size: size)), isNotNull, reason: trace);
    }
    expect(deal.progressAt(size.parseCell('D7')), 2);
    expect(deal.movesLeft, 0);
    expect(deal.lost, isTrue);
  });

  test('Night Fishing drops Swords into the Wand line', () {
    final deal = PuzzleDeal(nightFishing);
    final size = nightFishing.size;
    final lamp = size.parseCell('C5');
    final cord = size.parseCell('F5');
    final cuttingLine = cells('D5 E5', size: size);
    expect(deal.inspect(cuttingLine)?.suit, Suit.wand);
    expect(deal.inspect(cuttingLine)?.gains, isEmpty);
    expect(deal.play(cells('E5 D5', size: size))?.stroke.gains, {lamp: 2});
    expect(cuttingLine.map((cell) => deal.board[cell]), [
      Suit.sword,
      Suit.sword,
    ]);
    expect(deal.play(cuttingLine)?.stroke.gains, {cord: 2});
    expect(deal.won, isFalse);
  });

  test('Night Fishing clears from either opening and after a missed spark', () {
    final size = nightFishing.size;
    final lamp = size.parseCell('C5');
    final cord = size.parseCell('F5');
    for (final route in [
      nightFishingReplay,
      const [
        ('H5 G5', 0, 2),
        ('C7 C6', 2, 2),
        ('C1 G1 G8 C8 C1', 6, 2),
        ('G8 F8 F7 F6', 6, 6),
      ],
      const [
        ('D5 E5', 0, 0),
        ('D5 E5', 0, 2),
        ('F8 E8 D8', 0, 2),
        ('D8 C8 B8 B7 C7 C6', 6, 2),
        ('H5 G5', 6, 4),
        ('F3 F2 F1 E1', 6, 4),
        ('F3 F4', 6, 6),
      ],
    ]) {
      final deal = PuzzleDeal(nightFishing);
      for (final (path, light, cut) in route) {
        expect(deal.play(cells(path, size: size)), isNotNull, reason: path);
        expect(deal.progressAt(lamp), light, reason: path);
        expect(deal.progressAt(cord), cut, reason: path);
        expect(deal.won, light == 6 && cut == 6);
      }
      expect(deal.won, isTrue);
    }
  });

  test('Night Fishing loses at the move limit with the mooring still tied', () {
    final deal = PuzzleDeal(nightFishing);
    final size = nightFishing.size;
    const route = [
      'E5 D5',
      'B8 C8 C7 C6',
      'F1 E1',
      'B8 A8',
      'B1 A1',
      'B1 A1',
      'B2 B1',
      'A2 A1',
      'B1 A1',
      'A2 A1',
      'B1 A1',
      'A2 A1',
      'B1 A1',
      'B1 A1',
      'A2 A1',
      'B1 A1',
      'B1 A1',
      'C1 B1',
      'C1 B1',
      'B1 A1',
    ];
    for (final (index, path) in route.indexed) {
      expect(deal.play(cells(path, size: size)), isNotNull, reason: path);
      expect(deal.lost, index == route.length - 1);
    }
    expect(deal.progressAt(size.parseCell('C5')), 6);
    expect(deal.progressAt(size.parseCell('F5')), 0);
  });

  test('validates and replays every authored guide', () {
    expect(catalog.next(foolsStep), lamplighter);
    expect(catalog.next(lamplighter), highWater);
    expect(catalog.next(highWater), mooring);
    expect(catalog.next(mooring), ferrymansFare);
    expect(catalog.next(ferrymansFare), marketDay);
    expect(catalog.next(marketDay), fairSplit);
    expect(catalog.next(fairSplit), fromBehind);
    expect(catalog.next(fromBehind), keepMeAPartner);
    expect(catalog.next(keepMeAPartner), nightFishing);
    expect(catalog.next(nightFishing), isNull);
    expect(catalog.unlockedIndex('002'), 1);
    expect(catalog.unlockedIndex('003'), 2);
    expect(catalog.unlockedIndex('004'), 3);
    expect(catalog.unlockedIndex('005'), 4);
    expect(catalog.unlockedIndex('006'), 5);
    expect(catalog.unlockedIndex('007'), 6);
    expect(catalog.unlockedIndex('008'), 7);
    expect(catalog.unlockedIndex('009'), 8);
    expect(catalog.unlockedIndex('010'), 9);
    expect(catalog.puzzles.map((puzzle) => puzzle.limit), [
      25,
      22,
      18,
      26,
      25,
      18,
      24,
      18,
      14,
      20,
    ]);
    expect(
      catalog.puzzles.map((puzzle) => (puzzle.size.columns, puzzle.size.rows)),
      [
        (6, 6),
        (5, 6),
        (6, 7),
        (7, 6),
        (8, 8),
        (7, 7),
        (7, 7),
        (6, 6),
        (7, 7),
        (8, 8),
      ],
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
    expect(size.cellLabel(highWater.targets.keys.single), 'B5');
    expect(highWater.limit, 18);
    expect(deal.guide, isNull);
    expect(deal.inspect(route('A6 A7 B7 B6'))?.totalGain, 4);
    expect(deal.inspect(route('D4 D5 C5'))?.totalGain, 3);
    expect(deal.inspect(route(millReplay[1].$1)), isNull);

    final setup = deal.play(route(millReplay[0].$1))!;
    expect(deal.progressAt(deal.puzzle.targets.keys.single), 0);
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
    expect(expectedClear.totalGain, 4);
    for (final (trace, water) in millReplay.skip(1)) {
      expect(deal.play(route(trace)), isNotNull, reason: trace);
      expect(
        deal.progressAt(deal.puzzle.targets.keys.single),
        water,
        reason: trace,
      );
      expect(deal.board[highWater.targets.keys.single], isNull);
    }
    expect(deal.won, isTrue);
    expect(deal.stars, 3);

    final missed = PuzzleDeal(highWater);
    expect(missed.play(route('B6 B7'))?.stroke.totalGain, 0);
    while (!missed.finished) {
      final misses = [
        for (var cell = 0; cell < size.cellCount; cell++)
          for (final next in size.neighbours(cell))
            if (missed.inspect([cell, next])?.totalGain == 0) [cell, next],
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

  test('both pans can lead and a missed opening leaves room to recover', () {
    final west = marketSize.parseCell('C4');
    final east = marketSize.parseCell('F4');
    final masked = cells('B1 G1', size: marketSize);
    expect(ferrymansFare.targets.keys, [west, east]);
    expect(ferrymansFare.masked, unorderedEquals(masked));

    for (final (replay, stars) in [
      (westFareReplay, 3),
      (eastFareReplay, 3),
      (_fareRecovery, 2),
    ]) {
      final deal = PuzzleDeal(ferrymansFare);
      expect(deal.guide, isNull);
      for (final (trace, westCoins, eastCoins) in replay) {
        expect(deal.won, isFalse);
        expect(
          deal.play(cells(trace, size: marketSize)),
          isNotNull,
          reason: trace,
        );
        expect(deal.progressAt(west), westCoins, reason: trace);
        expect(deal.progressAt(east), eastCoins, reason: trace);
        expect(deal.link, isNull);
        for (final cell in [...masked, west, east]) {
          expect(deal.board[cell], isNull);
        }
      }
      expect(deal.won, isTrue);
      expect(deal.stars, stars);
    }
  });

  test('a Coin square can pay both pans in one move', () {
    final deal = PuzzleDeal(ferrymansFare);
    final west = marketSize.parseCell('C4');
    final east = marketSize.parseCell('F4');
    for (final trace in ['D4 E4', 'A2 H2 H7 A7 A2', 'C3 G3 G6 C6 C3']) {
      expect(deal.play(cells(trace, size: marketSize)), isNotNull);
    }
    final square = deal.play(cells('C1 F1 F4 C4 C1', size: marketSize))!;
    expect(square.stroke.gains, {west: 7, east: 7});
    expect(deal.link, isNull);
    for (final trace in ['C2 H2 H8 C8 C2', 'C4 G4 G6 C6 C4']) {
      expect(deal.play(cells(trace, size: marketSize)), isNotNull);
    }
    expect(deal.won, isTrue);
  });

  test('a full west pan does not cover an unpaid east pan', () {
    final deal = PuzzleDeal(ferrymansFare);
    final west = marketSize.parseCell('C4');
    final east = marketSize.parseCell('F4');
    for (final (trace, _, _) in westFareReplay.take(9)) {
      expect(deal.play(cells(trace, size: marketSize)), isNotNull);
    }
    final pairs = [
      for (var cell = 0; cell < marketSize.cellCount; cell++)
        for (final neighbour in marketSize.neighbours(cell)) [cell, neighbour],
    ];
    while (!deal.finished) {
      final miss = pairs.firstWhere(
        (path) => deal.inspect(path)?.gains.isEmpty ?? false,
      );
      expect(deal.play(miss), isNotNull);
    }
    expect(deal.progressAt(west), 24);
    expect(deal.progressAt(east), 14);
    expect(deal.movesLeft, 0);
    expect(deal.lost, isTrue);
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
    expect(foolsStep.scoringSuits.single, Suit.wand);
    expect(lamplighter.scoringSuits.single, Suit.cup);
    expect(route.board[cells('A3', size: lampSize).single], Suit.cup);
    expect(route.inspect(cells('A3 B3', size: lampSize))?.totalGain, 2);
    expect(route.inspect(cells('B3 A3', size: lampSize))?.totalGain, 0);
    final enclosure = route.inspect(
      cells(lampReplay.first.$1, size: lampSize),
    )!;
    expect(enclosure.totalGain, 4);
    expect(
      enclosure.cleared.map((cell) => route.board[cell]).toSet(),
      unorderedEquals(Suit.values),
    );
    expect(unlit.play(cells('D1 D2', size: lampSize)), isNotNull);
    expect(unlit.progressAt(unlit.puzzle.targets.keys.single), 0);
    expect(unlit.faded, isEmpty);
    expect(route.guide, isNull);
    for (final (trace, light) in lampReplay) {
      final before = route.progressAt(route.puzzle.targets.keys.single);
      final turn = route.play(cells(trace, size: lampSize));
      expect(turn, isNotNull, reason: trace);
      expect(
        route.progressAt(route.puzzle.targets.keys.single),
        light,
        reason: trace,
      );
      expect(
        route.faded[lamplighter.targets.keys.single] ?? 0,
        before > light ? 1 : 0,
        reason: trace,
      );
      if (!turn!.stroke.isRectangle && turn.stroke.totalGain > 0) {
        expect(turn.stroke.totalGain, turn.stroke.path.length);
      }
      expect(route.board[lamplighter.targets.keys.single], isNull);
      expect(repeat.play(cells(trace, size: lampSize)), isNotNull);
      expect(repeat.board, route.board);
      expect(
        repeat.progressAt(repeat.puzzle.targets.keys.single),
        route.progressAt(route.puzzle.targets.keys.single),
      );
    }
    expect(route.won, isTrue);
    expect(route.stars, 3);
    expect(route.moves, lampReplay.length);
  });

  test('keeps E4 fixed from the start and matches the authored handoff', () {
    final deal = PuzzleDeal(foolsStep);
    expect(deal.board[foolsStep.targets.keys.single], isNull);
    expect(deal.progressAt(deal.puzzle.targets.keys.single), 0);
    expect(deal.play(cells('D1 C1')), isNull);
    expect(deal.movesLeft, 25);
    expect(deal.play(cells('C2 C1')), isNotNull);
    final square = deal.play(cells(guidedRoutes[1]))!.stroke;
    expect(square.isRectangle, isTrue);
    expect(square.totalGain, 0);
    expect(square.cleared, hasLength(9));
    expect(deal.board[foolsStep.targets.keys.single], isNull);
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
    expect(deal.board[foolsStep.targets.keys.single], isNull);
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
    expect(enclosure.stroke.totalGain, 4);
    expect(deal.progressAt(deal.puzzle.targets.keys.single), 4);
    expect(deal.play(cells('E3 E2')), isNull);
    expect(deal.play(cells(guidedRoutes[4]))?.stroke.totalGain, 2);
    expect(deal.progressAt(deal.puzzle.targets.keys.single), 6);
    expect(deal.guide?.cue, GuideCue.wildcard);
    final wildcard = deal.play(cells(guidedRoutes[5]))!.stroke;
    expect(wildcard.isRectangle, isTrue);
    expect(wildcard.path, contains(foolsStep.targets.keys.single));
    expect(wildcard.cleared, unorderedEquals(cells('E3 F3 F4')));
    expect(wildcard.totalGain, 0);
    expect(deal.guide, isNull);
    expect(deal.movesLeft, 19);
    expect(deal.progressAt(deal.puzzle.targets.keys.single), 6);
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
          expect(
            deal.progressAt(deal.puzzle.targets.keys.single),
            light,
            reason: route,
          );
          expect(deal.board[foolsStep.targets.keys.single], isNull);
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
    expect(wandSquare.totalGain, 0);
    final edge = deal.inspect(cells('D1 E1 E5 D5 D1'))!;
    expect(edge.totalGain, 4);
    final corner = deal.inspect(cells('D1 E1 E4 D4 D1'))!;
    expect(corner.totalGain, 7);
    expect(corner.cleared, isNot(contains(foolsStep.targets.keys.single)));
    expect(deal.play(cells('D1 E1')), isNotNull);
    final coin = deal.inspect(cells('E1 F1 F4 E4 E1'))!;
    expect(coin.totalGain, 0);
    expect(coin.cleared, containsAll(cells('F3 F4')));
    expect(coin.cleared, isNot(contains(foolsStep.targets.keys.single)));
    expect(deal.inspect(cells('C1 E3 C5 A3 C1')), isNull);
    expect(deal.inspect(cells('E4 F3 F5 E4')), isNull);
    expect(deal.inspect(cells('E1 F1 E2 F2 E1')), isNull);
  });
}
