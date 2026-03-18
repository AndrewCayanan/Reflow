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

$search = isset($_GET['search']) ? $conn->real_escape_string($_GET['search']) : '';

if ($search) {
    $result = $conn->query("SELECT foods.*, users.name as added_by_name FROM foods LEFT JOIN users ON foods.added_by = users.id WHERE foods.name LIKE '%$search%' ORDER BY foods.name ASC");
} else {
    $result = $conn->query("SELECT foods.*, users.name as added_by_name FROM foods LEFT JOIN users ON foods.added_by = users.id ORDER BY foods.name ASC");
}

$foods = [];
while ($row = $result->fetch_assoc()) {
    $foods[] = $row;
}

echo json_encode($foods);
$conn->close();
?>