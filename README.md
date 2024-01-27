End to end Data engineering solution for ODI cricket dataset using Snowflake - Cloud Data warehouse

Dataset - All ODI cricket matches (played between 2000 and 2023) data 
Format - Dataset includes JSON file for each match containing all information

Data flow  (ETL pipeline) - 

1.Data ingestion
Load raw data into Snowflake Stage using SnowSQL CLI
Copy data from SF Internal stage to Landing layer

2.Data transformation
Perform data transformations (flatten JSON data and load as relational tables) and move data to Curated layer

3.Dimensional modelling 
Create fact and dimenion tables and move data to Consumption layer

4.Data visualizatin (using Power BI)



