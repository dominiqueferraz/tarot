import 'package:flutter/widgets.dart';

const paper = Color(0xFFF5EDD9);
const parchment = Color(0xFFEDE1C3);
const ink = Color(0xFF252720);
const mutedInk = Color(0xFF645B4B);
const rule = Color(0xFFB8A98A);
const gold = Color(0xFFCA922F);
const paleGold = Color(0xFFF6D784);
const blue = Color(0xFF194D68);
const rust = Color(0xFF9F4027);

abstract final class BoardStyle {
  static const spacing = 10.0;
  static const frameWidth = 1.4;
  static const outerPadding = 16.0;
  static const maxWidth = 490.0;
  static const sidebarWidth = 250.0;
  static const sidebarGap = 22.0;
  static const wideBreakpoint = 580.0;
  static const movesDiameter = 50.0;
  static const tileUnits = 100.0;
  static const hitRadius = .42;
  static const hintTail = 7.0;
  static const hintMargin = 4.0;
  static const hintWidth = 208.0;
  static const hintTypeSize = 13.0;
  static const fadeHaloRadius = 24.0;
  static const fadeHaloTravel = 12.0;
  static const fadeHaloStroke = 3.0;
  static const fadeHaloOpacity = .72;
}

abstract final class CampaignStyle {
  static const maxWidth = 460.0;
  static const sideInset = 22.0;
  static const phaseSpacing = 64.0;
  static const phaseLaneOffset = 9.0;
  static const lowerMargin = 106.0;
  static const upperMargin = 110.0;
  static const trailEndInset = 24.0;
  static const medallion = 42.0;
  static const phaseNumberSize = 20.0;
  static const phaseTapHeight = 48.0;
  static const lockBadge = 18.0;
  static const suitBadge = 24.0;
  static const suitBadgeOverhang = 13.0;
  static const fragmentWidthFraction = .21;
  static const fragmentMaxWidth = 90.0;
  static const fragmentDrop = 5.0;
  static const fragmentCycle = 4;
  static const fragmentInset = 4.0;
  static const fragmentAspect = 126 / 232;
  static const previewAspect = 3.2;
}

abstract final class BoardMotion {
  static const fall = Duration(milliseconds: 530);
  static const scene = Duration(milliseconds: 720);
  static const rejected = Duration(milliseconds: 180);
  static const guideLead = .40;
  static const guideStep = .33;
  static const guidePause = 1.05;
  static const releaseFraction = .22;
  static const fadeCueFraction = .60;
}

abstract final class SceneLayout {
  static const width = 600.0;
  static const height = 110.0;
  static const ratio = width / height;
  static const ridgeTrail = [
    Offset(142, 98),
    Offset(232, 96),
    Offset(321, 75),
    Offset(397, 54),
    Offset(478, 73),
    Offset(543, 94),
  ];
  static const ridgeMarkerFoot = Offset(397, 58);
  static const quayLampFoot = Offset(275, 57);
  static const quayFool = Offset(166, 84);
  static const quayMooring = Offset(294, 84);
}

abstract final class SceneLight {
  static const markerRadius = 10.0;
  static const markerFullRadius = 21.0;
  static const markerFootRatio = 32 / 24;
  static const lampScale = .66;
  static const lampFullScale = 1.04;
  static const lampFootOffset = 21.0;
  static const ridgeGlowRadius = 66.0;
  static const quayGlowRadius = 92.0;
  static const glowStops = [0.0, .40, 1.0];
  static const flareThreshold = .55;
  static const flareFullRadius = 17.0;
}
