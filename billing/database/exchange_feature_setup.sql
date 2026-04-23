-- ─────────────────────────────────────────────────────────────────────────────
--  Exchange Feature - Database Migration
--  Run this script once to add required columns and tables.
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. Add is_exchanged column to prod_bill_details
ALTER TABLE `prod_bill_details`
  ADD COLUMN `is_exchanged` TINYINT(1) NOT NULL DEFAULT 0
  COMMENT '1 = this item was exchanged via the Exchange feature';

-- 2. Create pro_bill_exchange table
CREATE TABLE IF NOT EXISTS `pro_bill_exchange` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `bill_id`     INT NOT NULL,
  `customer_id` INT DEFAULT NULL,
  `old_prod_id` INT NOT NULL,
  `new_prod_id` INT NOT NULL,
  `uid`         INT NOT NULL,
  `date_time`   DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bill_id`     (`bill_id`),
  KEY `customer_id` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Create customers_exchange_point table
CREATE TABLE IF NOT EXISTS `customers_exchange_point` (
  `id`             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id`    INT NOT NULL,
  `bill_id`        INT NOT NULL,
  `old_point`      DOUBLE(10,3) DEFAULT '0.000',
  `exchange_point` DOUBLE(10,3) DEFAULT '0.000',
  `total_point`    DOUBLE(10,3) DEFAULT '0.000',
  `uid`            INT DEFAULT NULL,
  `date_time`      DATETIME DEFAULT NULL,
  `notes`          TEXT DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `bill_id`     (`bill_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3a. Add notes column if table already exists (run if upgrading):
-- ALTER TABLE `customers_exchange_point` ADD COLUMN `notes` TEXT DEFAULT NULL;

-- 4. Add exchange_point column to customers (if not already present)
--    Uncomment if the column doesn't exist yet:
-- ALTER TABLE `customers` ADD COLUMN `exchange_point` DOUBLE DEFAULT 0;
