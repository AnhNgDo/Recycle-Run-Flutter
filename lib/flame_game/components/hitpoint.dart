import 'dart:async';
import 'package:flame/components.dart';

import '../recycle_game.dart';

// state of Hitpoint sprite
enum HpState {
  available,
  depleted,
}

class HitPoint extends SpriteGroupComponent<HpState>
    with HasGameRef<RecycleRunGame> {
  // hp number that this Sprite presents
  final int hpNumber;

  HitPoint({required this.hpNumber, required super.position})
      : super(size: Vector2.all(32));

  @override
  FutureOr<void> onLoad() {
    // load sprites
    final spriteAvailable = Sprite(game.images.fromCache('huds/heart.png'));
    final spriteDepleted = Sprite(game.images.fromCache('huds/heart_half.png'));

    // set sprite mapping property
    sprites = {
      HpState.available: spriteAvailable,
      HpState.depleted: spriteDepleted,
    };

    // default state to full onLoad
    current = HpState.available;
  }

  @override
  void update(double dt) {
    // deplete sprite based on current hitpoint
    if (hpNumber > game.currentHPs) {
      current = HpState.depleted;
    } else {
      current = HpState.available;
    }

    super.update(dt);
  }
}
