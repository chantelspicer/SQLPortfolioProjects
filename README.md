# SQLPortfolioProjects

# Project: COVID-19 Data Analysis

**Link to project:** https://github.com/chantelspicer/SQLPortfolioProjects

![COVID19_Tableau_Project](https://user-images.githubusercontent.com/94324220/214210515-0910f7e0-62c5-4464-a549-d5fa5b734fed.png)

## How It's Made:

**Tech used:** SQL, SSMS, Tableau, Excel, and GitHub

The COVID-19 Data Exploration project was my first large-scale project in the world of data analytics. I chose a COVID-19 dataset as I am a Registered Nurse working in Public Health with an interest in utilizing data to explore and improve health. I began by reviewing open-source worldwide COVID-19 datasets that would allow me to delve deeper into the effects of COVID-19 since the beginning, around January 2020. Once the datasets were downloaded, I separated the information into two spreadsheets, based on deaths and vaccinations and imported the datasets into Microsoft SQL Server Management Studio. Once completed, the fun began by exploring data through the implementation of various Data Definition Language (DDL) and Data Manipulation Language (DML) SQL queries into reportable information.

My last task was to choose several queries that would represent the COVID-19 dataset well and create a Tableau dashboard. For this, I used queries that related to global numbers, continents, countries, and the infection rate for specific countries. By manipulating the data, it became easier to visualize the impact COVID-19 has globally and my quest to use data to support population health.

## Optimizations:

Understanding the difference between data types like INT and BIGINT in SQL was an important aspect of database optimization. As the database values increased (due to increasing vaccination, death rates, etc), using the INT datatype was causing overflow errors and BIGINT had to be used instead. Another optimization made included cleaning up a query into less syntax for simplicity and ease of understanding. Previously, the query included a case statement, with the CONCAT() function to add a % symbol at the end, along with the CAST() function as a decimal with a maximum of 5 digits after the comma. While the end result of using the latter looked cleaner, it also was not as accurate due to the rounding caused by the CAST() function.

## Lessons Learned:

Understanding common table expressions (CTE), temporary tables, and the use of creating views were important advanced SQL topics to practice. For example, I tried to utilize an alias name from a column I created with OVER(PARTITION BY) to further expand the query by dividing and multiplying to display a percentage. Unfortunately, I determined this was not possible. However, by creating a CTE, this solution now became possible where I could select everything from within the CTE and perform the calculation outside the CTE by using the previous column alias. Moreover, I learned that creating views in SQL could simplify the database for external users. This project has highlighted the many opportunities for using SQL queries to transform data into valuable insights and information. It has reinforced the power and versatility of SQL as a tool for data exploration and analysis.

## Examples:
Take a look at my GitHub portfolio:

**GitHub Portfolio:** https://github.com/chantelspicer
