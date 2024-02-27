import 'package:logging/logging.dart';

import '../../level_selection/levels.dart';
import '../../style/palette.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart';

/// This dialog is shown when a level is completed.
///
/// It shows what time the level was completed in and if there are more levels
/// it lets the user go to the next level, or otherwise back to the level
/// selection screen.
class GameWinDialog extends StatefulWidget {
  const GameWinDialog({
    super.key,
    required this.level,
    required this.levelCompletedIn,
  });

  /// The properties of the level that was just finished.
  final GameLevel level;

  /// How many seconds that the level was completed in.
  final int levelCompletedIn;

  @override
  State<GameWinDialog> createState() => _GameWinDialogState();
}

class _GameWinDialogState extends State<GameWinDialog> {
  static final _logger = Logger('GameWinDialog logger');

  // Helper fn to load image to cache for faster widget builds
  Future<void> cacheImage() async {
    try {
      _logger.info('Caching Image: ${widget.level.recyleImage}');
      // load image from asset to cache
      await precacheImage(AssetImage(widget.level.recyleImage), context);
    } catch (e) {
      // log error
      _logger.severe('Could not load image ${widget.level.recyleImage}: $e', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.read<Palette>();
    cacheImage();
    return Center(
      child: NesContainer(
        label:
            'Level ${widget.level.number} completed in ${widget.levelCompletedIn}s',
        width: 500,
        height: 700,
        backgroundColor: palette.backgroundPlaySession.color,
        // Code Tip: to make Column become scrollable when overflow
        // Wrap with LayoutBuilder and SingleChildScrollView & ConstrainedBox
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scrollController = ScrollController();
            // Code Tip: to add visible scroll bar to scroll view
            // Wrap Scrollbar and set the same ScrollController for both widgets
            return Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: scrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(widget.level.recyleImage, width: 300),
                      const SizedBox(height: 16),
                      Text(
                        'Well done!',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(widget.level.recycleFact,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 32),
                      if (widget.level.number < gameLevels.length) ...[
                        NesButton(
                          onPressed: () {
                            // need to pop current route before supply a new parameter
                            GoRouter.of(context).pop();
                            // go to next level
                            GoRouter.of(context)
                                .go('/play/session/${widget.level.number + 1}');
                          },
                          type: NesButtonType.primary,
                          child: const Text('Next level'),
                        ),
                        const SizedBox(height: 16),
                      ],
                      NesButton(
                        onPressed: () {
                          GoRouter.of(context).pop();
                          GoRouter.of(context).go('/play');
                        },
                        type: NesButtonType.normal,
                        child: const Text('Level selection'),
                      ),

                      // Google Wallet Button - not working for web!
                      // const SizedBox(height: 16),
                      // const WalletButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
