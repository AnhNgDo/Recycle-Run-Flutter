import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../recycle_game.dart';

/// [Platform] for player to jump on.
/// Apperance (sprite) changes based on game level's theme.
///
/// Note: sprite images must have platform height ~1/3 height of canvas.

class Platform extends SpriteComponent with HasGameReference<RecycleRunGame> {
  late String imageName;

  final Vector2 velocity = Vector2.zero();

  Platform({super.position}) : super(anchor: Anchor.bottomLeft);

  /// [setImage] assign [imageName] a random image path based on game level.
  /// This should called in onLoad after game instance is initialised.
  void setImage() {
    // lists of files for each level
    // change file names or add new files here
    final List<String> platformsLvL1 = [
      'platforms/beach_platform_01.png',
      'platforms/beach_platform_02.png',
      'platforms/beach_platform_03.png',
    ];

    final List<String> platformsLvL2 = [
      'platforms/town_platform_01.png',
      'platforms/town_platform_02.png',
      'platforms/town_platform_03.png',
    ];

    final List<String> platformsLvL3 = [
      'platforms/city_platform_01.png',
      'platforms/city_platform_02.png',
      'platforms/city_platform_03.png',
    ];

    // select list of files based on game level
    List<String> imageNames = [];
    switch (game.level.number) {
      case 1:
        imageNames = platformsLvL1;
        break;
      case 2:
        imageNames = platformsLvL2;
        break;
      case 3:
        imageNames = platformsLvL3;
        break;
    }

    // select random image from list to create different obstacles
    imageName = imageNames[game.random.nextInt(imageNames.length)];
  }

  // game initialise
  @override
  FutureOr<void> onLoad() {
    // load sprite image
    setImage();
    sprite = Sprite(game.images.fromCache(imageName));

    // add hitbox around top part of platform
    // equal to width x 1/6 height (starting from 5/6 of y-axis)
    // assuming platform is 1/3 and bottom of the sprit image
    add(RectangleHitbox(
      position: Vector2(0, size.y * 5 / 6),
      size: Vector2(size.x, size.y / 6),
      anchor: Anchor.bottomLeft,
      collisionType: CollisionType.passive,
    ));

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
