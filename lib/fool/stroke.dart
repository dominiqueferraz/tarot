enum BoardDirection {
  north(0, -1),
  east(1, 0),
  south(0, 1),
  west(-1, 0);

  const BoardDirection(this.dx, this.dy);

  final int dx;
  final int dy;
}

class BoardSize {
  const BoardSize(this.columns, this.rows);

  final int columns;
  final int rows;

  int get cellCount => columns * rows;
  double get aspectRatio => columns / rows;

  int parseCell(String value) {
    final match = RegExp(r'^([A-Z]+)([1-9][0-9]*)$').firstMatch(value);
    if (match != null) {
      var column = 0;
      for (final letter in match[1]!.codeUnits) {
        column = column * 26 + letter - 64;
        if (column > columns) break;
      }
      final row = int.tryParse(match[2]!);
      if (row != null) {
        final cell = cellAt(column - 1, row - 1);
        if (cell != null) return cell;
      }
    }
    throw FormatException('Invalid board coordinate: $value.');
  }

  String cellLabel(int cell) {
    var column = columnOf(cell) + 1;
    var letters = '';
    while (column > 0) {
      column--;
      letters = String.fromCharCode(65 + column % 26) + letters;
      column ~/= 26;
    }
    return '$letters${rowOf(cell) + 1}';
  }

  int columnOf(int cell) => cell % columns;
  int rowOf(int cell) => cell ~/ columns;

  int? cellAt(int column, int row) {
    if (column < 0 || column >= columns || row < 0 || row >= rows) {
      return null;
    }
    return row * columns + column;
  }

  Iterable<int> neighbours(int cell) sync* {
    final column = columnOf(cell);
    final row = rowOf(cell);
    if (column > 0) yield cell - 1;
    if (column < columns - 1) yield cell + 1;
    if (row > 0) yield cell - columns;
    if (row < rows - 1) yield cell + columns;
  }

  int? aimOf(List<int> path) {
    if (path.length < 2) return null;
    final end = path.last;
    final previous = path[path.length - 2];
    return cellAt(
      2 * columnOf(end) - columnOf(previous),
      2 * rowOf(end) - rowOf(previous),
    );
  }

  bool aimsAlong(int previous, int end, BoardDirection direction) =>
      columnOf(end) - columnOf(previous) == direction.dx &&
      rowOf(end) - rowOf(previous) == direction.dy;

  bool coversCell(List<int> corners, int cell) {
    final a = corners[0];
    final b = corners[2];
    return _between(columnOf(cell), columnOf(a), columnOf(b)) &&
        _between(rowOf(cell), rowOf(a), rowOf(b));
  }

  List<int>? rectangleCorners(List<int> path) {
    if (path.length < 5 || path.first != path.last) return null;
    final sides = <(int, int)>[];
    final edge = path.length - 1;
    if (path.take(edge).toSet().length != edge) return null;

    for (var i = 0; i < edge; i++) {
      final dx = columnOf(path[i + 1]) - columnOf(path[i]);
      final dy = rowOf(path[i + 1]) - rowOf(path[i]);
      if (dx != 0 && dy != 0) return null;
      sides.add((dx.sign, dy.sign));
    }

    final corners = <int>[];
    for (var i = 0; i < edge; i++) {
      final incoming = sides[(i - 1) % edge];
      final outgoing = sides[i];
      if (incoming == (-outgoing.$1, -outgoing.$2)) return null;
      if (incoming != outgoing) corners.add(path[i]);
    }
    return corners.length == 4 ? corners : null;
  }
}

bool _between(int value, int a, int b) => (value - a) * (value - b) <= 0;
