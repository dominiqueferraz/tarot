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
    required this.phaseNumber,
    required this.artwork,
    this.onClear,
    this.onContinue,
    super.key,
  });

  final PuzzleDefinition puzzle;
  final int phaseNumber;
  final Artwork artwork;
  final VoidCallback? onClear;
  final void Function(BuildContext)? onContinue;

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> with TickerProviderStateMixin {
  late var _deal = PuzzleDeal(widget.puzzle);
  PuzzleDefinition get _puzzle => widget.puzzle;
  BoardSize get _size => _puzzle.size;
  bool get _animatesClear => _puzzle.scene != PuzzleScene.quay;
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

  bool get _acceptsInput => _turn == null && !_deal.finished;
  int _displayProgress(int cell) =>
      _turn?.progressBefore[cell] ??
      (_turn == null ? _deal.progressAt(cell) : 0);

  double get _fadeProgress =>
      _turn == null || _deal.faded == 0 || _reducedMotion
      ? 1
      : (_fallMotion.value / BoardMotion.fadeCueFraction).clamp(0.0, 1.0);

  double _fixtureProgress(int cell) {
    final fade = _turn == null ? 0 : _deal.fadedAt(cell);
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
                availableHeight /
                    (1 / _size.aspectRatio + 1 / SceneLayout.ratio),
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
  }

  String _guideExplanation(
    AppLocalizations strings,
    GuideCue cue,
    Stroke stroke,
  ) => switch (cue) {
    GuideCue.match => strings.guideMatch,
    GuideCue.square => strings.guideSquare,
    GuideCue.rectangle => strings.guideCupRectangle,
    GuideCue.enclose => strings.guideEnclose(
      stroke.light,
      suitName(strings, _puzzle.scoringSuit),
    ),
    GuideCue.aim => strings.guideAim(
      stroke.light,
      suitName(strings, _puzzle.scoringSuit),
    ),
    GuideCue.wildcard => strings.guideCoinWildcard,
    GuideCue.linkSquare => strings.guideLinkSquare(
      suitName(strings, _puzzle.scoringSuit),
    ),
    GuideCue.linkedAim => strings.guideLinkedAim(
      suitName(strings, _puzzle.scoringSuit),
      stroke.gains.values.first,
    ),
  };

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
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: strings.campaignPath,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: PaperSurface(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        2,
                        4,
                        10,
                        4,
                      ),
                      child: Text(
                        '${widget.phaseNumber}',
                        semanticsLabel: strings.puzzleNumber(
                          widget.phaseNumber,
                        ),
                        style: labelType.copyWith(color: mutedInk),
                      ),
                    ),
                  ),
                ),
              ),
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
    final words = puzzleWords(strings, _puzzle.textKey);
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
              Text(
                words.objective,
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
    double boardWidth, {
    required bool showResult,
  }) {
    final boardHeight = boardWidth / _size.aspectRatio;
    final pitch = boardWidth / _size.columns;
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
                    key: switch (_puzzle.scene) {
                      PuzzleScene.ridge => const Key('fool-ridge'),
                      PuzzleScene.quay => const Key('quay-scene'),
                      PuzzleScene.mill => const Key('mill-scene'),
                      PuzzleScene.dock => const Key('dock-scene'),
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
                          scene: _puzzle.scene,
                          progress: _puzzle.targets.keys
                              .map(_sceneProgress)
                              .toList(),
                          motion: motion,
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
                    _markerValue(cell, pitch),
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
                      _deal.faded > 0 &&
                      _path.isEmpty &&
                      !_showResult)
                    Positioned.fill(
                      child: GuideHint(
                        pitch: pitch,
                        placement: _fadeHintPlacement,
                        explanation: strings.lampFadingHint(_puzzle.fading),
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

  Widget _markerValue(int cell, double pitch) {
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
                  '${_displayProgress(cell)}/${_puzzle.targets[cell]!.quota}',
                  key: switch (_puzzle.scene) {
                    PuzzleScene.ridge => const Key('trail-marker-value'),
                    PuzzleScene.quay => const Key('quay-lamp-value'),
                    PuzzleScene.mill => const Key('mill-inlet-value'),
                    PuzzleScene.dock => Key(
                      'cord-value-${_size.cellLabel(cell)}',
                    ),
                  },
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
    final row = _size.rowOf(_puzzle.marker);
    return row < _size.rows - 2
        ? (
            x: _size.columnOf(_puzzle.marker) + .5,
            y: row + 1.04,
            tail: HintTail.top,
          )
        : (
            x: _size.columnOf(_puzzle.marker) + .5,
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
          : '${strings.board}, ${strings.gestureGuide}',
      child: Stack(
        children: [
          for (var cell = 0; cell < _size.cellCount; cell++)
            if (!_puzzle.masked.contains(cell))
              Positioned(
                left: _size.columnOf(cell) * pitch,
                top: _size.rowOf(cell) * pitch,
                width: pitch,
                height: pitch,
                child: Semantics(
                  sortKey: OrdinalSortKey(cell.toDouble()),
                  label:
                      '${_size.cellLabel(cell)}, '
                      '${labels[_deal.board[cell]] ?? _targetLabel(strings, cell)}',
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

  String _targetLabel(AppLocalizations strings, int cell) {
    final target = _puzzle.targets[cell]!;
    return [
      '${targetName(strings, target.label)} ${_displayProgress(cell)}/${target.quota}',
      if (_turn == null && _deal.fadedAt(cell) > 0)
        strings.lampFaded(_deal.fadedAt(cell)),
    ].join(', ');
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
                _deal.won
                    ? strings.clear
                    : _puzzle.targets.entries
                          .map(
                            (target) =>
                                '${_deal.progressAt(target.key)}/${target.value.quota}',
                          )
                          .join(' · '),
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
