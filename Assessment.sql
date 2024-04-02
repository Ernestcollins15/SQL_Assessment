-- Creating the client table
CREATE TABLE client (
     client_id SERIAL PRIMARY KEY
    ,first_name VARCHAR(50)
    ,middle_name VARCHAR(50)
    ,last_name VARCHAR(50)
    ,date_of_birth DATE
);

-- Creating the loan table
CREATE TABLE loan (
    loan_id SERIAL PRIMARY KEY
   ,client_id INT REFERENCES client(client_id)
   ,vehicle_id INT
   ,principal_amount NUMERIC
   ,submitted_on_date DATE
);

-- Creating the vehicle table
CREATE TABLE vehicle (
     vehicle_id SERIAL PRIMARY KEY
    ,make VARCHAR(50)
    ,model_name VARCHAR(50)
);

-- Inserting data into the client table
INSERT INTO client (client_id, first_name, middle_name, last_name, date_of_birth) VALUES
(33, 'Susan', 'Mapenzi', 'Marigu', '1974-06-11'),
(35, 'Paul', NULL, 'Pogba', '1993-03-15'),
(36, 'Hafsa', 'Wangui', 'Munga', '1987-05-07'),
(37, 'Everlyne', NULL, 'Maten''ge', '1973-02-27'),
(38, 'Barack', NULL, 'Obama', '1961-08-04'),
(39, 'Prudence', 'Salim', 'Okeyo', '1985-02-16'),
(40, 'Rosemary', 'Pauline', 'Kinyua', '1977-01-27'),
(42, 'Elizabeth', NULL, 'Mbaji', '1975-10-03'),
(43, 'Johny', 'Paul', 'Orengo', '1971-07-29'),
(44, 'Merceline', 'Lucy', 'Njenga', '1982-04-21');

-- Inserting data into the loan table
INSERT INTO loan (loan_id, client_id, vehicle_id, principal_amount, submitted_on_date) VALUES
(75676, 33, 24, 106500, '2019-05-02'),
(75659, 35, 26, 108400, '2020-12-05'),
(75685, 36, 27, 101500, '2019-05-02'),
(75657, 37, 28, 271482, '2019-06-21'),
(75662, 38, 29, 114400, '2019-05-02'),
(75660, 39, 30, 95300, '2019-05-02'),
(75656, 40, 31, 78500, '2019-05-02'),
(75666, 42, 32, 111800, '2019-05-02'),
(75658, 43, 33, 107050, '2019-05-02'),
(75663, 44, 34, 101800, '2019-05-02');

-- Inserting data into the vehicle table
INSERT INTO vehicle (vehicle_id, make, model_name) VALUES
(24, 'Haojin', 'HJ 150CC-11A'),
(26, 'Honda', 'Ace CB 125CC ES'),
(27, 'TVS', 'HLX 125CC ES'),
(29, 'TVS', 'HLX 150CC X'),
(30, 'TVS', 'HLX 100CC KS'),
(31, 'Haojin', 'HJ 125CC-A'),
(32, 'Boxer', 'BM 150CC (4)'),
(33, 'Ferrari', 'Enzo 6000CC'),
(34, 'Boxer', 'BM 150cc-2'),
(35, 'Boxer', 'BM 150cc-3');




---Question 1
-- Select all the clients called Paul in first_name or middle_name and who are more than 25 years old.
-- In the results, create a column with the client's age in years. 
-- Order them from older to younger.

SELECT
    c.client_id
   ,CONCAT(c.first_name, ' ', c.middle_name, ' ', c.last_name) AS full_name
   ,EXTRACT(YEAR FROM AGE(CURRENT_DATE, c.date_of_birth)) AS age_in_years
FROM
    client c
WHERE
    (c.first_name = 'Paul' OR c.middle_name = 'Paul') AND
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, c.date_of_birth)) > 25 --Employing the use of "AGE" function to calculate difference between the current date and the date_of_birth
ORDER BY
    age_in_years 
	DESC
;



---Question 2
-- Add a column to the table from question (1) that contains the number of loans each customer made.
-- If there is no loan, this column should show 0.
   
---Adding a column ~ num_loans to the existing client table to store the number of loans each customer made
ALTER TABLE client
ADD COLUMN num_loans INTEGER DEFAULT 0; --- using the default as 0 to ensure that clients without any loans are correctly initialized

-- Updating the num_loans column with the count of loans for each client
UPDATE client c
SET num_loans = COALESCE((SELECT COUNT(*) FROM loan l ---Using COALESCE function is used to handle cases where a client has no loans
						  WHERE
						  l.client_id = c.client_id), 0) --Using  a correlated subquery to update the num_loans column in the client table
;


---Question 3
-- Select the 100cc, 125cc and 150cc bikes from the vehicle table.
-- Add an engine_size column to the output (that contains the engine size).

 
-- Adding the engine_size column to the vehicle table using  'CASE'  statement to determine the engine size based on the model name
--- We will need to employ the use of 'CASE'  statement to determine the engine size based on the model name 
SELECT
    vehicle_id
   ,make
   ,model_name
   ,CASE
        WHEN model_name LIKE '%100CC%' THEN '100cc'
        WHEN model_name LIKE '%125CC%' THEN '125cc'
        WHEN model_name LIKE '%150CC%' THEN '150cc'
        ELSE 'Unknown_cc'
    END AS engine_size
FROM
    vehicle
WHERE
    model_name LIKE '%100CC%' OR
    model_name LIKE '%125CC%' OR
    model_name LIKE '%150CC%'
;
	
	


---Question 4
-- Calculate the total principal_amount per client full name (one column that includes all the names for each client) and per vehicle make.

SELECT
    CONCAT(c.first_name, ' ', c.middle_name, ' ', c.last_name) AS client_full_name
   ,v.make AS vehicle_make
   ,SUM(l.principal_amount) AS total_principal_amount
FROM
    client c
LEFT JOIN
    loan l ON c.client_id = l.client_id
LEFT JOIN
    vehicle v ON l.vehicle_id = v.vehicle_id
GROUP BY
    client_full_name, 
	vehicle_make
; 



---Question 5
-- Select the loan table and add an extra column that shows the chronological loan order for each client based on the submitted_on_date column: 
-- 1 if it's the client's first sale, 2 if it's the client's second sale etc.
-- Call it loan_order
SELECT
    * ,
	ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY submitted_on_date) AS loan_order
FROM
    loan
;


