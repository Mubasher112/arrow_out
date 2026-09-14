import '../config/environment.dart';
import '../domain/models/support_ticket.dart';

/// Service submitting player support tickets and social abuse reports with safe diagnostic metadata.
class SupportService {
  final List<SupportTicket> _submittedTickets = [];

  List<SupportTicket> get submittedTickets => _submittedTickets;

  /// Submit a support ticket or feedback.
  Future<SupportTicket> submitTicket({
    required String category,
    required String description,
    int? levelId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final ticket = SupportTicket(
      ticketId: 'ticket_$now',
      category: category,
      description: description,
      levelId: levelId,
      status: 'Open',
      createdAt: now,
      diagnostics: {
        'appVersion': AppConfig.defaultConfig.version,
        'environment': AppConfig.defaultConfig.environment.name,
      },
    );

    _submittedTickets.add(ticket);
    return ticket;
  }
}
