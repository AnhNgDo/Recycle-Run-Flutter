import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:recycle_run_game/flame_game/components/mobile_obstacle.dart';
import 'package:recycle_run_game/flame_game/components/recycle_item.dart';

import 'recycle_game.dart';
import 'components/recycle_bin.dart';
import 'components/platform.dart';
import 'components/stationary_obstacle.dart';

class RecycleRunWorld extends World with HasGameRef<RecycleRunGame> {
  // player character
  late BinPlayer bin;

  // ground level based on pixel size of ground blocks
  final double groundLevel = -RecycleRunGame.blockSize;
  // y-offet to make objects 'sinked' into ground
  final double groundOffsetY = 8;

  // platform blocks
  final double minPlatformHeight = 100;
  final double maxPlatformHeight = 200;

  /// initialise world
  @override
  FutureOr<void> onLoad() {
    // add one platform on initial screen
    add(
      Platform(
        position: Vector2(
          game.size.x,
          groundLevel - minPlatformHeight,
        ),
      ),
    );

    // random placed platform to run on
    add(
      SpawnComponent.periodRange(
        factory: (_) => Platform(),
        minPeriod: 3,
        maxPeriod: 6,
        area: Rectangle.fromPoints(
          Vector2(game.size.x, groundLevel - minPlatformHeight),
          Vector2(game.size.x * 1.5, groundLevel - maxPlatformHeight),
        ),
        random: game.random,
      ),
    );

    // stationary obstacle on initial screen
    add(StationaryObstacle.small(
      position: Vector2(
        game.size.x / 2,
        groundLevel,
      ),
    ));

    // random stationary obstacles as player moves
    add(SpawnComponent.periodRange(
      factory: (_) => StationaryObstacle.random(
        level: game.level.number,
        random: game.random,
      ),
      minPeriod: 3,
      maxPeriod: 6,
      area: Rectangle.fromPoints(
        Vector2(game.size.x, groundLevel + groundOffsetY),
        Vector2(game.size.x * 1.5, groundLevel + groundOffsetY),
      ),
      random: game.random,
    ));

    // random mobile obstacles as player moves
    // only appear from lvl 2 and above
    if (game.level.number > 1) {
      add(
        SpawnComponent.periodRange(
          factory: (_) => MobileObstacle(),
          minPeriod: 3,
          maxPeriod: 8,
          area: Rectangle.fromPoints(
            Vector2(game.size.x, groundLevel - minPlatformHeight),
            Vector2(game.size.x * 1.5, groundLevel - maxPlatformHeight * 2),
          ),
        ),
      );
    }

    // place 3 initial recycle items randomly
    for (var i = 1; i < 5; i++) {
      double rand = game.random.nextDouble();
      add(
        RecycleItem(
          position: Vector2(
            // horizontal increment of 1/4 screen + 1/3 screen increment
            rand * game.size.x / 4 + game.size.x / 3 * i,
            // vertical space between ground and max platform height * 2
            rand * (-maxPlatformHeight * 2) + groundLevel,
          ),
        ),
      );
    }

    // random recycle items spawn as player moves
    add(SpawnComponent.periodRange(
      factory: (_) => RecycleItem(),
      minPeriod: 2,
      maxPeriod: 4,
      area: Rectangle.fromPoints(
        Vector2(game.size.x, groundLevel - minPlatformHeight),
        Vector2(game.size.x * 1.5, groundLevel - maxPlatformHeight * 2),
      ),
      random: game.random,
    ));

    // add player character
    bin = BinPlayer();
    add(bin);
  }
}
