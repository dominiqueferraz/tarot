import 'package:material_ui/material_ui.dart';

import 'dialogs.dart';
import 'l10n/generated/app_localizations.dart';
import 'lives.dart';
import 'visuals.dart';

class LivesIndicator extends StatelessWidget {
  const LivesIndicator({required this.lives, super.key});

  final LifePool lives;

  void _showDetails(BuildContext context, AppLocalizations strings) {
    showDialog<void>(
      context: context,
      builder: (context) => PaperDialog(
        title: strings.lives,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            LifeStatus(lives: lives),
            Text(strings.livesExplanation),
          ],
        ),
        actions: [
          DialogAction(
            label: strings.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: () => _showDetails(context, strings),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 5),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 128),
        child: LifeStatus(lives: lives, compact: true),
      ),
    );
  }
}

class LifeStatus extends StatelessWidget {
  const LifeStatus({
    required this.lives,
    this.compact = false,
    this.showDepletedLabel = false,
    super.key,
  });

  final LifePool lives;
  final bool compact;
  final bool showDepletedLabel;

  String _countdown(AppLocalizations strings, int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    final time = '$minutes:$remainder';
    return showDepletedLabel && lives.remaining == 0
        ? strings.noLivesRefillsIn(time)
        : strings.refillsIn(time);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: lives,
      builder: (context, child) {
        final remaining = lives.remaining;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: strings.livesRemaining(remaining, LifePool.capacity),
              excludeSemantics: true,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: compact ? 2 : 8,
                runSpacing: 4,
                children: [
                  for (var i = 0; i < LifePool.capacity; i++)
                    Icon(
                      i < remaining ? Icons.favorite : Icons.heart_broken,
                      size: compact ? 16 : 26,
                      color: i < remaining ? rust : mutedInk,
                    ),
                ],
              ),
            ),
            if (lives.secondsUntilNext case final seconds?)
              Padding(
                padding: EdgeInsets.only(top: compact ? 2 : 6),
                child: Text(
                  _countdown(strings, seconds),
                  textAlign: TextAlign.center,
                  style: labelType.copyWith(
                    fontSize: compact ? 11 : 14,
                    letterSpacing: 0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
