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
$calories = intval($data['calories_burned']);
$duration = intval($data['duration_minutes']);

// Calculate points
$workout_pts = 10;
$calorie_pts = intval($calories / 10);
$duration_pts = intval($duration / 5);
$total_pts = $workout_pts + $calorie_pts + $duration_pts;

// Calculate streak
$streakResult = $conn->query("
    SELECT COUNT(DISTINCT DATE(created_at)) as streak
    FROM workouts
    WHERE user_id = $user_id
    AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
");
$streak = intval($streakResult->fetch_assoc()['streak']);

// Determine rank title based on total points
$totalResult = $conn->query("
    SELECT COALESCE(total_points, 0) + $total_pts as new_total
    FROM user_points WHERE user_id = $user_id
");
$row = $totalResult->fetch_assoc();
$newTotal = intval($row['new_total'] ?? $total_pts);

$rankTitle = 'Beginner';
if ($newTotal >= 5000) $rankTitle = '👑 Legend';
else if ($newTotal >= 2000) $rankTitle = '💎 Elite';
else if ($newTotal >= 1000) $rankTitle = '🔥 Veteran';
else if ($newTotal >= 500) $rankTitle = '⚡ Warrior';
else if ($newTotal >= 200) $rankTitle = '💪 Athlete';
else if ($newTotal >= 100) $rankTitle = '🏃 Runner';
else if ($newTotal >= 50) $rankTitle = '🌱 Rookie';
else $rankTitle = '🐣 Beginner';

// Upsert points
$sql = "INSERT INTO user_points (user_id, total_points, workout_points, calorie_points, streak_days, rank_title)
        VALUES ($user_id, $total_pts, $workout_pts, $calorie_pts, $streak, '$rankTitle')
        ON DUPLICATE KEY UPDATE
            total_points = total_points + $total_pts,
            workout_points = workout_points + $workout_pts,
            calorie_points = calorie_points + $calorie_pts,
            streak_days = $streak,
            rank_title = '$rankTitle'";

if ($conn->query($sql)) {
    echo json_encode([
        "success" => true,
        "points_earned" => $total_pts,
        "rank_title" => $rankTitle
    ]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}
$conn->close();
?>