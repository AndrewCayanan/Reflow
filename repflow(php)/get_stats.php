<?php
include 'db.php';

$user_id = intval($_GET['user_id']);

$total = $conn->query("SELECT COUNT(*) as total, SUM(calories_burned) as calories, SUM(duration_minutes) as duration FROM workouts WHERE user_id=$user_id")->fetch_assoc();

$weekly = $conn->query("SELECT workout_date, SUM(calories_burned) as calories, COUNT(*) as count FROM workouts WHERE user_id=$user_id AND workout_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) GROUP BY workout_date ORDER BY workout_date ASC");

$weeklyData = [];
while ($row = $weekly->fetch_assoc()) {
    $weeklyData[] = $row;
}

echo json_encode([
    "total_workouts" => intval($total['total']),
    "total_calories" => intval($total['calories']),
    "total_duration" => intval($total['duration']),
    "weekly" => $weeklyData
]);
$conn->close();
?>