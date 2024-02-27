// This is the player controlled character
import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recycle_run_game/flame_game/components/mobile_obstacle.dart';

import '../../audio/sounds.dart';
import '../recycle_game.dart';
import '../recycle_world.dart';
import 'platform.dart';
import 'stationary_obstacle.dart';

// player will be in one of these states any given time
enum BinPlayerState {
  running,
  jumping,
  falling,
}

class BinPlayer extends SpriteAnimationGroupComponent
    with
        HasGameRef<RecycleRunGame>,
        HasWorldReference<RecycleRunWorld>,
        CollisionCallbacks,
        KeyboardHandler,
        TapCallbacks {
  BinPlayer()
      : super(
          size: Vector2.all(RecycleRunGame.playerSize),
          anchor: Anchor.center,
          priority: 9,
        );

  // initial x position of player
  final double startPositionX = 150;

  // movement physics
  final double maxSpeedX = 100;
  final double gravity = 700;
  final double jumpSpeed = 500;
  late final Vector2 velocity;
  bool canJump = true; // to allow jump and double-jump

  // interactions
  bool hitByEnemy = false;
  bool onPlatform = false; // if player is on platform (above ground)

  // check whether player is in-air to prevent jumping while already in-air.
  // and adjusted for y for anchor center (up is negative for y-axis).
  bool get inAir =>
      (position.y < world.groundLevel - size.y / 2) && !onPlatform;

  // check whether player is jumping
  bool get isJumping => velocity.y < 0;

  @override
  FutureOr<void> onLoad() {
    // Define different animations for running, jumping, falling
    animations = {
      BinPlayerState.running: SpriteAnimation.fromFrameData(
        // access game's images via mixins
        game.images.fromCache('bin_running.png'),
        // sprite animation via inheritance
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.2,
          textureSize: Vector2.all(256),
        ),
      ),
      BinPlayerState.jumping: SpriteAnimation.fromFrameData(
        game.images.fromCache('bin_jumping.png'),
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 0.5,
          textureSize: Vector2.all(256),
        ),
      ),
      BinPlayerState.falling: SpriteAnimation.fromFrameData(
        game.images.fromCache('bin_falling.png'),
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 0.5,
          textureSize: Vector2.all(256),
        ),
      ),
    };

    // set initial state = running horizontally from starting position.
    // starting at 3xheight of character for effect.
    position = Vector2(startPositionX, world.groundLevel - 3 * size.y);
    current = BinPlayerState.running;
    velocity = Vector2(maxSpeedX, 0);

    // add hitbox for collision
    add(RectangleHitbox());

    // debug mode show collition box
    // debugMode = true;
  }

  // game loop
  @override
  void update(double dt) {
    // update horizontal velocity
    if (position.x + size.x >= game.size.x / 2) {
      // prevent player going off (mid) screen
      velocity.x = 0;
    } else {
      // smooth out initial horizonal movement as player approach mid screen
      velocity.x =
          maxSpeedX * ((game.size.x / 2 - position.x) / (game.size.x / 2));
    }

    // update vertical velocity and player animation
    // IMPORTANT: update pixel value with (* dt) so make sure it works cross devices
    if (isJumping) {
      current = BinPlayerState.jumping;
      velocity.y += gravity * dt;
    } else if (inAir) {
      // if not jumping but still in air
      current = BinPlayerState.falling;
      velocity.y += gravity * dt;
    } else {
      current = BinPlayerState.running;
      velocity.y = 0;
      canJump = true; // reset to allow jump or double jump again
    }

    // update position in both directions x,y
    position += velocity * dt;

    // call super (syntax)
    super.update(dt);
  }

  // collision logic
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Platform) {
      // mid point of collision surface
      final mid =
          (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) /
              2;

      // if collision happens at bottom 25% of player hitbox
      // then let player run on platform (stop vertical motion)
      // else bounce back (stop any left over jumping motion)
      if (absoluteCenter.y + size.y / 4 < mid.y) {
        onPlatform = true;
        velocity.y = 0;
      } else {
        onPlatform = false;
        velocity.y = 0;
      }
    }

    // tumble and lose hitpoint if hit obstacles and play sound
    if (other is StationaryObstacle || other is MobileObstacle) {
      // use flag to only run hit collision logic once
      if (!hitByEnemy) {
        hitByEnemy = true;
        game.audioController.playSfx(SfxType.damage);
        game.currentHPs--;

        // hit effect: tumble forward and flashing white
        // once animation finish, set hitByEnemy back to default (false)
        addAll(
          [
            RotateEffect.by(
              pi * 2,
              EffectController(
                duration: 0.5,
                curve: Curves.easeInOut,
              ),
              onComplete: () => hitByEnemy = false,
            ),
            MoveByEffect(
              Vector2(20, 0),
              EffectController(
                duration: 0.5,
                curve: Curves.easeInOut,
              ),
            ),
            ColorEffect(
              Colors.white,
              EffectController(
                duration: 0.25,
                alternate: true,
                repeatCount: 2,
              ),
              opacityTo: 0.9,
            ),
          ],
        );
      }
    }

    // syntax req
    super.onCollisionStart(intersectionPoints, other);
  }

  // to reset back to default states after collisions
  @override
  void onCollisionEnd(PositionComponent other) {
    // reset back to default state once finishes platform
    if (other is Platform) onPlatform = false;

    // syntax req
    super.onCollisionEnd(other);
  }

  // jump with space key
  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // only jump if not already in air
    if (keysPressed.contains(LogicalKeyboardKey.space) && canJump) {
      // play jump sound
      game.audioController.playSfx(SfxType.jump);
      // move with initial jump speed
      velocity.y = -jumpSpeed;

      // can only double jump (jump once while already in air)
      if (inAir) canJump = false;
    }
    return true;
  }

  // jump with tap
  @override
  void onTapDown(TapDownEvent event) {
    // only jump if not already in air
    if (canJump) {
      // play jump sound
      game.audioController.playSfx(SfxType.jump);
      // move with initial jump speed
      velocity.y = -jumpSpeed;

      // can only double jump (jump once while already in air)
      if (inAir) canJump = false;
    }
  }

  // to accept tap input from anywhere on screen, not just on player
  @override
  bool containsLocalPoint(Vector2 point) {
    return true;
  }
}
