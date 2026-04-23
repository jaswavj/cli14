-- ─────────────────────────────────────────────────────────────────────────────
--  Purchase Edit / Cancel / Return - Database Migration
--  Run this script once.
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. Add is_cancelled column to prod_purchase_details
ALTER TABLE `prod_purchase_details`
  ADD COLUMN `is_cancelled` TINYINT(1) NOT NULL DEFAULT 0
  COMMENT '1 = this item was cancelled';

-- 2. Audit table for price edits and cancellations
CREATE TABLE IF NOT EXISTS `prod_purchase_edit_log` (
  `id`                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `purchase_id`         INT NOT NULL,
  `purchase_detail_id`  INT NOT NULL,
  `product_id`          INT NOT NULL,
  `edit_type`           ENUM('price_edit','cancel') NOT NULL,
  `old_rate`            DOUBLE DEFAULT NULL,
  `new_rate`            DOUBLE DEFAULT NULL,
  `old_mrp`             DOUBLE DEFAULT NULL,
  `new_mrp`             DOUBLE DEFAULT NULL,
  `qty`                 DOUBLE DEFAULT NULL,
  `reason`              TEXT DEFAULT NULL,
  `uid`                 INT NOT NULL,
  `date_time`           DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `purchase_id` (`purchase_id`),
  KEY `product_id`  (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Purchase return header
CREATE TABLE IF NOT EXISTS `prod_purchase_return` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `return_no`    VARCHAR(50) DEFAULT NULL,
  `purchase_id`  INT NOT NULL,
  `supplier_id`  INT DEFAULT NULL,
  `total`        DOUBLE DEFAULT 0,
  `notes`        TEXT DEFAULT NULL,
  `uid`          INT NOT NULL,
  `date_time`    DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `purchase_id`  (`purchase_id`),
  KEY `supplier_id`  (`supplier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Purchase return line items
CREATE TABLE IF NOT EXISTS `prod_purchase_return_details` (
  `id`                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `return_id`           INT NOT NULL,
  `purchase_detail_id`  INT NOT NULL,
  `product_id`          INT NOT NULL,
  `qty`                 DOUBLE DEFAULT 0,
  `rate`                DOUBLE DEFAULT 0,
  `total`               DOUBLE DEFAULT 0,
  `uid`                 INT NOT NULL,
  `date_time`           DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `return_id`          (`return_id`),
  KEY `purchase_detail_id` (`purchase_detail_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
