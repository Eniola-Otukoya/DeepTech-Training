-- Create and select database
CREATE DATABASE IF NOT EXISTS ShopDB;
USE ShopDB;

-- Customers Table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(15),
    CHECK (Phone REGEXP '^[0-9]{10,15}$')
);

-- Products Table
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    StockQuantity INT NOT NULL CHECK (StockQuantity >= 0)
);

-- Orders Table
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL CHECK (TotalAmount > 0),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- OrderDetails Table
CREATE TABLE OrderDetails (
    OrderDetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Subtotal DECIMAL(10,2) NOT NULL CHECK (Subtotal > 0),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Sample data
INSERT INTO Customers (FirstName, LastName, Email, Phone) VALUES
('John', 'Okafor', 'john.okafor@example.com', '08012345678'),
('Mary', 'Nwosu', 'mary.nwosu@example.com', '08123456789');

INSERT INTO Products (ProductName, Price, StockQuantity) VALUES
('Smartphone X', 150000.00, 10),
('Power Bank', 8500.00, 50),
('USB Cable', 1200.00, 200);

DELIMITER $$

CREATE PROCEDURE MakePurchase(
    IN in_customer_id INT,
    IN in_product_id INT,
    IN in_quantity INT
)
BEGIN
    DECLARE current_stock INT;
    DECLARE product_price DECIMAL(10,2);
    DECLARE subtotal DECIMAL(10,2);
    DECLARE order_id INT;

    START TRANSACTION;

    -- Lock the product row for update
    SELECT StockQuantity INTO current_stock
    FROM Products
    WHERE ProductID = in_product_id
    FOR UPDATE;

    -- If stock is insufficient, rollback
    IF current_stock < in_quantity THEN
        ROLLBACK;
        SELECT 'Transaction failed: Product out of stock.' AS Message;
    ELSE
        -- Get product price
        SELECT Price INTO product_price FROM Products WHERE ProductID = in_product_id;
        SET subtotal = product_price * in_quantity;

        -- Create order
        INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
        VALUES (in_customer_id, CURDATE(), subtotal);
        SET order_id = LAST_INSERT_ID();

        -- Insert into OrderDetails
        INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Subtotal)
        VALUES (order_id, in_product_id, in_quantity, subtotal);

        -- Update stock
        UPDATE Products
        SET StockQuantity = StockQuantity - in_quantity
        WHERE ProductID = in_product_id;

        COMMIT;
        SELECT CONCAT('Transaction successful. Order ID: ', order_id) AS Message;
    END IF;
END $$

DELIMITER ;

CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL CHECK (TotalAmount > 0),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
)
PARTITION BY RANGE (YEAR(OrderDate)) (
    PARTITION p_before_2023 VALUES LESS THAN (2023),
    PARTITION p_2023_and_after VALUES LESS THAN MAXVALUE
);

SELECT * FROM Orders WHERE OrderDate >= '2023-01-01';

SELECT * FROM Orders WHERE CustomerID = 1;

CREATE INDEX idx_customerid ON Orders(CustomerID);
