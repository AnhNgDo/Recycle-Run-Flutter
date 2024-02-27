import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart';

import '../recycle_game.dart';
import '../../style/palette.dart';

class GameOverDialog extends StatelessWidget {
  final RecycleRunGame game;
  const GameOverDialog({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // access color palette context in build method
    final palette = context.watch<Palette>();

    return Center(
      child: NesContainer(
        width: 420,
        height: 280,
        backgroundColor: palette.backgroundPlaySession.color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Game Over!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap Button to try again',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            NesButton(
              onPressed: () => game.reset(),
              type: NesButtonType.primary,
              child: const Text('Restart Level'),
            )
          ],
        ),
      ),
    );
  }
}
