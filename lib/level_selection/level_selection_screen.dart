import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart';

import 'instructions_dialog.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../player_progress/player_progress.dart';
import '../style/wobbly_button.dart';
import '../style/palette.dart';
import 'levels.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();
    final levelTextStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4);

    return Scaffold(
      backgroundColor: palette.backgroundLevelSelection.color,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Select Level',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'How to play',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary.color,
                    ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: NesButton(
                  type: NesButtonType.normal,
                  child: NesIcon(
                    iconData: NesIcons.questionMark,
                    size: const Size(12, 12),
                  ),
                  onPressed: () {
                    NesDialog.show(
                      context: context,
                      builder: (_) => const InstructionsDialog(),
                    );
                  },
                ),
              )
            ],
          ),
          const Flexible(child: SizedBox(height: 32)),
          // Code Tips: set fixed size viewport for ListView
          // by using SizedBox + shrinkWrap --> at cost of performance
          SizedBox(
            width: 500,
            height: 150,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final level in gameLevels)
                  ListTile(
                    enabled: playerProgress.levels.length >= level.number - 1,
                    onTap: () {
                      final audioController = context.read<AudioController>();
                      audioController.playSfx(SfxType.buttonTap);

                      GoRouter.of(context).go('/play/session/${level.number}');
                    },
                    leading: Text(
                      '#${level.number}.',
                      style: levelTextStyle,
                    ),
                    title: Row(
                      children: [
                        Text(
                          level.name,
                          style: levelTextStyle,
                        ),
                        // The spread operator ...[ ] syntax is used to
                        // conditionally include a list of widgets
                        // in the children property of the Row widget.
                        if (playerProgress.levels.length <
                            level.number - 1) ...[
                          const SizedBox(width: 10),
                          const Icon(Icons.lock, size: 20),
                        ] else if (playerProgress.levels.length >=
                            level.number) ...[
                          const SizedBox(width: 50),
                          Text(
                            '${playerProgress.levels[level.number - 1]}s',
                            style: levelTextStyle,
                          ),
                        ],
                      ],
                    ),
                  )
              ],
            ),
          ),
          const Flexible(child: SizedBox(height: 32)),
          WobblyButton(
            onPressed: () {
              GoRouter.of(context).go('/');
            },
            child: const Text('Back'),
          ),
          const Flexible(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
