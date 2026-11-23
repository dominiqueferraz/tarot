import 'dart:math' as math;

import 'puzzle_definition.dart';
import 'stroke.dart';

export 'puzzle_definition.dart';

class Stroke {
  const Stroke(
    this.suit,
    this.path,
    this.cleared,
    this.gains, {
    this.isRectangle = false,
    this.linkedTargets = const {},
  });

  final Suit suit;
  final List<int> path;
  final Set<int> cleared;
  final Map<int, int> gains;
  int get totalGain => gains.values.fold(0, (total, value) => total + value);
  final bool isRectangle;
  final Set<int> linkedTargets;
}

class Fall {
  const Fall(this.suit, this.column, this.fromRow, this.toRow);

  final Suit suit;
  final int column;
  final int fromRow;
  final int toRow;
}

class TargetLink {
  const TargetLink(this.cells, this.movesLeft);

  final Set<int> cells;
  final int movesLeft;
}

class Turn {
  const Turn(
    this.stroke,
    this.before,
    this.falls,
    this.progressBefore,
    this.linkBefore,
  );

  final Stroke stroke;
  final List<Suit?> before;
  final List<Fall> falls;
  final Map<int, int> progressBefore;
  final TargetLink? linkBefore;
}

class PuzzleDeal {
  PuzzleDeal(this.puzzle) : _board = puzzle.opening {
    _jammed = puzzle.guide.isEmpty && !_hasLegalStroke(_board);
  }

  final PuzzleDefinition puzzle;
  List<Suit?> _board;
  late final _ribbonCursors = List<int>.filled(_size.columns, 0);
  BoardSize get _size => puzzle.size;
  late final _random = math.Random((puzzle.refill as GuidedRefill).seed);
  int _moves = 0;
  Map<int, int> _progress = const {};
  Map<int, int> _faded = const {};
  bool _jammed = false;
  TargetLink? _link;

  List<Suit?> get board => _board;
  TargetLink? get link => _link;
  int get moves => _moves;
  int get movesLeft => puzzle.limit - moves;
  int progressAt(int cell) => _progress[cell] ?? 0;
  Map<int, int> get faded => _faded;
  bool get won => puzzle.targets.entries.every(
    (target) => progressAt(target.key) >= target.value.quota,
  );
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
    if (path.length < 2 ||
        path.any((cell) => cell < 0 || cell >= _size.cellCount)) {
      return null;
    }
    if (path.first == path.last) {
      final corners = _size.rectangleCorners(path);
      return corners == null ? null : _rectangle(corners);
    }
    final suit = board[path.first];
    if (suit == null || path.toSet().length != path.length) return null;
    for (var i = 1; i < path.length; i++) {
      if (board[path[i]] != suit ||
          !_size.neighbours(path[i - 1]).contains(path[i])) {
        return null;
      }
    }
    final aim = _size.aimOf(path);
    final targets = puzzle.targets[aim]?.suit != suit
        ? const <int>{}
        : (_link?.cells.contains(aim) ?? false)
        ? _link!.cells
        : {aim!};
    return Stroke(
      suit,
      List.unmodifiable(path),
      path.toSet(),
      Map.unmodifiable({for (final cell in targets) cell: path.length}),
    );
  }

  Suit? _cornerSuit(List<Suit?> layout, List<int> corners) {
    if (corners.any(puzzle.masked.contains)) return null;
    final suits = corners.map((cell) => layout[cell]).whereType<Suit>().toSet();
    return suits.length == 1 ? suits.single : null;
  }

  Stroke? _rectangle(List<int> corners) {
    final cornerSuit = _cornerSuit(board, corners);
    if (cornerSuit == null) return null;
    final cleared = {
      for (var cell = 0; cell < _size.cellCount; cell++)
        if (board[cell] != null && _size.coversCell(corners, cell)) cell,
    };
    final cornerGain = math.max(
      puzzle.rules.cornerProgressPerPiece,
      cleared.where((cell) => board[cell] == cornerSuit).length *
          puzzle.rules.cornerProgressPerPiece,
    );
    final gains = {
      for (final entry in puzzle.targets.entries)
        if (entry.value.suit == cornerSuit &&
            _size.coversCell(corners, entry.key))
          entry.key: corners.contains(entry.key)
              ? cornerGain
              : puzzle.rules.shapeProgress,
    };
    final a = corners[0];
    final b = corners[2];
    final square =
        (_size.columnOf(a) - _size.columnOf(b)).abs() ==
        (_size.rowOf(a) - _size.rowOf(b)).abs();
    final linkedTargets = puzzle.linksTargets && square
        ? corners.where(gains.containsKey).toSet()
        : const <int>{};
    return Stroke(
      cornerSuit,
      [...corners, corners.first],
      cleared,
      Map.unmodifiable(gains),
      isRectangle: true,
      linkedTargets: linkedTargets.length < 2
          ? const {}
          : Set.unmodifiable(linkedTargets),
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
        guide.cue != GuideCue.linkedAim &&
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
    final progressBefore = _progress;
    final linkBefore = _link;
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
    _refill(next, vacancies, falls, lesson);
    _moves++;
    if (stroke.linkedTargets.isNotEmpty) {
      _link = TargetLink(stroke.linkedTargets, stroke.linkedTargets.length);
    } else if (linkBefore != null) {
      _link = linkBefore.movesLeft > 1
          ? TargetLink(linkBefore.cells, linkBefore.movesLeft - 1)
          : null;
    }
    _faded = Map.unmodifiable({
      for (final entry in puzzle.targets.entries)
        if (!stroke.gains.containsKey(entry.key) &&
            entry.value.fading > 0 &&
            progressAt(entry.key) > 0)
          entry.key: math.min(progressAt(entry.key), entry.value.fading),
    });
    _progress = Map.unmodifiable({
      for (final entry in puzzle.targets.entries)
        entry.key: math.min(
          entry.value.quota,
          progressAt(entry.key) +
              (stroke.gains[entry.key] ?? 0) -
              (_faded[entry.key] ?? 0),
        ),
    });
    _board = List.unmodifiable(next);
    if (guide == null && movesLeft > 0 && !won) {
      _jammed = !_hasLegalStroke(board);
    }
    return Turn(stroke, before, falls, progressBefore, linkBefore);
  }

  void _refill(
    List<Suit?> next,
    List<int> vacancies,
    List<Fall> falls,
    GuideMove? lesson,
  ) {
    final arrivals = List<int>.filled(_size.columns, 0);
    final refill = puzzle.refill;
    if (lesson == null && refill is GuidedRefill) {
      _guidedFill(next, vacancies, refill.supply);
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
      next[cell] = suit;
      falls.add(Fall(suit, column, -arrival - 1, _size.rowOf(cell)));
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
      for (final neighbour in _size.neighbours(cell)) {
        if (next[neighbour] == null) continue;
        next[cell] = next[neighbour];
        return;
      }
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
        if (puzzle.targets[_size.aimOf([cell, neighbour])]?.suit == suit) {
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
    for (var cell = 0; cell < _size.cellCount; cell++) {
      final suit = layout[cell];
      if (suit != null &&
          _size.neighbours(cell).any((next) => layout[next] == suit)) {
        return true;
      }
    }
    for (var top = 0; top < _size.rows - 1; top++) {
      for (var bottom = top + 1; bottom < _size.rows; bottom++) {
        for (var left = 0; left < _size.columns - 1; left++) {
          for (var right = left + 1; right < _size.columns; right++) {
            final corners = [
              top * _size.columns + left,
              top * _size.columns + right,
              bottom * _size.columns + right,
              bottom * _size.columns + left,
            ];
            if (_cornerSuit(layout, corners) != null) return true;
          }
        }
      }
    }
    return false;
  }
}
