import 'package:flutter/widgets.dart';

import '../artwork.dart';
import '../l10n/generated/app_localizations.dart';
import 'puzzle_definition.dart';
import 'tableau_art.dart';

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
    this.light = 0,
    this.walk = 0,
    super.key,
  });

  final Artwork artwork;
  final PuzzleScene scene;
  final double light;
  final double walk;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: switch (scene) {
      PuzzleScene.ridge => RidgePainter(
        artwork: artwork,
        light: light,
        walk: walk,
      ),
      PuzzleScene.quay => QuayPainter(artwork: artwork, light: light),
    },
  );
}
