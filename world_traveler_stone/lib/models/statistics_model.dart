class StoneStatistics {
  final double totalDistance;
  final List<String> countriesVisited;
  final int totalOwners;
  final Duration longestStay;
  final String longestStayLocation;

  StoneStatistics({
    required this.totalDistance,
    required this.countriesVisited,
    required this.totalOwners,
    required this.longestStay,
    required this.longestStayLocation,
  });
}

class UserStatistics {
  final int stonesFound;
  final int stonesMoved;
  final double totalDistanceMoved;
  final List<String> countriesVisited;
  final int diamondsEarned;
  final int totalStones;

  UserStatistics({
    required this.stonesFound,
    required this.stonesMoved,
    required this.totalDistanceMoved,
    required this.countriesVisited,
    required this.diamondsEarned,
    required this.totalStones,
  });
}

class LeaderboardEntry {
  final String userId;
  final String userName;
  final int value;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.value,
    required this.rank,
  });
}

enum LeaderboardType {
  diamonds,
  stonesFound,
  distance,
  countriesVisited,
}
