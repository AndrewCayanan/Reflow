<?php
include 'db.php';

$data = json_decode(file_get_contents("php://input"), true);
$name = $conn->real_escape_string($data['name']);
$email = $conn->real_escape_string($data['email']);
$password = password_hash($data['password'], PASSWORD_DEFAULT);

$check = $conn->query("SELECT id FROM users WHERE email='$email'");
if ($check->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "Email already exists"]);
    exit;
}

$sql = "INSERT INTO users (name, email, password) VALUES ('$name', '$email', '$password')";
if ($conn->query($sql)) {
    $id = $conn->insert_id;
    echo json_encode([
        "success" => true,
        "message" => "Registered successfully",
        "user" => ["id" => $id, "name" => $name, "email" => $email]
    ]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}
$conn->close();
?>