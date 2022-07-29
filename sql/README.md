# Production SQL Scripts

## Getting Up and Running
The production SQL scripts assume that a database named `CDPH` exists on the instance. If one does not, it can be created by executing:

`CREATE DATABASE CDPH;`

Populating the database with data can be done by:
1. Export a CSV file from OpenRefine after applying the cleaning recipes.
1. Execute the `OpenRefine Output Database Import.sql` script. Note that you must set the `@filename` variable within the script to the location of the OpenRefine CSV output file. If successful, 153,810 rows should be inserted - the same as the number of records from the original CSV file. If this is not the case, then something is wrong with your OpenRefine output file.
1. Execute the `../python/address-to-coordinates.py` script to look up and populate coordinates for all records with empty coordinates.
1. Execute the `Schema.sql` script to create the database from the schema.
1. Execute the `Populate Normalized Schema.sql` script to populate the database with data from the imported OpenRefine CSV output provided that no integrity constraint violations exist.

This sequence of steps may be re-run again, completely and in order, to freshly reload the dataset into the database without need for manual data deletion/truncation.

## Workflow Scripts
### Schema.sql
Instantiates the constraint-enforced Schema. This script first deletes the current schema instance if one exists.

### OpenRefine Output Database Import.sql
Imports the user-specified CSV version of the dataset into the `DataOpenRefine` staging table for relational analysis.

### Raw Data Database Import.sql
Imports the user-specified CSV version of the dataset into the `DataRaw` staging table for relational analysis. This script is functionally identical to `OpenRefine Output Database Import.sql`, except that it loads the data into a separately named table so that the original dataset and an OpenRefine-produced dataset may be relationally profiled and compared using SQL.

### Populate Normalized Schema.sql
Loads the `DataOpenRefine` staging table into the normalized schema. The script throws an error if an integrity constraint violation is encountered.

## Analysis and Profiling Scripts
### Delta D Analysis.sql
Provides integrity constraint violation checks, "before-and-after" data set comparisons, and high-level profiling. This script is the same as `queries.txt` in the project's root directory.

### Use Case U1.sql
Executes the U1 query against the cleaned dataset in the normalized schema.

### User Case U1 Dirty Data.sql
Executes the U1 query against the original, dirty dataset in from the `DataRaw` table (see `Raw Data Database Import.sql`).

### Phase-II Report Violations Field Normalization Example.sql
Generates the data and screenshot used in Section 1.3 of the Phase-II report.

### SQL Relational Integrity Constraint Check - Empty Address, City, Zip.sql
Returns records from the `DataOpenRefine` staging table which contain any empty Address, City, or Zip fields.

### SQL Relational Integrity Constraint Check - Empty Address.sql
Returns records from the `DataOpenRefine` staging table which contain an empty Address.

### SQL Relational Integrity Constraint Check - Empty City.sql
Returns records from the `DataOpenRefine` staging table which contain an empty City.

### SQL Relational Integrity Constraint Check - Empty Zip.sql
Returns records from the `DataOpenRefine` staging table which contain an empty Zip.

### SQL Relational Integrity Constraint Check - Inconsistent Business Address.sql
Returns records from the `DataOpenRefine` staging table whose address elements are candidate inconsistent duplicates of each other for manual analysis and reconciliation if necessary (discussed in Section 1 of the Phase-II report).

### SQL Relational Integrity Constraint Check - Inconsistent DBA_Name.sql
Returns records from the `DataOpenRefine` staging table whose business name are candidate inconsistent duplicates of each other for manual analysis and reconciliation if necessary (discussed in Section 1 of the Phase-II report).