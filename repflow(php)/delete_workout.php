<?php
include 'db.php';

$data = json_decode(file_get_contents("php://input"), true);
$id = intval($data['id']);

if ($conn->query("DELETE FROM workouts WHERE id=$id")) {
    echo json_encode(["success" => true, "message" => "Workout deleted"]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}
$conn->close();
?>