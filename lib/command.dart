import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'chessboard.dart';

extension on List<List> {
  dynamic get(List<int> pos) {
    return this[pos[0]][pos[1]];
  }

  void set(List<int> pos, dynamic obj) {
    this[pos[0]][pos[1]] = obj;
  }
}

class Status {
  final bool success;
  final dynamic obj;
  Status(this.success, [this.obj]);
}

abstract class Command {
  Chessboard chessboard;
  Snapshot snapshot;

  Command([this.chessboard]);

  Status execute() {
    if (snapshot == null) snapshot = chessboard.createSnapshot();
    return Status(true);
  }

  void undo() {
    if (snapshot != null) {
      chessboard.restore(snapshot);
    }
  }
}

class OperateCommand extends Command {
  final Gesture gesture;
  OperateCommand(this.gesture, Chessboard game) : super(game);

  @override
  Status execute() {
    super.execute();
    var movement = chessboard.toPointInfo();
    bool isMoved = false;

    List<int> Function(int, int) pos;
    switch (gesture) {
      case Gesture.UP:
        pos = (i, j) => [j, i];
        break;
      case Gesture.DOWN:
        pos = (i, j) => [chessboard.scale - j - 1, i];
        break;
      case Gesture.LEFT:
        pos = (i, j) => [i, j];
        break;
      case Gesture.RIGHT:
        pos = (i, j) => [i, chessboard.scale - j - 1];
        break;
    }

    for (var i = 0; i < chessboard.scale; i++) {
      var last = -1;
      for (var j = 1; j < chessboard.scale; j++) {
        if (chessboard.grid.get(pos(i, j)) == 0) continue;
        var k = j - 1;
        while (k > last && chessboard.grid.get(pos(i, k)) == 0) k--;
        if (k > last &&
            chessboard.grid.get(pos(i, k)) == chessboard.grid.get(pos(i, j))) {
          var value = chessboard.grid.get(pos(i, j)) * 2;
          chessboard.grid.set(pos(i, k), value);
          chessboard.grid.set(pos(i, j), 0);
          chessboard.score += value;
          movement.get(pos(i, j)).setMove(pos(i, k));
          last = k;
          isMoved = true;
          continue;
        }
        if (k < j - 1) {
          var value = chessboard.grid.get(pos(i, j));
          chessboard.grid.set(pos(i, k + 1), value);
          chessboard.grid.set(pos(i, j), 0);
          movement.get(pos(i, j)).setMove(pos(i, k + 1));
          isMoved = true;
          continue;
        }
      }
    }
    return Status(isMoved, isMoved ? movement : null);
  }
}

class GenerateCommand extends Command {
  GenerateCommand(Chessboard game) : super(game);

  @override
  Status execute() {
    super.execute();
    var random = Random(DateTime.now().microsecondsSinceEpoch);
    var modify = chessboard.toPointInfo();
    List<Point<int>> freeList = [];
    chessboard.forEach((i, j, value) {
      if (value == 0) freeList.add(Point(i, j));
    });
    if (freeList.isNotEmpty) {
      var pos = freeList[random.nextInt(freeList.length)];
      var value = (random.nextInt(2) + 1) * 2;
      chessboard.grid[pos.x][pos.y] = value;
      modify.get([pos.x, pos.y]).setAppear(value);
      return Status(true, modify);
    } else {
      return Status(false);
    }
  }
}

class HighScoreUpdateCommand extends Command {
  int highScore;
  int newHighScore;
  SharedPreferences inst;
  HighScoreUpdateCommand(this.inst, this.newHighScore) {
    highScore = inst.getInt("high_score");
  }

  @override
  Status execute() {
    inst.setInt("high_score", newHighScore);
    return Status(true, newHighScore);
  }

  @override
  void undo() {
    inst.setInt("high_score", highScore);
  }
}
