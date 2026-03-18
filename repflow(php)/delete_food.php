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
$id = intval($data['id']);
$user_id = intval($data['user_id']);

// Only allow deleting if the user added it
$check = $conn->query("SELECT added_by FROM foods WHERE id=$id");
$food = $check->fetch_assoc();

if (!$food) {
    echo json_encode(["success" => false, "message" => "Food not found"]);
    exit();
}

if ($food['added_by'] != $user_id) {
    echo json_encode(["success" => false, "message" => "You can only delete foods you added"]);
    exit();
}

if ($conn->query("DELETE FROM foods WHERE id=$id")) {
    echo json_encode(["success" => true, "message" => "Food deleted"]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}
$conn->close();
?>