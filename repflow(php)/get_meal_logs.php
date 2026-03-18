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

$user_id = intval($_GET['user_id']);
$date = $conn->real_escape_string($_GET['date'] ?? date('Y-m-d'));

$result = $conn->query("SELECT * FROM meal_logs WHERE user_id=$user_id AND log_date='$date' ORDER BY created_at ASC");

$logs = [];
while ($row = $result->fetch_assoc()) {
    $logs[] = $row;
}

// Daily totals
$totals = $conn->query("SELECT SUM(calories) as total_calories, SUM(protein) as total_protein FROM meal_logs WHERE user_id=$user_id AND log_date='$date'")->fetch_assoc();

echo json_encode([
    "logs" => $logs,
    "total_calories" => floatval($totals['total_calories'] ?? 0),
    "total_protein" => floatval($totals['total_protein'] ?? 0),
]);
$conn->close();
?>