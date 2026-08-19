
/*
===========================================
create database and it's schemas
===========================================
Script Purpose:
 this script creates a new databse named 'DataWarhouse' after checking if it is alreay exists.
 If the database exists ,it is dropped and recreated. Additionally the script sets up three schemas
 within the database: 'bronze, 'silver', and 'gold'.

 Warning:
  Running this script will drop the entire database if it exists.
  All data in the database will be permantly deleted. Proceed with caution 
  and ensure that you have proper backups before running this script.
*/
use master;
go
----drop dwh if exist to recreate---
if exists(select 1 from sys.databases where name='DataWarhouse')
begin
alter database DataWarhouse  set SINGLE_USER with Rollback IMMEDIATE ;
drop database DataWarhouse 
end;
go
----create dwh database---
create database DataWarhouse;
use DataWarhouse;
Go
-----create schemas-----
 create schema bronze;
  go
  create schema silver;
  Go
   create schema gold;
