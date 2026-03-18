import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.100.214:8080/repflow";

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"name": name, "email": email, "password": password}),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "password": password}),
    );
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getWorkouts(int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_workouts.php?user_id=$userId"),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> addWorkout(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/add_workout.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateWorkout(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update_workout.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteWorkout(int id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete_workout.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id": id}),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getStats(int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_stats.php?user_id=$userId"),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getProfile(int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_profile.php?user_id=$userId"),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update_profile.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getFoods({String search = ''}) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_foods.php?search=$search"),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> addFood(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/add_food.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteFood(
      int id, int userId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete_food.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id": id, "user_id": userId}),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getMealLogs(
      int userId, String date) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_meal_logs.php?user_id=$userId&date=$date"),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> addMealLog(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/add_meal_log.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteMealLog(int id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete_meal_log.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id": id}),
    );
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getLeaderboard() async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_leaderboard.php"),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getUserRank(int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_user_rank.php?user_id=$userId"),
    );
    return json.decode(response.body);
  }
}