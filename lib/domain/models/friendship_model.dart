import 'friendship_status.dart';

/// Database model representing relationship state between two player IDs.
class FriendshipModel {
  final String id;
  final String userA;
  final String userB;
  final FriendshipStatus status;
  final String requestedBy;
  final int createdAt;
  final int updatedAt;

  const FriendshipModel({
    required this.id,
    required this.userA,
    required this.userB,
    required this.status,
    required this.requestedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userA': userA,
        'userB': userB,
        'status': status.name,
        'requestedBy': requestedBy,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory FriendshipModel.fromJson(Map<String, dynamic> json) => FriendshipModel(
        id: json['id'] as String,
        userA: json['userA'] as String,
        userB: json['userB'] as String,
        status: FriendshipStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => FriendshipStatus.none,
        ),
        requestedBy: json['requestedBy'] as String,
        createdAt: json['createdAt'] as int,
        updatedAt: json['updatedAt'] as int,
      );
}
