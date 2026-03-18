import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_workout_screen.dart';

class WorkoutListScreen extends StatefulWidget {
  final int userId;
  const WorkoutListScreen({super.key, required this.userId});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  List<dynamic> workouts = [];
  List<dynamic> filtered = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    setState(() => isLoading = true);
    workouts = await ApiService.getWorkouts(widget.userId);
    filtered = workouts;
    setState(() => isLoading = false);
  }

  void search(String query) {
    setState(() {
      searchQuery = query;
      filtered = workouts
          .where((w) =>
              w['title'].toLowerCase().contains(query.toLowerCase()) ||
              w['exercise_type'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Delete Workout',
            style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure?',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ApiService.deleteWorkout(id);
              Navigator.pop(context);
              loadWorkouts();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'cardio': return const Color(0xFF1E88E5);
      case 'strength': return const Color(0xFFE53935);
      case 'flexibility': return const Color(0xFF43A047);
      case 'hiit': return const Color(0xFFFF6D00);
      default: return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search workouts...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFE53935)))
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fitness_center,
                                color: Colors.grey, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No workouts yet!\nTap + to add one.'
                                  : 'No results found.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadWorkouts,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final w = filtered[i];
                            final color = _typeColor(w['exercise_type']);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: color.withOpacity(0.3)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.fitness_center,
                                      color: color),
                                ),
                                title: Text(w['title'],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(w['exercise_type'],
                                          style: TextStyle(
                                              color: color, fontSize: 11)),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(children: [
                                      const Icon(Icons.timer,
                                          color: Colors.grey, size: 14),
                                      const SizedBox(width: 4),
                                      Text('${w['duration_minutes']} min',
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12)),
                                      const SizedBox(width: 12),
                                      const Icon(
                                          Icons.local_fire_department,
                                          color: Colors.grey,
                                          size: 14),
                                      const SizedBox(width: 4),
                                      Text('${w['calories_burned']} cal',
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12)),
                                    ]),
                                    const SizedBox(height: 4),
                                    Text(w['workout_date'],
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Color(0xFF1E88E5)),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddWorkoutScreen(
                                              userId: widget.userId,
                                              workout: w,
                                            ),
                                          ),
                                        );
                                        loadWorkouts();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => confirmDelete(
                                          int.parse(w['id'].toString())),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE53935),
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AddWorkoutScreen(userId: widget.userId)));
          loadWorkouts();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}