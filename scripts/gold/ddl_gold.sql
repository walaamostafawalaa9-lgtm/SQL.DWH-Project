/*
========================================================================
DDL Script : Create gold layer views
========================================================================
Script Purpose:
   This script creates views for the 'gold_layer' schema in the dwh.
   The gold layer represents the final dimension and fact tables using star schema.
   Each view performs transformation and combining data from the silver layer
   to produce clean, enriched and business-ready data.

Usage:
    This views can be  directly queried for analytics and reporting.
========================================================================

*/
--========================================================================
-- CREATE CUSTOMER DIMENSION TABLE
--=========================================================================
If OBJECT_ID('gold.dim_customer','V') IS NOT NULL
  DROP VIEW gold.dim_customer;
GO
  Create View gold.dim_customer AS
    select 
          row_number() over (order by ci.cst_id asc) as customer_key,
          ci.cst_id as customer_id,
          ci.cst_key as customer_number,
          ci.cst_firstname as firstname,
          ci.cst_lastname as lastname,
          case when ci.cst_gndr !='n/a' then ci.cst_gndr
          else coalesce(ca.gen,'n/a')
          end as gender,
          ci.cst_marital_status as marital_status,
          la.cntry as country,
          ca.bdate as birthdate,
          ci.cst_create_date as create_date
  
  from silver.crm_cust_info ci
  left join silver.erp_cust_az12 ca
  on ci.cst_key=ca.cid
  left join silver.erp_loc_a101 la
  on ci.cst_key=la.cid;
GO
--========================================================================
-- CREATE PRODUCT DIMENSION TABLE
--=========================================================================
If OBJECT_ID('gold.dim_product','V') IS NOT NULL
  DROP VIEW gold.dim_product;
GO
  Create View gold.dim_product AS
    select 
        ROW_NUMBER() over(order by pr.prd_start_dt,pr.prd_key)as product_key,
      	pr.prd_id as product_id,
      	pr.prd_key as product_number,
      	pr.prd_nm as product_name,
      	pr.cat_id as category_id,
      	pc.cat as category,
      	pc.subcat as sub_category,
      	pr.prd_line as product_line,
      	pc.maintenance,
      	pr.prd_cost as cost,
      	pr.prd_start_dt as start_date
  
    from silver.crm_prd_info pr
    left join silver.erp_px_cat_g1v2 pc
    on pr.cat_id=pc.id
    where pr.prd_end_dt IS NULL  --filter out historical data (based on the requirments)
GO
--========================================================================
-- CREATE SALES FACT TABLE
--=========================================================================
If OBJECT_ID('gold.fact_sales','V') IS NOT NULL
  DROP VIEW gold.fact_sales;
GO
  Create View gold.fact_sales AS
  select  
    	sd.sls_ord_num as order_number,
    	dt.product_key,
    	dc.customer_key,
    	sd.sls_order_dt as order_date,
    	sd.sls_ship_dt as shipping_date,
    	sd.sls_due_dt as due_date,
    	sd.sls_quantity as quantity,
    	sd.sls_price as price,
    	sd.sls_sales as sales_amount
  
  from silver.crm_sales_details sd
  left join gold.dim_product dt
  on sd.sls_prd_key=dt.product_number
  left join gold.dim_customer dc 
  on sd.sls_cust_id= dc.customer_id;
GO
SELECT * FROM gold.dim_customer;
SELECT * FROM gold.dim_product;
SELECT * FROM gold.fact_sales;
