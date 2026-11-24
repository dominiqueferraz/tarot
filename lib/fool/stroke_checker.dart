import 'dart:math' as math;

import 'puzzle_definition.dart';
import 'stroke.dart';

class Stroke {
  const Stroke(
    this.suit,
    this.path,
    this.cleared,
    this.gains, {
    this.isRectangle = false,
    this.skippedCell,
    this.linkedTargets = const {},
  });

  final Suit suit;
  final List<int> path;
  final Set<int> cleared;
  final Map<int, int> gains;
  int get totalGain => gains.values.fold(0, (total, value) => total + value);
  final bool isRectangle;
  final int? skippedCell;

  Stroke withGains(Map<int, int> next) => Stroke(
    suit,
    path,
    cleared,
    Map.unmodifiable(next),
    isRectangle: isRectangle,
    skippedCell: skippedCell,
    linkedTargets: linkedTargets,
  );
  final Set<int> linkedTargets;
}

class TargetLink {
  const TargetLink(this.cells, this.movesLeft);

  final Set<int> cells;
  final int movesLeft;
}

class StrokeChecker {
  const StrokeChecker(this.puzzle);

  final PuzzleDefinition puzzle;
  BoardSize get _size => puzzle.size;

  Stroke? inspect(
    List<Suit?> board,
    List<int> path, {
    TargetLink? link,
    int? leapOver,
  }) {
    if (path.length < 2 ||
        path.any((cell) => cell < 0 || cell >= _size.cellCount)) {
      return null;
    }
    if (path.first == path.last) {
      final corners = _size.rectangleCorners(path);
      return corners == null ? null : _rectangle(board, corners);
    }
    final suit = board[path.first];
    if (suit == null || path.toSet().length != path.length) return null;
    int? skipped;
    for (var i = 1; i < path.length; i++) {
      if (board[path[i]] != suit) return null;
      if (_size.neighbours(path[i - 1]).contains(path[i])) continue;
      final gap = _size.jumpOver(path[i - 1], path[i]);
      if (gap == null ||
          gap != leapOver ||
          skipped != null ||
          path.contains(gap)) {
        return null;
      }
      skipped = gap;
    }
    final aim = _size.aimOf(path);
    final targets = !acceptsAim(aim, suit, path[path.length - 2], path.last)
        ? const <int>{}
        : (link?.cells.contains(aim) ?? false)
        ? link!.cells
        : {aim!};
    return Stroke(
      suit,
      List.unmodifiable(path),
      path.toSet(),
      Map.unmodifiable({for (final cell in targets) cell: path.length}),
      skippedCell: skipped,
    );
  }

  bool acceptsAim(int? cell, Suit suit, int previous, int end) {
    final target = puzzle.targets[cell];
    if (target == null || target.suit != suit) return false;
    final direction = target.aimDirection;
    return direction == null || _size.aimsAlong(previous, end, direction);
  }

  Suit? _rectangleSuit(List<Suit?> layout, List<int> corners) {
    if (puzzle.masked.any(
      (cell) => _size.onRectanglePerimeter(corners, cell),
    )) {
      return null;
    }
    final suits = corners.map((cell) => layout[cell]).whereType<Suit>().toSet();
    return suits.length == 1 ? suits.single : null;
  }

  Stroke? _rectangle(List<Suit?> board, List<int> corners) {
    final cornerSuit = _rectangleSuit(board, corners);
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
            entry.value.aimDirection == null &&
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

  bool hasLegalStroke(List<Suit?> layout) {
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
            if (_rectangleSuit(layout, corners) != null) return true;
          }
        }
      }
    }
    return false;
  }
}
