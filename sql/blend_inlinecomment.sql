
SET NAMES utf8;

-- ----------------------------
--  Table structure for `blend_inlinecomment`
-- ----------------------------
DROP TABLE IF EXISTS `blend_inlinecomment`;
CREATE TABLE `blend_inlinecomment` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `user_id` int(10) DEFAULT NULL,
  `author` varchar(255) DEFAULT NULL,
  `contentobjectattribute_id` int(10) NOT NULL,
  `version` int(8) NOT NULL,
  `comment` text,
  `language` varchar(8) NOT NULL,
  `added_at` int(10) NOT NULL,
  `reply_to` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

