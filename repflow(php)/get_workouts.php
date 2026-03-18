<?php
include 'db.php';

$user_id = intval($_GET['user_id']);
$result = $conn->query(
    "SELECT * FROM workouts WHERE user_id=$user_id ORDER BY workout_date DESC"
);

$workouts = [];
while ($row = $result->fetch_assoc()) {
    $workouts[] = $row;
}

echo json_encode($workouts);
$conn->close();
?>