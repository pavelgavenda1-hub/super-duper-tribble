import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/achievement_service.dart';
import '../../services/auth_service.dart';
import '../../models/achievement_model.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievementService = AchievementService();
    final authService = AuthService();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Nejste přihlášeni')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievementy'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<UserAchievements>(
        stream: achievementService.userAchievementsStream(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Chyba: ${snapshot.error}'),
            );
          }

          final userAchievements = snapshot.data;
          if (userAchievements == null) {
            return const Center(
              child: Text('Žádné achievementy'),
            );
          }

          final unlockedCount = userAchievements.unlockedAchievements.length;
          final totalCount = userAchievements.achievements.length;
          final completionPercentage = userAchievements.completionPercentage;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Progress header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '$unlockedCount / $totalCount',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Odemčeno ${completionPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 15),
                      LinearProgressIndicator(
                        value: completionPercentage / 100,
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.diamond,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${userAchievements.totalDiamondsFromAchievements} 💎 z achievementů',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Unlocked achievements
                if (userAchievements.unlockedAchievements.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Odemčené (${unlockedCount})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...userAchievements.unlockedAchievements
                      .map((a) => _buildAchievementCard(context, a, true)),
                ],

                // Locked achievements
                if (userAchievements.lockedAchievements.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Zamčené (${totalCount - unlockedCount})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...userAchievements.lockedAchievements
                      .map((a) => _buildAchievementCard(context, a, false)),
                ],

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementCard(
      BuildContext context, Achievement achievement, bool unlocked) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: unlocked ? Colors.white : Colors.grey[100],
      elevation: unlocked ? 3 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: unlocked
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                achievement.icon,
                size: 32,
                color: unlocked
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: unlocked ? Colors.black : Colors.grey[600],
                          ),
                        ),
                      ),
                      if (unlocked)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        )
                      else
                        const Icon(
                          Icons.lock,
                          color: Colors.grey,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: unlocked ? Colors.grey[700] : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.diamond,
                        size: 16,
                        color: unlocked ? Colors.amber : Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${achievement.diamondReward} 💎',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: unlocked ? Colors.amber[800] : Colors.grey[500],
                        ),
                      ),
                      if (unlocked && achievement.unlockedAt != null) ...[
                        const SizedBox(width: 15),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd.MM.yyyy')
                              .format(achievement.unlockedAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
