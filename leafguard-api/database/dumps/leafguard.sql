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
--  APLIKASI: DATASET PENYAKIT DAUN CABAI
--  (Gunakan filter kategori: Jamur, Bakteri, Virus, Hama)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `diseases` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `scientific_name` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `symptoms` text NOT NULL,
  `prevention_steps` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `diseases`
  (`name`, `scientific_name`, `category`, `image_url`, `description`, `symptoms`, `prevention_steps`, `created_at`, `updated_at`)
VALUES
('Bercak Daun (Leaf Spot)', 'Cercospora capsici', 'Jamur', 'https://placehold.co/600x400/7CBF8A/FFFFFF?text=Bercak%20Daun', 'Penyakit bercak daun disebabkan jamur Cercospora capsici yang menyerang daun cabai. Muncul bercak cokelat keabu-abuan yang menyebar dari daun bagian bawah ke atas.', 'Bercak lingkaran kecil cokelat tua dengan pusat kelabu, daun menguning lalu rontok.', 'Pilih benih varietas tahan penyakit.||Atur jarak tanam agar sirkulasi udara lancar.||Hindari penyiraman dari atas daun dan jaga kebersihan lahan.', NOW(), NOW()),
('Karat Daun (Rust)', 'Puccinia sorghi', 'Jamur', 'https://placehold.co/600x400/7CBF8A/FFFFFF?text=Karat%20Daun', 'Penyakit karat menyerang daun dengan bintik oranye keemasan seperti karat pada permukaan bawah daun, umum muncul pada musim lembap.', 'Pustul berisi spora berwarna serbuk karat cokelat kemerahan di permukaan bawah daun.', 'Gunakan varietas tahan karat.||Lakukan rotasi tanaman secara teratur.||Jaga sirkulasi udara dan hindari kelembapan berlebih.', NOW(), NOW()),
('Layu Fusarium', 'Fusarium oxysporum', 'Jamur', 'https://placehold.co/600x400/7CBF8A/FFFFFF?text=Layu%20Fusarium', 'Penyakit layu yang disebabkan jamur tanah Fusarium oxysporum. Tanaman layu mendadak dan pembuluh batang berwarna cokelat.', 'Daun bawah menguning lalu layu, batang tampak cekung, dan pangkal batang membusuk.', 'Gunakan benih sehat dan varietas tahan layu.||Sterilkan media tanam dengan cara solarisasi.||Cabut dan musnahkan tanaman yang terinfeksi.', NOW(), NOW()),
('Antraknosa (Patek)', 'Colletotrichum capsici', 'Jamur', 'https://placehold.co/600x400/7CBF8A/FFFFFF?text=Antraknosa', 'Penyakit patek menyerang buah dan daun cabai. Bercak cokelat dengan pusat lebih gelap seperti cincin dan buah membusuk berlendir.', 'Bercak cekung cokelat pada buah dengan cincin spora oranye kemerahan, daun menguning.', 'Gunakan fungisida nabati seperti ekstrak bawang putih.||Panen tepat waktu dan buang buah yang terserang.||Jaga kebersihan alat dan gulma sekitar lahan.', NOW(), NOW()),
('Busuk Akar (Root Rot)', 'Pythium spp.', 'Bakteri', 'https://placehold.co/600x400/6B8FBF/FFFFFF?text=Busuk%20Akar', 'Busuk akar berkembang akibat media tanam terlalu basah dan serangan patogen tanah. Akar membusuk sehingga tanaman tidak dapat menyerap air.', 'Daun menguning tiba-tiba, layu, dan batang bagian bawah lembek berair.', 'Atur drainase pot atau media tanam.||Hentikan penyiraman sementara hingga media agak kering.||Gunakan agen hayati Trichoderma pada media tanam.', NOW(), NOW()),
('Layu Bakteri', 'Ralstonia solanacearum', 'Bakteri', 'https://placehold.co/600x400/6B8FBF/FFFFFF?text=Layu%20Bakteri', 'Penyakit layu bakteri yang mematikan pada cabai. Bakteri menyumbat pembuluh sehingga tanaman layu permanen meski tanah lembap.', 'Layu cepat tanpa daun menguning, batang dipotong mengeluarkan lendir putih, akar membusuk.', 'Gunakan varietas tahan dan benih bebas penyakit.||Lakukan rotasi dengan tanaman bukan golongan terong-terongan.||Solarisasi tanah sebelum penanaman.', NOW(), NOW()),
('Bercak Bakteri', 'Xanthomonas campestris', 'Bakteri', 'https://placehold.co/600x400/6B8FBF/FFFFFF?text=Bercak%20Bakteri', 'Bercak bakteri menyerang daun dan buah. Bercak cokelat basah dengan tepi kuning yang dapat menyebabkan daun gugur.', 'Bercak kecil berair cokelat yang menyatu, daun keriting dan rontok.', 'Gunakan benih bebas penyakit.||Hindari penyiraman dengan percikan air.||Pisahkan dan buang tanaman yang sakit.', NOW(), NOW()),
('Virus Mosaik', 'Cucumber mosaic virus (CMV)', 'Virus', 'https://placehold.co/600x400/C9A86B/FFFFFF?text=Virus%20Mosaik', 'Virus mosaik disebarkan oleh kutu daun. Daun tampak belang-belang kuning-hijau, tanaman kerdil, dan buah kecil tidak normal.', 'Daun belang mosaik, keriting, tepi menggulung, dan tanaman kerdil.', 'Kendalikan kutu daun sebagai vektor penyebar virus.||Gunakan benih bebas virus.||Cabut tanaman terinfeksi segera.', NOW(), NOW()),
('Daun Keriting Kuning (Virus Kuning)', 'Begomovirus (PepYLCV)', 'Virus', 'https://placehold.co/600x400/C9A86B/FFFFFF?text=Virus%20Kuning', 'Penyakit kuning keriting disebarkan kutu kebul. Daun muda menguning dan mengeriting sehingga pertumbuhan terhambat.', 'Daun muda menguning dan mengeriting, tanaman kerdil, dan bunga rontok.', 'Pasang perangkap kuning untuk menangkap kutu kebul.||Tutup lahan dengan mulsa plastik perak.||Gunakan varietas tahan virus kuning.', NOW(), NOW()),
('Kutu Daun (Aphid)', 'Myzus persicae', 'Hama', 'https://placehold.co/600x400/C97B6B/FFFFFF?text=Kutu%20Daun', 'Serangan hama kutu daun mengisap cairan tanaman dan menjadi vektor virus. Koloni kutu tampak di pucuk dan daun muda.', 'Daun keriting dan lengket (embun madu), pucuk pertumbuhan terhambat.', 'Kendalikan dengan predator alami seperti kepik.||Semprot air sabun atau pestisida nabati.||Jaga kebersihan gulma di sekitar lahan.', NOW(), NOW());

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
  `misting_active` tinyint(1) NOT NULL DEFAULT 1,
  `grow_light_active` tinyint(1) NOT NULL DEFAULT 0,
  `fan_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
