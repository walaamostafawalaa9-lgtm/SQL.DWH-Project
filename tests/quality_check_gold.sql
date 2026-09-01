/*
==================================================================================
Quality Checks
==================================================================================
Script Purpose:
  This script performs quality check to validate integrity , consistency,
  and accuracy of the Gold Layer.
  These cheks ensure:
  -Uniqueness of surrogate keys in dimension tables.
  -Referential integrity between fact and dimension tables.
  -Validation of relationships in the data model for analytical purposes.

Usage Notes:
  -Run these checks after data loading gold layer.
  -Investigate and resolve discrepancies found during the checks.
==================================================================================
*/
--=============================================================================
-- CHECKING CUSTOMER DIMENSION
--=============================================================================
--check for uniqueness of customer key in gold.dim_customer
--Expectation :No results.
select
  COUNT(*) depulicates,
  customer_key 
from gold.dim_customer
group by customer_key
having COUNT(*) > 1;
--=============================================================================
-- CHECKING PRODUCT DIMENSION
--=============================================================================
--check for uniqueness of product_key in gold.dim_product
--Expectation :No results.
select 
    COUNT(*) depulicates,
    product_key 
from gold.dim_product
group by product_key
having COUNT(*) > 1;
--=============================================================================
-- CHECKING SALES FACT - REFERENTIAL INTEGRITY
--=============================================================================
-- Check for foreign keys in fact table that do not exist in customer dimension
-- Expectation: No results.
SELECT 
    s.customer_key 
FROM gold.fact_sales s
LEFT JOIN gold.dim_customer c
    ON s.customer_key = c.customer_key
WHERE c.customer_key IS NULL 
  AND s.customer_key IS NOT NULL;

-- Check for foreign keys in fact table that do not exist in product dimension
-- Expectation: No results.
SELECT 
    s.product_key 
FROM gold.fact_sales s
LEFT JOIN gold.dim_product p
    ON s.product_key = p.product_key
WHERE p.product_key IS NULL 
  AND s.product_key IS NOT NULL;
--=============================================================================
-- CHECKING SALES FACT - DATA ACCURACY & CONSISTENCY
--=============================================================================
-- Check for invalid or missing numerical values (negative/zero quantities or sales)
-- Expectation: No results.
SELECT 
    sales_amount,
    quantity,
    price
FROM gold.fact_sales
WHERE sales_amount IS NULL 
   OR sales_amount < 0
   OR quantity IS NULL 
   OR quantity <= 0
   OR price < 0;

-- Check for logical date sequences (e.g., shipping date occurring before order date)
-- Expectation: No results.
SELECT *
FROM gold.fact_sales
WHERE shipping_date < order_date
  OR shipping_date > due_date;
