## start-of-pk-position-in-join

### Version

```sql
SELECT VERSION();

+------------+
| VERSION()  |
+------------+
| 5.7.32-log |
+------------+
```

### DDL

```sql
CREATE TABLE `tb_driving` (
  `id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE `tb_driven` (
  `fk` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  KEY `tb_driven_ibfk_1` (`fk`),
  CONSTRAINT `tb_driven_ibfk_1` FOREIGN KEY (`fk`) REFERENCES `tb_driving` (`id`)
);
```

### DML

```sql
INSERT INTO tb_driving VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9);
INSERT INTO tb_driven VALUES
 (1,1)
,(1,2)
,(1,3)
,(2,4)
,(1,5)
,(2,6)
,(2,7)
,(1,8)
,(1,9)
,(3,10)
,(2,11)
,(3,12)
,(3,13)
,(3,14)
,(3,15)
;
```

### SELECT

```sql
SELECT
     1 dummy
    ,CONCAT((@pk_prev := @pk_curr), NULL) calc_prev
    ,CONCAT((@pk_curr := a.id    ), NULL) calc_curr
    -- ,@pk_prev
    -- ,@pk_curr
    ,(CASE WHEN @pk_prev != @pk_curr THEN CONCAT('-------------- ', @pk_curr) ELSE '' END) started_pk
    ,a.id a_pk -- , a.field_2, ...
    ,b.id b_pk -- , b.field_2, ...
FROM
    tb_driving a
    INNER JOIN (SELECT @pk_prev := 0, @pk_curr := 0 FROM DUAL) r
    -- INNER JOIN tb_driven b FORCE INDEX(tb_driven_ibfk_1) ON b.fk = a.id
    STRAIGHT_JOIN tb_driven b ON b.fk = a.id
-- WHERE
--    a.cond_1 = 'it is conditions'
;

+-------+-----------+-----------+------------------+------+------+
| dummy | calc_prev | calc_curr | started_pk       | a_pk | b_pk |
+-------+-----------+-----------+------------------+------+------+
|     1 | NULL      | NULL      | -------------- 1 |    1 |    1 |
|     1 | NULL      | NULL      |                  |    1 |    2 |
|     1 | NULL      | NULL      |                  |    1 |    3 |
|     1 | NULL      | NULL      |                  |    1 |    5 |
|     1 | NULL      | NULL      |                  |    1 |    8 |
|     1 | NULL      | NULL      |                  |    1 |    9 |
|     1 | NULL      | NULL      | -------------- 2 |    2 |    4 |
|     1 | NULL      | NULL      |                  |    2 |    6 |
|     1 | NULL      | NULL      |                  |    2 |    7 |
|     1 | NULL      | NULL      |                  |    2 |   11 |
|     1 | NULL      | NULL      | -------------- 3 |    3 |   10 |
|     1 | NULL      | NULL      |                  |    3 |   12 |
|     1 | NULL      | NULL      |                  |    3 |   13 |
|     1 | NULL      | NULL      |                  |    3 |   14 |
|     1 | NULL      | NULL      |                  |    3 |   15 |
+-------+-----------+-----------+------------------+------+------+
```
