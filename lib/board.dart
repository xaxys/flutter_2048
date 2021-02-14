import 'package:flutter/widgets.dart';

import 'config.dart';
import 'game.dart';
import 'tile.dart';

class Board extends StatefulWidget {
  final List<List<PointInfo>> pointInfo;
  final double tileSize;
  final void Function() animateFinishCallback;
  Board(this.tileSize, this.pointInfo, this.animateFinishCallback);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> with SingleTickerProviderStateMixin {
  AnimationController controller;

  _BoardState();

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.animateFinishCallback();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> grids = [];
    widget.pointInfo.forEach(
      (list) => list.forEach((info) {
        Widget tile;
        switch (info.action) {
          case TileAction.NONE:
            tile = StaticTile(info.value, widget.tileSize);
            break;
          case TileAction.MOVE:
            var animation = Tween(
              begin: Offset.zero,
              end: Offset(info.move.x, info.move.y),
            ).animate(controller);
            tile = AnimatedMoveTile(info.value, widget.tileSize, animation);
            break;
          default:
        }
        grids.add(tile);
      }),
    );
    controller.reset();
    controller.forward();
    double spacing = (widget.tileSize * 0.08).floorToDouble();
    return Stack(
      children: [
        GridView.count(
          primary: false,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          crossAxisCount: Config.SCALE,
          children: List.filled(
            Config.SCALE * Config.SCALE,
            TileEmpty(widget.tileSize),
          ),
        ),
        GridView.count(
          primary: false,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          crossAxisCount: Config.SCALE,
          children: grids,
        )
      ],
    );
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }
}
