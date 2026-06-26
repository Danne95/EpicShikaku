/// Static application metadata shown in the UI.
class AppMetadata {
  const AppMetadata._();

  /// Human-readable app version.
  static const versionLabel = '1.1.0';

  /// Player-facing patch notes for the current app version.
  ///
  /// Keep technical, generic, and internal implementation notes out of this
  /// list because these notes are shown directly to users.
  static const patchNotes = [
    PatchNote(
      title: 'Release 1.1.0',
      changes: [
        'Added a settings button to check for app updates.',
        'Made direct APK updates easier to start from inside the app.',
      ],
    ),
    PatchNote(
      title: 'Release 1.0.0',
      changes: [
        'Generated Shikaku puzzles with adjustable board sizes.',
        'Dark mode, vibration, and saved local settings.',
        'Added a sound setting for game sound effects.',
        'Added scrollable patch notes to the settings screen.',
        'Completion confetti with a quick New puzzle action.',
      ],
    ),
  ];

  /// Signature shown on the settings screen.
  static const signature = 'Made by EpicBrain';
}

/// User-facing changes for one released app version.
class PatchNote {
  /// Creates patch notes for a single app release.
  const PatchNote({required this.title, required this.changes});

  /// Version or release title shown above the changes.
  final String title;

  /// Short change descriptions shown to users.
  final List<String> changes;
}
