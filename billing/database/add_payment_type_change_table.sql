-- ============================================================
-- Table: prod_bill_payment_type_change
-- Purpose: Audit log for payment type / amount changes on bills
-- ============================================================
CREATE TABLE IF NOT EXISTS `prod_bill_payment_type_change` (
  `id`               int unsigned NOT NULL AUTO_INCREMENT,
  `bill_id`          int          NOT NULL,
  `old_cash_amount`  double(10,3) DEFAULT NULL,
  `cash_amount`      double(10,3) DEFAULT NULL,
  `old_bank_amount`  double(10,3) DEFAULT NULL,
  `bank_amount`      double(10,3) DEFAULT NULL,
  `bank_mode`        int          DEFAULT NULL,
  `uid`              int          DEFAULT NULL,
  `date_time`        datetime     DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
