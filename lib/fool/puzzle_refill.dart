import 'dart:math' as math;

import 'puzzle_definition.dart';
import 'stroke.dart';
import 'stroke_checker.dart';

class Fall {
  const Fall(this.suit, this.column, this.fromRow, this.toRow);

  final Suit suit;
  final int column;
  final int fromRow;
  final int toRow;
}

class PuzzleRefill {
  PuzzleRefill(this.puzzle, this.checker);

  final PuzzleDefinition puzzle;
  final StrokeChecker checker;
  late final _ribbonCursors = List<int>.filled(_size.columns, 0);
  late final _random = math.Random((puzzle.refill as GuidedRefill).seed);
  BoardSize get _size => puzzle.size;

  ({List<Suit?> board, List<Fall> falls}) settle(
    List<Suit?> before,
    Stroke stroke, {
    required GuideMove? lesson,
    required bool keepPlayable,
    Map<int, Suit> arrivals = const {},
  }) {
    final next = List<Suit?>.filled(_size.cellCount, null);
    final falls = <Fall>[];
    final vacancies = <int>[];
    for (var column = 0; column < _size.columns; column++) {
      final slots = [
        for (var row = _size.rows - 1; row >= 0; row--)
          if (puzzle.holdsPiece(row * _size.columns + column)) row,
      ];
      var destination = 0;
      for (final row in slots) {
        final index = row * _size.columns + column;
        if (stroke.cleared.contains(index)) continue;
        final suit = before[index]!;
        final toRow = slots[destination++];
        final to = toRow * _size.columns + column;
        next[to] = suit;
        falls.add(Fall(suit, column, row, toRow));
      }
      while (destination < slots.length) {
        vacancies.add(slots[destination++] * _size.columns + column);
      }
    }
    _refill(next, vacancies, falls, lesson, arrivals);
    if (keepPlayable) _keepBoardPlayable(next, falls, stroke, arrivals);
    return (board: List.unmodifiable(next), falls: List.unmodifiable(falls));
  }

  void _refill(
    List<Suit?> next,
    List<int> vacancies,
    List<Fall> falls,
    GuideMove? lesson,
    Map<int, Suit> overrides,
  ) {
    final arrivals = List<int>.filled(_size.columns, 0);
    final refill = puzzle.refill;
    if (lesson == null && refill is GuidedRefill) {
      _guidedFill(next, vacancies, refill.supply, overrides);
    }
    for (final cell in vacancies) {
      final column = _size.columnOf(cell);
      final arrival = arrivals[column]++;
      final Suit suit;
      if (lesson != null) {
        suit = lesson.arrivals[column][arrival];
      } else if (refill is RibbonRefill) {
        final ribbon = refill.columns[column];
        suit = ribbon[_ribbonCursors[column]++ % ribbon.length];
      } else {
        suit = next[cell]!;
      }
      final placed = overrides[cell] ?? suit;
      next[cell] = placed;
      falls.add(Fall(placed, column, -arrival - 1, _size.rowOf(cell)));
    }
  }

  void _guidedFill(
    List<Suit?> next,
    List<int> vacancies,
    List<Suit> supply,
    Map<int, Suit> overrides,
  ) {
    var bestScore = -1;
    final candidate = List<Suit?>.of(next);
    for (var sample = 0; sample < puzzle.rules.refillSamples; sample++) {
      for (final cell in vacancies) {
        final sampled = supply[_random.nextInt(supply.length)];
        candidate[cell] = overrides[cell] ?? sampled;
      }
      final score = _refillScore(candidate);
      if (score <= bestScore) continue;
      bestScore = score;
      for (final cell in vacancies) {
        next[cell] = candidate[cell];
      }
    }
  }

  void _keepBoardPlayable(
    List<Suit?> next,
    List<Fall> falls,
    Stroke stroke,
    Map<int, Suit> overrides,
  ) {
    if (checker.hasLegalStroke(next)) return;
    for (final (index, fall) in falls.indexed) {
      if (fall.fromRow >= 0) continue;
      final cell = fall.toRow * _size.columns + fall.column;
      if (overrides.containsKey(cell)) continue;
      for (final neighbour in _size.neighbours(cell)) {
        final suit = next[neighbour];
        if (suit == null) continue;
        next[cell] = suit;
        falls[index] = Fall(suit, fall.column, fall.fromRow, fall.toRow);
        return;
      }
    }

    final match = stroke.path.take(stroke.isRectangle ? 4 : 2).toSet();
    for (final (index, fall) in falls.indexed) {
      final cell = fall.toRow * _size.columns + fall.column;
      if (overrides.containsKey(cell)) continue;
      if (!match.contains(cell) || fall.suit == stroke.suit) continue;
      next[cell] = stroke.suit;
      falls[index] = Fall(stroke.suit, fall.column, fall.fromRow, fall.toRow);
    }
  }

  int _refillScore(List<Suit?> layout) {
    final rules = puzzle.rules;
    final lowerRow = rules.firstLowerRow(_size);
    var score = layout.whereType<Suit>().toSet().length;
    for (var cell = 0; cell < _size.cellCount; cell++) {
      final suit = layout[cell];
      if (suit == null) continue;
      for (final neighbour in _size.neighbours(cell)) {
        if (layout[neighbour] != suit) continue;
        if (cell < neighbour) {
          score += _size.rowOf(cell) >= lowerRow
              ? rules.refillLowerPairWeight
              : rules.refillOtherPairWeight;
        }
        if (checker.acceptsAim(
          _size.aimOf([cell, neighbour]),
          suit,
          cell,
          neighbour,
        )) {
          score += rules.refillAimWeight;
        }
      }
    }
    return score;
  }
}
