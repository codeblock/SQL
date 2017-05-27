CREATE TABLE `tb_error` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `err_text` text,
  `err_query` text,
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB COMMENT='for query error';