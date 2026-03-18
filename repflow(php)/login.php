<?php
include 'db.php';

$data = json_decode(file_get_contents("php://input"), true);
$email = $conn->real_escape_string($data['email']);
$password = $data['password'];

$result = $conn->query("SELECT * FROM users WHERE email='$email'");
if ($result->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Email not found"]);
    exit;
}

$user = $result->fetch_assoc();
if (password_verify($password, $user['password'])) {
    echo json_encode([
        "success" => true,
        "message" => "Login successful",
        "user" => [
            "id" => $user['id'],
            "name" => $user['name'],
            "email" => $user['email']
        ]
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Incorrect password"]);
}
$conn->close();
?>