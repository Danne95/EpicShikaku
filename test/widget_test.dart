import 'package:flutter_test/flutter_test.dart';
import 'package:shikaku_puzzle/app/app.dart';

/// Verifies that the app shell renders the puzzle screen.
void main() {
  testWidgets('shows the puzzle screen', (tester) async {
    await tester.pumpWidget(const ShikakuPuzzleApp());
    await tester.pumpAndSettle();

    expect(find.text('Shikaku Puzzle'), findsOneWidget);
    expect(find.text('Drag across cells to create rectangles.'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });
}
