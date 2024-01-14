--create database cricket
create database if not exists cricket;

--create schemas
create or replace schema cricket.land;
create or replace schema cricket.raw;
create or replace schema cricket.clean;
create or replace schema cricket.consumption;

--view schemas
show schemas in database cricket;

--create file format
create or replace file format my_json_format
    type = json
    null_if = ('\\n', 'null', '')
    strip_outer_array=true
    comment="Json File format";

--create internal named stage
create or replace stage cricket.land.my_stg;

-- view internal stage
list @cricket.land.my_stg;

--Loaded few sample files via Web UI

-- view files loaded in internal stage
list @cricket.land.my_stg/cricket/json;

--view sample data
select 
        t.$1:meta::variant as meta, 
        t.$1:info::variant as info, 
        t.$1:innings::array as innings, 
        metadata$filename as file_name,
        metadata$file_row_number int,
        metadata$file_content_key text,
        metadata$file_last_modified stg_modified_ts
     from  @my_stg/cricket/json/1000887.json (file_format => 'my_json_format') t;


-- load 2400+ files (odi matches - json data) using SnowSQL 

--connecting to snowsql -
snowsql -a bm65837.ap-southeast-1 -u Aniket

use database cricket;

use schema land;

put file:///C:\odis_male_json/*.json @my_stg/cricket/json/ parallel=50;

-- 
