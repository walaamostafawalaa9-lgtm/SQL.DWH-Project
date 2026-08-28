/*
================================================================================
Stored Procedure: Load Silver Layer (bronze->silver)
=================================================================================
Script Purpose:
	This stored procedure performs the ETL (Extract,Transform,Load) process to
	populate the <silver> schema tables from the <bronze> schema.
Actions Performed:
	-Truncates Silver tables
	-Inserts transformed & cleansed data from Bronze into Silver tables
Parameters:
	None.
	This stored procedure does not accept any parameters or return any values.
Usage Example:
	Exec silver.load_silver ;
=====================================================================================
*/

Create or Alter procedure silver.load_silver AS
Begin
	Declare @start_time DateTime , @end_time DateTime,@batch_start_time DateTime,@batch_end_time DateTime;
	Begin TRY
	set @batch_start_time = GETDATE();
	print'=====================================';
	print'<<loading_silver_layer>> ';
	print'=====================================';

	print'-------------------------------------';
	print'	CRM TABLES	';
	print'-------------------------------------';

	Set @start_time=Getdate();
	print'>>truncate table: silver.crm_cust_info';
	Truncate table silver.crm_cust_info;
	print'>>inserting data into silver.crm_cust_info';
	INSERT INTO silver.crm_cust_info
	(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
	)

	select 
		cst_id,
		cst_key,
		trim(cst_firstname) as cst_firstname,
		trim(cst_lastname) as cst_lastname,
		case when upper(cst_marital_status) ='M' then 'Married'
			 when upper(cst_marital_status) ='S' then 'Single'
			 else 'n/a'
		end cst_marital_status,
		case when upper(cst_gndr) ='M' then 'Male'
			 when upper(cst_gndr) ='F' then 'Female'
			 else 'n/a'
		end cst_gndr,
		cst_create_date
	from
		(select *,ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as most_recent 
		from bronze.crm_cust_info
		where cst_id IS NOT NULL
		 )d where most_recent=1 
		 Set @end_time=Getdate();
		 print'Table loading time:'+cast(datediff(second,@start_time,@end_time) AS varchar)+'seconds';
		 print'-------------------';
	 
	 Set @start_time=GETDATE();
	 print'>>truncating table: silver.crm_prd_info';
	 Truncate table silver.crm_prd_info;
	 print'>>inserting into silver.crm_prd_info';
	 INSERT INTO silver.crm_prd_info
	 (
		 prd_id,
		 cat_id,
		 prd_key,
		 prd_nm,
		 prd_cost,
		 prd_line,
		 prd_start_dt,
		 prd_end_dt
	 )
	 select 
		 prd_id,
		 REPLACE( substring(prd_key,1,5),'-','_' )as cat_id,
		 REPLACE( substring(prd_key,7,len(prd_key)),'-','_' )as prd_key,
		 prd_nm,
		 ISNULL( prd_cost, 0) as prd_cost,
		 case upper(prd_line)
			   when 'M' then 'Mountain'  
			   when 'T' then 'Touring' 
			   when 'R' then 'Road' 
			   when 'S' then 'OtherSales' 
			   else 'n/a'
		end prd_line,
		cast(prd_start_dt as date)as prd_start_dt,
		cast( lead(prd_start_dt) over(partition by prd_key order by prd_start_dt asc )-1 as date )as prd_end_dt
	 from bronze.crm_prd_info;
	 	Set @end_time=Getdate();
		print'Table loading time:'+cast(datediff(second,@start_time,@end_time) AS varchar)+'seconds';
	    print'-------------------';

	 Set @start_time=GETDATE();
	print'>>truncating table :silver.crm_sales_details';
	Truncate table silver.crm_sales_details;
	print'>>inserting into silver.crm_sales_details';
	INSERT INTO silver.crm_sales_details
	(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)

	select 
		sls_ord_num,
		REPLACE(TRIM(sls_prd_key), '-', '_') as sls_prd_key,
		sls_cust_id,
		case 
			when sls_order_dt <=0 or LEN(sls_order_dt)!=8  then NULL
			else cast (cast(sls_order_dt as varchar)as date)
		end sls_order_dt,
		case 
			when sls_ship_dt <=0 or LEN(sls_ship_dt)!=8  then NULL
			else cast (cast(sls_ship_dt as varchar)as date)
		end sls_ship_dt,
		case 
			when sls_due_dt <=0 or LEN(sls_due_dt)!=8  then NULL
			else cast (cast(sls_due_dt as varchar)as date)
		end sls_due_dt,
		case 
			when sls_sales IS NULL or sls_sales<=0 or sls_sales != sls_quantity*sls_price   then sls_quantity*ABS(sls_price)
			else  sls_sales
		end sls_sales,
		sls_quantity ,
		case
			when sls_price is NULL or sls_price <=0 then sls_sales/nullif(sls_quantity,0)
			else sls_price
		end sls_price
	from bronze.crm_sales_details;
		Set @end_time=Getdate();
		print'Table loading time:'+cast(datediff(second,@start_time,@end_time) AS varchar)+'seconds';
		
	print'-------------------------------------';
	print'-------ERP TABLES--------';
	print'-------------------------------------';
	 Set @start_time=GETDATE();
	print'>>truncating table: silver.erp_cust_az12';
	Truncate table silver.erp_cust_az12;
	print'>>inserting into silver.erp_cust_az12';
	INSERT INTO silver.erp_cust_az12
	(
		cid,
		bdate,
		gen
	)
	select 
		case when cid like 'NAS%' then SUBSTRING(cid,4,LEN(cid))
			 else cid
		end as cid,
		case 
			when bdate >GETDATE() then NULL
			else bdate
		end as bdate,
		case 
			when upper(trim(gen)) IN('M','MALE') THEN 'Male'
			when upper(trim(gen)) IN('F','FEMALE') THEN 'Female'
			else 'n/a'
		end as gen
	from bronze.erp_cust_az12;
		Set @end_time=Getdate();
		print'Table loading time:'+cast(datediff(second,@start_time,@end_time) AS varchar)+'seconds';
	    print'-------------------';

	 Set @start_time=GETDATE();
	print'>>truncating table : silver.erp_loc_a101';
	Truncate table silver.erp_loc_a101;
	print'inserting into silver.erp_loc_a101';
	INSERT INTO silver.erp_loc_a101(cid,cntry)
	select
		replace (cid,'-','') as cid ,
		case 
			when TRIM(cntry)='DE'then 'Germany'
			when TRIM(cntry) in ('US','USA')then 'United States'
			when TRIM(cntry)='' OR cntry IS NULL then 'n/a'
			else TRIM(cntry)
		end as cntry
	from bronze.erp_loc_a101 ;
		Set @end_time=Getdate();
		print'Table loading time:'+cast(datediff(second,@start_time,@end_time) AS varchar)+'seconds';
		print'-------------------';
	
	 Set @start_time=GETDATE();
	print'>>truncating table :silver.erp_px_cat_g1v2';
	Truncate table silver.erp_px_cat_g1v2;
	print'inserting into silver.erp_px_cat_g1v2';
	INSERT INTO silver.erp_px_cat_g1v2(id,cat,subcat,maintenance)
	select
		id,
		cat,
		subcat,
		maintenance
	from bronze.erp_px_cat_g1v2;
	 	Set @end_time=Getdate();
		print'Table loading time:'+cast(datediff(second,@start_time,@end_time) AS varchar)+'seconds';
		print'-------------------';
		Set @batch_end_time=Getdate();
		print'==========================';
		print'<<loading silver_layer completed>>';
		print'Batch loading time:'+cast(datediff(second,@batch_start_time,@batch_end_time) AS varchar)+'seconds'
		print'==========================';
	End TRY
	Begin CATCH
	print 'Error Occured During Loading ';
	print'Error message:'+ ERROR_MESSAGE();
	print'Error message:'+ Cast(ERROR_NUMBER() AS Varchar);
	print'Error message:'+ Cast(ERROR_STATE() AS Varchar);
	END CATCH
End;
Exec silver.load_silver ;
