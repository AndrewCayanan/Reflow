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

$result = $conn->query("
    SELECT 
        u.id,
        u.name,
        COALESCE(up.total_points, 0) as total_points,
        COALESCE(up.workout_points, 0) as workout_points,
        COALESCE(up.calorie_points, 0) as calorie_points,
        COALESCE(up.streak_days, 0) as streak_days,
        COALESCE(up.rank_title, 'Beginner') as rank_title,
        COUNT(w.id) as total_workouts,
        COALESCE(SUM(w.calories_burned), 0) as total_calories,
        COALESCE(SUM(w.duration_minutes), 0) as total_duration
    FROM users u
    LEFT JOIN user_points up ON u.id = up.user_id
    LEFT JOIN workouts w ON u.id = w.user_id
    GROUP BY u.id
    ORDER BY total_points DESC
");

$leaderboard = [];
$rank = 1;
while ($row = $result->fetch_assoc()) {
    $row['rank'] = $rank++;
    $leaderboard[] = $row;
}

echo json_encode($leaderboard);
$conn->close();
?>