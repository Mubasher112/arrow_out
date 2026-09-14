import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/services/audio_service.dart';
import 'package:arrow_path/services/support_service.dart';
import 'package:arrow_path/ui/widgets/support_dialog.dart';

void main() {
  testWidgets('SupportDialog renders input fields and submits feedback', (WidgetTester tester) async {
    final supportService = SupportService();
    final audioService = AudioService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SupportDialog(
            supportService: supportService,
            audioService: audioService,
          ),
        ),
      ),
    );

    expect(find.text('Feedback & Support'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('SUBMIT TICKET'), findsOneWidget);

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, 'Great game, love the arrow puzzles!');
    await tester.tap(find.text('SUBMIT TICKET'));
    await tester.pumpAndSettle();

    final tickets = supportService.submittedTickets;
    expect(tickets.length, equals(1));
    expect(tickets.first.description, equals('Great game, love the arrow puzzles!'));
  });
}
