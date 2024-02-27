import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';

/// The [Background] is a component that is composed of multiple scrolling
/// images which form a parallax, a way to simulate movement and depth in the
/// background.
class Background extends ParallaxComponent {
  Background({required this.levelNumber, required this.speed});

  final int levelNumber;
  final double speed;

  @override
  Future<void> onLoad() async {
    List<String> imageNames = [];

    switch (levelNumber) {
      case 1:
        imageNames = [
          'scenery/bluesky_background.png',
          'scenery/clouds_01.png',
          'scenery/mountains_01.png',
          'scenery/beach_horizon.png',
          'scenery/beach_ground.png'
        ];
        break;
      case 2:
        imageNames = [
          'scenery/bluesky_background.png',
          'scenery/clouds_01.png',
          'scenery/mountains_02.png',
          'scenery/town_horizon.png',
          'scenery/town_ground.png'
        ];
        break;
      case 3:
        imageNames = [
          'scenery/bluesky_background.png',
          'scenery/clouds_city.png',
          'scenery/city_background.png',
          'scenery/city_foreground.png',
          'scenery/city_ground.png'
        ];
        break;
    }

    // create parallax layers from image files
    final layers = imageNames.map((str) => ParallaxImageData(str)).toList();

    // set baseVelocity and velocityMultipler to match parallax speed
    // with game scrolling
    //
    // The base velocity sets the speed of the layer the farthest to the back.
    // Since the speed in our game is defined as the speed of the layer in the
    // front, where the player is, we have to calculate what speed the layer in
    // the back should have and then the parallax will take care of setting the
    // speeds for the rest of the layers.
    final baseVelocity = Vector2(speed / pow(2, layers.length), 0);

    // The multiplier delta is used by the parallax to multiply the speed of
    // each layer compared to the last, starting from the back. Since we only
    // want our layers to move in the X-axis, we multiply by something larger
    // than 1.0 here so that the speed of each layer is higher the closer to the
    // screen it is.
    final velocityMultiplierDelta = Vector2(2.0, 0.0);

    parallax = await game.loadParallax(
      layers,
      baseVelocity: baseVelocity,
      velocityMultiplierDelta: velocityMultiplierDelta,
    );
  }
}
