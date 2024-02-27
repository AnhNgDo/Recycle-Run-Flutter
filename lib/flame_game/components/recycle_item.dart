import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:recycle_run_game/flame_game/components/recycle_bin.dart';

import '../../audio/sounds.dart';
import '../recycle_game.dart';

/// [RecycleItem] for player to collect.
/// Apperance (sprite) changes based on game level's theme
class RecycleItem extends SpriteComponent
    with HasGameRef<RecycleRunGame>, CollisionCallbacks {
  // sprite name
  late final String imageName;

  // collected by player
  bool collected = false;

  // velocity in both direction
  final Vector2 velocity = Vector2.zero();

  RecycleItem({super.position})
      : super(
          anchor: Anchor.center,
          scale: Vector2.all(0.4), // 40% orginal image size
        );

  /// Select a random image file to display different appearance.
  /// Potential images for display changes based on level (theme).
  void setImage() {
    // lists of files for each level
    // change file names or add new files here
    final List<String> obstaclesLvL1 = [
      'recyclable_items/bottle.png',
      'recyclable_items/can.png',
      'recyclable_items/drink_bottle.png',
      'recyclable_items/jar.png',
      'recyclable_items/sauce_bottle.png',
    ];

    final List<String> obstaclesLvL2 = [
      'recyclable_items/paper_01.png',
      'recyclable_items/paper_02.png',
      'recyclable_items/paper_03.png',
      'recyclable_items/paper_04.png',
      'recyclable_items/paper_05.png',
    ];

    final List<String> obstaclesLvL3 = [
      'recyclable_items/electronic_01.png',
      'recyclable_items/electronic_02.png',
      'recyclable_items/electronic_03.png',
      'recyclable_items/electronic_04.png',
      'recyclable_items/electronic_05.png',
    ];

    // select list of files based on game level
    final List<String> imageNames;
    switch (game.level.number) {
      case 1:
        imageNames = obstaclesLvL1;
        break;
      case 2:
        imageNames = obstaclesLvL2;
        break;
      case 3:
        imageNames = obstaclesLvL3;
        break;
      default:
        imageNames = obstaclesLvL1;
    }

    // select random image from the selected list
    imageName = imageNames.random(game.random);
  }

  @override
  FutureOr<void> onLoad() {
    // load sprite with random angles
    setImage();
    sprite = Sprite(game.images.fromCache(imageName));
    angle = [-0.2, -0.1, 0.0, 0.1, 0.1].random(game.random); // in radians

    // add idle effect (pulsing)
    add(ScaleEffect.by(
      Vector2.all(0.8),
      EffectController(
        duration: 1,
        alternate: true,
        infinite: true,
      ),
    ));

    // add hitbox
    add(RectangleHitbox(
      collisionType: CollisionType.passive,
    ));

    // move left to create illusion of player running right
    velocity.x = -game.objSpeed;

    // debug mode
    // debugMode = true;
  }

  // collision logics
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is BinPlayer && !collected) {
      collected = true;
      game.score++;
      game.audioController.playSfx(SfxType.score); // play scoring sound

      add(
        ScaleEffect.by(
          Vector2.all(0.2),
          EffectController(duration: 1),
          onComplete: () => removeFromParent(),
        ),
      );
    }

    // syntax
    super.onCollisionStart(intersectionPoints, other);
  }

  // game loop
  @override
  void update(double dt) {
    // clean up if when moved off-screen
    if (position.x < -size.x) removeFromParent();

    // update ground position
    position += velocity * dt;

    super.update(dt);
  }
}
