import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stone_model.dart';
import '../models/statistics_model.dart';
import 'location_service.dart';

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();

  // Calculate stone statistics
  Future<StoneStatistics> calculateStoneStatistics(StoneModel stone) async {
    double totalDistance = 0;
    final Set<String> countries = {};
    Duration longestStay = Duration.zero;
    String longestStayLocation = '';

    // Calculate total distance and countries
    for (int i = 1; i < stone.history.length; i++) {
      final prev = stone.history[i - 1];
      final curr = stone.history[i];

      // Calculate distance
      final distance = _locationService.calculateDistance(
        prev.location.latitude,
        prev.location.longitude,
        curr.location.latitude,
        curr.location.longitude,
      );
      totalDistance += distance;

      // Get country
      final country = await _locationService.getCountryFromLocation(
        prev.location.latitude,
        prev.location.longitude,
      );
      if (country != null) {
        countries.add(country);
      }

      // Calculate stay duration
      final stayDuration = curr.timestamp.difference(prev.timestamp);
      if (stayDuration > longestStay) {
        longestStay = stayDuration;
        final address = await _locationService.getAddressFromCoordinates(
          prev.location.latitude,
          prev.location.longitude,
        );
        longestStayLocation = address ?? 'Neznámá lokace';
      }
    }

    // Don't forget the last location's country
    if (stone.history.isNotEmpty) {
      final lastLocation = stone.history.last.location;
      final country = await _locationService.getCountryFromLocation(
        lastLocation.latitude,
        lastLocation.longitude,
      );
      if (country != null) {
        countries.add(country);
      }
    }

    // Count unique visitors from history
    final Set<String> visitors = {};
    for (final historyEntry in stone.history) {
      visitors.add(historyEntry.ownerId);
    }

    return StoneStatistics(
      totalDistance: totalDistance,
      countriesVisited: countries.toList(),
      totalOwners: visitors.length, // Now it's visitors, not owners
      longestStay: longestStay,
      longestStayLocation: longestStayLocation,
    );
  }

  // Calculate user statistics
  Future<UserStatistics> calculateUserStatistics(String userId) async {
    try {
      // Get stones owned by user
      final ownedStonesSnapshot = await _firestore
          .collection('stones')
          .where('ownerId', isEqualTo: userId)
          .get();

      final ownedStones = ownedStonesSnapshot.docs
          .map((doc) => StoneModel.fromJson(doc.data()))
          .toList();

      // Get all stones to check for visits
      final allStonesSnapshot = await _firestore.collection('stones').get();
      final allStones = allStonesSnapshot.docs
          .map((doc) => StoneModel.fromJson(doc.data()))
          .toList();

      int stonesFound = ownedStones.length; // Stones user owns (first to scan)
      int stonesVisited = 0; // Stones user visited (in history)
      double totalDistance = 0;
      final Set<String> countries = {};

      // Count visits and calculate distance
      for (final stone in allStones) {
        // Check if user visited this stone (appears in history)
        final userVisits = stone.history.where((h) => h.ownerId == userId);
        if (userVisits.isNotEmpty) {
          stonesVisited++;

          // Calculate distance for user's visits
          for (int i = 0; i < stone.history.length; i++) {
            if (stone.history[i].ownerId == userId && i > 0) {
              final prev = stone.history[i - 1];
              final curr = stone.history[i];

              final distance = _locationService.calculateDistance(
                prev.location.latitude,
                prev.location.longitude,
                curr.location.latitude,
                curr.location.longitude,
              );
              totalDistance += distance;
            }

            // Get countries visited by user
            if (stone.history[i].ownerId == userId) {
              final country = await _locationService.getCountryFromLocation(
                stone.history[i].location.latitude,
                stone.history[i].location.longitude,
              );
              if (country != null) {
                countries.add(country);
              }
            }
          }
        }
      }

      // Get user's diamonds
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final diamonds = userDoc.data()?['diamonds'] as int? ?? 0;

      return UserStatistics(
        stonesFound: stonesFound, // Stones user owns
        stonesMoved: stonesVisited, // Stones user visited
        totalDistanceMoved: totalDistance,
        countriesVisited: countries.toList(),
        diamondsEarned: diamonds,
        totalStones: stonesVisited, // Total stones interacted with
      );
    } catch (e) {
      print('Error calculating user statistics: $e');
      return UserStatistics(
        stonesFound: 0,
        stonesMoved: 0,
        totalDistanceMoved: 0,
        countriesVisited: [],
        diamondsEarned: 0,
        totalStones: 0,
      );
    }
  }

  // Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard(LeaderboardType type) async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final entries = <LeaderboardEntry>[];

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final userName = userData['name'] as String? ?? 'Unknown';
        int value = 0;

        switch (type) {
          case LeaderboardType.diamonds:
            value = userData['diamonds'] as int? ?? 0;
            break;
          case LeaderboardType.stonesFound:
            // Count stones owned by this user
            final stats = await calculateUserStatistics(userDoc.id);
            value = stats.stonesFound;
            break;
          case LeaderboardType.distance:
            final stats = await calculateUserStatistics(userDoc.id);
            value = stats.totalDistanceMoved.toInt();
            break;
          case LeaderboardType.countriesVisited:
            final stats = await calculateUserStatistics(userDoc.id);
            value = stats.countriesVisited.length;
            break;
        }

        entries.add(LeaderboardEntry(
          userId: userDoc.id,
          userName: userName,
          value: value,
          rank: 0, // Will be set after sorting
        ));
      }

      // Sort by value descending
      entries.sort((a, b) => b.value.compareTo(a.value));

      // Assign ranks
      for (int i = 0; i < entries.length; i++) {
        entries[i] = LeaderboardEntry(
          userId: entries[i].userId,
          userName: entries[i].userName,
          value: entries[i].value,
          rank: i + 1,
        );
      }

      return entries.take(10).toList(); // Top 10
    } catch (e) {
      print('Error getting leaderboard: $e');
      return [];
    }
  }
}
