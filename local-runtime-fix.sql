-- VOSTOK local runtime compatibility tables/fixes.
CREATE TABLE IF NOT EXISTS `reports_list` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL DEFAULT 0,
  `player_name` varchar(24) NOT NULL,
  `player_id` int(11) NOT NULL DEFAULT 0,
  `kind` varchar(8) NOT NULL DEFAULT 'report',
  `text` varchar(144) NOT NULL DEFAULT '',
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint(4) NOT NULL DEFAULT 0,
  `admin` int(11) NOT NULL DEFAULT 0,
  `answer` varchar(144) NOT NULL DEFAULT '',
  `answer_by_name` varchar(24) NOT NULL DEFAULT '',
  `answer_by_account_id` int(11) NOT NULL DEFAULT 0,
  `answered_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `kind_status_admin` (`kind`,`status`,`admin`),
  KEY `player_name` (`player_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `reports_list` ENGINE=InnoDB;
ALTER TABLE `reports_list` ADD COLUMN IF NOT EXISTS `account_id` int(11) NOT NULL DEFAULT 0 AFTER `id`;
ALTER TABLE `reports_list` ADD COLUMN IF NOT EXISTS `kind` varchar(8) NOT NULL DEFAULT 'report' AFTER `player_id`;
ALTER TABLE `reports_list` ADD COLUMN IF NOT EXISTS `answer` varchar(144) NOT NULL DEFAULT '' AFTER `admin`;
ALTER TABLE `reports_list` ADD COLUMN IF NOT EXISTS `answer_by_name` varchar(24) NOT NULL DEFAULT '' AFTER `answer`;
ALTER TABLE `reports_list` ADD COLUMN IF NOT EXISTS `answer_by_account_id` int(11) NOT NULL DEFAULT 0 AFTER `answer_by_name`;
ALTER TABLE `reports_list` ADD COLUMN IF NOT EXISTS `answered_at` datetime NULL DEFAULT NULL AFTER `answer_by_account_id`;


-- Keep action_log usable even if an old local dump lost AUTO_INCREMENT.
ALTER TABLE `action_log`
  MODIFY COLUMN `i` int(11) NOT NULL AUTO_INCREMENT;

UPDATE `server` SET `server_open`=1;

-- Local founder account. This is intentionally repeated at every local start so
-- old database values cannot silently take the founder/admin access away.
UPDATE `v2_account_permissions` p
JOIN `v2_accounts` a ON a.`id`=p.`account_id`
SET p.`admin`=6,
    p.`dostup`=1,
    p.`tester`=1,
    p.`helper`=1,
    p.`admin_warn`=0,
    p.`cmdaccess`='111111'
WHERE a.`name`='Kenar_Meander';
