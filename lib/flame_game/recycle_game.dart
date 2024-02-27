import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:recycle_run_game/audio/sounds.dart';

import 'package:recycle_run_game/style/palette.dart';

import '../audio/audio_controller.dart';
import '../level_selection/levels.dart';
import '../player_progress/player_progress.dart';
import 'components/background.dart';
import 'components/hud.dart';
import 'recycle_world.dart';
import 'game_screen.dart';

class RecycleRunGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  // pixel settings
  static const double playerSize = 64;
  static const double blockSize = 128;

  // to share music and sfx player
  final AudioController audioController;

  // to share color pallete
  final Palette palette;

  // to share player progress
  final PlayerProgress playerProgress;

  // to share random generator
  final Random random = Random();

  // game states
  final GameLevel level;
  bool levelCompleted = false;
  bool isGameOver = false;

  // player states
  final int maxHps = 3;
  late int currentHPs;
  int score = 0;

  // object states
  double objSpeed = 350;

  // Construtor
  RecycleRunGame({
    required this.audioController,
    required this.palette,
    required this.playerProgress,
    required this.level,
  }) : super(
          world: RecycleRunWorld(),
          camera: CameraComponent.withFixedResolution(width: 1600, height: 720),
        );

  // level timer
  final double timeLimit = 46;
  late int timeLeft;
  late int levelCompletedIn;
  late Timer timer;

  // overlay display delay
  final Duration overlayDelay = const Duration(milliseconds: 200);

  @override
  Future<void> onLoad() async {
    // set game coordinate to be (0,0) at Top Left corner
    camera.viewfinder.anchor = Anchor.bottomLeft;

    // add parallax background
    camera.backdrop.add(Background(levelNumber: level.number, speed: objSpeed));

    // load image to cache once and reuse many times
    await images.loadAll([
      'bin_running.png',
      'bin_jumping.png',
      'bin_falling.png',
      'huds/clock.png',
      'huds/heart.png',
      'huds/heart_half.png',
      'huds/recycle_symbol.png',
      'platforms/beach_platform_01.png',
      'platforms/beach_platform_02.png',
      'platforms/beach_platform_03.png',
      'platforms/town_platform_01.png',
      'platforms/town_platform_02.png',
      'platforms/town_platform_03.png',
      'platforms/city_platform_01.png',
      'platforms/city_platform_02.png',
      'platforms/city_platform_03.png',
      'obstacles/trash_small.png',
      'obstacles/trash_medium.png',
      'obstacles/trash_large.png',
      'obstacles/trash_ball.png',
      'recyclable_items/bottle.png',
      'recyclable_items/can.png',
      'recyclable_items/drink_bottle.png',
      'recyclable_items/jar.png',
      'recyclable_items/sauce_bottle.png',
      'recyclable_items/paper_01.png',
      'recyclable_items/paper_02.png',
      'recyclable_items/paper_03.png',
      'recyclable_items/paper_04.png',
      'recyclable_items/paper_05.png',
      'recyclable_items/electronic_01.png',
      'recyclable_items/electronic_02.png',
      'recyclable_items/electronic_03.png',
      'recyclable_items/electronic_04.png',
      'recyclable_items/electronic_05.png',
    ]);

    // initial game states
    currentHPs = maxHps;

    // start level timer and set initial time limit
    timer = Timer(timeLimit);
    timeLeft = timeLimit.toInt();

    // add Huds to viewport to always overlay game
    camera.viewport.add(Hud()); // default is MaxViewport, position (0,0)

    // add overlays
    Future.delayed(overlayDelay, () {
      overlays.add(GameScreen.backButtonKey);
      overlays.add(GameScreen.gameStartKey);
      pauseEngine();
    });
  }

  // Reset game after Game Over
  void reset() {
    // remove overlay
    overlays.remove(GameScreen.gameOverKey);

    // remove old world and add a new fresh world to game
    remove(world);
    world = RecycleRunWorld();
    add(world);

    // reset to initial game states
    currentHPs = maxHps;
    score = 0;
    isGameOver = false;

    // reset timer
    // timeStarted = DateTime.now();
    timer.reset();
    timeLeft = timeLimit.toInt();

    // resume game
    resumeEngine();
  }

  @override
  void update(double dt) {
    // update level time
    timer.update(dt);
    timeLeft = (timeLimit - timer.current).toInt();

    // Game over if health = 0 or run out of time for the round
    if ((currentHPs <= 0 || timeLeft == 0) && !isGameOver) {
      isGameOver = true; // ensure Game Over logic only run once

      // let game loop run a few seconds before pause
      Future.delayed(overlayDelay, () {
        pauseEngine();
        // play game over sound
        audioController.playSfx(SfxType.gameOver);
        // add game over dialog
        overlays.add(GameScreen.gameOverKey);
      });
    }
    // Win level if reach required score, only if not Game Over
    else if (score >= level.winScore && !levelCompleted) {
      // toggle update flag. Ensure level compelte logic only run once.
      levelCompleted = true;

      // update level completion time
      levelCompletedIn = timer.current.toInt();

      // update player progress (with persistence)
      playerProgress.setLevelFinished(level.number, levelCompletedIn);

      // let game loop run a few seconds before pause
      Future.delayed(overlayDelay, () {
        pauseEngine();
        // show win screen
        overlays.add(GameScreen.winDialogKey);
      });
    }

    // parent component
    super.update(dt);
  }
}
