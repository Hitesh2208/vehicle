create database vehicle_service_db;
use vehicle_service_db;

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `vehicle_service_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SaveCategory` (IN `categoryId` INT, IN `categoryName` VARCHAR(255), IN `categoryDescription` TEXT)   BEGIN
    DECLARE errorMessage VARCHAR(255);

    -- Check if the category already exists
    IF EXISTS (SELECT * FROM categories WHERE category = categoryName AND id != categoryId) THEN
        SELECT 'failed' AS status, 'Category already exists.' AS msg;
    ELSE
        -- Perform the insert or update
        INSERT INTO categories (id, category, description) VALUES (categoryId, categoryName, categoryDescription)
        ON DUPLICATE KEY UPDATE category = categoryName, description = categoryDescription;

        IF ROW_COUNT() > 0 THEN
            SELECT 'success' AS status, IF(categoryId IS NULL, 'New Category successfully saved.', 'Category successfully updated.') AS msg;
        ELSE
            SELECT 'failed' AS status, CONCAT('Error: ', errorMessage) AS msg;
        END IF;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(30) NOT NULL,
  `category` varchar(250) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  `date_created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `category`, `status`, `date_created`) VALUES
(7, '2 wheeler vehicle', 1, '2023-11-21 22:26:10'),
(8, '3 wheeler vehicle', 1, '2023-11-21 22:26:22'),
(9, '4 wheeler vehicle', 1, '2023-11-21 22:26:31'),
(10, '6 wheeler vehicle', 1, '2023-11-21 22:26:40');

-- --------------------------------------------------------

--
-- Table structure for table `mechanics_list`
--

CREATE TABLE `mechanics_list` (
  `id` int(30) NOT NULL,
  `name` text NOT NULL,
  `contact` varchar(50) NOT NULL,
  `email` varchar(150) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  `date_created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `mechanics_list`
--

INSERT INTO `mechanics_list` (`id`, `name`, `contact`, `email`, `status`, `date_created`) VALUES
(3, 'pavan', '9900556622', 'pavan@gmail.com', 0, '2023-11-20 11:03:44'),
(6, 'surya', '9900556624', 'pappuhiteshreddy@gmail.com', 1, '2023-11-22 10:24:42');

--
-- Triggers `mechanics_list`
--
DELIMITER $$
CREATE TRIGGER `prevent_duplicate_contact_email` BEFORE INSERT ON `mechanics_list` FOR EACH ROW BEGIN
    DECLARE contact_count INT;
    DECLARE email_count INT;

    -- Check if the new contact already exists in the table
    SELECT COUNT(*) INTO contact_count
    FROM mechanics_list
    WHERE contact = NEW.contact;

    -- Check if the new email already exists in the table
    SELECT COUNT(*) INTO email_count
    FROM mechanics_list
    WHERE email = NEW.email;

    -- If the contact or email already exists, prevent the insertion
    IF contact_count > 0 OR email_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Two mechanics cannot have the same phone number or email.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `request_meta`
--

CREATE TABLE `request_meta` (
  `request_id` int(30) NOT NULL,
  `meta_field` text NOT NULL,
  `meta_value` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `request_meta`
--

INSERT INTO `request_meta` (`request_id`, `meta_field`, `meta_value`) VALUES
(11, 'contact', '9866267333'),
(11, 'email', 'pappuhiteshreddy@gmail.com'),
(11, 'address', 'vizag'),
(11, 'vehicle_name', 'verna'),
(11, 'vehicle_registration_number', 'AP39CN3456'),
(11, 'vehicle_model', '2019'),
(11, 'service_id', '1'),
(11, 'pickup_address', 'hiol'),
(12, 'contact', '9900556622'),
(12, 'email', 'pappuhiteshreddy@gmail.com'),
(12, 'address', 'blr'),
(12, 'vehicle_name', 'verna'),
(12, 'vehicle_registration_number', 'AP39CN3456'),
(12, 'vehicle_model', '2022'),
(12, 'service_id', '1'),
(12, 'pickup_address', 'blr');

--
-- Triggers `request_meta`
--
DELIMITER $$
CREATE TRIGGER `before_insert_request_meta` BEFORE INSERT ON `request_meta` FOR EACH ROW BEGIN
    DECLARE existing_contact_count INT;

    -- Check if the combination of contact number and vehicle_registration_number already exists
    SELECT COUNT(*) INTO existing_contact_count
    FROM request_meta r1
    JOIN request_meta r2 ON r1.request_id <> r2.request_id
    WHERE r1.meta_field = 'contact' AND r1.meta_value = NEW.meta_value
      AND r2.meta_field = 'vehicle_registration_number' AND r2.meta_value = NEW.meta_value;

    -- If there is an existing combination, prevent the insertion
    IF existing_contact_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Two different contact numbers cannot have the same vehicle registration number.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `service_list`
--

CREATE TABLE `service_list` (
  `id` int(30) NOT NULL,
  `service` text NOT NULL,
  `description` text NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 1,
  `date_created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `service_list`
--

INSERT INTO `service_list` (`id`, `service`, `description`, `status`, `date_created`) VALUES
(1, 'Oil Change', '&lt;p&gt;&lt;span style=&quot;color: rgb(236, 236, 241); font-family: S&ouml;hne, ui-sans-serif, system-ui, -apple-system, &quot;Segoe UI&quot;, Roboto, Ubuntu, Cantarell, &quot;Noto Sans&quot;, sans-serif, &quot;Helvetica Neue&quot;, Arial, &quot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;, &quot;Segoe UI Symbol&quot;, &quot;Noto Color Emoji&quot;; white-space-collapse: preserve; background-color: rgb(52, 53, 65);&quot;&gt;An oil change is like a spa day for your car. It involves draining the old, dirty oil from your engine and replacing it with fresh, clean oil. This process helps to keep your engine running smoothly by reducing friction and preventing wear and tear. It&#039;s a simple but crucial maintenance task that promotes the longevity and efficiency of your vehicle. Plus, it&#039;s a great excuse to pamper your car a bit!&lt;/span&gt;&lt;br&gt;&lt;/p&gt;', 1, '2023-10-30 14:11:38'),
(2, 'Overall Checkup', '&lt;p&gt;&lt;br&gt;&lt;/p&gt;&lt;p&gt;&lt;span style=&quot;color: rgb(236, 236, 241); font-family: S&ouml;hne, ui-sans-serif, system-ui, -apple-system, &amp;quot;Segoe UI&amp;quot;, Roboto, Ubuntu, Cantarell, &amp;quot;Noto Sans&amp;quot;, sans-serif, &amp;quot;Helvetica Neue&amp;quot;, Arial, &amp;quot;Apple Color Emoji&amp;quot;, &amp;quot;Segoe UI Emoji&amp;quot;, &amp;quot;Segoe UI Symbol&amp;quot;, &amp;quot;Noto Color Emoji&amp;quot;; white-space-collapse: preserve; background-color: rgb(52, 53, 65);&quot;&gt;An overall vehicle checkup is like a thorough health check for your car. It involves a meticulous examination of various systems and components to ensure everything is in tip-top shape. Mechanics will inspect key areas such as brakes, tires, suspension, lights, and fluid levels. They&#039;ll also check for any signs of wear and tear, leaks, or potential issues that might be lurking beneath the surface. It&#039;s a preventative measure to catch and address problems early on, keeping your ride safe, reliable, and running smoothly. Consider it a wellness check for your four-wheeled companion!&lt;/span&gt;&lt;br&gt;&lt;/p&gt;', 1, '2023-10-30 14:11:38'),
(3, 'Engine Tune up', '&lt;p&gt;&lt;span style=&quot;color: rgb(236, 236, 241); font-family: S&ouml;hne, ui-sans-serif, system-ui, -apple-system, &amp;quot;Segoe UI&amp;quot;, Roboto, Ubuntu, Cantarell, &amp;quot;Noto Sans&amp;quot;, sans-serif, &amp;quot;Helvetica Neue&amp;quot;, Arial, &amp;quot;Apple Color Emoji&amp;quot;, &amp;quot;Segoe UI Emoji&amp;quot;, &amp;quot;Segoe UI Symbol&amp;quot;, &amp;quot;Noto Color Emoji&amp;quot;; white-space-collapse: preserve; background-color: rgb(52, 53, 65);&quot;&gt;Think of an engine tune-up as a rejuvenating makeover for your car&#039;s heart and soul. It&#039;s a comprehensive maintenance service that goes beyond just changing the oil. During a tune-up, mechanics inspect, adjust, and replace various components to ensure your engine is operating at its best. This can include checking and replacing spark plugs, ignition timing, fuel and air filters, and other vital parts. The goal is to optimize performance, improve fuel efficiency, and reduce emissions. It&#039;s like a spa day for your engine, leaving it refreshed and ready to hit the road with renewed vitality!&lt;/span&gt;&lt;br&gt;&lt;/p&gt;', 1, '2023-10-30 14:12:03'),
(4, 'Tire Replacement', '&lt;p&gt;&lt;span style=&quot;color: rgb(236, 236, 241); font-family: S&ouml;hne, ui-sans-serif, system-ui, -apple-system, &amp;quot;Segoe UI&amp;quot;, Roboto, Ubuntu, Cantarell, &amp;quot;Noto Sans&amp;quot;, sans-serif, &amp;quot;Helvetica Neue&amp;quot;, Arial, &amp;quot;Apple Color Emoji&amp;quot;, &amp;quot;Segoe UI Emoji&amp;quot;, &amp;quot;Segoe UI Symbol&amp;quot;, &amp;quot;Noto Color Emoji&amp;quot;; white-space-collapse: preserve; background-color: rgb(52, 53, 65);&quot;&gt;Tire replacement is like giving your car a new set of shoes for the road. Over time, tires wear down due to regular use, road conditions, and weather. When the tread depth becomes insufficient or if there are signs of damage, it&#039;s time for a tire replacement. This not only ensures optimal traction and handling but also contributes to overall safety on the road. Choosing the right tires for your driving needs and maintaining proper inflation is crucial for a smooth and secure journey. So, think of tire replacement as a stylish and functional wardrobe upgrade for your car!&lt;/span&gt;&lt;br&gt;&lt;/p&gt;', 1, '2023-10-30 14:12:24'),
(5, 'general check up', '&lt;p&gt;ckvhb&lt;/p&gt;', 1, '2023-11-22 10:28:49');

-- --------------------------------------------------------

--
-- Table structure for table `service_requests`
--

CREATE TABLE `service_requests` (
  `id` int(30) NOT NULL,
  `owner_name` text NOT NULL,
  `category_id` int(30) NOT NULL,
  `service_type` text NOT NULL,
  `mechanic_id` int(30) DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 0,
  `date_created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `service_requests`
--

INSERT INTO `service_requests` (`id`, `owner_name`, `category_id`, `service_type`, `mechanic_id`, `status`, `date_created`) VALUES
(11, 'yathindra paladagu', 7, 'Pick Up', 3, 3, '2023-11-21 23:11:57'),
(12, 'prawal chowdary', 7, 'Pick Up', 3, 3, '2023-11-22 10:22:14');

-- --------------------------------------------------------

--
-- Table structure for table `system_info`
--

CREATE TABLE `system_info` (
  `id` int(30) NOT NULL,
  `meta_field` text NOT NULL,
  `meta_value` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `system_info`
--

INSERT INTO `system_info` (`id`, `meta_field`, `meta_value`) VALUES
(1, 'name', 'Vehicle Service Management System'),
(6, 'short_name', 'VSMS - PHP'),
(11, 'logo', 'uploads/1632965940_vrs-logo.jpg'),
(13, 'user_avatar', 'uploads/user_avatar.jpg'),
(14, 'cover', 'uploads/1700453760_lance-asper-N9Pf2J656aQ-unsplash.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(50) NOT NULL,
  `firstname` varchar(250) NOT NULL,
  `lastname` varchar(250) NOT NULL,
  `username` text NOT NULL,
  `password` text NOT NULL,
  `avatar` text DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `type` tinyint(1) NOT NULL DEFAULT 0,
  `date_added` datetime NOT NULL DEFAULT current_timestamp(),
  `date_updated` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `firstname`, `lastname`, `username`, `password`, `avatar`, `last_login`, `type`, `date_added`, `date_updated`) VALUES
(1, 'Adminstrator', 'Admin', 'admin', '1d0f071b6e5428bb961b6714d117a056', 'uploads/1700453700_WhatsApp Image 2023-11-06 at 11.28.37_6a75e492.jpg', NULL, 1, '2021-01-20 14:02:37', '2023-11-20 09:45:35'),
(7, 'Hitesh ', 'Reddy', 'hitesh', '3d2d73252a546471c67243a97458371b', 'uploads/1700458320_DSCN1598.JPG', NULL, 2, '2023-11-20 11:02:05', NULL),
(14, 'ninad', 'n', 'ninad', '81dc9bdb52d04dc20036dbd8313ed055', NULL, NULL, 2, '2023-11-21 12:34:15', NULL),
(15, 'Claire', 'Blake', 'cblake', '3aa49ec6bfc910647fa1c5a013e48eef', NULL, NULL, 2, '2023-11-22 09:43:25', NULL),
(16, 'laire', 'Blake', 'xyz', 'd16fb36f0911f878998c136191af705e', NULL, NULL, 2, '2023-11-22 10:25:57', NULL);

--
-- Triggers `users`
--
DELIMITER $$
CREATE TRIGGER `before_insert_users` BEFORE INSERT ON `users` FOR EACH ROW BEGIN
    DECLARE count_name INT;

    -- Check if there is another user with the same full name
    SELECT COUNT(*) INTO count_name
    FROM users
    WHERE CONCAT(firstname, ' ', lastname) = CONCAT(NEW.firstname, ' ', NEW.lastname);

    -- If there is another user with the same name, raise an error
    IF count_name > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Two users with the same name are not allowed';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_users_check_username` BEFORE INSERT ON `users` FOR EACH ROW BEGIN
    DECLARE count_username INT;

    -- Check if there is another user with the same username
    SELECT COUNT(*) INTO count_username
    FROM users
    WHERE username = NEW.username;

    -- If there is another user with the same username, raise an error
    IF count_username > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Two users with the same username are not allowed';
    END IF;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `mechanics_list`
--
ALTER TABLE `mechanics_list`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `request_meta`
--
ALTER TABLE `request_meta`
  ADD KEY `request_id` (`request_id`);

--
-- Indexes for table `service_list`
--
ALTER TABLE `service_list`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `service_requests`
--
ALTER TABLE `service_requests`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `system_info`
--
ALTER TABLE `system_info`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `mechanics_list`
--
ALTER TABLE `mechanics_list`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `service_list`
--
ALTER TABLE `service_list`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `service_requests`
--
ALTER TABLE `service_requests`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `system_info`
--
ALTER TABLE `system_info`
  MODIFY `id` int(30) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(50) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `request_meta`
--
ALTER TABLE `request_meta`
  ADD CONSTRAINT `request_meta_ibfk_1` FOREIGN KEY (`request_id`) REFERENCES `service_requests` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
