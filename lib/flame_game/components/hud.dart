import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';
import 'package:recycle_run_game/audio/sounds.dart';

import '../recycle_game.dart';
import 'hitpoint.dart';

class Hud extends PositionComponent with HasGameRef<RecycleRunGame> {
  Hud({super.position}) : super(priority: 5);

  // elements of score Hud
  late final SpriteComponent _scoreSprite;
  late final TextComponent _score;

  // elements of timer Hud
  late final SpriteComponent _clockSprite;
  late final TextComponent _time;
  bool _clockAnimated = false;

  @override
  FutureOr<void> onLoad() {
    // Hitpoints Hud, each is 40px apart, suitable if sprite is 32px wide
    for (var i = 1; i <= game.maxHps; i++) {
      final positionX = 40 * i;
      add(
        HitPoint(
          hpNumber: i,
          position: Vector2(positionX.toDouble(), 20),
        ),
      );
    }

    // Score Hud (icon + score text)
    _scoreSprite = SpriteComponent(
      sprite: Sprite(game.images.fromCache('huds/recycle_symbol.png')),
      size: Vector2.all(40),
      position: Vector2(game.size.x - 138, 60),
      anchor: Anchor.bottomCenter,
    );

    _score = TextComponent(
      text: '${game.score}',
      position: Vector2(game.size.x - 90, 60),
      anchor: Anchor.bottomCenter,
      textRenderer: TextPaint(
        style: TextStyle(
          fontFamily: 'Press Start 2P',
          fontSize: 30,
          color: game.palette.textHud.color,
        ),
      ),
    );

    // Clock Hud
    _clockSprite = SpriteComponent(
      sprite: Sprite(game.images.fromCache('huds/clock.png')),
      size: Vector2.all(40),
      position: Vector2(game.size.x / 2, 50),
      anchor: Anchor.bottomCenter,
    );

    _time = TextBoxComponent(
      text: '${game.timeLeft}',
      position: Vector2(game.size.x / 2 + 128, 60),
      anchor: Anchor.bottomCenter,
      textRenderer: TextPaint(
        style: TextStyle(
          fontFamily: 'Press Start 2P',
          fontSize: 30,
          color: game.palette.textHud.color,
        ),
      ),
    );

    // add all Hud components
    addAll([
      _scoreSprite,
      _score,
      _clockSprite,
      _time,
    ]);
  }

  @override
  void update(double dt) {
    _score.text = '${game.score}';
    _time.text = '${game.timeLeft}';

    // Play Sound and animate once when time is nearly up
    if (game.timeLeft == 8 && !_clockAnimated) {
      _clockAnimated = true;
      game.audioController.playSfx(SfxType.timeUp);
      _clockSprite.add(
        MoveByEffect(
          Vector2(0, -8),
          EffectController(
            duration: 0.5,
            curve: Curves.easeIn,
            alternate: true,
            repeatCount: 5,
          ),
          onComplete: () => _clockAnimated = false,
        ),
      );
    }

    super.update(dt);
  }
}
