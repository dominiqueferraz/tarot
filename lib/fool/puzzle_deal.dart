import 'dart:math' as math;

import 'puzzle_definition.dart';
import 'puzzle_refill.dart';
import 'stroke_checker.dart';

export 'puzzle_definition.dart';
export 'puzzle_refill.dart' show Fall;
export 'stroke_checker.dart' show Stroke, TargetLink;

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
    if (!_checker.hasLegalStroke(_board)) {
      throw FormatException(
        'Puzzle ${puzzle.id} needs a legal opening stroke.',
      );
    }
  }

  final PuzzleDefinition puzzle;
  List<Suit?> _board;
  late final _checker = StrokeChecker(puzzle);
  late final _refill = PuzzleRefill(puzzle, _checker);
  int _moves = 0;
  Map<int, int> _progress = const {};
  Map<int, int> _faded = const {};
  TargetLink? _link;
  int? _spilledCell;

  List<Suit?> get board => _board;
  TargetLink? get link => _link;
  int get moves => _moves;
  int get movesLeft => puzzle.limit - moves;
  int progressAt(int cell) => _progress[cell] ?? 0;
  Map<int, int> get faded => _faded;
  bool get won => puzzle.targets.entries.every(
    (target) => progressAt(target.key) >= target.value.quota,
  );
  bool get lost => !won && movesLeft == 0;
  int? get spilledCell => _spilledCell;
  bool get finished => won || lost;
  GuideMove? get guide => moves < guideLength ? puzzle.guide[moves] : null;
  int get guideLength => puzzle.guide.length;
  int get stars => !won
      ? 0
      : (moves <= puzzle.par
            ? 3
            : (moves <= (puzzle.par + puzzle.limit + 1) ~/ 2 ? 2 : 1));

  bool get finishingWithLeap {
    final plan = puzzle.leapFinish;
    return plan != null && progressAt(plan.target) >= plan.startAt;
  }

  bool get leapAvailable => finishingWithLeap && !finished;

  int? get leapGap => leapAvailable ? puzzle.leapFinish!.skip : null;

  Stroke? get leapHint =>
      leapAvailable ? inspect(puzzle.leapFinish!.path, leap: true) : null;

  Stroke? inspect(List<int> path, {bool leap = false}) {
    final plan = puzzle.leapFinish;
    final stroke = _checker.inspect(
      board,
      path,
      link: link,
      leapOver: leap ? leapGap : null,
    );
    if (stroke == null || plan == null) return stroke;
    final gain = stroke.gains[plan.target] ?? 0;
    if (stroke.skippedCell != null) {
      return gain >=
              puzzle.targets[plan.target]!.quota - progressAt(plan.target)
          ? stroke
          : null;
    }
    if (gain == 0) return stroke;
    final available = math.max(0, plan.startAt - progressAt(plan.target));
    final allowed = math.min(available, gain);
    return stroke.withGains({if (allowed > 0) plan.target: allowed});
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

  Turn? play(List<int> path, {bool leap = false}) {
    if (finished) return null;
    final stroke = inspect(path, leap: leap);
    final lesson = guide;
    if (stroke == null || (lesson != null && !_matchesGuide(stroke, lesson))) {
      return null;
    }
    final before = board;
    final progressBefore = _progress;
    final linkBefore = _link;
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
    final progress = {
      for (final entry in puzzle.targets.entries)
        entry.key: math.min(
          entry.value.quota,
          progressAt(entry.key) +
              (stroke.gains[entry.key] ?? 0) -
              (_faded[entry.key] ?? 0),
        ),
    };
    _spilledCell = null;
    if (puzzle.fillTogether) {
      final filled = puzzle.targets.entries
          .where((entry) => progress[entry.key] == entry.value.quota)
          .toList();
      if (filled.length == 1) {
        final target = filled.single;
        progress[target.key] = target.value.quota - 1;
        _spilledCell = target.key;
      }
    }
    _progress = Map.unmodifiable(progress);
    final settled = _refill.settle(
      before,
      stroke,
      lesson: lesson,
      keepPlayable: guide == null && !finished,
      arrivals: finishingWithLeap ? puzzle.leapFinish!.arrivals : const {},
    );
    _board = settled.board;
    return Turn(stroke, before, settled.falls, progressBefore, linkBefore);
  }

  Stroke? get demonstration {
    final lesson = guide;
    return lesson == null ? null : inspect(lesson.path);
  }
}
