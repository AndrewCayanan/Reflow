import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ageCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final heightCtrl = TextEditingController();
  String selectedGender = 'Male';
  String selectedActivity = 'moderate';
  bool isLoading = true;
  bool isSaving = false;

  // Results
  double? dailyCalories;
  double? dailyProtein;

  final List<Map<String, String>> activityLevels = [
    {'value': 'sedentary', 'label': 'Sedentary (no exercise)'},
    {'value': 'light', 'label': 'Light (1-3 days/week)'},
    {'value': 'moderate', 'label': 'Moderate (3-5 days/week)'},
    {'value': 'active', 'label': 'Active (6-7 days/week)'},
    {'value': 'very_active', 'label': 'Very Active (twice/day)'},
  ];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final profile = await ApiService.getProfile(widget.userId);
    setState(() {
      ageCtrl.text = profile['age']?.toString() ?? '';
      weightCtrl.text = profile['weight']?.toString() ?? '';
      heightCtrl.text = profile['height']?.toString() ?? '';
      selectedGender = profile['gender'] ?? 'Male';
      selectedActivity = profile['activity_level'] ?? 'moderate';
      isLoading = false;
    });
    _calculate();
  }

  void _calculate() {
    final age = double.tryParse(ageCtrl.text);
    final weight = double.tryParse(weightCtrl.text);
    final height = double.tryParse(heightCtrl.text);

    if (age == null || weight == null || height == null) return;

    // Mifflin-St Jeor BMR formula
    double bmr;
    if (selectedGender == 'Male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Activity multiplier
    final multipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };

    final tdee = bmr * (multipliers[selectedActivity] ?? 1.55);
    final protein = weight * 2.2; // 1g per pound of bodyweight

    setState(() {
      dailyCalories = tdee;
      dailyProtein = protein;
    });
  }

  Future<void> saveProfile() async {
    if (ageCtrl.text.isEmpty ||
        weightCtrl.text.isEmpty ||
        heightCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red));
      return;
    }
    setState(() => isSaving = true);
    await ApiService.updateProfile({
      'user_id': widget.userId,
      'age': int.parse(ageCtrl.text),
      'gender': selectedGender,
      'weight': double.parse(weightCtrl.text),
      'height': double.parse(heightCtrl.text),
      'activity_level': selectedActivity,
    });
    setState(() => isSaving = false);
    _calculate();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profile saved!'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile',
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
                  // Results Cards
                  if (dailyCalories != null) ...[
                    const Text('Your Daily Targets',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _resultCard(
                          icon: Icons.local_fire_department,
                          label: 'Daily Calories',
                          value: '${dailyCalories!.toStringAsFixed(0)} kcal',
                          color: const Color(0xFFE53935),
                        ),
                        const SizedBox(width: 12),
                        _resultCard(
                          icon: Icons.fitness_center,
                          label: 'Daily Protein',
                          value: '${dailyProtein!.toStringAsFixed(0)}g',
                          color: const Color(0xFF1E88E5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Form
                  const Text('Body Measurements',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Gender
                  _label('Gender'),
                  Row(
                    children: ['Male', 'Female'].map((g) {
                      final isSelected = selectedGender == g;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => selectedGender = g),
                          child: Container(
                            margin: EdgeInsets.only(
                                right: g == 'Male' ? 8 : 0),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE53935)
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(g,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Age
                  _label('Age'),
                  TextField(
                    controller: ageCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 21',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.cake, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weight & Height
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Weight (kg)'),
                            TextField(
                              controller: weightCtrl,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'e.g. 70',
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(Icons.monitor_weight,
                                    color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Height (cm)'),
                            TextField(
                              controller: heightCtrl,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'e.g. 175',
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(Icons.height,
                                    color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Activity Level
                  _label('Activity Level'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedActivity,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1A1A1A),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) =>
                            setState(() => selectedActivity = val!),
                        items: activityLevels.map((a) {
                          return DropdownMenuItem(
                            value: a['value'],
                            child: Text(a['label']!),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : saveProfile,
                      child: isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text('Save & Calculate',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _resultCard({
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
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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