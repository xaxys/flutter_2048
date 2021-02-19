import 'package:shared_preferences/shared_preferences.dart';

import 'command.dart';
import 'config.dart';
import 'chessboard.dart';

typedef GridListener = void Function(List<List<PointInfo>>);
typedef ScoreListener = void Function(int);

class Game {
  int score = 0;
  int highScore = 0;
  SharedPreferences inst;
  Chessboard chessboard = Chessboard(Config.SCALE);
  List<Command> commandHistory = [];
  // Listeners
  List<GridListener> operateListeners = [];
  List<GridListener> generateListeners = [];
  List<GridListener> updateListeners = [];
  List<ScoreListener> scoreListeners = [];

  Game() {
    SharedPreferences.getInstance().then((v) {
      inst = v;
      highScore = v.getInt("high_score") ?? 0;
    });
    GenerateCommand(chessboard).execute();
    GenerateCommand(chessboard).execute();
  }

  List<List<PointInfo>> getPointInfo() {
    return chessboard.toPointInfo();
  }

  bool isGameOver() {
    return chessboard.isGameOver();
  }

  void updateScore() {
    if (chessboard.score != score) {
      if (chessboard.score < score) {
        highScore = inst.getInt("high_score") ?? 0;
      } else if (chessboard.score > highScore) {
        highScore = chessboard.score;
        Command command = HighScoreUpdateCommand(inst, highScore)..execute();
        commandHistory.add(command);
      }
      score = chessboard.score;
    }
  }

  void notify(List listeners, dynamic arg) {
    listeners.forEach((listener) => listener(arg));
  }

  void restart() {
    chessboard.clear();
    GenerateCommand(chessboard).execute();
    GenerateCommand(chessboard).execute();
    commandHistory.clear();
    score = 0;
  }

  void operate(Gesture gesture) {
    Command command = OperateCommand(gesture, chessboard);
    var result = command.execute();
    if (result.success) {
      commandHistory.add(command);
      notify(operateListeners, result.obj);
      updateScore();
    }
  }

  void generate() {
    Command command = GenerateCommand(chessboard);
    var result = command.execute();
    if (result.success) {
      commandHistory.add(command);
      notify(generateListeners, result.obj);
    }
  }

  bool undo() {
    while (commandHistory.isNotEmpty) {
      Command command = commandHistory.last..undo();
      commandHistory.removeLast();
      if (command is OperateCommand) {
        updateScore();
        notify(updateListeners, chessboard.toPointInfo());
        return true;
      }
    }
    return false;
  }
}
