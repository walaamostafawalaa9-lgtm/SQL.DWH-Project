/*
===============================================================
Quality Checks
===============================================================
Script Purpose:
   This script performs various quality checks for data consistency, accurancy,
  and standarization across the 'silver' schema . It includes checks for:
  -Null or duplicate primary Keys.
  -Unwanted spaces in string fields.
  -Data standarization and consistency.
  -Invalid date ranges and orders.
  -Data consistency between related fields.
Usage Notes:
  -Run these cheks after data loading silver layer.
  -Investigate and resolve any discrepancies found during the checks.
===============================================================
*/
--============================================================
--Checking silver 'silver.crm_cust_info'
--=============================================================
-- Check for Nulls OR Duplicates in primary key 
-- Expectation:No results
select count(*),cst_id from silver.crm_cust_info
group by cst_id
having COUNT(*)!=1 OR cst_id IS NUll;
--check if there unwanted spaces
--Expectation:No results
select cst_firstname from silver.crm_cust_info
where cst_firstname != trim(cst_firstname);

select cst_lastname from silver.crm_cust_info
where cst_lastname != trim(cst_lastname);
--check data consistency
--Expectation:No results
select distinct cst_gndr from silver.crm_cust_info;
select distinct cst_marital_status from silver.crm_cust_info;
--============================================================
--Checking silver 'silver.crm_prd_info'
--=============================================================
-- Check for Nulls OR Duplicates in primary key 
-- Expectation:No results
select count(*),prd_id from silver.crm_prd_info
group by prd_id
having COUNT(*)!=1 OR prd_id IS NUll;

--check if there unwanted spaces
--Expectation:No results
select prd_nm from silver.crm_prd_info
where prd_nm != trim(prd_nm);

--check data consistency
--Expectation:No results
select distinct prd_line from silver.crm_prd_info;

--check for Nulls & negative values
--Expectation:No results
select prd_cost from silver.crm_prd_info
where prd_cost<0 OR prd_cost IS NULL;

--check if invalid date
--Expectation:No results
select * from silver.crm_prd_info
where prd_start_dt>prd_end_dt;
--============================================================
--Checking silver 'silver.crm_sales_details'
--=============================================================
----check that the prd_key& cust_id exist in their origin column
---Expectation:No results
SELECT 
    sls_ord_num,
   sls_prd_key 
FROM silver.crm_sales_details 
where sls_prd_key not in( select prd_key from silver.crm_prd_info);
select * from silver.crm_sales_details
where sls_cust_id not in(select cst_id from silver.crm_cust_info);

---check order date validation
---Expectation:No results
select sls_order_dt from silver.crm_sales_details
where  sls_order_dt>sls_ship_dt or sls_order_dt>sls_due_dt ;

---check date validation
---Expectation:No results
select sls_order_dt
from silver.crm_sales_details
where  sls_order_dt> '2050-01-01' or sls_order_dt<'1990-01-01';

select sls_ship_dt from silver.crm_sales_details
where  sls_ship_dt IS NULL ;

select sls_due_dt from silver.crm_sales_details
where  sls_due_dt IS NULL ;
---check sales
---Expectation:No results
select sls_sales,sls_quantity,sls_price  from silver.crm_sales_details
where sls_sales !=sls_quantity*sls_price
      or sls_sales is NULL or sls_quantity  is NULL or sls_price  is NULL 
      or sls_quantity<=0 or sls_price<=0 or sls_sales<=0;
-------------------------------------
-----ERP-----------------------------
--============================================================
--Checking silver 'silver.erp_cust_az12'
--=============================================================
--check that the cid exist in their origin column
--Expectation:No results
select cid from silver.erp_cust_az12
where cid not in(select cst_key from silver.crm_cust_info);

select count(*),cid from silver.erp_cust_az12
group by cid
having COUNT(*)!=1 OR cid IS NUll;
--Normilazation&standarization
--Expectation:No results
select bdate from silver.erp_cust_az12
where  bdate IS NULL OR bdate<'1921-01-01' OR bdate>GETDATE();
select DISTINCT gen from silver.erp_cust_az12;

--============================================================
--Checking silver 'silver.erp_loc_a101'
--=============================================================
--check that cid exist in their origin column
-- Expectation:No results
select cid from silver.erp_loc_a101
where cid not in(select cst_key from silver.crm_cust_info);
--check data consistency
--Expectation:No results
select distinct cntry old,case 
	when TRIM(cntry)='DE'then 'Germany'
	when TRIM(cntry) in ('US','USA')then 'United States'
	when TRIM(cntry)='' OR cntry IS NULL then 'n/a'
	else TRIM(cntry)
end as cntry from silver.erp_loc_a101
order by cntry;
--============================================================
--Checking silver 'silver.erp_px_cat_g1v2'
--=============================================================
-- check that the cat_id exist in their origin column
-- Expectation:No results
select id from silver.erp_px_cat_g1v2
where id not in(select cat_id from silver.crm_prd_info);
--check if there is un wanted spaces
--Expectation:No results
select cat,subcat, maintenance  from silver.erp_px_cat_g1v2
where cat != TRIM(cat) or subcat !=TRIM(subcat) or  maintenance !=TRIM( maintenance );
--check data consistency&standraiztion
--Expectation:No results
select distinct maintenance from silver.erp_px_cat_g1v2;
select distinct cat from silver.erp_px_cat_g1v2;
select distinct subcat from silver.erp_px_cat_g1v2;
