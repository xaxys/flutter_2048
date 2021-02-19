import 'package:flutter/material.dart';
import 'config.dart';

class StaticTile extends StatelessWidget {
  final int num;
  final double size;
  StaticTile(this.num, this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: num > 0
          ? Center(
              child: Text(
                "$num",
                style: TextStyle(
                  fontSize: size / Config.SIZE_MAP["$num".length],
                  fontWeight: FontWeight.bold,
                  color: num >= 8
                      ? Config.COLOR_FONT_LIGHT
                      : Config.COLOR_FONT_DARK,
                ),
              ),
            )
          : null,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Config.COLOR_MAP[num],
        borderRadius: BorderRadius.all(
          Radius.circular(size * 0.1),
        ),
      ),
    );
  }
}

class AnimatedMoveTile extends AnimatedWidget {
  final int num;
  final double size;
  AnimatedMoveTile(this.num, this.size, Animation<Offset> animation)
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: listenable,
      child: Container(
        child: StaticTile(num, size),
      ),
    );
  }
}

class AnimatedSizeTile extends AnimatedWidget {
  final int num;
  final double size;
  final Animation<double> animation;
  AnimatedSizeTile(this.num, this.size, this.animation)
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: listenable,
      child: Container(
        child: StaticTile(num, animation.value),
      ),
    );
  }
}

class TileEmpty extends StatelessWidget {
  final double size;
  TileEmpty(this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Config.COLOR_EMPTY,
        borderRadius: BorderRadius.all(
          Radius.circular(size * 0.1),
        ),
      ),
    );
  }
}
