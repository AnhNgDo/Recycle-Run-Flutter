import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../recycle_game.dart';

/// [MobileObstacle] are enemies moving across screen.
/// Player will lose HP when hit them.
class MobileObstacle extends SpriteAnimationComponent
    with HasGameReference<RecycleRunGame> {
  final String mobileObstacle = 'obstacles/trash_ball.png';
  final Vector2 smallObstacleSize = Vector2.all(64);
  final Vector2 largeObstacleSize = Vector2.all(100);

  // movements
  // x times faster than other object to create illusion of obstacle flying across
  final double speedMulitple = 2.0;
  late Vector2 velocity = Vector2.zero();

  MobileObstacle({super.position}) : super(anchor: Anchor.center);

  @override
  FutureOr<void> onLoad() {
    // set animation
    animation = SpriteAnimation.fromFrameData(
      // access game's images via mixins
      game.images.fromCache('obstacles/trash_ball.png'),
      // sprite animation via inheritance
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.25,
        textureSize: Vector2.all(256),
      ),
    );

    // large mobile obstacle for lvl 3+
    size = (game.level.number < 3) ? smallObstacleSize : largeObstacleSize;

    // add hitbox
    add(CircleHitbox(collisionType: CollisionType.passive));

    // fly across the screen
    velocity.x = -game.objSpeed * speedMulitple;

    // debug box
    // debugMode = true;
  }

  @override
  void update(double dt) {
    // clean up
    if (position.x < -size.x) {
      removeFromParent();
    }

    // update ground position
    position += velocity * dt;

    // syntax
    super.update(dt);
  }
}
