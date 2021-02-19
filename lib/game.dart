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
      notify(updateListeners);
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
    if (chessboard.score > highScore) {
      highScore = chessboard.score;
      execute(HighScoreUpdateCommand(inst, highScore));
    }
    score = chessboard.score;
  }

  void notify(List listeners, [dynamic arg]) {
    listeners.forEach((listener) => listener(arg));
  }

  void restart() {
    chessboard.clear();
    GenerateCommand(chessboard).execute();
    GenerateCommand(chessboard).execute();
    commandHistory.clear();
    score = 0;
    notify(updateListeners);
  }

  Status execute(Command command) {
    return command.execute()
      ..then((_) {
        commandHistory.add(command);
        updateScore();
      });
  }

  void operate(Gesture gesture) {
    execute(OperateCommand(gesture, chessboard))
      ..then((obj) => notify(operateListeners, obj));
  }

  void generate() {
    execute(GenerateCommand(chessboard))
      ..then((obj) => notify(generateListeners, obj));
  }

  bool undo() {
    while (commandHistory.isNotEmpty) {
      Command command = commandHistory.last..undo();
      commandHistory.removeLast();
      if (command is HighScoreUpdateCommand) {
        highScore = inst.getInt("high_score") ?? 0;
      }
      if (command is OperateCommand) {
        updateScore();
        notify(updateListeners);
        return true;
      }
    }
    return false;
  }
}
