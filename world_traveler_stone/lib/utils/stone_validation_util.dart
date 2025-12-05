import 'package:geolocator/geolocator.dart';
import '../models/stone_model.dart';
import '../services/location_service.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

class StoneValidationUtil {
  static const double MIN_DISTANCE_KM = 5.0; // Minimum 5 km
  static const int MIN_TIME_HOURS = 24; // Minimum 24 hours

  // Validate stone move
  static ValidationResult validateStoneMove({
    required StoneModel stone,
    required Position newPosition,
  }) {
    // Check if stone has any history
    if (stone.history.isEmpty) {
      // First move - always valid
      return ValidationResult(isValid: true);
    }

    // Get last location from history
    final lastHistory = stone.history.last;
    final lastLocation = lastHistory.location;
    final lastTimestamp = lastHistory.timestamp;

    // Calculate distance
    final locationService = LocationService();
    final distance = locationService.calculateDistance(
      lastLocation.latitude,
      lastLocation.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    // Check minimum distance
    if (distance < MIN_DISTANCE_KM) {
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Kámen musí být přemístěn alespoň $MIN_DISTANCE_KM km. '
            'Aktuální vzdálenost: ${distance.toStringAsFixed(2)} km',
      );
    }

    // Calculate time difference
    final now = DateTime.now();
    final timeDifference = now.difference(lastTimestamp);

    // Check minimum time interval
    if (timeDifference.inHours < MIN_TIME_HOURS) {
      final remainingHours = MIN_TIME_HOURS - timeDifference.inHours;
      return ValidationResult(
        isValid: false,
        errorMessage:
            'Kámen lze přemístit po $MIN_TIME_HOURS hodinách od posledního přesunu. '
            'Zbývá: $remainingHours hodin',
      );
    }

    // All validations passed
    return ValidationResult(isValid: true);
  }

  // Check if user can move stone (additional checks)
  static ValidationResult canUserMoveStone({
    required StoneModel stone,
    required String userId,
  }) {
    // Check if stone is lost
    if (stone.isLost) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Tento kámen je označen jako ztracený',
      );
    }

    // Additional business logic can be added here
    // For example: check if user has enough permissions, etc.

    return ValidationResult(isValid: true);
  }

  // Validate all move requirements
  static ValidationResult validateAllMoveRequirements({
    required StoneModel stone,
    required String userId,
    required Position newPosition,
  }) {
    // Check user permissions
    final userCheck = canUserMoveStone(stone: stone, userId: userId);
    if (!userCheck.isValid) {
      return userCheck;
    }

    // Check move validations
    final moveCheck = validateStoneMove(stone: stone, newPosition: newPosition);
    if (!moveCheck.isValid) {
      return moveCheck;
    }

    return ValidationResult(isValid: true);
  }
}
