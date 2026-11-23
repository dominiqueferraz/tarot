import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../visuals.dart';
import 'puzzle_deal.dart';

class GuideHint extends StatelessWidget {
  const GuideHint({
    required this.placement,
    required this.pitch,
    required this.explanation,
    super.key,
  });

  final HintPlacement placement;
  final double pitch;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final (:x, :y, :tail) = placement;
    final anchor = Offset(x * pitch, y * pitch);
    return IgnorePointer(
      child: CustomSingleChildLayout(
        delegate: _HintPosition(anchor, tail),
        child: Semantics(
          container: true,
          liveRegion: true,
          child: CustomPaint(
            key: const Key('fool-help-bubble'),
            painter: _HintOutline(tail),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                10,
                7 + (tail == HintTail.top ? BoardStyle.hintTail : 0),
                11 + (tail == HintTail.right ? BoardStyle.hintTail : 0),
                8 + (tail == HintTail.bottom ? BoardStyle.hintTail : 0),
              ),
              child: Text(
                explanation,
                textWidthBasis: TextWidthBasis.longestLine,
                style: labelType.copyWith(
                  fontSize: BoardStyle.hintTypeSize,
                  height: 1.22,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HintPosition extends SingleChildLayoutDelegate {
  const _HintPosition(this.anchor, this.tail);

  final Offset anchor;
  final HintTail tail;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final board = constraints.biggest;
    final span = tail == HintTail.right
        ? anchor.dx - BoardStyle.hintMargin
        : board.width * .63;
    return BoxConstraints(
      maxWidth: math.max(0, math.min(span, BoardStyle.hintWidth)),
      maxHeight: math.max(0, board.height - BoardStyle.hintMargin * 2),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final Offset(dx: x, dy: y) = anchor;
    final origin = switch (tail) {
      HintTail.top => Offset(x - childSize.width / 2, y),
      HintTail.right => Offset(x - childSize.width, y - childSize.height / 2),
      HintTail.bottom => Offset(x - childSize.width / 2, y - childSize.height),
    };
    return Offset(
      origin.dx.clamp(
        BoardStyle.hintMargin,
        math.max(
          BoardStyle.hintMargin,
          size.width - childSize.width - BoardStyle.hintMargin,
        ),
      ),
      origin.dy.clamp(
        BoardStyle.hintMargin,
        math.max(
          BoardStyle.hintMargin,
          size.height - childSize.height - BoardStyle.hintMargin,
        ),
      ),
    );
  }

  @override
  bool shouldRelayout(_HintPosition oldDelegate) =>
      anchor != oldDelegate.anchor || tail != oldDelegate.tail;
}

class _HintOutline extends CustomPainter {
  const _HintOutline(this.tail);

  final HintTail tail;

  @override
  void paint(Canvas canvas, Size size) {
    final body = Rect.fromLTRB(
      .6,
      tail == HintTail.top ? BoardStyle.hintTail : .6,
      size.width - (tail == HintTail.right ? BoardStyle.hintTail : 2),
      size.height - (tail == HintTail.bottom ? BoardStyle.hintTail : 2),
    );
    final outline = Path()
      ..addPolygon([
        body.topLeft,
        if (tail == HintTail.top) ...[
          body.topCenter - const Offset(5, 0),
          Offset(body.center.dx, .6),
          body.topCenter + const Offset(5, 0),
        ],
        body.topRight,
        if (tail == HintTail.right) ...[
          body.centerRight - const Offset(0, 5),
          Offset(size.width - 2, body.center.dy),
          body.centerRight + const Offset(0, 5),
        ],
        body.bottomRight,
        if (tail == HintTail.bottom) ...[
          body.bottomCenter + const Offset(5, 0),
          Offset(body.center.dx, size.height - 2),
          body.bottomCenter - const Offset(5, 0),
        ],
        body.bottomLeft,
      ], true);
    canvas.drawPath(
      outline.shift(const Offset(1.5, 1.5)),
      Paint()..color = const Color(0xFFC3B292),
    );
    canvas.drawPath(outline, Paint()..color = paper);
    canvas.drawPath(
      outline,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(_HintOutline oldDelegate) => tail != oldDelegate.tail;
}
