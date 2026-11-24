import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../artwork.dart';
import '../dialogs.dart';
import '../fool/fool_fragments.dart';
import '../fool/power_deck.dart';
import '../l10n/generated/app_localizations.dart';
import '../tarot_card_face.dart';
import '../visuals.dart';

const _journeyArea = Rect.fromLTWH(14, 29, 212, 303);
const _socket = Color(0xFFE8D6AA);
const foolFirstReading = '012';

Future<void> showFoolJourney(
  BuildContext context,
  Artwork artwork,
  Set<FoolFragment> earned, {
  bool leapAcquired = false,
  bool acquiring = false,
}) {
  final strings = AppLocalizations.of(context)!;
  final reducedMotion = MediaQuery.disableAnimationsOf(context);
  return showDialog<void>(
    context: context,
    builder: (context) => PaperDialog(
      key: Key(acquiring ? 'leap-acquisition' : 'fool-journey'),
      title: leapAcquired ? strings.leapPower : strings.foolChapter,
      titleContent: leapAcquired
          ? DecoratedBox(
              key: const Key('leap-title-box'),
              decoration: BoxDecoration(
                color: parchment,
                border: Border.all(color: ink),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    const LeapSymbol(),
                    Flexible(
                      child: Text(strings.leapPower, style: displayType(26)),
                    ),
                  ],
                ),
              ),
            )
          : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          if (leapAcquired) ...[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 156),
                child: TarotCardFace(
                  key: const Key('abstract-fool-card'),
                  title: strings.foolChapter,
                  illustration: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: acquiring && !reducedMotion && earned.isNotEmpty
                        ? const Duration(milliseconds: 1850)
                        : Duration.zero,
                    child: SvgPicture.asset(
                      AppAssets.foolCard,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                    builder: (context, progress, face) {
                      final assembly = (progress / .68).clamp(0.0, 1.0);
                      final reveal = Curves.easeInOut.transform(
                        ((progress - .78) / .22).clamp(0.0, 1.0),
                      );
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox.fromSize(
                              size: _journeyArea.size,
                              child: CustomPaint(
                                key: const Key('fool-card-fragment-slots'),
                                painter: _FoolJourneyPainter(
                                  artwork,
                                  earned,
                                  assembly,
                                ),
                              ),
                            ),
                          ),
                          Opacity(opacity: reveal, child: face),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Text(
              strings.leapDescription,
              textAlign: TextAlign.center,
              style: labelType.copyWith(letterSpacing: 0, height: 1.25),
            ),
            Text(
              strings.leapUsesPerAttempt,
              textAlign: TextAlign.center,
              style: labelType.copyWith(color: mutedInk, letterSpacing: 0),
            ),
          ] else ...[
            AspectRatio(
              aspectRatio: _journeyArea.size.aspectRatio,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: reducedMotion || earned.isEmpty
                    ? Duration.zero
                    : const Duration(milliseconds: 1050),
                builder: (context, progress, child) => CustomPaint(
                  painter: _FoolJourneyPainter(artwork, earned, progress),
                ),
              ),
            ),
            Text(
              strings.foolFragments(earned.length, FoolFragment.values.length),
              style: labelType,
              textAlign: TextAlign.center,
            ),
          ],
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
