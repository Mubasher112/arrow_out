import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_path/services/support_service.dart';

void main() {
  group('SupportService', () {
    late SupportService supportService;

    setUp(() {
      supportService = SupportService();
    });

    test('creates and stores support tickets', () async {
      final ticket = await supportService.submitTicket(
        category: 'Bug Report',
        description: 'Arrow stuck on level 12',
        levelId: 12,
      );

      expect(ticket.ticketId, startsWith('ticket_'));
      expect(ticket.category, equals('Bug Report'));
      expect(ticket.levelId, equals(12));

      final tickets = supportService.submittedTickets;
      expect(tickets.length, equals(1));
      expect(tickets.first.description, equals('Arrow stuck on level 12'));
    });
  });
}
