# Production SQL Scripts

## Getting Up and Running
The production SQL scripts assume that a database named `CDPH` exists on the instance. If one does not, it can be created by executing:

`CREATE DATABASE CDPH;`

Populating the database with data can be done by:
1. Export a CSV file from OpenRefine after applying the cleaning recipes.
1. Execute the `OpenRefine Output Database Import.sql` script. Note that you must set the `@filename` variable within the script to the location of the OpenRefine CSV output file. If successful, 153,810 rows should be inserted - the same as the number of records from the original CSV file. If this is not the case, then something is wrong with your OpenRefine output file.
1. Execute the `Schema.sql` script to create the database from the schema.
1. Execute the `Populate Normalized Schema.sql` script to populate the database with data from the imported OpenRefine CSV output.

This sequence of steps may be re-run again, completely and in order, to freshly reload the dataset into the database without need for manual data deletion/truncation.