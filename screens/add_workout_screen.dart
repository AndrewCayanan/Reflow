import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AddWorkoutScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic>? workout;
  const AddWorkoutScreen({super.key, required this.userId, this.workout});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final titleCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
  final caloriesCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final setsCtrl = TextEditingController();
  final repsCtrl = TextEditingController();
  final weightLiftedCtrl = TextEditingController();
  final distanceCtrl = TextEditingController();
  final inclineCtrl = TextEditingController();
  final heartRateCtrl = TextEditingController();

  String selectedType = 'Strength';
  String selectedIntensity = 'moderate';
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  bool isSaving = false;
  bool autoCalculate = true;
  double userWeight = 70.0;

  bool get isEditing => widget.workout != null;

  final List<String> exerciseTypes = [
    'Strength', 'Cardio', 'HIIT', 'Flexibility', 'Sports', 'Other'
  ];

  final List<Map<String, dynamic>> intensityLevels = [
    {'value': 'light', 'label': 'Light', 'description': 'Easy, minimal effort'},
    {'value': 'moderate', 'label': 'Moderate', 'description': 'Comfortable pace'},
    {'value': 'vigorous', 'label': 'Vigorous', 'description': 'Hard, sweating'},
    {'value': 'very_vigorous', 'label': 'Very Vigorous', 'description': 'Max effort'},
  ];

  // MET values for calorie calculation
  final Map<String, Map<String, double>> metValues = {
    'Strength': {
      'light': 3.0,
      'moderate': 5.0,
      'vigorous': 6.0,
      'very_vigorous': 8.0,
    },
    'Cardio': {
      'light': 4.0,
      'moderate': 7.0,
      'vigorous': 10.0,
      'very_vigorous': 13.0,
    },
    'HIIT': {
      'light': 6.0,
      'moderate': 8.5,
      'vigorous': 12.0,
      'very_vigorous': 14.5,
    },
    'Flexibility': {
      'light': 2.0,
      'moderate': 2.5,
      'vigorous': 3.0,
      'very_vigorous': 3.5,
    },
    'Sports': {
      'light': 4.0,
      'moderate': 6.0,
      'vigorous': 9.0,
      'very_vigorous': 12.0,
    },
    'Other': {
      'light': 3.5,
      'moderate': 5.0,
      'vigorous': 7.0,
      'very_vigorous': 9.0,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
    if (isEditing) {
      titleCtrl.text = widget.workout!['title'];
      selectedType = widget.workout!['exercise_type'];
      durationCtrl.text = widget.workout!['duration_minutes'].toString();
      caloriesCtrl.text = widget.workout!['calories_burned'].toString();
      notesCtrl.text = widget.workout!['notes'] ?? '';
      selectedDate = DateTime.parse(widget.workout!['workout_date']);
      autoCalculate = false;
    }
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getProfile(widget.userId);
    setState(() {
      userWeight =
          double.tryParse(profile['weight']?.toString() ?? '') ?? 70.0;
      isLoading = false;
    });
    if (autoCalculate) _calculateCalories();
  }

  void _calculateCalories() {
    if (!autoCalculate) return;
    final duration = double.tryParse(durationCtrl.text) ?? 0;
    if (duration <= 0) return;

    final met =
        metValues[selectedType]?[selectedIntensity] ?? 5.0;
    double calories = met * userWeight * (duration / 60);

    // Bonus calories for distance (cardio)
    final distance = double.tryParse(distanceCtrl.text) ?? 0;
    if (distance > 0 &&
        (selectedType == 'Cardio' || selectedType == 'Sports')) {
      // Additional calories from distance: ~1 kcal per kg per km
      calories += userWeight * distance * 0.9;
    }

    // Bonus for incline
    final incline = double.tryParse(inclineCtrl.text) ?? 0;
    if (incline > 0) {
      calories *= (1 + incline * 0.03);
    }

    // Heart rate adjustment
    final hr = double.tryParse(heartRateCtrl.text) ?? 0;
    if (hr > 0) {
      final hrMultiplier = (hr / 150).clamp(0.7, 1.5);
      calories *= hrMultiplier;
    }

    setState(() {
      caloriesCtrl.text = calories.toStringAsFixed(0);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE53935),
            surface: Color(0xFF1A1A1A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> save() async {
    if (titleCtrl.text.isEmpty || durationCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill in required fields'),
          backgroundColor: Colors.red));
      return;
    }
    setState(() => isSaving = true);

    final data = {
      'user_id': widget.userId,
      'title': titleCtrl.text,
      'exercise_type': selectedType,
      'duration_minutes': int.tryParse(durationCtrl.text) ?? 0,
      'calories_burned': int.tryParse(caloriesCtrl.text) ?? 0,
      'notes': _buildNotes(),
      'workout_date': DateFormat('yyyy-MM-dd').format(selectedDate),
    };

    if (isEditing) {
      data['id'] = int.parse(widget.workout!['id'].toString());
      await ApiService.updateWorkout(data);
    } else {
      await ApiService.addWorkout(data);
    }

    setState(() => isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  String _buildNotes() {
    final parts = <String>[];
    if (notesCtrl.text.isNotEmpty) parts.add(notesCtrl.text);
    if (setsCtrl.text.isNotEmpty && repsCtrl.text.isNotEmpty) {
      parts.add('Sets: ${setsCtrl.text} | Reps: ${repsCtrl.text}');
    }
    if (weightLiftedCtrl.text.isNotEmpty) {
      parts.add('Weight lifted: ${weightLiftedCtrl.text}kg');
    }
    if (distanceCtrl.text.isNotEmpty) {
      parts.add('Distance: ${distanceCtrl.text}km');
    }
    if (inclineCtrl.text.isNotEmpty) {
      parts.add('Incline: ${inclineCtrl.text}%');
    }
    if (heartRateCtrl.text.isNotEmpty) {
      parts.add('Avg HR: ${heartRateCtrl.text}bpm');
    }
    return parts.join(' | ');
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'cardio': return const Color(0xFF1E88E5);
      case 'strength': return const Color(0xFFE53935);
      case 'flexibility': return const Color(0xFF43A047);
      case 'hiit': return const Color(0xFFFF6D00);
      case 'sports': return const Color(0xFF9C27B0);
      default: return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(selectedType);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Workout' : 'Log Workout',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User weight info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFE53935).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monitor_weight,
                            color: Color(0xFFE53935), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Calculating for ${userWeight.toStringAsFixed(1)}kg body weight',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                        const Spacer(),
                        Switch(
                          value: autoCalculate,
                          activeColor: const Color(0xFFE53935),
                          onChanged: (val) {
                            setState(() => autoCalculate = val);
                            if (val) _calculateCalories();
                          },
                        ),
                        const Text('Auto',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  _label('Workout Title *'),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Morning Run, Chest Day...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Exercise Type
                  _label('Exercise Type'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: exerciseTypes.map((type) {
                      final isSelected = selectedType == type;
                      final color = _typeColor(type);
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedType = type);
                          _calculateCalories();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color
                                : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Text(type,
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Intensity
                  _label('Intensity'),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: intensityLevels.map((level) {
                        final isSelected =
                            selectedIntensity == level['value'];
                        return GestureDetector(
                          onTap: () {
                            setState(() =>
                                selectedIntensity = level['value']);
                            _calculateCalories();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? typeColor.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: typeColor.withOpacity(0.5))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: isSelected
                                      ? typeColor
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(level['label'],
                                        style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey,
                                            fontWeight:
                                                FontWeight.bold)),
                                    Text(level['description'],
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11)),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  'MET ${metValues[selectedType]?[level['value']]}',
                                  style: TextStyle(
                                      color: isSelected
                                          ? typeColor
                                          : Colors.grey,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Duration
                  _label('Duration (mins) *'),
                  TextField(
                    controller: durationCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateCalories(),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.timer, color: Colors.grey),
                      hintText: 'e.g. 45',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cardio specific fields
                  if (selectedType == 'Cardio' ||
                      selectedType == 'Sports') ...[
                    _label('Distance (km) — optional'),
                    TextField(
                      controller: distanceCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateCalories(),
                      decoration: const InputDecoration(
                        prefixIcon:
                            Icon(Icons.map, color: Colors.grey),
                        hintText: 'e.g. 5.5',
                        hintStyle: TextStyle(color: Colors.grey),
                        suffixText: 'km',
                        suffixStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _label('Incline (%) — optional'),
                    TextField(
                      controller: inclineCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateCalories(),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.trending_up,
                            color: Colors.grey),
                        hintText: 'e.g. 5',
                        hintStyle: TextStyle(color: Colors.grey),
                        suffixText: '%',
                        suffixStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Strength specific fields
                  if (selectedType == 'Strength') ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _label('Sets'),
                              TextField(
                                controller: setsCtrl,
                                style:
                                    const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. 4',
                                  hintStyle:
                                      TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _label('Reps'),
                              TextField(
                                controller: repsCtrl,
                                style:
                                    const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. 12',
                                  hintStyle:
                                      TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _label('Weight (kg)'),
                              TextField(
                                controller: weightLiftedCtrl,
                                style:
                                    const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. 80',
                                  hintStyle:
                                      TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Heart Rate
                  _label('Avg Heart Rate (bpm) — optional'),
                  TextField(
                    controller: heartRateCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateCalories(),
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.favorite, color: Colors.red),
                      hintText: 'e.g. 145',
                      hintStyle: TextStyle(color: Colors.grey),
                      suffixText: 'bpm',
                      suffixStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Calories
                  _label('Calories Burned'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: typeColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            color: typeColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: caloriesCtrl,
                            style: TextStyle(
                                color: typeColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              hintStyle: TextStyle(
                                  color: typeColor.withOpacity(0.5),
                                  fontSize: 24),
                              suffixText: 'kcal',
                              suffixStyle: TextStyle(
                                  color: typeColor, fontSize: 14),
                            ),
                          ),
                        ),
                        if (autoCalculate)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Auto',
                                style: TextStyle(
                                    color: typeColor, fontSize: 11)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (autoCalculate)
                    Text(
                      'Based on MET formula: ${metValues[selectedType]?[selectedIntensity]} MET × ${userWeight.toStringAsFixed(1)}kg × duration',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11),
                    ),
                  const SizedBox(height: 20),

                  // Date
                  _label('Date'),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.grey, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('MMMM dd, yyyy')
                                .format(selectedDate),
                            style:
                                const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notes
                  _label('Notes (optional)'),
                  TextField(
                    controller: notesCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'How did it go?',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Summary card before saving
                  if (durationCtrl.text.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: typeColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Workout Summary',
                              style: TextStyle(
                                  color: typeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 12),
                          _summaryRow(Icons.fitness_center,
                              selectedType, typeColor),
                          _summaryRow(Icons.timer,
                              '${durationCtrl.text} minutes', Colors.grey),
                          _summaryRow(
                              Icons.local_fire_department,
                              '${caloriesCtrl.text} kcal burned',
                              const Color(0xFFE53935)),
                          if (distanceCtrl.text.isNotEmpty)
                            _summaryRow(Icons.map,
                                '${distanceCtrl.text} km', Colors.grey),
                          if (setsCtrl.text.isNotEmpty)
                            _summaryRow(
                                Icons.repeat,
                                '${setsCtrl.text} sets × ${repsCtrl.text} reps',
                                Colors.grey),
                          if (weightLiftedCtrl.text.isNotEmpty)
                            _summaryRow(
                                Icons.fitness_center,
                                '${weightLiftedCtrl.text}kg lifted',
                                Colors.grey),
                          if (heartRateCtrl.text.isNotEmpty)
                            _summaryRow(Icons.favorite,
                                '${heartRateCtrl.text} bpm avg', Colors.red),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : save,
                      child: isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : Text(
                              isEditing
                                  ? 'Update Workout'
                                  : 'Save Workout',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _summaryRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
    );
  }
}