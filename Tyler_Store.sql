CREATE TABLE PropertyInfo(
PropID INT PRIMARY KEY,
PropertyCity TEXT NOT NULL,
PropertyState TEXT NOT NULL);

CREATE TABLE Products(
ProductID INT PRIMARY KEY,
ProductName TEXT NOT NULL,
ProductCategory TEXT NOT NULL,
Price DECIMAL(10,2) );


CREATE TABLE Orders(
OrderID INT PRIMARY KEY,
OrderDate DATE NOT NULL,
PropID INT NOT NULL,
FOREIGN KEY (PropID) REFERENCES PropertyInfo(PropID),
ProductID INT NOT NULL,
FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
Quantity INT NOT NULL);


-- Load data from PropertyInfo csv into Property table
BULK INSERT PropertyInfo
FROM 'C:\Users\ANJOLA\Downloads\PropertyInfo.csv'
WITH (
    FIELDTERMINATOR = ',',   -- Comma-separated fields
    ROWTERMINATOR = '\n',    -- Newline-separated rows
    FIRSTROW = 2             -- Skip the header row
);

-- Load data from Products csv into Products table
BULK INSERT Products
FROM 'C:\Users\ANJOLA\Downloads\Products.csv'
WITH (
    FIELDTERMINATOR = ',',   -- Comma-separated fields
    ROWTERMINATOR = '0x0A'    -- Newline-separated rows
   
);
-- Alter the table to change the data type of the "price" column from DECIMAL
ALTER TABLE Products
ALTER COLUMN Price INT NOT NULL; 

-- Load data from Orders csv into Orders table
-- I used the import wizard for the Orders table because the date column was causing a lot of trouble

--Had to confirm the data type of the date column after going through so much
SELECT DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Orders'  
AND COLUMN_NAME = 'OrderDate'; 

--Join tables 
SELECT Orders.OrderID, Orders.OrderDate, Orders.ProductID, Orders.PropID, PropertyInfo.PropertyCity,
PropertyInfo.PropertyState, Products.ProductName,Products.ProductCategory,Products.Price

INTO New_Table --gave the new table a name

FROM Orders
JOIN PropertyInfo
ON Orders.PropID = PropertyInfo.PropID
JOIN Products
ON Orders.ProductID = Products.ProductID

--Showing all details about orders, products and properties
SELECT * 
FROM New_Table
ORDER BY Price DESC

--Extract list of all cities and their respective states where properties are located
SELECT PropertyCity, PropertyState
FROM New_Table

--What are the different product categories Denis has in his store
SELECT DISTINCT CONVERT(NVARCHAR(MAX), ProductCategory) AS UniqueProductCategory
FROM New_Table; 

--What are the 5 most expensive products ****
SELECT TOP 5 ProductName, Price
FROM New_Table
ORDER BY Price DESC;

--Extract names and category of products whose prices are above $200
SELECT DISTINCT CONVERT(NVARCHAR(MAX),ProductCategory) AS Unique_Category, CONVERT(NVARCHAR(MAX), ProductName) AS Unique_Product
FROM New_Table
WHERE Price > 200;

--Products sold between a time frame
SELECT DISTINCT CONVERT(NVARCHAR(MAX), ProductName) AS Products_Sold
FROM New_Table
WHERE OrderDate BETWEEN '2015-01-01' AND '2015-01-10'

--Orders made by Property 14, 16 & 10
SELECT ProductName, PropID
FROM New_Table
WHERE PropID = 10 OR 
 PropID =14 OR 
 PropID =16
 ORDER BY PropID;

 --Product Names starting with T
 SELECT DISTINCT CONVERT(NVARCHAR(MAX), ProductName)
 FROM New_Table
 WHERE ProductName LIKE 'T%'

 --Forgot to add a column
ALTER TABLE New_table
ADD Quantity INT;

UPDATE New_Table
SET New_table.Quantity = Orders.Quantity
FROM New_Table
JOIN Orders ON New_Table.OrderID =Orders.OrderID;

--Average quantity of products bought by each property
SELECT  PropID, AVG(Quantity) AS Average_Quantity
FROM New_Table
GROUP BY PropID
ORDER BY PropID



--Changind data type of ProductName column
ALTER TABLE New_table
ALTER COLUMN ProductName NVARCHAR(30) ; 

--What are the most expensive and least expensive products **
--Max
SELECT DISTINCT CONVERT(NVARCHAR(MAX), ProductName) AS Product, Price
FROM New_Table
WHERE Price = (SELECT MAX(Price)FROM New_Table)
 --Min
SELECT DISTINCT CONVERT(NVARCHAR(MAX), ProductName) AS Product, Price
FROM New_Table
WHERE Price = (SELECT MIN(Price)FROM New_Table)



--Identify whether a product's worth is  more than $200 in a new column named price category
-- ADD a new column

ALTER TABLE New_table
ADD Price_Category VARCHAR(10);

UPDATE New_Table
SET Price_Category =

CASE WHEN Price > 200
THEN 'Yes'
ELSE 'No'
END;

SELECT * FROM New_Table