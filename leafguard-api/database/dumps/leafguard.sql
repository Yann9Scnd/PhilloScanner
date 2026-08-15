-- ============================================================
--  LEAFGUARD / PHYLLOSCANNER - MYSQL DUMP
--  Import via phpMyAdmin (Import) atau:
--    mysql -u root -p < leafguard.sql
--
--  Struktur diselaraskan dengan:
--    - Migrasi Laravel  leafguard-api/database/migrations
--    - Skema SQLite      chiliguard/lib/database/database_helper.dart
--  Setelah import, pastikan .env Laravel memakai:
--    DB_CONNECTION=mysql, DB_DATABASE=leafguard
-- ============================================================

CREATE DATABASE IF NOT EXISTS `leafguard`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `leafguard`;

-- ------------------------------------------------------------
--  USERS & AUTH
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `payload` longtext NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
--  CACHE, QUEUE, JOBS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `jobs` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
--  HASIL SCAN DAUN (ESPA-CAM / APLIKASI) -> HISTORI RIWAYAT
--  image_url: URL foto (data: atau http://<ip-cam>/capture)
--  ai_recommendations: daftar rekomendasi dipisah "||"
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `scan_results` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `device_id` varchar(255) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `disease_name` varchar(255) NOT NULL,
  `scientific_name` varchar(255) NOT NULL,
  `severity` varchar(255) NOT NULL,
  `confidence` smallint UNSIGNED NOT NULL DEFAULT 0,
  `timestamp` varchar(255) NOT NULL,
  `soil_moisture` varchar(255) NOT NULL,
  `sector` varchar(255) NOT NULL DEFAULT 'Greenhouse Sektor A',
  `temperature_at_scan` varchar(255) NOT NULL DEFAULT '28.0',
  `ai_recommendations` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
--  PEMBACAAN SENSOR (TELEMETRI ESP32 NODE 2)
--  Diisi otomatis lewat POST /api/sensor-readings atau /api/telemetry
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sensor_readings` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `device_id` varchar(255) DEFAULT NULL,
  `soil_moisture` varchar(255) DEFAULT NULL,
  `temperature` varchar(255) DEFAULT NULL,
  `air_humidity` varchar(255) DEFAULT NULL,
  `light_intensity` varchar(255) DEFAULT NULL,
  `water_tank_level` varchar(255) DEFAULT NULL,
  `soil_ph` varchar(255) DEFAULT NULL,
  `pump_status` varchar(255) DEFAULT NULL,
  `timestamp` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
--  STATE AKTUATOR (POMPA / MISTING / LAMPU / KIPAS)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `actuator_states` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `pump_auto_mode` tinyint(1) NOT NULL DEFAULT 1,
  `pump_active` tinyint(1) NOT NULL DEFAULT 0,
  `pesticide_active` tinyint(1) NOT NULL DEFAULT 0,
  `laser_active` tinyint(1) NOT NULL DEFAULT 0,
  `led_active` tinyint(1) NOT NULL DEFAULT 0,
  `misting_active` tinyint(1) NOT NULL DEFAULT 1,
  `grow_light_active` tinyint(1) NOT NULL DEFAULT 0,
  `fan_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
