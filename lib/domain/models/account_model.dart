import 'auth_provider.dart';

/// Non-sensitive player account details.
class AccountModel {
  final String userId;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final AuthProvider provider;
  final int createdAt;
  final int? lastSyncedAt;

  const AccountModel({
    required this.userId,
    required this.displayName,
    this.email,
    this.photoUrl,
    required this.provider,
    required this.createdAt,
    this.lastSyncedAt,
  });

  bool get isGuest => provider == AuthProvider.guest;

  AccountModel copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    AuthProvider? provider,
    int? lastSyncedAt,
  }) {
    return AccountModel(
      userId: userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'provider': provider.name,
        'createdAt': createdAt,
        'lastSyncedAt': lastSyncedAt,
      };

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        userId: json['userId'] as String,
        displayName: json['displayName'] as String,
        email: json['email'] as String?,
        photoUrl: json['photoUrl'] as String?,
        provider: AuthProvider.fromString(json['provider'] as String),
        createdAt: json['createdAt'] as int,
        lastSyncedAt: json['lastSyncedAt'] as int?,
      );

  factory AccountModel.createGuest({String? guestId}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = guestId ?? 'guest_${now}';
    return AccountModel(
      userId: id,
      displayName: 'Guest Player',
      provider: AuthProvider.guest,
      createdAt: now,
    );
  }
}
