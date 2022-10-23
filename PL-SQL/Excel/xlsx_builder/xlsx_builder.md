# XLSX_BUILDER_PKG
A PL/SQL Package to create OOXML workbooks.
This package is based on work done by Anton Scheffer.  
It also includes additions to support my own package [APEXIR_XLSX_PKG](https://github.com/commi235/APEX_IR_XLSX)

## Installation
### Single Script
1. Install ZIP_UTIL_PKG and XLSX_BUILDER_PKG by running install_full.sql script.

### One by One
1. Install the ZIP_UTIL_PKG from the lib folder.
2. Install XLSX_BUILDER_PKG by running install.sql

## Export Data into Excel from Oracle Table Using PL SQL

### Create Oracle Directory Object

```sql
Create OR Replace Directory excel_files as  'c:\excel_files';
```sql

```sql
create or replace directory app_dir as '/opt/oracle/appdir';
grant read, write on directory app_dir to hr;
```sql

### Export Data into Excel from Oracle Table using PL SQL

```sql
BEGIN
xlsx_builder_Pkg.clear_workbook;
xlsx_builder_pkg.new_sheet ('emp');
xlsx_builder_pkg.query2sheet (p_sql => 'select * from emp', p_sheet => 1);
xlsx_builder_pkg.save ('EXCEL_FILES', 'emp.xlsx');
END;
```sql

```sql
BEGIN
xlsx_builder_Pkg.clear_workbook;
xlsx_builder_pkg.new_sheet ('emp');
xlsx_builder_pkg.query2sheet (p_sql => 'select * from emp', p_sheet => 1);
xlsx_builder_pkg.new_sheet ('dept');
xlsx_builder_pkg.query2sheet (p_sql => 'select deptno, dname from dept where deptno = 20',
 p_sheet => 2);
xlsx_builder_pkg.save ('EXCEL_FILES', 'emp.xlsx');
END;
```sql
