End to end Data engineering solution for ODI cricket dataset using Snowflake - Cloud Data warehouse

Dataset - All ODI cricket matches (played between 2000 and 2023) data 
Format - Dataset includes JSON file for each match containing all information

**Data flow  (ETL pipeline) : ** 

**1.Data ingestion**
Load raw data into Snowflake Stage using SnowSQL CLI
Copy data from SF Internal stage to Landing layer

**2.Data transformation**
Perform data transformations (flatten JSON data and load as relational tables) and move data to Curated layer

**3.Dimensional modelling** 
Create fact and dimenion tables and move data to Consumption layer

**4.Data visualization** (using Power BI)

**5.Automate entire process** from Ingestion (Raw layer) to loading to Consumption layer via Snowflake Streams and Tasks.

Screenshots - 

Architecture

![image](https://github.com/AniketRathod305/Cricket_Data_Engineering/assets/70813453/88233d18-ee42-49b1-8cc8-c9b8dcc43624)

Fact and Dimension tables
![image](https://github.com/AniketRathod305/Cricket_Data_Engineering/assets/70813453/95cd1ff8-2992-4675-8150-8ec3bb42572e)

Power BI Dashboard 
![image](https://github.com/AniketRathod305/Cricket_Data_Engineering/assets/70813453/3f8b618a-444b-409c-be08-067601a558ed)
