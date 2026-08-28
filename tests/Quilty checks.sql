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


select * from bronze.crm_cust_info;
--Check if there is  duplicates & missing values

select count(*),cst_id from bronze.crm_cust_info

group by cst_id
having COUNT(*)!=1 OR cst_id IS NUll

-----check if there unwanted spaces
select cst_firstname from bronze.crm_cust_info
where cst_firstname != trim(cst_firstname);

select cst_lastname from bronze.crm_cust_info
where cst_lastname != trim(cst_lastname);
-----check consistency
select distinct cst_gndr from bronze.crm_cust_info;
select distinct cst_marital_status from bronze.crm_cust_info;
----check insertion
select * from silver.crm_cust_info;
------------------------------------
------------------------------------
select * from bronze.crm_prd_info;
--Check if there is  duplicates & missing values

select count(*),prd_id from bronze.crm_prd_info
group by prd_id
having COUNT(*)!=1 OR prd_id IS NUll

-----check if there unwanted spaces
select prd_nm from bronze.crm_prd_info
where prd_nm != trim(prd_nm);
-----check consistency
select distinct prd_line from bronze.crm_prd_info;
------check for Nulls & negative values
select prd_cost from bronze.crm_prd_info
where prd_cost<0 OR prd_cost IS NULL;
------check if invalid date
select * from bronze.crm_prd_info
where prd_start_dt>prd_end_dt;
----check insertion
select * from silver.crm_prd_info;
-------------------------
-------------------------
select * from bronze.crm_sales_details;
---- check that the prd_key& cust_id exist in their origin column
SELECT 
    sls_ord_num,
   REPLACE(sls_prd_key, '-', '_') Sales_Key 
FROM bronze.crm_sales_details 
where REPLACE(sls_prd_key, '-', '_')not in( select prd_key from silver.crm_prd_info);

select * from bronze.crm_sales_details
where sls_cust_id not in(select cst_id from silver.crm_cust_info);
-------check order date validation
select sls_order_dt from bronze.crm_sales_details
where  sls_order_dt>sls_ship_dt or sls_order_dt>sls_due_dt ;
-------check date validation
select NULLIF( sls_order_dt,0)sls_order_dt
from bronze.crm_sales_details
where sls_order_dt <=0 or LEN(sls_order_dt)!=8 or sls_order_dt> 20500101 or sls_order_dt<19900101

select sls_ship_dt from bronze.crm_sales_details
where sls_ship_dt <=0 or sls_ship_dt IS NULL ;

select sls_due_dt from bronze.crm_sales_details
where sls_due_dt <=0 or sls_due_dt IS NULL ;
-----check sales=quantity*price
select sls_sales,sls_quantity,sls_price  from bronze.crm_sales_details
where sls_sales !=sls_quantity*sls_price
      or sls_sales is NULL or sls_quantity  is NULL or sls_price  is NULL 
      or sls_quantity<=0 or sls_price<=0 or sls_sales<=0;

----check insertion
select * from silver.crm_sales_details;
-------------------------------------
-----ERP-----------------------------
select * from bronze.erp_cust_az12;
--Normilazation&standarization
--check cid
select cid from bronze.erp_cust_az12
where cid not in(select cst_key from silver.crm_cust_info);

select count(*),cid from bronze.erp_cust_az12
group by cid
having COUNT(*)!=1 OR cid IS NUll;
--check birthdate(bdate)
select bdate from silver.erp_cust_az12
where  bdate IS NULL OR bdate<'1921-01-01' OR bdate>GETDATE();
--check gen
select DISTINCT gen from silver.erp_cust_az12;
--check insertion
select * from silver.erp_cust_az12;
---------------------------------
---------------------------------
select * from bronze.erp_loc_a101;
----check cid
select cid from silver.erp_loc_a101
where cid not in(select cst_key from silver.crm_cust_info);
---check cntry
select distinct cntry old,case 
	when TRIM(cntry)='DE'then 'Germany'
	when TRIM(cntry) in ('US','USA')then 'United States'
	when TRIM(cntry)='' OR cntry IS NULL then 'n/a'
	else TRIM(cntry)
end as cntry from bronze.erp_loc_a101
order by cntry;
---check insertion
select * from silver.erp_loc_a101;
---------------------------------
select * from bronze.erp_px_cat_g1v2;
----------------------------------
select id from bronze.erp_px_cat_g1v2
where id not in(select cat_id from silver.crm_prd_info)
--check if there is un wanted spaces
select cat,subcat, maintenance  from bronze.erp_px_cat_g1v2
where cat != TRIM(cat) or subcat !=TRIM(subcat) or  maintenance !=TRIM( maintenance );
--standraiztion
select distinct maintenance from bronze.erp_px_cat_g1v2;
select distinct cat from bronze.erp_px_cat_g1v2;
select distinct subcat from bronze.erp_px_cat_g1v2;
--check insertion
select * from silver.erp_px_cat_g1v2;
