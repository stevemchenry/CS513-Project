# CS513-Project

## Summary
This repository contains a working collection of both production code and utility/analysis code snippets.

## Organization of Contents
This repository is organized into folders containing different aspects of the project.

### openrefine/
This folder contains the production OpenRefine recipes for the project. Until submission, each column of the dataset has a separate recipe file so that columns may be more easily worked with in a singular fashion to prevent inadvertent and undesired modifications to other columns.

### sql/
This folder contains production SQL queries. The only prerequisite are:
1. Microsoft SQL Server 2017 (or greater) as the database engine
1. A database named `CDPH` with the default collation `SQL_Latin1_General_CP1_CI_AS`

### sql-scratch-queries/
This folder contains "scratch" queries used primarily for exploration and analysis of the loaded dataset - either in its pre-normalization form in the `DataOpenRefine` staging/analysis table, or in its post-normalization form. These are queries that are helpful in aiding analysis and validation and are either frequently reused or lengthy to the point that they are inconvenient to re-write.

The quries in this folder have the same prerequisites as those in the `sql/` folder.