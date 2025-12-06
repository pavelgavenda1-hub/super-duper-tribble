import 'package:flutter/material.dart';

// Typy achievementů
enum AchievementType {
  firstStone, // První nalezený kámen
  collector5, // 5 kamenů
  collector10, // 10 kamenů
  collector25, // 25 kamenů
  collector50, // 50 kamenů
  worldTraveler, // Navštíveno 5+ zemí
  globetrotter, // Navštíveno 10+ zemí
  explorer, // 100+ návštěv kamenů
  photographer, // Přidáno 10+ fotek
  storyteller, // Přidáno 10+ příběhů
  diamondHunter1000, // 1000 diamantů
  diamondHunter5000, // 5000 diamantů
  diamondHunter10000, // 10000 diamantů
  socialite, // 10+ veřejných kamenů
  mysterious, // 10+ soukromých kamenů
}

// Achievement model
class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final IconData icon;
  final int requirement;
  final int diamondReward;
  final bool unlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.requirement,
    required this.diamondReward,
    this.unlocked = false,
    this.unlockedAt,
  });

  // Static list of all achievements
  static List<Achievement> getAllAchievements() {
    return [
      Achievement(
        type: AchievementType.firstStone,
        title: 'První nález',
        description: 'Našel jsi svůj první kámen!',
        icon: Icons.star,
        requirement: 1,
        diamondReward: 100,
      ),
      Achievement(
        type: AchievementType.collector5,
        title: 'Začínající sběratel',
        description: 'Vlastníš 5 kamenů',
        icon: Icons.collections,
        requirement: 5,
        diamondReward: 200,
      ),
      Achievement(
        type: AchievementType.collector10,
        title: 'Pokročilý sběratel',
        description: 'Vlastníš 10 kamenů',
        icon: Icons.collections_bookmark,
        requirement: 10,
        diamondReward: 500,
      ),
      Achievement(
        type: AchievementType.collector25,
        title: 'Mistr sběratel',
        description: 'Vlastníš 25 kamenů',
        icon: Icons.workspace_premium,
        requirement: 25,
        diamondReward: 1000,
      ),
      Achievement(
        type: AchievementType.collector50,
        title: 'Legendární sběratel',
        description: 'Vlastníš 50 kamenů',
        icon: Icons.emoji_events,
        requirement: 50,
        diamondReward: 2500,
      ),
      Achievement(
        type: AchievementType.worldTraveler,
        title: 'Světoběžník',
        description: 'Navštívil jsi 5 různých zemí',
        icon: Icons.public,
        requirement: 5,
        diamondReward: 300,
      ),
      Achievement(
        type: AchievementType.globetrotter,
        title: 'Globální cestovatel',
        description: 'Navštívil jsi 10 různých zemí',
        icon: Icons.flight_takeoff,
        requirement: 10,
        diamondReward: 1000,
      ),
      Achievement(
        type: AchievementType.explorer,
        title: 'Průzkumník',
        description: 'Navštívil jsi 100+ kamenů',
        icon: Icons.explore,
        requirement: 100,
        diamondReward: 750,
      ),
      Achievement(
        type: AchievementType.photographer,
        title: 'Fotograf',
        description: 'Přidal jsi 10+ fotek ke kamenům',
        icon: Icons.photo_camera,
        requirement: 10,
        diamondReward: 200,
      ),
      Achievement(
        type: AchievementType.storyteller,
        title: 'Vypravěč',
        description: 'Přidal jsi 10+ příběhů ke kamenům',
        icon: Icons.auto_stories,
        requirement: 10,
        diamondReward: 200,
      ),
      Achievement(
        type: AchievementType.diamondHunter1000,
        title: 'Lovec diamantů I',
        description: 'Získal jsi 1000 diamantů',
        icon: Icons.diamond,
        requirement: 1000,
        diamondReward: 100,
      ),
      Achievement(
        type: AchievementType.diamondHunter5000,
        title: 'Lovec diamantů II',
        description: 'Získal jsi 5000 diamantů',
        icon: Icons.diamond,
        requirement: 5000,
        diamondReward: 500,
      ),
      Achievement(
        type: AchievementType.diamondHunter10000,
        title: 'Lovec diamantů III',
        description: 'Získal jsi 10000 diamantů',
        icon: Icons.diamond,
        requirement: 10000,
        diamondReward: 1000,
      ),
      Achievement(
        type: AchievementType.socialite,
        title: 'Společenský',
        description: 'Máš 10+ veřejných kamenů',
        icon: Icons.group,
        requirement: 10,
        diamondReward: 150,
      ),
      Achievement(
        type: AchievementType.mysterious,
        title: 'Tajemný',
        description: 'Máš 10+ soukromých kamenů',
        icon: Icons.lock,
        requirement: 10,
        diamondReward: 150,
      ),
    ];
  }

  // Copy with updated values
  Achievement copyWith({
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      type: type,
      title: title,
      description: description,
      icon: icon,
      requirement: requirement,
      diamondReward: diamondReward,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'unlocked': unlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory Achievement.fromJson(Map<String, dynamic> json, Achievement template) {
    return template.copyWith(
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}

// User's achievement progress
class UserAchievements {
  final String userId;
  final List<Achievement> achievements;
  final int totalDiamondsFromAchievements;

  UserAchievements({
    required this.userId,
    required this.achievements,
    this.totalDiamondsFromAchievements = 0,
  });

  // Get unlocked achievements
  List<Achievement> get unlockedAchievements =>
      achievements.where((a) => a.unlocked).toList();

  // Get locked achievements
  List<Achievement> get lockedAchievements =>
      achievements.where((a) => !a.unlocked).toList();

  // Calculate completion percentage
  double get completionPercentage {
    if (achievements.isEmpty) return 0;
    return (unlockedAchievements.length / achievements.length) * 100;
  }
}
