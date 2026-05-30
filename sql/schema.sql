-- ============================================================
--  Eiseb Country Traders — Livestock Financial System
--  Database: eiseb_lfs
-- ============================================================

CREATE DATABASE IF NOT EXISTS eiseb_lfs
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE eiseb_lfs;

-- ── USERS ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  full_name    VARCHAR(100) NOT NULL,
  username     VARCHAR(50)  NOT NULL UNIQUE,
  email        VARCHAR(150) NOT NULL UNIQUE,
  password     VARCHAR(255) NOT NULL,   -- BCrypt hash
  role         ENUM('admin','manager','staff') DEFAULT 'staff',
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ── LIVESTOCK ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS livestock (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  tag          VARCHAR(20)  NOT NULL UNIQUE,
  species      ENUM('Cattle','Goat','Sheep') NOT NULL,
  breed        VARCHAR(80),
  gender       ENUM('Male','Female') NOT NULL,
  dob          DATE,
  current_value DECIMAL(12,2) DEFAULT 0.00,
  status       ENUM('Active','Sold','Deceased') DEFAULT 'Active',
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ── VALUATIONS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS valuations (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  livestock_id INT NOT NULL,
  val_date     DATE NOT NULL,
  value        DECIMAL(12,2) NOT NULL,
  method       VARCHAR(100),
  notes        TEXT,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (livestock_id) REFERENCES livestock(id) ON DELETE CASCADE
);

-- ── SALES ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sales (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  livestock_id INT NOT NULL,
  buyer        VARCHAR(120) NOT NULL,
  sale_type    ENUM('Auction','Direct','Export') DEFAULT 'Direct',
  sale_date    DATE NOT NULL,
  price        DECIMAL(12,2) NOT NULL,
  payment_status ENUM('Paid','Pending','Partial') DEFAULT 'Pending',
  notes        TEXT,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (livestock_id) REFERENCES livestock(id) ON DELETE RESTRICT
);

-- ── EXPENSES ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS expenses (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  category     ENUM('Feed','Vet','Transport','Wages','Equipment','Other') DEFAULT 'Other',
  amount       DECIMAL(12,2) NOT NULL,
  expense_date DATE NOT NULL,
  description  VARCHAR(255),
  livestock_id INT DEFAULT NULL,   -- optional link to an animal
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (livestock_id) REFERENCES livestock(id) ON DELETE SET NULL
);

-- ── ENQUIRIES ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS enquiries (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  full_name    VARCHAR(100) NOT NULL,
  email        VARCHAR(150) NOT NULL,
  subject      VARCHAR(200),
  message      TEXT NOT NULL,
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  SEED DATA
-- ============================================================

-- Default admin user  (password: admin123  — BCrypt)
INSERT IGNORE INTO users (full_name, username, email, password, role) VALUES
  ('Admin User', 'admin', 'admin@eiseb.na',
   '$2a$12$QGtKlMz9mZuVp3BEhHG0Ou2hqM1P6JQHv0dSOHPf0sJj70wDwRcaW', 'admin');

-- Livestock
INSERT IGNORE INTO livestock (tag, species, breed, gender, dob, current_value, status) VALUES
  ('ECT-001','Cattle','Brahman',    'Male',  '2021-03-10', 12000.00, 'Active'),
  ('ECT-002','Cattle','Nguni',      'Female','2020-07-22', 10500.00, 'Active'),
  ('ECT-003','Goat',  'Boer',       'Female','2022-01-05',  3200.00, 'Active'),
  ('ECT-004','Cattle','Simmentaler','Male',  '2019-11-15', 15000.00, 'Sold'),
  ('ECT-005','Sheep', 'Damara',     'Male',  '2022-05-30',  2800.00, 'Active'),
  ('ECT-006','Cattle','Hereford',   'Female','2021-08-18', 11200.00, 'Active'),
  ('ECT-007','Goat',  'Kalahari Red','Male', '2023-02-12',  2500.00, 'Deceased');

-- Sales
INSERT IGNORE INTO sales (livestock_id, buyer, sale_type, sale_date, price, payment_status, notes) VALUES
  (4, 'Agra Cooperative',  'Auction', '2024-08-14', 18500.00, 'Paid',    'Sold at monthly auction'),
  (1, 'MeatCo Namibia',    'Direct',  '2024-09-01', 12000.00, 'Pending', 'Awaiting payment confirmation'),
  (3, 'Local Smallholder', 'Direct',  '2024-09-10',  3200.00, 'Partial', 'Deposit received');

-- Expenses
INSERT IGNORE INTO expenses (category, amount, expense_date, description, livestock_id) VALUES
  ('Feed',      4500.00, '2024-07-01', 'Monthly hay and pellets supply',  NULL),
  ('Vet',        850.00, '2024-07-15', 'Vaccination drive — all cattle',  NULL),
  ('Transport',  1200.00,'2024-08-14', 'Truck hire to Agra auction',       4),
  ('Wages',      6000.00,'2024-08-31', 'Monthly farm-hand wages',         NULL),
  ('Equipment',  2300.00,'2024-09-05', 'Fence repair materials',          NULL),
  ('Feed',       4500.00,'2024-09-01', 'Monthly hay and pellets supply',  NULL);
