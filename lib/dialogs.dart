import 'package:material_ui/material_ui.dart';

import 'visuals.dart';

class PaperDialog extends StatelessWidget {
  const PaperDialog({
    required this.title,
    required this.content,
    required this.actions,
    super.key,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: DialogPanel(
      title: Semantics(
        header: true,
        child: Text(title, style: displayType(30)),
      ),
      content: content,
      actions: actions,
    ),
  );
}

class DialogPanel extends StatelessWidget {
  const DialogPanel({
    this.title,
    required this.content,
    required this.actions,
    super.key,
  });

  final Widget? title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 312),
    child: Material(
      color: paper,
      surfaceTintColor: Colors.transparent,
      shadowColor: ink.withValues(alpha: .35),
      elevation: 4,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: ink),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            ?title,
            content,
            if (actions.length == 1)
              actions.single
            else
              OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowAlignment: OverflowBarAlignment.end,
                spacing: 8,
                overflowSpacing: 8,
                children: actions,
              ),
          ],
        ),
      ),
    ),
  );
}

enum DialogActionKind { primary, secondary, destructive }

class DialogAction extends StatelessWidget {
  const DialogAction({
    required this.label,
    required this.onPressed,
    this.kind = DialogActionKind.primary,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final DialogActionKind kind;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, side) = switch (kind) {
      DialogActionKind.primary => (ink, paper, null),
      DialogActionKind.secondary => (paper, ink, const BorderSide(color: ink)),
      DialogActionKind.destructive => (rust, paper, null),
    };
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        side: side,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: labelType.copyWith(fontSize: 14, letterSpacing: .2),
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}
