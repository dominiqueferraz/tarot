import 'package:material_ui/material_ui.dart';

import '../artwork.dart';
import '../fool/puzzle_definition.dart';
import '../fool/puzzle_presentation.dart';
import '../fool/tableau_art.dart';
import '../l10n/generated/app_localizations.dart';
import '../visuals.dart';

class PhasePreview extends StatelessWidget {
  const PhasePreview({
    required this.puzzle,
    required this.artwork,
    required this.onPlay,
    super.key,
  });

  final PuzzleDefinition puzzle;
  final Artwork artwork;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final words = puzzleWords(strings, puzzle.textKey);
    final quotas = <(Suit, TargetKind, int), List<PuzzleTarget>>{};
    for (final target in puzzle.targets.values) {
      (quotas[(target.suit, target.kind, target.quota)] ??= []).add(target);
    }
    return Scaffold(
      key: const Key('phase-preview'),
      body: PaperSurface(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CampaignStyle.sideInset,
                ),
                child: Row(
                  children: [
                    const Expanded(child: Divider(color: rule)),
                    const SizedBox(width: 12),
                    IconButton.outlined(
                      tooltip: strings.close,
                      style: IconButton.styleFrom(
                        shape: const RoundedRectangleBorder(),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) => SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CampaignStyle.sideInset,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: CampaignStyle.maxWidth,
                          minHeight: box.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                height: 2,
                                width: 30,
                                color: rust,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Semantics(
                              header: true,
                              child: Text(
                                words.title,
                                textAlign: TextAlign.center,
                                style: displayType(46),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _PreviewArt(artwork: artwork, puzzle: puzzle),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: parchment,
                                    border: Border.all(color: ink),
                                  ),
                                  child: CustomPaint(
                                    painter: SuitPainter(
                                      artwork,
                                      puzzle.scoringSuits,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        words.objective,
                                        style: displayType(23),
                                      ),
                                      const SizedBox(height: 7),
                                      for (final group in quotas.values)
                                        Text(
                                          strings.suitAndQuota(
                                            suitName(strings, group.first.suit),
                                            targetQuota(
                                              strings,
                                              group.first,
                                              group.length > 1,
                                            ),
                                          ),
                                          style: labelType.copyWith(
                                            color: mutedInk,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 17),
                            _PhaseStats(
                              moves: strings.moveLimit(puzzle.limit),
                              difficulty: difficultyName(
                                strings,
                                puzzle.difficulty,
                              ),
                            ),
                            const SizedBox(height: 20),
                            PlayAction(
                              label: onPlay == null
                                  ? strings.lockedPhase
                                  : strings.play,
                              onPressed: onPlay,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhaseStats extends StatelessWidget {
  const _PhaseStats({required this.moves, required this.difficulty});

  final String moves;
  final String difficulty;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(
        top: BorderSide(color: rule),
        bottom: BorderSide(color: rule),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(moves, textAlign: TextAlign.center, style: labelType),
          ),
          const SizedBox(height: 18, width: 1, child: ColoredBox(color: rule)),
          Expanded(
            child: Text(
              difficulty,
              textAlign: TextAlign.center,
              style: labelType,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PreviewArt extends StatelessWidget {
  const _PreviewArt({required this.artwork, required this.puzzle});

  final Artwork artwork;
  final PuzzleDefinition puzzle;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('phase-illustration'),
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: parchment,
      border: Border.all(color: ink, width: BoardStyle.frameWidth),
      boxShadow: const [BoxShadow(color: rule, offset: Offset(4, 4))],
    ),
    child: AspectRatio(
      aspectRatio: CampaignStyle.previewAspect,
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: SceneLayout.width,
            height: SceneLayout.height,
            child: PuzzleIllustration(artwork: artwork, puzzle: puzzle),
          ),
        ),
      ),
    ),
  );
}
