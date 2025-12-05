class UserModel {
  final String id;
  final String email;
  final String name;
  final int diamonds;
  final List<DiamondTransaction> diamondHistory;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.diamonds = 0,
    this.diamondHistory = const [],
  });

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'diamonds': diamonds,
      'diamondHistory': diamondHistory.map((t) => t.toJson()).toList(),
    };
  }

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      diamonds: json['diamonds'] as int? ?? 0,
      diamondHistory: (json['diamondHistory'] as List<dynamic>?)
              ?.map((t) => DiamondTransaction.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Create a copy with modified fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    int? diamonds,
    List<DiamondTransaction>? diamondHistory,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      diamonds: diamonds ?? this.diamonds,
      diamondHistory: diamondHistory ?? this.diamondHistory,
    );
  }
}

class DiamondTransaction {
  final int amount;
  final String reason;
  final DateTime timestamp;
  final String? relatedStoneId;

  DiamondTransaction({
    required this.amount,
    required this.reason,
    required this.timestamp,
    this.relatedStoneId,
  });

  // Convert DiamondTransaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
      'relatedStoneId': relatedStoneId,
    };
  }

  // Create DiamondTransaction from JSON
  factory DiamondTransaction.fromJson(Map<String, dynamic> json) {
    return DiamondTransaction(
      amount: json['amount'] as int,
      reason: json['reason'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      relatedStoneId: json['relatedStoneId'] as String?,
    );
  }
}
