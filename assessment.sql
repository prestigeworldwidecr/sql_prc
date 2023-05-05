
/*
#   Filename: assessment.sql                                   
#   Author: Craig Saiz                                         
#   Date: 04-may-2023                                          
#   Purpose: Each row of table trucks contains information about a single trucks’ origin (origin), destination (destination) and time of departure (time). 
#	Each row of table products describes a single product and contains information about the warehouse they're traveling from (origin), the store they're traveling to (destination) and the time they will arrive at the departure warehouse (time). Products will be loaded on the earliest possible truck that travels directly to their desired destination. Products can still be loaded on a truck if it departs in the same minute that they arrive at the warehouse's loading bay. All products which are still at the warehouse at 23:59 and are not loaded on any of the 23:59 trucks will stay at the warehouse without being loaded on any truck.
#	You can assume that no two trucks with the same origin and destination depart at the same time.
#	Write an SQL query that, for each truck, returns the number of products loaded on it. For each truck you should provide its id (id) and the number of products loaded (products_loaded). Rows should be ordered by the id column (in ascending order).
#	Time is represented as a string in the format HH:MM.
*/

select 1
;

CREATE TABLE trucks 
(
	id INTEGER PRIMARY KEY,
	origin VARCHAR(255) NOT NULL,
	destination VARCHAR(255) NOT NULL,
	time VARCHAR(255) NOT NULL,
	unique (origin, destination, time)
)
;

DROP TABLE trucks
;

CREATE TABLE products 
(
	id INTEGER PRIMARY KEY,
	origin VARCHAR(255) NOT NULL,
	destination VARCHAR(255) NOT NULL,
	time VARCHAR(255) NOT NULL
)
;

DROP TABLE products
;

INSERT INTO trucks
(id, origin, destination, time)
VALUES
(10, 'Warehouse A', 'Store 3', '10:55'),
(20, 'Warehouse B', 'Store 112', '06:20'),
(21, 'Warehouse B', 'Store 112', '14:00'),
(22, 'Warehouse B', 'Store 112', '21:40'),
(30, 'Warehouse C', 'Store 121', '13:30')
;

INSERT INTO products
(id, origin, destination, time)
VALUES
(1, 'Warehouse C', 'Store 121', '13:30'),
(2, 'Warehouse C', 'Store 121', '13:31'),
(10, 'Warehouse A', 'Store 112', '10:00'),
(11, 'Warehouse A', 'Store 3', '22:31'),
(40, 'Warehouse B', 'Store 112', '06:15'),
(41, 'Warehouse B', 'Store 112', '06:50'),
(42, 'Warehouse B', 'Store 112', '07:12'),
(43, 'Warehouse B', 'Store 112', '12:03'),
(44, 'Warehouse B', 'Store 112', '20:00')
;

INSERT INTO trucks
(id, origin, destination, time)
VALUES
(100, 'Warehouse X', 'Store 233', '13:00'),
(200, 'Warehouse X', 'Store 233', '15:30'),
(300, 'Warehouse X', 'Store 233', '20:00')
;

INSERT INTO products
(id, origin, destination, time)
VALUES
(1, 'Warehouse X', 'Store 233', '10:01'),
(2, 'Warehouse X', 'Store 233', '11:30'),
(3, 'Warehouse X', 'Store 233', '11:30'),
(4, 'Warehouse X', 'Store 233', '12:03'),
(5, 'Warehouse X', 'Store 233', '13:00')
;

SELECT *
FROM trucks
;

SELECT *
FROM products
;

/*
	Write an SQL query that, for each truck, returns the number of products loaded on it. 
	For each truck you should provide its id (id) and the number of products loaded (products_loaded). 
	Rows should be ordered by the id column (in ascending order).
*/

-- build query w/accurate table selections, connections
-- ensure *no Cartesian product

SELECT DISTINCT
t1.id AS truck_id
, t1.origin AS truck_origin
, t1.destination AS truck_destination
, REPLACE(t1.time, ':', '') AS truck_time
, t2.id AS product_id
, t2.origin AS product_origin
, t2.destination AS product_destination
, REPLACE(t2.time, ':', '') AS product_time
FROM trucks AS t1 
LEFT JOIN products AS t2 ON t1.origin = t2.origin
AND t1.destination = t2.destination
AND t1.time >= t2.time
ORDER BY truck_id, truck_time, product_time ASC
;

DROP TABLE v1
;

CREATE VIEW v1 AS
SELECT *
FROM
(SELECT DISTINCT
t1.id AS truck_id
, t2.id AS product_id
, REPLACE(t1.time, ':', '') AS truck_time
, REPLACE(t2.time, ':', '') AS product_time
FROM trucks AS t1 
LEFT JOIN products AS t2 ON t1.origin = t2.origin
AND t1.destination = t2.destination
AND t1.time >= t2.time
ORDER BY truck_id, truck_time, product_time ASC) AS v1
;

SELECT *
FROM v1
;

DROP VIEW v2
;

CREATE VIEW v2 AS
SELECT DISTINCT
product_id
, MIN(truck_time) AS min_truck_time
FROM v1
GROUP BY (v1.product_id)
ORDER BY 1
;

SELECT *
FROM v2
;

DROP VIEW v3
;

CREATE VIEW v3 AS
SELECT DISTINCT
t1.truck_id
, t1.product_id
FROM v1 AS t1
LEFT JOIN v2 AS t2 ON t1.product_id = t2.product_id
AND t1.truck_time = t2.min_truck_time
WHERE t2.min_truck_time IS NOT NULL
;

SELECT *
FROM v3
;

SELECT DISTINCT
t2.id AS id
, (CASE WHEN products_loaded IS NULL
		THEN 0
		ELSE products_loaded
		END) AS products_loaded
FROM trucks AS t2
LEFT JOIN
(SELECT DISTINCT
t1.truck_id AS id
, COUNT(t1.product_id) AS products_loaded
FROM v3 as t1
GROUP BY (t1.truck_id)
ORDER BY 1) AS t3 ON t2.id = t3.id
;