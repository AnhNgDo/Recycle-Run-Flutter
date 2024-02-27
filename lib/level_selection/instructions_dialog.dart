import 'package:flame/components.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';

/// Instruction box with 3 swipable mini pages.
/// Implemented using PageView.
class InstructionsDialog extends StatefulWidget {
  const InstructionsDialog({super.key});

  @override
  State<InstructionsDialog> createState() => _InstructionsDialogState();
}

class _InstructionsDialogState extends State<InstructionsDialog> {
  final _pageController = PageController();
  late int _currentPage = _pageController.initialPage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Instructions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Flexible(child: SizedBox(height: 30)),
        Row(
          children: [
            SizedBox(
              width: 30,
              child: _currentPage != 0
                  ? NesIconButton(
                      icon: NesIcons.leftArrowIndicator,
                      onPress: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                  : null,
            ),
            Flexible(
              fit: FlexFit.tight,
              child: SizedBox(
                width: 350,
                height: 200,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int newPage) {
                    setState(() {
                      _currentPage = newPage;
                    });
                  },
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 3,
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: SpriteAnimationWidget.asset(
                              path: 'bin_running.png',
                              data: SpriteAnimationData.sequenced(
                                amount: 4,
                                stepTime: 0.25,
                                textureSize: Vector2.all(256),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Flexible(
                          flex: 7,
                          child: Text(
                            '''Press SPACE or Tap/Click on the screen to jump.
                            While in air, SPACE or tap again to double jump (ONCE only).''',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          flex: 7,
                          child: Text(
                            '''Collect Recycle Items within the Time Limit to progress to next Level.''',
                          ),
                        ),
                        const SizedBox(width: 20),
                        Flexible(
                          flex: 3,
                          child: SizedBox(
                            width: 90,
                            height: 60,
                            child: SpriteWidget.asset(
                              path: 'recyclable_items/recycle_items.png',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 4,
                          child: SizedBox(
                            width: 100,
                            height: 200,
                            child: SpriteAnimationWidget.asset(
                              path: 'obstacles/obstacles.png',
                              data: SpriteAnimationData.sequenced(
                                amount: 4,
                                stepTime: 0.25,
                                textureSize: Vector2(256, 512),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Flexible(
                          flex: 6,
                          child: Text(
                            '''Avoid these obstacles, they will make you lose HPs. 
                            If you run out of Hearts, it's GameOver!''',
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 30,
              child: _currentPage != 2
                  ? NesIconButton(
                      icon: NesIcons.rightArrowIndicator,
                      onPress: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }
}
