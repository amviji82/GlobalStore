USE global_electronics;

-- Create Modified Sales Table
CREATE TABLE New_Sales_modified
LIKE New_sales;

INSERT new_sales_modified
SELECT *
FROM new_sales;

-- Create Modified Products Table
CREATE TABLE product_modified
LIKE product;

INSERT product_modified
SELECT *
FROM product;

-- Removing Duplicates within Tables
WITH Sales_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY OrderNumber, lineitem, productkey, 
                  storekey, customerkey) AS Row_Num
FROM New_sales_modified
)
SELECT *
FROM Sales_CTE
WHERE Row_Num > 1;

WITH Products_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY productkey, productname, brand, 
                  color, subcategorykey, categorykey) AS Row_Num
FROM products_modified
)
SELECT *
FROM Products_CTE
WHERE Row_Num > 1;

WITH Customers_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY customerkey, gender, name, 
                   city, state, country) AS Row_Num
FROM customers
)
SELECT *
FROM customers_CTE
WHERE Row_Num > 1;

-- Updating Date Columns (Customers)
SELECT Birthday,
STR_TO_DATE(Birthday, 'yyyy-mm-dd')
FROM Customers;

UPDATE Customers
SET Birthday = TO_DATE(Birthday, 'yyyy-mm-dd');

-- Updating Date Columns (Stores)
SELECT OpenDate,
STR_TO_DATE(OpenDate, 'yyyy-mm-dd')
FROM stores;

UPDATE Stores
SET OpenDate = TO_DATE(OpenDate, 'yyyy-mm-dd');

UPDATE stores
SET SquareMeters = NULL
WHERE SquareMeters = '';

-- Updating Date Columns (Exhcange Rates)
SELECT `Date`,
STR_TO_DATE(`Date`, 'yyyy-mm-dd')
FROM exchange_rates;

UPDATE exchange_rates
SET `Date` = STR_TO_DATE(`Date`, 'yyyy-mm-dd');

-- Updating Date Columns (New_sales_modified)
SELECT OrderDate, STR_TO_DATE(OrderDate, 'yyyy-mm-dd'),
  DeliveryDate, STR_TO_DATE(DeliveryDate, 'yyyy-mm-dd')
FROM new_sales_modified;

UPDATE New_sales_modified
SET OrderDate = STR_TO_DATE(OrderDate, 'yyyy-mm-dd');

UPDATE New_sales_modified
SET DeliveryDate = STR_TO_DATE(DeliveryDate, 'yyyy-mm-dd')
WHERE DeliveryDate != '';

UPDATE New_sales_modified
SET DeliveryDate = NULL
WHERE DeliveryDate = '';

-- Updating Date Columns (New_Sales)
SELECT OrderDate, STR_TO_DATE(OrderDate, 'yyyy-mm-dd''),
  DeliveryDate, STR_TO_DATE(DeliveryDate, 'yyyy-mm-dd'')
FROM New_sales;

UPDATE New_sales
SET OrderDate = STR_TO_DATE(OrderDate, 'yyyy-mm-dd');

UPDATE New_Sales
SET DeliveryDate = NULL
WHERE DeliveryDate = '';

UPDATE New_Sales
SET DeliveryDate = TO_DATE(DeliveryDate, 'yyyy-mm-dd')
WHERE DeliveryDate IS NOT NULL;

-- Recent Exchange Rates
CREATE TABLE Recent_Exchange_Rates
LIKE exchange_rates;

INSERT Recent_Exchange_Rates
SELECT *
FROM exchange_rates
WHERE Date = '2021-02-20';

-- Modifying UnitCost & UnitPrice columns
UPDATE product_modified
SET unitpriceusd = CAST(REPLACE(unitpriceusd, '$', '') AS DECIMAL);

UPDATE product_modified
SET unitcostusd = CAST(REPLACE(unitcostusd, '$', '') AS DECIMAL);