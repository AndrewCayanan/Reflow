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
$age = intval($data['age']);
$gender = $conn->real_escape_string($data['gender']);
$weight = floatval($data['weight']);
$height = floatval($data['height']);
$activity_level = $conn->real_escape_string($data['activity_level']);

$sql = "UPDATE users SET age=$age, gender='$gender', weight=$weight, height=$height, activity_level='$activity_level' WHERE id=$user_id";

if ($conn->query($sql)) {
    echo json_encode(["success" => true, "message" => "Profile updated"]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}
$conn->close();
?>