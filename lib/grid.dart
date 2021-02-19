import 'package:flutter/widgets.dart';

import 'config.dart';
import 'chessboard.dart';
import 'tile.dart';

extension on List<List<PointInfo>> {
  void forEachPoint(void Function(PointInfo) func) {
    this.forEach((list) => list.forEach((elem) => func(elem)));
  }
}

class Grid extends StatefulWidget {
  final List<List<PointInfo>> pointInfo;
  final double tileSize;
  final void Function() animateFinishCallback;
  Grid(this.tileSize, this.pointInfo, this.animateFinishCallback);

  @override
  _GridState createState() => _GridState();
}

class _GridState extends State<Grid> with SingleTickerProviderStateMixin {
  AnimationController controller;
  _GridState();

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
  void didUpdateWidget(Grid oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool hasAnimation = false;
    widget.pointInfo.forEachPoint((info) {
      if (info.action != TileAction.NONE) hasAnimation = true;
    });
    if (!hasAnimation) return;

    controller.reset();
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> grids = [];
    widget.pointInfo.forEachPoint(
      (info) {
        Widget tile;
        switch (info.action) {
          case TileAction.MOVE:
            var animation = Tween(
              begin: Offset.zero,
              end: Offset(info.move.x, info.move.y),
            ).animate(controller);
            tile = AnimatedMoveTile(info.value, widget.tileSize, animation);
            break;
          case TileAction.APPEAR:
            var animation = Tween(
              begin: 0.0,
              end: widget.tileSize,
            ).animate(controller);
            tile = AnimatedSizeTile(info.value, widget.tileSize, animation);
            break;
          case TileAction.NONE:
          default:
            tile = StaticTile(info.value, widget.tileSize);
            break;
        }
        grids.add(tile);
      },
    );
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
