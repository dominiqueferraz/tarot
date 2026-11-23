import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import '../artwork.dart';
import '../fool/puzzle_definition.dart';
import '../fool/puzzle_page.dart';
import '../fool/puzzle_presentation.dart';
import '../fool/tableau_art.dart';
import '../l10n/generated/app_localizations.dart';
import '../visuals.dart';
import 'phase_preview.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({
    required this.catalog,
    required this.artwork,
    required this.unlockedIndex,
    required this.onUnlock,
    super.key,
  });

  final PuzzleCatalog catalog;
  final Artwork artwork;
  final ValueListenable<int> unlockedIndex;
  final void Function(PuzzleDefinition) onUnlock;

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(
        math.min(
          widget.unlockedIndex.value * CampaignStyle.phaseSpacing,
          _scroll.position.maxScrollExtent,
        ),
      );
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  MaterialPageRoute<void> _previewRoute(int phase) => MaterialPageRoute(
    builder: (context) => ValueListenableBuilder<int>(
      valueListenable: widget.unlockedIndex,
      builder: (context, unlocked, child) => PhasePreview(
        puzzle: widget.catalog.puzzles[phase],
        artwork: widget.artwork,
        onPlay: phase <= unlocked
            ? () => Navigator.of(context).pushReplacement(_puzzleRoute(phase))
            : null,
      ),
    ),
  );

  MaterialPageRoute<void> _puzzleRoute(int phase) {
    final puzzle = widget.catalog.puzzles[phase];
    final next = widget.catalog.next(puzzle);
    return MaterialPageRoute(
      builder: (context) => PuzzlePage(
        puzzle: puzzle,
        phaseNumber: phase + 1,
        artwork: widget.artwork,
        onClear: next == null ? null : () => widget.onUnlock(next),
        onContinue: next == null
            ? null
            : (context) =>
                  Navigator.of(context)
                      .pushReplacement(_previewRoute(phase + 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final puzzles = widget.catalog.puzzles;
    return Scaffold(
      key: const Key('campaign-path'),
      body: PaperSurface(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CampaignStyle.sideInset,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: strings.home,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          strings.foolChapter,
                          textAlign: TextAlign.center,
                          style: displayType(33),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Divider(height: 1, color: rule),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, view) {
                    final width = math.min(
                      view.maxWidth,
                      CampaignStyle.maxWidth,
                    );
                    final routeHeight =
                        CampaignStyle.lowerMargin +
                        CampaignStyle.upperMargin +
                        CampaignStyle.phaseSpacing * (puzzles.length - 1);
                    final height = math.max(view.maxHeight, routeHeight);
                    final stops = [
                      for (var index = 0; index < puzzles.length; index++)
                        Offset(
                          width / 2 +
                              (index.isEven ? -1 : 1) *
                                  CampaignStyle.phaseLaneOffset,
                          height -
                              CampaignStyle.lowerMargin -
                              index * CampaignStyle.phaseSpacing,
                        ),
                    ];
                    return SingleChildScrollView(
                      controller: _scroll,
                      reverse: true,
                      child: Center(
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: ValueListenableBuilder<int>(
                            valueListenable: widget.unlockedIndex,
                            builder: (context, unlocked, child) => Stack(
                              fit: StackFit.expand,
                              children: [
                                CustomPaint(
                                  painter: _TrailPainter(stops, unlocked),
                                ),
                                for (final (index, puzzle) in puzzles.indexed)
                                  if (index % CampaignStyle.fragmentCycle < 2)
                                    _fragment(
                                      puzzle,
                                      width,
                                      stops[index],
                                      index.isEven,
                                    ),
                                for (final (index, puzzle) in puzzles.indexed)
                                  _phase(
                                    strings,
                                    puzzle,
                                    stops[index],
                                    index,
                                    unlocked,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fragment(
    PuzzleDefinition puzzle,
    double width,
    Offset stop,
    bool right,
  ) {
    final fragmentWidth = math.min(
      width * CampaignStyle.fragmentWidthFraction,
      CampaignStyle.fragmentMaxWidth,
    );
    const margin = CampaignStyle.fragmentInset * 2;
    final fragmentHeight =
        (fragmentWidth - margin) / CampaignStyle.fragmentAspect + margin;
    final center = width * (right ? .82 : .17);
    return Positioned(
      left: center - fragmentWidth / 2,
      top: stop.dy + CampaignStyle.fragmentDrop - fragmentHeight / 2,
      width: fragmentWidth,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Transform.rotate(
            angle: right ? .12 : -.13,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: parchment,
                border: Border.all(color: mutedInk),
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [BoxShadow(color: rule, offset: Offset(3, 4))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(CampaignStyle.fragmentInset),
                child: AspectRatio(
                  aspectRatio: CampaignStyle.fragmentAspect,
                  child: ClipRect(
                    child: CustomPaint(
                      painter: _DeckFragment(
                        widget.artwork,
                        puzzle.scoringSuits.contains(Suit.cup)
                            ? Art.cupsFragment
                            : Art.foolFragment,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _phase(
    AppLocalizations strings,
    PuzzleDefinition puzzle,
    Offset stop,
    int index,
    int unlocked,
  ) {
    final title = puzzleWords(strings, puzzle.textKey).title;
    const tapWidth =
        CampaignStyle.medallion + CampaignStyle.suitBadgeOverhang * 2;
    final locked = index > unlocked;
    final current = index == unlocked;
    void open() => Navigator.of(context).push(_previewRoute(index));

    return Positioned(
      left: stop.dx - tapWidth / 2,
      top: stop.dy - CampaignStyle.phaseTapHeight / 2,
      width: tapWidth,
      height: CampaignStyle.phaseTapHeight,
      child: Semantics(
        sortKey: OrdinalSortKey(index.toDouble()),
        label: strings.labelWithDetail(
          strings.phaseLabel(index + 1, title),
          suitNames(strings, puzzle.scoringSuits),
        ),
        value: locked ? strings.lockedPhase : null,
        button: true,
        onTap: open,
        child: ExcludeSemantics(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              key: Key('phase-${puzzle.id}'),
              borderRadius: BorderRadius.circular(
                CampaignStyle.phaseTapHeight / 2,
              ),
              onTap: open,
              child: Center(
                child: _medallion(
                  puzzle: puzzle,
                  number: index + 1,
                  locked: locked,
                  border: current ? rust : rule,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _medallion({
    required PuzzleDefinition puzzle,
    required int number,
    required bool locked,
    required Color border,
  }) => Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        key: Key('phase-medallion-${puzzle.id}'),
        width: CampaignStyle.medallion,
        height: CampaignStyle.medallion,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: paper,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 1.6),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: locked ? parchment : ink,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                AppLocalizations.of(context)!.puzzleIndex(number),
                style: displayType(CampaignStyle.phaseNumberSize)
                    .copyWith(color: locked ? mutedInk : paleGold),
              ),
            ),
          ),
        ),
      ),
      if (locked)
        Positioned(
          left: -CampaignStyle.suitBadgeOverhang,
          top: (CampaignStyle.medallion - CampaignStyle.lockBadge) / 2,
          child: Container(
            width: CampaignStyle.lockBadge,
            height: CampaignStyle.lockBadge,
            decoration: BoxDecoration(
              color: paper,
              shape: BoxShape.circle,
              border: Border.all(color: border),
            ),
            child: const Icon(Icons.lock_outline, size: 11, color: mutedInk),
          ),
        ),
      Positioned(
        right: -CampaignStyle.suitBadgeOverhang,
        top: (CampaignStyle.medallion - CampaignStyle.suitBadge) / 2,
        child: Container(
          key: Key('phase-suit-${puzzle.id}'),
          width: CampaignStyle.suitBadge,
          height: CampaignStyle.suitBadge,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: paper,
            shape: BoxShape.circle,
            border: Border.all(color: border),
          ),
          child: CustomPaint(
            painter: SuitPainter(widget.artwork, puzzle.scoringSuits),
          ),
        ),
      ),
    ],
  );
}

class _DeckFragment extends CustomPainter {
  const _DeckFragment(this.artwork, this.art);

  final Artwork artwork;
  final Art art;

  @override
  void paint(Canvas canvas, Size size) =>
      artwork.paint(canvas, art, scale: size.width / 126);

  @override
  bool shouldRepaint(_DeckFragment oldDelegate) =>
      oldDelegate.artwork != artwork || oldDelegate.art != art;
}

class _TrailPainter extends CustomPainter {
  const _TrailPainter(this.stops, this.unlocked);

  final List<Offset> stops;
  final int unlocked;

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(
      size.width / 2,
      size.height - CampaignStyle.trailEndInset,
    );
    final finish = Offset(size.width / 2, CampaignStyle.trailEndInset);
    final points = [start, ...stops, finish];
    for (var i = 0; i < points.length - 1; i++) {
      final from = points[i];
      final to = points[i + 1];
      final extensionBend = i == points.length - 2
          ? math.min(size.width * .16, (from.dy - to.dy) / 9)
          : 0.0;
      final drift = (to.dx - from.dx) * .22 + extensionBend;
      final bend = (to.dy - from.dy) * .46;
      final segment = Path()
        ..moveTo(from.dx, from.dy)
        ..cubicTo(
          from.dx - drift,
          from.dy + bend,
          to.dx + drift,
          to.dy - bend,
          to.dx,
          to.dy,
        );
      canvas.drawPath(segment, _stroke(rule.withValues(alpha: .17), 13));
      if (i <= unlocked) {
        canvas.drawPath(segment, _stroke(gold, 3));
      } else {
        final metric = segment.computeMetrics().single;
        for (var position = 0.0; position < metric.length; position += 11) {
          canvas.drawPath(
            metric.extractPath(position, math.min(position + 5, metric.length)),
            _stroke(mutedInk.withValues(alpha: .55), 1.8),
          );
        }
      }
    }
    _star(canvas, start, 9, rust);
    _star(canvas, finish, 14, gold);
  }

  Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = width;

  void _star(Canvas canvas, Offset center, double radius, Color color) {
    final inset = radius * .23;
    canvas.drawCircle(center, radius + 6, _stroke(rule, 1));
    final star = Path()
      ..addPolygon([
        center.translate(0, -radius),
        center.translate(inset, -inset),
        center.translate(radius, 0),
        center.translate(inset, inset),
        center.translate(0, radius),
        center.translate(-inset, inset),
        center.translate(-radius, 0),
        center.translate(-inset, -inset),
      ], true);
    canvas.drawPath(star, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TrailPainter oldDelegate) =>
      oldDelegate.unlocked != unlocked || !listEquals(oldDelegate.stops, stops);
}
