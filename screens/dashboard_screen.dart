import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'workout_list_screen.dart';
import 'add_workout_screen.dart';
import 'stats_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'nutrition_screen.dart';
import 'leaderboard_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = '';
  int userId = 0;
  Map<String, dynamic> stats = {
    'total_workouts': 0,
    'total_calories': 0,
    'total_duration': 0,
  };
  Map<String, dynamic> profile = {};
  Map<String, dynamic> todayNutrition = {
    'total_calories': 0.0,
    'total_protein': 0.0,
  };
  Map<String, dynamic> myRank = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id') ?? 0;
    userName = prefs.getString('user_name') ?? 'Athlete';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final s = await ApiService.getStats(userId);
    final p = await ApiService.getProfile(userId);
    final n = await ApiService.getMealLogs(userId, today);
    final r = await ApiService.getUserRank(userId);
    setState(() {
      stats = s;
      profile = p;
      todayNutrition = {
        'total_calories': (n['total_calories'] ?? 0.0).toDouble(),
        'total_protein': (n['total_protein'] ?? 0.0).toDouble(),
      };
      myRank = r;
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  double? _getDailyCalories() {
    final age = double.tryParse(profile['age']?.toString() ?? '');
    final weight = double.tryParse(profile['weight']?.toString() ?? '');
    final height = double.tryParse(profile['height']?.toString() ?? '');
    final gender = profile['gender']?.toString() ?? '';
    final activity = profile['activity_level']?.toString() ?? 'moderate';
    if (age == null || weight == null || height == null || gender.isEmpty) {
      return null;
    }
    double bmr;
    if (gender == 'Male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    final multipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    return bmr * (multipliers[activity] ?? 1.55);
  }

  double? _getDailyProtein() {
    final weight = double.tryParse(profile['weight']?.toString() ?? '');
    if (weight == null) return null;
    return weight * 2.2;
  }

  Color _titleColor(String title) {
    if (title.contains('Legend')) return const Color(0xFFFFD700);
    if (title.contains('Elite')) return const Color(0xFF00BCD4);
    if (title.contains('Veteran')) return const Color(0xFFE53935);
    if (title.contains('Warrior')) return const Color(0xFFFF6D00);
    if (title.contains('Athlete')) return const Color(0xFF9C27B0);
    if (title.contains('Runner')) return const Color(0xFF43A047);
    if (title.contains('Rookie')) return const Color(0xFF1E88E5);
    return Colors.grey;
  }

  Widget _progressCard({
    required String label,
    required double current,
    required double target,
    required IconData icon,
    required Color color,
    required String unit,
  }) {
    final progress = (current / target).clamp(0.0, 1.0);
    final isComplete = current >= target;
    final remaining = (target - current).clamp(0.0, double.infinity);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isComplete ? Colors.green : color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isComplete ? Colors.green : color, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: isComplete ? Colors.green : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Spacer(),
              if (isComplete)
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withOpacity(0.2),
              color: isComplete ? Colors.green : color,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                isComplete
                    ? 'Goal reached! 🎉'
                    : '${remaining.toStringAsFixed(0)} $unit left',
                style: TextStyle(
                    color: isComplete ? Colors.green : Colors.grey,
                    fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyCalories = _getDailyCalories();
    final dailyProtein = _getDailyProtein();
    final caloriesEaten =
        (todayNutrition['total_calories'] as double?) ?? 0.0;
    final proteinEaten =
        (todayNutrition['total_protein'] as double?) ?? 0.0;
    final rankTitle = myRank['rank_title']?.toString() ?? '🐣 Beginner';
    final totalPoints = myRank['total_points']?.toString() ?? '0';
    final rankPosition = myRank['rank_position']?.toString() ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hey, $userName 👋',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Ready to crush it?',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout, color: Colors.grey),
              onPressed: _logout),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rank card
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  LeaderboardScreen(userId: userId))),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE53935).withOpacity(0.8),
                              const Color(0xFFE53935).withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Your Rank',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(rankTitle,
                                    style: TextStyle(
                                        color: _titleColor(rankTitle),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$totalPoints pts',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text('Global #$rankPosition',
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.white70, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Daily Targets
                    if (dailyCalories != null) ...[
                      const Text('Today\'s Goals',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _progressCard(
                        label: 'Calorie Intake',
                        current: caloriesEaten,
                        target: dailyCalories,
                        icon: Icons.local_fire_department,
                        color: const Color(0xFFE53935),
                        unit: 'kcal',
                      ),
                      const SizedBox(height: 12),
                      _progressCard(
                        label: 'Protein Intake',
                        current: proteinEaten,
                        target: dailyProtein!,
                        icon: Icons.fitness_center,
                        color: const Color(0xFF1E88E5),
                        unit: 'g',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _miniCard(
                            label: 'Cal Target',
                            value: '${dailyCalories.toStringAsFixed(0)} kcal',
                            color: const Color(0xFFE53935),
                          ),
                          const SizedBox(width: 8),
                          _miniCard(
                            label: 'Protein Target',
                            value: '${dailyProtein.toStringAsFixed(0)}g',
                            color: const Color(0xFF1E88E5),
                          ),
                          const SizedBox(width: 8),
                          _miniCard(
                            label: 'Eaten Today',
                            value: '${caloriesEaten.toStringAsFixed(0)} kcal',
                            color: const Color(0xFF43A047),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFE53935).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Color(0xFFE53935)),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Set up your profile to see daily calorie & protein goals!',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ProfileScreen(userId: userId)));
                                _loadData();
                              },
                              child: const Text('Setup',
                                  style:
                                      TextStyle(color: Color(0xFFE53935))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Stats
                    const Text('Your Stats',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _statCard(
                          icon: Icons.fitness_center,
                          label: 'Workouts',
                          value: '${stats['total_workouts']}',
                          color: const Color(0xFFE53935),
                        ),
                        const SizedBox(width: 12),
                        _statCard(
                          icon: Icons.local_fire_department,
                          label: 'Cal Burned',
                          value: '${stats['total_calories']}',
                          color: const Color(0xFFFF6D00),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _statCard(
                          icon: Icons.timer,
                          label: 'Minutes',
                          value: '${stats['total_duration']}',
                          color: const Color(0xFF1E88E5),
                        ),
                        const SizedBox(width: 12),
                        _statCard(
                          icon: Icons.restaurant,
                          label: 'Meals Today',
                          value:
                              '${caloriesEaten.toStringAsFixed(0)} kcal',
                          color: const Color(0xFFFF6D00),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Quick Actions
                    const Text('Quick Actions',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _actionCard(
                      icon: Icons.add_circle,
                      title: 'Log Workout',
                      subtitle: 'Record a new workout session',
                      color: const Color(0xFFE53935),
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AddWorkoutScreen(userId: userId)));
                        _loadData();
                      },
                    ),
                    const SizedBox(height: 12),
                    _actionCard(
                      icon: Icons.list_alt,
                      title: 'My Workouts',
                      subtitle: 'View and manage all workouts',
                      color: const Color(0xFF1E88E5),
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    WorkoutListScreen(userId: userId)));
                        _loadData();
                      },
                    ),
                    const SizedBox(height: 12),
                    _actionCard(
                      icon: Icons.restaurant,
                      title: 'Nutrition',
                      subtitle: 'Log meals & track calories',
                      color: const Color(0xFFFF6D00),
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    NutritionScreen(userId: userId)));
                        _loadData();
                      },
                    ),
                    const SizedBox(height: 12),
                    _actionCard(
                      icon: Icons.leaderboard,
                      title: 'Leaderboard',
                      subtitle: 'See how you rank globally',
                      color: const Color(0xFFFFD700),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  LeaderboardScreen(userId: userId))),
                    ),
                    const SizedBox(height: 12),
                    _actionCard(
                      icon: Icons.bar_chart,
                      title: 'Statistics',
                      subtitle: 'View your progress charts',
                      color: const Color(0xFF43A047),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  StatsScreen(userId: userId))),
                    ),
                    const SizedBox(height: 12),
                    _actionCard(
                      icon: Icons.person,
                      title: 'My Profile',
                      subtitle: 'Set goals & calculate calories',
                      color: const Color(0xFF9C27B0),
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ProfileScreen(userId: userId)));
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _miniCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}