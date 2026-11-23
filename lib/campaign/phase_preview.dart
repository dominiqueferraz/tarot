import 'package:material_ui/material_ui.dart';

import '../artwork.dart';
import '../fool/puzzle_definition.dart';
import '../fool/puzzle_presentation.dart';
import '../fool/tableau_art.dart';
import '../l10n/generated/app_localizations.dart';
import '../lives.dart';
import '../lives_indicator.dart';
import '../visuals.dart';

class PhasePreview extends StatelessWidget {
  const PhasePreview({
    required this.puzzle,
    required this.artwork,
    required this.lives,
    required this.onPlay,
    super.key,
  });

  final PuzzleDefinition puzzle;
  final Artwork artwork;
  final LifePool lives;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final words = puzzleWords(strings, puzzle.textKey);
    final story = puzzleStory(strings, puzzle.textKey);
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
                    const SizedBox(width: 6),
                    LivesIndicator(lives: lives),
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
                            if (story != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                story.opening,
                                textAlign: TextAlign.center,
                                style: displayType(19),
                              ),
                              const SizedBox(height: 18),
                            ] else ...[
                              const SizedBox(height: 22),
                              Text(
                                words.objective,
                                textAlign: TextAlign.center,
                                style: displayType(23),
                              ),
                              const SizedBox(height: 10),
                            ],
                            _PhaseTargets(artwork: artwork, puzzle: puzzle),
                            const SizedBox(height: 17),
                            _PhaseStats(
                              moves: strings.moveLimit(puzzle.limit),
                              difficulty: difficultyName(
                                strings,
                                puzzle.difficulty,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ListenableBuilder(
                              listenable: lives,
                              builder: (context, child) {
                                final waiting =
                                    onPlay != null && lives.remaining == 0;
                                return PlayAction(
                                  label: waiting
                                      ? strings.noLivesLeft
                                      : onPlay == null
                                      ? strings.lockedPhase
                                      : strings.play,
                                  onPressed: waiting ? null : onPlay,
                                );
                              },
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

class _PhaseTargets extends StatelessWidget {
  const _PhaseTargets({required this.artwork, required this.puzzle});

  final Artwork artwork;
  final PuzzleDefinition puzzle;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final numbers = MaterialLocalizations.of(context);
    const gap = 8.0;
    final columns = puzzle.targets.length.clamp(1, 4);
    return LayoutBuilder(
      builder: (context, box) {
        final width = ((box.maxWidth - gap * (columns - 1)) / columns)
            .clamp(64.0, 94.0)
            .toDouble();
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: gap,
          runSpacing: 12,
          children: [
            for (final target in puzzle.targets.values)
              Semantics(
                label: strings.labelWithDetail(
                  targetName(strings, target.label),
                  strings.suitAndQuota(
                    suitName(strings, target.suit),
                    target.quota,
                  ),
                ),
                excludeSemantics: true,
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: parchment,
                          border: Border.all(color: rule),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: [
                              SizedBox.square(
                                dimension: 28,
                                child: CustomPaint(
                                  painter: SuitPainter(artwork, {target.suit}),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                numbers.formatDecimal(target.quota),
                                style: displayType(25),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        targetName(strings, target.label),
                        textAlign: TextAlign.center,
                        style: labelType.copyWith(
                          fontSize: 12,
                          color: mutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
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
