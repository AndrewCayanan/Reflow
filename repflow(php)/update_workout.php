<?php
include 'db.php';

$data = json_decode(file_get_contents("php://input"), true);
$id = intval($data['id']);
$title = $conn->real_escape_string($data['title']);
$exercise_type = $conn->real_escape_string($data['exercise_type']);
$duration = intval($data['duration_minutes']);
$calories = intval($data['calories_burned']);
$notes = $conn->real_escape_string($data['notes'] ?? '');
$date = $conn->real_escape_string($data['workout_date']);

$sql = "UPDATE workouts SET title='$title', exercise_type='$exercise_type',
        duration_minutes=$duration, calories_burned=$calories,
        notes='$notes', workout_date='$date' WHERE id=$id";

if ($conn->query($sql)) {
    echo json_encode(["success" => true, "message" => "Workout updated"]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}
$conn->close();
?>