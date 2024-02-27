import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

import '../recycle_game.dart';

enum ObstacleType {
  small,
  medium,
  large,
}

/// [StationaryObstacle] are fixed enemies. Player will lose HP when hit them.
/// Apperance (sprite) changes based on game level's theme.
class StationaryObstacle extends SpriteComponent
    with HasGameRef<RecycleRunGame> {
  final String imageName;

  final Vector2 velocity = Vector2.zero();

  StationaryObstacle.small({super.position})
      : imageName = 'obstacles/trash_small.png',
        super(
          size: Vector2.all(64),
          anchor: Anchor.bottomLeft,
        );

  StationaryObstacle.medium({super.position})
      : imageName = 'obstacles/trash_medium.png',
        super(
          size: Vector2(155, 64),
          anchor: Anchor.bottomLeft,
        );

  StationaryObstacle.large({super.position})
      : imageName = 'obstacles/trash_large.png',
        super(
          size: Vector2(144, 128),
          anchor: Anchor.bottomLeft,
        );

  // for SpawnComponent to spawn random ostacles based on game's level
  factory StationaryObstacle.random({
    required int level,
    required Random random,
  }) {
    // to store possible obstacle types
    final List<Enum> obstacleTypes;

    // determine possible obstacle types based on level
    switch (level) {
      case 1:
        obstacleTypes = [ObstacleType.small, ObstacleType.medium];
        break;
      case 2 || 3:
        obstacleTypes = [
          ObstacleType.small,
          ObstacleType.medium,
          ObstacleType.large
        ];
        break;
      default:
        obstacleTypes = [ObstacleType.small, ObstacleType.medium];
    }

    // display random obstacle from possible types
    final type = obstacleTypes.random(random);

    switch (type) {
      case ObstacleType.small:
        return StationaryObstacle.small();
      case ObstacleType.medium:
        return StationaryObstacle.medium();
      case ObstacleType.large:
        return StationaryObstacle.large();
    }

    // default
    return StationaryObstacle.small();
  }

  // initialise object
  @override
  FutureOr<void> onLoad() {
    // load sprite image
    sprite = Sprite(game.images.fromCache(imageName));

    // add hitbox
    // Hacky: require image filename contain word 'large' for large obstacle sprite
    if (imageName.contains('large')) {
      // triangle hitbox for large obstacles
      // note coord 0,0 is always top-left of rectangle
      add(PolygonHitbox(
          [Vector2(0, size.y), Vector2(size.x / 2, 0), Vector2(size.x, size.y)],
          collisionType: CollisionType.passive));
    } else {
      // rectangle hitbox for other obstacles
      add(RectangleHitbox(collisionType: CollisionType.passive));
    }

    // move left to create illusion of player running right
    velocity.x = -game.objSpeed;

    // debug mode
    // debugMode = true;
  }

  // game loop
  @override
  void update(double dt) {
    // clean up
    if (position.x < -size.x) {
      removeFromParent();
    }

    // update ground position
    position += velocity * dt;

    super.update(dt);
  }
}
