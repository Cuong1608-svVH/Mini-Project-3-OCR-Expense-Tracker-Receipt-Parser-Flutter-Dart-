import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const OcrExpenseTrackerApp());
    expect(find.byType(OcrExpenseTrackerApp), findsOneWidget);
  });
}
