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
$title = $conn->real_escape_string($data['title']);
$exercise_type = $conn->real_escape_string($data['exercise_type']);
$duration = intval($data['duration_minutes']);
$calories = intval($data['calories_burned']);
$notes = $conn->real_escape_string($data['notes'] ?? '');
$date = $conn->real_escape_string($data['workout_date']);

$sql = "INSERT INTO workouts (user_id, title, exercise_type, duration_minutes, calories_burned, notes, workout_date)
        VALUES ($user_id, '$title', '$exercise_type', $duration, $calories, '$notes', '$date')";

if ($conn->query($sql)) {
    // Calculate and update points
    $workout_pts = 10;
    $calorie_pts = intval($calories / 10);
    $duration_pts = intval($duration / 5);
    $total_pts = $workout_pts + $calorie_pts + $duration_pts;

    // Calculate streak
    $streakResult = $conn->query("
        SELECT COUNT(DISTINCT workout_date) as streak
        FROM workouts
        WHERE user_id = $user_id
        AND workout_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    ");
    $streak = intval($streakResult->fetch_assoc()['streak']);

    // Get new total to determine rank
    $totalResult = $conn->query("SELECT total_points FROM user_points WHERE user_id = $user_id");
    $row = $totalResult->fetch_assoc();
    $newTotal = intval($row['total_points'] ?? 0) + $total_pts;

    $rankTitle = '🐣 Beginner';
    if ($newTotal >= 5000) $rankTitle = '👑 Legend';
    else if ($newTotal >= 2000) $rankTitle = '💎 Elite';
    else if ($newTotal >= 1000) $rankTitle = '🔥 Veteran';
    else if ($newTotal >= 500) $rankTitle = '⚡ Warrior';
    else if ($newTotal >= 200) $rankTitle = '💪 Athlete';
    else if ($newTotal >= 100) $rankTitle = '🏃 Runner';
    else if ($newTotal >= 50) $rankTitle = '🌱 Rookie';

    $conn->query("INSERT INTO user_points (user_id, total_points, workout_points, calorie_points, streak_days, rank_title)
        VALUES ($user_id, $total_pts, $workout_pts, $calorie_pts, $streak, '$rankTitle')
        ON DUPLICATE KEY UPDATE
            total_points = total_points + $total_pts,
            workout_points = workout_points + $workout_pts,
            calorie_points = calorie_points + $calorie_pts,
            streak_days = $streak,
            rank_title = '$rankTitle'");

    echo json_encode([
        "success" => true,
        "message" => "Workout added",
        "points_earned" => $total_pts,
        "rank_title" => $rankTitle
    ]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}
$conn->close();
?>