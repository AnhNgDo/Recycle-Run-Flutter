import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart';

import '../recycle_game.dart';
import '../../style/palette.dart';
import '../game_screen.dart';

class GameStartDialog extends StatelessWidget {
  final RecycleRunGame game;
  const GameStartDialog({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // access color palette context in build method
    final palette = context.watch<Palette>();

    return SafeArea(
      child: Center(
        child: NesContainer(
          width: 400,
          height: 300,
          backgroundColor: palette.backgroundPlaySession.color,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ready ?',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '''Gather ${game.level.winScore} Recycle Points to complete this level.
                \n\nTap Button to Start!''',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              NesButton(
                onPressed: () {
                  game.overlays.remove(GameScreen.gameStartKey);
                  game.resumeEngine();
                },
                type: NesButtonType.primary,
                child: const Text('Start'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
