INSERT INTO dw_rep.sales VALUES (1, '2025-03-23 12:20:30', 101, 99.99);
INSERT INTO dw_rep.sales VALUES (1, '2025-03-25 03:15:30', 101, 35.99);
INSERT INTO dw_rep.sales VALUES (3, '2025-02-22 15:36:24', 223, 190.99);
INSERT INTO dw_rep.sales VALUES (3, '2025-02-22 21:05:44', 223, 288.99);
INSERT INTO dw_rep.sales VALUES (4, '2025-02-26 15:06:09', 335, 1050.99);
INSERT INTO dw_rep.sales VALUES (5, '2022-02-26 15:06:09', 111, 1050.99);
INSERT INTO dw_rep.sales VALUES (6, '2023-02-26 15:06:09', 222, 1050.99);
INSERT INTO dw_rep.sales VALUES (10, '2030-02-26 15:06:09', 222, 1050.99);

INSERT INTO dw.sales VALUES (3, '2025-02-22 15:36:24', 223, 190.99);
INSERT INTO dw.sales VALUES (3, '2025-02-22 21:05:44', 223, 288.99);
INSERT INTO dw.sales VALUES (4, '2025-02-26 15:06:09', 335, 1050.99);

INSERT INTO dw.sales VALUES (7, '2029-02-26 15:06:09', 335, 1050.99);
INSERT INTO dw.sales VALUES (8, '2027-02-26 15:06:09', 335, 1050.99);
INSERT INTO dw.sales VALUES (9, '2027-05-26 15:06:09', 335, 1050.99);
INSERT INTO dw.sales VALUES (11, '2036-05-26 15:06:09', 335, 1050.99);


-- Consultar SEM FINALIZE
SELECT * FROM dw_rep.sales ORDER BY sale_id, sale_datetime;
SELECT * FROM dw.sales ORDER BY sale_id, sale_datetime;

-- Consultar com FINALIZE
SELECT * FROM dw_rep.sales FINAL ORDER BY sale_id, sale_datetime;

-- Consultar após OTMIZE
OPTIMIZE TABLE dw_rep.sales FINAL;

SELECT * FROM dw_rep.sales ORDER BY sale_id, sale_datetime;
SELECT * FROM dw.sales ORDER BY sale_id, sale_datetime;
