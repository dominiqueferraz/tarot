import 'dart:convert';

import 'stroke.dart';

enum Suit {
  wand('W'),
  cup('C'),
  sword('S'),
  coin('O');

  const Suit(this.symbol);
  final String symbol;

  static Suit read(String symbol) =>
      _named(values, symbol, (suit) => suit.symbol, 'suit');
}

enum PuzzleScene {
  ridge,
  quay,
  mill,
  dock,
  market,
  breadStall,
  sluice,
  lampPath,
  fishingLanding,
  nightFishing,
  brokenRoad,
  drawbridge;

  bool get hasWaterGaps => this == brokenRoad || this == drawbridge;
}

enum PuzzleTextKey {
  foolsStep,
  lamplighter,
  highWater,
  mooring,
  ferrymansFare,
  marketDay,
  fairSplit,
  fromBehind,
  keepMeAPartner,
  nightFishing,
  brokenRoad,
  drawbridge,
}

enum TargetKind { marker, lantern, inlet, cord, pan, bell }

enum TargetLabel {
  trailMarker(TargetKind.marker),
  quayLamp(TargetKind.lantern),
  millInlet(TargetKind.inlet),
  bowCord(TargetKind.cord),
  sternCord(TargetKind.cord),
  westPan(TargetKind.pan),
  eastPan(TargetKind.pan),
  marketLamp(TargetKind.lantern),
  marketInlet(TargetKind.inlet),
  paymentPan(TargetKind.pan),
  westFloat(TargetKind.inlet),
  eastFloat(TargetKind.inlet),
  westFacingLamp(TargetKind.lantern),
  landingBasin(TargetKind.inlet),
  harbourLamp(TargetKind.lantern),
  mooringCord(TargetKind.cord),
  farBankBell(TargetKind.bell),
  drawbridgeInlet(TargetKind.inlet);

  const TargetLabel(this.defaultKind);

  final TargetKind defaultKind;
}

enum PuzzleDifficulty { normal, hard, superHard }

enum GuideCue {
  match,
  square,
  rectangle,
  enclose,
  aim,
  wildcard,
  linkSquare,
  linkedAim,
}

enum HintTail { top, right, bottom }

typedef HintPlacement = ({double x, double y, HintTail tail});

class GuideMove {
  const GuideMove(this.cue, this.path, this.hint, this.arrivals);

  final GuideCue cue;
  final List<int> path;
  final HintPlacement hint;
  final List<List<Suit>> arrivals;

  factory GuideMove._read(Map<String, Object?> data, BoardSize size) {
    final cue = _field<String>(data, 'cue');
    final route = _field<String>(data, 'path').trim().split(RegExp(r'\s+'));
    final hint = _field<List<Object?>>(data, 'hint');
    if (route.length < 2 ||
        hint.length != 3 ||
        hint[0] is! num ||
        hint[1] is! num ||
        hint[2] is! String) {
      throw const FormatException(
        'A guide needs a path and a hint [x, y, tail].',
      );
    }
    final x = (hint[0] as num).toDouble();
    final y = (hint[1] as num).toDouble();
    if (x <= 0 || x >= size.columns || y <= 0 || y >= size.rows) {
      throw const FormatException(
        'Guide hint coordinates must be inside the board.',
      );
    }
    return GuideMove(
      _named(GuideCue.values, cue, (value) => value.name, 'guide cue'),
      List.unmodifiable(route.map(size.parseCell)),
      (
        x: x,
        y: y,
        tail: _named(
          HintTail.values,
          hint[2] as String,
          (value) => value.name,
          'hint tail',
        ),
      ),
      _columns(
        _field<List<Object?>>(data, 'arrivals'),
        size.columns,
        allowEmpty: true,
      ),
    );
  }
}

sealed class Refill {
  const Refill();

  factory Refill._read(Map<String, Object?> data, int width) {
    return switch (_field<String>(data, 'type')) {
      'ribbons' => RibbonRefill(
        _columns(_field<List<Object?>>(data, 'columns'), width),
      ),
      'guided' => GuidedRefill(
        _field<int>(data, 'seed'),
        List.unmodifiable([
          for (final entry in _field<Map<String, Object?>>(
            data,
            'weights',
          ).entries)
            ...List<Suit>.filled(
              _boundedInt(entry.value, 1, 32, 'suit weight'),
              Suit.read(entry.key),
            ),
        ]),
      ),
      final type => throw FormatException('Unknown refill type: $type.'),
    };
  }
}

class RibbonRefill extends Refill {
  const RibbonRefill(this.columns);
  final List<List<Suit>> columns;
}

class GuidedRefill extends Refill {
  GuidedRefill(this.seed, this.supply) {
    if (supply.isEmpty) {
      throw const FormatException('Guided refill needs suit weights.');
    }
  }
  final int seed;
  final List<Suit> supply;
}

class PuzzleRules {
  PuzzleRules._read(Map<String, Object?> data)
    : shapeProgress = _boundedInt(
        data['shapeProgress'],
        1,
        99,
        'shapeProgress',
      ),
      cornerProgressPerPiece = _boundedInt(
        data['cornerProgressPerPiece'],
        1,
        99,
        'cornerProgressPerPiece',
      ),
      refillSamples = _boundedInt(
        data['refillSamples'],
        1,
        32,
        'refillSamples',
      ),
      refillLowerRow = _boundedInt(
        data['refillLowerRow'],
        1,
        _refillReferenceRows,
        'refillLowerRow',
      ),
      refillLowerPairWeight = _boundedInt(
        data['refillLowerPairWeight'],
        0,
        99,
        'refillLowerPairWeight',
      ),
      refillOtherPairWeight = _boundedInt(
        data['refillOtherPairWeight'],
        0,
        99,
        'refillOtherPairWeight',
      ),
      refillAimWeight = _boundedInt(
        data['refillAimWeight'],
        0,
        99,
        'refillAimWeight',
      );

  final int shapeProgress;
  final int cornerProgressPerPiece;
  final int refillSamples;
  final int refillLowerRow;
  final int refillLowerPairWeight;
  final int refillOtherPairWeight;
  final int refillAimWeight;

  static const _refillReferenceRows = 6;

  int firstLowerRow(BoardSize size) =>
      (refillLowerRow - 1) * size.rows ~/ _refillReferenceRows;
}

class PuzzleTarget {
  const PuzzleTarget(
    this.suit,
    this.quota,
    this.fading,
    this.label,
    this.kind, {
    this.aimDirection,
  });

  final Suit suit;
  final int quota;
  final int fading;
  final TargetLabel label;
  final TargetKind kind;
  final BoardDirection? aimDirection;
}

class LeapFinish {
  const LeapFinish._({
    required this.target,
    required this.startAt,
    required this.skip,
    required this.path,
    required this.arrivals,
    required this.hint,
  });

  final int target;
  final int startAt;
  final int skip;
  final List<int> path;
  final Map<int, Suit> arrivals;
  final HintPlacement hint;

  factory LeapFinish._read(
    Map<String, Object?> data,
    BoardSize size,
    Map<int, PuzzleTarget> targets,
    Set<int> masked,
  ) {
    final target = size.parseCell(_field<String>(data, 'target'));
    final marker = targets[target];
    if (marker == null || marker.fading != 0) {
      throw const FormatException(
        'A Leap finish needs a fixed, non-fading target.',
      );
    }
    final startAt = _boundedInt(
      data['startAt'],
      1,
      marker.quota - 2,
      'finish progress',
    );
    final route = _field<String>(data, 'path').trim().split(RegExp(r'\s+'));
    final path = route.map(size.parseCell).toList();
    if (path.length < marker.quota - startAt ||
        path.toSet().length != path.length ||
        path.any(
          (cell) => masked.contains(cell) || targets.containsKey(cell),
        ) ||
        size.aimOf(path) != target) {
      throw const FormatException(
        'The Leap finish path must reach its target.',
      );
    }
    int? skip;
    for (var i = 1; i < path.length; i++) {
      if (size.neighbours(path[i - 1]).contains(path[i])) continue;
      final gap = size.jumpOver(path[i - 1], path[i]);
      if (gap == null || skip != null) {
        throw const FormatException('A Leap finish must use one jump.');
      }
      skip = gap;
    }
    final direction = marker.aimDirection;
    if (skip == null ||
        path.contains(skip) ||
        (direction != null &&
            !size.aimsAlong(path[path.length - 2], path.last, direction))) {
      throw const FormatException('A Leap finish needs a valid jump and aim.');
    }
    final blockedSuit = data['skipSuit'];
    if (!masked.contains(skip) &&
        (targets.containsKey(skip) ||
            blockedSuit is! String ||
            Suit.read(blockedSuit) == marker.suit)) {
      throw const FormatException('The jumped cell needs a different suit.');
    }
    return LeapFinish._(
      target: target,
      startAt: startAt,
      skip: skip,
      path: List.unmodifiable(path),
      arrivals: Map.unmodifiable({
        for (final cell in path) cell: marker.suit,
        if (!masked.contains(skip)) skip: Suit.read(blockedSuit as String),
      }),
      hint: (
        x: size.columnOf(skip) + .5,
        y: size.rowOf(skip) + 1.03,
        tail: HintTail.top,
      ),
    );
  }
}

class PuzzleDefinition {
  const PuzzleDefinition._({
    required this.id,
    required this.scene,
    required this.textKey,
    required this.size,
    required this.opening,
    required this.targets,
    required this.masked,
    required this.linksTargets,
    required this.fillTogether,
    required this.scoringSuits,
    required this.limit,
    required this.difficulty,
    required this.par,
    required this.refill,
    required this.guide,
    required this.leapFinish,
    required this.rules,
  });

  final String id;
  final PuzzleScene scene;
  final PuzzleTextKey textKey;
  final BoardSize size;
  final List<Suit?> opening;
  final Map<int, PuzzleTarget> targets;
  final Set<int> masked;
  final bool linksTargets;
  final bool fillTogether;
  final Set<Suit> scoringSuits;
  final int limit;
  final PuzzleDifficulty difficulty;
  final int par;
  final Refill refill;
  final List<GuideMove> guide;
  final LeapFinish? leapFinish;
  final PuzzleRules rules;

  bool holdsPiece(int cell) =>
      !targets.containsKey(cell) && !masked.contains(cell);

  factory PuzzleDefinition._read(Map<String, Object?> data, PuzzleRules rules) {
    final id = _field<String>(data, 'id');
    final scene = _field<String>(data, 'scene');
    final difficulty = data.containsKey('difficulty')
        ? _field<String>(data, 'difficulty')
        : 'normal';
    final rows = _field<List<Object?>>(data, 'board');
    final firstRow = rows.firstOrNull;
    if (firstRow is! String ||
        firstRow.isEmpty ||
        rows.any((row) => row is! String || row.length != firstRow.length)) {
      throw const FormatException(
        'The board needs nonempty rows of equal width.',
      );
    }
    final size = BoardSize(firstRow.length, rows.length);
    final symbols = rows.join().split('');
    final entries = data.containsKey('targets')
        ? _field<List<Object?>>(
            data,
            'targets',
          ).map((value) => _object(value, 'target'))
        : [_field<Map<String, Object?>>(data, 'target')];
    final targets = <int, PuzzleTarget>{};
    for (final entry in entries) {
      final cell = size.parseCell(_field<String>(entry, 'cell'));
      if (symbols[cell] != 'L' || targets.containsKey(cell)) {
        throw const FormatException('Each L needs exactly one target.');
      }
      final label = _named(
        TargetLabel.values,
        _field<String>(entry, 'label'),
        (value) => value.name,
        'target label',
      );
      targets[cell] = PuzzleTarget(
        Suit.read(_field<String>(entry, 'suit')),
        _boundedInt(entry['quota'] ?? entry['light'], 1, 999, 'target.quota'),
        _boundedInt(entry['fade'] ?? 0, 0, 999, 'target.fade'),
        label,
        entry.containsKey('kind')
            ? _named(
                TargetKind.values,
                _field<String>(entry, 'kind'),
                (value) => value.name,
                'target kind',
              )
            : label.defaultKind,
        aimDirection: entry.containsKey('aimDirection')
            ? _named<BoardDirection>(
                BoardDirection.values,
                _field<String>(entry, 'aimDirection'),
                (value) => value.name,
                'target aim direction',
              )
            : null,
      );
    }
    if (targets.isEmpty ||
        symbols.where((value) => value == 'L').length != targets.length) {
      throw const FormatException(
        'The board needs at least one target and one L per target.',
      );
    }
    final fillTogether =
        data.containsKey('fillTogether') && _field<bool>(data, 'fillTogether');
    if (fillTogether && targets.length != 2) {
      throw const FormatException('Filling together requires two targets.');
    }
    final masked = {
      for (var cell = 0; cell < symbols.length; cell++)
        if (symbols[cell] == '.') cell,
    };
    final moveLimit = _boundedInt(data['moves'], 1, 999, 'moves');
    final guide = data['guide'] == null
        ? const <GuideMove>[]
        : List<GuideMove>.unmodifiable(
            _field<List<Object?>>(
              data,
              'guide',
            ).map((move) => GuideMove._read(_object(move, 'guide move'), size)),
          );
    if (guide.length >= moveLimit) {
      throw const FormatException('The guide must leave free-play moves.');
    }
    final leapFinish = data['leapFinish'] == null
        ? null
        : LeapFinish._read(
            _object(data['leapFinish'], 'leap finish'),
            size,
            targets,
            masked,
          );
    if (leapFinish != null && (guide.isNotEmpty || targets.length != 1)) {
      throw const FormatException(
        'A Leap finish needs one target and free play.',
      );
    }
    return PuzzleDefinition._(
      id: id,
      scene: _named(PuzzleScene.values, scene, (value) => value.name, 'scene'),
      textKey: _named(
        PuzzleTextKey.values,
        _field<String>(data, 'textKey'),
        (value) => value.name,
        'puzzle text key',
      ),
      size: size,
      opening: List.unmodifiable([
        for (var cell = 0; cell < symbols.length; cell++)
          if (targets.containsKey(cell) || masked.contains(cell))
            null
          else
            Suit.read(symbols[cell]),
      ]),
      targets: Map.unmodifiable(targets),
      masked: Set.unmodifiable(masked),
      linksTargets:
          data.containsKey('linksTargets') &&
          _field<bool>(data, 'linksTargets'),
      fillTogether: fillTogether,
      scoringSuits: Set.unmodifiable(
        targets.values.map((target) => target.suit),
      ),
      limit: moveLimit,
      difficulty: _named(
        PuzzleDifficulty.values,
        difficulty,
        (value) => value.name,
        'difficulty',
      ),
      par: _boundedInt(data['par'], 1, moveLimit, 'par'),
      refill: Refill._read(
        _field<Map<String, Object?>>(data, 'refill'),
        size.columns,
      ),
      guide: guide,
      leapFinish: leapFinish,
      rules: rules,
    );
  }
}

class PuzzleCatalog {
  const PuzzleCatalog._(this.puzzles);

  static const assetPath = 'assets/puzzles/fool.json';
  static const _clearedPrefix = 'cleared:';
  final List<PuzzleDefinition> puzzles;

  factory PuzzleCatalog.parse(String source) {
    final data = _object(jsonDecode(source), 'catalog');
    if (data['version'] != 2) {
      throw const FormatException('Unknown puzzle format version.');
    }
    final rules = PuzzleRules._read(
      _field<Map<String, Object?>>(data, 'rules'),
    );
    final puzzles = <PuzzleDefinition>[];
    final ids = <String>{};
    for (final entry in _field<List<Object?>>(data, 'puzzles')) {
      final definition = _object(entry, 'puzzle');
      try {
        final puzzle = PuzzleDefinition._read(definition, rules);
        if (puzzle.id.isEmpty || !ids.add(puzzle.id)) {
          throw const FormatException(
            'Puzzle IDs must be unique and nonempty.',
          );
        }
        puzzles.add(puzzle);
      } on FormatException catch (error) {
        throw FormatException('Puzzle ${definition['id']}: ${error.message}');
      }
    }
    if (puzzles.isEmpty) {
      throw const FormatException('The catalog needs a puzzle.');
    }
    return PuzzleCatalog._(List.unmodifiable(puzzles));
  }

  PuzzleDefinition? next(PuzzleDefinition puzzle) {
    final index = puzzles.indexOf(puzzle);
    return index >= 0 && index + 1 < puzzles.length ? puzzles[index + 1] : null;
  }

  String progressAfter(PuzzleDefinition puzzle) =>
      next(puzzle)?.id ?? '$_clearedPrefix${puzzle.id}';

  int unlockedIndex(String? progress) {
    final cleared = progress?.startsWith(_clearedPrefix) ?? false;
    final id = cleared ? progress!.substring(_clearedPrefix.length) : progress;
    final index = puzzles.indexWhere((puzzle) => puzzle.id == id);
    return index < 0 ? 0 : index + (cleared ? 1 : 0);
  }
}

List<List<Suit>> _columns(
  List<Object?> values,
  int width, {
  bool allowEmpty = false,
}) {
  if (values.length != width ||
      values.any(
        (value) => value is! String || (!allowEmpty && value.isEmpty),
      )) {
    throw FormatException('Supply must list $width column strings.');
  }
  return List.unmodifiable([
    for (final column in values.cast<String>())
      List<Suit>.unmodifiable(column.split('').map(Suit.read)),
  ]);
}

T _field<T>(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! T) throw FormatException('Missing or invalid $key.');
  return value;
}

Map<String, Object?> _object(Object? value, String label) {
  if (value is! Map<String, Object?>) {
    throw FormatException('Expected a $label object.');
  }
  return value;
}

int _boundedInt(Object? value, int min, int max, String label) {
  if (value is! int || value < min || value > max) {
    throw FormatException('$label must be an integer between $min and $max.');
  }
  return value;
}

T _named<T>(
  Iterable<T> choices,
  String name,
  String Function(T) nameOf,
  String label,
) => choices.firstWhere(
  (choice) => nameOf(choice) == name,
  orElse: () => throw FormatException('Unknown $label: $name.'),
);
