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

    return StoneStatistics(
      totalDistance: totalDistance,
      countriesVisited: countries.toList(),
      totalOwners: stone.previousOwners.length,
      longestStay: longestStay,
      longestStayLocation: longestStayLocation,
    );
  }

  // Calculate user statistics
  Future<UserStatistics> calculateUserStatistics(String userId) async {
    try {
      // Get all stones where user is in previousOwners
      final stonesSnapshot = await _firestore
          .collection('stones')
          .where('previousOwners', arrayContains: userId)
          .get();

      final stones =
          stonesSnapshot.docs.map((doc) => StoneModel.fromJson(doc.data())).toList();

      int stonesFound = 0;
      int stonesMoved = 0;
      double totalDistance = 0;
      final Set<String> countries = {};

      for (final stone in stones) {
        // Count stones found (user is in previousOwners)
        if (stone.previousOwners.contains(userId)) {
          stonesFound++;
        }

        // Count moves by this user
        final userMoves = stone.history.where((h) => h.ownerId == userId);
        stonesMoved += userMoves.length;

        // Calculate distance for user's moves
        for (int i = 1; i < stone.history.length; i++) {
          if (stone.history[i].ownerId == userId) {
            final prev = stone.history[i - 1];
            final curr = stone.history[i];

            final distance = _locationService.calculateDistance(
              prev.location.latitude,
              prev.location.longitude,
              curr.location.latitude,
              curr.location.longitude,
            );
            totalDistance += distance;

            // Get country
            final country = await _locationService.getCountryFromLocation(
              curr.location.latitude,
              curr.location.longitude,
            );
            if (country != null) {
              countries.add(country);
            }
          }
        }
      }

      // Get user's diamonds
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final diamonds = userDoc.data()?['diamonds'] as int? ?? 0;

      return UserStatistics(
        stonesFound: stonesFound,
        stonesMoved: stonesMoved,
        totalDistanceMoved: totalDistance,
        countriesVisited: countries.toList(),
        diamondsEarned: diamonds,
        totalStones: stones.length,
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
            // This would need to be calculated from stones collection
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
