create database amazon;
use amazon;
select * from customers;
select * from products;
--- Retrieve all customers from a specific city (e.g., 'Patelberg')
SELECT * FROM customers 
WHERE City = 'Patelberg';

-- Fetch all products under "Fruits" category
-- Note: Adjust category name based on actual data
SELECT * FROM products 
WHERE Category = 'Fruits';
-- Create Customers table with constraints
CREATE TABLE Customer (
    CustomerID VARCHAR(36) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    Age INT NOT NULL CHECK (Age > 18),
    Gender VARCHAR(10),
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    SignupDate DATE,
    PrimeMember VARCHAR(3) DEFAULT 'No'
);
-- Insert 3 new rows with UUID format matching your data
INSERT INTO Products (ï»¿ProductID, ProductName, Category, SubCategory, PricePerUnit, StockQuantity, SupplierID)
VALUES 
    ('f8c3de3d-1fea-4d7c-a8b0-2e1f5c8d9a2b', 'Organic Apple', 'Fruits', 'Sub-Fruits-1', 2.99, 150, '0658c953-98c4-4d00-bf29-4fbfe4aca4cd'),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Fresh Milk', 'Dairy', 'Sub-Dairy-1', 3.49, 200, '20e7f27c-8f08-46b3-950f-2c0bbf56722d'),
    ('b2c3d4e5-f6a7-8901-bcde-f23456789012', 'Whole Wheat Bread', 'Bakery', 'Sub-Bakery-1', 2.49, 100, '96f2ce95-e1a1-457f-bdac-a304b06a8521');
    -- Update stock quantity for a specific ProductID
set sql_safe_updates = 0;
UPDATE Products 
SET StockQuantity = 75 
WHERE ï»¿ProductID = '2aa28375-c563-41b5-aa33-8e2c2e0f4db9';
-- Delete suppliers from a specific city
DELETE FROM Suppliers 
WHERE City = 'Patelberg';
-- Add CHECK constraint to Reviews table for ratings 1-5
ALTER TABLE Reviews 
ADD CONSTRAINT chk_rating CHECK (Rating BETWEEN 1 AND 5);

-- Add DEFAULT constraint for PrimeMember column
ALTER TABLE Customer 
ALTER COLUMN PrimeMember SET DEFAULT 'No';
-- WHERE clause: Orders after 2024-01-01
SELECT * FROM Orders 
WHERE OrderDate > '2024-01-01';

-- HAVING clause: Products with average rating > 4
SELECT p.ï»¿ProductID, p.ProductName, AVG(r.Rating) as AvgRating
FROM Products p
JOIN Reviews r ON p.ï»¿ProductID = r.ProductID
GROUP BY p.ï»¿ProductID, p.ProductName
HAVING AVG(r.Rating) > 4;

-- GROUP BY and ORDER BY: Rank products by total sales
SELECT 
    p.ï»¿ProductID, 
    p.ProductName, 
    SUM(od.Quantity * od.UnitPrice) as TotalSales
FROM Products p
JOIN Order_Details od ON p.ï»¿ProductID = od.ProductID
GROUP BY p.ï»¿ProductID, p.ProductName
ORDER BY TotalSales DESC;
-- Calculate total spending per customer and rank them
SELECT 
    c.CustomerID,
    c.Name,
    SUM(od.Quantity * od.UnitPrice) as TotalSpending,
    RANK() OVER (ORDER BY SUM(od.Quantity * od.UnitPrice) DESC) as SpendingRank
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Order_Details od ON o.ï»¿OrderID = od.ï»¿OrderID
GROUP BY c.CustomerID, c.Name
HAVING SUM(od.Quantity * od.UnitPrice) > 5000
ORDER BY TotalSpending DESC;
-- Total revenue per order
SELECT 
    o.ï»¿OrderID,
    o.CustomerID,
    SUM(od.Quantity * od.UnitPrice) as TotalRevenue
FROM Orders o
JOIN Order_Details od ON o.ï»¿OrderID = od.ï»¿OrderID
GROUP BY o.ï»¿OrderID, o.CustomerID;

-- Customers with most orders in a specific time period (e.g., 2024)
SELECT 
    c.CustomerID,
    c.Name,
    COUNT(o.ï»¿OrderID) as OrderCount
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE YEAR(o.OrderDate) = 2024
GROUP BY c.CustomerID, c.Name
ORDER BY OrderCount DESC
LIMIT 10;

-- Supplier with most products in stock
SELECT 
    s.ï»¿SupplierID,
    s.SupplierName,
    SUM(p.StockQuantity) as TotalStock
FROM Suppliers s
JOIN Products p ON s.ï»¿SupplierID = p.SupplierID
GROUP BY s.ï»¿SupplierID, s.SupplierName
ORDER BY TotalStock DESC
LIMIT 1;
-- Create separate Categories table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(50) NOT NULL,
    SubCategoryName VARCHAR(50)
);

-- Create SubCategories table for better normalization
CREATE TABLE SubCategories (
    SubCategoryID INT PRIMARY KEY AUTO_INCREMENT,
    SubCategoryName VARCHAR(50) NOT NULL,
    CategoryID INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Insert distinct categories from Products
INSERT INTO Categories (CategoryName)
SELECT DISTINCT Category FROM Products;

-- Insert distinct subcategories
INSERT INTO SubCategories (SubCategoryName, CategoryID)
SELECT DISTINCT p.SubCategory, c.CategoryID
FROM Products p
JOIN Categories c ON p.Category = c.CategoryName;

-- Add CategoryID and SubCategoryID to Products
ALTER TABLE Products 
ADD COLUMN CategoryID INT,
ADD COLUMN SubCategoryID INT;

set sql_safe_updates = 0;
-- Update foreign keys
UPDATE Products p
SET p.CategoryID = (SELECT CategoryID FROM Categories c WHERE c.CategoryName = p.Category);

UPDATE Products p
SET p.SubCategoryID = (SELECT SubCategoryID FROM SubCategories sc WHERE sc.SubCategoryName = p.SubCategory);

-- Add foreign key constraints
ALTER TABLE Products
ADD FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
ADD FOREIGN KEY (SubCategoryID) REFERENCES SubCategories(SubCategoryID);
-- Top 3 products based on sales revenue
SELECT * FROM (
    SELECT 
        p.ï»¿ProductID,
        p.ProductName,
        SUM(od.Quantity * od.UnitPrice) as Revenue,
        DENSE_RANK() OVER (ORDER BY SUM(od.Quantity * od.UnitPrice) DESC) as ProductRank
    FROM Products p
    JOIN Order_Details od ON p.ï»¿ProductID = od.ProductID
    GROUP BY p.ï»¿ProductID, p.ProductName
) ranked
WHERE ProductRank <= 3;  

-- Customers who haven't placed any orders
SELECT 
    c.CustomerID, 
    c.Name, 
    c.City
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.ï»¿OrderID IS NULL;


-- Cities with highest concentration of Prime members
SELECT 
    City,
    COUNT(CustomerID) as TotalCustomers,
    SUM(CASE WHEN PrimeMember = 'Yes' THEN 1 ELSE 0 END) as PrimeMembers,
    ROUND(100.0 * SUM(CASE WHEN PrimeMember = 'Yes' THEN 1 ELSE 0 END) / COUNT(CustomerID), 2) as PrimePercentage
FROM Customers
GROUP BY City
ORDER BY PrimePercentage DESC
LIMIT 10;


-- Top 3 most frequently ordered categories 
SELECT 
    p.Category,
    COUNT(*) as OrderFrequency
FROM Products p
JOIN Order_Details od ON p.ï»¿ProductID = od.ProductID
GROUP BY p.Category
ORDER BY OrderFrequency DESC
LIMIT 3;

-- Low stock alert (products with stock < 50)
SELECT ProductName, StockQuantity, Category
FROM Products
WHERE StockQuantity < 50
ORDER BY StockQuantity ASC;

-- Category-wise stock summary
SELECT 
    Category,
    COUNT(*) as TotalProducts,
    SUM(StockQuantity) as TotalStock,
    AVG(PricePerUnit) as AvgPrice
FROM Products
GROUP BY Category
ORDER BY TotalStock DESC;

-- Expensive products (price above average)
SELECT ProductName, PricePerUnit, Category
FROM Products
WHERE PricePerUnit > (SELECT AVG(PricePerUnit) FROM Products)
ORDER BY PricePerUnit DESC;

-- Products by subcategory count
SELECT 
    Category,
    SubCategory,
    COUNT(*) as ProductCount
FROM Products
GROUP BY Category, SubCategory
ORDER BY Category, ProductCount DESC;