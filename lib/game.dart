import 'dart:math';

enum Gesture { UP, DOWN, LEFT, RIGHT }
enum TileAction { NONE, MOVE, APPEAR, COMBINE }

class PointInfo {
  Point<int> orig;
  Point<double> move;
  TileAction action;
  int value;

  PointInfo(int i, int j, this.value, [this.action = TileAction.NONE]) {
    orig = Point(i, j);
    move = Point(0, 0);
  }

  void setMove(List<int> targetPos) {
    int x = targetPos[1] - orig.y;
    int y = targetPos[0] - orig.x;
    move = Point(x.toDouble(), y.toDouble());
    action = TileAction.MOVE;
  }

  void setAppear(int num) {
    value = num;
    action = TileAction.APPEAR;
  }

  void setCombine(int num) {
    value = num;
    action = TileAction.APPEAR;
  }
}

class Game {
  int scale;
  int score = 0;
  List<List<int>> grid;
  List<List<PointInfo>> modify;

  Game(this.scale) {
    grid = List.generate(scale, (_) => List.filled(scale, 0));
  }

  List<List<PointInfo>> getGrid() {
    return List.generate(
      scale,
      (i) => List.generate(
        scale,
        (j) => PointInfo(i, j, grid[i][j]),
      ),
    );
  }

  List<Point<int>> freeList() {
    List<Point<int>> options = [];
    for (int i = 0; i < scale; i++) {
      for (int j = 0; j < scale; j++) {
        if (grid[i][j] == 0) options.add(Point(i, j));
      }
    }
    return options;
  }

  bool isGameOver() {
    for (int i = 0; i < scale; i++) {
      for (int j = 0; j < scale; j++) {
        if (grid[i][j] == 0) return false;
        if (i < scale - 1 && grid[i][j] == grid[i + 1][j]) return false;
        if (j < scale - 1 && grid[i][j] == grid[i][j + 1]) return false;
      }
    }
    return true;
  }
}
