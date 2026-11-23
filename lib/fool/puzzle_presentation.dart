import 'package:flutter/widgets.dart';

import '../artwork.dart';
import '../l10n/generated/app_localizations.dart';
import 'puzzle_definition.dart';
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
};

String targetName(AppLocalizations strings, TargetLabel label) =>
    switch (label) {
      TargetLabel.trailMarker => strings.trailMarker,
      TargetLabel.quayLamp => strings.quayLamp,
      TargetLabel.millInlet => strings.millInlet,
      TargetLabel.bowCord => strings.bowCord,
      TargetLabel.sternCord => strings.sternCord,
    };

String suitName(AppLocalizations strings, Suit suit) => switch (suit) {
  Suit.wand => strings.wands,
  Suit.cup => strings.cups,
  Suit.sword => strings.swords,
  Suit.coin => strings.coins,
};

String difficultyName(AppLocalizations strings, PuzzleDifficulty difficulty) =>
    switch (difficulty) {
      PuzzleDifficulty.normal => strings.normalDifficulty,
      PuzzleDifficulty.hard => strings.hardDifficulty,
      PuzzleDifficulty.superHard => strings.superHardDifficulty,
    };

class PuzzleIllustration extends StatelessWidget {
  const PuzzleIllustration({
    required this.artwork,
    required this.scene,
    this.progress = const [],
    this.motion = 0,
    super.key,
  });

  final Artwork artwork;
  final PuzzleScene scene;
  final List<double> progress;
  final double motion;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: switch (scene) {
      PuzzleScene.ridge => RidgePainter(
        artwork: artwork,
        light: progress.firstOrNull ?? 0,
        walk: motion,
      ),
      PuzzleScene.quay => QuayPainter(
        artwork: artwork,
        light: progress.firstOrNull ?? 0,
      ),
      PuzzleScene.mill => MillPainter(
        artwork: artwork,
        water: progress.firstOrNull ?? 0,
        motion: motion,
      ),
      PuzzleScene.dock => DockPainter(
        artwork: artwork,
        bow: progress.elementAtOrNull(0) ?? 0,
        stern: progress.elementAtOrNull(1) ?? 0,
        motion: motion,
      ),
    },
  );
}
