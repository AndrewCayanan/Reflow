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

$result = $conn->query("SELECT id, name, email, age, gender, weight, height, activity_level FROM users WHERE id=$user_id");
$user = $result->fetch_assoc();

echo json_encode($user);
$conn->close();
?>