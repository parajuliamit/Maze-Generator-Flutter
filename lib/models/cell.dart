import '../constants.dart';

class Cell {
  late final double x;
  late final double y;
  late final int i;
  late final int j;
  bool left = true;
  bool right = true;
  bool top = true;
  bool bottom = true;
  bool visited = false;

  Cell(this.i, this.j) {
    x = i * spacing;
    y = j * spacing;
  }
}
