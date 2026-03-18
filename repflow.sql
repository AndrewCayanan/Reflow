-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Mar 18, 2026 at 12:40 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `repflow`
--

-- --------------------------------------------------------

--
-- Table structure for table `foods`
--

CREATE TABLE `foods` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `calories_per_serving` float NOT NULL,
  `protein_per_serving` float NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `calories_per_100g` float DEFAULT NULL,
  `protein_per_100g` float DEFAULT NULL,
  `added_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `foods`
--

INSERT INTO `foods` (`id`, `name`, `calories_per_serving`, `protein_per_serving`, `created_at`, `calories_per_100g`, `protein_per_100g`, `added_by`) VALUES
(1, 'Chicken', 600, 50, '2026-03-17 19:03:56', 239, 26, NULL),
(2, 'Chicken Breast', 300, 27, '2026-03-17 19:10:54', 165, 31, 5),
(3, 'breast', 100, 30, '2026-03-17 19:16:52', NULL, NULL, 5),
(4, 'chickensss', 150, 30, '2026-03-17 19:18:52', 150, 30, 5);

-- --------------------------------------------------------

--
-- Table structure for table `meal_logs`
--

CREATE TABLE `meal_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `food_id` int(11) DEFAULT NULL,
  `meal_name` varchar(100) NOT NULL,
  `calories` float NOT NULL,
  `protein` float NOT NULL,
  `meal_type` varchar(20) DEFAULT 'snack',
  `log_date` date NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `meal_logs`
--

INSERT INTO `meal_logs` (`id`, `user_id`, `food_id`, `meal_name`, `calories`, `protein`, `meal_type`, `log_date`, `notes`, `created_at`) VALUES
(1, 5, 1, 'Chicken', 600, 50, 'lunch', '2026-03-18', 'good', '2026-03-17 19:03:56'),
(2, 5, 1, 'Chicken', 600, 50, 'breakfast', '2026-03-18', '', '2026-03-17 19:04:02'),
(3, 5, 1, 'Chicken', 600, 50, 'breakfast', '2026-03-18', '', '2026-03-17 19:10:23'),
(6, 5, 2, 'Chicken Breast', 330, 62, 'breakfast', '2026-03-18', '', '2026-03-17 19:16:17'),
(7, 5, NULL, 'Chicken Breast', 100, 30, 'lunch', '2026-03-18', 'meal', '2026-03-17 19:16:35'),
(8, 5, 3, 'breast', 100, 30, 'lunch', '2026-03-18', '', '2026-03-17 19:16:52'),
(9, 5, 3, 'breast', 100, 30, 'breakfast', '2026-03-18', '', '2026-03-17 19:18:13'),
(10, 5, 4, 'chickensss', 450, 90, 'breakfast', '2026-03-18', '', '2026-03-17 19:19:06'),
(11, 5, 4, 'chickensss', 900, 180, 'breakfast', '2026-03-18', '', '2026-03-17 19:33:53'),
(12, 6, 4, 'chickensss', 825, 165, 'breakfast', '2026-03-18', '', '2026-03-17 19:38:19');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `age` int(11) DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `weight` float DEFAULT NULL,
  `height` float DEFAULT NULL,
  `activity_level` varchar(20) DEFAULT 'moderate'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `created_at`, `age`, `gender`, `weight`, `height`, `activity_level`) VALUES
(5, 'Andrew Cayanan', 'cayananandrew09@gmail.com', '$2y$10$KIPmw4MyiryEuTEFXL/5SeQWnsea4KJRjr2JlCX983R7c.I2ONVDe', '2026-03-17 17:34:49', 22, 'Male', 84, 177, 'active'),
(6, 'Andrew Bart Cayanan', 'cayananandrew07@gmail.com', '$2y$10$R04b9dRc7Twsh6FU0k/oS.A.QeOc7D08tRerpNsmpBol3dtiQynyu', '2026-03-17 19:36:35', 21, 'Male', 70, 177, 'active');

-- --------------------------------------------------------

--
-- Table structure for table `user_points`
--

CREATE TABLE `user_points` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `total_points` int(11) DEFAULT 0,
  `workout_points` int(11) DEFAULT 0,
  `calorie_points` int(11) DEFAULT 0,
  `streak_days` int(11) DEFAULT 0,
  `rank_title` varchar(50) DEFAULT 'Beginner',
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_points`
--

INSERT INTO `user_points` (`id`, `user_id`, `total_points`, `workout_points`, `calorie_points`, `streak_days`, `rank_title`, `last_updated`) VALUES
(1, 5, 64, 10, 42, 1, '🌱 Rookie', '2026-03-18 11:15:11');

-- --------------------------------------------------------

--
-- Table structure for table `workouts`
--

CREATE TABLE `workouts` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(150) NOT NULL,
  `exercise_type` varchar(100) NOT NULL,
  `duration_minutes` int(11) NOT NULL,
  `calories_burned` int(11) NOT NULL,
  `notes` text DEFAULT NULL,
  `workout_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `workouts`
--

INSERT INTO `workouts` (`id`, `user_id`, `title`, `exercise_type`, `duration_minutes`, `calories_burned`, `notes`, `workout_date`, `created_at`) VALUES
(2, 5, 'chest day', 'Strength', 120, 6000, 'nice', '2026-03-18', '2026-03-17 18:22:29'),
(3, 5, 'Run', 'Cardio', 60, 995, 'nice | Distance: 5km | Incline: 1%', '2026-03-18', '2026-03-17 19:26:28'),
(4, 5, 'run', 'Cardio', 60, 966, 'nice | Distance: 5km', '2026-03-18', '2026-03-17 19:30:14'),
(5, 5, 'Chest', 'Strength', 60, 420, 'nice | Sets: 4 | Reps: 12 | Weight lifted: 75kg', '2026-03-18', '2026-03-18 11:15:11');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `foods`
--
ALTER TABLE `foods`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `meal_logs`
--
ALTER TABLE `meal_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_points`
--
ALTER TABLE `user_points`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `workouts`
--
ALTER TABLE `workouts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `foods`
--
ALTER TABLE `foods`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `meal_logs`
--
ALTER TABLE `meal_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `user_points`
--
ALTER TABLE `user_points`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `workouts`
--
ALTER TABLE `workouts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `workouts`
--
ALTER TABLE `workouts`
  ADD CONSTRAINT `workouts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
