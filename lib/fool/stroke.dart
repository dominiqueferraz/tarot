const boardSide = 6;
const cellCount = boardSide * boardSide;

int columnOf(int cell) => cell % boardSide;
int rowOf(int cell) => cell ~/ boardSide;

int? cellAt(int column, int row) {
  if (column < 0 || column >= boardSide || row < 0 || row >= boardSide) {
    return null;
  }
  return row * boardSide + column;
}

Iterable<int> neighbours(int cell) sync* {
  final column = columnOf(cell);
  final row = rowOf(cell);
  if (column > 0) yield cell - 1;
  if (column < boardSide - 1) yield cell + 1;
  if (row > 0) yield cell - boardSide;
  if (row < boardSide - 1) yield cell + boardSide;
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

bool _between(int value, int a, int b) => (value - a) * (value - b) <= 0;

bool coversCell(List<int> corners, int cell) {
  final a = corners[0];
  final b = corners[2];
  return _between(columnOf(cell), columnOf(a), columnOf(b)) &&
      _between(rowOf(cell), rowOf(a), rowOf(b));
}

List<int>? rectangleCorners(List<int> path) {
  if (path.length < 5 || path.first != path.last) return null;
  final sides = <int>[];
  final edge = path.length - 1;
  if (path.take(edge).toSet().length != edge) return null;

  for (var i = 0; i < edge; i++) {
    final dx = columnOf(path[i + 1]) - columnOf(path[i]);
    final dy = rowOf(path[i + 1]) - rowOf(path[i]);
    if (dx != 0 && dy != 0) return null;
    sides.add(dx != 0 ? dx.sign : dy.sign * boardSide);
  }

  final corners = <int>[];
  for (var i = 0; i < edge; i++) {
    final incoming = sides[(i - 1) % edge];
    final outgoing = sides[i];
    if (incoming == -outgoing) return null;
    if (incoming != outgoing) corners.add(path[i]);
  }
  return corners.length == 4 ? corners : null;
}
