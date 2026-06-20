import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikaku_puzzle/app/app.dart';

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
    expect(find.text('Version 1.0.0'), findsOneWidget);
    expect(find.text('Made by EpicBrain'), findsOneWidget);
  });
}
