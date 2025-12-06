import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement_model.dart';
import '../models/stone_model.dart';
import 'statistics_service.dart';
import 'diamond_service.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StatisticsService _statisticsService = StatisticsService();
  final DiamondService _diamondService = DiamondService();

  // Get user's achievements
  Future<UserAchievements> getUserAchievements(String userId) async {
    try {
      final allAchievements = Achievement.getAllAchievements();
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final achievementsData =
          userDoc.data()?['achievements'] as Map<String, dynamic>? ?? {};

      final userAchievements = <Achievement>[];
      int totalDiamonds = 0;

      for (final template in allAchievements) {
        final typeKey = template.type.toString();
        if (achievementsData.containsKey(typeKey)) {
          final achievement =
              Achievement.fromJson(achievementsData[typeKey], template);
          userAchievements.add(achievement);
          if (achievement.unlocked) {
            totalDiamonds += achievement.diamondReward;
          }
        } else {
          userAchievements.add(template);
        }
      }

      return UserAchievements(
        userId: userId,
        achievements: userAchievements,
        totalDiamondsFromAchievements: totalDiamonds,
      );
    } catch (e) {
      print('Error getting user achievements: $e');
      return UserAchievements(
        userId: userId,
        achievements: Achievement.getAllAchievements(),
      );
    }
  }

  // Check and unlock achievements for a user
  Future<List<Achievement>> checkAndUnlockAchievements(String userId) async {
    try {
      final newlyUnlocked = <Achievement>[];

      // Get current achievements
      final userAchievements = await getUserAchievements(userId);

      // Get user statistics
      final stats = await _statisticsService.calculateUserStatistics(userId);

      // Get user's stones
      final stonesSnapshot = await _firestore
          .collection('stones')
          .where('ownerId', isEqualTo: userId)
          .get();
      final stones =
          stonesSnapshot.docs.map((doc) => StoneModel.fromJson(doc.data())).toList();

      // Get user data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final diamonds = userDoc.data()?['diamonds'] as int? ?? 0;

      // Count photos and stories
      int totalPhotos = 0;
      int totalStories = 0;
      int publicStones = 0;
      int privateStones = 0;

      for (final stone in stones) {
        totalPhotos += stone.photos.length;
        if (stone.story != null && stone.story!.isNotEmpty) {
          totalStories++;
        }
        if (stone.isPublic) {
          publicStones++;
        } else {
          privateStones++;
        }
      }

      // Check each achievement
      for (final achievement in userAchievements.achievements) {
        if (achievement.unlocked) continue; // Already unlocked

        bool shouldUnlock = false;

        switch (achievement.type) {
          case AchievementType.firstStone:
            shouldUnlock = stats.stonesFound >= 1;
            break;
          case AchievementType.collector5:
            shouldUnlock = stats.stonesFound >= 5;
            break;
          case AchievementType.collector10:
            shouldUnlock = stats.stonesFound >= 10;
            break;
          case AchievementType.collector25:
            shouldUnlock = stats.stonesFound >= 25;
            break;
          case AchievementType.collector50:
            shouldUnlock = stats.stonesFound >= 50;
            break;
          case AchievementType.worldTraveler:
            shouldUnlock = stats.countriesVisited.length >= 5;
            break;
          case AchievementType.globetrotter:
            shouldUnlock = stats.countriesVisited.length >= 10;
            break;
          case AchievementType.explorer:
            shouldUnlock = stats.stonesMoved >= 100;
            break;
          case AchievementType.photographer:
            shouldUnlock = totalPhotos >= 10;
            break;
          case AchievementType.storyteller:
            shouldUnlock = totalStories >= 10;
            break;
          case AchievementType.diamondHunter1000:
            shouldUnlock = diamonds >= 1000;
            break;
          case AchievementType.diamondHunter5000:
            shouldUnlock = diamonds >= 5000;
            break;
          case AchievementType.diamondHunter10000:
            shouldUnlock = diamonds >= 10000;
            break;
          case AchievementType.socialite:
            shouldUnlock = publicStones >= 10;
            break;
          case AchievementType.mysterious:
            shouldUnlock = privateStones >= 10;
            break;
        }

        if (shouldUnlock) {
          final unlockedAchievement = achievement.copyWith(
            unlocked: true,
            unlockedAt: DateTime.now(),
          );
          newlyUnlocked.add(unlockedAchievement);

          // Save to Firestore
          await _saveAchievement(userId, unlockedAchievement);

          // Award diamonds
          await _diamondService.awardDiamonds(
            userId: userId,
            amount: achievement.diamondReward,
            reason: 'Achievement: ${achievement.title}',
          );
        }
      }

      return newlyUnlocked;
    } catch (e) {
      print('Error checking achievements: $e');
      return [];
    }
  }

  // Save single achievement to Firestore
  Future<void> _saveAchievement(String userId, Achievement achievement) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'achievements.${achievement.type.toString()}': achievement.toJson(),
      });
    } catch (e) {
      print('Error saving achievement: $e');
    }
  }

  // Get achievement by type
  Future<Achievement?> getAchievement(
      String userId, AchievementType type) async {
    try {
      final userAchievements = await getUserAchievements(userId);
      return userAchievements.achievements.firstWhere(
        (a) => a.type == type,
      );
    } catch (e) {
      print('Error getting achievement: $e');
      return null;
    }
  }

  // Stream of user achievements
  Stream<UserAchievements> userAchievementsStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().asyncMap(
      (doc) async {
        return await getUserAchievements(userId);
      },
    );
  }
}
