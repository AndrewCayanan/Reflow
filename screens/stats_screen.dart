import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class StatsScreen extends StatefulWidget {
  final int userId;
  const StatsScreen({super.key, required this.userId});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic> stats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final s = await ApiService.getStats(widget.userId);
    setState(() {
      stats = s;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekly = stats['weekly'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  const Text('Overview',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _summaryCard('Total\nWorkouts',
                          '${stats['total_workouts']}',
                          Icons.fitness_center, const Color(0xFFE53935)),
                      const SizedBox(width: 12),
                      _summaryCard('Total\nCalories',
                          '${stats['total_calories']}',
                          Icons.local_fire_department,
                          const Color(0xFFFF6D00)),
                      const SizedBox(width: 12),
                      _summaryCard('Total\nMinutes',
                          '${stats['total_duration']}',
                          Icons.timer, const Color(0xFF1E88E5)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Weekly Chart
                  const Text('Weekly Calories Burned',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    height: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: weekly.isEmpty
                        ? const Center(
                            child: Text(
                              'No data for this week yet.\nAdd some workouts!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: weekly
                                      .map((e) => double.parse(
                                          e['calories'].toString()))
                                      .reduce((a, b) => a > b ? a : b) *
                                  1.3,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) => Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 10),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() < weekly.length) {
                                        final date = weekly[value.toInt()]
                                            ['workout_date'] as String;
                                        return Text(
                                          date.substring(5),
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey.withOpacity(0.1),
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: weekly
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => BarChartGroupData(
                                      x: e.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: double.parse(
                                              e.value['calories'].toString()),
                                          color: const Color(0xFFE53935),
                                          width: 20,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),
                  // Weekly Workout Count
                  const Text('Weekly Workout Count',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: weekly.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No data yet',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        : Column(
                            children: weekly.map((w) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Text(w['workout_date'],
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13)),
                                    const Spacer(),
                                    Text('${w['count']} workout(s)',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 12),
                                    Text('${w['calories']} cal',
                                        style: const TextStyle(
                                            color: Color(0xFFE53935),
                                            fontSize: 13)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}