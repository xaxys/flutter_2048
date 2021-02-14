import 'game.dart';

class Snapshot {
  final Game game;
  int _score;
  List<List<int>> _backup;

  Snapshot(this.game, [List<List<PointInfo>> pointInfo, this._score]) {
    List<List<int>> grid = [];
    if (pointInfo == null) pointInfo = game.getGrid();
    if (_score == null) _score = game.score;
    pointInfo.forEach((list) {
      List<int> row = [];
      list.forEach((info) => row.add(info.value));
      grid.add(row);
    });
    _backup = grid;
  }

  void restore() {
    game.grid = _backup;
    game.score = _score;
  }
}
