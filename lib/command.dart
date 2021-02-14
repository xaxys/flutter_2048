import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'game.dart';
import 'snapshot.dart';

extension on List<List> {
  dynamic get(List<int> pos) {
    return this[pos[0]][pos[1]];
  }

  void set(List<int> pos, dynamic obj) {
    this[pos[0]][pos[1]] = obj;
  }
}

abstract class Command {
  Snapshot snapshot;
  Game game;

  Command([this.game, this.snapshot]) {
    if (game == null) return;
  }

  bool execute() {
    if (snapshot == null) snapshot = Snapshot(game);
    return true;
  }

  void undo() {
    if (snapshot != null) {
      snapshot.restore();
    }
  }
}

class OperateCommand extends Command {
  final Gesture gesture;
  OperateCommand(this.gesture, Game game, [Snapshot snapshot])
      : super(game, snapshot);

  @override
  bool execute() {
    super.execute();
    var movement = game.getGrid();
    bool isMoved = false;

    List<int> Function(int, int) pos;
    switch (gesture) {
      case Gesture.UP:
        pos = (i, j) => [j, i];
        break;
      case Gesture.DOWN:
        pos = (i, j) => [game.scale - j - 1, i];
        break;
      case Gesture.LEFT:
        pos = (i, j) => [i, j];
        break;
      case Gesture.RIGHT:
        pos = (i, j) => [i, game.scale - j - 1];
        break;
    }

    for (var i = 0; i < game.scale; i++) {
      var last = -1;
      for (var j = 1; j < game.scale; j++) {
        if (game.grid.get(pos(i, j)) == 0) continue;
        var k = j - 1;
        while (k > last && game.grid.get(pos(i, k)) == 0) k--;
        if (k > last && game.grid.get(pos(i, k)) == game.grid.get(pos(i, j))) {
          var value = game.grid.get(pos(i, j)) * 2;
          game.grid.set(pos(i, k), value);
          game.grid.set(pos(i, j), 0);
          game.score += value;
          movement.get(pos(i, j)).setMove(pos(i, k));
          last = k;
          isMoved = true;
          continue;
        }
        if (k < j - 1) {
          var value = game.grid.get(pos(i, j));
          game.grid.set(pos(i, k + 1), value);
          game.grid.set(pos(i, j), 0);
          movement.get(pos(i, j)).setMove(pos(i, k + 1));
          isMoved = true;
          continue;
        }
      }
    }
    game.modify = movement;
    return isMoved;
  }
}

class GenerateCommand extends Command {
  GenerateCommand(Game game, [Snapshot snapshot]) : super(game, snapshot);

  @override
  bool execute() {
    super.execute();
    var modify = game.getGrid();
    var list = game.freeList();
    if (list.isNotEmpty) {
      var pos = list[Random().nextInt(list.length)];
      var value = (Random().nextInt(2) + 1) * 2;
      game.grid[pos.x][pos.y] = value;
      modify.get([pos.x, pos.y]).setAppear(value);
      game.modify = modify;
      return true;
    } else {
      return false;
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
  bool execute() {
    inst.setInt("high_score", newHighScore);
    return true;
  }

  @override
  void undo() {
    inst.setInt("high_score", highScore);
  }
}
