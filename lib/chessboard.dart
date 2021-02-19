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
    action = TileAction.COMBINE;
  }
}

class Chessboard {
  int scale;
  int score = 0;
  List<List<int>> grid;

  Chessboard(this.scale) {
    clear();
  }

  void clear() {
    score = 0;
    grid = List.generate(scale, (_) => List.filled(scale, 0), growable: false);
  }

  Snapshot createSnapshot() {
    var clone = Chessboard(this.scale);
    this.forEach((i, j, value) => clone.grid[i][j] = value);
    clone.score = this.score;
    return Snapshot(clone);
  }

  void restore(Snapshot snapshot) {
    this.scale = snapshot.clone.scale;
    this.clear();
    snapshot.clone.forEach((i, j, value) => this.grid[i][j] = value);
    this.score = snapshot.clone.score;
  }

  List<List<PointInfo>> toPointInfo() {
    return List.generate(
      scale,
      (i) => List.generate(
        scale,
        (j) => PointInfo(i, j, grid[i][j]),
        growable: false,
      ),
      growable: false,
    );
  }

  void forEach(void Function(int, int, int) func) {
    for (int i = 0; i < scale; i++) {
      for (int j = 0; j < scale; j++) {
        func(i, j, grid[i][j]);
      }
    }
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

class Snapshot {
  final Chessboard clone;
  final DateTime time = DateTime.now();
  Snapshot(this.clone);
}
