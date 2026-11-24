import 'package:material_ui/material_ui.dart';

import '../visuals.dart';

class DeckPower {
  const DeckPower({
    required this.command,
    required this.card,
    required this.symbol,
    required this.selected,
    required this.onSelected,
    this.key,
  });

  final String command;
  final Widget card;
  final Widget symbol;
  final bool selected;
  final VoidCallback onSelected;
  final Key? key;
}

class PowerDeck extends StatelessWidget {
  const PowerDeck({required this.label, required this.powers, super.key});

  final String label;
  final List<DeckPower> powers;

  @override
  Widget build(BuildContext context) {
    final armed = powers.any((power) => power.selected);
    return PopupMenuButton<DeckPower>(
      tooltip: label,
      position: PopupMenuPosition.under,
      color: paper,
      surfaceTintColor: Colors.transparent,
      menuPadding: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: ink),
      ),
      onSelected: (power) => power.onSelected(),
      itemBuilder: (context) => [
        for (final power in powers)
          PopupMenuItem(
            key: power.key,
            value: power,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                SizedBox(width: 49, child: power.card),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      power.symbol,
                      Flexible(
                        child: Text(power.command, style: displayType(22)),
                      ),
                    ],
                  ),
                ),
                if (power.selected)
                  const Icon(Icons.check_rounded, color: ink, size: 17),
              ],
            ),
          ),
      ],
      icon: const Icon(Icons.style_outlined),
      style: IconButton.styleFrom(
        minimumSize: const Size.square(kMinInteractiveDimension),
        foregroundColor: armed ? paper : ink,
        backgroundColor: armed ? ink : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
    );
  }
}

class LeapSymbol extends StatelessWidget {
  const LeapSymbol({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: 26,
      child: CustomPaint(
        painter: _LeapPainter(IconTheme.of(context).color ?? ink),
      ),
    ),
  );
}

class _LeapPainter extends CustomPainter {
  const _LeapPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 26, size.height / 26);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.8;
    final fill = Paint()..color = color;
    const start = Offset(4, 20);
    const landing = Offset(22, 20);
    canvas.drawPath(
      Path()
        ..moveTo(4, 15)
        ..cubicTo(7, 4, 18, 4, 22, 15)
        ..moveTo(17.5, 12.5)
        ..lineTo(22, 15)
        ..lineTo(22.5, 10),
      stroke,
    );
    canvas.drawCircle(start, 1.7, fill);
    canvas.drawCircle(landing, 1.7, fill);
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(13, 20), width: 4, height: 4),
      stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LeapPainter oldDelegate) => color != oldDelegate.color;
}
