import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAssets {
  static const cover = 'assets/the-moon.webp';
  static const paper = 'assets/paper-grain.png';
}

enum Art {
  ridge('ridge'),
  quaySky('quay-sky'),
  quayPier('quay-pier'),
  mill('mill'),
  foolFragment('fool-fragment'),
  cupsFragment('cups-fragment'),
  fool('fool', Offset(32, 56)),
  mooredBoat('moored-boat', Offset(8, 12)),
  wand('wand', Offset(30, 30)),
  cup('cup', Offset(30, 30)),
  oilDrop('oil-drop', Offset(14, 16)),
  waterDrop('water-drop', Offset(14, 16)),
  sword('sword', Offset(30, 30)),
  coin('coin', Offset(30, 30)),
  hand('hand', Offset(21, 6)),
  marker('marker', Offset(26, 26)),
  lantern('lantern', Offset(24, 33));

  const Art(this.file, [this.pivot = Offset.zero]);
  final String file;
  final Offset pivot;

  String get path => 'assets/art/$file.svg';
}

class Artwork {
  Artwork._(this._pictures);

  final Map<Art, PictureInfo> _pictures;
  static Future<Artwork>? _loading;

  static Future<Artwork> load() => _loading ??= _load();

  static Future<Artwork> _load() async {
    final pictures = await Future.wait([
      for (final art in Art.values)
        vg.loadPicture(SvgAssetLoader(art.path), null),
    ]);
    return Artwork._({for (final art in Art.values) art: pictures[art.index]});
  }

  void paint(
    Canvas canvas,
    Art art, {
    Offset origin = Offset.zero,
    double scale = 1,
    double opacity = 1,
  }) {
    final asset = _pictures[art]!;
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale);
    canvas.translate(-art.pivot.dx, -art.pivot.dy);
    if (opacity < 1) {
      canvas.saveLayer(
        Offset.zero & asset.size,
        Paint()..color = Color.from(alpha: opacity, red: 1, green: 1, blue: 1),
      );
    }
    canvas.drawPicture(asset.picture);
    if (opacity < 1) canvas.restore();
    canvas.restore();
  }
}
