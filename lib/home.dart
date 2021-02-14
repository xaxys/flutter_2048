import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'board.dart';
import 'config.dart';
import 'game.dart';

import 'gamecontroller.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  GameController gameCtrl = GameController();
  List<List<PointInfo>> pointInfo;

  void handleGesture(Gesture gesture) {
    gameCtrl.operate(gesture);
  }

  void onAnimationFinished() {
    refresh();
  }

  void refresh() {
    setState(() => pointInfo = gameCtrl.getGrid());
  }

  void initGame() {
    gameCtrl.operateListeners.add((info) => setState(() {
          pointInfo = info;
          gameCtrl.generate();
        }));
    // gameCtrl.generateListeners.add((info) => pointInfo = info);
    gameCtrl.updateListeners.add((info) => setState(() => pointInfo = info));
    refresh();
  }

  @override
  void initState() {
    initGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double gridSize = min(width - 80, (height - 150) * 0.7);
    double tileSize = gridSize / Config.SCALE;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '2048',
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Config.COLOR_BG,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Container(
                  width: min(200.0, gridSize),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(tileSize * 0.2),
                    color: Config.COLOR_BG,
                  ),
                  height: tileSize * 0.8,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Text(
                          'Score',
                          style: TextStyle(
                            fontSize: tileSize * 0.18,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          '${gameCtrl.score}',
                          style: TextStyle(
                            fontSize: tileSize * 0.25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: gridSize,
                height: gridSize,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.all((tileSize * 0.08).floorToDouble()),
                      child: GestureDetector(
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          autofocus: true,
                          onKey: (RawKeyEvent e) {
                            if (e.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
                              handleGesture(Gesture.UP);
                              return;
                            }
                            if (e.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
                              handleGesture(Gesture.DOWN);
                              return;
                            }
                            if (e.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
                              handleGesture(Gesture.LEFT);
                              return;
                            }
                            if (e.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
                              handleGesture(Gesture.RIGHT);
                              return;
                            }
                          },
                          child:
                              Board(tileSize, pointInfo, onAnimationFinished),
                        ),
                        onVerticalDragEnd: (DragEndDetails details) {
                          //primaryVelocity -ve up +ve down
                          if (details.primaryVelocity < 0) {
                            handleGesture(Gesture.UP);
                          } else if (details.primaryVelocity > 0) {
                            handleGesture(Gesture.DOWN);
                          }
                        },
                        onHorizontalDragEnd: (details) {
                          //-ve left, +ve right
                          if (details.primaryVelocity < 0) {
                            handleGesture(Gesture.LEFT);
                          } else if (details.primaryVelocity > 0) {
                            handleGesture(Gesture.RIGHT);
                          }
                        },
                      ),
                    ),
                    gameCtrl.isGameOver()
                        ? Container(
                            height: height,
                            color: Config.COLOR_WHITE_MASK,
                            child: Center(
                              child: Text(
                                'Game over!',
                                style: TextStyle(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                  color: Config.COLOR_BG,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                color: Config.COLOR_BG,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: Center(
                  child: Container(
                    width: gridSize,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          height: tileSize * 0.6,
                          width: tileSize * 0.65,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(tileSize * 0.2),
                            color: Config.COLOR_BG,
                          ),
                          child: Center(
                            child: IconButton(
                                iconSize: tileSize * 0.35,
                                icon: Icon(
                                  Icons.refresh,
                                  color: Colors.white70,
                                ),
                                onPressed: gameCtrl.restart),
                          ),
                        ),
                        Container(
                          height: tileSize * 0.6,
                          width: tileSize * 1.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(tileSize * 0.2),
                            color: Config.COLOR_BG,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: tileSize * 0.05, bottom: tileSize * 0.05),
                            child: Center(
                              child: TextButton(
                                child: Text(
                                  "undo",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: tileSize * 0.22,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.white70,
                                  ),
                                ),
                                onPressed: gameCtrl.undo,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: tileSize * 0.6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(tileSize * 0.2),
                            color: Config.COLOR_BG,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 5.0, left: 5.0, right: 5.0),
                            child: Center(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    'High Score',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: tileSize * 0.15,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${gameCtrl.highScore}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: tileSize * 0.15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: tileSize * 0.2),
                child: Center(
                  child: Text(
                    "Copyright © 2021 xaxys. Powered by Flutter.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: max(14, tileSize * 0.12),
                      color: Colors.grey[300],
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
