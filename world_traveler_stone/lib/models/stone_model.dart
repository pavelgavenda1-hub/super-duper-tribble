import 'package:cloud_firestore/cloud_firestore.dart';

class StoneModel {
  final String id;
  final String qrCode;
  final String? currentOwnerId;
  final GeoPoint? currentLocation;
  final List<String> previousOwners;
  final List<LocationHistory> history;
  final DateTime createdAt;
  final bool isLost;

  StoneModel({
    required this.id,
    required this.qrCode,
    this.currentOwnerId,
    this.currentLocation,
    this.previousOwners = const [],
    this.history = const [],
    required this.createdAt,
    this.isLost = false,
  });

  // Convert StoneModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qrCode': qrCode,
      'currentOwnerId': currentOwnerId,
      'currentLocation': currentLocation != null
          ? {
              'latitude': currentLocation!.latitude,
              'longitude': currentLocation!.longitude,
            }
          : null,
      'previousOwners': previousOwners,
      'history': history.map((h) => h.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isLost': isLost,
    };
  }

  // Create StoneModel from JSON
  factory StoneModel.fromJson(Map<String, dynamic> json) {
    return StoneModel(
      id: json['id'] as String,
      qrCode: json['qrCode'] as String,
      currentOwnerId: json['currentOwnerId'] as String?,
      currentLocation: json['currentLocation'] != null
          ? GeoPoint(
              json['currentLocation']['latitude'] as double,
              json['currentLocation']['longitude'] as double,
            )
          : null,
      previousOwners: (json['previousOwners'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      history: (json['history'] as List<dynamic>?)
              ?.map((h) => LocationHistory.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      isLost: json['isLost'] as bool? ?? false,
    );
  }

  // Create a copy with modified fields
  StoneModel copyWith({
    String? id,
    String? qrCode,
    String? currentOwnerId,
    GeoPoint? currentLocation,
    List<String>? previousOwners,
    List<LocationHistory>? history,
    DateTime? createdAt,
    bool? isLost,
  }) {
    return StoneModel(
      id: id ?? this.id,
      qrCode: qrCode ?? this.qrCode,
      currentOwnerId: currentOwnerId ?? this.currentOwnerId,
      currentLocation: currentLocation ?? this.currentLocation,
      previousOwners: previousOwners ?? this.previousOwners,
      history: history ?? this.history,
      createdAt: createdAt ?? this.createdAt,
      isLost: isLost ?? this.isLost,
    );
  }
}

class LocationHistory {
  final GeoPoint location;
  final String ownerId;
  final DateTime timestamp;
  final String? story;
  final String? photoUrl;

  LocationHistory({
    required this.location,
    required this.ownerId,
    required this.timestamp,
    this.story,
    this.photoUrl,
  });

  // Convert LocationHistory to JSON
  Map<String, dynamic> toJson() {
    return {
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'ownerId': ownerId,
      'timestamp': timestamp.toIso8601String(),
      'story': story,
      'photoUrl': photoUrl,
    };
  }

  // Create LocationHistory from JSON
  factory LocationHistory.fromJson(Map<String, dynamic> json) {
    return LocationHistory(
      location: GeoPoint(
        json['location']['latitude'] as double,
        json['location']['longitude'] as double,
      ),
      ownerId: json['ownerId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      story: json['story'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
