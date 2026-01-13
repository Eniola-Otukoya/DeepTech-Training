CREATE DATABASE assignment3;
use assignment3;
CREATE TABLE Customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100),
  loyalty_points INT,
  registration_date DATE,
  age INT
);

INSERT INTO Customers (customer_id, name, loyalty_points, registration_date, age) VALUES
(101, 'Shehu Salihu', 150, '2019-05-15', 35),
(201, 'Job Timothy', 200, '2020-06-20', 42),
(305, 'Agnes Pam', 300, '2018-08-10', 29),
(405, 'Esther James', 120, '2022-01-05', 50),
(509, 'Larry Adams', 250, '2021-10-12', 32);

CREATE TABLE Transactions (
  transaction_id INT PRIMARY KEY,
  customer_id INT,
  amount_spent DECIMAL(10, 2),
  transaction_date DATE,
  FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

INSERT INTO Transactions (transaction_id, customer_id, amount_spent, transaction_date) VALUES
(1, 101, 100, '2023-05-10'),
(2, 201, 200, '2023-05-11'),
(3, 305, 300, '2023-05-12'),
(4, 405, 400, '2023-05-13'),
(5, 509, 150, '2023-05-14'),
(6, 305, 500, '2023-05-15');

CREATE TABLE Products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(100),
  price DECIMAL(12, 2),
  category VARCHAR(50)
);

INSERT INTO Products (product_id, product_name, price, category) VALUES
(102, 'Laptop', 200000, 'Electronics'),
(201, 'Smartphone', 500000, 'Electronics'),
(203, 'Blender', 120000, 'Home Appliance'),
(104, 'Sofa', 450000, 'Furniture'),
(107, 'Desk Lamp', 350000, 'Furniture');



select 
case
when age < 20 then "below 20"
when age between 20 and 29 then "20-29"
when age between 30 and 39 then "30-39"
end as age_group,
sum(t.amount_spent) as total_amount_spent
from Customers c
join Transactions t 
on c.customer_id = t.customer_id
where age < 40
group by age_group;



create index idx_transaction_date on Transactions (transaction_date);



select c.customer_id, count(transaction_id) as number_of_transaction, sum(amount_spent) as total_amount_spent
from Customers c 
join Transactions t 
on  c.customer_id = t.customer_id
group by c.customer_id;









