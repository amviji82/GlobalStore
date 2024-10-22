USE global_electronics;

-- Types of products sold, and customers location?
SELECT DISTINCT  Category, Subcategory, COUNT(category) AS Quantity
FROM product_modified
GROUP BY Category, Subcategory
ORDER BY Category
;

-- Count of Customers by Continent and Country 
SELECT Continent, Country, 
  COUNT(Country) AS Count
FROM customers
GROUP BY Continent, Country
;

-- Seasonal Patterns & Trends for Order Volume and Revenue
SELECT Month_Name, 
        Year_Name,
        SUM(QTY) AS Order_Volume, 
        ROUND(SUM(Revenue),2) AS Total_Revenue_USD
FROM
   (SELECT monthname(sal.orderdate) AS Month_Name,
           year(sal.orderdate) AS Year_Name,
           SUM(sal.Quantity) AS QTY, 
           SUM(sal.Quantity * prod.UnitPriceUSD * Exchange) AS Revenue
   FROM new_sales_modified AS sal
   LEFT JOIN product_modified AS prod
           ON prod.ProductKey = sal.ProductKey
   LEFT JOIN recent_exchange_rates AS exc
           ON exc.Currency = sal.CurrencyCode
   GROUP BY monthname(sal.orderdate), year(sal.orderdate)
  ) AS agg_table
GROUP BY Year_Name, Month_Name
;

-- Average Delivery Time in Days
SELECT AVG(Delivery_Time) AS Avg_Delivery_Time
FROM
   (SELECT OrderDate, 
     DeliveryDate, 
     CAST(datediff(deliverydate, orderdate) AS SIGNED) AS Delivery_Time
   FROM new_sales_modified
   WHERE DeliveryDate IS NOT NULL
   ) AS agg_table2
;

-- Trend of Average Delivery Time by Month and Years
WITH Delivery_CTE AS
        (SELECT monthname(deliverydate) Delivery_Month, 
                year(deliverydate) Delivery_Year,
                AVG(CAST(datediff(deliverydate, orderdate) AS SIGNED)) 
                AS Avg_Delivery_Time
        FROM new_sales_modified
        GROUP BY monthname(deliverydate), 
                year(deliverydate)
        )
SELECT *
FROM Delivery_CTE
WHERE Delivery_Month IS NOT NULL
;

-- Average Order Value for In-Store & Online Sales
WITH Store_CTE AS
        (SELECT 
             CASE
                  WHEN country = 'Online' THEN 'Online'
                        ELSE 'In-store'
                   END AS Stores,
              SUM(Quantity) AS Order_Volume,
              SUM(Quantity * UnitPriceUSD * Exchange) AS Revenue
        FROM new_sales_modified AS sal
        JOIN stores AS st
                ON st.StoreKey = sal.StoreKey
        JOIN product_modified AS prod
                ON prod.ProductKey = sal.ProductKey 
         JOIN recent_exchange_rates AS exc
                ON exc.Currency = sal.CurrencyCode
        GROUP BY CASE
                WHEN country = 'Online' THEN 'Online'
                      ELSE 'In-store'
                 END
        )
SELECT Stores, ROUND((Revenue/Order_Volume),2) AS Avg_Order_Value
FROM Store_CTE
;
    
-- Customers Age Range
CREATE VIEW Customers_Age_and_Gender AS
SELECT Name, Gender,TIMESTAMPDIFF(YEAR, birthday, CURDATE()) AS Age
FROM customers
;

SELECT Gender,
        AVG(age) AS Average_Age
FROM customers_age_and_gender
GROUP BY Gender
;

-- Total Orders & Revenue by Customers
SELECT Name,
        Country,
        SUM(Quantity) AS Total_Orders,
        ROUND(SUM(Revenue),2) AS Total_Revenue_USD
FROM
   (SELECT Name,
           Quantity,
           Country,
           (sal.Quantity * prod.UnitPriceUSD * exc.Exchange) AS Revenue
   FROM new_sales_modified AS Sal
   JOIN Customers AS Cus
          ON Cus.Customerkey = Sal.customerkey
   JOIN product_modified AS prod
          ON prod.ProductKey = sal.ProductKey 
   JOIN recent_exchange_rates AS exc
          ON exc.Currency = sal.CurrencyCode
   ) AS Agg_table5
GROUP BY Name, Country
ORDER BY Name
;

-- Total Gender Count of Customers
SELECT Gender, COUNT(Gender) AS Count
FROM customers_age_and_gender
GROUP BY Gender
;

-- Total Orders for Online & In-Strore Sales
WITH All_Stores_CTE AS
        (SELECT 
             CASE
                  WHEN country = 'Online' THEN 'Online'
                        ELSE 'In-store'
                 END AS Stores,
              SUM(Quantity) AS Order_Volume
        FROM new_sales_modified AS sal
        JOIN stores AS st
                ON st.StoreKey = sal.StoreKey
        GROUP BY CASE
                WHEN country = 'Online' THEN 'Online'
                      ELSE 'In-store'
               END
        )
SELECT Stores, Order_Volume AS Total_Order_Volume
FROM All_Stores_CTE
;

-- Profit, Revenue, Total Cost, Average Order Value by Products Category
WITH Products_CTE AS
        (SELECT Quantity, 
                Category,
                (Quantity * UnitPriceUSD *Exchange) AS Revenue,
                (Quantity * UnitCostUSD * Exchange) AS Cost
        FROM new_sales_modified AS sal
        LEFT JOIN product_modified AS prod
              ON prod.ProductKey = sal.ProductKey 
        LEFT JOIN recent_exchange_rates AS exc
              ON exc.Currency = sal.CurrencyCode
        )
SELECT Category AS Product_Category,
        SUM(Quantity) AS Total_Order_Vol,
        ROUND(SUM(Cost),2) AS Total_Cost_USD, 
        ROUND(SUM(Revenue),2) AS Total_Revenue_USD,
        ROUND(SUM(Revenue - Cost),2) AS Profit_USD,
        ROUND(SUM(Revenue)/SUM(Quantity),2) AS Avg_Order_Value
FROM Products_CTE
GROUP BY Category
ORDER BY Category
;