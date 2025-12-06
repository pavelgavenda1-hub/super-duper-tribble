import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/qr_service.dart';
import '../../models/user_model.dart';
import '../../models/stone_model.dart';
import '../stone/stone_detail_screen.dart';
import '../achievements/achievements_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final qrService = QRService();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Nejste přihlášeni')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<UserModel?>(
        stream: authService.userDataStream(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // User info
                Text(
                  userData?.name ?? 'Uživatel',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  currentUser.email ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                // Diamonds
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.diamond,
                        size: 40,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Diamanty',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${userData?.diamonds ?? 0}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // My Stones Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Moje kameny',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      StreamBuilder<List<StoneModel>>(
                        stream: qrService.userStonesStream(currentUser.uid),
                        builder: (context, stonesSnapshot) {
                          if (stonesSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final stones = stonesSnapshot.data ?? [];

                          if (stones.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Zatím jste nenašli žádný kámen',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Naskenujte QR kód na kameni!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              // Stones counter
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green[200]!,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.place,
                                      color: Colors.green[700],
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Vlastníte ${stones.length} ${stones.length == 1 ? "kámen" : stones.length < 5 ? "kameny" : "kamenů"}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              // Stones list
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: stones.length,
                                itemBuilder: (context, index) {
                                  final stone = stones[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        child: const Icon(
                                          Icons.place,
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: Text(
                                        stone.name ??
                                            'Kámen #${stone.id.substring(0, 8)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.visibility,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${stone.visitCount} návštěv',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              const Icon(
                                                Icons.history,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${stone.history.length} lokací',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right,
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StoneDetailScreen(
                                              stoneId: stone.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Menu items
                _buildMenuItem(
                  context,
                  icon: Icons.emoji_events,
                  title: 'Achievementy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AchievementsScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.bar_chart,
                  title: 'Moje statistiky',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Statistiky budou přidány v FÁZI 7'),
                      ),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Nastavení',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nastavení bude přidáno později'),
                      ),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.help,
                  title: 'Nápověda',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nápověda bude přidána později'),
                      ),
                    );
                  },
                ),

                const Divider(height: 30),

                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Odhlásit se',
                  color: Colors.red,
                  onTap: () async {
                    await authService.signOut();
                  },
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: color,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
