import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import '../artwork.dart';
import '../fool/fool_fragments.dart';
import '../fool/puzzle_definition.dart';
import '../fool/puzzle_page.dart';
import '../fool/puzzle_presentation.dart';
import '../fool/tableau_art.dart';
import '../l10n/generated/app_localizations.dart';
import '../lives.dart';
import '../lives_indicator.dart';
import '../visuals.dart';
import 'fool_journey.dart';
import 'phase_preview.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({
    required this.catalog,
    required this.artwork,
    required this.lives,
    required this.unlockedIndex,
    required this.onClear,
    super.key,
  });

  final PuzzleCatalog catalog;
  final Artwork artwork;
  final LifePool lives;
  final ValueListenable<int> unlockedIndex;
  final void Function(PuzzleDefinition) onClear;

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
          math.min(
                widget.unlockedIndex.value,
                widget.catalog.puzzles.length - 1,
              ) *
              CampaignStyle.phaseSpacing,
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
        lives: widget.lives,
        onPlay: phase <= unlocked
            ? () {
                if (widget.lives.remaining > 0) {
                  Navigator.of(context).pushReplacement(_puzzleRoute(phase));
                }
              }
            : null,
      ),
    ),
  );

  Set<FoolFragment> _earnedFragments() => {
    for (final puzzle in widget.catalog.puzzles.take(
      widget.unlockedIndex.value,
    ))
      ?FoolFragment.byPhase[puzzle.id],
  };

  MaterialPageRoute<void> _puzzleRoute(int phase) {
    final puzzle = widget.catalog.puzzles[phase];
    final hasNext = widget.catalog.next(puzzle) != null;
    final firstClear = phase == widget.unlockedIndex.value;
    final fragmentReward = firstClear ? FoolFragment.byPhase[puzzle.id] : null;
    final assemblesJourney = fragmentReward == FoolFragment.values.last;
    final earnsLeap = firstClear && puzzle.id == foolFirstReading;
    return MaterialPageRoute(
      builder: (context) => PuzzlePage(
        puzzle: puzzle,
        phaseNumber: phase + 1,
        artwork: widget.artwork,
        lives: widget.lives,
        onClear: () => widget.onClear(puzzle),
        fragmentReward: fragmentReward,
        continueLabel: earnsLeap
            ? AppLocalizations.of(context)!.viewLeap
            : assemblesJourney
            ? AppLocalizations.of(context)!.viewFoolJourney
            : null,
        onContinue: hasNext || assemblesJourney || earnsLeap
            ? (context) async {
                if (assemblesJourney || earnsLeap) {
                  await showFoolJourney(
                    context,
                    widget.artwork,
                    _earnedFragments(),
                    leapAcquired: earnsLeap,
                  );
                  if (!context.mounted) return;
                }
                final navigator = Navigator.of(context);
                if (hasNext) {
                  navigator.pushReplacement(_previewRoute(phase + 1));
                } else {
                  navigator.pop();
                }
              }
            : null,
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
                    SizedBox(
                      width: 68,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: IconButton(
                          tooltip: strings.home,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: TextButton(
                          key: const Key('view-fool-journey'),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          onPressed: () => showFoolJourney(
                            context,
                            widget.artwork,
                            _earnedFragments(),
                            leapAcquired: puzzles
                                .take(widget.unlockedIndex.value)
                                .any((puzzle) => puzzle.id == foolFirstReading),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 6,
                              children: [
                                Text(
                                  strings.foolChapter,
                                  style: displayType(33),
                                ),
                                const ExcludeSemantics(
                                  child: Icon(Icons.style_outlined, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    LivesIndicator(lives: widget.lives),
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

  Widget _phase(
    AppLocalizations strings,
    PuzzleDefinition puzzle,
    Offset stop,
    int index,
    int unlocked,
  ) {
    final title = puzzleWords(strings, puzzle.textKey).title;
    final count = puzzle.scoringSuits.length;
    final positions = suitOffsets(
      count,
      CampaignStyle.suitBadgeRadius,
      start: count.isEven ? -math.pi / 4 : 0,
    );
    const lockRadius = CampaignStyle.lockBadge / 2;
    const medallionRadius = CampaignStyle.medallion / 2;
    final lockOffset = count == 1
        ? medallionRadius + CampaignStyle.suitBadgeOverhang - lockRadius
        : medallionRadius + lockRadius + 1.0;
    final tapWidth =
        2.0 *
        math.max(
          lockOffset + lockRadius,
          positions.map((offset) => offset.dx.abs()).reduce(math.max) +
              CampaignStyle.suitBadge / 2,
        );
    final tapHeight = math.max(
      CampaignStyle.phaseTapHeight,
      2 * positions.map((offset) => offset.dy.abs()).reduce(math.max) +
          CampaignStyle.suitBadge,
    );
    final locked = index > unlocked;
    final current = index == unlocked;
    void open() => Navigator.of(context).push(_previewRoute(index));

    return Positioned(
      left: stop.dx - tapWidth / 2,
      top: stop.dy - tapHeight / 2,
      width: tapWidth,
      height: tapHeight,
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
              borderRadius: BorderRadius.circular(tapHeight / 2),
              onTap: open,
              child: _medallion(
                puzzle: puzzle,
                number: index + 1,
                locked: locked,
                border: current ? rust : rule,
                badgePositions: positions,
                lockOffset: lockOffset,
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
    required List<Offset> badgePositions,
    required double lockOffset,
  }) {
    final suits = puzzle.scoringSuits.toList();

    return Stack(
      alignment: Alignment.center,
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
          Transform.translate(
            offset: Offset(-lockOffset, 0),
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
        for (final (index, suit) in suits.indexed)
          Transform.translate(
            offset: badgePositions[index],
            child: Container(
              key: Key('phase-suit-${puzzle.id}-${suit.name}'),
              width: CampaignStyle.suitBadge,
              height: CampaignStyle.suitBadge,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: paper,
                shape: BoxShape.circle,
                border: Border.all(color: border),
              ),
              child: CustomPaint(painter: SuitPainter(widget.artwork, {suit})),
            ),
          ),
      ],
    );
  }
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
