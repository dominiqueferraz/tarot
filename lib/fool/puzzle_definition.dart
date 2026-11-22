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

enum PuzzleScene { ridge, quay }

enum PuzzleDifficulty { normal, hard, superHard }

enum GuideCue { match, square, rectangle, enclose, aim, wildcard }

enum HintTail { top, right, bottom }

typedef HintPlacement = ({double x, double y, HintTail tail});
typedef PuzzleWords = ({String title, String objective, String target});

class GuideMove {
  const GuideMove(this.cue, this.path, this.hint, this.arrivals);

  final GuideCue cue;
  final List<int> path;
  final HintPlacement hint;
  final List<List<Suit>> arrivals;

  factory GuideMove._read(Map<String, Object?> data) {
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
    if (x <= 0 || x >= boardSide || y <= 0 || y >= boardSide) {
      throw const FormatException(
        'Guide hint coordinates must be inside the board.',
      );
    }
    return GuideMove(
      _named(GuideCue.values, cue, (value) => value.name, 'guide cue'),
      List.unmodifiable(route.map(_cell)),
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
      _columns(_field<List<Object?>>(data, 'arrivals'), allowEmpty: true),
    );
  }
}

sealed class Refill {
  const Refill();

  factory Refill._read(Map<String, Object?> data) {
    return switch (_field<String>(data, 'type')) {
      'ribbons' => RibbonRefill(
        _columns(_field<List<Object?>>(data, 'columns')),
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
        boardSide,
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
}

class PuzzleDefinition {
  const PuzzleDefinition._({
    required this.id,
    required this.scene,
    required this.text,
    required this.opening,
    required this.marker,
    required this.target,
    required this.scoringSuit,
    required this.fading,
    required this.limit,
    required this.difficulty,
    required this.par,
    required this.refill,
    required this.guide,
    required this.rules,
  });

  final String id;
  final PuzzleScene scene;
  final Map<String, PuzzleWords> text;
  final List<Suit?> opening;
  final int marker;
  final int target;
  final Suit scoringSuit;
  final int fading;
  final int limit;
  final PuzzleDifficulty difficulty;
  final int par;
  final Refill refill;
  final List<GuideMove> guide;
  final PuzzleRules rules;

  PuzzleWords words(String language) => text[language] ?? text['en']!;

  factory PuzzleDefinition._read(Map<String, Object?> data, PuzzleRules rules) {
    final id = _field<String>(data, 'id');
    final scene = _field<String>(data, 'scene');
    final difficulty = data.containsKey('difficulty')
        ? _field<String>(data, 'difficulty')
        : 'normal';
    final rows = _field<List<Object?>>(data, 'board');
    final target = _field<Map<String, Object?>>(data, 'target');
    final marker = _cell(_field<String>(target, 'cell'));
    if (rows.length != boardSide ||
        rows.any((row) => row is! String || row.length != boardSide)) {
      throw const FormatException(
        'The board must have six rows of six symbols.',
      );
    }
    final symbols = rows.join().split('');
    if (symbols[marker] != 'L' ||
        symbols.where((symbol) => symbol == 'L').length != 1) {
      throw const FormatException('The board needs one L at the target cell.');
    }
    final text = _field<Map<String, Object?>>(data, 'text');
    final moveLimit = _boundedInt(data['moves'], 1, 999, 'moves');
    final guide = data['guide'] == null
        ? const <GuideMove>[]
        : List<GuideMove>.unmodifiable(
            _field<List<Object?>>(
              data,
              'guide',
            ).map((move) => GuideMove._read(_object(move, 'guide move'))),
          );
    if (guide.length >= moveLimit) {
      throw const FormatException('The guide must leave free-play moves.');
    }
    return PuzzleDefinition._(
      id: id,
      scene: _named(PuzzleScene.values, scene, (value) => value.name, 'scene'),
      text: Map.unmodifiable({
        for (final language in ['en', 'pt', 'es'])
          language: _words(_field<Map<String, Object?>>(text, language)),
      }),
      opening: List.unmodifiable(
        symbols.map((symbol) => symbol == 'L' ? null : Suit.read(symbol)),
      ),
      marker: marker,
      target: _boundedInt(target['light'], 1, 999, 'target.light'),
      scoringSuit: Suit.read(_field<String>(target, 'suit')),
      fading: _boundedInt(target['fade'] ?? 0, 0, 999, 'target.fade'),
      limit: moveLimit,
      difficulty: _named(
        PuzzleDifficulty.values,
        difficulty,
        (value) => value.name,
        'difficulty',
      ),
      par: _boundedInt(data['par'], 1, moveLimit, 'par'),
      refill: Refill._read(_field<Map<String, Object?>>(data, 'refill')),
      guide: guide,
      rules: rules,
    );
  }
}

class PuzzleCatalog {
  const PuzzleCatalog._(this.puzzles);

  static const assetPath = 'assets/puzzles/fool.json';
  final List<PuzzleDefinition> puzzles;

  factory PuzzleCatalog.parse(String source) {
    final data = _object(jsonDecode(source), 'catalog');
    if (data['version'] != 1) {
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

  int unlockedIndex(String? id) => puzzles
      .indexWhere((puzzle) => puzzle.id == id)
      .clamp(0, puzzles.length - 1);
}

int _cell(String value) {
  if (!RegExp(r'^[A-F][1-6]$').hasMatch(value)) {
    throw FormatException('Invalid board coordinate: $value.');
  }
  return (int.parse(value[1]) - 1) * boardSide + value.codeUnitAt(0) - 65;
}

List<List<Suit>> _columns(List<Object?> values, {bool allowEmpty = false}) {
  if (values.length != boardSide ||
      values.any(
        (value) => value is! String || (!allowEmpty && value.isEmpty),
      )) {
    throw const FormatException('Supply must list six column strings.');
  }
  return List.unmodifiable([
    for (final column in values.cast<String>())
      List<Suit>.unmodifiable(column.split('').map(Suit.read)),
  ]);
}

PuzzleWords _words(Map<String, Object?> text) => (
  title: _field<String>(text, 'title'),
  objective: _field<String>(text, 'objective'),
  target: _field<String>(text, 'target'),
);

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
