import 'package:material_ui/material_ui.dart';

import 'visuals.dart';

class TarotCardFace extends StatelessWidget {
  const TarotCardFace({
    required this.title,
    required this.illustration,
    super.key,
  });

  static const aspectRatio = 70 / 120;

  final String title;
  final Widget illustration;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: aspectRatio,
    child: LayoutBuilder(
      builder: (context, box) => DecoratedBox(
        decoration: BoxDecoration(
          color: parchment,
          border: Border.all(color: ink, width: 1.4),
          boxShadow: const [
            BoxShadow(color: Color(0xFFC4B595), offset: Offset(4, 5)),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(box.maxWidth * .038),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: ClipRect(child: illustration)),
              const Divider(height: 1, color: ink),
              SizedBox(
                height: box.maxHeight * .145,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(title.toUpperCase(), style: displayType(15)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
