/// Model representing a player support ticket or bug report.
class SupportTicket {
  final String ticketId;
  final String category;
  final String description;
  final int? levelId;
  final String status;
  final int createdAt;
  final Map<String, dynamic> diagnostics;

  const SupportTicket({
    required this.ticketId,
    required this.category,
    required this.description,
    this.levelId,
    this.status = 'Open',
    required this.createdAt,
    required this.diagnostics,
  });

  Map<String, dynamic> toJson() => {
        'ticketId': ticketId,
        'category': category,
        'description': description,
        'levelId': levelId,
        'status': status,
        'createdAt': createdAt,
        'diagnostics': diagnostics,
      };

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
        ticketId: json['ticketId'] as String,
        category: json['category'] as String,
        description: json['description'] as String,
        levelId: json['levelId'] as int?,
        status: (json['status'] ?? 'Open') as String,
        createdAt: json['createdAt'] as int,
        diagnostics: (json['diagnostics'] as Map<String, dynamic>?) ?? const {},
      );
}
