import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../artwork.dart';
import '../dialogs.dart';
import '../fool/fool_fragments.dart';
import '../l10n/generated/app_localizations.dart';
import '../tarot_card_face.dart';
import '../visuals.dart';

const _journeyArea = Rect.fromLTWH(14, 29, 212, 303);
const _socket = Color(0xFFE8D6AA);
const foolFirstReading = '013';

Future<void> showFoolJourney(
  BuildContext context,
  Artwork artwork,
  Set<FoolFragment> earned, {
  bool leapAcquired = false,
}) {
  final strings = AppLocalizations.of(context)!;
  final reducedMotion = MediaQuery.disableAnimationsOf(context);
  return showDialog<void>(
    context: context,
    builder: (context) => PaperDialog(
      key: Key(leapAcquired ? 'leap-acquisition' : 'fool-journey'),
      title: leapAcquired ? strings.leapAcquired : strings.foolChapter,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          AspectRatio(
            aspectRatio: _journeyArea.size.aspectRatio,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: reducedMotion || earned.isEmpty
                  ? Duration.zero
                  : Duration(milliseconds: leapAcquired ? 1500 : 1050),
              child: leapAcquired
                  ? Align(
                      alignment: const Alignment(.67, .03),
                      child: FractionallySizedBox(
                        widthFactor: .43,
                        child: TarotCardFace(
                          key: const Key('abstract-fool-card'),
                          title: strings.foolChapter,
                          illustration: SvgPicture.asset(
                            AppAssets.foolCard,
                            fit: BoxFit.cover,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                    )
                  : null,
              builder: (context, progress, card) {
                final assembly = leapAcquired
                    ? (progress / .68).clamp(0.0, 1.0)
                    : progress;
                final reveal = Curves.easeOut.transform(
                  ((progress - .68) / .32).clamp(0.0, 1.0),
                );
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _FoolJourneyPainter(artwork, earned, assembly),
                    ),
                    if (card != null) ...[
                      ColoredBox(color: paper.withValues(alpha: .24 * reveal)),
                      Opacity(
                        opacity: reveal,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - reveal)),
                          child: card,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          if (!leapAcquired)
            Text(
              strings.foolFragments(earned.length, FoolFragment.values.length),
              style: labelType,
              textAlign: TextAlign.center,
            ),
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

class _FoolJourneyPainter extends CustomPainter {
  const _FoolJourneyPainter(this.artwork, this.earned, this.progress);

  final Artwork artwork;
  final Set<FoolFragment> earned;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _journeyArea.width);
    canvas.translate(-_journeyArea.left, -_journeyArea.top);
    canvas.clipRect(_journeyArea);
    artwork.paint(canvas, Art.foolJourney);

    final moving = <(Path, Offset)>[];
    for (final fragment in FoolFragment.values) {
      final owned = earned.contains(fragment);
      final delay = fragment.index * .045;
      final arrival = ((progress - delay) / .54).clamp(0.0, 1.0);
      if (owned && arrival == 1) continue;
      final path = fragment.path;
      canvas.drawPath(path, Paint()..color = _socket);
      canvas.drawPath(
        path,
        Paint()
          ..color = mutedInk
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      if (owned) {
        final distance = 1 - Curves.easeOutCubic.transform(arrival);
        final side = path.getBounds().center.dx < _journeyArea.center.dx
            ? 1
            : -1;
        moving.add((path, Offset(side * 35 * distance, -22 * distance)));
      }
    }

    for (final (path, offset) in moving) {
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.drawPath(
        path.shift(const Offset(2, 3)),
        Paint()..color = mutedInk,
      );
      paintFoolFragment(canvas, artwork, path);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FoolJourneyPainter oldDelegate) =>
      oldDelegate.artwork != artwork ||
      oldDelegate.earned != earned ||
      oldDelegate.progress != progress;
}
