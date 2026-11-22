import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'artwork.dart';
import 'fool/puzzle_definition.dart';
import 'campaign/campaign_page.dart';
import 'l10n/generated/app_localizations.dart';
import 'visuals.dart';

const _languageKey = 'language';
const _progressKey = 'unlockedPuzzle';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = SharedPreferencesAsync();
  String? savedLanguage;
  String? unlockedPuzzle;
  final catalog = PuzzleCatalog.parse(
    await rootBundle.loadString(PuzzleCatalog.assetPath),
  );
  try {
    savedLanguage = await preferences.getString(_languageKey);
  } on PlatformException catch (error) {
    debugPrint('Could not read the app language: ${error.code}');
  }
  try {
    unlockedPuzzle = await preferences.getString(_progressKey);
  } on PlatformException catch (error) {
    debugPrint('Could not read puzzle progress: ${error.code}');
  }
  final artwork = await Artwork.load();
  runApp(
    TarotSquaredApp(
      initialLanguage: savedLanguage,
      saveLanguage: (language) => preferences.setString(_languageKey, language),
      catalog: catalog,
      artwork: artwork,
      unlockedPuzzle: unlockedPuzzle,
      saveUnlock: (id) => preferences.setString(_progressKey, id),
    ),
  );
}

class TarotSquaredApp extends StatefulWidget {
  const TarotSquaredApp({
    this.initialLanguage,
    this.saveLanguage,
    required this.catalog,
    required this.artwork,
    this.unlockedPuzzle,
    this.saveUnlock,
    super.key,
  });

  final String? initialLanguage;
  final Future<void> Function(String)? saveLanguage;
  final PuzzleCatalog catalog;
  final Artwork artwork;
  final String? unlockedPuzzle;
  final Future<void> Function(String)? saveUnlock;

  @override
  State<TarotSquaredApp> createState() => _TarotSquaredAppState();
}

class _TarotSquaredAppState extends State<TarotSquaredApp> {
  Locale? _locale;
  late final _unlockedIndex = ValueNotifier(
    widget.catalog.unlockedIndex(widget.unlockedPuzzle),
  );

  @override
  void initState() {
    super.initState();
    final initial = widget.initialLanguage;
    if (AppLocalizations.supportedLocales.any(
      (locale) => locale.languageCode == initial,
    )) {
      _locale = Locale(initial!);
    }
  }

  @override
  void dispose() {
    _unlockedIndex.dispose();
    super.dispose();
  }

  Future<void> _selectLanguage(Locale locale) async {
    setState(() => _locale = locale);
    try {
      await widget.saveLanguage?.call(locale.languageCode);
    } on PlatformException catch (error) {
      debugPrint('Could not save the app language: ${error.code}');
    }
  }

  Future<void> _unlock(PuzzleDefinition next) async {
    final index = widget.catalog.puzzles.indexOf(next);
    if (index <= _unlockedIndex.value) return;
    _unlockedIndex.value = index;
    try {
      await widget.saveUnlock?.call(next.id);
    } on PlatformException catch (error) {
      debugPrint('Could not save puzzle progress: ${error.code}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: ink,
          onPrimary: paper,
          secondary: rust,
          surface: paper,
          onSurface: ink,
        ),
        scaffoldBackgroundColor: paper,
        splashFactory: InkRipple.splashFactory,
      ),
      home: _HomePage(
        onLanguageSelected: _selectLanguage,
        onPlay: (context) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => CampaignPage(
              catalog: widget.catalog,
              artwork: widget.artwork,
              unlockedIndex: _unlockedIndex,
              onUnlock: _unlock,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.onLanguageSelected, required this.onPlay});

  final Future<void> Function(Locale) onLanguageSelected;
  final void Function(BuildContext) onPlay;

  Future<void> _showSettings(BuildContext context) async {
    final chosen = await showModalBottomSheet<Locale>(
      context: context,
      useSafeArea: true,
      backgroundColor: paper,
      shape: const RoundedRectangleBorder(side: BorderSide(color: ink)),
      builder: (context) => const _LanguageSheet(),
    );
    if (chosen != null) await onLanguageSelected(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      body: PaperSurface(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 480,
                      minHeight: box.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const ExcludeSemantics(child: _DeckMark()),
                            const SizedBox(width: 12),
                            const Expanded(child: Divider(color: rule)),
                            const SizedBox(width: 12),
                            IconButton.outlined(
                              tooltip: strings.settings,
                              style: IconButton.styleFrom(
                                shape: const RoundedRectangleBorder(),
                              ),
                              onPressed: () => _showSettings(context),
                              icon: const Icon(
                                Icons.settings_outlined,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 26),
                          child: _HomeCover(
                            title: strings.appTitle,
                            cardName: strings.moon,
                            maxHeight: (box.maxHeight * .57).clamp(230, 420),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 22),
                          child: PlayAction(
                            label: strings.play,
                            onPressed: () => onPlay(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DeckMark extends StatelessWidget {
  const _DeckMark();

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 38,
    child: DecoratedBox(
      decoration: const BoxDecoration(color: ink),
      child: Center(
        child: Transform.rotate(
          angle: .785398163,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              border: Border.all(color: paleGold, width: 1.5),
            ),
          ),
        ),
      ),
    ),
  );
}

class _HomeCover extends StatelessWidget {
  const _HomeCover({
    required this.title,
    required this.cardName,
    required this.maxHeight,
  });

  final String title;
  final String cardName;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: maxHeight,
      child: LayoutBuilder(
        builder: (context, box) {
          final cardWidth = (box.maxHeight * .36).clamp(
            0.0,
            box.maxWidth * .44,
          );
          final remaining = box.maxWidth - cardWidth - 4;
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                width: cardWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: parchment,
                    border: Border.all(color: ink, width: 1.4),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFFC4B595), offset: Offset(4, 5)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRect(
                            child: Image.asset(
                              AppAssets.cover,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              excludeFromSemantics: true,
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: ink),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 3,
                          ),
                          child: Text(
                            cardName.toUpperCase(),
                            style: displayType(15),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: remaining,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 34, height: 3, color: rust),
                    const SizedBox(height: 16),
                    Semantics(
                      header: true,
                      label: title,
                      excludeSemantics: true,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title.replaceFirst(' ', '\n'),
                          style: displayType((remaining * .30).clamp(29, 74)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Icon(Icons.auto_awesome, size: 21, color: rust),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  static const names = {'en': 'English', 'pt': 'Português', 'es': 'Español'};

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final language = Localizations.localeOf(context).languageCode;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(strings.settings, style: displayType(31)),
                  ),
                ),
                IconButton(
                  tooltip: strings.close,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(strings.language, style: labelType),
            const SizedBox(height: 8),
            for (final entry in names.entries) ...[
              const Divider(height: 1, color: rule),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.value),
                selected: entry.key == language,
                trailing: Icon(
                  entry.key == language
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: entry.key == language ? rust : mutedInk,
                  size: 20,
                ),
                onTap: () => Navigator.of(context).pop(Locale(entry.key)),
              ),
            ],
            const Divider(height: 1, color: rule),
          ],
        ),
      ),
    );
  }
}
