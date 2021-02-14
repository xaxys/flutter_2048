import 'package:shared_preferences/shared_preferences.dart';

import 'command.dart';
import 'config.dart';
import 'game.dart';

typedef GridListener = void Function(List<List<PointInfo>>);
typedef ScoreListener = void Function(int);

class GameController {
  int score = 0;
  int highScore = 0;
  SharedPreferences inst;
  Game game = Game(Config.SCALE);
  List<Command> commandHistory = [];
  // Listeners
  List<GridListener> operateListeners = [];
  List<GridListener> generateListeners = [];
  List<GridListener> updateListeners = [];
  List<ScoreListener> scoreListeners = [];

  GameController() {
    SharedPreferences.getInstance().then((v) {
      inst = v;
      highScore = v.getInt("high_score") ?? 0;
    });
    GenerateCommand(game).execute();
    GenerateCommand(game).execute();
  }

  List<List<PointInfo>> getGrid() {
    return game.getGrid();
  }

  bool isGameOver() {
    return game.isGameOver();
  }

  void updateScore() {
    if (game.score != score) {
      if (game.score < score) {
        highScore = inst.getInt("high_score") ?? 0;
      }
      if (game.score > highScore) {
        highScore = game.score;
        Command command = HighScoreUpdateCommand(inst, highScore);
        command.execute();
        commandHistory.add(command);
      }
      score = game.score;
      notify(scoreListeners, score);
    }
  }

  void notify(List listeners, dynamic arg) {
    listeners.forEach((listener) => listener(arg));
  }

  void restart() {
    game = Game(Config.SCALE);
    GenerateCommand(game).execute();
    GenerateCommand(game).execute();
    commandHistory = [];
    score = 0;
  }

  void operate(Gesture gesture) {
    Command command = OperateCommand(gesture, game);
    if (command.execute()) {
      updateScore();
      commandHistory.add(command);
      notify(operateListeners, game.modify);
    }
  }

  void generate() {
    Command command = GenerateCommand(game);
    if (command.execute()) {
      commandHistory.add(command);
      notify(generateListeners, game.modify);
    }
  }

  bool undo() {
    while (commandHistory.isNotEmpty) {
      Command command = commandHistory.last..undo();
      commandHistory.removeLast();
      if (command is OperateCommand) {
        notify(updateListeners, game.getGrid());
        updateScore();
        return true;
      }
    }
    return false;
  }
}
