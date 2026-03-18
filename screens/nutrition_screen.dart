import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class NutritionScreen extends StatefulWidget {
  final int userId;
  const NutritionScreen({super.key, required this.userId});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedDate = DateTime.now();
  List<dynamic> mealLogs = [];
  List<dynamic> foods = [];
  List<dynamic> filteredFoods = [];
  double totalCalories = 0;
  double totalProtein = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final mealData = await ApiService.getMealLogs(widget.userId, dateStr);
    final foodData = await ApiService.getFoods();
    setState(() {
      mealLogs = mealData['logs'] ?? [];
      totalCalories = (mealData['total_calories'] ?? 0).toDouble();
      totalProtein = (mealData['total_protein'] ?? 0).toDouble();
      foods = foodData;
      filteredFoods = foodData;
      isLoading = false;
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
    if (picked != null) {
      setState(() => selectedDate = picked);
      loadData();
    }
  }

  void _showAddMealDialog() {
    final mealNameCtrl = TextEditingController();
    final caloriesCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final gramsCtrl = TextEditingController();
    final searchCtrl = TextEditingController();
    String selectedMealType = 'breakfast';
    dynamic selectedFood;
    bool saveToDatabase = false;
    bool usePer100g = false;
    List<dynamic> searchResults = List.from(foods);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Log a Meal',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Search foods
                const Text('Search Global Food Database',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search foods...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                  ),
                  onChanged: (val) {
                    setModalState(() {
                      searchResults = foods
                          .where((f) => f['name']
                              .toString()
                              .toLowerCase()
                              .contains(val.toLowerCase()))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 8),

                // Food search results
                if (searchResults.isNotEmpty)
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (_, i) {
                        final f = searchResults[i];
                        final isSelected = selectedFood != null &&
                            selectedFood['id'] == f['id'];
                        return ListTile(
                          tileColor: isSelected
                              ? const Color(0xFFE53935).withOpacity(0.2)
                              : Colors.transparent,
                          title: Text(f['name'],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14)),
                          subtitle: Text(
                            '${f['calories_per_serving']} kcal | ${f['protein_per_serving']}g protein per serving'
                            '${f['calories_per_100g'] != null ? ' | ${f['calories_per_100g']} kcal/100g' : ''}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11),
                          ),
                          trailing: f['added_by_name'] != null
                              ? Text('by ${f['added_by_name']}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 10))
                              : null,
                          onTap: () {
                            setModalState(() {
                              selectedFood = f;
                              mealNameCtrl.text = f['name'];
                              if (!usePer100g) {
                                caloriesCtrl.text =
                                    f['calories_per_serving'].toString();
                                proteinCtrl.text =
                                    f['protein_per_serving'].toString();
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),

                // Per 100g toggle (only if food has 100g data)
                if (selectedFood != null &&
                    selectedFood['calories_per_100g'] != null) ...[
                  Row(
                    children: [
                      const Text('Use per 100g calculation',
                          style:
                              TextStyle(color: Colors.white, fontSize: 14)),
                      const Spacer(),
                      Switch(
                        value: usePer100g,
                        activeColor: const Color(0xFFE53935),
                        onChanged: (val) {
                          setModalState(() {
                            usePer100g = val;
                            if (!val) {
                              caloriesCtrl.text = selectedFood[
                                      'calories_per_serving']
                                  .toString();
                              proteinCtrl.text =
                                  selectedFood['protein_per_serving']
                                      .toString();
                              gramsCtrl.clear();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (usePer100g) ...[
                    const Text('Amount (grams)',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: gramsCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 150',
                        hintStyle: TextStyle(color: Colors.grey),
                        suffixText: 'g',
                        suffixStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Color(0xFF2A2A2A),
                      ),
                      onChanged: (val) {
                        final grams = double.tryParse(val);
                        if (grams != null && selectedFood != null) {
                          final cal = (double.parse(selectedFood[
                                          'calories_per_100g']
                                      .toString()) *
                                  grams /
                                  100)
                              .toStringAsFixed(1);
                          final pro = (double.parse(selectedFood[
                                          'protein_per_100g']
                                      .toString()) *
                                  grams /
                                  100)
                              .toStringAsFixed(1);
                          setModalState(() {
                            caloriesCtrl.text = cal;
                            proteinCtrl.text = pro;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ],

                const Row(children: [
                  Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('or enter manually',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey)),
                ]),
                const SizedBox(height: 16),

                // Meal name
                const Text('Meal Name',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: mealNameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Chicken Rice, Protein Shake...',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                  ),
                ),
                const SizedBox(height: 12),

                // Calories and Protein
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Calories (kcal)',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: caloriesCtrl,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Color(0xFF2A2A2A),
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
                          const Text('Protein (g)',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: proteinCtrl,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Color(0xFF2A2A2A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Meal type
                const Text('Meal Type',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['breakfast', 'lunch', 'dinner', 'snack']
                      .map((type) {
                    final isSelected = selectedMealType == type;
                    return GestureDetector(
                      onTap: () =>
                          setModalState(() => selectedMealType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE53935)
                              : const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          type[0].toUpperCase() + type.substring(1),
                          style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Notes
                const Text('Notes (optional)',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: notesCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Any notes...',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                  ),
                ),
                const SizedBox(height: 12),

                // Save to database option
                if (selectedFood == null)
                  GestureDetector(
                    onTap: () => setModalState(
                        () => saveToDatabase = !saveToDatabase),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: saveToDatabase
                                ? const Color(0xFFE53935)
                                : Colors.transparent,
                            border: Border.all(
                                color: saveToDatabase
                                    ? const Color(0xFFE53935)
                                    : Colors.grey),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: saveToDatabase
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 16)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        const Text('Save to global food database',
                            style: TextStyle(
                                color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (mealNameCtrl.text.isEmpty ||
                          caloriesCtrl.text.isEmpty ||
                          proteinCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill in all fields'),
                                backgroundColor: Colors.red));
                        return;
                      }

                      int? foodId;
                      if (saveToDatabase && selectedFood == null) {
                        final saved = await ApiService.addFood({
                          'added_by': widget.userId,
                          'name': mealNameCtrl.text,
                          'calories_per_serving':
                              double.parse(caloriesCtrl.text),
                          'protein_per_serving':
                              double.parse(proteinCtrl.text),
                        });
                        if (saved['success'] == true) {
                          foodId = saved['id'];
                        }
                      } else if (selectedFood != null) {
                        foodId =
                            int.parse(selectedFood['id'].toString());
                      }

                      await ApiService.addMealLog({
                        'user_id': widget.userId,
                        'food_id': foodId,
                        'meal_name': mealNameCtrl.text,
                        'calories': double.parse(caloriesCtrl.text),
                        'protein': double.parse(proteinCtrl.text),
                        'meal_type': selectedMealType,
                        'log_date': DateFormat('yyyy-MM-dd')
                            .format(selectedDate),
                        'notes': notesCtrl.text,
                      });

                      Navigator.pop(context);
                      loadData();
                    },
                    child: const Text('Log Meal',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showManageFoodsDialog() {
    final nameCtrl = TextEditingController();
    final caloriesCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final cal100Ctrl = TextEditingController();
    final pro100Ctrl = TextEditingController();
    bool addPer100g = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Global Food Database',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const Text(
                    'Foods added here are available to all users',
                    style:
                        TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),

                // Add new food form
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add New Food to Database',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Food name',
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: caloriesCtrl,
                              style:
                                  const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Cal/serving',
                                hintStyle:
                                    TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: proteinCtrl,
                              style:
                                  const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Protein/serving (g)',
                                hintStyle:
                                    TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Per 100g toggle
                      GestureDetector(
                        onTap: () => setModalState(
                            () => addPer100g = !addPer100g),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: addPer100g
                                    ? const Color(0xFFE53935)
                                    : Colors.transparent,
                                border: Border.all(
                                    color: addPer100g
                                        ? const Color(0xFFE53935)
                                        : Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: addPer100g
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 14)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            const Text('Add per 100g data',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13)),
                          ],
                        ),
                      ),

                      if (addPer100g) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: cal100Ctrl,
                                style: const TextStyle(
                                    color: Colors.white),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Cal/100g',
                                  hintStyle:
                                      TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: pro100Ctrl,
                                style: const TextStyle(
                                    color: Colors.white),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Protein/100g (g)',
                                  hintStyle:
                                      TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameCtrl.text.isEmpty ||
                                caloriesCtrl.text.isEmpty ||
                                proteinCtrl.text.isEmpty) return;
                            final result = await ApiService.addFood({
                              'added_by': widget.userId,
                              'name': nameCtrl.text,
                              'calories_per_serving':
                                  double.parse(caloriesCtrl.text),
                              'protein_per_serving':
                                  double.parse(proteinCtrl.text),
                              if (addPer100g &&
                                  cal100Ctrl.text.isNotEmpty)
                                'calories_per_100g':
                                    double.parse(cal100Ctrl.text),
                              if (addPer100g &&
                                  pro100Ctrl.text.isNotEmpty)
                                'protein_per_100g':
                                    double.parse(pro100Ctrl.text),
                            });
                            if (result['success'] == true) {
                              nameCtrl.clear();
                              caloriesCtrl.clear();
                              proteinCtrl.clear();
                              cal100Ctrl.clear();
                              pro100Ctrl.clear();
                              final updated =
                                  await ApiService.getFoods();
                              setModalState(() => foods = updated);
                              setState(() => foods = updated);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      content: Text('Food added!'),
                                      backgroundColor: Colors.green));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      content:
                                          Text(result['message']),
                                      backgroundColor: Colors.red));
                            }
                          },
                          child: const Text('Add to Database'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Food list
                const Text('All Foods',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 8),
                Expanded(
                  child: foods.isEmpty
                      ? const Center(
                          child: Text('No foods in database yet',
                              style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: foods.length,
                          itemBuilder: (_, i) {
                            final f = foods[i];
                            final isOwner = f['added_by'] != null &&
                                int.parse(
                                        f['added_by'].toString()) ==
                                    widget.userId;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(f['name'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.bold)),
                                        Text(
                                          '${f['calories_per_serving']} kcal | ${f['protein_per_serving']}g protein/serving',
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11),
                                        ),
                                        if (f['calories_per_100g'] !=
                                            null)
                                          Text(
                                            '${f['calories_per_100g']} kcal | ${f['protein_per_100g']}g protein/100g',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11),
                                          ),
                                        if (f['added_by_name'] != null)
                                          Text(
                                            'Added by ${f['added_by_name']}',
                                            style: const TextStyle(
                                                color: Color(0xFFE53935),
                                                fontSize: 10),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isOwner)
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        final result =
                                            await ApiService.deleteFood(
                                          int.parse(f['id'].toString()),
                                          widget.userId,
                                        );
                                        if (result['success'] == true) {
                                          final updated =
                                              await ApiService.getFoods();
                                          setModalState(
                                              () => foods = updated);
                                          setState(
                                              () => foods = updated);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      result['message']),
                                                  backgroundColor:
                                                      Colors.red));
                                        }
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _mealTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFF6D00);
      case 'lunch':
        return const Color(0xFF43A047);
      case 'dinner':
        return const Color(0xFF1E88E5);
      case 'snack':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.food_bank, color: Colors.grey),
            onPressed: _showManageFoodsDialog,
            tooltip: 'Manage Foods',
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
                    // Date picker
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
                                color: Color(0xFFE53935), size: 20),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('MMMM dd, yyyy')
                                  .format(selectedDate),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Daily totals
                    const Text('Today\'s Nutrition',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _totalCard(
                            'Calories',
                            '${totalCalories.toStringAsFixed(0)} kcal',
                            Icons.local_fire_department,
                            const Color(0xFFE53935)),
                        const SizedBox(width: 12),
                        _totalCard(
                            'Protein',
                            '${totalProtein.toStringAsFixed(0)}g',
                            Icons.fitness_center,
                            const Color(0xFF1E88E5)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Meal logs
                    const Text('Meal Log',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    mealLogs.isEmpty
                        ? Center(
                            child: Column(
                              children: const [
                                SizedBox(height: 32),
                                Icon(Icons.restaurant,
                                    color: Colors.grey, size: 64),
                                SizedBox(height: 16),
                                Text('No meals logged yet',
                                    style:
                                        TextStyle(color: Colors.grey)),
                                SizedBox(height: 8),
                                Text('Tap + to log a meal',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: mealLogs.length,
                            itemBuilder: (_, i) {
                              final m = mealLogs[i];
                              final color =
                                  _mealTypeColor(m['meal_type']);
                              return Container(
                                margin:
                                    const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  border: Border.all(
                                      color: color.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.restaurant,
                                          color: color),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(m['meal_name'],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 8,
                                                vertical: 2),
                                            decoration: BoxDecoration(
                                              color: color
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8),
                                            ),
                                            child: Text(
                                              m['meal_type'][0]
                                                      .toUpperCase() +
                                                  m['meal_type']
                                                      .substring(1),
                                              style: TextStyle(
                                                  color: color,
                                                  fontSize: 11),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(children: [
                                            const Icon(
                                                Icons
                                                    .local_fire_department,
                                                color: Colors.grey,
                                                size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                                '${m['calories']} kcal',
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                            const SizedBox(width: 12),
                                            const Icon(
                                                Icons.fitness_center,
                                                color: Colors.grey,
                                                size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                                '${m['protein']}g protein',
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12)),
                                          ]),
                                          if (m['notes'] != null &&
                                              m['notes']
                                                  .toString()
                                                  .isNotEmpty)
                                            Text(m['notes'],
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        await ApiService.deleteMealLog(
                                            int.parse(
                                                m['id'].toString()));
                                        loadData();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE53935),
        onPressed: _showAddMealDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _totalCard(
      String label, String value, IconData icon, Color color) {
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
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}