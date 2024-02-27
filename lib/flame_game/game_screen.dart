import 'dart:ui';

import 'package:flame/game.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart';

import 'recycle_game.dart';
import 'components/game_win_overlay.dart';
import 'components/game_start_overaly.dart';
import 'components/game_over_overlay.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../audio/audio_controller.dart';
import '../level_selection/levels.dart';

/// This widget defines the properties of the game screen.
///
/// It mostly sets up the overlays (widgets shown on top of the Flame game) and
/// the gets the [AudioController] from the context and passes it in to the
/// game class so that it can play audio.
class GameScreen extends StatelessWidget {
  const GameScreen({required this.level, super.key});

  final GameLevel level;

  // to build overlays on top of game
  static const String winDialogKey = 'win_dialog';
  static const String backButtonKey = 'back_buttton';
  static const String gameOverKey = 'game_over';
  static const String gameStartKey = 'game_start';

  @override
  Widget build(BuildContext context) {
    // pass global states to Game obj so its components can freely access
    // Code Note: use '.watch' within build method
    final audioController = context.watch<AudioController>();
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();

    // build game widget
    return Scaffold(
      body: GameWidget<RecycleRunGame>.controlled(
        key: const Key('play session'),
        gameFactory: () => RecycleRunGame(
          audioController: audioController,
          palette: palette,
          playerProgress: playerProgress,
          level: level,
        ),
        backgroundBuilder: (context) {
          // a blurred background image behind game widget
          return ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  // Note: use full image path for web build to work properly
                  image: AssetImage('assets/images/backdrop.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
        loadingBuilder: (context) => const Material(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        overlayBuilderMap: {
          backButtonKey: (context, game) {
            // use [Positioned] widget to place widget any where on screen
            return Positioned(
              top: 40,
              right: 5,
              child: NesButton(
                type: NesButtonType.normal,
                onPressed: GoRouter.of(context).pop,
                child: NesIcon(iconData: NesIcons.leftArrowIndicator),
              ),
            );
          },
          gameStartKey: (context, game) => GameStartDialog(game: game),
          gameOverKey: (context, game) => GameOverDialog(game: game),
          winDialogKey: (context, game) {
            // display game in dialog
            return GameWinDialog(
              level: level,
              levelCompletedIn: game.levelCompletedIn,
            );
          },
        },
      ),
    );
  }
}
