-- create raw table to store match data
create or replace table cricket.raw.match_raw_table(
meta object not null,
info variant not null,
innings ARRAY not null,
stg_file_name text not null,
stg_file_row_number int not null,
stg_file_hashkey text not null,
stg_modified_ts timestamp not null
);

--execute copy command and load odi match data
copy into cricket.raw.match_raw_table
from ( select 
t.$1:meta::object as meta, 
t.$1:info::variant as info, 
t.$1:innings::array as innings,
metadata$filename,
metadata$file_row_number,
metadata$file_content_key,
metadata$file_last_modified
from @cricket.land.my_stg/cricket/json (file_format => 'cricket.land.my_json_format') t ) on_error='continue';

-- verify all match data is copied onto the raw match table successfully

select count(*) from cricket.raw.match_raw_table;

select * from cricket.raw.match_raw_table limit 10;
