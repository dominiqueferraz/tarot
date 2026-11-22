# Arcana · Rider–Waite–Smith

A 78-card English edition with tall 1:3 frames, serif lettering, warm paper, and a palette of black, blue, red, ochre, and olive.

The **22 Major Arcana** follow the Rider–Waite–Smith order, with **The Fool (0)**, **Strength (VIII)**, and **Justice (XI)**. The compositions include the Chariot's twin sphinxes, Death's white rose, and the Sun's child on horseback.

The **56 Minor Arcana** depict geometric scenes for **Wands, Cups, Swords, and Pentacles**. Each suit includes Ace through Ten, Page, Knight, Queen, and King. Pentacles use discs with five-pointed stars.

[Full-deck contact sheet](sheets/full-deck.png)

The `svg/` folder contains one face per file, with embedded paper texture and outlined lettering. The [deck manifest](manifest.json) includes card names, numbers, suits, scene descriptions, and asset paths.

The artwork draws on Pamela Colman Smith’s compositions and Arthur Edward Waite’s descriptions. [Major Arcana](https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_2) · [Minor Arcana](https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3)

## Rendering card PNGs

Extract `tools/deck/` from `Arcana-Code-and-Prototype.zip` in Downloads, preserving its path. To render the 396 × 1188 PNGs on macOS, run this from the repository root.

```sh
swift tools/deck/export.swift deck/rider-waite-smith
```

Pass another edition directory to render that edition from its manifest. The original PNG sets, extra contact sheets and deck distribution ZIPs are also in the archive, under their original `deck/` paths.

To generate new art with the archived Python tools, use `build.py` for Rider–Waite–Smith and `marseille.py` for Marseille. Both use Pillow, fontTools and the font passed with `--font`. For Marseille, also extract the original Portuguese sheet at `deck/reference/tarot.png` from the archive and pass that path as the source argument.
