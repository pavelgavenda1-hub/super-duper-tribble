import 'package:cloud_firestore/cloud_firestore.dart';

class StoneModel {
  final String id;
  final String qrCode;
  final String? ownerId; // První uživatel, který kámen naskenoval
  final String? ownerName; // Jméno vlastníka
  final GeoPoint? currentLocation;
  final List<LocationHistory> history;
  final DateTime createdAt;
  final bool isLost;

  // Nové fieldy pro příběh kamene
  final String? name; // Název kamene
  final String? story; // Příběh kamene
  final List<String> photos; // URL fotek
  final int visitCount; // Počet návštěv (skenování)
  final bool isPublic; // Je příběh veřejný?

  StoneModel({
    required this.id,
    required this.qrCode,
    this.ownerId,
    this.ownerName,
    this.currentLocation,
    this.history = const [],
    required this.createdAt,
    this.isLost = false,
    this.name,
    this.story,
    this.photos = const [],
    this.visitCount = 0,
    this.isPublic = true,
  });

  // Convert StoneModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qrCode': qrCode,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'currentLocation': currentLocation != null
          ? {
              'latitude': currentLocation!.latitude,
              'longitude': currentLocation!.longitude,
            }
          : null,
      'history': history.map((h) => h.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isLost': isLost,
      'name': name,
      'story': story,
      'photos': photos,
      'visitCount': visitCount,
      'isPublic': isPublic,
    };
  }

  // Create StoneModel from JSON
  factory StoneModel.fromJson(Map<String, dynamic> json) {
    return StoneModel(
      id: json['id'] as String,
      qrCode: json['qrCode'] as String,
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      currentLocation: json['currentLocation'] != null
          ? GeoPoint(
              json['currentLocation']['latitude'] as double,
              json['currentLocation']['longitude'] as double,
            )
          : null,
      history: (json['history'] as List<dynamic>?)
              ?.map((h) => LocationHistory.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      isLost: json['isLost'] as bool? ?? false,
      name: json['name'] as String?,
      story: json['story'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      visitCount: json['visitCount'] as int? ?? 0,
      isPublic: json['isPublic'] as bool? ?? true,
    );
  }

  // Create a copy with modified fields
  StoneModel copyWith({
    String? id,
    String? qrCode,
    String? ownerId,
    String? ownerName,
    GeoPoint? currentLocation,
    List<LocationHistory>? history,
    DateTime? createdAt,
    bool? isLost,
    String? name,
    String? story,
    List<String>? photos,
    int? visitCount,
    bool? isPublic,
  }) {
    return StoneModel(
      id: id ?? this.id,
      qrCode: qrCode ?? this.qrCode,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      currentLocation: currentLocation ?? this.currentLocation,
      history: history ?? this.history,
      createdAt: createdAt ?? this.createdAt,
      isLost: isLost ?? this.isLost,
      name: name ?? this.name,
      story: story ?? this.story,
      photos: photos ?? this.photos,
      visitCount: visitCount ?? this.visitCount,
      isPublic: isPublic ?? this.isPublic,
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
