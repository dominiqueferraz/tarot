import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals, setEquals;
import 'package:flutter/widgets.dart';

import '../artwork.dart';
import '../visuals.dart';
import 'puzzle_deal.dart';
import 'stroke.dart';

const _tile = BoardStyle.tileUnits;
const _water = Color(0xFF528A8D);
const _waterline = Color(0xFFB6D6C9);

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

class LampPathPainter extends CustomPainter {
  const LampPathPainter({
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
    const trail = SceneLayout.ridgeTrail;
    const lamp = Offset(397, 34);
    final route = _path(trail);
    canvas.drawPath(route, _pen(mutedInk.withValues(alpha: .65), 2));
    if (light > 0) {
      final metric = route.computeMetrics().single;
      canvas.drawPath(
        metric.extractPath(0, light * metric.length),
        _pen(paleGold, 3),
      );
      _sceneGlow(canvas, lamp - const Offset(13, 0), 66, light);
    }
    _lantern(canvas, artwork, lamp, .92, light);
    final steps = walk * (trail.length - 1);
    final index = math.min(steps.floor(), trail.length - 2);
    final feet = Offset.lerp(trail[index], trail[index + 1], steps - index)!;
    artwork.paint(canvas, Art.fool, origin: feet);
    canvas.restore();
  }

  @override
  bool shouldRepaint(LampPathPainter oldDelegate) =>
      oldDelegate.artwork != artwork ||
      oldDelegate.light != light ||
      oldDelegate.walk != walk;
}

class FishingLandingPainter extends CustomPainter {
  const FishingLandingPainter({
    required this.artwork,
    required this.water,
    required this.walk,
  });

  final Artwork artwork;
  final double water;
  final double walk;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / SceneLayout.width,
      size.height / SceneLayout.height,
    );
    _fishingPier(canvas, artwork);
    _lantern(canvas, artwork, const Offset(118, 57), .53, 1);
    _landingBasin(canvas, const Offset(321, 64), 1.65, water);
    artwork.paint(
      canvas,
      Art.fool,
      origin: Offset(185 + 48 * walk, 91),
      scale: .92,
    );
    artwork.paint(
      canvas,
      Art.mooredBoat,
      origin: const Offset(445, 89),
      scale: .76,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(FishingLandingPainter oldDelegate) =>
      oldDelegate.artwork != artwork ||
      oldDelegate.water != water ||
      oldDelegate.walk != walk;
}

class DrawbridgePainter extends CustomPainter {
  const DrawbridgePainter({
    required this.artwork,
    required this.water,
    required this.motion,
  });

  final Artwork artwork;
  final double water;
  final double motion;

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
    _rect(canvas, 0, 72, SceneLayout.width, 38, blue);
    _polygon(canvas, [0, 63, 252, 63, 237, 87, 0, 107], ink);
    _polygon(canvas, [600, 63, 397, 63, 410, 85, 600, 106], ink);
    for (final (x, y) in [(260.0, 92.0), (314.0, 81.0), (349.0, 101.0)]) {
      canvas.drawLine(Offset(x, y), Offset(x + 36, y), _pen(_waterline, 1.4));
    }
    _inlet(canvas, const Offset(480, 56), .85, water, marked: true);
    final walk = Curves.easeInOut.transform(motion);
    artwork.paint(
      canvas,
      Art.fool,
      origin: Offset(206 + 225 * walk, 63),
      scale: .82,
    );
    canvas.save();
    canvas.translate(398, 62);
    canvas.rotate(.41 * (1 - water.clamp(0.0, 1.0)));
    _rect(canvas, -146, -4, 146, 8, gold);
    canvas.drawLine(const Offset(-146, 4), const Offset(0, 4), _pen(ink, 3));
    for (var x = -136.0; x < 0; x += 13) {
      canvas.drawLine(Offset(x, -3), Offset(x, 3), _pen(ink, 1));
    }
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(DrawbridgePainter oldDelegate) =>
      artwork != oldDelegate.artwork ||
      water != oldDelegate.water ||
      motion != oldDelegate.motion;
}

class BrokenRoadPainter extends CustomPainter {
  const BrokenRoadPainter({
    required this.artwork,
    required this.rung,
    required this.motion,
  });

  final Artwork artwork;
  final bool rung;
  final double motion;

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
    _rect(canvas, 0, 67, SceneLayout.width, 43, blue);
    _polygon(canvas, [0, 63, 258, 63, 249, 74, 260, 81, 237, 88, 0, 104], ink);
    _polygon(canvas, [
      600,
      60,
      383,
      60,
      394,
      72,
      381,
      81,
      402,
      88,
      600,
      105,
    ], ink);
    canvas.drawPath(
      _path(const [Offset(0, 63), Offset(258, 63), Offset(249, 74)]),
      _pen(const Color(0xFFB39D73), 3.5),
    );
    canvas.drawPath(
      _path(const [Offset(394, 72), Offset(383, 60), Offset(600, 60)]),
      _pen(const Color(0xFFB39D73), 3.5),
    );
    for (final (x, y, width) in [
      (268.0, 80.0, 30.0),
      (329.0, 90.0, 37.0),
      (243.0, 101.0, 60.0),
      (385.0, 103.0, 50.0),
    ]) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x + width, y),
        _pen(_waterline.withValues(alpha: .55), 1.5),
      );
    }
    final boatX = 361 - 58 * Curves.easeInOut.transform(motion);
    artwork.paint(
      canvas,
      Art.mooredBoat,
      origin: Offset(boatX, 97),
      scale: .72,
    );
    artwork.paint(
      canvas,
      Art.fool,
      origin: Offset(196 + 30 * motion, 62),
      scale: .86,
    );
    canvas.drawLine(const Offset(480, 23), const Offset(480, 60), _pen(ink, 5));
    canvas.drawLine(const Offset(451, 23), const Offset(482, 23), _pen(ink, 5));
    _bell(
      canvas,
      const Offset(451, 45),
      scale: .84,
      rung: rung,
      swing: math.sin(motion * 6 * math.pi) * (1 - motion) * .39,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(BrokenRoadPainter oldDelegate) =>
      artwork != oldDelegate.artwork ||
      rung != oldDelegate.rung ||
      motion != oldDelegate.motion;
}

class NightFishingPainter extends CustomPainter {
  const NightFishingPainter({
    required this.artwork,
    required this.light,
    required this.cut,
    required this.sail,
  });

  final Artwork artwork;
  final double light;
  final double cut;
  final double sail;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / SceneLayout.width,
      size.height / SceneLayout.height,
    );
    _fishingPier(canvas, artwork);
    _landingBasin(canvas, const Offset(307, 64), 1.65, 1);
    artwork.paint(canvas, Art.fool, origin: const Offset(157, 90), scale: .92);

    const lamp = Offset(219, 54);
    _sceneGlow(canvas, lamp, 55, light);
    canvas.drawLine(lamp, const Offset(219, 84), _pen(ink, 4));
    _lantern(canvas, artwork, lamp, .83, light);

    const post = Offset(366, 79);
    final boat = Offset(381 + 118 * Curves.easeInOut.transform(sail), 91);
    canvas.drawLine(
      post - const Offset(0, 7),
      post + const Offset(0, 16),
      _pen(ink, 5),
    );
    final rope = Path()..moveTo(post.dx, post.dy);
    if (cut >= 1) {
      rope.quadraticBezierTo(
        post.dx + 7,
        post.dy + 6,
        post.dx + 4,
        post.dy + 12,
      );
    } else {
      rope.quadraticBezierTo(post.dx + 8, boat.dy + 3, boat.dx + 3, boat.dy);
    }
    canvas.drawPath(rope, _pen(paleGold, 2.9 - 1.5 * cut));

    canvas.translate(boat.dx, boat.dy);
    for (final (x, coat) in [(24.0, rust), (53.0, _water)]) {
      canvas.drawCircle(Offset(x, -21), 4, Paint()..color = paleGold);
      _polygon(canvas, [x - 5, 2, x - 3, -16, x + 4, -16, x + 8, 2], coat);
    }
    _polygon(canvas, [0, -4, 21, 1, 68, 0, 86, -8, 74, 11, 21, 13, 9, 8], ink);
    _polygon(canvas, [
      8,
      0,
      22,
      4,
      67,
      3,
      78,
      -2,
      69,
      8,
      23,
      10,
    ], const Color(0xFF947255));
    canvas.restore();
  }

  @override
  bool shouldRepaint(NightFishingPainter oldDelegate) =>
      oldDelegate.artwork != artwork ||
      oldDelegate.light != light ||
      oldDelegate.cut != cut ||
      oldDelegate.sail != sail;
}

void _fishingPier(Canvas canvas, Artwork artwork) {
  artwork.paint(canvas, Art.quaySky);
  _polygon(canvas, [0, 78, 362, 76, 445, 110, 0, 110], const Color(0xFF877257));
  for (final y in [86.0, 96.0, 106.0]) {
    canvas.drawLine(
      Offset(0, y),
      Offset(359 + (y - 76) * 2.35, y),
      _pen(ink, 1.5),
    );
  }
}

class MillPainter extends CustomPainter {
  const MillPainter({
    required this.artwork,
    required this.water,
    required this.motion,
  });

  final Artwork artwork;
  final double water;
  final double motion;

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
    artwork.paint(canvas, Art.mill);
    final channel = Path()
      ..moveTo(174, 78)
      ..lineTo(279, 84)
      ..lineTo(300, 101)
      ..lineTo(179, 100)
      ..close();
    canvas.drawPath(channel, Paint()..color = const Color(0xFF373E35));
    canvas.save();
    canvas.clipPath(channel);
    if (water > 0) {
      final surface = 100 - 18 * water;
      _rect(canvas, 170, surface, 132, 23, _water);
      canvas.drawLine(
        Offset(173, surface),
        Offset(301, surface),
        _pen(_waterline, 1.5),
      );
    }
    canvas.restore();
    canvas.drawPath(channel, _pen(const Color(0xFFC5AC7E), 2));

    _paintWheel(canvas);
    _inlet(canvas, const Offset(174, 87), .65, water);
    artwork.paint(canvas, Art.fool, origin: const Offset(124, 83), scale: .82);
    canvas.restore();
  }

  void _paintWheel(Canvas canvas) {
    const center = Offset(300, 75);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi * (water / 2 + 2 * motion));
    canvas.drawCircle(
      Offset.zero,
      23,
      Paint()..color = const Color(0xFF42372D),
    );
    canvas.drawCircle(
      Offset.zero,
      19,
      Paint()..color = const Color(0xFF78664C),
    );
    for (var spoke = 0; spoke < 8; spoke++) {
      canvas.drawLine(const Offset(0, 0), const Offset(0, -18), _pen(ink, 2));
      canvas.drawLine(
        const Offset(-4, -21),
        const Offset(4, -21),
        _pen(const Color(0xFFD4B781), 2),
      );
      canvas.rotate(math.pi / 4);
    }
    canvas.drawCircle(Offset.zero, 5, Paint()..color = ink);
    canvas.drawCircle(Offset.zero, 2, Paint()..color = const Color(0xFFD4B781));
    canvas.restore();
  }

  @override
  bool shouldRepaint(MillPainter oldDelegate) =>
      oldDelegate.artwork != artwork ||
      oldDelegate.water != water ||
      oldDelegate.motion != motion;
}

class DockPainter extends CustomPainter {
  const DockPainter({
    required this.artwork,
    required this.bow,
    required this.stern,
    required this.motion,
  });

  final Artwork artwork;
  final double bow;
  final double stern;
  final double motion;

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
    _rect(canvas, 0, 0, 600, 70, const Color(0x337B4640));
    _polygon(canvas, [
      110,
      53,
      505,
      52,
      536,
      65,
      130,
      68,
    ], const Color(0xFFC2AC82));
    _polygon(canvas, [130, 68, 536, 65, 525, 75, 137, 77], ink);
    for (final x in [154.0, 262.0, 430.0, 509.0]) {
      _rect(canvas, x, 65, 7, 23, ink);
    }
    artwork.paint(canvas, Art.fool, origin: const Offset(170, 59), scale: .80);

    final drift = -120 * Curves.easeInOut.transform(motion);
    _tether(canvas, const Offset(254, 60), Offset(295 + drift, 89), bow, gold);
    _tether(
      canvas,
      const Offset(436, 60),
      Offset(413 + drift, 86),
      stern,
      _waterline,
    );
    canvas.save();
    canvas.translate(drift, 0);
    _polygon(canvas, [
      281,
      83,
      315,
      86,
      402,
      82,
      420,
      75,
      418,
      92,
      403,
      101,
      315,
      102,
    ], ink);
    _polygon(canvas, [
      287,
      85,
      321,
      88,
      402,
      84,
      417,
      79,
      406,
      91,
      321,
      96,
    ], const Color(0xFF947255));
    canvas.drawLine(
      const Offset(319, 92),
      const Offset(396, 88),
      _pen(paleGold, 1.4),
    );
    canvas.restore();
    canvas.restore();
  }

  void _tether(
    Canvas canvas,
    Offset post,
    Offset boat,
    double cut,
    Color color,
  ) {
    canvas.drawLine(
      post - const Offset(0, 10),
      post + const Offset(0, 13),
      _pen(ink, 5),
    );
    final end = cut >= 1 ? post + const Offset(3, 13) : boat;
    canvas.drawLine(post, end, _pen(color, cut >= 1 ? 1.6 : 3 - 1.5 * cut));
  }

  @override
  bool shouldRepaint(DockPainter oldDelegate) =>
      oldDelegate.artwork != artwork ||
      oldDelegate.bow != bow ||
      oldDelegate.stern != stern ||
      oldDelegate.motion != motion;
}

class MarketPainter extends CustomPainter {
  const MarketPainter({
    required this.artwork,
    required this.targets,
    required this.motion,
  });

  final Artwork artwork;
  final List<({PuzzleTarget target, double progress})> targets;
  final double motion;

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
    _polygon(canvas, [93, 85, 441, 85, 469, 94, 109, 97], parchment);
    _polygon(canvas, [109, 97, 469, 94, 461, 101, 116, 105], ink);
    artwork.paint(
      canvas,
      Art.fool,
      origin: Offset(187 + 37 * Curves.easeInOut.transform(motion), 89),
      scale: .86,
    );

    if (targets.length == 2 &&
        targets.every((entry) => entry.target.kind == TargetKind.pan)) {
      _paintScale(canvas, targets.first.progress, targets.last.progress);
    } else {
      final spacing = 176 / targets.length;
      for (final (index, entry) in targets.indexed) {
        _paintFixture(
          canvas,
          artwork,
          entry.target,
          Offset(251 + (index + .5) * spacing, 56),
          entry.progress,
        );
      }
    }
    canvas.restore();
  }

  void _paintScale(Canvas canvas, double west, double east) {
    const pivot = Offset(337, 33);
    final tilt = 13 * (west - east);
    final westHook = pivot + Offset(-64, tilt);
    final eastHook = pivot + Offset(64, -tilt);
    final support = _pen(ink, 7);
    canvas.drawLine(pivot, const Offset(337, 87), support);
    canvas.drawLine(const Offset(319, 88), const Offset(355, 88), support);
    canvas.drawLine(westHook, eastHook, support);
    canvas.drawLine(westHook, eastHook, _pen(gold, 2.5));
    canvas.drawCircle(pivot, 5, Paint()..color = paleGold);
    for (final (hook, amount) in [(westHook, west), (eastHook, east)]) {
      canvas.drawLine(hook, hook + const Offset(0, 10), _pen(paleGold, 1.5));
      _scalePan(canvas, hook + const Offset(0, 27), amount);
    }
  }

  @override
  bool shouldRepaint(MarketPainter oldDelegate) =>
      oldDelegate.artwork != artwork ||
      !listEquals(oldDelegate.targets, targets) ||
      oldDelegate.motion != motion;
}

class BreadStallPainter extends CustomPainter {
  const BreadStallPainter({
    required this.artwork,
    required this.light,
    required this.water,
    required this.payment,
    required this.motion,
  });

  final Artwork artwork;
  final double light;
  final double water;
  final double payment;
  final double motion;

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
    artwork.paint(
      canvas,
      Art.mooredBoat,
      origin: const Offset(29, 84),
      scale: .80,
    );
    _polygon(canvas, [97, 85, 523, 85, 552, 94, 112, 99], parchment);
    _polygon(canvas, [112, 99, 552, 94, 545, 101, 119, 106], ink);

    final walk = Curves.easeInOut.transform(motion);
    artwork.paint(
      canvas,
      Art.fool,
      origin: Offset(182 + 57 * walk, 90),
      scale: .89,
    );

    _rect(canvas, 272, 31, 177, 57, const Color(0xFF6D503C));
    const window = Rect.fromLTWH(289, 33, 142, 36);
    final opening = Curves.easeOut.transform(motion);
    canvas.save();
    canvas.clipRect(window);
    canvas.drawRect(window, Paint()..color = const Color(0xFFDDA761));
    final apron = Paint()..color = const Color(0xFF3B5B51);
    canvas.drawOval(const Rect.fromLTWH(368, 52, 37, 30), apron);
    canvas.drawCircle(
      const Offset(386, 48),
      9,
      Paint()..color = const Color(0xFF9E694A),
    );
    canvas.drawOval(
      const Rect.fromLTWH(375, 37, 22, 9),
      Paint()..color = paper,
    );
    _loaf(canvas, const Offset(334, 63));
    _loaf(canvas, const Offset(358, 63));
    final shutterHeight = window.height * (1 - opening);
    _rect(
      canvas,
      window.left,
      window.top,
      window.width,
      shutterHeight,
      const Color(0xFFB08C66),
    );
    for (var y = window.top + 7; y < window.top + shutterHeight; y += 7) {
      canvas.drawLine(
        Offset(window.left, y),
        Offset(window.right, y),
        _pen(ink, 1),
      );
    }
    canvas.restore();
    canvas.drawRect(window, _pen(ink, 2));
    _rect(canvas, 276, 69, 169, 7, const Color(0xFFCEAA76));
    _polygon(canvas, [266, 18, 452, 18, 469, 35, 253, 35], rust);
    for (var x = 277.0; x < 450; x += 32) {
      canvas.drawLine(Offset(x, 21), Offset(x + 2, 32), _pen(paleGold, 2));
    }
    canvas.drawLine(const Offset(254, 35), const Offset(468, 35), _pen(ink, 2));

    const lantern = Offset(271, 54);
    _sceneGlow(canvas, lantern, 44, light);
    _lantern(canvas, artwork, lantern, .55, light);
    _inlet(canvas, const Offset(480, 72), .86, water);
    _scalePan(canvas, const Offset(428, 55), payment);

    if (motion > .28) {
      final handoff = const Interval(
        .28,
        1,
        curve: Curves.easeInOut,
      ).transform(motion);
      final point = Offset.lerp(
        const Offset(310, 63),
        Offset(193 + 57 * walk, 70),
        handoff,
      )!;
      _loaf(canvas, point);
    }
    canvas.restore();
  }

  void _loaf(Canvas canvas, Offset center) {
    final shape = Rect.fromCenter(center: center, width: 23, height: 12);
    canvas.drawOval(shape, Paint()..color = const Color(0xFFE9AF59));
    canvas.drawOval(shape, _pen(ink, 1.5));
    for (final x in [-4.0, 3.0]) {
      canvas.drawLine(
        center + Offset(x + 2, -4),
        center + Offset(x, 1),
        _pen(paper, 1.5),
      );
    }
  }

  @override
  bool shouldRepaint(BreadStallPainter oldDelegate) =>
      oldDelegate.artwork != artwork ||
      oldDelegate.light != light ||
      oldDelegate.water != water ||
      oldDelegate.payment != payment ||
      oldDelegate.motion != motion;
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

class SluicePainter extends CustomPainter {
  const SluicePainter({
    required this.artwork,
    required this.west,
    required this.east,
    required this.motion,
  });

  final Artwork artwork;
  final double west;
  final double east;
  final double motion;

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
    _rect(canvas, 0, 83, SceneLayout.width, 27, _water);
    for (final (x, y) in [(8.0, 93.0), (116.0, 104.0), (467.0, 100.0)]) {
      canvas.drawLine(Offset(x, y), Offset(x + 64, y), _pen(_waterline, 1.6));
    }

    const stone = Color(0xFFBAA17A);
    _polygon(canvas, [84, 45, 516, 45, 550, 94, 50, 94], stone);
    canvas.drawPath(
      _path(const [
        Offset(50, 94),
        Offset(84, 45),
        Offset(516, 45),
        Offset(550, 94),
      ]),
      _pen(ink, 2),
    );
    _rect(canvas, 50, 88, 500, 7, ink);

    final channel = Path()
      ..addPolygon(const [
        Offset(174, 67),
        Offset(426, 67),
        Offset(439, 82),
        Offset(325, 82),
        Offset(341, 110),
        Offset(259, 110),
        Offset(275, 82),
        Offset(161, 82),
      ], true);
    canvas.drawPath(channel, Paint()..color = const Color(0xFF33423E));
    canvas.save();
    canvas.clipPath(channel);
    if (motion > 0) {
      final arms = const Interval(
        0,
        .55,
        curve: Curves.easeOut,
      ).transform(motion);
      final outlet = const Interval(
        .45,
        1,
        curve: Curves.easeOut,
      ).transform(motion);
      final reach = 141 * arms;
      _rect(canvas, 159, 68, reach, 14, _water);
      _rect(canvas, 441 - reach, 68, reach, 14, _water);
      _rect(canvas, 257, 80, 86, 30 * outlet, _water);
      final surface = _pen(_waterline, 1.5);
      canvas.drawLine(const Offset(159, 74), Offset(159 + reach, 74), surface);
      canvas.drawLine(Offset(441 - reach, 74), const Offset(441, 74), surface);
      canvas.drawLine(
        const Offset(300, 80),
        Offset(300, 80 + 30 * outlet),
        surface,
      );
    }
    canvas.restore();
    canvas.drawPath(channel, _pen(ink, 2));

    _inlet(canvas, const Offset(174, 65), 1.32, west, marked: true);
    _inlet(canvas, const Offset(426, 65), 1.32, east, marked: true);
    artwork.paint(canvas, Art.fool, origin: const Offset(86, 86), scale: .71);
    canvas.restore();
  }

  @override
  bool shouldRepaint(SluicePainter oldDelegate) =>
      artwork != oldDelegate.artwork ||
      west != oldDelegate.west ||
      east != oldDelegate.east ||
      motion != oldDelegate.motion;
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
    required this.progress,
    this.turn,
    this.link,
    this.turnProgress = 1,
    this.fadeProgress = 1,
    this.fadedCells = const [],
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
  final Map<int, double> progress;
  final Turn? turn;
  final TargetLink? link;
  final double turnProgress;
  final double fadeProgress;
  final Iterable<int> fadedCells;
  final int? keyboardCell;
  final bool reducedMotion;
  final bool rejected;

  BoardSize get _size => puzzle.size;

  Offset _center(int cell) => Offset(
    (_size.columnOf(cell) + .5) * _tile,
    (_size.rowOf(cell) + .5) * _tile,
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final width = _tile * _size.columns;
    final height = _tile * _size.rows;
    canvas.scale(size.width / width, size.height / height);
    canvas.clipRect(Rect.fromLTWH(0, 0, width, height));
    for (var cell = 0; cell < _size.cellCount; cell++) {
      final color = puzzle.targets.containsKey(cell)
          ? const Color(0xFFDDCCA3)
          : (_size.rowOf(cell) + _size.columnOf(cell)).isEven
          ? paper
          : parchment;
      _rect(
        canvas,
        _size.columnOf(cell) * _tile,
        _size.rowOf(cell) * _tile,
        _tile,
        _tile,
        color,
      );
    }
    final gridLine = _pen(rule, .9);
    for (var column = 1; column < _size.columns; column++) {
      final x = column * _tile;
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridLine);
    }
    for (var row = 1; row < _size.rows; row++) {
      final y = row * _tile;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridLine);
    }

    final pieceBounds = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, width, height));
    for (final cell in puzzle.masked) {
      final center = _center(cell);
      final gap = Rect.fromCenter(center: center, width: _tile, height: _tile);
      pieceBounds.addRect(gap);
      if (puzzle.scene.hasWaterGaps) {
        canvas.drawRect(gap, Paint()..color = blue);
        canvas.drawLine(
          center.translate(-30, -16),
          center.translate(8, -16),
          _pen(_waterline.withValues(alpha: .5), 2),
        );
        canvas.drawLine(
          center.translate(-8, 16),
          center.translate(32, 16),
          _pen(_waterline.withValues(alpha: .4), 2),
        );
      } else {
        artwork.paint(canvas, Art.ruinedWall, origin: center);
      }
    }
    canvas.save();
    canvas.clipPath(pieceBounds);
    final activeTurn = turn;
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
    for (final entry in puzzle.targets.entries) {
      final center = _center(entry.key);
      _paintFixture(
        canvas,
        artwork,
        entry.value,
        center - const Offset(0, 7),
        progress[entry.key]!,
        marked: puzzle.fillTogether,
      );
      if (puzzle.scoringSuits.length > 1) {
        artwork.paint(
          canvas,
          _suitArt(entry.value.suit),
          origin: center - const Offset(32, 32),
          scale: .46,
        );
      }
    }
    canvas.restore();
    final activeLink = link;
    if (activeLink != null) _paintLink(canvas, activeLink);
    if (fadeProgress < 1) {
      final strength = 1 - Curves.easeOut.transform(fadeProgress);
      final halo = _pen(
        gold.withValues(alpha: strength * BoardStyle.fadeHaloOpacity),
        BoardStyle.fadeHaloStroke,
      );
      for (final cell in fadedCells) {
        canvas.drawCircle(
          _center(cell) - const Offset(0, 7),
          BoardStyle.fadeHaloRadius + BoardStyle.fadeHaloTravel * strength,
          halo,
        );
      }
    }
    if (activeTurn == null) {
      if (demonstration != null && path.isEmpty) {
        _paintDemonstration(canvas, demonstration!);
      }
      if (path.isNotEmpty) {
        canvas.save();
        if (preview?.skippedCell == null) canvas.clipPath(pieceBounds);
        _paintStroke(
          canvas,
          preview?.path ?? path,
          rejected ? rust : blue,
          skipped: preview?.skippedCell,
        );
        canvas.restore();
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

  void _paintLink(Canvas canvas, TargetLink link) {
    final stroke = turn?.stroke;
    final sharing =
        stroke != null && !stroke.isRectangle && stroke.gains.length > 1;
    final connecting = stroke?.linkedTargets.isNotEmpty ?? false;
    final flash = reducedMotion || !(sharing || connecting)
        ? 0.0
        : math.sin(math.pi * turnProgress);
    final color = Color.lerp(blue, const Color(0xFF2F97BC), flash)!;
    final points = link.cells
        .map((cell) => _center(cell) - const Offset(0, 7))
        .toList();
    final ring = _pen(color, 3 + flash * 2);
    for (final point in points) {
      canvas.drawCircle(point, 29, ring);
    }
    for (var i = 1; i < points.length; i++) {
      final from = points[i - 1];
      final to = points[i];
      final direction = (to - from) / (to - from).distance;
      final normal = Offset(-direction.dy, direction.dx);
      final start = from + direction * 29;
      final end = to - direction * 29;
      final bolt = _path([
        start,
        Offset.lerp(start, end, .32)! + normal * 11,
        Offset.lerp(start, end, .43)! - normal * 9,
        Offset.lerp(start, end, .68)! + normal * 12,
        end,
      ]);
      canvas.drawPath(bolt, _pen(paper, 7));
      canvas.drawPath(bolt, _pen(color, 3 + flash * 2));
    }
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
      if (turn.stroke.gains.isNotEmpty && !turn.stroke.isRectangle) {
        final aim = _size.aimOf(turn.stroke.path)!;
        final point = Offset.lerp(
          _center(turn.stroke.path.last),
          _center(aim),
          dissolve,
        )!;
        if (turn.stroke.suit == Suit.cup) {
          artwork.paint(
            canvas,
            puzzle.targets[aim]!.kind == TargetKind.lantern
                ? Art.oilDrop
                : Art.waterDrop,
            origin: point,
          );
        } else if (turn.stroke.suit == Suit.sword) {
          artwork.paint(canvas, Art.sword, origin: point, scale: .75);
        } else if (turn.stroke.suit == Suit.coin) {
          artwork.paint(canvas, Art.coin, origin: point, scale: .68);
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
    final guide = _traceOutline(clue.path, clue.skippedCell);
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
        : clue.skippedCell != null
        ? points
        : [points.first, points.last];
    for (final corner in corners) {
      canvas.drawCircle(corner, 35, _pen(blue.withValues(alpha: .55), 2.6));
    }
    final progress = reducedMotion
        ? 0.0
        : ((guideTime - BoardMotion.guideLead) /
                  ((points.length - 1) * BoardMotion.guideStep))
              .clamp(0.0, 1.0);
    final Offset tip;
    final Path active;
    if (clue.skippedCell != null) {
      final distance = progress * metric.length;
      tip = metric.getTangentForOffset(distance)!.position;
      active = metric.extractPath(0, distance);
    } else {
      final segment = math.min(
        points.length - 2,
        (progress * (points.length - 1)).floor(),
      );
      tip = Offset.lerp(
        points[segment],
        points[segment + 1],
        progress * (points.length - 1) - segment,
      )!;
      active = _path([...points.take(segment + 1), tip]);
    }
    canvas.drawPath(active, _pen(blue, 6));
    if (!clue.isRectangle && clue.gains.isNotEmpty) {
      _paintAim(canvas, clue, rust);
    } else if (!clue.isRectangle || reducedMotion) {
      _arrow(canvas, points[points.length - 2], points.last, blue, .5);
    }
    _paintHand(canvas, tip);
  }

  void _paintHand(Canvas canvas, Offset tip) {
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    if (tip.dx > _tile * _size.columns - 60) canvas.scale(-1, 1);
    if (tip.dy > _tile * _size.rows - 60) canvas.scale(1, -1);
    canvas.scale(.80);
    artwork.paint(canvas, Art.hand, origin: const Offset(2, 3), opacity: .24);
    artwork.paint(canvas, Art.hand);
    canvas.restore();
  }

  Path _traceOutline(List<int> cells, int? skipped) {
    if (skipped == null) return _path(cells.map(_center).toList());
    final outline = Path()
      ..moveTo(_center(cells.first).dx, _center(cells.first).dy);
    for (var i = 1; i < cells.length; i++) {
      final start = _center(cells[i - 1]);
      final end = _center(cells[i]);
      if (_size.jumpOver(cells[i - 1], cells[i]) == skipped) {
        final center = _center(skipped);
        final control =
            center +
            (start.dy == end.dy ? const Offset(0, -68) : const Offset(68, 0));
        outline.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      } else {
        outline.lineTo(end.dx, end.dy);
      }
    }
    return outline;
  }

  void _paintStroke(
    Canvas canvas,
    List<int> cells,
    Color color, {
    int? skipped,
  }) {
    final points = cells.map(_center).toList();
    final outline = _traceOutline(cells, skipped);
    canvas.drawPath(outline, _pen(paper, 10));
    canvas.drawPath(outline, _pen(color, 5));
    for (final point in points) {
      canvas.drawCircle(point, 29, _pen(paper, 6));
      canvas.drawCircle(point, 29, _pen(color, 3));
    }
  }

  void _paintAim(Canvas canvas, Stroke stroke, Color color) {
    final aim = _size.aimOf(stroke.path);
    if (aim != null && !puzzle.masked.contains(aim)) {
      final blocked =
          puzzle.targets[aim]?.aimDirection != null &&
          !stroke.gains.containsKey(aim);
      _arrow(
        canvas,
        _center(stroke.path.last),
        _center(aim),
        blocked ? rust : color,
        .68,
      );
    }
  }

  @override
  bool shouldRepaint(TableauPainter oldDelegate) => true;
}

class SuitPainter extends CustomPainter {
  const SuitPainter(this.artwork, this.suits);

  final Artwork artwork;
  final Set<Suit> suits;

  @override
  void paint(Canvas canvas, Size size) {
    final columns = suits.length == 1 ? 1 : 2;
    final rows = (suits.length + columns - 1) ~/ columns;
    final pitch = size.shortestSide / columns;
    final center = size.center(Offset.zero);
    for (final (index, suit) in suits.indexed) {
      final row = index ~/ columns;
      final inRow = math.min(columns, suits.length - row * columns);
      artwork.paint(
        canvas,
        _suitArt(suit),
        origin:
            center +
            Offset(
              (index % columns + .5 - inRow / 2) * pitch,
              (row + .5 - rows / 2) * pitch,
            ),
        scale: pitch / 60,
      );
    }
  }

  @override
  bool shouldRepaint(SuitPainter oldDelegate) =>
      artwork != oldDelegate.artwork || !setEquals(suits, oldDelegate.suits);
}

void _paintFixture(
  Canvas canvas,
  Artwork artwork,
  PuzzleTarget target,
  Offset center,
  double amount, {
  bool marked = false,
}) {
  switch (target.kind) {
    case TargetKind.marker:
      _marker(canvas, artwork, center, 24, amount);
    case TargetKind.lantern:
      _lantern(
        canvas,
        artwork,
        center,
        target.aimDirection == null ? 1 : .85,
        amount,
      );
    case TargetKind.inlet when target.label == TargetLabel.landingBasin:
      _landingBasin(canvas, center, 1, amount);
    case TargetKind.inlet:
      _inlet(canvas, center, 1, amount, marked: marked);
    case TargetKind.cord:
      _cord(
        canvas,
        center,
        amount,
        target.label == TargetLabel.sternCord ? _water : gold,
      );
    case TargetKind.pan:
      _scalePan(canvas, center, amount);
    case TargetKind.bell:
      _bell(canvas, center, rung: amount >= 1);
  }
  final aim = target.aimDirection;
  if (aim != null) {
    final direction = Offset(aim.dx.toDouble(), aim.dy.toDouble());
    _arrow(
      canvas,
      center - direction * 40,
      center - direction * 24,
      blue,
      1,
      scale: .65,
    );
  }
}

Art _suitArt(Suit suit) => switch (suit) {
  Suit.wand => Art.wand,
  Suit.cup => Art.cup,
  Suit.sword => Art.sword,
  Suit.coin => Art.coin,
};

void _bell(
  Canvas canvas,
  Offset center, {
  double scale = 1,
  required bool rung,
  double swing = 0,
}) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.scale(scale);
  if (rung) {
    for (final side in [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(24 * side, -7),
        Offset(31 * side, -11),
        _pen(gold, 3),
      );
      canvas.drawLine(
        Offset(25 * side, 4),
        Offset(33 * side, 5),
        _pen(gold, 3),
      );
    }
  }
  canvas.translate(0, -22);
  canvas.rotate(swing);
  canvas.translate(0, 22);
  canvas.drawCircle(const Offset(0, -23), 4, _pen(ink, 2.5));
  canvas.drawCircle(const Offset(0, 15), 5, Paint()..color = ink);
  final shell = Path()
    ..moveTo(-20, 12)
    ..quadraticBezierTo(-13, 5, -12, -7)
    ..quadraticBezierTo(-11, -19, 0, -19)
    ..quadraticBezierTo(11, -19, 12, -7)
    ..quadraticBezierTo(13, 5, 20, 12)
    ..close();
  canvas.drawPath(shell, Paint()..color = rung ? paleGold : gold);
  canvas.drawPath(shell, _pen(ink, 2.5));
  canvas.drawPath(
    _path(const [Offset(-7, -11), Offset(-9, -2), Offset(-11, 5)]),
    _pen(paleGold, 2.5),
  );
  canvas.restore();
}

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

void _landingBasin(Canvas canvas, Offset center, double scale, double water) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.scale(scale);

  final bowl = Path()
    ..moveTo(-33, -11)
    ..cubicTo(-30, 5, -23, 15, -13, 18)
    ..quadraticBezierTo(0, 21, 13, 18)
    ..cubicTo(23, 15, 30, 5, 33, -11)
    ..close();
  canvas.drawPath(bowl, Paint()..color = const Color(0xFFA97850));
  canvas.drawPath(bowl, _pen(ink, 2.5));

  const rim = Rect.fromLTRB(-33, -23, 33, 1);
  const opening = Rect.fromLTRB(-27, -18, 27, -4);
  canvas.drawOval(rim, Paint()..color = const Color(0xFFE1BD83));
  canvas.drawOval(opening, Paint()..color = const Color(0xFF4F4338));
  if (water > 0) {
    final spread = math.sqrt(water);
    final surface = Rect.fromCenter(
      center: Offset(0, -8 - 3 * water),
      width: 53 * spread,
      height: 13 * spread,
    );
    canvas.drawOval(surface, Paint()..color = _water);
    canvas.drawArc(
      surface,
      math.pi * 1.13,
      math.pi * .49,
      false,
      _pen(_waterline, 1.4),
    );
  }
  canvas.drawOval(rim, _pen(ink, 2.5));
  canvas.restore();
}

void _inlet(
  Canvas canvas,
  Offset center,
  double scale,
  double water, {
  bool marked = false,
}) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.scale(scale);
  RRect basin(Rect rect) =>
      RRect.fromRectAndRadius(rect, const Radius.circular(3));
  final frame = basin(const Rect.fromLTRB(-24, -19, 24, 19));
  final channel = basin(const Rect.fromLTRB(-15, -11, 15, 14));
  canvas.drawRRect(frame, Paint()..color = const Color(0xFFBAA17A));
  canvas.drawRRect(frame, _pen(ink, 2));
  canvas.drawLine(
    const Offset(-18, -14),
    const Offset(18, -14),
    _pen(paper, 1.5),
  );
  canvas.drawRRect(channel, Paint()..color = const Color(0xFF33423E));
  const mark = -2.5;
  const bottom = 14.0;
  final surface = bottom - (marked ? bottom - mark : 25) * water;
  if (water > 0) {
    canvas.save();
    canvas.clipRRect(channel);
    _rect(canvas, -16, surface, 32, bottom - surface, _water);
    canvas.drawLine(
      Offset(-14, surface + 1),
      Offset(14, surface + 1),
      _pen(_waterline, 2),
    );
    canvas.restore();
  }
  if (marked) {
    for (final x in [-15.0, 9.0]) {
      canvas.drawLine(Offset(x, mark), Offset(x + 6, mark), _pen(paleGold, 2));
    }
    final floatHeight = (surface - 2).clamp(-8.0, 10.0);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, floatHeight), width: 13, height: 5),
      Paint()..color = paleGold,
    );
  }
  canvas.drawRRect(channel, _pen(ink, 1.5));
  canvas.restore();
}

void _cord(Canvas canvas, Offset center, double cut, Color color) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTRB(-25, -19, 25, 19),
      const Radius.circular(3),
    ),
    Paint()..color = ink,
  );
  for (final x in [-17.0, 17.0]) {
    canvas.drawCircle(Offset(x, 0), 5, Paint()..color = paleGold);
  }
  for (var strand = 0; strand < 5; strand++) {
    if (strand < (1 - cut) * 5) {
      final y = (strand - 2) * 3.0;
      canvas.drawLine(Offset(-17, y), Offset(17, y), _pen(color, 2));
    }
  }
  if (cut == 1) {
    canvas.drawLine(const Offset(-17, 0), const Offset(-8, 9), _pen(color, 2));
    canvas.drawLine(const Offset(17, 0), const Offset(8, -9), _pen(color, 2));
  }
  canvas.restore();
}

void _scalePan(Canvas canvas, Offset center, double fill) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  final hanger = _path([
    const Offset(-24, 10),
    const Offset(0, -17),
    const Offset(24, 10),
  ]);
  canvas.drawPath(hanger, _pen(ink, 3.5));
  canvas.drawPath(hanger, _pen(gold, 1.6));
  final bowl = Path()
    ..moveTo(-25, 10)
    ..lineTo(25, 10)
    ..quadraticBezierTo(20, 24, 0, 25)
    ..quadraticBezierTo(-20, 24, -25, 10)
    ..close();
  canvas.drawPath(bowl, Paint()..color = gold);
  canvas.drawPath(bowl, _pen(ink, 2.5));
  if (fill > 0) {
    final stack = RRect.fromRectAndRadius(
      Rect.fromLTRB(-11, 9 - 17 * fill, 11, 10),
      const Radius.circular(2),
    );
    canvas.drawRRect(stack, Paint()..color = paleGold);
    canvas.drawRRect(stack, _pen(ink, 2));
    for (var y = 5.0; y > stack.top + 2; y -= 4) {
      canvas.drawLine(Offset(-9, y), Offset(9, y), _pen(gold, 1.3));
    }
  }
  canvas.restore();
}

void _arrow(
  Canvas canvas,
  Offset a,
  Offset b,
  Color color,
  double fraction, {
  double scale = 1,
}) {
  final direction = (b - a) / (b - a).distance;
  final normal = Offset(-direction.dy, direction.dx);
  final tip = Offset.lerp(a, b, fraction)!;
  final back = tip - direction * (10 * scale);
  final wing = normal * (8 * scale);
  final stem = _path([tip - direction * (21 * scale), tip]);
  final head = _path([back + wing, tip, back - wing]);
  final outline = _pen(paper, 12 * scale);
  final fill = _pen(color, 5 * scale);
  canvas.drawPath(stem, outline);
  canvas.drawPath(head, outline);
  canvas.drawPath(stem, fill);
  canvas.drawPath(head, fill);
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
