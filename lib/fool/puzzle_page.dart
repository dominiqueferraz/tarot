import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../artwork.dart';
import '../l10n/generated/app_localizations.dart';
import '../visuals.dart';
import 'puzzle_deal.dart';
import 'puzzle_presentation.dart';
import 'guide_hint.dart';
import 'stroke.dart';
import 'tableau_art.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({
    required this.puzzle,
    required this.artwork,
    this.onClear,
    this.onContinue,
    super.key,
  });

  final PuzzleDefinition puzzle;
  final Artwork artwork;
  final VoidCallback? onClear;
  final void Function(BuildContext)? onContinue;

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> with TickerProviderStateMixin {
  late var _deal = PuzzleDeal(widget.puzzle);
  PuzzleDefinition get _puzzle => widget.puzzle;
  bool get _atQuay => _puzzle.scene == PuzzleScene.quay;
  PuzzleWords get _words =>
      _puzzle.words(Localizations.localeOf(context).languageCode);
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
  Timer? _rejectTimer;

  late final _guideMotion = AnimationController(vsync: this);
  late final _fallMotion =
      AnimationController(vsync: this, duration: BoardMotion.fall)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) _settled();
        });
  late final _walkMotion =
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
    _walkMotion.dispose();
    super.dispose();
  }

  bool get _acceptsInput => _turn == null && !_deal.finished;
  int get _displayLight => _turn?.lightBefore ?? _deal.light;
  double get _fadeProgress =>
      _turn == null || _deal.faded == 0 || _reducedMotion
      ? 1
      : (_fallMotion.value / BoardMotion.fadeCueFraction).clamp(0.0, 1.0);

  double get _fixtureLight {
    final light = _displayLight;
    if (_turn == null || _deal.faded == 0) return light / _puzzle.target;
    return (light - _deal.faded * Curves.easeOut.transform(_fadeProgress)) /
        _puzzle.target;
  }

  double get _sceneLight {
    final turn = _turn;
    if (turn == null || _deal.light <= turn.lightBefore) return _fixtureLight;
    const arrival = Interval(
      BoardMotion.releaseFraction,
      1,
      curve: Curves.easeOut,
    );
    final progress = arrival.transform(_fallMotion.value);
    return (turn.lightBefore + (_deal.light - turn.lightBefore) * progress) /
        _puzzle.target;
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
      if (_deal.won && !_atQuay && !_reducedMotion) {
        _walkMotion.forward(from: 0);
      }
    });
  }

  void _restart() {
    _rejectTimer?.cancel();
    _fallMotion.stop();
    _walkMotion.reset();
    setState(() {
      _deal = PuzzleDeal(_puzzle);
      _turn = null;
      _keyboardCell = null;
      _clearGesture();
      _animateGuide(_deal.demonstration);
    });
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
        if (_deal.won) widget.onClear?.call();
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

  int? _hit(Offset point, double width, {bool centered = true}) {
    final column = (point.dx * boardSide / width).floor();
    final row = (point.dy * boardSide / width).floor();
    final cell = cellAt(column, row);
    if (cell == null || !centered) return cell;
    final delta = Offset(
      point.dx * boardSide / width - column - .5,
      point.dy * boardSide / width - row - .5,
    );
    return delta.distanceSquared <= BoardStyle.hitRadius * BoardStyle.hitRadius
        ? cell
        : null;
  }

  void _pointerDown(PointerDownEvent event, double width) {
    if (!_acceptsInput ||
        _activePointer != null ||
        (event.buttons & kPrimaryButton) == 0) {
      return;
    }
    final cell = _hit(event.localPosition, width, centered: false);
    if (cell == null) return;
    _rejectTimer?.cancel();
    setState(() {
      _clearGesture();
      _keyboardCell = null;
      _activePointer = event.pointer;
      _lastPoint = event.localPosition;
      _visit(cell);
    });
  }

  void _pointerMove(PointerEvent event, double width) {
    if (event.pointer != _activePointer || _lastPoint == null) return;
    final start = _lastPoint!;
    final end = event.localPosition;
    // Sample the intervening cells so fast swipes behave like slow ones.
    final steps = ((end - start).distance / (width / boardSide / 6))
        .ceil()
        .clamp(1, 128);
    setState(() {
      for (var step = 1; step <= steps; step++) {
        final cell = _hit(Offset.lerp(start, end, step / steps)!, width);
        if (cell != null) _visit(cell);
      }
      _lastPoint = end;
    });
  }

  void _pointerUp(PointerUpEvent event, double width) {
    if (event.pointer != _activePointer) return;
    _pointerMove(event, width);
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
    final cell = current ?? _demonstration?.path.first ?? 0;
    final (dx, dy) = switch (key) {
      LogicalKeyboardKey.arrowLeft => (-1, 0),
      LogicalKeyboardKey.arrowRight => (1, 0),
      LogicalKeyboardKey.arrowUp => (0, -1),
      LogicalKeyboardKey.arrowDown => (0, 1),
      _ => (0, 0),
    };
    if (dx != 0 || dy != 0) {
      setState(
        () => _keyboardCell = current == null
            ? cell
            : cellAt(columnOf(cell) + dx, rowOf(cell) + dy) ?? cell,
      );
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
      (!_deal.won || _atQuay || _reducedMotion || _walkMotion.isCompleted);

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
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
              final headerSpace = wide ? 58 : 132 * scaler.scale(1).clamp(1, 2);
              final availableHeight =
                  box.maxHeight - headerSpace - BoardStyle.spacing;
              final maxWidth = wide
                  ? contentWidth -
                        BoardStyle.sidebarWidth -
                        BoardStyle.sidebarGap
                  : math.min(BoardStyle.maxWidth, contentWidth);
              final size = math.min(
                maxWidth,
                availableHeight / (1 + 1 / SceneLayout.ratio),
              );
              final width = size.clamp(128.0, contentWidth).toDouble();
              final panelHeight =
                  (width - BoardStyle.spacing - BoardStyle.frameWidth * 4) /
                  (SceneLayout.ratio + 1);
              final heading = _heading(
                strings,
                wide: wide,
                suitWidth: panelHeight + BoardStyle.frameWidth * 2,
              );
              final board = _tableau(strings, width, panelHeight, _showResult);
              return Column(
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
                              width: width,
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
            },
          ),
        ),
      ),
    );
  }

  String _guideExplanation(AppLocalizations strings, GuideCue cue, int light) =>
      switch (cue) {
        GuideCue.match => strings.guideMatch,
        GuideCue.square => strings.guideSquare,
        GuideCue.rectangle => strings.guideCupRectangle,
        GuideCue.enclose => strings.guideEnclose(
          light,
          suitName(strings, _puzzle.scoringSuit),
        ),
        GuideCue.aim => strings.guideAim(
          light,
          suitName(strings, _puzzle.scoringSuit),
        ),
        GuideCue.wildcard => strings.guideCoinWildcard,
      };

  Widget _navigation(AppLocalizations strings, EdgeInsets sides) {
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
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: strings.campaignPath,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const Spacer(),
              if (_deal.guide != null)
                PaperSurface(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Semantics(
                      label: '${_deal.moves + 1}/${_deal.guideLength}',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < _deal.guideLength; i++)
                            Container(
                              width: 7,
                              height: 7,
                              margin: EdgeInsets.only(left: i == 0 ? 0 : 5),
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
      ],
    );
  }

  Widget _heading(
    AppLocalizations strings, {
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
                child: Text(_words.title, style: displayType(wide ? 32 : 38)),
              ),
              const SizedBox(height: 5),
              Text(
                _words.objective,
                style: labelType.copyWith(fontSize: 14, color: mutedInk),
              ),
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
                  '${_deal.movesLeft}',
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
    bool finished,
  ) {
    final inside = width - BoardStyle.frameWidth * 2;
    final guide = _demonstration;
    final lesson = _deal.guide;
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
                    key: Key(_atQuay ? 'quay-scene' : 'fool-ridge'),
                    height: panelHeight,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_walkMotion, _fallMotion]),
                      builder: (context, child) {
                        final motion = _deal.won && _reducedMotion
                            ? 1.0
                            : _walkMotion.value;
                        return PuzzleIllustration(
                          artwork: widget.artwork,
                          scene: _puzzle.scene,
                          light: _sceneLight,
                          walk: motion,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: BoardStyle.spacing),
              Semantics(
                label: suitName(strings, _puzzle.scoringSuit),
                image: true,
                child: _frame(
                  SizedBox.square(
                    key: const Key('fool-suit-panel'),
                    dimension: panelHeight,
                    child: ColoredBox(
                      color: parchment,
                      child: FractionallySizedBox(
                        widthFactor: .82,
                        heightFactor: .82,
                        child: CustomPaint(
                          painter: SuitPainter(
                            widget.artwork,
                            _puzzle.scoringSuit,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BoardStyle.spacing),
          _frame(
            SizedBox.square(
              dimension: inside,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Focus(
                    autofocus: true,
                    onKeyEvent: _onKey,
                    child: Listener(
                      key: const Key('fool-grid'),
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (event) => _pointerDown(event, inside),
                      onPointerMove: (event) => _pointerMove(event, inside),
                      onPointerUp: (event) => _pointerUp(event, inside),
                      onPointerCancel: (event) {
                        if (event.pointer == _activePointer) _cancel();
                      },
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _guideMotion,
                          _fallMotion,
                        ]),
                        child: _accessibilityGrid(strings, inside),
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
                              light: _fixtureLight,
                              fadeProgress: _fadeProgress,
                              path: _path,
                              preview: _preview,
                              demonstration: demonstration,
                              guideTime:
                                  (_guideMotion.value * cycle * 2) % cycle,
                              turn: _turn,
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
                  _markerValue(inside / boardSide),
                  if (guide != null && lesson != null && _path.isEmpty)
                    Positioned.fill(
                      child: GuideHint(
                        placement: lesson.hint,
                        explanation: _guideExplanation(
                          strings,
                          lesson.cue,
                          guide.light,
                        ),
                      ),
                    ),
                  if (_turn == null &&
                      _deal.faded > 0 &&
                      _path.isEmpty &&
                      !finished)
                    Positioned.fill(
                      child: GuideHint(
                        placement: _fadeHintPlacement,
                        explanation: strings.lampFadingHint(_puzzle.fading),
                      ),
                    ),
                  if (finished) BlockSemantics(child: _result(strings)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _markerValue(double pitch) {
    return Positioned(
      left: columnOf(_puzzle.marker) * pitch,
      top: (rowOf(_puzzle.marker) + .73) * pitch,
      width: pitch,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Center(
            child: ColoredBox(
              color: ink,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pitch * .07),
                child: Text(
                  '$_displayLight/${_puzzle.target}',
                  key: Key(_atQuay ? 'quay-lamp-value' : 'trail-marker-value'),
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

  HintPlacement get _fadeHintPlacement {
    final row = rowOf(_puzzle.marker);
    return row < boardSide - 2
        ? (x: columnOf(_puzzle.marker) + .5, y: row + 1.04, tail: HintTail.top)
        : (
            x: columnOf(_puzzle.marker) + .5,
            y: row + .10,
            tail: HintTail.bottom,
          );
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

  Widget _accessibilityGrid(AppLocalizations strings, double width) {
    final pitch = width / boardSide;
    final labels = {
      Suit.wand: strings.wand,
      Suit.cup: strings.cup,
      Suit.sword: strings.sword,
      Suit.coin: strings.coin,
    };
    final markerLabel = [
      '${_words.target} $_displayLight/${_puzzle.target}',
      if (_turn == null && _deal.faded > 0) strings.lampFaded(_deal.faded),
    ].join(', ');
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: _demonstration == null
          ? strings.board
          : '${strings.board}, ${strings.gestureGuide}',
      child: Stack(
        children: [
          for (var cell = 0; cell < cellCount; cell++)
            Positioned(
              left: columnOf(cell) * pitch,
              top: rowOf(cell) * pitch,
              width: pitch,
              height: pitch,
              child: Semantics(
                sortKey: OrdinalSortKey(cell.toDouble()),
                label:
                    '${String.fromCharCode(65 + columnOf(cell))}${rowOf(cell) + 1}, '
                    '${labels[_deal.board[cell]] ?? markerLabel}',
                selected: _path.contains(cell),
                onTap: _acceptsInput ? () => _markCell(cell) : null,
                customSemanticsActions: _path.isEmpty
                    ? null
                    : {
                        CustomSemanticsAction(label: strings.commit): _commit,
                        CustomSemanticsAction(label: strings.cancel): _cancel,
                      },
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _result(AppLocalizations strings) {
    return ColoredBox(
      color: ink.withValues(alpha: .26),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(14),
          constraints: const BoxConstraints(maxWidth: 285),
          decoration: BoxDecoration(
            color: paper,
            border: Border.all(color: ink, width: 1.5),
            boxShadow: const [BoxShadow(color: ink, offset: Offset(4, 4))],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_deal.won)
                Semantics(
                  label: '${_deal.stars}/3',
                  excludeSemantics: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 6),
              Text(
                _deal.won ? strings.clear : '${_deal.light}/${_puzzle.target}',
                style: displayType(27),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: _deal.won
                    ? () {
                        final continuePuzzle = widget.onContinue;
                        if (continuePuzzle == null) {
                          Navigator.of(context).pop();
                        } else {
                          continuePuzzle(context);
                        }
                      }
                    : _restart,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 46),
                  textStyle: labelType,
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(
                  !_deal.won
                      ? strings.retry
                      : widget.onContinue == null
                      ? strings.campaignPath
                      : strings.nextPuzzle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
