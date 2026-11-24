import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../artwork.dart';
import '../dialogs.dart';
import '../l10n/generated/app_localizations.dart';
import '../lives.dart';
import '../lives_indicator.dart';
import '../visuals.dart';
import 'fool_fragments.dart';
import 'guide_hint.dart';
import 'puzzle_deal.dart';
import 'puzzle_presentation.dart';
import 'stroke.dart';
import 'tableau_art.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({
    required this.puzzle,
    required this.phaseNumber,
    required this.artwork,
    required this.lives,
    this.onClear,
    this.fragmentReward,
    this.continueLabel,
    this.onContinue,
    super.key,
  });

  final PuzzleDefinition puzzle;
  final int phaseNumber;
  final Artwork artwork;
  final LifePool lives;
  final VoidCallback? onClear;
  final FoolFragment? fragmentReward;
  final String? continueLabel;
  final void Function(BuildContext)? onContinue;

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> with TickerProviderStateMixin {
  static const _arrivalHeight = 22.0;
  static const _visibleArrivals = 3;

  late var _deal = PuzzleDeal(widget.puzzle);
  PuzzleDefinition get _puzzle => widget.puzzle;
  BoardSize get _size => _puzzle.size;
  bool get _animatesClear => _puzzle.scene != PuzzleScene.quay;
  bool get _showsArrivals => _deal.upcomingArrivals(0).isNotEmpty;
  Turn? _turn;
  Stroke? _demonstration;
  List<int> _path = [];
  Stroke? _preview;
  int? _activePointer;
  Offset? _lastPoint;
  int? _keyboardCell;
  bool _rejected = false;
  bool _reducedMotion = false;
  bool _ready = false;
  bool _confirmingExit = false;
  Timer? _rejectTimer;

  late final _guideMotion = AnimationController(vsync: this);
  late final _fallMotion =
      AnimationController(vsync: this, duration: BoardMotion.fall)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) _settled();
        });
  late final _sceneMotion =
      AnimationController(vsync: this, duration: BoardMotion.scene)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) setState(() {});
        });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (!_ready || reduced != _reducedMotion) {
      _ready = true;
      _reducedMotion = reduced;
      if (reduced && _turn != null) {
        _fallMotion.stop();
        _settled();
      }
      _animateGuide(_demonstration ?? _deal.demonstration);
    }
  }

  @override
  void dispose() {
    _rejectTimer?.cancel();
    _guideMotion.dispose();
    _fallMotion.dispose();
    _sceneMotion.dispose();
    super.dispose();
  }

  TargetLink? get _visibleLink {
    final turn = _turn;
    if (turn == null ||
        (turn.stroke.linkedTargets.isNotEmpty &&
            _fallMotion.value >= BoardMotion.releaseFraction)) {
      return _deal.link;
    }
    return turn.linkBefore;
  }

  bool get _acceptsInput =>
      _turn == null && !_deal.finished && !_confirmingExit;
  int _displayProgress(int cell) =>
      _turn?.progressBefore[cell] ??
      (_turn == null ? _deal.progressAt(cell) : 0);

  double get _fadeProgress =>
      _turn == null || _deal.faded.isEmpty || _reducedMotion
      ? 1
      : (_fallMotion.value / BoardMotion.fadeCueFraction).clamp(0.0, 1.0);

  double _fixtureProgress(int cell) {
    final fade = _turn == null ? 0 : _deal.faded[cell] ?? 0;
    return (_displayProgress(cell) -
            fade * Curves.easeOut.transform(_fadeProgress)) /
        _puzzle.targets[cell]!.quota;
  }

  double _sceneProgress(int cell) {
    final before = _displayProgress(cell);
    final after = _deal.progressAt(cell);
    if (_turn == null || after <= before) return _fixtureProgress(cell);
    const arrival = Interval(
      BoardMotion.releaseFraction,
      1,
      curve: Curves.easeOut,
    );
    final progress = arrival.transform(_fallMotion.value);
    return (before + (after - before) * progress) /
        _puzzle.targets[cell]!.quota;
  }

  double _guideCycle(Stroke clue) =>
      BoardMotion.guidePause + BoardMotion.guideStep * (clue.path.length - 1);

  void _animateGuide(Stroke? clue) {
    _guideMotion.stop();
    _demonstration = clue;
    if (clue != null && !_reducedMotion) {
      _guideMotion.duration = Duration(
        milliseconds: (_guideCycle(clue) * 2000).round(),
      );
      _guideMotion.forward(from: 0);
    }
  }

  void _settled() {
    setState(() {
      _turn = null;
      _animateGuide(_deal.demonstration);
      if (_deal.won && _animatesClear && !_reducedMotion) {
        _sceneMotion.forward(from: 0);
      }
    });
  }

  void _restart() {
    if (!_deal.lost || widget.lives.remaining == 0) return;
    _rejectTimer?.cancel();
    _fallMotion.stop();
    _sceneMotion.reset();
    setState(() {
      _deal = PuzzleDeal(_puzzle);
      _turn = null;
      _keyboardCell = null;
      _clearGesture();
      _animateGuide(_deal.demonstration);
    });
  }

  Future<void> _returnToPath() async {
    if (_confirmingExit) return;
    final navigator = Navigator.of(context);
    if (_deal.finished) {
      navigator.pop();
      return;
    }
    _confirmingExit = true;
    final strings = AppLocalizations.of(context)!;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => PaperDialog(
        title: strings.leavePuzzleTitle,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            LifeStatus(lives: widget.lives),
            Text(strings.leavePuzzleWarning),
          ],
        ),
        actions: [
          DialogAction(
            label: strings.keepPlaying,
            kind: DialogActionKind.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          DialogAction(
            label: strings.returnToPath,
            kind: DialogActionKind.destructive,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    _confirmingExit = false;
    if (leave == true && mounted) navigator.pop();
  }

  void _clearGesture() {
    _path = [];
    _preview = null;
    _activePointer = null;
    _lastPoint = null;
    _rejected = false;
  }

  void _commit() {
    if (!_acceptsInput || _path.isEmpty) return;
    final turn = _deal.play(_path);
    if (turn == null && _path.length > 1) {
      _rejectTimer?.cancel();
      setState(() => _rejected = true);
      _rejectTimer = Timer(BoardMotion.rejected, () {
        setState(() {
          _clearGesture();
          if (_deal.guide != null) _animateGuide(_deal.demonstration);
        });
      });
    } else {
      setState(() {
        _clearGesture();
        if (turn != null) _animateGuide(null);
        _turn = turn;
      });
      if (turn != null) {
        if (_deal.won) {
          widget.onClear?.call();
        } else if (_deal.lost) {
          widget.lives.loseLife();
        }
        if (_reducedMotion) {
          _settled();
        } else {
          _fallMotion.forward(from: 0);
        }
      }
    }
  }

  void _visit(int cell) {
    if (_path.isEmpty) {
      _path = [cell];
    } else if (_path.last == cell) {
      return;
    } else if (_path.length > 1 && _path[_path.length - 2] == cell) {
      _path.removeLast();
    } else if (_path.length > 1 && _path.first == _path.last) {
      return;
    } else if (_path.length > 1 && _path.first == cell) {
      final loop = [..._path, cell];
      _path = _deal.inspect(loop) == null ? [cell] : loop;
    } else if (!_path.contains(cell)) {
      _path.add(cell);
    }
    _preview = _deal.inspect(_path);
  }

  int? _hit(Offset point, double pitch, {bool centered = true}) {
    final column = (point.dx / pitch).floor();
    final row = (point.dy / pitch).floor();
    final cell = _size.cellAt(column, row);
    if (cell == null || !centered) return cell;
    final delta = Offset(
      point.dx / pitch - column - .5,
      point.dy / pitch - row - .5,
    );
    return delta.distanceSquared <= BoardStyle.hitRadius * BoardStyle.hitRadius
        ? cell
        : null;
  }

  void _pointerDown(PointerDownEvent event, double pitch) {
    if (!_acceptsInput ||
        _activePointer != null ||
        (event.buttons & kPrimaryButton) == 0) {
      return;
    }
    final cell = _hit(event.localPosition, pitch, centered: false);
    if (cell == null || _puzzle.masked.contains(cell)) return;
    _rejectTimer?.cancel();
    setState(() {
      _clearGesture();
      _keyboardCell = null;
      _activePointer = event.pointer;
      _lastPoint = event.localPosition;
      _visit(cell);
    });
  }

  void _pointerMove(PointerEvent event, double pitch) {
    if (event.pointer != _activePointer || _lastPoint == null) return;
    final start = _lastPoint!;
    final end = event.localPosition;
    final steps = ((end - start).distance / (pitch / 6)).ceil().clamp(
      1,
      math.max(128, 6 * math.max(_size.columns, _size.rows)),
    );
    setState(() {
      for (var step = 1; step <= steps; step++) {
        final cell = _hit(Offset.lerp(start, end, step / steps)!, pitch);
        if (cell != null) _visit(cell);
      }
      _lastPoint = end;
    });
  }

  void _pointerUp(PointerUpEvent event, double pitch) {
    if (event.pointer != _activePointer) return;
    _pointerMove(event, pitch);
    _activePointer = null;
    _lastPoint = null;
    _commit();
  }

  void _markCell(int cell) {
    if (!_acceptsInput || _activePointer != null) return;
    _rejectTimer?.cancel();
    setState(() {
      if (_rejected) _clearGesture();
      _keyboardCell = cell;
      _visit(cell);
    });
  }

  void _cancel() {
    _rejectTimer?.cancel();
    if (mounted) setState(_clearGesture);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if ((event is! KeyDownEvent && event is! KeyRepeatEvent) ||
        !_acceptsInput) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final current = _keyboardCell;
    final cell =
        current ??
        _demonstration?.path.first ??
        _deal.board.indexWhere((piece) => piece != null);
    final (dx, dy) = switch (key) {
      LogicalKeyboardKey.arrowLeft => (-1, 0),
      LogicalKeyboardKey.arrowRight => (1, 0),
      LogicalKeyboardKey.arrowUp => (0, -1),
      LogicalKeyboardKey.arrowDown => (0, 1),
      _ => (0, 0),
    };
    if (dx != 0 || dy != 0) {
      final neighbour = _size.cellAt(
        _size.columnOf(cell) + dx,
        _size.rowOf(cell) + dy,
      );
      setState(() {
        _keyboardCell =
            current == null ||
                neighbour == null ||
                _puzzle.masked.contains(neighbour)
            ? cell
            : neighbour;
      });
      return KeyEventResult.handled;
    }
    switch (key) {
      case LogicalKeyboardKey.space:
        _markCell(cell);
      case LogicalKeyboardKey.enter:
        _commit();
      case LogicalKeyboardKey.escape:
        if (_path.isEmpty) return KeyEventResult.ignored;
        _cancel();
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  bool get _showResult =>
      _deal.finished &&
      _turn == null &&
      (!_deal.won ||
          !_animatesClear ||
          _reducedMotion ||
          _sceneMotion.isCompleted);

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final page = Scaffold(
      body: PaperSurface(
        child: SafeArea(
          left: false,
          right: false,
          minimum: const EdgeInsets.only(top: 5, bottom: 9),
          child: LayoutBuilder(
            builder: (context, box) {
              final safe = MediaQuery.paddingOf(context);
              final sides = EdgeInsets.only(
                left: math.max(BoardStyle.outerPadding, safe.left),
                right: math.max(BoardStyle.outerPadding, safe.right),
              );
              final contentWidth = box.maxWidth - sides.horizontal;
              final wide =
                  contentWidth >= BoardStyle.wideBreakpoint &&
                  box.maxWidth > box.maxHeight;
              final scaler = MediaQuery.textScalerOf(context);
              final headerSpace = wide
                  ? 58.0
                  : 132 * scaler.scale(1).clamp(1, 2);
              final maxWidth = wide
                  ? contentWidth -
                        BoardStyle.sidebarWidth -
                        BoardStyle.sidebarGap
                  : math.min(BoardStyle.maxWidth, contentWidth);
              final tableauRatio =
                  1 / _size.aspectRatio + 1 / SceneLayout.ratio;
              final arrivalSpace = _showsArrivals
                  ? _arrivalHeight + BoardStyle.spacing
                  : 0.0;
              double widthFor(double height) => math
                  .min(maxWidth, height / tableauRatio)
                  .clamp(128.0, contentWidth)
                  .toDouble();
              double panelHeightFor(double width) =>
                  (width - BoardStyle.spacing - BoardStyle.frameWidth * 4) /
                  (SceneLayout.ratio + 1);
              final nominalHeight =
                  box.maxHeight -
                  headerSpace -
                  BoardStyle.spacing -
                  arrivalSpace;
              final headingWidth = widthFor(nominalHeight);
              final suitWidth =
                  panelHeightFor(headingWidth) + BoardStyle.frameWidth * 2;
              final words = puzzleWords(strings, _puzzle.textKey);
              final availableHeight = wide
                  ? nominalHeight
                  : math.min(
                      nominalHeight,
                      box.maxHeight -
                          kMinInteractiveDimension -
                          10 -
                          BoardStyle.spacing * 2 -
                          BoardStyle.frameWidth * 4 -
                          arrivalSpace -
                          _headingHeight(
                            context,
                            words,
                            headingWidth - suitWidth - 12,
                          ),
                    );
              final width = widthFor(availableHeight);
              final panelHeight = panelHeightFor(width);
              final heading = _heading(
                strings,
                words,
                wide: wide,
                suitWidth: suitWidth,
              );
              final boardWidth = math.min(
                width - BoardStyle.frameWidth * 2,
                math.max(1.0, availableHeight - panelHeight) *
                    _size.aspectRatio,
              );
              final resultOnBoard =
                  boardWidth / _size.aspectRatio >= BoardStyle.resultMinHeight;
              final board = _tableau(
                strings,
                width,
                panelHeight,
                boardWidth,
                showResult: _showResult && resultOnBoard,
              );
              final content = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _navigation(strings, sides),
                  const SizedBox(height: 5),
                  Padding(
                    padding: sides,
                    child: wide
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: BoardStyle.sidebarWidth,
                                child: heading,
                              ),
                              const SizedBox(width: BoardStyle.sidebarGap),
                              board,
                            ],
                          )
                        : Center(
                            child: SizedBox(
                              width: headingWidth,
                              child: Column(
                                children: [
                                  heading,
                                  const SizedBox(height: 5),
                                  board,
                                  const SizedBox(height: BoardStyle.spacing),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              );
              return _showResult && !resultOnBoard
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        content,
                        BlockSemantics(child: _result(strings)),
                      ],
                    )
                  : content;
            },
          ),
        ),
      ),
    );
    return PopScope<void>(
      canPop: _deal.finished,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          if (!_deal.finished) widget.lives.loseLife();
        } else {
          _returnToPath();
        }
      },
      child: page,
    );
  }

  String _guideExplanation(
    AppLocalizations strings,
    GuideCue cue,
    Stroke stroke,
  ) {
    final suit = suitName(strings, stroke.suit);
    final instruction = switch (cue) {
      GuideCue.match => strings.guideMatch,
      GuideCue.square => strings.guideSquare,
      GuideCue.rectangle => strings.guideRectangle,
      GuideCue.enclose => strings.guideEnclose(suit),
      GuideCue.aim => strings.guideAim(suit),
      GuideCue.wildcard => strings.guideWildcard,
      GuideCue.linkSquare => strings.guideLinkSquare(
        suit,
        stroke.linkedTargets.length,
      ),
      GuideCue.linkedAim => strings.guideLinkedAim(
        suit,
        stroke.gains.values.first,
      ),
    };
    if ((cue != GuideCue.aim && cue != GuideCue.enclose) ||
        stroke.gains.isEmpty) {
      return instruction;
    }
    final gains = stroke.gains.entries.map((entry) {
      final target = _puzzle.targets[entry.key]!;
      return strings.targetGain(
        targetName(strings, target.label),
        targetAmount(strings, target.kind, entry.value),
      );
    });
    return strings.guideWithGains(
      instruction,
      gains.reduce(strings.labelWithDetail),
    );
  }

  Widget _navigation(AppLocalizations strings, EdgeInsets sides) {
    final link = _visibleLink;
    return Stack(
      alignment: Alignment.center,
      children: [
        const Positioned(
          left: 0,
          right: 0,
          child: Divider(key: Key('fool-header-rule'), height: 1, color: rule),
        ),
        Padding(
          padding: sides,
          child: Row(
            children: [
              PaperSurface(
                child: IconButton(
                  onPressed: _returnToPath,
                  tooltip: strings.returnToPath,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              PaperSurface(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(2, 4, 10, 4),
                  child: Text(
                    strings.puzzleIndex(widget.phaseNumber),
                    semanticsLabel: strings.puzzleNumber(widget.phaseNumber),
                    style: labelType.copyWith(color: mutedInk),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (link != null)
                        PaperSurface(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              strings.linkMovesRemaining(link.movesLeft),
                              style: labelType.copyWith(color: blue),
                            ),
                          ),
                        ),
                      if (_deal.guide != null)
                        PaperSurface(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Semantics(
                              label: strings.guideStepProgress(
                                _deal.moves + 1,
                                _deal.guideLength,
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 5,
                                runSpacing: 3,
                                children: [
                                  for (var i = 0; i < _deal.guideLength; i++)
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: i < _deal.moves
                                            ? ink
                                            : i == _deal.moves
                                            ? gold
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: i <= _deal.moves ? ink : rule,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle get _objectiveStyle =>
      labelType.copyWith(fontSize: 14, color: mutedInk);

  double _headingHeight(
    BuildContext context,
    ({String title, String objective}) words,
    double width,
  ) {
    final inheritedStyle = DefaultTextStyle.of(context).style;
    final painter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
    );
    double measure(String text, TextStyle style) {
      painter.text = TextSpan(text: text, style: inheritedStyle.merge(style));
      painter.layout(maxWidth: width);
      return painter.height;
    }

    final height =
        measure(words.title, displayType(38)) +
        5 +
        measure(words.objective, _objectiveStyle);
    painter.dispose();
    return math.max(height, BoardStyle.movesDiameter);
  }

  Widget _heading(
    AppLocalizations strings,
    ({String title, String objective}) words, {
    required bool wide,
    required double suitWidth,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(words.title, style: displayType(wide ? 32 : 38)),
              ),
              const SizedBox(height: 5),
              Text(words.objective, style: _objectiveStyle),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: suitWidth,
          child: Center(child: _moves(strings, suitWidth)),
        ),
      ],
    );
  }

  Widget _moves(AppLocalizations strings, double maxDiameter) {
    final preferredDiameter =
        MediaQuery.textScalerOf(context).scale(21).clamp(21, 34).toDouble() +
        (BoardStyle.movesDiameter - 21);
    return Semantics(
      label: strings.movesRemaining(_deal.movesLeft),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: math.min(preferredDiameter, maxDiameter),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _deal.movesLeft < 5 ? rust : ink,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  strings.puzzleIndex(_deal.movesLeft),
                  style: labelType.copyWith(
                    color: paper,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableau(
    AppLocalizations strings,
    double width,
    double panelHeight,
    double boardWidth, {
    required bool showResult,
  }) {
    final boardHeight = boardWidth / _size.aspectRatio;
    final pitch = boardWidth / _size.columns;
    final guide = _demonstration;
    final lesson = _deal.guide;
    final faded = _deal.faded.entries.firstOrNull;
    final spilled = _deal.spilledCell;
    final hintCell = spilled ?? faded?.key;
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _frame(
                  SizedBox(
                    key: switch (_puzzle.scene) {
                      PuzzleScene.ridge => const Key('fool-ridge'),
                      PuzzleScene.quay => const Key('quay-scene'),
                      PuzzleScene.mill => const Key('mill-scene'),
                      PuzzleScene.dock => const Key('dock-scene'),
                      PuzzleScene.market => const Key('market-scene'),
                      PuzzleScene.breadStall => const Key('bread-stall-scene'),
                      PuzzleScene.sluice => const Key('sluice-scene'),
                      PuzzleScene.lampPath => const Key('lamp-path-scene'),
                      PuzzleScene.fishingLanding => const Key(
                        'fishing-landing-scene',
                      ),
                      PuzzleScene.nightFishing => const Key(
                        'night-fishing-scene',
                      ),
                    },
                    height: panelHeight,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_sceneMotion, _fallMotion]),
                      builder: (context, child) {
                        final motion = _deal.won && _reducedMotion
                            ? 1.0
                            : _sceneMotion.value;
                        return PuzzleIllustration(
                          artwork: widget.artwork,
                          puzzle: _puzzle,
                          progress: {
                            for (final cell in _puzzle.targets.keys)
                              cell: _sceneProgress(cell),
                          },
                          motion: motion,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: BoardStyle.spacing),
              _suitPanel(strings, panelHeight),
            ],
          ),
          const SizedBox(height: BoardStyle.spacing),
          if (_showsArrivals) ...[
            _arrivalStrip(strings, boardWidth),
            const SizedBox(height: BoardStyle.spacing),
          ],
          _frame(
            SizedBox(
              width: boardWidth,
              height: boardHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Focus(
                    autofocus: true,
                    onKeyEvent: _onKey,
                    child: Listener(
                      key: const Key('fool-grid'),
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (event) => _pointerDown(event, pitch),
                      onPointerMove: (event) => _pointerMove(event, pitch),
                      onPointerUp: (event) => _pointerUp(event, pitch),
                      onPointerCancel: (event) {
                        if (event.pointer == _activePointer) _cancel();
                      },
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _guideMotion,
                          _fallMotion,
                        ]),
                        child: _accessibilityGrid(strings, pitch),
                        builder: (context, child) {
                          final demonstration = _demonstration;
                          final cycle = demonstration == null
                              ? 1.0
                              : _guideCycle(demonstration);
                          return CustomPaint(
                            painter: TableauPainter(
                              board: _deal.board,
                              artwork: widget.artwork,
                              puzzle: _puzzle,
                              progress: {
                                for (final cell in _puzzle.targets.keys)
                                  cell: _fixtureProgress(cell),
                              },
                              fadeProgress: _fadeProgress,
                              fadedCells: _deal.faded.keys,
                              path: _path,
                              preview: _preview,
                              demonstration: demonstration,
                              guideTime:
                                  (_guideMotion.value * cycle * 2) % cycle,
                              turn: _turn,
                              link: _visibleLink,
                              turnProgress: _fallMotion.value,
                              keyboardCell: _keyboardCell,
                              reducedMotion: _reducedMotion,
                              rejected: _rejected,
                            ),
                            child: child,
                          );
                        },
                      ),
                    ),
                  ),
                  for (final cell in _puzzle.targets.keys)
                    _targetValue(strings, cell, pitch),
                  if (guide != null && lesson != null && _path.isEmpty)
                    Positioned.fill(
                      child: GuideHint(
                        pitch: pitch,
                        placement: lesson.hint,
                        explanation: _guideExplanation(
                          strings,
                          lesson.cue,
                          guide,
                        ),
                      ),
                    ),
                  if (_turn == null &&
                      hintCell != null &&
                      _path.isEmpty &&
                      !_showResult)
                    Positioned.fill(
                      child: GuideHint(
                        pitch: pitch,
                        placement: _targetHintPlacement(hintCell),
                        explanation: spilled != null
                            ? strings.fillTogetherHint
                            : _fadingHint(strings, _puzzle.targets[hintCell]!),
                      ),
                    ),
                  if (showResult) BlockSemantics(child: _result(strings)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrivalStrip(AppLocalizations strings, double boardWidth) {
    return _frame(
      SizedBox(
        key: const Key('arrival-ribbons'),
        width: boardWidth,
        height: _arrivalHeight,
        child: Row(
          children: [
            for (var column = 0; column < _size.columns; column++)
              Expanded(child: _columnArrivals(strings, column)),
          ],
        ),
      ),
    );
  }

  Widget _columnArrivals(AppLocalizations strings, int column) {
    final arrivals = _deal
        .upcomingArrivals(column)
        .take(_visibleArrivals)
        .toList();
    return Semantics(
      label: strings.incomingSuits(
        _size.cellLabel(column),
        suitNames(strings, arrivals),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: parchment,
          border: column == 0
              ? null
              : const Border(left: BorderSide(color: rule)),
        ),
        child: Row(
          children: [
            for (final (index, suit) in arrivals.indexed)
              Expanded(
                child: Opacity(
                  opacity: index == 0 ? 1 : .72,
                  child: CustomPaint(
                    painter: SuitPainter(widget.artwork, {suit}),
                    child: const SizedBox(height: _arrivalHeight - 5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _suitPanel(AppLocalizations strings, double size) {
    final suits = _puzzle.scoringSuits.toList();
    final mixed = suits.length > 1;
    final radius = mixed ? size * .28 : 0.0;
    final positions = suitOffsets(suits.length, radius, start: -math.pi / 2);
    final symbolSize = size * (mixed ? .42 : .82);

    return _frame(
      SizedBox.square(
        key: const Key('fool-suit-panel'),
        dimension: size,
        child: ColoredBox(
          color: parchment,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (mixed)
                SizedBox.square(
                  key: const Key('puzzle-suit-ring'),
                  dimension: 2 * radius,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(
                          color: mutedInk,
                          width: 1.25,
                          strokeAlign: BorderSide.strokeAlignCenter,
                        ),
                      ),
                    ),
                  ),
                ),
              for (final (index, suit) in suits.indexed)
                Transform.translate(
                  offset: positions[index],
                  child: Semantics(
                    key: Key('puzzle-suit-${suit.name}'),
                    label: suitName(strings, suit),
                    image: true,
                    child: SizedBox.square(
                      dimension: symbolSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (mixed)
                            SizedBox.square(
                              dimension: symbolSize * .72,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: parchment,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: SuitPainter(widget.artwork, {suit}),
                            ),
                          ),
                        ],
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

  Widget _targetValue(AppLocalizations strings, int cell, double pitch) {
    final target = _puzzle.targets[cell]!;
    final progress = _displayProgress(cell);
    return Positioned(
      left: _size.columnOf(cell) * pitch,
      top: (_size.rowOf(cell) + .73) * pitch,
      width: pitch,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Center(
            child: ColoredBox(
              color: ink,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pitch * .07),
                child: Text(
                  strings.targetProgress(progress, target.quota),
                  key: Key('target-value-${_size.cellLabel(cell)}'),
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: paper,
                    fontWeight: FontWeight.w800,
                    fontSize: pitch * .15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fadingHint(AppLocalizations strings, PuzzleTarget target) =>
      strings.targetFadingHint(
        targetName(strings, target.label),
        targetAmount(strings, target.kind, target.fading),
      );

  HintPlacement _targetHintPlacement(int cell) {
    final row = _size.rowOf(cell);
    return row < _size.rows - 2
        ? (x: _size.columnOf(cell) + .5, y: row + 1.04, tail: HintTail.top)
        : (x: _size.columnOf(cell) + .5, y: row + .10, tail: HintTail.bottom);
  }

  Widget _frame(Widget child) => DecoratedBox(
    decoration: BoxDecoration(
      color: ink,
      border: Border.all(color: ink, width: BoardStyle.frameWidth),
      boxShadow: const [
        BoxShadow(color: Color(0xFFC6B897), offset: Offset(3, 3)),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(BoardStyle.frameWidth),
      child: child,
    ),
  );

  Widget _accessibilityGrid(AppLocalizations strings, double pitch) {
    final labels = {
      Suit.wand: strings.wand,
      Suit.cup: strings.cup,
      Suit.sword: strings.sword,
      Suit.coin: strings.coin,
    };
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: _demonstration == null
          ? strings.board
          : strings.labelWithDetail(strings.board, strings.gestureGuide),
      child: Stack(
        children: List.generate(_size.cellCount, (cell) {
          final wall = _puzzle.masked.contains(cell);
          return Positioned(
            left: _size.columnOf(cell) * pitch,
            top: _size.rowOf(cell) * pitch,
            width: pitch,
            height: pitch,
            child: Semantics(
              sortKey: OrdinalSortKey(cell.toDouble()),
              label: strings.labelWithDetail(
                _size.cellLabel(cell),
                wall
                    ? strings.wall
                    : labels[_deal.board[cell]] ?? _targetLabel(strings, cell),
              ),
              selected: wall ? null : _path.contains(cell),
              onTap: _acceptsInput && !wall ? () => _markCell(cell) : null,
              customSemanticsActions: wall || _path.isEmpty
                  ? null
                  : {
                      CustomSemanticsAction(label: strings.commit): _commit,
                      CustomSemanticsAction(label: strings.cancel): _cancel,
                    },
              child: const SizedBox.expand(),
            ),
          );
        }),
      ),
    );
  }

  String _targetLabel(AppLocalizations strings, int cell) {
    final target = _puzzle.targets[cell]!;
    final label = strings.namedTargetProgress(
      targetName(strings, target.label),
      strings.targetProgress(_displayProgress(cell), target.quota),
    );
    final loss = _turn == null ? _deal.faded[cell] : null;
    return [
      label,
      if (_puzzle.scoringSuits.length > 1) suitName(strings, target.suit),
      if (target.aimDirection case final direction?)
        aimDirectionName(strings, direction),
      if (loss != null)
        strings.targetLostProgress(targetAmount(strings, target.kind, loss)),
    ].reduce(strings.labelWithDetail);
  }

  String _lossProgress(AppLocalizations strings) {
    final nameTargets = _puzzle.scoringSuits.length > 1 || _puzzle.fillTogether;
    return _puzzle.targets.entries
        .map((entry) {
          final progress = strings.targetProgress(
            _deal.progressAt(entry.key),
            entry.value.quota,
          );
          return nameTargets
              ? strings.namedTargetProgress(
                  targetName(strings, entry.value.label),
                  progress,
                )
              : progress;
        })
        .join(nameTargets ? '\n' : strings.progressSeparator);
  }

  Widget _winResult(AppLocalizations strings) => Column(
    mainAxisSize: MainAxisSize.min,
    spacing: 10,
    children: [
      if (widget.fragmentReward case final reward?)
        Semantics(
          container: true,
          label: strings.journeyFragmentFound,
          excludeSemantics: true,
          child: DecoratedBox(
            key: const Key('fragment-reward-box'),
            decoration: BoxDecoration(
              color: parchment,
              border: Border.all(color: rule),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                spacing: 10,
                children: [
                  SizedBox(
                    width: 52,
                    height: 44,
                    child: CustomPaint(
                      painter: _FragmentRewardPainter(widget.artwork, reward),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      strings.journeyFragmentFound,
                      style: labelType.copyWith(
                        letterSpacing: 0,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      Semantics(
        label: strings.starRating(_deal.stars),
        excludeSemantics: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              Icon(
                i < _deal.stars
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: i < _deal.stars ? rust : rule,
                size: 27,
              ),
          ],
        ),
      ),
    ],
  );

  Widget _result(AppLocalizations strings) {
    return ColoredBox(
      color: ink.withValues(alpha: .26),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: DialogPanel(
            content: _deal.won
                ? _winResult(strings)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      Text(strings.movesRemaining(0), style: _objectiveStyle),
                      Text(
                        _lossProgress(strings),
                        style: displayType(27),
                        textAlign: TextAlign.center,
                      ),
                      LifeStatus(lives: widget.lives, showDepletedLabel: true),
                    ],
                  ),
            actions: [
              if (_deal.won)
                DialogAction(
                  label:
                      widget.continueLabel ??
                      (widget.onContinue == null
                          ? strings.continueJourney
                          : strings.nextPuzzle),
                  onPressed: () {
                    final continuePuzzle = widget.onContinue;
                    if (continuePuzzle == null) {
                      Navigator.of(context).pop();
                    } else {
                      continuePuzzle(context);
                    }
                  },
                )
              else
                ListenableBuilder(
                  listenable: widget.lives,
                  builder: (context, child) => widget.lives.remaining > 0
                      ? DialogAction(label: strings.retry, onPressed: _restart)
                      : DialogAction(
                          label: strings.returnToPath,
                          onPressed: _returnToPath,
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FragmentRewardPainter extends CustomPainter {
  _FragmentRewardPainter(this.artwork, this.fragment) : shape = fragment.path;

  final Artwork artwork;
  final FoolFragment fragment;
  final Path shape;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = shape.getBounds();
    final scale = math.min(
      (size.width - 6) / bounds.width,
      (size.height - 6) / bounds.height,
    );
    final origin = size.center(Offset.zero) - bounds.center * scale;
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale);
    canvas.drawPath(
      shape.shift(Offset(1 / scale, 2 / scale)),
      Paint()..color = ink,
    );
    paintFoolFragment(canvas, artwork, shape);
    canvas.drawPath(
      shape,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 2 / scale,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FragmentRewardPainter oldDelegate) =>
      artwork != oldDelegate.artwork || fragment != oldDelegate.fragment;
}
