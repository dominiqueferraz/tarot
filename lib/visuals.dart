import 'package:material_ui/material_ui.dart';

import 'artwork.dart';
import 'design_tokens.dart';

export 'design_tokens.dart';

TextStyle displayType(double size) => TextStyle(
  fontFamily: 'Baskerville',
  fontFamilyFallback: const ['Noto Serif', 'serif'],
  color: ink,
  fontSize: size,
  height: .94,
  letterSpacing: -.032 * size,
);

const labelType = TextStyle(
  color: ink,
  fontSize: 13,
  fontWeight: FontWeight.w600,
  letterSpacing: .45,
);

class PaperSurface extends StatelessWidget {
  const PaperSurface({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: paper,
        image: DecorationImage(
          image: AssetImage(AppAssets.paper),
          repeat: ImageRepeat.repeat,
          opacity: .075,
        ),
      ),
      child: child,
    );
  }
}

class PlayAction extends StatelessWidget {
  const PlayAction({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 56),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: const RoundedRectangleBorder(),
      textStyle: labelType.copyWith(fontSize: 18),
      backgroundColor: ink,
      foregroundColor: paper,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Icon(
          onPressed == null ? Icons.lock_outline : Icons.arrow_forward_rounded,
        ),
      ],
    ),
  );
}
