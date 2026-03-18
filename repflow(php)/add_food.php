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
$added_by = intval($data['added_by']);
$name = $conn->real_escape_string($data['name']);
$calories_per_serving = floatval($data['calories_per_serving']);
$protein_per_serving = floatval($data['protein_per_serving']);
$calories_per_100g = isset($data['calories_per_100g']) ? floatval($data['calories_per_100g']) : 'NULL';
$protein_per_100g = isset($data['protein_per_100g']) ? floatval($data['protein_per_100g']) : 'NULL';

// Check if food already exists
$check = $conn->query("SELECT id FROM foods WHERE name='$name'");
if ($check->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "Food already exists in database"]);
    exit();
}

$sql = "INSERT INTO foods (name, calories_per_serving, protein_per_serving, calories_per_100g, protein_per_100g, added_by) 
        VALUES ('$name', $calories_per_serving, $protein_per_serving, $calories_per_100g, $protein_per_100g, $added_by)";

if ($conn->query($sql)) {
    echo json_encode(["success" => true, "message" => "Food added to database", "id" => $conn->insert_id]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}
$conn->close();
?>