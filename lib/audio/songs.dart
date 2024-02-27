const List<Song> songs = [
  Song('intro_theme.mp3', 'Platformer Game Music Pack', artist: 'CodeManu'),
  Song('free_run.mp3', 'Free Run', artist: 'TAD'),
  Song('boss_theme.mp3', 'Platformer Game Music Pack', artist: 'CodeManu'),
  Song('dungeon_theme.mp3', 'Platformer Game Music Pack', artist: 'CodeManu'),
];

class Song {
  final String filename;

  final String name;

  final String? artist;

  const Song(this.filename, this.name, {this.artist});

  @override
  String toString() => 'Song<$filename>';
}
