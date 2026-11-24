import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../artwork.dart';
import '../l10n/generated/app_localizations.dart';
import 'puzzle_definition.dart';
import 'stroke.dart';
import 'tableau_art.dart';

({String title, String objective}) puzzleWords(
  AppLocalizations strings,
  PuzzleTextKey key,
) => switch (key) {
  PuzzleTextKey.foolsStep => (
    title: strings.foolsStepTitle,
    objective: strings.foolsStepObjective,
  ),
  PuzzleTextKey.lamplighter => (
    title: strings.lamplighterTitle,
    objective: strings.lamplighterObjective,
  ),
  PuzzleTextKey.highWater => (
    title: strings.highWaterTitle,
    objective: strings.highWaterObjective,
  ),
  PuzzleTextKey.mooring => (
    title: strings.mooringTitle,
    objective: strings.mooringObjective,
  ),
  PuzzleTextKey.ferrymansFare => (
    title: strings.ferrymansFareTitle,
    objective: strings.ferrymansFareObjective,
  ),
  PuzzleTextKey.marketDay => (
    title: strings.marketDayTitle,
    objective: strings.marketDayObjective,
  ),
  PuzzleTextKey.fairSplit => (
    title: strings.fairSplitTitle,
    objective: strings.fairSplitObjective,
  ),
  PuzzleTextKey.fromBehind => (
    title: strings.fromBehindTitle,
    objective: strings.fromBehindObjective,
  ),
  PuzzleTextKey.keepMeAPartner => (
    title: strings.keepMeAPartnerTitle,
    objective: strings.keepMeAPartnerObjective,
  ),
  PuzzleTextKey.nightFishing => (
    title: strings.nightFishingTitle,
    objective: strings.nightFishingObjective,
  ),
  PuzzleTextKey.brokenRoad => (
    title: strings.brokenRoadTitle,
    objective: strings.brokenRoadObjective,
  ),
  PuzzleTextKey.drawbridge => (
    title: strings.drawbridgeTitle,
    objective: strings.drawbridgeObjective,
  ),
};

String? puzzleOpeningStory(AppLocalizations strings, PuzzleTextKey key) =>
    switch (key) {
      PuzzleTextKey.marketDay => strings.marketDayStory,
      PuzzleTextKey.keepMeAPartner => strings.keepMeAPartnerStory,
      PuzzleTextKey.nightFishing => strings.nightFishingStory,
      PuzzleTextKey.brokenRoad => strings.brokenRoadStory,
      PuzzleTextKey.drawbridge => strings.drawbridgeStory,
      _ => null,
    };

String targetName(AppLocalizations strings, TargetLabel label) =>
    switch (label) {
      TargetLabel.trailMarker => strings.trailMarker,
      TargetLabel.quayLamp => strings.quayLamp,
      TargetLabel.millInlet => strings.millInlet,
      TargetLabel.bowCord => strings.bowCord,
      TargetLabel.sternCord => strings.sternCord,
      TargetLabel.westPan => strings.westPan,
      TargetLabel.eastPan => strings.eastPan,
      TargetLabel.marketLamp => strings.marketLamp,
      TargetLabel.marketInlet => strings.marketInlet,
      TargetLabel.paymentPan => strings.paymentPan,
      TargetLabel.westFloat => strings.westFloat,
      TargetLabel.eastFloat => strings.eastFloat,
      TargetLabel.westFacingLamp => strings.westFacingLamp,
      TargetLabel.landingBasin => strings.landingBasin,
      TargetLabel.harbourLamp => strings.harbourLamp,
      TargetLabel.mooringCord => strings.mooringCord,
      TargetLabel.farBankBell => strings.farBankBell,
      TargetLabel.drawbridgeInlet => strings.drawbridgeInlet,
    };

String aimDirectionName(AppLocalizations strings, BoardDirection direction) =>
    switch (direction) {
      BoardDirection.north => strings.aimUp,
      BoardDirection.east => strings.aimRight,
      BoardDirection.south => strings.aimDown,
      BoardDirection.west => strings.aimLeft,
    };

String targetAmount(AppLocalizations strings, TargetKind kind, int amount) =>
    switch (kind) {
      TargetKind.marker || TargetKind.lantern => strings.lightGoal(amount),
      TargetKind.inlet => strings.waterGoal(amount),
      TargetKind.cord => strings.strandAmount(amount),
      TargetKind.pan || TargetKind.bell => strings.coinAmount(amount),
    };

String suitName(AppLocalizations strings, Suit suit) => switch (suit) {
  Suit.wand => strings.wands,
  Suit.cup => strings.cups,
  Suit.sword => strings.swords,
  Suit.coin => strings.coins,
};

String suitNames(AppLocalizations strings, Iterable<Suit> suits) => suits
    .map((suit) => suitName(strings, suit))
    .reduce(strings.labelWithDetail);

List<Offset> suitOffsets(int count, double radius, {required double start}) =>
    List.generate(count, (index) {
      final angle = start + index * 2 * math.pi / count;
      return Offset(math.cos(angle) * radius, math.sin(angle) * radius);
    });

String difficultyName(AppLocalizations strings, PuzzleDifficulty difficulty) =>
    switch (difficulty) {
      PuzzleDifficulty.normal => strings.normalDifficulty,
      PuzzleDifficulty.hard => strings.hardDifficulty,
      PuzzleDifficulty.superHard => strings.superHardDifficulty,
    };

class PuzzleIllustration extends StatelessWidget {
  const PuzzleIllustration({
    required this.artwork,
    required this.puzzle,
    this.progress = const {},
    this.motion = 0,
    super.key,
  });

  final Artwork artwork;
  final PuzzleDefinition puzzle;
  final Map<int, double> progress;
  final double motion;

  @override
  Widget build(BuildContext context) {
    final targets = [
      for (final entry in puzzle.targets.entries)
        (target: entry.value, progress: progress[entry.key] ?? 0.0),
    ];
    double progressOf(TargetKind kind, {TargetLabel? label}) =>
        targets
            .where(
              (entry) =>
                  entry.target.kind == kind &&
                  (label == null || entry.target.label == label),
            )
            .firstOrNull
            ?.progress ??
        0;

    return CustomPaint(
      painter: switch (puzzle.scene) {
        PuzzleScene.ridge => RidgePainter(
          artwork: artwork,
          light: progressOf(TargetKind.marker),
          walk: motion,
        ),
        PuzzleScene.quay => QuayPainter(
          artwork: artwork,
          light: progressOf(TargetKind.lantern),
        ),
        PuzzleScene.mill => MillPainter(
          artwork: artwork,
          water: progressOf(TargetKind.inlet),
          motion: motion,
        ),
        PuzzleScene.dock => DockPainter(
          artwork: artwork,
          bow: progressOf(TargetKind.cord, label: TargetLabel.bowCord),
          stern: progressOf(TargetKind.cord, label: TargetLabel.sternCord),
          motion: motion,
        ),
        PuzzleScene.market => MarketPainter(
          artwork: artwork,
          targets: targets,
          motion: motion,
        ),
        PuzzleScene.breadStall => BreadStallPainter(
          artwork: artwork,
          light: progressOf(TargetKind.lantern),
          water: progressOf(TargetKind.inlet),
          payment: progressOf(TargetKind.pan),
          motion: motion,
        ),
        PuzzleScene.sluice => SluicePainter(
          artwork: artwork,
          west: progressOf(TargetKind.inlet, label: TargetLabel.westFloat),
          east: progressOf(TargetKind.inlet, label: TargetLabel.eastFloat),
          motion: motion,
        ),
        PuzzleScene.lampPath => LampPathPainter(
          artwork: artwork,
          light: progressOf(TargetKind.lantern),
          walk: motion,
        ),
        PuzzleScene.fishingLanding => FishingLandingPainter(
          artwork: artwork,
          water: progressOf(TargetKind.inlet),
          walk: motion,
        ),
        PuzzleScene.nightFishing => NightFishingPainter(
          artwork: artwork,
          light: progressOf(TargetKind.lantern),
          cut: progressOf(TargetKind.cord),
          sail: motion,
        ),
        PuzzleScene.drawbridge => DrawbridgePainter(
          artwork: artwork,
          water: progressOf(TargetKind.inlet),
          motion: motion,
        ),
        PuzzleScene.brokenRoad => BrokenRoadPainter(
          artwork: artwork,
          rung: progressOf(TargetKind.bell) >= 1,
          motion: motion,
        ),
      },
    );
  }
}
