CREATE DATABASE IF NOT EXISTS CompanyDB;
USE CompanyDB;

CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    department_location VARCHAR(50),
    manager_id INT
);

-- Insert the raw data
INSERT INTO Employee (emp_id, emp_name, department, salary, department_location, manager_id) VALUES
(101, 'Umar Adamu', 'HR', 50000, 'Lokoja', 201),
(102, 'Jane Abu', 'IT', 60000, 'Cross River', 202),
(103, 'Caroline Agu', 'Finance', 55000, 'Sokoto', 203),
(104, 'Shehu Umar', 'Logistics', 48000, 'Zamfara', 204),
(105, 'Mohammed Bello', 'Procurement', 53000, 'Jigawa', 205),
(106, 'Frank Ewu', 'IT', 62000, 'Delta', 202);


SET SQL_SAFE_UPDATES = 0;

DELETE FROM Employee
WHERE Employee.emp_id NOT IN (
    SELECT temp.emp_id
    FROM (
        SELECT MIN(e.emp_id) AS emp_id
        FROM Employee e
        GROUP BY e.emp_id, e.emp_name, e.department, e.salary, e.department_location, e.manager_id
    ) AS temp
);

-- Table Employee is now in 1NF
SELECT * FROM Employee;

CREATE TABLE Department (
    department VARCHAR(50) PRIMARY KEY,
    department_location VARCHAR(50),
    manager_id INT
);

-- Insert one record per department (handle duplicates like IT safely)
INSERT INTO Department (department, department_location, manager_id)
SELECT 
    department,
    MIN(department_location) AS department_location,
    MIN(manager_id) AS manager_id
FROM Employee
GROUP BY department;

-- Remove department_location and manager_id from Employee
ALTER TABLE Employee
DROP COLUMN department_location,
DROP COLUMN manager_id;

-- Table Employee and Department are now in 2NF
SELECT * FROM Department;

CREATE TABLE Manager (
    manager_id INT PRIMARY KEY,
    manager_name VARCHAR(50)
);

-- Insert manager data
INSERT INTO Manager (manager_id, manager_name) VALUES
(201, 'HR Manager'),
(202, 'IT Manager'),
(203, 'Finance Manager'),
(204, 'Logistics Manager'),
(205, 'Procurement Manager');

-- Add foreign key from Department → Manager
ALTER TABLE Department
ADD CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES Manager(manager_id);

-- Tables are now in 3NF
SELECT * FROM Manager;

UPDATE Employee
SET salary = salary * 1.10
WHERE department = 'IT';

-- View updated salaries
SELECT emp_id, emp_name, department, salary AS new_salary
FROM Employee
WHERE department = 'IT';

SELECT e.emp_id, e.emp_name, e.department, e.salary,
       d.department_location, m.manager_name
FROM Employee e
JOIN Department d ON e.department = d.department
JOIN Manager m ON d.manager_id = m.manager_id;