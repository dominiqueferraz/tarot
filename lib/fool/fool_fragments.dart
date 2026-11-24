import 'package:flutter/widgets.dart';

import '../artwork.dart';

enum FoolFragment {
  trail('001', [
    Offset(27, 264),
    Offset(47, 254),
    Offset(65, 264),
    Offset(64, 285),
    Offset(47, 293),
    Offset(30, 284),
  ]),
  sun('002', [
    Offset(33, 44),
    Offset(56, 32),
    Offset(80, 43),
    Offset(82, 68),
    Offset(64, 83),
    Offset(36, 76),
  ]),
  millstream('003', [
    Offset(118, 294),
    Offset(135, 278),
    Offset(158, 283),
    Offset(164, 304),
    Offset(149, 317),
    Offset(122, 314),
  ]),
  knot('004', [
    Offset(143, 120),
    Offset(157, 109),
    Offset(179, 119),
    Offset(184, 140),
    Offset(165, 152),
    Offset(146, 147),
  ]),
  fare('005', [
    Offset(183, 218),
    Offset(203, 207),
    Offset(220, 217),
    Offset(219, 237),
    Offset(200, 248),
    Offset(187, 239),
  ]),
  bundle('006', [
    Offset(72, 117),
    Offset(88, 111),
    Offset(104, 117),
    Offset(109, 138),
    Offset(92, 151),
    Offset(74, 145),
  ]),
  channels('007', [
    Offset(61, 305),
    Offset(83, 295),
    Offset(103, 300),
    Offset(112, 319),
    Offset(96, 329),
    Offset(67, 328),
  ]),
  star('008', [
    Offset(171, 48),
    Offset(189, 39),
    Offset(207, 48),
    Offset(212, 72),
    Offset(193, 84),
    Offset(170, 75),
  ]),
  dog('009', [
    Offset(34, 198),
    Offset(53, 190),
    Offset(75, 196),
    Offset(80, 215),
    Offset(64, 231),
    Offset(40, 226),
  ]),
  sail('010', [
    Offset(173, 279),
    Offset(193, 267),
    Offset(216, 277),
    Offset(221, 299),
    Offset(201, 311),
    Offset(177, 302),
  ]);

  const FoolFragment(this.phase, this.points);

  final String phase;
  final List<Offset> points;

  static final byPhase = {
    for (final fragment in values) fragment.phase: fragment,
  };

  Path get path => Path()..addPolygon(points, true);
}

void paintFoolFragment(Canvas canvas, Artwork artwork, Path shape) {
  canvas.save();
  canvas.clipPath(shape);
  artwork.paint(canvas, Art.foolJourney);
  canvas.restore();
}
