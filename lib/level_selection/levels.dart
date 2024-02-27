const gameLevels = <GameLevel>[
  (
    name: 'Sun, Sand & Recycling',
    number: 1,
    winScore: 8,
    recycleFact: '''Almost 14% of all litter are drinks bottles and cans. 
    \nYou will help massively by reclying them!''',
    recyleImage: 'assets/images/complete_level_01.png',
  ),
  (
    name: 'Paper Town Chaser',
    number: 2,
    winScore: 10,
    recycleFact: '''Around 17 trees are saved for every tons of recycled paper.
        \nPlus significant savings of water and energy!''',
    recyleImage: 'assets/images/complete_level_02.png',
  ),
  (
    name: 'Circuit City Scavenger',
    number: 3,
    winScore: 12,
    recycleFact:
        '''Recycling e-waste, while challenging, is a worthwhile endeavor!
        \nCongrats, you've completed all Recycle Run challenges!''',
    recyleImage: 'assets/images/complete_level_03.png',
  ),
];

typedef GameLevel = ({
  String name,
  int number,
  int winScore,
  String recycleFact,
  String recyleImage, // Note: use full image path for web build to work properly
});
