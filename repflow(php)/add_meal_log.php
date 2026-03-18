<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

include 'db.php';

$data = json_decode(file_get_contents("php://input"), true);
$user_id = intval($data['user_id']);
$food_id = isset($data['food_id']) ? intval($data['food_id']) : 'NULL';
$meal_name = $conn->real_escape_string($data['meal_name']);
$calories = floatval($data['calories']);
$protein = floatval($data['protein']);
$meal_type = $conn->real_escape_string($data['meal_type'] ?? 'snack');
$log_date = $conn->real_escape_string($data['log_date']);
$notes = $conn->real_escape_string($data['notes'] ?? '');

$sql = "INSERT INTO meal_logs (user_id, food_id, meal_name, calories, protein, meal_type, log_date, notes)
        VALUES ($user_id, $food_id, '$meal_name', $calories, $protein, '$meal_type', '$log_date', '$notes')";

if ($conn->query($sql)) {
    echo json_encode(["success" => true, "message" => "Meal logged"]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}
$conn->close();
?>