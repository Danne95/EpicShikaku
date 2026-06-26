import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikaku_puzzle/app/application/app_update_controller.dart';
import 'package:shikaku_puzzle/app/app.dart';
import 'package:shikaku_puzzle/app/data/app_update_service.dart';

/// Verifies that the app shell renders the puzzle screen.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the puzzle screen', (tester) async {
    await tester.pumpWidget(const ShikakuPuzzleApp());
    await tester.pump();

    expect(find.text('EpicShikaku'), findsOneWidget);
    expect(
      find.text(
        'Drag to create rectangles. Tap a completed region to remove it.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows the settings screen', (tester) async {
    await tester.pumpWidget(const ShikakuPuzzleApp());
    await tester.pump();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('Vibration'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Updates'), findsOneWidget);
    expect(find.text('Check for updates'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();

    expect(find.text('Patch notes'), findsOneWidget);
    expect(
      find.text('Generated Shikaku puzzles with adjustable board sizes.'),
      findsOneWidget,
    );
    expect(find.text('Version 1.1.1'), findsOneWidget);
    expect(find.text('Made by EpicBrain'), findsOneWidget);
  });

  testWidgets('shows update available state', (tester) async {
    final updateController = AppUpdateController(
      service: _FakeUpdateService(
        result: AppUpdateCheckResult(
          isUpdateAvailable: true,
          release: AppRelease(
            version: AppVersion.parse('v1.0.1'),
            downloadUri: Uri.parse('https://example.com/EpicShikaku.apk'),
            releaseNotes: 'Better generated puzzles.',
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ShikakuPuzzleApp(updateController: updateController),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    await tester.pump();

    expect(find.text('get update'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Version 1.0.1 is available.'), findsNothing);
    expect(find.text('Better generated puzzles.'), findsNothing);
    expect(find.text('Download update'), findsNothing);
  });

  testWidgets('shows up to date state', (tester) async {
    final updateController = AppUpdateController(
      service: _FakeUpdateService(
        result: AppUpdateCheckResult(
          isUpdateAvailable: false,
          release: AppRelease(
            version: AppVersion.parse('v1.0.0'),
            downloadUri: Uri.parse('https://example.com/EpicShikaku.apk'),
            releaseNotes: 'No changes.',
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ShikakuPuzzleApp(updateController: updateController),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    await tester.pump();

    final buttonFinder = find.widgetWithText(FilledButton, 'up to date');
    final button = tester.widget<FilledButton>(buttonFinder);

    expect(buttonFinder, findsOneWidget);
    expect(button.onPressed, isNull);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('shows update check failure state', (tester) async {
    final updateController = AppUpdateController(
      service: _FakeUpdateService(errorMessage: 'No GitHub release was found.'),
    );

    await tester.pumpWidget(
      ShikakuPuzzleApp(updateController: updateController),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    await tester.pump();

    expect(find.text('No GitHub release was found.'), findsOneWidget);
  });
}

class _FakeUpdateService extends AppUpdateService {
  _FakeUpdateService({this.result, this.errorMessage});

  final AppUpdateCheckResult? result;
  final String? errorMessage;

  @override
  Future<AppUpdateCheckResult> checkForUpdates() async {
    final errorMessage = this.errorMessage;
    if (errorMessage != null) {
      throw AppUpdateException(errorMessage);
    }

    return result ??
        AppUpdateCheckResult(
          isUpdateAvailable: false,
          release: AppRelease(
            version: AppVersion.parse('v1.0.0'),
            downloadUri: Uri.parse('https://example.com/EpicShikaku.apk'),
            releaseNotes: 'No changes.',
          ),
        );
  }
}
