import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../artwork.dart';
import '../visuals.dart';
import 'puzzle_deal.dart';
import 'stroke.dart';

const _tile = BoardStyle.tileUnits;
const _grid = _tile * boardSide;

Offset _center(int cell) =>
    Offset((columnOf(cell) + .5) * _tile, (rowOf(cell) + .5) * _tile);

class RidgePainter extends CustomPainter {
  const RidgePainter({
    required this.artwork,
    required this.light,
    required this.walk,
  });

  final Artwork artwork;
  final double light;
  final double walk;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / SceneLayout.width,
      size.height / SceneLayout.height,
    );
    canvas.clipRect(
      const Rect.fromLTWH(0, 0, SceneLayout.width, SceneLayout.height),
    );
    artwork.paint(canvas, Art.ridge);
    final points = SceneLayout.ridgeTrail;
    final trail = _path(points);
    final metric = trail.computeMetrics().single;
    final revealed = light * metric.length;
    if (light == 1) {
      canvas.drawPath(trail, _pen(paleGold, 3));
    } else {
      for (var index = 0.0; index < metric.length; index += 13) {
        final end = math.min(index + 7.5, metric.length);
        canvas.drawPath(
          metric.extractPath(index, end),
          _pen(const Color(0xFF96886B), 2),
        );
        if (index < revealed) {
          canvas.drawPath(
            metric.extractPath(index, math.min(end, revealed)),
            _pen(paleGold, 3),
          );
        }
      }
    }
    final radius =
        SceneLight.markerRadius +
        (SceneLight.markerFullRadius - SceneLight.markerRadius) *
            math.sqrt(light);
    final center =
        SceneLayout.ridgeMarkerFoot -
        Offset(0, radius * SceneLight.markerFootRatio);
    _sceneGlow(canvas, center, SceneLight.ridgeGlowRadius, light);
    _marker(canvas, artwork, center, radius, light);
    _sceneFlare(canvas, center + Offset(radius * .40, -radius * .48), light);
    final feet = Offset.lerp(points[0], points[1], walk)!;
    final bob =
        math.sin(walk * math.pi * 6).abs() * math.sin(walk * math.pi) * 4;
    artwork.paint(canvas, Art.fool, origin: feet - Offset(0, bob));
    canvas.restore();
  }

  @override
  bool shouldRepaint(RidgePainter oldDelegate) =>
      oldDelegate.artwork != artwork ||
      oldDelegate.light != light ||
      oldDelegate.walk != walk;
}

class QuayPainter extends CustomPainter {
  const QuayPainter({required this.artwork, required this.light});

  final Artwork artwork;
  final double light;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / SceneLayout.width,
      size.height / SceneLayout.height,
    );
    canvas.clipRect(
      const Rect.fromLTWH(0, 0, SceneLayout.width, SceneLayout.height),
    );
    artwork.paint(canvas, Art.quaySky);
    if (light > 0) _paintReflection(canvas);
    artwork.paint(canvas, Art.quayPier);
    final scale =
        SceneLight.lampScale +
        (SceneLight.lampFullScale - SceneLight.lampScale) * math.sqrt(light);
    final center =
        SceneLayout.quayLampFoot - Offset(0, SceneLight.lampFootOffset * scale);
    _sceneGlow(canvas, center, SceneLight.quayGlowRadius, light);
    _lantern(canvas, artwork, center, scale, light);
    _sceneFlare(canvas, center + Offset(8 * scale, -3 * scale), light);
    artwork.paint(canvas, Art.fool, origin: SceneLayout.quayFool, scale: .92);

    artwork.paint(canvas, Art.mooredBoat, origin: SceneLayout.quayMooring);
    canvas.restore();
  }

  void _paintReflection(Canvas canvas) {
    final reflection = Paint()..color = paleGold.withValues(alpha: .63 * light);
    for (var i = 0; i < 6; i++) {
      final run = (16 + i * 14) * light;
      final y = 81.0 + i * 5;
      final x = 287 + i * 12 * light;
      canvas.drawRect(Rect.fromLTWH(x, y, run, 2), reflection);
    }
  }

  @override
  bool shouldRepaint(QuayPainter oldDelegate) =>
      oldDelegate.artwork != artwork || oldDelegate.light != light;
}

void _sceneGlow(Canvas canvas, Offset center, double fullRadius, double light) {
  if (light == 0) return;
  final reach = math.sqrt(light);
  final radius = fullRadius * reach;
  final shader = RadialGradient(
    colors: [
      paleGold.withValues(alpha: .95 * light),
      gold.withValues(alpha: .56 * light),
      gold.withValues(alpha: 0),
    ],
    stops: SceneLight.glowStops,
  ).createShader(Rect.fromCircle(center: center, radius: radius));
  canvas.drawCircle(center, radius, Paint()..shader = shader);
}

void _sceneFlare(Canvas canvas, Offset center, double light) {
  if (light <= SceneLight.flareThreshold) return;
  final strength =
      (light - SceneLight.flareThreshold) / (1 - SceneLight.flareThreshold);
  final reach = SceneLight.flareFullRadius * strength;
  final core = reach * .20;
  canvas.save();
  canvas.translate(center.dx, center.dy);
  _polygon(canvas, [
    0,
    -reach,
    core,
    -core,
    reach,
    0,
    core,
    core,
    0,
    reach,
    -core,
    core,
    -reach,
    0,
    -core,
    -core,
  ], paper.withValues(alpha: strength));
  canvas.restore();
}

class TableauPainter extends CustomPainter {
  TableauPainter({
    required this.board,
    required this.artwork,
    required this.puzzle,
    required this.path,
    required this.preview,
    required this.demonstration,
    required this.guideTime,
    required this.light,
    this.turn,
    this.turnProgress = 1,
    this.fadeProgress = 1,
    this.keyboardCell,
    this.reducedMotion = false,
    this.rejected = false,
  });

  final List<Suit?> board;
  final Artwork artwork;
  final PuzzleDefinition puzzle;
  final List<int> path;
  final Stroke? preview;
  final Stroke? demonstration;
  final double guideTime;
  final double light;
  final Turn? turn;
  final double turnProgress;
  final double fadeProgress;
  final int? keyboardCell;
  final bool reducedMotion;
  final bool rejected;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _grid, size.height / _grid);
    canvas.clipRect(const Rect.fromLTWH(0, 0, _grid, _grid));
    final activeTurn = turn;
    for (var cell = 0; cell < cellCount; cell++) {
      final color = cell == puzzle.marker
          ? const Color(0xFFDDCCA3)
          : (rowOf(cell) + columnOf(cell)).isEven
          ? paper
          : parchment;
      _rect(
        canvas,
        columnOf(cell) * _tile,
        rowOf(cell) * _tile,
        _tile,
        _tile,
        color,
      );
    }
    for (var i = 1; i < boardSide; i++) {
      final x = i * _tile;
      canvas.drawLine(Offset(x, 0), Offset(x, _grid), _pen(rule, .9));
      canvas.drawLine(Offset(0, x), Offset(_grid, x), _pen(rule, .9));
    }

    if (activeTurn == null) {
      for (var cell = 0; cell < board.length; cell++) {
        final suit = board[cell];
        if (suit != null) {
          artwork.paint(canvas, _suitArt(suit), origin: _center(cell));
        }
      }
    } else {
      _paintFall(canvas, activeTurn);
    }
    // The receiver sits in front of the pieces that pass through its row.
    final fixtureCenter = _center(puzzle.marker) - const Offset(0, 7);
    if (puzzle.scene == PuzzleScene.quay) {
      _lantern(canvas, artwork, fixtureCenter, 1, light);
    } else {
      _marker(canvas, artwork, fixtureCenter, 24, light);
    }
    if (fadeProgress < 1) {
      final strength = 1 - Curves.easeOut.transform(fadeProgress);
      canvas.drawCircle(
        fixtureCenter,
        BoardStyle.fadeHaloRadius + BoardStyle.fadeHaloTravel * strength,
        _pen(
          gold.withValues(alpha: strength * BoardStyle.fadeHaloOpacity),
          BoardStyle.fadeHaloStroke,
        ),
      );
    }
    if (activeTurn == null) {
      if (demonstration != null && path.isEmpty) {
        _paintDemonstration(canvas, demonstration!);
      }
      if (path.isNotEmpty) {
        _paintStroke(canvas, preview?.path ?? path, rejected ? rust : blue, 5);
        final stroke = preview;
        if (stroke != null && !stroke.isRectangle) {
          _paintAim(canvas, stroke, blue);
        }
      }
    }
    if (keyboardCell != null) {
      canvas.drawRect(
        Rect.fromCenter(center: _center(keyboardCell!), width: 92, height: 92),
        _pen(blue, 4),
      );
    }
    canvas.restore();
  }

  void _paintFall(Canvas canvas, Turn turn) {
    const release = BoardMotion.releaseFraction;
    if (turnProgress < release) {
      final dissolve = turnProgress / release;
      final rectangle = turn.stroke.isRectangle;
      for (var cell = 0; cell < turn.before.length; cell++) {
        final suit = turn.before[cell];
        if (suit == null) continue;
        if (turn.stroke.cleared.contains(cell)) {
          final size = 1 - .57 * dissolve;
          artwork.paint(
            canvas,
            _suitArt(suit),
            origin: _center(cell),
            scale: size,
            opacity: 1 - dissolve,
          );
          if (!rectangle || turn.stroke.path.contains(cell)) {
            canvas.drawCircle(
              _center(cell),
              22 + dissolve * 15,
              _pen(gold.withValues(alpha: 1 - dissolve), 2.4),
            );
          }
        } else {
          artwork.paint(canvas, _suitArt(suit), origin: _center(cell));
        }
      }
      if (turn.stroke.light > 0 && !turn.stroke.isRectangle) {
        final point = Offset.lerp(
          _center(turn.stroke.path.last),
          _center(puzzle.marker),
          dissolve,
        )!;
        if (puzzle.scoringSuit == Suit.cup) {
          artwork.paint(canvas, Art.oilDrop, origin: point);
        } else {
          canvas.drawCircle(point, 12, Paint()..color = paleGold);
        }
      }
      return;
    }
    final t = (turnProgress - release) / (1 - release);
    final eased = 1 - math.pow(1 - t, 2).toDouble();
    for (final tile in turn.falls) {
      final point = Offset(
        (tile.column + .5) * _tile,
        (tile.fromRow + (tile.toRow - tile.fromRow) * eased + .5) * _tile,
      );
      artwork.paint(canvas, _suitArt(tile.suit), origin: point);
    }
  }

  void _paintDemonstration(Canvas canvas, Stroke clue) {
    final points = clue.path.map(_center).toList();
    final guide = _path(points);
    final metric = guide.computeMetrics().single;
    final guideInk = _pen(blue.withValues(alpha: .68), 4);
    for (var index = 0.0; index < metric.length; index += 20) {
      canvas.drawPath(
        metric.extractPath(index, math.min(index + 10, metric.length)),
        guideInk,
      );
    }
    final corners = clue.isRectangle
        ? points.take(points.length - 1)
        : [points.first, points.last];
    for (final corner in corners) {
      canvas.drawCircle(corner, 35, _pen(blue.withValues(alpha: .55), 2.6));
    }
    final progress = reducedMotion
        ? 0.0
        : ((guideTime - BoardMotion.guideLead) /
                  ((points.length - 1) * BoardMotion.guideStep))
              .clamp(0.0, 1.0);
    final segment = math.min(
      points.length - 2,
      (progress * (points.length - 1)).floor(),
    );
    final tip = Offset.lerp(
      points[segment],
      points[segment + 1],
      progress * (points.length - 1) - segment,
    )!;
    final active = _path([...points.take(segment + 1), tip]);
    canvas.drawPath(active, _pen(blue, 6));
    if (!clue.isRectangle && clue.light > 0) {
      _paintAim(canvas, clue, rust);
    } else if (!clue.isRectangle || reducedMotion) {
      _arrow(canvas, points[points.length - 2], points.last, blue, .5);
    }
    _hand(canvas, artwork, tip);
  }

  void _paintStroke(Canvas canvas, List<int> cells, Color color, double width) {
    final points = cells.map(_center).toList();
    final outline = _path(points);
    canvas.drawPath(outline, _pen(paper, width + 5));
    canvas.drawPath(outline, _pen(color, width));
    for (final point in points) {
      canvas.drawCircle(point, 29, _pen(paper, 6));
      canvas.drawCircle(point, 29, _pen(color, 3));
    }
  }

  void _paintAim(Canvas canvas, Stroke stroke, Color color) {
    final aim = aimOf(stroke.path);
    if (aim != null) {
      _arrow(canvas, _center(stroke.path.last), _center(aim), color, .68);
    }
  }

  @override
  bool shouldRepaint(TableauPainter oldDelegate) => true;
}

class SuitPainter extends CustomPainter {
  const SuitPainter(this.artwork, this.suit);

  final Artwork artwork;
  final Suit suit;

  @override
  void paint(Canvas canvas, Size size) {
    artwork.paint(
      canvas,
      _suitArt(suit),
      origin: size.center(Offset.zero),
      scale: size.shortestSide / 60,
    );
  }

  @override
  bool shouldRepaint(SuitPainter oldDelegate) =>
      artwork != oldDelegate.artwork || suit != oldDelegate.suit;
}

Art _suitArt(Suit suit) => switch (suit) {
  Suit.wand => Art.wand,
  Suit.cup => Art.cup,
  Suit.sword => Art.sword,
  Suit.coin => Art.coin,
};

void _marker(
  Canvas canvas,
  Artwork artwork,
  Offset point,
  double radius,
  double fraction,
) {
  canvas.save();
  canvas.translate(point.dx, point.dy);
  canvas.scale(radius / 24);
  artwork.paint(canvas, Art.marker);
  canvas.save();
  canvas.clipPath(
    Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: 20)),
  );
  _rect(canvas, -20, 20 - fraction * 40, 40, fraction * 40, paleGold);
  canvas.restore();
  _polygon(canvas, [
    0,
    -10,
    10,
    0,
    0,
    10,
    -10,
    0,
  ], fraction > .72 ? ink : paper);
  canvas.restore();
}

void _lantern(
  Canvas canvas,
  Artwork artwork,
  Offset center,
  double scale,
  double light,
) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.scale(scale);
  if (light > 0) {
    canvas.drawCircle(
      Offset.zero,
      24,
      Paint()..color = gold.withValues(alpha: .2 * light),
    );
  }
  artwork.paint(canvas, Art.lantern);
  _polygon(canvas, [
    -12,
    13 - 22 * light,
    12,
    13 - 22 * light,
    10,
    13,
    -10,
    13,
  ], paleGold);
  canvas.drawLine(const Offset(0, -8), const Offset(0, 14), _pen(ink, 2));
  canvas.restore();
}

void _hand(Canvas canvas, Artwork artwork, Offset tip) {
  // Keep the pointer inside the frame at bottom-edge and right-edge cells.
  canvas.save();
  canvas.translate(tip.dx, tip.dy);
  if (tip.dx > _grid - 60) canvas.scale(-1, 1);
  if (tip.dy > _grid - 60) canvas.scale(1, -1);
  canvas.scale(.80);
  artwork.paint(canvas, Art.hand, origin: const Offset(2, 3), opacity: .24);
  artwork.paint(canvas, Art.hand);
  canvas.restore();
}

void _arrow(Canvas canvas, Offset a, Offset b, Color color, double fraction) {
  final direction = (b - a) / (b - a).distance;
  final normal = Offset(-direction.dy, direction.dx);
  final tip = Offset.lerp(a, b, fraction)!;
  final stem = tip - direction * 21;
  final back = tip - direction * 10;
  canvas.drawPath(_path([stem, tip]), _pen(paper, 12));
  canvas.drawPath(
    _path([back + normal * 8, tip, back - normal * 8]),
    _pen(paper, 12),
  );
  canvas.drawPath(_path([stem, tip]), _pen(color, 5));
  canvas.drawPath(
    _path([back + normal * 8, tip, back - normal * 8]),
    _pen(color, 5),
  );
}

Paint _pen(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

Path _path(List<Offset> points) => Path()..addPolygon(points, false);

void _rect(Canvas canvas, double x, double y, double w, double h, Color color) {
  canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = color);
}

void _polygon(Canvas canvas, List<double> coordinates, Color color) {
  final path = Path()
    ..addPolygon([
      for (var i = 0; i < coordinates.length; i += 2)
        Offset(coordinates[i], coordinates[i + 1]),
    ], true);
  canvas.drawPath(path, Paint()..color = color);
}
