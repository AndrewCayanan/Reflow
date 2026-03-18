import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final int userId;
  const LeaderboardScreen({super.key, required this.userId});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> leaderboard = [];
  Map<String, dynamic> myRank = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final lb = await ApiService.getLeaderboard();
    final rank = await ApiService.getUserRank(widget.userId);
    setState(() {
      leaderboard = lb;
      myRank = rank;
      isLoading = false;
    });
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return Colors.grey;
    }
  }

  String _rankEmoji(int rank) {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '#$rank';
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : RefreshIndicator(
              onRefresh: loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // My rank card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFE53935).withOpacity(0.8),
                            const Color(0xFFE53935).withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFE53935).withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          const Text('Your Ranking',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 8),
                          Text(
                            myRank['rank_title'] ?? '🐣 Beginner',
                            style: TextStyle(
                                color: _titleColor(
                                    myRank['rank_title'] ?? ''),
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                            children: [
                              _myStatItem(
                                '${myRank['rank_position'] ?? '-'}',
                                'Global Rank',
                                Icons.leaderboard,
                              ),
                              _myStatItem(
                                '${myRank['total_points'] ?? 0}',
                                'Total Points',
                                Icons.star,
                              ),
                              _myStatItem(
                                '${myRank['streak_days'] ?? 0}',
                                'Day Streak',
                                Icons.local_fire_department,
                              ),
                              _myStatItem(
                                '${myRank['total_workouts'] ?? 0}',
                                'Workouts',
                                Icons.fitness_center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Progress to next rank
                          _nextRankProgress(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Points guide
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('How Points Work',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          const SizedBox(height: 12),
                          _pointsGuideRow(
                              '🏋️ Log a workout', '+10 pts'),
                          _pointsGuideRow(
                              '🔥 Per 10 calories burned', '+1 pt'),
                          _pointsGuideRow(
                              '⏱️ Per 5 minutes worked out', '+1 pt'),
                          _pointsGuideRow(
                              '📅 7-day streak bonus', '+50 pts'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Rank titles guide
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rank Titles',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          const SizedBox(height: 12),
                          _rankTitleRow('🐣 Beginner', '0 pts', Colors.grey),
                          _rankTitleRow('🌱 Rookie', '50 pts', const Color(0xFF1E88E5)),
                          _rankTitleRow('🏃 Runner', '100 pts', const Color(0xFF43A047)),
                          _rankTitleRow('💪 Athlete', '200 pts', const Color(0xFF9C27B0)),
                          _rankTitleRow('⚡ Warrior', '500 pts', const Color(0xFFFF6D00)),
                          _rankTitleRow('🔥 Veteran', '1000 pts', const Color(0xFFE53935)),
                          _rankTitleRow('💎 Elite', '2000 pts', const Color(0xFF00BCD4)),
                          _rankTitleRow('👑 Legend', '5000 pts', const Color(0xFFFFD700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Top 3 podium
                    if (leaderboard.length >= 3) ...[
                      const Text('Top 3',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 2nd place
                          Expanded(
                            child: _podiumCard(leaderboard[1], 2),
                          ),
                          const SizedBox(width: 8),
                          // 1st place
                          Expanded(
                            flex: 2,
                            child: _podiumCard(leaderboard[0], 1),
                          ),
                          const SizedBox(width: 8),
                          // 3rd place
                          Expanded(
                            child: _podiumCard(leaderboard[2], 3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Full leaderboard
                    const Text('All Rankings',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...leaderboard.asMap().entries.map((entry) {
                      final i = entry.key;
                      final user = entry.value;
                      final rank = i + 1;
                      final isMe = int.parse(
                              user['id'].toString()) ==
                          widget.userId;
                      final rankColor = _rankColor(rank);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFFE53935).withOpacity(0.15)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isMe
                                ? const Color(0xFFE53935).withOpacity(0.5)
                                : rank <= 3
                                    ? rankColor.withOpacity(0.3)
                                    : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Rank
                            SizedBox(
                              width: 40,
                              child: Text(
                                _rankEmoji(rank),
                                style: TextStyle(
                                    fontSize: rank <= 3 ? 24 : 16,
                                    color: rankColor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Avatar
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFFE53935)
                                        .withOpacity(0.3)
                                    : rankColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: isMe
                                        ? const Color(0xFFE53935)
                                        : rankColor.withOpacity(0.5)),
                              ),
                              child: Center(
                                child: Text(
                                  user['name']
                                      .toString()
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: TextStyle(
                                      color: isMe
                                          ? const Color(0xFFE53935)
                                          : rankColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Name and rank title
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        user['name'] +
                                            (isMe ? ' (You)' : ''),
                                        style: TextStyle(
                                            color: isMe
                                                ? const Color(0xFFE53935)
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user['rank_title'] ?? '🐣 Beginner',
                                    style: TextStyle(
                                        color: _titleColor(
                                            user['rank_title'] ?? ''),
                                        fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.fitness_center,
                                          color: Colors.grey, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                          '${user['total_workouts']} workouts',
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11)),
                                      const SizedBox(width: 8),
                                      const Icon(
                                          Icons.local_fire_department,
                                          color: Colors.grey,
                                          size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                          '${user['total_calories']} cal',
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Points
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${user['total_points']}',
                                  style: TextStyle(
                                      color: isMe
                                          ? const Color(0xFFE53935)
                                          : rankColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text('pts',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _nextRankProgress() {
    final points = int.parse(myRank['total_points']?.toString() ?? '0');
    final ranks = [
      {'title': '🌱 Rookie', 'min': 50},
      {'title': '🏃 Runner', 'min': 100},
      {'title': '💪 Athlete', 'min': 200},
      {'title': '⚡ Warrior', 'min': 500},
      {'title': '🔥 Veteran', 'min': 1000},
      {'title': '💎 Elite', 'min': 2000},
      {'title': '👑 Legend', 'min': 5000},
    ];

    Map<String, dynamic>? nextRank;
    int currentMin = 0;
    for (final rank in ranks) {
      if (points < (rank['min'] as int)) {
        nextRank = rank;
        break;
      }
      currentMin = rank['min'] as int;
    }

    if (nextRank == null) {
      return const Text('👑 Maximum rank achieved!',
          style: TextStyle(
              color: Color(0xFFFFD700), fontWeight: FontWeight.bold));
    }

    final nextMin = nextRank['min'] as int;
    final progress =
        ((points - currentMin) / (nextMin - currentMin)).clamp(0.0, 1.0);
    final remaining = nextMin - points;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Next: ${nextRank['title']}',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('$remaining pts to go',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            color: Colors.white,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _podiumCard(dynamic user, int rank) {
    final rankColor = _rankColor(rank);
    final heights = {1: 120.0, 2: 90.0, 3: 70.0};
    final isMe =
        int.parse(user['id'].toString()) == widget.userId;

    return Column(
      children: [
        Text(_rankEmoji(rank), style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: rankColor, width: 2),
          ),
          child: Center(
            child: Text(
              user['name'].toString().substring(0, 1).toUpperCase(),
              style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user['name'] + (isMe ? '\n(You)' : ''),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: isMe ? const Color(0xFFE53935) : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${user['total_points']} pts',
          style: TextStyle(
              color: rankColor,
              fontSize: 13,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: heights[rank],
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: rankColor.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(
              rank == 1 ? '1st' : rank == 2 ? '2nd' : '3rd',
              style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _myStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Text(label,
            style:
                const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _pointsGuideRow(String action, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(action,
              style:
                  const TextStyle(color: Colors.grey, fontSize: 13)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(points,
                style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _rankTitleRow(String title, String pts, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const Spacer(),
          Text(pts,
              style:
                  const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}