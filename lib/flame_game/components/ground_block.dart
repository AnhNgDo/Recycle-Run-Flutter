import 'dart:async';

import 'package:flame/components.dart';
import 'package:recycle_run_game/flame_game/recycle_world.dart';

import '../recycle_game.dart';

// not using since parallax runs better?
class GroundBlock extends SpriteComponent
    with HasGameRef<RecycleRunGame>, HasWorldReference<RecycleRunWorld> {
  final Vector2 velocity = Vector2.zero();

  GroundBlock({required Vector2 position})
      : super(
          anchor: Anchor.bottomLeft,
          size: Vector2.all(RecycleRunGame.blockSize),
          position: position,
        );

  @override
  FutureOr<void> onLoad() {
    final groundImage = game.images.fromCache('ground.png');
    sprite = Sprite(groundImage);
  }

  @override
  void update(double dt) {
    // clean up
    if (position.x < -size.x) {
      removeFromParent();
      world.add(GroundBlock(position: Vector2(game.size.x - 3, 0)));
    }

    // to move ground blocks with other game objects
    velocity.x = -game.objSpeed;

    // update ground position
    position += velocity * dt;

    super.update(dt);
  }
}
