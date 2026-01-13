-- 1. Create Database
CREATE DATABASE SalesDB;
USE SalesDB;

-- 2. Create Tables

-- Customer Table
CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100)
);

-- Product Table
CREATE TABLE Product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(18,2)
);

-- Sales Table
CREATE TABLE Sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    total_amount DECIMAL(18,2),
    sale_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- 3. Insert Sample Data

INSERT INTO Customer (customer_name, email) VALUES
('John Okafor', 'john@example.com'),
('Mary Nwosu', 'mary@example.com'),
('James Ade', 'james@example.com');

INSERT INTO Product (product_name, category, price) VALUES
('iPhone 15', 'Phone', 850000.00),
('Samsung Galaxy S24', 'Phone', 780000.00),
('HP Laptop', 'Computer', 650000.00),
('Dell Laptop', 'Computer', 600000.00);

INSERT INTO Sales (customer_id, product_id, quantity, total_amount, sale_date) VALUES
(1, 1, 1, 850000.00, '2025-01-12'),
(2, 2, 1, 780000.00, '2025-02-18'),
(3, 3, 1, 650000.00, '2025-03-20'),
(1, 4, 1, 600000.00, '2025-04-22'),
(2, 1, 1, 850000.00, '2025-05-15');

-- 4. View: Customers Who Spent More Than ₦300,000

CREATE OR REPLACE VIEW HighValueCustomers AS
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(s.total_amount) AS total_spent
FROM Customer c
JOIN Sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(s.total_amount) > 300000;

-- Test the view
SELECT * FROM HighValueCustomers;

-- 5. Materialized View (MySQL Simulation)

-- MySQL does not support true Materialized Views.
-- To simulate one, create a summary table and refresh it when needed.

CREATE TABLE MonthlySalesSummary AS
SELECT 
    DATE_FORMAT(sale_date, '%Y-%m') AS month,
    SUM(total_amount) AS total_sales
FROM Sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m');

-- To refresh (recalculate) the summary later:
-- TRUNCATE TABLE MonthlySalesSummary;
-- INSERT INTO MonthlySalesSummary
-- SELECT DATE_FORMAT(sale_date, '%Y-%m') AS month,
--        SUM(total_amount)
-- FROM Sales
-- GROUP BY DATE_FORMAT(sale_date, '%Y-%m');

-- Test summary
SELECT * FROM MonthlySalesSummary;

-- 6. Stored Procedure: Increase Phone Prices by 10%

DELIMITER //
CREATE PROCEDURE update_product_price()
BEGIN
    UPDATE Product
    SET price = price * 1.10
    WHERE category = 'Phone';
END //
DELIMITER ;

-- Execute the procedure
CALL update_product_price();

-- Check updated prices
SELECT * FROM Product;
