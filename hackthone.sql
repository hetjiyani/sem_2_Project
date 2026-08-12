-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 12, 2026 at 10:27 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hackthone`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_combined_filter` (IN `p_city` VARCHAR(100), IN `p_skill_name` VARCHAR(100))   BEGIN
    SELECT
        h.hackathon_id,
        h.title,
        h.location_city,
        h.mode,
        h.prize_pool,
        h.start_date,
        (h.max_participants - h.current_participants) AS seats_left,
        GROUP_CONCAT(DISTINCT s.skill_name SEPARATOR ', ') AS required_skills
    FROM hackathons h
    JOIN hackathonskillrequired hsr ON hsr.hackathon_id = h.hackathon_id
    JOIN skills s ON s.skill_id = hsr.skill_id
    WHERE h.location_city = p_city
      AND h.current_participants < h.max_participants
    GROUP BY h.hackathon_id
    HAVING SUM(s.skill_name = p_skill_name) > 0
    ORDER BY h.prize_pool DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_filter_by_domain` (IN `p_domain_name` VARCHAR(100))   BEGIN
    SELECT
        h.hackathon_id,
        h.title,
        h.location_city,
        h.mode,
        h.prize_pool,
        h.start_date,
        di.interest_name
    FROM hackathons h
    JOIN hackathondomain hd ON hd.hackathon_id = h.hackathon_id
    JOIN domaininterests di ON di.interest_id = hd.interest_id
    WHERE di.interest_name = p_domain_name
    ORDER BY h.start_date ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_filter_by_skill` (IN `p_skill_name` VARCHAR(100))   BEGIN
    SELECT
        h.hackathon_id,
        h.title,
        h.location_city,
        h.mode,
        h.prize_pool,
        h.start_date,
        s.skill_name
    FROM hackathons h
    JOIN hackathonskillrequired hsr ON hsr.hackathon_id = h.hackathon_id
    JOIN skills s ON s.skill_id = hsr.skill_id
    WHERE s.skill_name = p_skill_name
    ORDER BY h.start_date ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_filter_city_mode_prize` (IN `p_city` VARCHAR(100), IN `p_mode` VARCHAR(20), IN `p_min_prize` DECIMAL(12,2), IN `p_max_prize` DECIMAL(12,2))   BEGIN
    SELECT
        h.hackathon_id,
        h.title,
        h.location_city,
        h.mode,
        h.prize_pool,
        h.start_date,
        h.end_date,
        (h.max_participants - h.current_participants) AS seats_left
    FROM hackathons h
    WHERE h.location_city = p_city
      AND h.mode = p_mode
      AND h.prize_pool BETWEEN p_min_prize AND p_max_prize
    ORDER BY h.prize_pool DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_hackathon_master_details` ()   BEGIN
    SELECT
        h.hackathon_id,
        h.title,
        h.location_city,
        h.mode,
        h.prize_pool,
        h.start_date,
        h.end_date,
        h.registration_deadline,
        h.max_participants,
        h.current_participants,
        (h.max_participants - h.current_participants) AS seats_left,
        GROUP_CONCAT(DISTINCT di.interest_name SEPARATOR ', ') AS domains,
        GROUP_CONCAT(DISTINCT s.skill_name SEPARATOR ', ')      AS required_skills,
        COUNT(DISTINCT r.registration_id)                        AS total_registrations,
        COUNT(DISTINCT t.team_id)                                 AS total_teams,
        COUNT(DISTINCT w.watchlist_id)                             AS total_bookmarks
    FROM hackathons h
    LEFT JOIN hackathondomain hd        ON hd.hackathon_id = h.hackathon_id
    LEFT JOIN domaininterests di        ON di.interest_id = hd.interest_id
    LEFT JOIN hackathonskillrequired hsr ON hsr.hackathon_id = h.hackathon_id
    LEFT JOIN skills s                  ON s.skill_id = hsr.skill_id
    LEFT JOIN registration r            ON r.hackathon_id = h.hackathon_id AND r.status = 'REGISTERED'
    LEFT JOIN teams t                   ON t.hackathon_id = h.hackathon_id
    LEFT JOIN watchlist w               ON w.hackathon_id = h.hackathon_id
    GROUP BY h.hackathon_id
    ORDER BY h.start_date ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_hackathon_status` (IN `p_status` VARCHAR(20))   BEGIN
    SELECT * FROM (
        SELECT
            h.hackathon_id,
            h.title,
            h.start_date,
            h.end_date,
            h.registration_deadline,
            CASE
                WHEN CURDATE() > h.end_date THEN 'CLOSED'
                WHEN CURDATE() BETWEEN h.start_date AND h.end_date THEN 'ONGOING'
                ELSE 'UPCOMING'
            END AS event_status
        FROM hackathons h
    ) AS status_table
    WHERE p_status IS NULL OR event_status = p_status
    ORDER BY start_date ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_open_seats` ()   BEGIN
    SELECT
        h.hackathon_id,
        h.title,
        h.location_city,
        h.mode,
        h.prize_pool,
        h.registration_deadline,
        (h.max_participants - h.current_participants) AS seats_left
    FROM hackathons h
    WHERE h.current_participants < h.max_participants
      AND h.registration_deadline >= CURDATE()
    ORDER BY h.registration_deadline ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_search_by_title` (IN `p_keyword` VARCHAR(150))   BEGIN
    SELECT
        h.hackathon_id,
        h.title,
        h.location_city,
        h.mode,
        h.prize_pool,
        h.start_date
    FROM hackathons h
    WHERE h.title LIKE CONCAT('%', p_keyword, '%')
    ORDER BY h.start_date ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_trending_hackathons` (IN `p_limit` INT)   BEGIN
    SELECT
        h.hackathon_id,
        h.title,
        h.location_city,
        h.mode,
        COUNT(w.watchlist_id) AS bookmark_count
    FROM hackathons h
    LEFT JOIN watchlist w ON w.hackathon_id = h.hackathon_id
    GROUP BY h.hackathon_id
    ORDER BY bookmark_count DESC
    LIMIT p_limit;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `domaininterests`
--

CREATE TABLE `domaininterests` (
  `interest_id` int(11) NOT NULL,
  `interest_name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `domaininterests`
--

INSERT INTO `domaininterests` (`interest_id`, `interest_name`) VALUES
(16, 'AgriTech'),
(11, 'AR/VR'),
(1, 'Artificial Intelligence'),
(21, 'Big Data'),
(8, 'Blockchain'),
(17, 'Climate Tech'),
(6, 'Cloud Computing'),
(22, 'Computer Vision'),
(7, 'Cybersecurity'),
(3, 'Data Science'),
(20, 'DevOps'),
(15, 'EdTech'),
(24, 'Embedded Systems'),
(13, 'FinTech'),
(10, 'Game Development'),
(14, 'HealthTech'),
(9, 'Internet of Things'),
(2, 'Machine Learning'),
(5, 'Mobile App Development'),
(23, 'Natural Language Processing'),
(18, 'Open Source'),
(25, 'Quantum Computing'),
(12, 'Robotics'),
(19, 'UI/UX Design'),
(4, 'Web Development');

-- --------------------------------------------------------

--
-- Table structure for table `hackathondomain`
--

CREATE TABLE `hackathondomain` (
  `hackathon_id` int(11) NOT NULL,
  `interest_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `hackathondomain`
--

INSERT INTO `hackathondomain` (`hackathon_id`, `interest_id`) VALUES
(1, 4),
(1, 19),
(2, 1),
(2, 2),
(3, 4),
(3, 5),
(4, 7),
(4, 20),
(5, 6),
(5, 21),
(6, 8),
(6, 13),
(7, 3),
(7, 14),
(8, 10),
(8, 11),
(9, 4),
(9, 15),
(10, 16),
(10, 17),
(11, 1),
(11, 22),
(12, 7),
(12, 18),
(13, 9),
(13, 24),
(14, 8),
(14, 13),
(15, 4),
(15, 20),
(16, 5),
(16, 19),
(17, 5),
(17, 14),
(18, 3),
(18, 21),
(19, 1),
(19, 23),
(20, 6),
(20, 8),
(21, 10),
(21, 19),
(22, 4),
(22, 15),
(23, 16),
(23, 17),
(24, 7),
(24, 20),
(25, 3),
(25, 13),
(26, 4),
(26, 5),
(27, 1),
(27, 2),
(28, 8),
(28, 18),
(29, 9),
(29, 12),
(30, 14),
(30, 19),
(31, 22),
(31, 23),
(32, 6),
(32, 20),
(33, 10),
(33, 11),
(34, 16),
(34, 17),
(35, 5),
(35, 15),
(36, 4),
(36, 13),
(37, 7),
(37, 24),
(38, 3),
(38, 21),
(39, 1),
(39, 6),
(40, 5),
(40, 19),
(41, 3),
(41, 14),
(42, 8),
(42, 13),
(43, 10),
(43, 11),
(44, 4),
(44, 15),
(45, 16),
(45, 17),
(46, 1),
(46, 22),
(47, 7),
(47, 18),
(48, 9),
(48, 24),
(49, 8),
(49, 13),
(50, 4),
(50, 20),
(51, 5),
(51, 19),
(52, 5),
(52, 14),
(53, 3),
(53, 21),
(54, 1),
(54, 23),
(55, 6),
(55, 8),
(56, 10),
(56, 19),
(57, 4),
(57, 15),
(58, 16),
(58, 17),
(59, 7),
(59, 20),
(60, 3),
(60, 13),
(61, 4),
(61, 5),
(62, 1),
(62, 2),
(63, 8),
(63, 18),
(64, 9),
(64, 12),
(65, 14),
(65, 19),
(66, 22),
(66, 23),
(67, 2),
(67, 6),
(67, 20),
(68, 10),
(68, 11),
(69, 16),
(69, 17),
(70, 5),
(70, 15),
(71, 4),
(71, 13),
(72, 7),
(72, 24),
(73, 3),
(73, 21),
(74, 1),
(74, 6),
(75, 5),
(75, 19),
(76, 3),
(76, 14),
(77, 8),
(77, 13),
(78, 10),
(78, 11),
(79, 4),
(79, 15),
(80, 16),
(80, 17),
(81, 1),
(81, 22),
(82, 7),
(82, 18),
(83, 9),
(83, 24),
(84, 8),
(84, 13),
(85, 4),
(85, 20),
(86, 5),
(86, 19),
(87, 5),
(87, 14),
(88, 3),
(88, 21),
(89, 1),
(89, 23),
(90, 6),
(90, 8),
(91, 10),
(91, 19),
(92, 4),
(92, 15),
(93, 16),
(93, 17),
(94, 7),
(94, 20),
(95, 3),
(95, 13),
(96, 4),
(96, 5),
(97, 1),
(97, 2),
(98, 8),
(98, 18),
(99, 9),
(99, 12);

-- --------------------------------------------------------

--
-- Table structure for table `hackathons`
--

CREATE TABLE `hackathons` (
  `hackathon_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `location_city` varchar(100) NOT NULL,
  `mode` enum('ONLINE','OFFLINE','HYBRID') NOT NULL,
  `prize_pool` decimal(12,2) NOT NULL CHECK (`prize_pool` >= 0),
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `registration_deadline` date NOT NULL,
  `max_participants` int(11) NOT NULL CHECK (`max_participants` > 0),
  `current_participants` int(11) DEFAULT 0 CHECK (`current_participants` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `hackathons`
--

INSERT INTO `hackathons` (`hackathon_id`, `title`, `location_city`, `mode`, `prize_pool`, `start_date`, `end_date`, `registration_deadline`, `max_participants`, `current_participants`) VALUES
(1, 'CodeStorm 2026', 'Ahmedabad', 'OFFLINE', 100000.00, '2026-08-10', '2026-08-12', '2026-08-01', 50, 49),
(2, 'Hack the Future', 'Bangalore', 'ONLINE', 250000.00, '2026-08-15', '2026-08-17', '2026-08-05', 75, 18),
(3, 'AI Fusion Challenge', 'Hyderabad', 'OFFLINE', 300000.00, '2026-08-20', '2026-08-22', '2026-08-10', 150, 108),
(4, 'Byte Battle', 'Pune', 'ONLINE', 75000.00, '2026-08-25', '2026-08-26', '2026-08-15', 50, 13),
(5, 'CodeSprint India', 'Delhi', 'ONLINE', 150000.00, '2026-09-01', '2026-09-03', '2026-08-20', 150, 6),
(6, 'CloudHack Summit', 'Mumbai', 'OFFLINE', 200000.00, '2026-09-05', '2026-09-07', '2026-08-25', 150, 107),
(7, 'VisionX AI Hack', 'Chennai', 'ONLINE', 500000.00, '2026-09-10', '2026-09-12', '2026-08-30', 250, 207),
(8, 'HackVerse', 'Kolkata', 'HYBRID', 100000.00, '2026-09-15', '2026-09-17', '2026-09-05', 75, 54),
(9, 'NextGen Coders', 'Ahmedabad', 'ONLINE', 125000.00, '2026-09-18', '2026-09-20', '2026-09-08', 75, 27),
(10, 'Cyber Shield Hack', 'Delhi', 'HYBRID', 400000.00, '2026-09-22', '2026-09-24', '2026-09-12', 250, 26),
(11, 'Open Source Sprint', 'Jaipur', 'ONLINE', 50000.00, '2026-09-25', '2026-09-26', '2026-09-15', 50, 22),
(12, 'InnovateX', 'Surat', 'HYBRID', 175000.00, '2026-10-01', '2026-10-03', '2026-09-20', 150, 67),
(13, 'DataHack India', 'Bangalore', 'HYBRID', 350000.00, '2026-10-05', '2026-10-07', '2026-09-25', 300, 274),
(14, 'Build for Bharat', 'Lucknow', 'ONLINE', 120000.00, '2026-10-10', '2026-10-12', '2026-09-30', 120, 10),
(15, 'GreenTech Hack', 'Indore', 'OFFLINE', 150000.00, '2026-10-15', '2026-10-17', '2026-10-05', 150, 92),
(16, 'Blockchain Blitz', 'Hyderabad', 'OFFLINE', 450000.00, '2026-10-20', '2026-10-22', '2026-10-10', 150, 11),
(17, 'Smart City Challenge', 'Ahmedabad', 'OFFLINE', 275000.00, '2026-10-25', '2026-10-27', '2026-10-15', 250, 20),
(18, 'FinTech HackFest', 'Mumbai', 'HYBRID', 325000.00, '2026-11-01', '2026-11-03', '2026-10-20', 150, 97),
(19, 'Code Carnival', 'Nagpur', 'ONLINE', 80000.00, '2026-11-05', '2026-11-06', '2026-10-25', 100, 20),
(20, 'AppForge', 'Pune', 'OFFLINE', 140000.00, '2026-11-10', '2026-11-12', '2026-10-30', 75, 35),
(21, 'HealthTech Innovators', 'Chandigarh', 'OFFLINE', 250000.00, '2026-11-15', '2026-11-17', '2026-11-05', 50, 38),
(22, 'Hack Infinity', 'Vadodara', 'OFFLINE', 90000.00, '2026-11-20', '2026-11-22', '2026-11-10', 150, 62),
(23, 'Quantum Quest', 'Noida', 'ONLINE', 600000.00, '2026-11-25', '2026-11-27', '2026-11-15', 600, 276),
(24, 'Robo Revolution', 'Kochi', 'HYBRID', 225000.00, '2026-12-01', '2026-12-03', '2026-11-20', 150, 56),
(25, 'Code Cosmos', 'Rajkot', 'OFFLINE', 100000.00, '2026-12-05', '2026-12-07', '2026-11-25', 50, 14),
(26, 'DevSprint Challenge', 'Ahmedabad', 'HYBRID', 125000.00, '2026-12-10', '2026-12-12', '2026-11-30', 100, 51),
(27, 'AI Odyssey', 'Bangalore', 'ONLINE', 450000.00, '2026-12-15', '2026-12-17', '2026-12-05', 200, 145),
(28, 'Cloud Catalyst', 'Hyderabad', 'HYBRID', 275000.00, '2026-12-20', '2026-12-22', '2026-12-10', 250, 54),
(29, 'SecureCode Hack', 'Delhi', 'OFFLINE', 300000.00, '2027-01-05', '2027-01-07', '2026-12-25', 300, 234),
(30, 'Web Wizards Cup', 'Pune', 'ONLINE', 100000.00, '2027-01-10', '2027-01-12', '2026-12-30', 75, 31),
(31, 'AppVerse', 'Mumbai', 'OFFLINE', 180000.00, '2027-01-15', '2027-01-17', '2027-01-05', 150, 67),
(32, 'ML Marathon', 'Chennai', 'OFFLINE', 400000.00, '2027-01-20', '2027-01-22', '2027-01-10', 300, 298),
(33, 'Hack Horizon', 'Surat', 'OFFLINE', 90000.00, '2027-01-25', '2027-01-27', '2027-01-15', 75, 17),
(34, 'Future Builders', 'Jaipur', 'OFFLINE', 150000.00, '2027-02-01', '2027-02-03', '2027-01-20', 50, 48),
(35, 'CryptoCon Hack', 'Noida', 'ONLINE', 500000.00, '2027-02-05', '2027-02-07', '2027-01-25', 150, 39),
(36, 'DeepVision Challenge', 'Indore', 'OFFLINE', 225000.00, '2027-02-10', '2027-02-12', '2027-01-30', 120, 76),
(37, 'Tech Titans Hack', 'Nagpur', 'ONLINE', 130000.00, '2027-02-15', '2027-02-17', '2027-02-05', 120, 76),
(38, 'Digital India Hack', 'Ahmedabad', 'HYBRID', 250000.00, '2027-02-20', '2027-02-22', '2027-02-10', 150, 64),
(39, 'Innovator\'s Arena', 'Lucknow', 'HYBRID', 110000.00, '2027-02-25', '2027-02-27', '2027-02-15', 50, 43),
(40, 'Code Clash', 'Bhopal', 'OFFLINE', 85000.00, '2027-03-01', '2027-03-03', '2027-02-20', 150, 68),
(41, 'AgriTech Sprint', 'Vadodara', 'HYBRID', 175000.00, '2027-03-05', '2027-03-07', '2027-02-23', 100, 14),
(42, 'SpaceHack India', 'Bangalore', 'ONLINE', 700000.00, '2027-03-10', '2027-03-12', '2027-02-28', 400, 232),
(43, 'GameDev Jam', 'Hyderabad', 'ONLINE', 210000.00, '2027-03-15', '2027-03-17', '2027-03-05', 100, 64),
(44, 'EcoHack Challenge', 'Pune', 'HYBRID', 140000.00, '2027-03-20', '2027-03-22', '2027-03-10', 150, 27),
(45, 'IoT Innovators', 'Mumbai', 'HYBRID', 275000.00, '2027-03-25', '2027-03-27', '2027-03-15', 250, 217),
(46, 'Women in Tech Hack', 'Delhi', 'OFFLINE', 320000.00, '2027-04-01', '2027-04-03', '2027-03-20', 200, 39),
(47, 'Code Nexus', 'Ahmedabad', 'OFFLINE', 95000.00, '2027-04-05', '2027-04-07', '2027-03-25', 75, 69),
(48, 'AI for Good', 'Kolkata', 'HYBRID', 350000.00, '2027-04-10', '2027-04-12', '2027-03-30', 150, 82),
(49, 'Startup Sprint', 'Chandigarh', 'OFFLINE', 200000.00, '2027-04-15', '2027-04-17', '2027-04-05', 50, 23),
(50, 'Hack Beyond Borders', 'Kochi', 'HYBRID', 160000.00, '2027-04-20', '2027-04-22', '2027-04-10', 100, 30),
(51, 'Code Odyssey', 'Ahmedabad', 'ONLINE', 120000.00, '2027-04-25', '2027-04-27', '2027-04-15', 150, 20),
(52, 'Neural Nexus', 'Bangalore', 'ONLINE', 550000.00, '2027-05-01', '2027-05-03', '2027-04-20', 600, 70),
(53, 'VisionAI Challenge', 'Hyderabad', 'HYBRID', 375000.00, '2027-05-05', '2027-05-07', '2027-04-25', 200, 32),
(54, 'ByteCraft Hackathon', 'Surat', 'OFFLINE', 95000.00, '2027-05-10', '2027-05-12', '2027-04-30', 150, 42),
(55, 'CloudVerse Challenge', 'Pune', 'ONLINE', 275000.00, '2027-05-15', '2027-05-17', '2027-05-05', 300, 108),
(56, 'Cyber Fortress', 'Delhi', 'HYBRID', 450000.00, '2027-05-20', '2027-05-22', '2027-05-10', 200, 182),
(57, 'HackOrbit', 'Mumbai', 'ONLINE', 180000.00, '2027-05-25', '2027-05-27', '2027-05-15', 100, 56),
(58, 'Quantum Coders Cup', 'Noida', 'HYBRID', 650000.00, '2027-06-01', '2027-06-03', '2027-05-20', 600, 123),
(59, 'GreenByte Challenge', 'Indore', 'ONLINE', 140000.00, '2027-06-05', '2027-06-07', '2027-05-25', 50, 21),
(60, 'HealthSync Hack', 'Chennai', 'ONLINE', 250000.00, '2027-06-10', '2027-06-12', '2027-05-30', 150, 58),
(61, 'FinHack Pro', 'Ahmedabad', 'OFFLINE', 320000.00, '2027-06-15', '2027-06-17', '2027-06-05', 150, 18),
(62, 'OpenHack India', 'Jaipur', 'OFFLINE', 110000.00, '2027-06-20', '2027-06-22', '2027-06-10', 50, 14),
(63, 'DevFusion', 'Vadodara', 'ONLINE', 175000.00, '2027-06-25', '2027-06-27', '2027-06-15', 50, 21),
(64, 'BuildX Challenge', 'Nagpur', 'ONLINE', 125000.00, '2027-07-01', '2027-07-03', '2027-06-20', 75, 35),
(65, 'DataForge Hackathon', 'Bangalore', 'OFFLINE', 420000.00, '2027-07-05', '2027-07-07', '2027-06-25', 200, 138),
(66, 'Code Velocity', 'Lucknow', 'ONLINE', 100000.00, '2027-07-10', '2027-07-12', '2027-06-30', 150, 149),
(67, 'FutureTech Sprint', 'Hyderabad', 'OFFLINE', 280000.00, '2027-07-15', '2027-07-17', '2027-07-05', 300, 208),
(68, 'SecureSphere Hack', 'Delhi', 'ONLINE', 390000.00, '2027-07-20', '2027-07-22', '2027-07-10', 150, 110),
(69, 'WebNova Challenge', 'Pune', 'OFFLINE', 160000.00, '2027-07-25', '2027-07-27', '2027-07-15', 120, 59),
(70, 'AI Innovision', 'Mumbai', 'HYBRID', 500000.00, '2027-08-01', '2027-08-03', '2027-07-20', 150, 25),
(71, 'Smart Mobility Hack', 'Kochi', 'ONLINE', 220000.00, '2027-08-05', '2027-08-07', '2027-07-25', 100, 13),
(72, 'Hack Matrix', 'Ahmedabad', 'ONLINE', 135000.00, '2027-08-10', '2027-08-12', '2027-07-30', 75, 68),
(73, 'DeepCode Arena', 'Bangalore', 'OFFLINE', 360000.00, '2027-08-15', '2027-08-17', '2027-08-05', 300, 93),
(74, 'IoT Builders League', 'Hyderabad', 'ONLINE', 240000.00, '2027-08-20', '2027-08-22', '2027-08-10', 75, 9),
(75, 'CodeGalaxy Finals', 'Mumbai', 'OFFLINE', 800000.00, '2027-08-25', '2027-08-27', '2027-08-15', 300, 25),
(76, 'SkyNet Innovation Challenge', 'Delhi', 'OFFLINE', 350000.00, '2027-09-01', '2027-09-03', '2027-08-20', 150, 23),
(77, 'RoboForge Championship', 'Pune', 'HYBRID', 280000.00, '2027-09-05', '2027-09-07', '2027-08-25', 200, 42),
(78, 'HackSphere', 'Ahmedabad', 'OFFLINE', 125000.00, '2027-09-10', '2027-09-12', '2027-08-30', 120, 27),
(79, 'Pixel Perfect Hackathon', 'Mumbai', 'HYBRID', 150000.00, '2027-09-15', '2027-09-17', '2027-09-05', 50, 10),
(80, 'CodeWave Challenge', 'Bangalore', 'OFFLINE', 250000.00, '2027-09-20', '2027-09-22', '2027-09-10', 120, 33),
(81, 'Neural Hack League', 'Hyderabad', 'HYBRID', 475000.00, '2027-09-25', '2027-09-27', '2027-09-15', 300, 146),
(82, 'Blockchain Builders Summit', 'Noida', 'OFFLINE', 550000.00, '2027-10-01', '2027-10-03', '2027-09-20', 600, 158),
(83, 'HackArena', 'Chennai', 'ONLINE', 175000.00, '2027-10-05', '2027-10-07', '2027-09-25', 75, 7),
(84, 'Smart India Innovators', 'Ahmedabad', 'OFFLINE', 300000.00, '2027-10-10', '2027-10-12', '2027-09-30', 150, 80),
(85, 'CloudOps Masters', 'Pune', 'ONLINE', 240000.00, '2027-10-15', '2027-10-17', '2027-10-05', 150, 122),
(86, 'Cyber Sentinel Cup', 'Delhi', 'OFFLINE', 450000.00, '2027-10-20', '2027-10-22', '2027-10-10', 200, 14),
(87, 'EcoTech Revolution', 'Surat', 'HYBRID', 180000.00, '2027-10-25', '2027-10-27', '2027-10-15', 50, 11),
(88, 'AR/VR BuildFest', 'Kochi', 'ONLINE', 325000.00, '2027-11-01', '2027-11-03', '2027-10-20', 150, 60),
(89, 'Code Titans League', 'Jaipur', 'OFFLINE', 135000.00, '2027-11-05', '2027-11-07', '2027-10-25', 150, 64),
(90, 'FinVision Hackathon', 'Mumbai', 'OFFLINE', 400000.00, '2027-11-10', '2027-11-12', '2027-10-30', 150, 20),
(91, 'BioTech Innovate', 'Chandigarh', 'OFFLINE', 260000.00, '2027-11-15', '2027-11-17', '2027-11-05', 250, 239),
(92, 'DevSprint X', 'Vadodara', 'ONLINE', 95000.00, '2027-11-20', '2027-11-22', '2027-11-10', 100, 30),
(93, 'HackGenesis', 'Nagpur', 'ONLINE', 145000.00, '2027-11-25', '2027-11-27', '2027-11-15', 75, 38),
(94, 'Quantum Minds Challenge', 'Bangalore', 'OFFLINE', 700000.00, '2027-12-01', '2027-12-03', '2027-11-20', 300, 4),
(95, 'AgriNova Hackathon', 'Indore', 'OFFLINE', 210000.00, '2027-12-05', '2027-12-07', '2027-11-25', 150, 30),
(96, 'CodeXtreme Finals', 'Hyderabad', 'ONLINE', 850000.00, '2027-12-10', '2027-12-12', '2027-11-30', 400, 259),
(97, 'NextWave Developers Cup', 'Ahmedabad', 'ONLINE', 175000.00, '2027-12-15', '2027-12-17', '2027-12-05', 100, 8),
(98, 'Digital Frontier Challenge', 'Lucknow', 'HYBRID', 230000.00, '2027-12-20', '2027-12-22', '2027-12-10', 100, 36),
(99, 'HackFusion Global', 'Bangalore', 'ONLINE', 950000.00, '2028-01-05', '2028-01-07', '2027-12-20', 500, 315),
(112, 'day', 'surat', 'ONLINE', 50000.00, '2026-02-01', '2026-02-01', '2026-02-01', 500, 1);

-- --------------------------------------------------------

--
-- Table structure for table `hackathonskillrequired`
--

CREATE TABLE `hackathonskillrequired` (
  `hackathon_id` int(11) NOT NULL,
  `skill_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `hackathonskillrequired`
--

INSERT INTO `hackathonskillrequired` (`hackathon_id`, `skill_id`) VALUES
(1, 5),
(1, 12),
(1, 25),
(2, 8),
(2, 19),
(2, 34),
(3, 2),
(3, 15),
(3, 41),
(4, 7),
(4, 21),
(4, 38),
(5, 10),
(5, 18),
(5, 29),
(6, 3),
(6, 14),
(6, 44),
(7, 6),
(7, 22),
(7, 37),
(8, 11),
(8, 26),
(8, 48),
(9, 1),
(9, 17),
(9, 31),
(10, 9),
(10, 24),
(10, 42),
(11, 13),
(11, 27),
(11, 50),
(12, 4),
(12, 20),
(12, 35),
(13, 16),
(13, 28),
(13, 46),
(14, 5),
(14, 23),
(14, 39),
(15, 7),
(15, 18),
(15, 53),
(16, 12),
(16, 30),
(16, 45),
(17, 2),
(17, 25),
(17, 36),
(18, 8),
(18, 19),
(18, 54),
(19, 14),
(19, 33),
(19, 47),
(20, 11),
(20, 22),
(20, 58),
(21, 6),
(21, 24),
(21, 40),
(22, 15),
(22, 29),
(22, 49),
(23, 1),
(23, 17),
(23, 43),
(24, 10),
(24, 26),
(24, 55),
(25, 9),
(25, 21),
(25, 32),
(26, 13),
(26, 34),
(26, 59),
(27, 4),
(27, 18),
(27, 37),
(28, 16),
(28, 27),
(28, 52),
(29, 3),
(29, 20),
(29, 41),
(30, 7),
(30, 31),
(30, 44),
(31, 12),
(31, 23),
(31, 38),
(32, 5),
(32, 19),
(32, 50),
(33, 8),
(33, 28),
(33, 35),
(34, 2),
(34, 24),
(34, 46),
(35, 11),
(35, 30),
(35, 57),
(36, 6),
(36, 18),
(36, 42),
(37, 14),
(37, 26),
(37, 33),
(38, 9),
(38, 22),
(38, 48),
(39, 1),
(39, 27),
(39, 53),
(40, 15),
(40, 29),
(40, 39),
(41, 4),
(41, 17),
(41, 45),
(42, 13),
(42, 20),
(42, 56),
(43, 7),
(43, 31),
(43, 47),
(44, 10),
(44, 25),
(44, 36),
(45, 3),
(45, 21),
(45, 51),
(46, 16),
(46, 28),
(46, 40),
(47, 5),
(47, 24),
(47, 58),
(48, 8),
(48, 19),
(48, 43),
(49, 2),
(49, 32),
(49, 54),
(50, 11),
(50, 23),
(50, 37),
(51, 6),
(51, 18),
(51, 49),
(52, 14),
(52, 27),
(52, 41),
(53, 9),
(53, 20),
(53, 55),
(54, 1),
(54, 30),
(54, 46),
(55, 12),
(55, 26),
(55, 38),
(56, 4),
(56, 22),
(56, 52),
(57, 15),
(57, 29),
(57, 44),
(58, 7),
(58, 17),
(58, 57),
(59, 10),
(59, 24),
(59, 35),
(60, 3),
(60, 31),
(60, 48),
(61, 16),
(61, 19),
(61, 42),
(62, 5),
(62, 28),
(62, 53),
(63, 8),
(63, 21),
(63, 39),
(64, 2),
(64, 25),
(64, 50),
(65, 11),
(65, 18),
(65, 45),
(66, 6),
(66, 27),
(66, 36),
(67, 14),
(67, 20),
(67, 58),
(68, 9),
(68, 23),
(68, 47),
(69, 1),
(69, 30),
(69, 41),
(70, 13),
(70, 24),
(70, 54),
(71, 4),
(71, 19),
(71, 37),
(72, 15),
(72, 22),
(72, 49),
(73, 7),
(73, 28),
(73, 56),
(74, 10),
(74, 17),
(74, 43),
(75, 3),
(75, 31),
(75, 40),
(76, 16),
(76, 26),
(76, 51),
(77, 5),
(77, 20),
(77, 59),
(78, 8),
(78, 29),
(78, 46),
(79, 2),
(79, 23),
(79, 35),
(80, 11),
(80, 18),
(80, 52),
(81, 6),
(81, 27),
(81, 44),
(82, 14),
(82, 21),
(82, 57),
(83, 9),
(83, 30),
(83, 38),
(84, 1),
(84, 24),
(84, 48),
(85, 12),
(85, 19),
(85, 55),
(86, 4),
(86, 28),
(86, 42),
(87, 15),
(87, 17),
(87, 50),
(88, 7),
(88, 26),
(88, 39),
(89, 10),
(89, 20),
(89, 53),
(90, 3),
(90, 22),
(90, 45),
(91, 16),
(91, 31),
(91, 36),
(92, 5),
(92, 23),
(92, 58),
(93, 8),
(93, 18),
(93, 47),
(94, 2),
(94, 27),
(94, 41),
(95, 11),
(95, 24),
(95, 54),
(96, 6),
(96, 29),
(96, 37),
(97, 14),
(97, 21),
(97, 49),
(98, 9),
(98, 30),
(98, 56),
(99, 1),
(99, 25),
(99, 43),
(100, 13),
(100, 20),
(100, 59);

-- --------------------------------------------------------

--
-- Table structure for table `organization`
--

CREATE TABLE `organization` (
  `organization_id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(50) NOT NULL,
  `contact_person` varchar(20) NOT NULL,
  `phone` varchar(10) NOT NULL,
  `website` varchar(100) NOT NULL,
  `organization_type` varchar(50) NOT NULL,
  `city` varchar(20) NOT NULL,
  `organization_name` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `organization`
--

INSERT INTO `organization` (`organization_id`, `email`, `password`, `contact_person`, `phone`, `website`, `organization_type`, `city`, `organization_name`) VALUES
(1, 'org1@gmail.com', 'pass1', 'Aarav Shah', '9876500001', 'www.techspark.com', 'Private', 'Ahmedabad', 'TechSpark Solutions'),
(2, 'org2@gmail.com', 'pass2', 'Diya Patel', '9876500002', 'www.codehub.com', 'Startup', 'Surat', 'CodeHub Technologies'),
(3, 'org3@gmail.com', 'pass3', 'Vivaan Mehta', '9876500003', 'www.innovatex.com', 'Private', 'Vadodara', 'InnovaTex'),
(4, 'org4@gmail.com', 'pass4', 'Anaya Desai', '9876500004', 'www.futurelabs.com', 'Educational', 'Rajkot', 'Future Labs'),
(5, 'org5@gmail.com', 'pass5', 'Krish Joshi', '9876500005', 'www.greenworld.org', 'NGO', 'Bhavnagar', 'Green World Foundati'),
(6, 'org6@gmail.com', 'pass6', 'Riya Shah', '9876500006', 'www.smartindia.com', 'Government', 'Gandhinagar', 'Smart India Mission'),
(7, 'org7@gmail.com', 'pass7', 'Arjun Patel', '9876500007', 'www.techwave.com', 'Private', 'Ahmedabad', 'TechWave Pvt Ltd'),
(8, 'org8@gmail.com', 'pass8', 'Meera Trivedi', '9876500008', 'www.nexgen.com', 'Startup', 'Surat', 'NextGen Solutions'),
(9, 'org9@gmail.com', 'pass9', 'Kabir Bhatt', '9876500009', 'www.cloudcore.com', 'Private', 'Vadodara', 'CloudCore'),
(10, 'org10@gmail.com', 'pass10', 'Siya Dave', '9876500010', 'www.learnhub.edu', 'Educational', 'Rajkot', 'LearnHub Institute'),
(11, 'org11@gmail.com', 'pass11', 'Rahul Shah', '9876500011', 'www.visiontech.com', 'Private', 'Ahmedabad', 'Vision Tech'),
(12, 'org12@gmail.com', 'pass12', 'Priya Patel', '9876500012', 'www.bluecode.com', 'Startup', 'Surat', 'BlueCode'),
(13, 'org13@gmail.com', 'pass13', 'Karan Joshi', '9876500013', 'www.aiworks.com', 'Private', 'Vadodara', 'AI Works'),
(14, 'org14@gmail.com', 'pass14', 'Nisha Mehta', '9876500014', 'www.edutech.edu', 'Educational', 'Rajkot', 'EduTech Academy'),
(15, 'org15@gmail.com', 'pass15', 'Yash Patel', '9876500015', 'www.helpinghands.org', 'NGO', 'Bhavnagar', 'Helping Hands'),
(16, 'org16@gmail.com', 'pass16', 'Sneha Shah', '9876500016', 'www.digitalindia.gov', 'Government', 'Gandhinagar', 'Digital India Cell'),
(17, 'org17@gmail.com', 'pass17', 'Rohan Desai', '9876500017', 'www.coderush.com', 'Private', 'Ahmedabad', 'CodeRush'),
(18, 'org18@gmail.com', 'pass18', 'Isha Patel', '9876500018', 'www.appforge.com', 'Startup', 'Surat', 'AppForge'),
(19, 'org19@gmail.com', 'pass19', 'Dhruv Shah', '9876500019', 'www.datagen.com', 'Private', 'Vadodara', 'DataGen'),
(20, 'org20@gmail.com', 'pass20', 'Mahi Trivedi', '9876500020', 'www.skillhub.edu', 'Educational', 'Rajkot', 'SkillHub'),
(22, 'org22@gmail.com', 'pass22', 'Anvi Shah', '9876500022', 'www.innovision.com', 'Startup', 'Surat', 'Innovision'),
(23, 'org23@gmail.com', 'pass23', 'Parth Patel', '9876500023', 'www.softlabs.com', 'Private', 'Vadodara', 'SoftLabs'),
(24, 'org24@gmail.com', 'pass24', 'Kiara Joshi', '9876500024', 'www.knowledge.edu', 'Educational', 'Rajkot', 'Knowledge Academy'),
(25, 'org25@gmail.com', 'pass25', 'Dev Shah', '9876500025', 'www.care.org', 'NGO', 'Bhavnagar', 'Care Foundation'),
(26, 'org26@gmail.com', 'pass26', 'Aditi Mehta', '9876500026', 'www.govconnect.gov', 'Government', 'Gandhinagar', 'Gov Connect'),
(27, 'org27@gmail.com', 'pass27', 'Harsh Patel', '9876500027', 'www.techzone.com', 'Private', 'Ahmedabad', 'TechZone'),
(28, 'org28@gmail.com', 'pass28', 'Riddhi Shah', '9876500028', 'www.startupx.com', 'Startup', 'Surat', 'StartupX'),
(29, 'org29@gmail.com', 'pass29', 'Manav Desai', '9876500029', 'www.infotech.com', 'Private', 'Vadodara', 'InfoTech'),
(30, 'org30@gmail.com', 'pass30', 'Pooja Patel', '9876500030', 'www.futureedu.edu', 'Educational', 'Rajkot', 'Future Education'),
(31, 'org31@gmail.com', 'pass31', 'Nirav Shah', '9876500031', 'www.logicsoft.com', 'Private', 'Ahmedabad', 'LogicSoft'),
(32, 'org32@gmail.com', 'pass32', 'Khushi Patel', '9876500032', 'www.sparktech.com', 'Startup', 'Surat', 'SparkTech'),
(33, 'org33@gmail.com', 'pass33', 'Jatin Mehta', '9876500033', 'www.webnova.com', 'Private', 'Vadodara', 'WebNova'),
(34, 'org34@gmail.com', 'pass34', 'Heena Shah', '9876500034', 'www.collegehub.edu', 'Educational', 'Rajkot', 'CollegeHub'),
(35, 'org35@gmail.com', 'pass35', 'Aakash Patel', '9876500035', 'www.socialhelp.org', 'NGO', 'Bhavnagar', 'Social Help Trust'),
(36, 'org36@gmail.com', 'pass36', 'Neha Joshi', '9876500036', 'www.smartcity.gov', 'Government', 'Gandhinagar', 'Smart City Office'),
(37, 'org37@gmail.com', 'pass37', 'Sahil Shah', '9876500037', 'www.byteworks.com', 'Private', 'Ahmedabad', 'ByteWorks'),
(38, 'org38@gmail.com', 'pass38', 'Tanvi Mehta', '9876500038', 'www.futureapps.com', 'Startup', 'Surat', 'Future Apps'),
(39, 'org39@gmail.com', 'pass39', 'Jay Patel', '9876500039', 'www.digisol.com', 'Private', 'Vadodara', 'DigiSol'),
(40, 'org40@gmail.com', 'pass40', 'Rupal Shah', '9876500040', 'www.campus.edu', 'Educational', 'Rajkot', 'Campus Academy'),
(41, 'org41@gmail.com', 'pass41', 'Aarohi Patel', '9876500041', 'www.alpha.com', 'Private', 'Ahmedabad', 'Alpha Technologies'),
(42, 'org42@gmail.com', 'pass42', 'Vihaan Shah', '9876500042', 'www.beta.com', 'Startup', 'Surat', 'Beta Innovations'),
(43, 'org43@gmail.com', 'pass43', 'Mitali Desai', '9876500043', 'www.gamma.com', 'Private', 'Vadodara', 'Gamma Solutions'),
(44, 'org44@gmail.com', 'pass44', 'Darsh Patel', '9876500044', 'www.delta.edu', 'Educational', 'Rajkot', 'Delta Institute'),
(45, 'org45@gmail.com', 'pass45', 'Nidhi Shah', '9876500045', 'www.ngohelp.org', 'NGO', 'Bhavnagar', 'NGO Help'),
(46, 'org46@gmail.com', 'pass46', 'Rakesh Patel', '9876500046', 'www.govtech.gov', 'Government', 'Gandhinagar', 'GovTech'),
(47, 'org47@gmail.com', 'pass47', 'Ishan Mehta', '9876500047', 'www.techplus.com', 'Private', 'Ahmedabad', 'Tech Plus'),
(48, 'org48@gmail.com', 'pass48', 'Palak Shah', '9876500048', 'www.creative.com', 'Startup', 'Surat', 'Creative Labs'),
(49, 'org49@gmail.com', 'pass49', 'Om Patel', '9876500049', 'www.datalink.com', 'Private', 'Vadodara', 'DataLink'),
(50, 'org50@gmail.com', 'pass50', 'Simran Shah', '9876500050', 'www.school.edu', 'Educational', 'Rajkot', 'SchoolTech'),
(51, 'info51@techspark.org', 'pass123', 'Aarav Shah', '9876500051', 'www.techspark51.com', 'Private', 'Ahmedabad', 'TechSpark Solutions'),
(52, 'info52@innovatehub.org', 'pass123', 'Diya Patel', '9876500052', 'www.innovatehub52.com', 'Startup', 'Surat', 'Innovate Hub'),
(53, 'info53@codenest.org', 'pass123', 'Rohan Mehta', '9876500053', 'www.codenest53.com', 'Private', 'Vadodara', 'CodeNest Pvt Ltd'),
(54, 'info54@futurelabs.org', 'pass123', 'Ananya Joshi', '9876500054', 'www.futurelabs54.com', 'NGO', 'Rajkot', 'Future Labs'),
(55, 'info55@nextgen.org', 'pass123', 'Karan Desai', '9876500055', 'www.nextgen55.com', 'College', 'Mumbai', 'NextGen Institute'),
(56, 'info56@digitaledge.org', 'pass123', 'Priya Shah', '9876500056', 'www.digitaledge56.com', 'Private', 'Delhi', 'Digital Edge'),
(57, 'info57@smartbyte.org', 'pass123', 'Raj Patel', '9876500057', 'www.smartbyte57.com', 'Startup', 'Pune', 'SmartByte'),
(58, 'info58@techvision.org', 'pass123', 'Neha Trivedi', '9876500058', 'www.techvision58.com', 'Private', 'Bengaluru', 'TechVision'),
(59, 'info59@alphatech.org', 'pass123', 'Yash Modi', '9876500059', 'www.alphatech59.com', 'College', 'Hyderabad', 'Alpha Tech'),
(60, 'info60@codewave.org', 'pass123', 'Krisha Shah', '9876500060', 'www.codewave60.com', 'Government', 'Chennai', 'CodeWave'),
(61, 'info61@infotech.org', 'pass123', 'Rahul Joshi', '9876500061', 'www.infotech61.com', 'Private', 'Jaipur', 'InfoTech Solutions'),
(62, 'info62@cybercore.org', 'pass123', 'Pooja Mehta', '9876500062', 'www.cybercore62.com', 'Startup', 'Lucknow', 'CyberCore'),
(63, 'info63@datasphere.org', 'pass123', 'Harsh Patel', '9876500063', 'www.datasphere63.com', 'Private', 'Kolkata', 'DataSphere'),
(64, 'info64@logiclabs.org', 'pass123', 'Mihir Shah', '9876500064', 'www.logiclabs64.com', 'NGO', 'Indore', 'Logic Labs'),
(65, 'info65@futurecode.org', 'pass123', 'Sneha Patel', '9876500065', 'www.futurecode65.com', 'Private', 'Ahmedabad', 'FutureCode'),
(66, 'info66@visiontech.org', 'pass123', 'Aakash Mehta', '9876500066', 'www.visiontech66.com', 'College', 'Surat', 'Vision Tech'),
(67, 'info67@hackzone.org', 'pass123', 'Jiya Shah', '9876500067', 'www.hackzone67.com', 'Startup', 'Vadodara', 'HackZone'),
(68, 'info68@techpoint.org', 'pass123', 'Parth Desai', '9876500068', 'www.techpoint68.com', 'Private', 'Rajkot', 'TechPoint'),
(69, 'info69@codefactory.org', 'pass123', 'Nidhi Patel', '9876500069', 'www.codefactory69.com', 'Government', 'Mumbai', 'Code Factory'),
(70, 'info70@cloudhub.org', 'pass123', 'Dev Shah', '9876500070', 'www.cloudhub70.com', 'Private', 'Delhi', 'CloudHub'),
(71, 'info71@byteworks.org', 'pass123', 'Khushi Mehta', '9876500071', 'www.byteworks71.com', 'Startup', 'Pune', 'ByteWorks'),
(72, 'info72@innovision.org', 'pass123', 'Meet Patel', '9876500072', 'www.innovision72.com', 'Private', 'Bengaluru', 'InnoVision'),
(73, 'info73@digitalmind.org', 'pass123', 'Riya Joshi', '9876500073', 'www.digitalmind73.com', 'College', 'Hyderabad', 'Digital Mind'),
(74, 'info74@greenlabs.org', 'pass123', 'Jay Shah', '9876500074', 'www.greenlabs74.com', 'NGO', 'Chennai', 'Green Labs'),
(75, 'info75@robotics.org', 'pass123', 'Ishita Patel', '9876500075', 'www.robotics75.com', 'Private', 'Jaipur', 'Robotics India'),
(76, 'info76@aifuture.org', 'pass123', 'Vivek Mehta', '9876500076', 'www.aifuture76.com', 'Startup', 'Lucknow', 'AI Future'),
(77, 'info77@softworld.org', 'pass123', 'Aditi Shah', '9876500077', 'www.softworld77.com', 'Private', 'Kolkata', 'SoftWorld'),
(78, 'info78@globalcode.org', 'pass123', 'Nirav Patel', '9876500078', 'www.globalcode78.com', 'Government', 'Indore', 'Global Code'),
(79, 'info79@techmasters.org', 'pass123', 'Riddhi Shah', '9876500079', 'www.techmasters79.com', 'Private', 'Ahmedabad', 'Tech Masters'),
(80, 'info80@futurebyte.org', 'pass123', 'Smit Patel', '9876500080', 'www.futurebyte80.com', 'College', 'Surat', 'FutureByte'),
(81, 'info81@braintech.org', 'pass123', 'Komal Mehta', '9876500081', 'www.braintech81.com', 'Startup', 'Vadodara', 'BrainTech'),
(82, 'info82@techworld.org', 'pass123', 'Dhruv Shah', '9876500082', 'www.techworld82.com', 'Private', 'Rajkot', 'TechWorld'),
(83, 'info83@digicode.org', 'pass123', 'Het Patel', '9876500083', 'www.digicode83.com', 'Private', 'Mumbai', 'DigiCode'),
(84, 'info84@innovators.org', 'pass123', 'Krunal Mehta', '9876500084', 'www.innovators84.com', 'NGO', 'Delhi', 'Innovators Foundatio'),
(85, 'info85@futurevision.org', 'pass123', 'Mansi Shah', '9876500085', 'www.futurevision85.com', 'Private', 'Pune', 'Future Vision'),
(86, 'info86@technova.org', 'pass123', 'Aryan Patel', '9876500086', 'www.technova86.com', 'Startup', 'Bengaluru', 'TechNova'),
(87, 'info87@codegen.org', 'pass123', 'Tanvi Mehta', '9876500087', 'www.codegen87.com', 'College', 'Hyderabad', 'CodeGen Institute'),
(88, 'info88@itworld.org', 'pass123', 'Ritesh Shah', '9876500088', 'www.itworld88.com', 'Private', 'Chennai', 'IT World'),
(89, 'info89@visionary.org', 'pass123', 'Nisha Patel', '9876500089', 'www.visionary89.com', 'Government', 'Jaipur', 'Visionary Tech'),
(90, 'info90@futureit.org', 'pass123', 'Sahil Mehta', '9876500090', 'www.futureit90.com', 'Private', 'Lucknow', 'Future IT'),
(91, 'info91@smarttech.org', 'pass123', 'Vidhi Shah', '9876500091', 'www.smarttech91.com', 'Startup', 'Kolkata', 'SmartTech'),
(92, 'info92@cloudtech.org', 'pass123', 'Manan Patel', '9876500092', 'www.cloudtech92.com', 'Private', 'Indore', 'CloudTech'),
(93, 'info93@elitecode.org', 'pass123', 'Pallavi Mehta', '9876500093', 'www.elitecode93.com', 'College', 'Ahmedabad', 'Elite Code'),
(94, 'info94@logicsoft.org', 'pass123', 'Tushar Shah', '9876500094', 'www.logicsoft94.com', 'Private', 'Surat', 'LogicSoft'),
(95, 'info95@cybertech.org', 'pass123', 'Bhavya Patel', '9876500095', 'www.cybertech95.com', 'Government', 'Vadodara', 'CyberTech India'),
(96, 'info96@nextvision.org', 'pass123', 'Ankit Mehta', '9876500096', 'www.nextvision96.com', 'Startup', 'Rajkot', 'Next Vision'),
(97, 'info97@digitalhub.org', 'pass123', 'Meera Shah', '9876500097', 'www.digitalhub97.com', 'Private', 'Mumbai', 'Digital Hub'),
(98, 'info98@codecraft.org', 'pass123', 'Arjun Patel', '9876500098', 'www.codecraft98.com', 'College', 'Delhi', 'CodeCraft'),
(99, 'info99@futurelab.org', 'pass123', 'Kavya Mehta', '9876500099', 'www.futurelab99.com', 'NGO', 'Pune', 'FutureLab Foundation'),
(100, 'info100@techfusion.org', 'pass123', 'Yuvraj Shah', '9876500100', 'www.techfusion100.com', 'Private', 'Bengaluru', 'TechFusion'),
(101, 'h@gmail.com', 'Het@1234', 'het', '9023255320', 'wefwwef', 'Company', 'surat', 'het');

-- --------------------------------------------------------

--
-- Table structure for table `organizationhackthone`
--

CREATE TABLE `organizationhackthone` (
  `hackthone_id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `organizationhackthone`
--

INSERT INTO `organizationhackthone` (`hackthone_id`, `organization_id`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20),
(21, 21),
(22, 22),
(23, 23),
(24, 24),
(25, 25),
(26, 26),
(27, 27),
(28, 28),
(29, 29),
(30, 30),
(31, 31),
(32, 32),
(33, 33),
(34, 34),
(35, 35),
(36, 36),
(37, 37),
(38, 38),
(39, 39),
(40, 40),
(41, 41),
(42, 42),
(43, 43),
(44, 44),
(45, 45),
(46, 46),
(47, 47),
(48, 48),
(49, 49),
(50, 50),
(51, 51),
(52, 52),
(53, 53),
(54, 54),
(55, 55),
(56, 56),
(57, 57),
(58, 58),
(59, 59),
(60, 60),
(61, 61),
(62, 62),
(63, 63),
(64, 64),
(65, 65),
(66, 66),
(67, 67),
(68, 68),
(69, 69),
(70, 70),
(71, 71),
(72, 72),
(73, 73),
(74, 74),
(75, 75),
(76, 76),
(77, 77),
(78, 78),
(79, 79),
(80, 80),
(81, 81),
(82, 82),
(83, 83),
(84, 84),
(85, 85),
(86, 86),
(87, 87),
(88, 88),
(89, 89),
(90, 90),
(91, 91),
(92, 92),
(93, 93),
(94, 94),
(95, 95),
(96, 96),
(97, 97),
(98, 98),
(99, 99),
(100, 100),
(114, 101);

-- --------------------------------------------------------

--
-- Table structure for table `organization_auditlog`
--

CREATE TABLE `organization_auditlog` (
  `audit_id` int(11) NOT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `hackathon_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `location_city` varchar(100) DEFAULT NULL,
  `mode` varchar(20) DEFAULT NULL,
  `prize_pool` decimal(12,2) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `registration_deadline` date DEFAULT NULL,
  `max_participants` int(11) DEFAULT NULL,
  `current_participants` int(11) DEFAULT NULL,
  `action` varchar(30) DEFAULT NULL,
  `action_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `organization_auditlog`
--

INSERT INTO `organization_auditlog` (`audit_id`, `organization_id`, `hackathon_id`, `title`, `location_city`, `mode`, `prize_pool`, `start_date`, `end_date`, `registration_deadline`, `max_participants`, `current_participants`, `action`, `action_time`) VALUES
(1, 1, 110, 'wew', 'wea', 'ONLINE', 5000.00, '2026-01-02', '2026-01-02', '2026-01-02', 50, 0, 'DELETE', '2026-08-04 10:20:01'),
(2, 3, 111, 'het', 'surat', 'ONLINE', 50000.00, '2026-02-01', '2026-02-01', '2026-02-01', 500, 0, 'INSERT', '2026-08-05 04:42:17'),
(3, 3, 112, 'day', 'surat', 'ONLINE', 50000.00, '2026-02-01', '2026-02-01', '2026-02-01', 500, 0, 'INSERT', '2026-08-05 04:43:40'),
(4, 3, 113, 'may', 'surat', 'ONLINE', 50000.00, '2026-02-01', '2026-02-01', '2026-02-01', 500, 0, 'INSERT', '2026-08-05 04:46:54'),
(5, 3, 113, 'may', 'surat', 'ONLINE', 50000.00, '2026-02-01', '2026-02-01', '2026-02-01', 500, 0, 'DELETE', '2026-08-05 04:47:12'),
(6, 101, 114, 'code with het', 'surat', 'ONLINE', 400000.00, '2026-08-01', '2026-08-01', '2026-08-01', 2000, 0, 'INSERT', '2026-08-07 04:45:10');

-- --------------------------------------------------------

--
-- Table structure for table `recommendationlog`
--

CREATE TABLE `recommendationlog` (
  `recommendation_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `hackathon_id` int(11) NOT NULL,
  `match_score` decimal(5,2) NOT NULL CHECK (`match_score` between 0 and 100),
  `reason` varchar(255) NOT NULL,
  `recommended_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `recommendationlog`
--

INSERT INTO `recommendationlog` (`recommendation_id`, `user_id`, `hackathon_id`, `match_score`, `reason`, `recommended_at`) VALUES
(1, 1, 51, 87.50, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(2, 1, 40, 66.67, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(3, 1, 1, 62.50, 'Matches 1 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(4, 2, 25, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(5, 2, 38, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(6, 2, 97, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(7, 3, 96, 55.00, 'Matches 1 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(8, 3, 2, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(9, 3, 27, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(10, 4, 51, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(11, 4, 40, 66.67, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(12, 4, 16, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(13, 5, 97, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(14, 5, 2, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(15, 5, 11, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(16, 6, 36, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(17, 6, 71, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(18, 6, 42, 55.00, 'Matches 1 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(19, 7, 30, 87.50, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(20, 7, 16, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(21, 7, 17, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(22, 8, 15, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(23, 8, 24, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(24, 8, 50, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(25, 9, 29, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(26, 9, 83, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(27, 9, 99, 60.00, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(28, 10, 4, 66.67, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(29, 10, 24, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(30, 10, 32, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(31, 11, 44, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(32, 11, 1, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(33, 11, 22, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(34, 12, 31, 62.50, 'Matches 1 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(35, 12, 2, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(36, 12, 19, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(37, 13, 53, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(38, 13, 73, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(39, 13, 15, 58.33, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(40, 14, 8, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(41, 14, 43, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(42, 14, 21, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(43, 15, 12, 100.00, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(44, 15, 4, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(45, 15, 24, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(46, 16, 3, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(47, 16, 17, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(48, 16, 26, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(49, 17, 46, 87.50, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(50, 17, 11, 66.67, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(51, 17, 2, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(52, 18, 2, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(53, 18, 19, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(54, 18, 27, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(55, 19, 10, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(56, 19, 23, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(57, 19, 34, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(58, 20, 3, 80.00, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(59, 20, 75, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(60, 20, 96, 70.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(61, 21, 39, 62.50, 'Matches 1 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(62, 21, 63, 62.50, 'Matches 1 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(63, 21, 90, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(64, 22, 18, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(65, 22, 25, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(66, 22, 38, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(67, 23, 96, 70.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(68, 23, 26, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(69, 23, 61, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(70, 24, 5, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(71, 24, 20, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(72, 24, 28, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(73, 25, 56, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(74, 25, 68, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(75, 25, 8, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(76, 26, 99, 80.00, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(77, 26, 13, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(78, 26, 29, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(79, 27, 26, 87.50, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(80, 27, 61, 87.50, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(81, 27, 96, 70.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(82, 28, 79, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(83, 28, 57, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(84, 28, 9, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(85, 29, 23, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(86, 29, 93, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(87, 29, 10, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(88, 30, 46, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(89, 30, 97, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(90, 30, 2, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(91, 31, 88, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(92, 31, 18, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(93, 31, 38, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(94, 32, 12, 83.33, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(95, 32, 4, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(96, 32, 24, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(97, 33, 3, 80.00, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(98, 33, 75, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(99, 33, 96, 60.00, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(100, 34, 4, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(101, 34, 24, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(102, 34, 32, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(103, 35, 33, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(104, 35, 78, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(105, 35, 8, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(106, 36, 1, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(107, 36, 16, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(108, 36, 26, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(109, 37, 49, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(110, 37, 77, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(111, 37, 84, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(112, 38, 5, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(113, 38, 38, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(114, 38, 18, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(115, 39, 27, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(116, 39, 81, 70.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(117, 39, 46, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(118, 40, 31, 87.50, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(119, 40, 11, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(120, 40, 12, 50.00, 'Matches 0 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(121, 41, 1, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(122, 41, 26, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(123, 41, 51, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(124, 42, 74, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(125, 42, 67, 58.33, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(126, 42, 2, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(127, 43, 4, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(128, 43, 24, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(129, 43, 32, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(130, 44, 18, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(131, 44, 88, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(132, 44, 38, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(136, 46, 19, 100.00, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(137, 46, 54, 87.50, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(138, 46, 46, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(139, 47, 8, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(140, 47, 43, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(141, 47, 33, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(142, 48, 6, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(143, 48, 36, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(144, 48, 42, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(145, 49, 52, 80.00, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(146, 49, 70, 70.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(147, 49, 87, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(148, 50, 23, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(149, 50, 45, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(150, 50, 10, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(151, 51, 62, 66.67, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(152, 51, 2, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(153, 51, 97, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(154, 52, 94, 70.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(155, 52, 4, 66.67, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(156, 52, 24, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(157, 53, 1, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(158, 53, 3, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(159, 53, 16, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(160, 54, 77, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(161, 54, 6, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(162, 54, 14, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(163, 55, 7, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(164, 55, 18, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(165, 55, 38, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(166, 56, 43, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(167, 56, 8, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(168, 56, 21, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(169, 57, 94, 80.00, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(170, 57, 32, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(171, 57, 59, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(172, 58, 44, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(173, 58, 71, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(174, 58, 6, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(175, 59, 13, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(176, 59, 29, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(177, 59, 48, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(178, 60, 89, 87.50, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(179, 60, 11, 83.33, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(180, 60, 19, 83.33, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(181, 61, 10, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(182, 61, 23, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(183, 61, 34, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(184, 62, 12, 50.00, 'Matches 0 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(185, 62, 18, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(186, 62, 38, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(187, 63, 79, 62.50, 'Matches 1 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(188, 63, 3, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(189, 63, 8, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(190, 64, 4, 66.67, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(191, 64, 24, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(192, 64, 94, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(193, 65, 65, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(195, 65, 30, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(196, 66, 36, 62.50, 'Matches 1 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(197, 66, 44, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(198, 66, 15, 58.33, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(199, 67, 33, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(200, 67, 37, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(201, 67, 72, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(202, 68, 5, 37.50, 'Matches 1 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(203, 68, 34, 37.50, 'Matches 1 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(204, 68, 69, 37.50, 'Matches 1 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(205, 69, 66, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(206, 69, 31, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(207, 69, 11, 41.67, 'Matches 1 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(208, 70, 39, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(209, 70, 5, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(210, 70, 32, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(211, 71, 71, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(212, 71, 1, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(213, 71, 36, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(214, 72, 52, 80.00, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(215, 72, 70, 70.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(216, 72, 87, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(217, 73, 28, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(218, 73, 82, 70.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(219, 73, 42, 55.00, 'Matches 1 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(220, 74, 18, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(221, 74, 38, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(222, 74, 53, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(223, 75, 8, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(224, 75, 31, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(225, 75, 33, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(226, 76, 69, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(227, 76, 80, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(228, 76, 34, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(229, 77, 62, 66.67, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(230, 77, 97, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(231, 77, 1, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(232, 78, 14, 66.67, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(233, 78, 39, 62.50, 'Matches 1 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(234, 78, 63, 62.50, 'Matches 1 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(235, 79, 75, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(236, 79, 96, 60.00, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(237, 79, 15, 58.33, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(238, 80, 76, 70.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(239, 80, 41, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(240, 80, 7, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(241, 81, 4, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(242, 81, 24, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(243, 81, 37, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(244, 82, 12, 58.33, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(245, 82, 29, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(246, 82, 64, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(247, 83, 73, 62.50, 'Matches 1 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(248, 83, 81, 55.00, 'Matches 1 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(249, 83, 31, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(250, 84, 25, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(251, 84, 36, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(252, 84, 50, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(253, 85, 78, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(254, 85, 8, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(255, 85, 33, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(256, 86, 90, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(257, 86, 20, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(258, 86, 55, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(259, 87, 93, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(260, 87, 10, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(261, 87, 23, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(262, 88, 12, 50.00, 'Matches 0 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(263, 88, 71, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(264, 88, 20, 37.50, 'Matches 0 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(265, 89, 15, 58.33, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(266, 89, 70, 45.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(267, 89, 94, 45.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(268, 90, 11, 66.67, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(269, 90, 62, 66.67, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(270, 90, 2, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(271, 91, 64, 66.67, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(272, 91, 83, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(273, 91, 13, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(274, 92, 37, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(275, 92, 47, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(276, 92, 72, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(277, 93, 16, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(278, 93, 86, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(279, 93, 61, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(280, 94, 8, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(281, 94, 21, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(282, 94, 33, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(283, 95, 69, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(284, 95, 34, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(285, 95, 10, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(286, 96, 39, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(287, 96, 32, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(288, 96, 74, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(289, 97, 79, 50.00, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(290, 97, 25, 37.50, 'Matches 1 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(291, 97, 38, 37.50, 'Matches 1 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(292, 98, 12, 58.33, 'Matches 1 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(293, 98, 6, 37.50, 'Matches 1 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(294, 98, 17, 37.50, 'Matches 1 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(295, 99, 66, 62.50, 'Matches 2 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(296, 99, 31, 50.00, 'Matches 2 domain interest(s) and 0 required skill(s)', '2026-07-09 21:04:21'),
(297, 99, 97, 37.50, 'Matches 1 domain interest(s) and 1 required skill(s)', '2026-07-09 21:04:21'),
(298, 100, 51, 87.50, 'Matches 2 domain interest(s) and 3 required skill(s)', '2026-07-09 21:04:21'),
(299, 100, 40, 83.33, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21'),
(300, 100, 75, 75.00, 'Matches 2 domain interest(s) and 2 required skill(s)', '2026-07-09 21:04:21');

-- --------------------------------------------------------

--
-- Table structure for table `registration`
--

CREATE TABLE `registration` (
  `registration_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `hackathon_id` int(11) NOT NULL,
  `status` enum('REGISTERED','WAITLISTED','CANCELLED') NOT NULL,
  `waitlist_position` int(11) DEFAULT NULL,
  `registered_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `registration`
--

INSERT INTO `registration` (`registration_id`, `user_id`, `hackathon_id`, `status`, `waitlist_position`, `registered_at`) VALUES
(1, 1, 1, 'REGISTERED', NULL, '2026-01-01 10:00:00'),
(2, 2, 2, 'REGISTERED', NULL, '2026-01-02 10:00:00'),
(3, 3, 3, 'WAITLISTED', 1, '2026-01-03 10:00:00'),
(4, 4, 4, 'REGISTERED', NULL, '2026-01-04 10:00:00'),
(5, 5, 5, 'CANCELLED', NULL, '2026-01-05 10:00:00'),
(6, 6, 6, 'REGISTERED', NULL, '2026-01-06 10:00:00'),
(7, 7, 7, 'WAITLISTED', 2, '2026-01-07 10:00:00'),
(8, 8, 8, 'REGISTERED', NULL, '2026-01-08 10:00:00'),
(9, 9, 9, 'REGISTERED', NULL, '2026-01-09 10:00:00'),
(10, 10, 10, 'CANCELLED', NULL, '2026-01-10 10:00:00'),
(11, 11, 11, 'REGISTERED', NULL, '2026-01-11 10:00:00'),
(12, 12, 12, 'REGISTERED', NULL, '2026-01-12 10:00:00'),
(13, 13, 13, 'WAITLISTED', 3, '2026-01-13 10:00:00'),
(14, 14, 14, 'REGISTERED', NULL, '2026-01-14 10:00:00'),
(15, 15, 15, 'REGISTERED', NULL, '2026-01-15 10:00:00'),
(16, 16, 16, 'REGISTERED', NULL, '2026-01-16 10:00:00'),
(17, 17, 17, 'WAITLISTED', 4, '2026-01-17 10:00:00'),
(18, 18, 18, 'REGISTERED', NULL, '2026-01-18 10:00:00'),
(19, 19, 19, 'REGISTERED', NULL, '2026-01-19 10:00:00'),
(20, 20, 20, 'CANCELLED', NULL, '2026-01-20 10:00:00'),
(21, 21, 21, 'REGISTERED', NULL, '2026-01-21 10:00:00'),
(22, 22, 22, 'REGISTERED', NULL, '2026-01-22 10:00:00'),
(23, 23, 23, 'WAITLISTED', 5, '2026-01-23 10:00:00'),
(24, 24, 24, 'REGISTERED', NULL, '2026-01-24 10:00:00'),
(25, 25, 25, 'REGISTERED', NULL, '2026-01-25 10:00:00'),
(26, 26, 26, 'REGISTERED', NULL, '2026-01-26 10:00:00'),
(27, 27, 27, 'WAITLISTED', 6, '2026-01-27 10:00:00'),
(28, 28, 28, 'REGISTERED', NULL, '2026-01-28 10:00:00'),
(29, 29, 29, 'REGISTERED', NULL, '2026-01-29 10:00:00'),
(30, 30, 30, 'CANCELLED', NULL, '2026-01-30 10:00:00'),
(31, 31, 31, 'REGISTERED', NULL, '2026-01-31 10:00:00'),
(32, 32, 32, 'REGISTERED', NULL, '2026-02-01 10:00:00'),
(33, 33, 33, 'WAITLISTED', 7, '2026-02-02 10:00:00'),
(34, 34, 34, 'REGISTERED', NULL, '2026-02-03 10:00:00'),
(35, 35, 35, 'REGISTERED', NULL, '2026-02-04 10:00:00'),
(36, 36, 36, 'REGISTERED', NULL, '2026-02-05 10:00:00'),
(37, 37, 37, 'WAITLISTED', 8, '2026-02-06 10:00:00'),
(38, 38, 38, 'REGISTERED', NULL, '2026-02-07 10:00:00'),
(39, 39, 39, 'REGISTERED', NULL, '2026-02-08 10:00:00'),
(40, 40, 40, 'CANCELLED', NULL, '2026-02-09 10:00:00'),
(41, 41, 41, 'REGISTERED', NULL, '2026-02-10 10:00:00'),
(42, 42, 42, 'REGISTERED', NULL, '2026-02-11 10:00:00'),
(43, 43, 43, 'WAITLISTED', 9, '2026-02-12 10:00:00'),
(44, 44, 44, 'REGISTERED', NULL, '2026-02-13 10:00:00'),
(45, 45, 45, 'REGISTERED', NULL, '2026-02-14 10:00:00'),
(46, 46, 46, 'REGISTERED', NULL, '2026-02-15 10:00:00'),
(47, 47, 47, 'WAITLISTED', 10, '2026-02-16 10:00:00'),
(48, 48, 48, 'REGISTERED', NULL, '2026-02-17 10:00:00'),
(49, 49, 49, 'REGISTERED', NULL, '2026-02-18 10:00:00'),
(50, 50, 50, 'CANCELLED', NULL, '2026-02-19 10:00:00'),
(51, 51, 51, 'REGISTERED', NULL, '2026-02-20 10:00:00'),
(52, 52, 52, 'REGISTERED', NULL, '2026-02-21 10:00:00'),
(53, 53, 53, 'WAITLISTED', 11, '2026-02-22 10:00:00'),
(54, 54, 54, 'REGISTERED', NULL, '2026-02-23 10:00:00'),
(55, 55, 55, 'REGISTERED', NULL, '2026-02-24 10:00:00'),
(56, 56, 56, 'REGISTERED', NULL, '2026-02-25 10:00:00'),
(57, 57, 57, 'WAITLISTED', 12, '2026-02-26 10:00:00'),
(58, 58, 58, 'REGISTERED', NULL, '2026-02-27 10:00:00'),
(59, 59, 59, 'REGISTERED', NULL, '2026-02-28 10:00:00'),
(60, 60, 60, 'CANCELLED', NULL, '2026-03-01 10:00:00'),
(61, 61, 61, 'REGISTERED', NULL, '2026-03-02 10:00:00'),
(62, 62, 62, 'REGISTERED', NULL, '2026-03-03 10:00:00'),
(63, 63, 63, 'WAITLISTED', 13, '2026-03-04 10:00:00'),
(64, 64, 64, 'REGISTERED', NULL, '2026-03-05 10:00:00'),
(65, 65, 65, 'REGISTERED', NULL, '2026-03-06 10:00:00'),
(66, 66, 66, 'REGISTERED', NULL, '2026-03-07 10:00:00'),
(67, 67, 67, 'WAITLISTED', 14, '2026-03-08 10:00:00'),
(68, 68, 68, 'REGISTERED', NULL, '2026-03-09 10:00:00'),
(69, 69, 69, 'REGISTERED', NULL, '2026-03-10 10:00:00'),
(70, 70, 70, 'CANCELLED', NULL, '2026-03-11 10:00:00'),
(71, 71, 71, 'REGISTERED', NULL, '2026-03-12 10:00:00'),
(72, 72, 72, 'REGISTERED', NULL, '2026-03-13 10:00:00'),
(73, 73, 73, 'WAITLISTED', 15, '2026-03-14 10:00:00'),
(74, 74, 74, 'REGISTERED', NULL, '2026-03-15 10:00:00'),
(75, 75, 75, 'REGISTERED', NULL, '2026-03-16 10:00:00'),
(76, 76, 76, 'REGISTERED', NULL, '2026-03-17 10:00:00'),
(77, 77, 77, 'WAITLISTED', 16, '2026-03-18 10:00:00'),
(78, 78, 78, 'REGISTERED', NULL, '2026-03-19 10:00:00'),
(79, 79, 79, 'REGISTERED', NULL, '2026-03-20 10:00:00'),
(80, 80, 80, 'CANCELLED', NULL, '2026-03-21 10:00:00'),
(81, 81, 81, 'REGISTERED', NULL, '2026-03-22 10:00:00'),
(82, 82, 82, 'REGISTERED', NULL, '2026-03-23 10:00:00'),
(83, 83, 83, 'WAITLISTED', 17, '2026-03-24 10:00:00'),
(84, 84, 84, 'REGISTERED', NULL, '2026-03-25 10:00:00'),
(85, 85, 85, 'REGISTERED', NULL, '2026-03-26 10:00:00'),
(86, 86, 86, 'REGISTERED', NULL, '2026-03-27 10:00:00'),
(87, 87, 87, 'WAITLISTED', 18, '2026-03-28 10:00:00'),
(88, 88, 88, 'REGISTERED', NULL, '2026-03-29 10:00:00'),
(89, 89, 89, 'REGISTERED', NULL, '2026-03-30 10:00:00'),
(90, 90, 90, 'CANCELLED', NULL, '2026-03-31 10:00:00'),
(91, 91, 91, 'REGISTERED', NULL, '2026-04-01 10:00:00'),
(92, 92, 92, 'REGISTERED', NULL, '2026-04-02 10:00:00'),
(93, 93, 93, 'WAITLISTED', 19, '2026-04-03 10:00:00'),
(94, 94, 94, 'REGISTERED', NULL, '2026-04-04 10:00:00'),
(95, 95, 95, 'REGISTERED', NULL, '2026-04-05 10:00:00'),
(96, 96, 96, 'REGISTERED', NULL, '2026-04-06 10:00:00'),
(97, 97, 97, 'WAITLISTED', 20, '2026-04-07 10:00:00'),
(98, 98, 98, 'REGISTERED', NULL, '2026-04-08 10:00:00'),
(99, 99, 99, 'REGISTERED', NULL, '2026-04-09 10:00:00'),
(100, 100, 100, 'CANCELLED', NULL, '2026-04-10 10:00:00'),
(101, 127, 95, 'CANCELLED', NULL, '2026-08-04 16:36:01'),
(102, 127, 95, 'CANCELLED', NULL, '2026-08-04 16:36:35'),
(103, 127, 95, 'REGISTERED', NULL, '2026-08-04 16:37:36'),
(104, 127, 66, 'REGISTERED', NULL, '2026-08-04 21:14:01'),
(105, 127, 100, 'REGISTERED', NULL, '2026-08-04 22:39:09'),
(106, 133, 99, 'REGISTERED', NULL, '2026-08-05 09:51:31'),
(107, 133, 66, 'CANCELLED', NULL, '2026-08-05 09:52:34'),
(108, 134, 112, 'REGISTERED', NULL, '2026-08-07 09:48:48'),
(109, 127, 2, 'REGISTERED', NULL, '2026-08-07 10:04:48'),
(110, 127, 114, 'REGISTERED', NULL, '2026-08-07 10:52:30'),
(111, 127, 20, 'REGISTERED', NULL, '2026-08-07 13:15:23'),
(112, 127, 89, 'REGISTERED', NULL, '2026-08-08 09:46:51'),
(113, 136, 45, 'REGISTERED', NULL, '2026-08-08 11:44:11'),
(114, 137, 45, 'REGISTERED', NULL, '2026-08-08 11:49:32');

-- --------------------------------------------------------

--
-- Table structure for table `skills`
--

CREATE TABLE `skills` (
  `skill_id` int(11) NOT NULL,
  `skill_name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `skills`
--

INSERT INTO `skills` (`skill_id`, `skill_name`) VALUES
(59, 'AI'),
(31, 'Algorithms'),
(45, 'Android Development'),
(9, 'Angular'),
(37, 'Artificial Intelligence'),
(24, 'AWS'),
(25, 'Azure'),
(3, 'C'),
(4, 'C++'),
(34, 'Computer Networks'),
(7, 'CSS'),
(40, 'Cybersecurity'),
(39, 'Data Science'),
(30, 'Data Structures'),
(35, 'DBMS'),
(38, 'Deep Learning'),
(49, 'Django'),
(22, 'Docker'),
(41, 'Ethical Hacking'),
(12, 'Express.js'),
(43, 'Figma'),
(19, 'Firebase'),
(44, 'Flutter'),
(20, 'Git'),
(21, 'GitHub'),
(26, 'Google Cloud'),
(29, 'GraphQL'),
(14, 'Hibernate'),
(6, 'HTML'),
(46, 'iOS Development'),
(1, 'Java'),
(5, 'JavaScript'),
(23, 'Kubernetes'),
(48, 'Laravel'),
(27, 'Linux'),
(36, 'Machine Learning'),
(17, 'MongoDB'),
(15, 'MySQL'),
(11, 'Node.js'),
(32, 'Object Oriented Programming'),
(33, 'Operating Systems'),
(18, 'Oracle SQL'),
(47, 'PHP'),
(16, 'PostgreSQL'),
(50, 'Problem Solving'),
(2, 'Python'),
(8, 'React'),
(28, 'REST API'),
(13, 'Spring Boot'),
(42, 'UI/UX Design'),
(10, 'Vue.js');

-- --------------------------------------------------------

--
-- Table structure for table `teammembers`
--

CREATE TABLE `teammembers` (
  `team_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `teammembers`
--

INSERT INTO `teammembers` (`team_id`, `user_id`, `joined_at`) VALUES
(1, 1, '2026-06-30 22:10:25'),
(1, 2, '2026-06-30 22:22:48'),
(1, 3, '2026-06-30 22:45:17'),
(1, 4, '2026-06-30 23:06:53'),
(1, 5, '2026-06-30 23:21:41'),
(2, 6, '2026-06-30 22:14:56'),
(2, 7, '2026-06-30 22:48:20'),
(2, 8, '2026-06-30 23:16:02'),
(3, 9, '2026-07-01 00:08:36'),
(3, 10, '2026-07-01 00:24:58'),
(3, 11, '2026-07-01 00:47:51'),
(3, 12, '2026-07-01 01:05:39'),
(4, 13, '2026-07-01 22:06:14'),
(4, 14, '2026-07-01 22:18:29'),
(4, 15, '2026-07-01 22:36:47'),
(4, 16, '2026-07-01 22:54:20'),
(4, 17, '2026-07-01 23:15:31'),
(5, 18, '2026-07-01 23:22:45'),
(5, 19, '2026-07-01 23:47:13'),
(5, 20, '2026-07-02 00:11:09'),
(6, 21, '2026-07-02 00:24:52'),
(6, 22, '2026-07-02 00:39:36'),
(6, 23, '2026-07-02 00:58:08'),
(6, 24, '2026-07-02 01:15:27'),
(6, 25, '2026-07-02 01:36:14'),
(7, 26, '2026-07-02 22:05:11'),
(7, 27, '2026-07-02 22:23:40'),
(7, 28, '2026-07-02 22:48:25'),
(8, 29, '2026-07-02 23:02:58'),
(8, 30, '2026-07-02 23:24:33'),
(8, 31, '2026-07-02 23:41:57'),
(8, 32, '2026-07-03 00:08:46'),
(8, 33, '2026-07-03 00:33:12'),
(9, 34, '2026-07-03 00:52:27'),
(9, 35, '2026-07-03 01:13:04'),
(9, 36, '2026-07-03 01:34:19'),
(10, 37, '2026-07-03 22:03:51'),
(10, 38, '2026-07-03 22:26:42'),
(10, 39, '2026-07-03 22:48:17'),
(10, 40, '2026-07-03 23:11:36'),
(10, 41, '2026-07-03 23:32:28'),
(11, 42, '2026-07-03 23:54:15'),
(11, 43, '2026-07-04 00:19:23'),
(11, 44, '2026-07-04 00:45:37'),
(12, 46, '2026-07-04 01:26:19'),
(12, 47, '2026-07-04 01:48:56'),
(12, 48, '2026-07-04 02:05:41'),
(13, 49, '2026-07-04 22:07:35'),
(13, 50, '2026-07-04 22:26:48'),
(13, 51, '2026-07-04 22:47:19'),
(13, 52, '2026-07-04 23:14:03'),
(13, 53, '2026-07-04 23:33:58'),
(14, 54, '2026-07-04 23:52:11'),
(14, 55, '2026-07-05 00:13:29'),
(14, 56, '2026-07-05 00:35:47'),
(14, 57, '2026-07-05 00:58:12'),
(14, 58, '2026-07-05 01:17:46'),
(15, 59, '2026-07-05 01:36:09'),
(15, 60, '2026-07-05 01:58:41'),
(15, 61, '2026-07-05 02:16:33'),
(15, 62, '2026-07-05 02:38:15'),
(15, 63, '2026-07-05 02:57:46'),
(16, 64, '2026-07-05 22:05:18'),
(16, 65, '2026-07-05 22:26:47'),
(16, 66, '2026-07-05 22:43:39'),
(17, 67, '2026-07-05 23:02:41'),
(17, 68, '2026-07-05 23:18:56'),
(17, 69, '2026-07-05 23:35:21'),
(17, 70, '2026-07-05 23:52:44'),
(17, 71, '2026-07-06 00:09:37'),
(18, 72, '2026-07-06 00:26:11'),
(18, 73, '2026-07-06 00:42:28'),
(18, 74, '2026-07-06 01:03:42'),
(19, 75, '2026-07-06 01:20:31'),
(19, 76, '2026-07-06 01:41:26'),
(19, 77, '2026-07-06 02:04:15'),
(20, 78, '2026-07-06 22:08:46'),
(20, 79, '2026-07-06 22:23:57'),
(20, 80, '2026-07-06 22:46:38'),
(20, 81, '2026-07-06 23:04:51'),
(20, 82, '2026-07-06 23:22:35'),
(21, 83, '2026-07-06 23:41:18'),
(21, 84, '2026-07-07 00:03:47'),
(21, 85, '2026-07-07 00:24:52'),
(22, 86, '2026-07-07 00:43:29'),
(22, 87, '2026-07-07 01:05:34'),
(22, 88, '2026-07-07 01:28:11'),
(23, 89, '2026-07-07 01:46:42'),
(23, 90, '2026-07-07 02:02:33'),
(23, 91, '2026-07-07 02:19:26'),
(23, 92, '2026-07-07 02:35:14'),
(23, 93, '2026-07-07 02:58:47'),
(24, 94, '2026-07-07 22:10:36'),
(24, 95, '2026-07-07 22:26:11'),
(24, 96, '2026-07-07 22:43:18'),
(24, 97, '2026-07-07 23:01:22'),
(24, 98, '2026-07-07 23:18:55'),
(25, 99, '2026-07-07 23:41:36'),
(25, 100, '2026-07-08 00:02:47'),
(26, 1, '2026-07-08 00:24:36'),
(26, 6, '2026-07-08 00:48:11'),
(26, 11, '2026-07-08 01:07:24'),
(27, 16, '2026-07-08 22:11:37'),
(27, 21, '2026-07-08 22:28:52'),
(27, 26, '2026-07-08 22:46:18'),
(27, 31, '2026-07-08 23:09:44'),
(27, 36, '2026-07-08 23:31:25'),
(28, 41, '2026-07-08 23:56:41'),
(28, 46, '2026-07-09 00:13:38'),
(28, 51, '2026-07-09 00:37:55'),
(29, 56, '2026-07-09 01:01:43'),
(29, 61, '2026-07-09 01:24:51'),
(29, 66, '2026-07-09 01:48:29'),
(30, 71, '2026-07-09 22:07:42'),
(30, 76, '2026-07-09 22:28:36'),
(30, 81, '2026-07-09 22:46:57'),
(30, 86, '2026-07-09 23:05:19'),
(30, 91, '2026-07-09 23:27:43'),
(31, 2, '2026-07-09 23:41:26'),
(31, 7, '2026-07-09 23:55:41'),
(31, 12, '2026-07-10 00:18:37'),
(32, 17, '2026-07-10 00:32:49'),
(32, 22, '2026-07-10 00:47:58'),
(32, 27, '2026-07-10 01:06:15'),
(33, 32, '2026-07-10 01:21:42'),
(33, 37, '2026-07-10 01:36:18'),
(33, 42, '2026-07-10 01:57:35'),
(33, 47, '2026-07-10 02:15:53'),
(33, 52, '2026-07-10 02:38:41'),
(34, 57, '2026-07-10 02:56:28'),
(34, 62, '2026-07-10 03:14:31'),
(34, 67, '2026-07-10 03:29:42'),
(34, 72, '2026-07-10 03:47:57'),
(34, 77, '2026-07-10 04:08:39'),
(35, 82, '2026-07-10 04:26:18'),
(35, 87, '2026-07-10 04:43:57'),
(35, 92, '2026-07-10 05:01:11'),
(36, 3, '2026-07-10 05:41:20'),
(36, 8, '2026-07-10 05:58:16'),
(36, 97, '2026-07-10 05:19:45'),
(37, 13, '2026-07-10 22:08:54'),
(37, 18, '2026-07-10 22:27:41'),
(37, 23, '2026-07-10 22:46:32'),
(37, 28, '2026-07-10 23:05:27'),
(37, 33, '2026-07-10 23:24:38'),
(38, 38, '2026-07-10 23:42:13'),
(38, 43, '2026-07-10 23:58:47'),
(38, 48, '2026-07-11 00:16:22'),
(39, 53, '2026-07-11 00:34:55'),
(39, 58, '2026-07-11 00:56:28'),
(39, 63, '2026-07-11 01:17:39'),
(40, 68, '2026-07-11 01:36:41'),
(40, 73, '2026-07-11 01:58:33'),
(40, 78, '2026-07-11 02:17:12'),
(40, 83, '2026-07-11 02:38:44'),
(40, 88, '2026-07-11 02:56:53'),
(41, 4, '2026-07-11 03:57:26'),
(41, 93, '2026-07-11 03:19:31'),
(41, 98, '2026-07-11 03:36:42'),
(42, 9, '2026-07-11 04:18:07'),
(42, 14, '2026-07-11 04:37:41'),
(42, 19, '2026-07-11 04:59:16'),
(43, 24, '2026-07-11 05:18:55'),
(43, 29, '2026-07-11 05:37:28'),
(43, 34, '2026-07-11 05:56:09'),
(43, 39, '2026-07-11 06:18:26'),
(43, 44, '2026-07-11 06:39:41'),
(44, 49, '2026-07-11 22:12:44'),
(44, 54, '2026-07-11 22:33:58'),
(44, 59, '2026-07-11 22:55:11'),
(44, 64, '2026-07-11 23:16:35'),
(44, 69, '2026-07-11 23:38:22'),
(45, 74, '2026-07-11 23:59:47'),
(45, 79, '2026-07-12 00:21:36'),
(45, 84, '2026-07-12 00:42:55'),
(46, 89, '2026-07-12 01:08:11'),
(46, 94, '2026-07-12 01:29:47'),
(46, 99, '2026-07-12 01:51:28'),
(47, 5, '2026-07-12 02:09:56'),
(47, 10, '2026-07-12 02:27:42'),
(47, 15, '2026-07-12 02:46:51'),
(47, 20, '2026-07-12 03:08:33'),
(47, 25, '2026-07-12 03:29:17'),
(48, 30, '2026-07-12 03:51:04'),
(48, 35, '2026-07-12 04:13:26'),
(48, 40, '2026-07-12 04:37:11'),
(49, 50, '2026-07-12 05:23:18'),
(49, 55, '2026-07-12 05:44:52'),
(50, 60, '2026-07-12 22:06:14'),
(50, 65, '2026-07-12 22:28:41'),
(50, 70, '2026-07-12 22:47:56'),
(50, 75, '2026-07-12 23:08:32'),
(50, 80, '2026-07-12 23:29:11'),
(51, 85, '2026-07-12 23:48:36'),
(51, 90, '2026-07-13 00:09:42'),
(51, 95, '2026-07-13 00:28:57'),
(52, 6, '2026-07-13 01:13:44'),
(52, 12, '2026-07-13 01:34:17'),
(52, 100, '2026-07-13 00:51:09'),
(53, 18, '2026-07-13 01:58:36'),
(53, 24, '2026-07-13 02:19:58'),
(53, 30, '2026-07-13 02:42:11'),
(53, 36, '2026-07-13 03:03:45'),
(53, 42, '2026-07-13 03:27:19'),
(54, 48, '2026-07-13 03:49:56'),
(54, 54, '2026-07-13 04:08:35'),
(54, 60, '2026-07-13 04:29:48'),
(55, 66, '2026-07-13 04:54:16'),
(55, 72, '2026-07-13 05:15:29'),
(55, 78, '2026-07-13 05:37:53'),
(56, 2, '2026-07-13 07:08:44'),
(56, 8, '2026-07-13 07:31:17'),
(56, 84, '2026-07-13 06:02:08'),
(56, 90, '2026-07-13 06:24:16'),
(56, 96, '2026-07-13 06:47:33'),
(57, 14, '2026-07-13 22:07:55'),
(57, 20, '2026-07-13 22:31:42'),
(57, 26, '2026-07-13 22:54:23'),
(58, 32, '2026-07-13 23:18:46'),
(58, 38, '2026-07-13 23:42:15'),
(58, 44, '2026-07-14 00:04:28'),
(58, 50, '2026-07-14 00:26:59'),
(58, 56, '2026-07-14 00:49:41'),
(59, 62, '2026-07-14 01:11:37'),
(59, 68, '2026-07-14 01:34:52'),
(59, 74, '2026-07-14 01:58:21'),
(60, 80, '2026-07-14 02:23:08'),
(60, 86, '2026-07-14 02:45:16'),
(60, 92, '2026-07-14 03:09:44'),
(61, 4, '2026-07-14 03:52:18'),
(61, 10, '2026-07-14 04:15:09'),
(61, 98, '2026-07-14 03:31:26'),
(62, 16, '2026-07-14 04:37:54'),
(62, 22, '2026-07-14 04:58:43'),
(62, 28, '2026-07-14 05:19:51'),
(63, 34, '2026-07-14 22:06:18'),
(63, 40, '2026-07-14 22:28:37'),
(63, 46, '2026-07-14 22:49:11'),
(63, 52, '2026-07-14 23:12:47'),
(63, 58, '2026-07-14 23:36:25'),
(64, 64, '2026-07-14 23:58:41'),
(64, 70, '2026-07-15 00:19:52'),
(64, 76, '2026-07-15 00:42:16'),
(64, 82, '2026-07-15 01:04:39'),
(64, 88, '2026-07-15 01:26:57'),
(65, 5, '2026-07-15 02:35:29'),
(65, 94, '2026-07-15 01:49:35'),
(65, 100, '2026-07-15 02:13:48'),
(66, 11, '2026-07-15 02:57:54'),
(66, 17, '2026-07-15 03:18:43'),
(66, 23, '2026-07-15 03:42:37'),
(67, 29, '2026-07-15 04:06:51'),
(67, 35, '2026-07-15 04:28:46'),
(67, 41, '2026-07-15 04:49:32'),
(67, 47, '2026-07-15 05:13:07'),
(67, 53, '2026-07-15 05:37:28'),
(68, 59, '2026-07-15 06:02:46'),
(68, 65, '2026-07-15 06:25:38'),
(68, 71, '2026-07-15 06:47:13'),
(68, 77, '2026-07-15 07:08:52'),
(68, 83, '2026-07-15 07:31:27'),
(69, 1, '2026-07-15 22:54:33'),
(69, 89, '2026-07-15 22:09:46'),
(69, 95, '2026-07-15 22:31:52'),
(70, 7, '2026-07-15 23:18:57'),
(70, 13, '2026-07-15 23:42:29'),
(70, 19, '2026-07-16 00:05:48'),
(71, 25, '2026-07-16 00:29:17'),
(71, 31, '2026-07-16 00:53:21'),
(71, 37, '2026-07-16 01:14:56'),
(71, 43, '2026-07-16 01:37:42'),
(71, 49, '2026-07-16 01:59:38'),
(72, 55, '2026-07-16 02:24:13'),
(72, 61, '2026-07-16 02:48:07'),
(72, 67, '2026-07-16 03:09:31'),
(73, 73, '2026-07-16 03:32:54'),
(73, 79, '2026-07-16 03:55:46'),
(73, 85, '2026-07-16 04:18:11'),
(74, 3, '2026-07-16 05:28:49'),
(74, 9, '2026-07-16 05:51:13'),
(74, 15, '2026-07-16 06:12:55'),
(74, 91, '2026-07-16 04:41:25'),
(74, 97, '2026-07-16 05:05:32'),
(75, 21, '2026-07-16 22:07:31'),
(75, 27, '2026-07-16 22:29:18'),
(75, 33, '2026-07-16 22:52:46'),
(76, 39, '2026-07-16 23:16:22'),
(76, 51, '2026-07-17 00:02:47'),
(76, 57, '2026-07-17 00:24:59'),
(76, 63, '2026-07-17 00:47:35'),
(77, 69, '2026-07-17 01:11:53'),
(77, 75, '2026-07-17 01:33:42'),
(77, 81, '2026-07-17 01:56:14'),
(78, 87, '2026-07-17 02:18:39'),
(78, 93, '2026-07-17 02:42:18'),
(78, 99, '2026-07-17 03:05:52'),
(79, 6, '2026-07-17 03:28:37'),
(79, 12, '2026-07-17 03:52:49'),
(79, 18, '2026-07-17 04:15:21'),
(80, 24, '2026-07-17 04:38:56'),
(80, 30, '2026-07-17 05:02:31'),
(80, 36, '2026-07-17 05:25:44'),
(80, 42, '2026-07-17 05:47:55'),
(80, 48, '2026-07-17 06:11:29'),
(87, 127, '2026-08-04 17:11:20');

--
-- Triggers `teammembers`
--
DELIMITER $$
CREATE TRIGGER `before_locked_team_join` BEFORE INSERT ON `teammembers` FOR EACH ROW BEGIN
    DECLARE team_state VARCHAR(20);
    SELECT status INTO team_state FROM teams WHERE team_id = NEW.team_id;
    IF team_state = 'LOCKED' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot join a locked team.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_team_join` BEFORE INSERT ON `teammembers` FOR EACH ROW BEGIN
    DECLARE current_members INT;
    SELECT COUNT(*) INTO current_members FROM teammembers WHERE team_id = NEW.team_id;
    IF current_members >= 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This team is already full.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `check_and_lock_team` AFTER INSERT ON `teammembers` FOR EACH ROW BEGIN
    DECLARE m_count INT;
    SELECT COUNT(*) INTO m_count FROM teammembers WHERE team_id = NEW.team_id;
    IF m_count = 5 THEN
        UPDATE teams SET status = 'LOCKED' WHERE team_id = NEW.team_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `teams`
--

CREATE TABLE `teams` (
  `team_id` int(11) NOT NULL,
  `hackathon_id` int(11) NOT NULL,
  `team_name` varchar(100) NOT NULL,
  `max_capacity` int(11) NOT NULL CHECK (`max_capacity` between 2 and 6),
  `status` enum('FORMING','FULL','LOCKED') NOT NULL DEFAULT 'FORMING',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `leader_user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `teams`
--

INSERT INTO `teams` (`team_id`, `hackathon_id`, `team_name`, `max_capacity`, `status`, `created_at`, `leader_user_id`) VALUES
(1, 1, 'Byte Bandits', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(2, 2, 'Neural Ninjas', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(3, 3, 'Runtime Rebels', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(4, 4, 'Stack Masters', 6, 'FULL', '2026-07-09 20:18:19', NULL),
(5, 5, 'Quantum Coders', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(6, 6, 'Syntax Squad', 5, 'LOCKED', '2026-07-09 20:18:19', NULL),
(7, 7, 'Cloud Commanders', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(8, 8, 'Bug Hunters', 6, 'FULL', '2026-07-09 20:18:19', NULL),
(9, 9, 'AI Avengers', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(10, 10, 'Logic Lords', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(11, 11, 'Null Terminators', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(12, 12, 'Pixel Pirates', 6, 'FORMING', '2026-07-09 20:18:19', NULL),
(13, 13, 'Code Crushers', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(14, 14, 'Binary Beasts', 5, 'LOCKED', '2026-07-09 20:18:19', NULL),
(15, 15, 'Compile Crew', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(16, 16, 'Cyber Knights', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(17, 17, 'Debug Dynasty', 6, 'FULL', '2026-07-09 20:18:19', NULL),
(18, 18, 'Tech Titans', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(19, 19, 'Git Pushers', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(20, 20, 'Data Dragons', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(21, 21, 'Dream Coders', 6, 'FORMING', '2026-07-09 20:18:19', NULL),
(22, 22, 'Hackoholics', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(23, 23, 'Infinite Loopers', 5, 'LOCKED', '2026-07-09 20:18:19', NULL),
(24, 24, 'Ctrl Alt Elite', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(25, 25, '404 Not Found', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(26, 26, 'Code Catalysts', 6, 'FORMING', '2026-07-09 20:18:19', NULL),
(27, 27, 'Alpha Hackers', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(28, 28, 'Omega Developers', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(29, 29, 'Neon Coders', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(30, 30, 'Tech Mavericks', 6, 'FULL', '2026-07-09 20:18:19', NULL),
(31, 31, 'Rapid Coders', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(32, 32, 'Digital Dynamos', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(33, 33, 'Dev Dominators', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(34, 34, 'Fusion Force', 5, 'LOCKED', '2026-07-09 20:18:19', NULL),
(35, 35, 'Future Builders', 6, 'FORMING', '2026-07-09 20:18:19', NULL),
(36, 36, 'Innovation Crew', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(37, 37, 'Vision Coders', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(38, 38, 'Phoenix Stack', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(39, 39, 'Byte Warriors', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(40, 40, 'Circuit Breakers', 6, 'FULL', '2026-07-09 20:18:19', NULL),
(41, 41, 'Algorithm Army', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(42, 42, 'Kernel Kings', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(43, 43, 'Matrix Minds', 5, 'LOCKED', '2026-07-09 20:18:19', NULL),
(44, 44, 'Cloud Ninjas', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(45, 45, 'Hackstorm', 6, 'FORMING', '2026-07-09 20:18:19', NULL),
(46, 46, 'Dev Avengers', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(47, 47, 'Terminal Titans', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(48, 48, 'Brain Bytes', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(49, 49, 'Smart Coders', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(50, 50, 'Infinite Innovators', 6, 'FULL', '2026-07-09 20:18:19', NULL),
(51, 51, 'Logic Ninjas', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(52, 52, 'Techno Sparks', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(53, 53, 'NextGen Devs', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(54, 54, 'Bug Blasters', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(55, 55, 'Script Squad', 6, 'FORMING', '2026-07-09 20:18:19', NULL),
(56, 56, 'Code Commandos', 5, 'LOCKED', '2026-07-09 20:18:19', NULL),
(57, 57, 'Dream Stack', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(58, 58, 'Elite Engineers', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(59, 59, 'Neural Force', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(60, 60, 'Binary Brotherhood', 6, 'FORMING', '2026-07-09 20:18:19', NULL),
(61, 61, 'Dynamic Developers', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(62, 62, 'Digital Detectives', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(63, 63, 'Cloud Coders', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(64, 64, 'Visionary Hackers', 6, 'FULL', '2026-07-09 20:18:19', NULL),
(65, 65, 'Hack Wizards', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(66, 66, 'Rocket Coders', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(67, 67, 'Agile Geeks', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(68, 68, 'DevOps Legends', 5, 'LOCKED', '2026-07-09 20:18:19', NULL),
(69, 69, 'Cyber Wizards', 6, 'FORMING', '2026-07-09 20:18:19', NULL),
(70, 70, 'Parallel Minds', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(71, 71, 'Byte Storm', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(72, 72, 'Tech Fusion', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(73, 73, 'Quantum Force', 6, 'FORMING', '2026-07-09 20:18:19', NULL),
(74, 74, 'Stack Overflowed', 5, 'FULL', '2026-07-09 20:18:19', NULL),
(75, 75, 'Creative Coders', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(76, 76, 'AI Innovators', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(77, 77, 'Future Hackers', 6, 'FULL', '2026-07-09 20:18:19', NULL),
(78, 78, 'Vision Warriors', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(79, 79, 'Data Pirates', 5, 'FORMING', '2026-07-09 20:18:19', NULL),
(80, 80, 'Hack Elite', 5, 'LOCKED', '2026-07-09 20:18:19', NULL),
(81, 1, 'gv', 2, 'FORMING', '2026-07-31 14:54:14', NULL),
(82, 1, 'nj', 2, 'FORMING', '2026-07-31 14:54:58', NULL),
(83, 1, 'h', 2, 'FORMING', '2026-07-31 15:16:58', NULL),
(84, 1, 'bh', 2, 'FORMING', '2026-07-31 15:48:30', NULL),
(87, 2, 'het', 5, 'FORMING', '2026-08-04 17:11:20', NULL),
(88, 5, 'ff', 5, 'FORMING', '2026-08-05 04:17:31', NULL);

--
-- Triggers `teams`
--
DELIMITER $$
CREATE TRIGGER `update_team_full_status` BEFORE UPDATE ON `teams` FOR EACH ROW BEGIN
    DECLARE m_count INT;
    SELECT COUNT(*) INTO m_count FROM teammembers WHERE team_id = NEW.team_id;
    IF m_count = 5 THEN
        SET NEW.status = 'FULL';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `userinterests`
--

CREATE TABLE `userinterests` (
  `user_id` int(11) NOT NULL,
  `interest_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `userinterests`
--

INSERT INTO `userinterests` (`user_id`, `interest_id`) VALUES
(1, 3),
(1, 5),
(1, 19),
(2, 1),
(2, 3),
(2, 5),
(3, 2),
(3, 4),
(3, 8),
(4, 3),
(4, 5),
(4, 19),
(5, 1),
(5, 2),
(5, 22),
(6, 4),
(6, 13),
(6, 19),
(7, 5),
(7, 14),
(7, 19),
(8, 4),
(8, 8),
(8, 20),
(9, 9),
(9, 12),
(9, 24),
(10, 6),
(10, 7),
(10, 20),
(11, 4),
(11, 15),
(11, 19),
(12, 1),
(12, 2),
(12, 23),
(13, 3),
(13, 20),
(13, 21),
(14, 10),
(14, 11),
(14, 19),
(15, 7),
(15, 18),
(15, 20),
(16, 4),
(16, 5),
(16, 14),
(17, 1),
(17, 2),
(17, 22),
(18, 1),
(18, 2),
(18, 23),
(19, 16),
(19, 17),
(19, 18),
(20, 4),
(20, 5),
(20, 19),
(21, 6),
(21, 8),
(21, 20),
(22, 3),
(22, 13),
(22, 21),
(23, 4),
(23, 5),
(23, 10),
(24, 6),
(24, 8),
(24, 18),
(25, 10),
(25, 11),
(25, 19),
(26, 9),
(26, 12),
(26, 24),
(27, 4),
(27, 5),
(27, 14),
(28, 4),
(28, 13),
(28, 15),
(29, 16),
(29, 17),
(29, 18),
(30, 1),
(30, 2),
(30, 22),
(31, 2),
(31, 3),
(31, 21),
(32, 7),
(32, 18),
(32, 20),
(33, 4),
(33, 5),
(33, 19),
(34, 6),
(34, 7),
(34, 20),
(35, 10),
(35, 11),
(35, 19),
(36, 4),
(36, 5),
(36, 19),
(37, 8),
(37, 13),
(37, 20),
(38, 3),
(38, 6),
(38, 21),
(39, 1),
(39, 2),
(39, 22),
(40, 1),
(40, 22),
(40, 23),
(41, 4),
(41, 5),
(41, 19),
(42, 1),
(42, 2),
(42, 6),
(43, 6),
(43, 7),
(43, 20),
(44, 3),
(44, 20),
(44, 21),
(45, 4),
(45, 13),
(45, 19),
(46, 1),
(46, 22),
(46, 23),
(47, 5),
(47, 10),
(47, 11),
(48, 4),
(48, 8),
(48, 13),
(49, 5),
(49, 14),
(49, 15),
(50, 16),
(50, 17),
(50, 18),
(51, 1),
(51, 2),
(51, 3),
(52, 7),
(52, 18),
(52, 20),
(53, 4),
(53, 5),
(53, 19),
(54, 4),
(54, 8),
(54, 13),
(55, 3),
(55, 14),
(55, 21),
(56, 10),
(56, 11),
(56, 19),
(57, 6),
(57, 7),
(57, 20),
(58, 4),
(58, 13),
(58, 15),
(59, 9),
(59, 12),
(59, 24),
(60, 1),
(60, 22),
(60, 23),
(61, 16),
(61, 17),
(61, 18),
(62, 1),
(62, 3),
(62, 21),
(63, 4),
(63, 5),
(63, 10),
(64, 7),
(64, 8),
(64, 20),
(65, 13),
(65, 14),
(65, 19),
(66, 4),
(66, 15),
(66, 16),
(67, 11),
(67, 12),
(67, 24),
(68, 6),
(68, 17),
(68, 18),
(69, 2),
(69, 22),
(69, 23),
(70, 1),
(70, 6),
(70, 20),
(71, 4),
(71, 13),
(71, 19),
(72, 5),
(72, 14),
(72, 15),
(73, 7),
(73, 8),
(73, 18),
(74, 3),
(74, 9),
(74, 21),
(75, 10),
(75, 11),
(75, 22),
(76, 16),
(76, 17),
(76, 20),
(77, 1),
(77, 2),
(77, 4),
(78, 6),
(78, 8),
(78, 13),
(79, 4),
(79, 5),
(79, 19),
(80, 3),
(80, 14),
(80, 15),
(81, 7),
(81, 20),
(81, 24),
(82, 9),
(82, 12),
(82, 18),
(83, 21),
(83, 22),
(83, 23),
(84, 1),
(84, 4),
(84, 13),
(85, 5),
(85, 10),
(85, 11),
(86, 6),
(86, 7),
(86, 8),
(87, 14),
(87, 16),
(87, 17),
(88, 3),
(88, 4),
(88, 19),
(89, 15),
(89, 18),
(89, 20),
(90, 1),
(90, 2),
(90, 22),
(91, 9),
(91, 12),
(91, 24),
(92, 7),
(92, 13),
(92, 21),
(93, 4),
(93, 5),
(93, 19),
(94, 10),
(94, 11),
(94, 15),
(95, 16),
(95, 17),
(95, 18),
(96, 1),
(96, 6),
(96, 20),
(97, 3),
(97, 4),
(97, 8),
(98, 7),
(98, 13),
(98, 14),
(99, 2),
(99, 22),
(99, 23),
(100, 5),
(100, 19),
(100, 20),
(130, 55),
(133, 9),
(134, 42),
(135, 42),
(137, 3);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `city` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `name`, `email`, `password_hash`, `city`, `created_at`) VALUES
(1, ' Aarav Pat', 'aarav.patel@gmail.com ', ' hash001', ' Ahmedabad ', '2026-06-30 22:00:00'),
(2, 'Vivaan Sha', 'vivaan.shah@gmail.com ', ' hash002 ', ' Surat ', '2026-06-30 22:10:00'),
(3, ' Aditya Me', 'aditya.mehta@gmail.com ', ' hash003 ', ' Vadodara ', '2026-06-30 22:20:00'),
(4, ' Krish Des', ' krish.desai@gmail.com ', ' hash004 ', ' Rajkot ', '2026-06-30 22:30:00'),
(5, 'Aryan Josh', 'aryan.joshi@gmail.com', 'hash005', 'Ahmedabad', '2026-06-30 22:40:00'),
(6, 'Rohan Triv', 'rohan.trivedi@gmail.com', 'hash006', 'Pune', '2026-06-30 22:50:00'),
(7, 'Dhruv Modi', 'dhruv.modi@gmail.com', 'hash007', 'Mumbai', '2026-06-30 23:00:00'),
(8, 'Harsh Pand', 'harsh.pandya@gmail.com', 'hash008', 'Delhi', '2026-06-30 23:10:00'),
(9, 'Yash Chauh', 'yash.chauhan@gmail.com', 'hash009', 'Indore', '2026-06-30 23:20:00'),
(10, 'Parth Bhat', 'parth.bhatt@gmail.com', 'hash010', 'Jaipur', '2026-06-30 23:30:00'),
(11, 'Neha Shah', 'neha.shah@gmail.com', 'hash011', 'Ahmedabad', '2026-06-30 23:40:00'),
(12, 'Priya Pate', 'priya.patel@gmail.com', 'hash012', 'Surat', '2026-06-30 23:50:00'),
(13, 'Ananya Iye', 'ananya.iyer@gmail.com', 'hash013', 'Bangalore', '2026-07-01 00:00:00'),
(14, 'Ishita Kap', 'ishita.kapoor@gmail.com', 'hash014', 'Mumbai', '2026-07-01 00:10:00'),
(15, 'Sneha Nair', 'sneha.nair@gmail.com', 'hash015', 'Kochi', '2026-07-01 00:20:00'),
(16, 'Riya Sharm', 'riya.sharma@gmail.com', 'hash016', 'Delhi', '2026-07-01 00:30:00'),
(17, 'Pooja Verm', 'pooja.verma@gmail.com', 'hash017', 'Lucknow', '2026-07-01 00:40:00'),
(18, 'Kavya Sing', 'kavya.singh@gmail.com', 'hash018', 'Chandigarh', '2026-07-01 00:50:00'),
(19, 'Diya Agarw', 'diya.agarwal@gmail.com', 'hash019', 'Noida', '2026-07-01 01:00:00'),
(20, 'Meera Kulk', 'meera.k@gmail.com', 'hash020', 'Pune', '2026-07-01 01:10:00'),
(21, 'Arjun Malh', 'arjun.m@gmail.com', 'hash021', 'Delhi', '2026-07-01 01:20:00'),
(22, 'Rahul Gupt', 'rahul.g@gmail.com', 'hash022', 'Kanpur', '2026-07-01 01:30:00'),
(23, 'Siddharth ', 'sid.jain@gmail.com', 'hash023', 'Indore', '2026-07-01 01:40:00'),
(24, 'Nikhil Ban', 'nikhil.b@gmail.com', 'hash024', 'Jaipur', '2026-07-01 01:50:00'),
(25, 'Akash Yada', 'akash.y@gmail.com', 'hash025', 'Patna', '2026-07-01 02:00:00'),
(26, 'Aman Choud', 'aman.c@gmail.com', 'hash026', 'Bhopal', '2026-07-01 02:10:00'),
(27, 'Sahil Soni', 'sahil.s@gmail.com', 'hash027', 'Nagpur', '2026-07-01 02:20:00'),
(28, 'Manav Kapo', 'manav.k@gmail.com', 'hash028', 'Mumbai', '2026-07-01 02:30:00'),
(29, 'Dev Mishra', 'dev.m@gmail.com', 'hash029', 'Varanasi', '2026-07-01 02:40:00'),
(30, 'Laksh Shar', 'laksh.s@gmail.com', 'hash030', 'Delhi', '2026-07-01 02:50:00'),
(31, 'Tanvi Shah', 'tanvi.shah@gmail.com', 'hash031', 'Ahmedabad', '2026-07-01 03:00:00'),
(32, 'Muskan Pat', 'muskan@gmail.com', 'hash032', 'Surat', '2026-07-01 03:10:00'),
(33, 'Nandini Ra', 'nandini@gmail.com', 'hash033', 'Hyderabad', '2026-07-01 03:20:00'),
(34, 'Shruti Jos', 'shruti@gmail.com', 'hash034', 'Pune', '2026-07-01 03:30:00'),
(35, 'Komal Meht', 'komal@gmail.com', 'hash035', 'Ahmedabad', '2026-07-01 03:40:00'),
(36, 'Riddhi Sha', 'riddhi@gmail.com', 'hash036', 'Rajkot', '2026-07-01 03:50:00'),
(37, 'Mihir Pate', 'mihir@gmail.com', 'hash037', 'Ahmedabad', '2026-07-01 04:00:00'),
(38, 'Tirth Shah', 'tirth@gmail.com', 'hash038', 'Surat', '2026-07-01 04:10:00'),
(39, 'Om Trivedi', 'om@gmail.com', 'hash039', 'Vadodara', '2026-07-01 04:20:00'),
(40, 'Jay Desai', 'jay@gmail.com', 'hash040', 'Rajkot', '2026-07-01 04:30:00'),
(41, 'Kevin Pate', 'kevin@gmail.com', 'hash041', 'Ahmedabad', '2026-07-01 04:40:00'),
(42, 'Nisarg Sha', 'nisarg@gmail.com', 'hash042', 'Surat', '2026-07-01 04:50:00'),
(43, 'Ronak Josh', 'ronak@gmail.com', 'hash043', 'Bhavnagar', '2026-07-01 05:00:00'),
(44, 'Yug Mehta', 'yug@gmail.com', 'hash044', 'Junagadh', '2026-07-01 05:10:00'),
(46, 'Prince Kum', 'prince@gmail.com', 'hash046', 'Patna', '2026-07-01 05:30:00'),
(47, 'Abhishek S', 'abhishek@gmail.com', 'hash047', 'Lucknow', '2026-07-01 05:40:00'),
(48, 'Ritesh Ver', 'ritesh@gmail.com', 'hash048', 'Delhi', '2026-07-01 05:50:00'),
(49, 'Sourabh Ja', 'sourabh@gmail.com', 'hash049', 'Indore', '2026-07-01 06:00:00'),
(50, 'Ankit Shar', 'ankit@gmail.com', 'hash050', 'Jaipur', '2026-07-01 06:10:00'),
(51, 'Rajat Mish', 'rajat@gmail.com', 'hash051', 'Delhi', '2026-07-01 06:20:00'),
(52, 'Mohit Gupt', 'mohit@gmail.com', 'hash052', 'Noida', '2026-07-01 06:30:00'),
(53, 'Sagar Pate', 'sagar@gmail.com', 'hash053', 'Ahmedabad', '2026-07-01 06:40:00'),
(54, 'Chirag Sha', 'chirag@gmail.com', 'hash054', 'Surat', '2026-07-01 06:50:00'),
(55, 'Bhavin Des', 'bhavin@gmail.com', 'hash055', 'Rajkot', '2026-07-01 07:00:00'),
(56, 'Kishan Par', 'kishan@gmail.com', 'hash056', 'Vadodara', '2026-07-01 07:10:00'),
(57, 'Hemal Pate', 'hemal@gmail.com', 'hash057', 'Ahmedabad', '2026-07-01 07:20:00'),
(58, 'Darshan Sh', 'darshan@gmail.com', 'hash058', 'Surat', '2026-07-01 07:30:00'),
(59, 'Jatin Triv', 'jatin@gmail.com', 'hash059', 'Pune', '2026-07-01 07:40:00'),
(60, 'Hardik Bha', 'hardik@gmail.com', 'hash060', 'Ahmedabad', '2026-07-01 07:50:00'),
(61, 'Anmol Kapo', 'anmol@gmail.com', 'hash061', 'Mumbai', '2026-07-01 08:00:00'),
(62, 'Reyansh Si', 'reyansh@gmail.com', 'hash062', 'Delhi', '2026-07-01 08:10:00'),
(63, 'Kabir Aror', 'kabir@gmail.com', 'hash063', 'Chandigarh', '2026-07-01 08:20:00'),
(64, 'Vedant Sha', 'vedant@gmail.com', 'hash064', 'Jaipur', '2026-07-01 08:30:00'),
(65, 'Sarthak Ja', 'sarthak@gmail.com', 'hash065', 'Indore', '2026-07-01 08:40:00'),
(66, 'Tanish Meh', 'tanish@gmail.com', 'hash066', 'Ahmedabad', '2026-07-01 08:50:00'),
(67, 'Krunal Pat', 'krunal@gmail.com', 'hash067', 'Rajkot', '2026-07-01 09:00:00'),
(68, 'Devansh Sh', 'devansh@gmail.com', 'hash068', 'Surat', '2026-07-01 09:10:00'),
(69, 'Rudra Josh', 'rudra@gmail.com', 'hash069', 'Vadodara', '2026-07-01 09:20:00'),
(70, 'Harit Modi', 'harit@gmail.com', 'hash070', 'Ahmedabad', '2026-07-01 09:30:00'),
(71, 'Naman Soni', 'naman@gmail.com', 'hash071', 'Nagpur', '2026-07-01 09:40:00'),
(72, 'Kunal Chau', 'kunal@gmail.com', 'hash072', 'Indore', '2026-07-01 09:50:00'),
(73, 'Yuvraj Sha', 'yuvraj@gmail.com', 'hash073', 'Delhi', '2026-07-01 10:00:00'),
(74, 'Tejas Pate', 'tejas@gmail.com', 'hash074', 'Ahmedabad', '2026-07-01 10:10:00'),
(75, 'Dhaval Sha', 'dhaval@gmail.com', 'hash075', 'Surat', '2026-07-01 10:20:00'),
(76, 'Bhargav Me', 'bhargav@gmail.com', 'hash076', 'Vadodara', '2026-07-01 10:30:00'),
(77, 'Nirav Desa', 'nirav@gmail.com', 'hash077', 'Rajkot', '2026-07-01 10:40:00'),
(78, 'Pratik Pat', 'pratik@gmail.com', 'hash078', 'Ahmedabad', '2026-07-01 10:50:00'),
(79, 'Yatin Shah', 'yatin@gmail.com', 'hash079', 'Surat', '2026-07-01 11:00:00'),
(80, 'Rakesh Kum', 'rakesh@gmail.com', 'hash080', 'Delhi', '2026-07-01 11:10:00'),
(81, 'Aditi Shar', 'aditi@gmail.com', 'hash081', 'Delhi', '2026-07-01 11:20:00'),
(82, 'Palak Pate', 'palak@gmail.com', 'hash082', 'Ahmedabad', '2026-07-01 11:30:00'),
(83, 'Khushi Sha', 'khushi@gmail.com', 'hash083', 'Surat', '2026-07-01 11:40:00'),
(84, 'Jiya Mehta', 'jiya@gmail.com', 'hash084', 'Rajkot', '2026-07-01 11:50:00'),
(85, 'Mahi Desai', 'mahi@gmail.com', 'hash085', 'Vadodara', '2026-07-01 12:00:00'),
(86, 'Siya Patel', 'siya@gmail.com', 'hash086', 'Ahmedabad', '2026-07-01 12:10:00'),
(87, 'Nitya Shah', 'nitya@gmail.com', 'hash087', 'Mumbai', '2026-07-01 12:20:00'),
(88, 'Avni Joshi', 'avni@gmail.com', 'hash088', 'Pune', '2026-07-01 12:30:00'),
(89, 'Myra Kapoo', 'myra@gmail.com', 'hash089', 'Delhi', '2026-07-01 12:40:00'),
(90, 'Kiara Verm', 'kiara@gmail.com', 'hash090', 'Lucknow', '2026-07-01 12:50:00'),
(91, 'Ira Sharma', 'ira@gmail.com', 'hash091', 'Noida', '2026-07-01 22:00:00'),
(92, 'Rhea Singh', 'rhea@gmail.com', 'hash092', 'Indore', '2026-07-01 22:10:00'),
(93, 'Sara Jain', 'sara@gmail.com', 'hash093', 'Jaipur', '2026-07-01 22:20:00'),
(94, 'Aisha Khan', 'aisha@gmail.com', 'hash094', 'Hyderabad', '2026-07-01 22:30:00'),
(95, 'Zara Ali', 'zara@gmail.com', 'hash095', 'Mumbai', '2026-07-01 22:40:00'),
(96, 'Tanisha Gu', 'tanisha@gmail.com', 'hash096', 'Delhi', '2026-07-01 22:50:00'),
(97, 'Niharika R', 'niharika@gmail.com', 'hash097', 'Bangalore', '2026-07-01 23:00:00'),
(98, 'Vaidehi Ku', 'vaidehi@gmail.com', 'hash098', 'Pune', '2026-07-01 23:10:00'),
(99, 'Saanvi Pat', 'saanvi@gmail.com', 'hash099', 'Ahmedabad', '2026-07-01 23:20:00'),
(100, 'Anvi Shah', 'anvi@gmail.com', 'hash100', 'Surat', '2026-07-01 23:30:00'),
(101, 'pri', '@gmail.com', '12', 'suat', '2026-07-15 17:20:44'),
(103, 'priyanshi', 'pri@gmail.com', '12', 'surat', '2026-07-26 05:14:02'),
(104, 'prisha', 'priyanshipatoliya@gmail.com', '5112007', 'surat', '2026-07-26 05:19:00'),
(105, 'priyanshi', 'pp@gmail.com', '5112007', 'suat', '2026-07-26 06:49:42'),
(107, 'pri', 'pm@gmail.com', '5112007', 'surat', '2026-07-31 08:46:43'),
(121, 'lily', 'lily@gmail.com', '456', 'ahm', '2026-08-01 15:40:00'),
(123, 'jenny', 'jena1@gmail.com', '333', 'ahm', '2026-08-01 15:41:23'),
(124, 'nency', 'n@gmail.com', '12', 'surat', '2026-08-02 06:35:01'),
(125, 'prii', 'prii@gmail.com', '12', 'surat', '2026-08-02 06:36:27'),
(126, 'pari', 'pari@gmail.com', '12', 'surat', '2026-08-03 11:51:42'),
(127, 'het', 'hetjiyani24@gmail.com', '1', 'mumbai', '2026-08-04 10:23:39'),
(135, 'mj', 'mj@gmail.com', 'Mj@12345', 'surat', '2026-08-08 04:50:57'),
(136, 'het', 'hetjiyani.99@gmail.com', 'Het@1234', 'surat', '2026-08-08 06:11:14'),
(137, 'het', 'hetjiyani99@gmail.com', 'Het@1234', 'surat', '2026-08-08 06:16:38');

-- --------------------------------------------------------

--
-- Table structure for table `userskills`
--

CREATE TABLE `userskills` (
  `user_id` int(11) NOT NULL,
  `skill_id` int(11) NOT NULL,
  `proficiency_level` enum('BEGINNER','INTERMEDIATE','ADVANCED') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `userskills`
--

INSERT INTO `userskills` (`user_id`, `skill_id`, `proficiency_level`) VALUES
(1, 1, 'ADVANCED'),
(1, 2, 'INTERMEDIATE'),
(1, 5, 'BEGINNER'),
(2, 1, 'INTERMEDIATE'),
(2, 3, 'ADVANCED'),
(2, 7, 'INTERMEDIATE'),
(3, 2, 'ADVANCED'),
(3, 4, 'BEGINNER'),
(3, 8, 'INTERMEDIATE'),
(4, 1, 'BEGINNER'),
(4, 5, 'ADVANCED'),
(4, 9, 'INTERMEDIATE'),
(5, 3, 'INTERMEDIATE'),
(5, 6, 'ADVANCED'),
(5, 10, 'BEGINNER'),
(6, 2, 'BEGINNER'),
(6, 4, 'INTERMEDIATE'),
(6, 7, 'ADVANCED'),
(7, 1, 'ADVANCED'),
(7, 6, 'INTERMEDIATE'),
(7, 8, 'BEGINNER'),
(8, 3, 'ADVANCED'),
(8, 5, 'INTERMEDIATE'),
(8, 9, 'BEGINNER'),
(9, 2, 'INTERMEDIATE'),
(9, 6, 'BEGINNER'),
(9, 10, 'ADVANCED'),
(10, 1, 'INTERMEDIATE'),
(10, 4, 'ADVANCED'),
(10, 7, 'BEGINNER'),
(11, 3, 'BEGINNER'),
(11, 5, 'ADVANCED'),
(11, 8, 'INTERMEDIATE'),
(12, 1, 'ADVANCED'),
(12, 4, 'INTERMEDIATE'),
(12, 9, 'BEGINNER'),
(13, 2, 'BEGINNER'),
(13, 6, 'ADVANCED'),
(13, 10, 'INTERMEDIATE'),
(14, 3, 'INTERMEDIATE'),
(14, 7, 'ADVANCED'),
(14, 8, 'BEGINNER'),
(15, 1, 'BEGINNER'),
(15, 5, 'INTERMEDIATE'),
(15, 9, 'ADVANCED'),
(16, 2, 'ADVANCED'),
(16, 4, 'BEGINNER'),
(16, 6, 'INTERMEDIATE'),
(17, 3, 'ADVANCED'),
(17, 8, 'INTERMEDIATE'),
(17, 10, 'BEGINNER'),
(18, 1, 'INTERMEDIATE'),
(18, 5, 'ADVANCED'),
(18, 7, 'BEGINNER'),
(19, 2, 'INTERMEDIATE'),
(19, 6, 'ADVANCED'),
(19, 9, 'BEGINNER'),
(20, 1, 'ADVANCED'),
(20, 4, 'INTERMEDIATE'),
(20, 8, 'BEGINNER'),
(21, 3, 'BEGINNER'),
(21, 5, 'INTERMEDIATE'),
(21, 10, 'ADVANCED'),
(22, 2, 'ADVANCED'),
(22, 7, 'INTERMEDIATE'),
(22, 9, 'BEGINNER'),
(23, 1, 'INTERMEDIATE'),
(23, 6, 'BEGINNER'),
(23, 8, 'ADVANCED'),
(24, 3, 'ADVANCED'),
(24, 4, 'INTERMEDIATE'),
(24, 10, 'BEGINNER'),
(25, 1, 'BEGINNER'),
(25, 5, 'ADVANCED'),
(25, 7, 'INTERMEDIATE'),
(26, 2, 'INTERMEDIATE'),
(26, 6, 'ADVANCED'),
(26, 9, 'BEGINNER'),
(27, 3, 'ADVANCED'),
(27, 8, 'BEGINNER'),
(27, 10, 'INTERMEDIATE'),
(28, 1, 'ADVANCED'),
(28, 4, 'BEGINNER'),
(28, 7, 'INTERMEDIATE'),
(29, 2, 'BEGINNER'),
(29, 5, 'INTERMEDIATE'),
(29, 9, 'ADVANCED'),
(30, 3, 'INTERMEDIATE'),
(30, 6, 'BEGINNER'),
(30, 8, 'ADVANCED'),
(31, 1, 'ADVANCED'),
(31, 5, 'INTERMEDIATE'),
(31, 10, 'BEGINNER'),
(32, 2, 'INTERMEDIATE'),
(32, 4, 'ADVANCED'),
(32, 7, 'BEGINNER'),
(33, 3, 'BEGINNER'),
(33, 6, 'INTERMEDIATE'),
(33, 9, 'ADVANCED'),
(34, 1, 'INTERMEDIATE'),
(34, 8, 'ADVANCED'),
(34, 10, 'BEGINNER'),
(35, 2, 'ADVANCED'),
(35, 5, 'BEGINNER'),
(35, 7, 'INTERMEDIATE'),
(135, 37, 'BEGINNER'),
(136, 1, 'BEGINNER'),
(137, 3, 'BEGINNER'),
(137, 37, 'BEGINNER'),
(137, 42, 'BEGINNER');

--
-- Triggers `userskills`
--
DELIMITER $$
CREATE TRIGGER `before_user_skill_insert` BEFORE INSERT ON `userskills` FOR EACH ROW BEGIN
    DECLARE exists_flag INT;
    SELECT COUNT(*) INTO exists_flag FROM userskills WHERE user_id = NEW.user_id AND skill_id = NEW.skill_id;
    IF exists_flag > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Skill already registered for this user.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `watchlist`
--

CREATE TABLE `watchlist` (
  `watchlist_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `hackathon_id` int(11) NOT NULL,
  `added_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `watchlist`
--

INSERT INTO `watchlist` (`watchlist_id`, `user_id`, `hackathon_id`, `added_at`) VALUES
(4, 2, 3, '2026-07-02 22:41:33'),
(5, 2, 70, '2026-07-04 07:12:05'),
(6, 3, 7, '2026-07-04 21:50:12'),
(7, 3, 75, '2026-07-06 01:18:40'),
(8, 3, 100, '2026-07-06 10:10:15'),
(9, 4, 18, '2026-07-04 00:32:28'),
(10, 4, 94, '2026-07-06 06:44:52'),
(11, 5, 61, '2026-07-05 02:08:10'),
(12, 5, 90, '2026-07-06 07:14:22'),
(13, 6, 15, '2026-07-04 03:25:17'),
(14, 6, 58, '2026-07-05 08:42:03'),
(15, 6, 99, '2026-07-06 11:50:11'),
(16, 7, 10, '2026-07-03 23:11:26'),
(17, 7, 81, '2026-07-05 04:18:55'),
(18, 8, 5, '2026-07-03 22:55:09'),
(19, 8, 100, '2026-07-06 10:44:33'),
(20, 9, 32, '2026-07-05 01:20:41'),
(21, 9, 70, '2026-07-06 05:12:18'),
(22, 10, 25, '2026-07-05 00:35:16'),
(23, 10, 42, '2026-07-06 03:47:59'),
(24, 10, 99, '2026-07-06 22:18:27'),
(25, 11, 48, '2026-07-04 06:05:12'),
(26, 11, 94, '2026-07-06 09:26:30'),
(27, 12, 71, '2026-07-04 21:46:55'),
(28, 12, 96, '2026-07-06 23:33:12'),
(29, 13, 3, '2026-07-05 03:09:21'),
(30, 13, 65, '2026-07-06 07:41:15'),
(31, 14, 22, '2026-07-04 23:15:42'),
(32, 14, 84, '2026-07-06 08:20:18'),
(33, 15, 40, '2026-07-04 22:27:51'),
(34, 15, 98, '2026-07-07 00:12:36'),
(35, 16, 2, '2026-07-05 01:58:20'),
(36, 16, 52, '2026-07-06 05:33:49'),
(37, 17, 56, '2026-07-05 04:48:12'),
(38, 17, 91, '2026-07-06 10:30:22'),
(39, 18, 30, '2026-07-05 00:18:42'),
(40, 18, 82, '2026-07-06 07:15:33'),
(41, 19, 7, '2026-07-04 22:18:45'),
(42, 19, 75, '2026-07-06 07:44:11'),
(43, 19, 100, '2026-07-07 01:30:28'),
(44, 20, 61, '2026-07-04 23:24:16'),
(45, 20, 99, '2026-07-06 08:20:53'),
(46, 21, 17, '2026-07-05 00:15:42'),
(47, 21, 42, '2026-07-06 06:54:08'),
(48, 21, 94, '2026-07-06 22:16:37'),
(49, 22, 13, '2026-07-05 03:27:19'),
(50, 22, 82, '2026-07-06 09:35:40'),
(51, 23, 35, '2026-07-05 01:18:22'),
(52, 23, 96, '2026-07-06 23:47:15'),
(53, 24, 28, '2026-07-05 02:55:08'),
(54, 24, 90, '2026-07-06 07:33:29'),
(55, 24, 100, '2026-07-07 03:25:47'),
(56, 25, 4, '2026-07-04 22:44:51'),
(57, 25, 58, '2026-07-06 05:48:11'),
(58, 26, 27, '2026-07-05 04:32:06'),
(59, 26, 70, '2026-07-06 10:18:39'),
(60, 26, 99, '2026-07-07 00:09:52'),
(61, 27, 11, '2026-07-04 23:58:44'),
(62, 27, 51, '2026-07-06 06:25:17'),
(63, 28, 45, '2026-07-05 03:10:55'),
(64, 28, 88, '2026-07-06 08:37:31'),
(65, 28, 97, '2026-07-07 02:42:24'),
(66, 29, 6, '2026-07-05 00:48:36'),
(67, 29, 76, '2026-07-06 09:26:12'),
(68, 30, 22, '2026-07-05 02:04:15'),
(69, 30, 94, '2026-07-06 07:18:54'),
(70, 31, 53, '2026-07-05 04:16:28'),
(71, 31, 95, '2026-07-06 22:56:43'),
(72, 32, 41, '2026-07-04 23:37:22'),
(73, 32, 81, '2026-07-06 08:48:09'),
(74, 32, 100, '2026-07-07 04:24:51'),
(75, 33, 24, '2026-07-04 22:59:34'),
(76, 33, 68, '2026-07-06 06:43:20'),
(77, 34, 37, '2026-07-05 01:27:58'),
(78, 34, 91, '2026-07-06 23:32:41'),
(79, 35, 9, '2026-07-05 00:41:17'),
(80, 35, 99, '2026-07-06 09:09:36'),
(201, 101, 99, '2026-07-15 17:22:35'),
(211, 1, 1, '2026-07-31 15:53:57'),
(212, 1, 5, '2026-08-03 12:28:36');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `domaininterests`
--
ALTER TABLE `domaininterests`
  ADD PRIMARY KEY (`interest_id`),
  ADD UNIQUE KEY `interest_name` (`interest_name`);

--
-- Indexes for table `hackathondomain`
--
ALTER TABLE `hackathondomain`
  ADD PRIMARY KEY (`hackathon_id`,`interest_id`),
  ADD KEY `interest_id` (`interest_id`);

--
-- Indexes for table `hackathons`
--
ALTER TABLE `hackathons`
  ADD PRIMARY KEY (`hackathon_id`);

--
-- Indexes for table `organization`
--
ALTER TABLE `organization`
  ADD PRIMARY KEY (`organization_id`),
  ADD UNIQUE KEY `1` (`email`);

--
-- Indexes for table `organizationhackthone`
--
ALTER TABLE `organizationhackthone`
  ADD PRIMARY KEY (`hackthone_id`);

--
-- Indexes for table `organization_auditlog`
--
ALTER TABLE `organization_auditlog`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `recommendationlog`
--
ALTER TABLE `recommendationlog`
  ADD PRIMARY KEY (`recommendation_id`),
  ADD UNIQUE KEY `uq_recommendation` (`user_id`,`hackathon_id`),
  ADD KEY `hackathon_id` (`hackathon_id`);

--
-- Indexes for table `registration`
--
ALTER TABLE `registration`
  ADD PRIMARY KEY (`registration_id`);

--
-- Indexes for table `skills`
--
ALTER TABLE `skills`
  ADD PRIMARY KEY (`skill_id`),
  ADD UNIQUE KEY `skill_name` (`skill_name`);

--
-- Indexes for table `teammembers`
--
ALTER TABLE `teammembers`
  ADD PRIMARY KEY (`team_id`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `teams`
--
ALTER TABLE `teams`
  ADD PRIMARY KEY (`team_id`),
  ADD UNIQUE KEY `uq_team` (`hackathon_id`,`team_name`),
  ADD KEY `fk_teams_leader` (`leader_user_id`);

--
-- Indexes for table `userinterests`
--
ALTER TABLE `userinterests`
  ADD PRIMARY KEY (`user_id`,`interest_id`),
  ADD KEY `interest_id` (`interest_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `userskills`
--
ALTER TABLE `userskills`
  ADD PRIMARY KEY (`user_id`,`skill_id`),
  ADD KEY `skill_id` (`skill_id`);

--
-- Indexes for table `watchlist`
--
ALTER TABLE `watchlist`
  ADD PRIMARY KEY (`watchlist_id`),
  ADD UNIQUE KEY `uq_watchlist` (`user_id`,`hackathon_id`),
  ADD KEY `hackathon_id` (`hackathon_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `domaininterests`
--
ALTER TABLE `domaininterests`
  MODIFY `interest_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `hackathons`
--
ALTER TABLE `hackathons`
  MODIFY `hackathon_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=115;

--
-- AUTO_INCREMENT for table `organization`
--
ALTER TABLE `organization`
  MODIFY `organization_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102;

--
-- AUTO_INCREMENT for table `organization_auditlog`
--
ALTER TABLE `organization_auditlog`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `recommendationlog`
--
ALTER TABLE `recommendationlog`
  MODIFY `recommendation_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=301;

--
-- AUTO_INCREMENT for table `registration`
--
ALTER TABLE `registration`
  MODIFY `registration_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=115;

--
-- AUTO_INCREMENT for table `skills`
--
ALTER TABLE `skills`
  MODIFY `skill_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT for table `teams`
--
ALTER TABLE `teams`
  MODIFY `team_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=90;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=138;

--
-- AUTO_INCREMENT for table `watchlist`
--
ALTER TABLE `watchlist`
  MODIFY `watchlist_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=215;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `hackathondomain`
--
ALTER TABLE `hackathondomain`
  ADD CONSTRAINT `hackathondomain_ibfk_1` FOREIGN KEY (`hackathon_id`) REFERENCES `hackathons` (`hackathon_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `hackathondomain_ibfk_2` FOREIGN KEY (`interest_id`) REFERENCES `domaininterests` (`interest_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `recommendationlog`
--
ALTER TABLE `recommendationlog`
  ADD CONSTRAINT `recommendationlog_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `recommendationlog_ibfk_2` FOREIGN KEY (`hackathon_id`) REFERENCES `hackathons` (`hackathon_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `teammembers`
--
ALTER TABLE `teammembers`
  ADD CONSTRAINT `teammembers_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `teams` (`team_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `teammembers_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `teams`
--
ALTER TABLE `teams`
  ADD CONSTRAINT `fk_teams_leader` FOREIGN KEY (`leader_user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `teams_ibfk_1` FOREIGN KEY (`hackathon_id`) REFERENCES `hackathons` (`hackathon_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `userskills`
--
ALTER TABLE `userskills`
  ADD CONSTRAINT `userskills_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `userskills_ibfk_2` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`skill_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
