import 'dart:math' as math;

import 'puzzle_definition.dart';
import 'stroke.dart';

export 'puzzle_definition.dart';

class Stroke {
  const Stroke(this.path, this.cleared, this.light, {this.isRectangle = false});

  final List<int> path;
  final Set<int> cleared;
  final int light;
  final bool isRectangle;
}

class Fall {
  const Fall(this.suit, this.column, this.fromRow, this.toRow);

  final Suit suit;
  final int column;
  final int fromRow;
  final int toRow;
}

class Turn {
  const Turn(this.stroke, this.before, this.falls, this.lightBefore);

  final Stroke stroke;
  final List<Suit?> before;
  final List<Fall> falls;
  final int lightBefore;
}

class PuzzleDeal {
  PuzzleDeal(this.puzzle) : _board = puzzle.opening;

  final PuzzleDefinition puzzle;
  List<Suit?> _board;
  final _ribbonCursors = List<int>.filled(boardSide, 0);
  late final _random = math.Random((puzzle.refill as GuidedRefill).seed);
  int _moves = 0;
  int _light = 0;
  int _faded = 0;
  bool _jammed = false;

  List<Suit?> get board => _board;
  int get moves => _moves;
  int get movesLeft => puzzle.limit - moves;
  int get light => _light;
  int get faded => _faded;
  bool get won => light >= puzzle.target;
  bool get lost => !won && (movesLeft == 0 || _jammed);
  bool get finished => won || lost;
  GuideMove? get guide => moves < guideLength ? puzzle.guide[moves] : null;
  int get guideLength => puzzle.guide.length;
  int get stars => !won
      ? 0
      : (moves <= puzzle.par
            ? 3
            : (moves <= (puzzle.par + puzzle.limit + 1) ~/ 2 ? 2 : 1));

  Stroke? inspect(List<int> path) {
    if (path.length < 2 || path.any((cell) => cell < 0 || cell >= cellCount)) {
      return null;
    }
    if (path.first == path.last) {
      final corners = rectangleCorners(path);
      return corners == null ? null : _rectangle(corners);
    }
    final suit = board[path.first];
    if (suit == null || path.toSet().length != path.length) return null;
    for (var i = 1; i < path.length; i++) {
      if (board[path[i]] != suit ||
          !neighbours(path[i - 1]).contains(path[i])) {
        return null;
      }
    }
    final gain = suit == puzzle.scoringSuit && aimOf(path) == puzzle.marker
        ? path.length
        : 0;
    return Stroke(List.unmodifiable(path), path.toSet(), gain);
  }

  Suit? _cornerSuit(List<Suit?> layout, List<int> corners) {
    final suits = corners.map((cell) => layout[cell]).whereType<Suit>().toSet();
    return suits.length == 1 ? suits.single : null;
  }

  Stroke? _rectangle(List<int> corners) {
    final cornerSuit = _cornerSuit(board, corners);
    if (cornerSuit == null) return null;
    final cleared = {
      for (var cell = 0; cell < cellCount; cell++)
        if (board[cell] != null && coversCell(corners, cell)) cell,
    };
    var gain = 0;
    if (cornerSuit == puzzle.scoringSuit &&
        coversCell(corners, puzzle.marker)) {
      gain = corners.contains(puzzle.marker)
          ? math.max(
              puzzle.rules.cornerProgressPerPiece,
              cleared
                      .where((cell) => board[cell] == puzzle.scoringSuit)
                      .length *
                  puzzle.rules.cornerProgressPerPiece,
            )
          : puzzle.rules.shapeProgress;
    }
    return Stroke(
      [...corners, corners.first],
      cleared,
      gain,
      isRectangle: true,
    );
  }

  bool _matchesGuide(Stroke stroke, GuideMove guide) {
    if (stroke.isRectangle) {
      if (guide.path.first != guide.path.last) return false;
      final taught = guide.path.toSet();
      final attempted = stroke.path.toSet();
      return attempted.length == taught.length && attempted.containsAll(taught);
    }
    if (stroke.path.length != guide.path.length) return false;
    if (stroke.path.first == guide.path.first &&
        stroke.path.last == guide.path.last) {
      return true;
    }
    return guide.cue != GuideCue.aim &&
        stroke.path.first == guide.path.last &&
        stroke.path.last == guide.path.first;
  }

  Turn? play(List<int> path) {
    if (finished) return null;
    final stroke = inspect(path);
    final lesson = guide;
    if (stroke == null || (lesson != null && !_matchesGuide(stroke, lesson))) {
      return null;
    }
    final before = board;
    final lightBefore = light;
    final next = List<Suit?>.filled(cellCount, null);
    final falls = <Fall>[];
    final vacancies = <int>[];
    for (var column = 0; column < boardSide; column++) {
      final slots = [
        for (var row = boardSide - 1; row >= 0; row--)
          if (row * boardSide + column != puzzle.marker) row,
      ];
      var destination = 0;
      for (final row in slots) {
        final index = row * boardSide + column;
        if (stroke.cleared.contains(index)) continue;
        final suit = before[index]!;
        final toRow = slots[destination++];
        final to = toRow * boardSide + column;
        next[to] = suit;
        falls.add(Fall(suit, column, row, toRow));
      }
      while (destination < slots.length) {
        vacancies.add(slots[destination++] * boardSide + column);
      }
    }
    _refill(next, vacancies, falls, lesson);
    _moves++;
    _faded = stroke.light == 0 ? math.min(light, puzzle.fading) : 0;
    _light = math.min(puzzle.target, light + stroke.light - faded);
    _board = List.unmodifiable(next);
    if (guide == null && movesLeft > 0 && !won) {
      _jammed = !_hasLegalStroke(board);
    }
    return Turn(stroke, before, falls, lightBefore);
  }

  void _refill(
    List<Suit?> next,
    List<int> vacancies,
    List<Fall> falls,
    GuideMove? lesson,
  ) {
    final arrivals = List<int>.filled(boardSide, 0);
    final refill = puzzle.refill;
    if (lesson == null && refill is GuidedRefill) {
      _guidedFill(next, vacancies, refill.supply);
    }
    for (final cell in vacancies) {
      final column = columnOf(cell);
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
      next[cell] = suit;
      falls.add(Fall(suit, column, -arrival - 1, rowOf(cell)));
    }
  }

  void _guidedFill(List<Suit?> next, List<int> vacancies, List<Suit> supply) {
    var bestScore = -1;
    final candidate = List<Suit?>.of(next);
    for (var sample = 0; sample < puzzle.rules.refillSamples; sample++) {
      for (final cell in vacancies) {
        candidate[cell] = supply[_random.nextInt(supply.length)];
      }
      final score = _refillScore(candidate);
      if (score <= bestScore) continue;
      bestScore = score;
      for (final cell in vacancies) {
        next[cell] = candidate[cell];
      }
    }
    if (_hasLegalStroke(next)) return;
    for (final cell in vacancies) {
      for (final neighbour in neighbours(cell)) {
        if (next[neighbour] == null) continue;
        next[cell] = next[neighbour];
        return;
      }
    }
  }

  int _refillScore(List<Suit?> layout) {
    final rules = puzzle.rules;
    var score = layout.whereType<Suit>().toSet().length;
    for (var cell = 0; cell < cellCount; cell++) {
      final suit = layout[cell];
      if (suit == null) continue;
      for (final neighbour in neighbours(cell)) {
        if (layout[neighbour] != suit) continue;
        if (cell < neighbour) {
          score += rowOf(cell) + 1 >= rules.refillLowerRow
              ? rules.refillLowerPairWeight
              : rules.refillOtherPairWeight;
        }
        if (suit == puzzle.scoringSuit &&
            aimOf([cell, neighbour]) == puzzle.marker) {
          score += rules.refillAimWeight;
        }
      }
    }
    return score;
  }

  Stroke? get demonstration {
    final lesson = guide;
    return lesson == null ? null : inspect(lesson.path);
  }

  bool _hasLegalStroke(List<Suit?> layout) {
    for (var cell = 0; cell < cellCount; cell++) {
      final suit = layout[cell];
      if (suit != null &&
          neighbours(cell).any((next) => layout[next] == suit)) {
        return true;
      }
    }
    for (var top = 0; top < boardSide - 1; top++) {
      for (var bottom = top + 1; bottom < boardSide; bottom++) {
        for (var left = 0; left < boardSide - 1; left++) {
          for (var right = left + 1; right < boardSide; right++) {
            final corners = [
              top * boardSide + left,
              top * boardSide + right,
              bottom * boardSide + right,
              bottom * boardSide + left,
            ];
            if (_cornerSuit(layout, corners) != null) return true;
          }
        }
      }
    }
    return false;
  }
}
