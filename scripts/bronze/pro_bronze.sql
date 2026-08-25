/*
=========================================
Stored procedures: Load Bronze Layer 
=========================================
Script purpose: 
 This stored procedures load data into <<bronze>> schema from csv files.
  It performs the following:
  1- Truncate bronze tables and then load the data from file.csv.
  2- Use Bulkinsert to load data into bronze.tables.

Parameters:
  None.
THIS PROCEDURE DOES NOT USE ANY PARAMETER OR RETURN A VALUE.

USEGE EXAMPLE:
exec bronze.load_bronze
===========================================================
*/
create or alter procedure bronze.load_bronze
as
begin
	declare @start_time datetime, @end_time datetime ,@batch_start_time datetime,@batch_end_time datetime;
	begin try
			set @batch_start_time=GETDATE();
			print '============================';
			print ' loading bronze layer';
			print '============================';

			print '-----CRM tables-----';

			set @start_time=getdate();
			print '>>truncate table :bronze.crm_cust_info';
			truncate table bronze.crm_cust_info;
			print'>>insert into table :bronze.crm_cust_info';
			BULK INSERT bronze.crm_cust_info
			from 'D:\downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
			with(
			firstrow=2,
			fieldterminator=',',
			tablock
			);
			set @end_time=getdate();
			print 'LOADING DURATION :'+cast(datediff(second,@start_time,@end_time)as nvarchar)+'seconds';
			
			print '-------------------------';

			set @start_time=getdate();
			print '>>truncate table :bronze.crm_prd_info';
			Truncate TABLE bronze.crm_prd_info;
			print '>>insert into table :bronze.crm_prd_info';
			BULK INSERT bronze.crm_prd_info
			FROM 'D:\downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
			WITH
			(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
			);
			set @end_time=getdate();
			print 'LOADING DURATION :'+cast(datediff(second,@start_time,@end_time)as nvarchar)+'seconds';
			
			print '-------------------------';
			
			set @start_time=getdate();
			print '>>truncate table :bronze.crm_sales_details';
			TRUNCATE TABLE bronze.crm_sales_details ;
			print '>>insert into table :bronze.crm_sales_details';
			BULK INSERT bronze.crm_sales_details
			FROM 'D:\downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
			WITH
			(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
			);
			set @end_time=getdate();
			print 'LOADING DURATION :'+cast(datediff(second,@start_time,@end_time)as nvarchar)+'seconds';

			
			print'----ERP tables----------';
			
			set @start_time=getdate();
			print '>>truncate table :bronze.erp_cust_az12';
			TRUNCATE TABLE bronze.erp_cust_az12 ;
			print '>>insert into table :bronze.erp_cust_az12';
			BULK INSERT bronze.erp_cust_az12
			FROM 'D:\downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
			WITH
			(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
			);
			set @end_time=getdate();
			print 'LOADING DURATION :'+cast(datediff(second,@start_time,@end_time)as nvarchar)+'seconds';
			
			print '-------------------------';
			
			set @start_time=getdate();
			print '>>truncate table :bronze.erp_loc_a101';
			TRUNCATE TABLE bronze.erp_loc_a101;
			print '>>insert into table :bronze.erp_loc_a101';
			BULK INSERT bronze.erp_loc_a101
			FROM 'D:\downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
			WITH
			(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
			);
			set @end_time=getdate();
			print 'LOADING DURATION :'+cast(datediff(second,@start_time,@end_time )as nvarchar)+'seconds';
			
			print '-------------------------';
			
			set @start_time=getdate();
		    print '>>truncate table :bronze.erp_px_cat_g1v2 ';
			TRUNCATE TABLE bronze.erp_px_cat_g1v2 ;
			print '>>insert into table :bronze.erp_px_cat_g1v2 ';
			BULK INSERT bronze.erp_px_cat_g1v2
			FROM 'D:\downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
			WITH
			(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
			);
			set @end_time=getdate();
			print 'LOADING DURATION :'+cast(datediff(second,@start_time,@end_time)as nvarchar) +'seconds';
			
			print '-------------------------';
			
			print '>>bronze layer loading duration';
			set @batch_end_time=GETDATE();
			print 'TOTAL LOADING DURATION :'+cast(datediff(second,@batch_start_time,@batch_end_time)as nvarchar)+ 'seconds';
	
	end try
	begin catch
	print'===error occured during loading bronze layer===';
	print 'error message:'+ error_message();
	print 'error message:'+cast(error_number()as nvarchar);
	print 'error message:'+cast(error_state()as nvarchar);
	end catch
end
exec bronze.load_bronze;
	
