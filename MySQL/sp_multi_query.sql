CREATE PROCEDURE `sp_multi_query`(
    IN `queries` TEXT,
    IN _transaction BOOL
)
    COMMENT 'multiple works with plain query'
BEGIN
    DECLARE seperator CHAR(3) DEFAULT ';';
    DECLARE inserted  TEXT DEFAULT '';
    
    DECLARE EXIT HANDLER FOR SQLWARNING, SQLEXCEPTION
    BEGIN
        IF _transaction = FALSE THEN
            ROLLBACK;
            
            /*
             * GET DIAGNOSTICS statement is not supported until MySQL 5.6
             * 
            GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
            SET @error = CONCAT("sp_multi_query error | ", "ERROR ", @errno, " (", @sqlstate, "): ", @text);
            INSERT INTO tb_error ( err_text, err_query ) values ( @error, queries );
            
            SELECT @errno AS 'errno', @sqlstate AS 'sqlstate', @text AS 'error', inserted FROM DUAL;
             */
            RESIGNAL;
        ELSE
            RESIGNAL;
        END IF;
    END;
    
    IF _transaction = FALSE THEN START TRANSACTION; END IF;
    
    SET @queries         = queries;
    SET @insertid_before = LAST_INSERT_ID(); -- for insert
    
    WHILE (LENGTH(@queries) > 0)
    DO
        SET @queries_each = SUBSTRING(@queries,                               1, LOCATE(seperator, @queries) - 1);
        SET @queries      = SUBSTRING(@queries, LOCATE(seperator, @queries) + 1);
        
        IF @queries_each = '' THEN
            SET @queries_each = SUBSTRING(@queries, 1);
            SET @queries      = '';
        END IF;
        
        PREPARE stmt FROM @queries_each;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        SET @insertid_after = LAST_INSERT_ID();
        IF @insertid_before != @insertid_after THEN
            SET inserted         = CONCAT(inserted, ',', @insertid_after);
            SET @insertid_before = @insertid_after;
        END IF;
    END WHILE;
    
    IF _transaction = FALSE THEN COMMIT; END IF;
    
    SET inserted = SUBSTRING(inserted, 2);
    SET @insertid_before = 0;
    SET @insertid_after  = 0;
    
    SELECT 0 AS 'errno', '' AS 'sqlstate', '' AS 'error', inserted FROM DUAL;
    
END
