-- Creating Dimesion and Fact Tables 

--Venue Dimension
create or replace table cricket.consumption.venue_dim (
    venue_id int primary key autoincrement,
    venue_name text not null,
    city text
);

insert into cricket.consumption.venue_dim(venue_name,city)
select distinct venue,city from cricket.clean.match_detail_clean
group by venue,city
order by 1,2;

select * from venue_dim limit 10;

--Team Dimension
create or replace table team_dim (
    team_id int primary key autoincrement,
    team_name text not null
);

insert into team_dim(team_name)
select distinct country from cricket.clean.player_clean_tbl;

select * from team_dim limit 10;

--Player dimension
create or replace table player_dim (
    player_id int primary key autoincrement,
    team_id int not null,
    player_name text not null
);

alter table cricket.consumption.player_dim
add constraint fk_team_player_id
foreign key (team_id)
references cricket.consumption.team_dim (team_id);

insert into player_dim(team_id,player_name)
select distinct team_id,player_name from cricket.clean.player_clean_tbl a join cricket.consumption.team_dim b 
on a.country=b.team_name group by team_id,player_name;

select * from player_dim limit 10;

--Match Dimension
create or replace table match_type_dim (
    match_type_id int primary key autoincrement,
    match_type text not null
);

insert into match_type_dim(match_type)
select distinct match_type from cricket.clean.match_detail_clean;

select * from match_type_dim;

--Date Dimension
create or replace table date_dim (
    date_id int primary key autoincrement,
    full_dt date,
    day int,
    month int,
    year int,
    quarter int,
    dayofweek int,
    dayofmonth int,
    dayofyear int,
    dayofweekname varchar(3), -- to store day names (e.g., "Mon")
    isweekend boolean -- to indicate if it's a weekend (True/False Sat/Sun both falls under weekend)
);


CREATE or replace TABLE cricket.consumption.date_rnage01 (Date DATE);

INSERT INTO cricket.consumption.date_dim (Date_ID, Full_Dt, Day, Month, Year, Quarter, DayOfWeek, DayOfMonth, DayOfYear, DayOfWeekName, IsWeekend)
SELECT
    ROW_NUMBER() OVER (ORDER BY Date) AS DateID,
    Date AS FullDate,
    EXTRACT(DAY FROM Date) AS Day,
    EXTRACT(MONTH FROM Date) AS Month,
    EXTRACT(YEAR FROM Date) AS Year,
    CASE WHEN EXTRACT(QUARTER FROM Date) IN (1, 2, 3, 4) THEN EXTRACT(QUARTER FROM Date) END AS Quarter,
    DAYOFWEEKISO(Date) AS DayOfWeek,
    EXTRACT(DAY FROM Date) AS DayOfMonth,
    DAYOFYEAR(Date) AS DayOfYear,
    DAYNAME(Date) AS DayOfWeekName,
    CASE When DAYNAME(Date) IN ('Sat', 'Sun') THEN 1 ELSE 0 END AS IsWeekend
FROM cricket.consumption.date_rnage01;

select * from cricket.consumption.date_dim;

select * from cricket.consumption.date_rnage01;


--Match Fact Table
CREATE or replace TABLE match_fact (
    match_id INT PRIMARY KEY,
    date_id INT NOT NULL,
    team_a_id INT NOT NULL,
    team_b_id INT NOT NULL,
    match_type_id INT NOT NULL,
    venue_id INT NOT NULL,
    total_overs number(3),
    balls_per_over number(1),

    overs_played_by_team_a number(2),
    bowls_played_by_team_a number(3),
    extra_bowls_played_by_team_a number(3),
    extra_runs_scored_by_team_a number(3),
    fours_by_team_a number(3),
    sixes_by_team_a number(3),
    total_score_by_team_a number(3),
    wicket_lost_by_team_a number(2),

    overs_played_by_team_b number(2),
    bowls_played_by_team_b number(3),
    extra_bowls_played_by_team_b number(3),
    extra_runs_scored_by_team_b number(3),
    fours_by_team_b number(3),
    sixes_by_team_b number(3),
    total_score_by_team_b number(3),
    wicket_lost_by_team_b number(2),

    toss_winner_team_id int not null, 
    toss_decision text not null, 
    match_result text not null, 
    winner_team_id int not null,

    CONSTRAINT fk_date FOREIGN KEY (date_id) REFERENCES date_dim (date_id),
    CONSTRAINT fk_team1 FOREIGN KEY (team_a_id) REFERENCES team_dim (team_id),
    CONSTRAINT fk_team2 FOREIGN KEY (team_b_id) REFERENCES team_dim (team_id),
    CONSTRAINT fk_match_type FOREIGN KEY (match_type_id) REFERENCES match_type_dim (match_type_id),
    CONSTRAINT fk_venue FOREIGN KEY (venue_id) REFERENCES venue_dim (venue_id),
    CONSTRAINT fk_toss_winner_team FOREIGN KEY (toss_winner_team_id) REFERENCES team_dim (team_id),
    CONSTRAINT fk_winner_team FOREIGN KEY (winner_team_id) REFERENCES team_dim (team_id)
);

insert into cricket.consumption.match_fact 
select 
    m.match_type_number as match_id,
    dd.date_id as date_id,
    ftd.team_id as first_team_id,
    std.team_id as second_team_id,
    mtd.match_type_id as match_type_id,
    vd.venue_id as venue_id,
    50 as total_overs,
    6 as balls_per_overs,
    max(case when d.country = m.first_team then  d.over else 0 end ) as OVERS_PLAYED_BY_TEAM_A,
    sum(case when d.country = m.first_team then  1 else 0 end ) as balls_PLAYED_BY_TEAM_A,
    sum(case when d.country = m.first_team then  d.extras else 0 end ) as 
extra_balls_PLAYED_BY_TEAM_A,
    sum(case when d.country = m.first_team and d.extras <> 0 then 1 else 0 end ) as extra_runs_scored_BY_TEAM_A,
    sum(case when d.country = m.first_team  and d.runs=4 then 1 else 0 end ) fours_by_team_a,
    sum(case when d.country = m.first_team  and d.runs=6 then 1 else 0 end ) sixes_by_team_a,
    (sum(case when d.country = m.first_team then  d.runs else 0 end ) + sum(case when d.country = m.first_team then  d.extra_runs else 0 end ) ) as total_runs_scored_BY_TEAM_A,
    sum(case when d.country = m.first_team and player_out is not null then  1 else 0 end ) as wicket_lost_by_team_a,    
    
    max(case when d.country = m.second_team then d.over else 0 end ) as OVERS_PLAYED_BY_TEAM_B,
    sum(case when d.country = m.second_team then  1 else 0 end ) as balls_PLAYED_BY_TEAM_B,
    sum(case when d.country = m.second_team and d.extras <> 0 then 1 else 0 end ) as extra_balls_PLAYED_BY_TEAM_B,
    sum(case when d.country = m.second_team then  d.extra_runs else 0 end ) as extra_runs_scored_BY_TEAM_B,
   sum(case when d.country = m.second_team  and d.runs=4 then 1 else 0 end ) fours_by_team_b,
   sum(case when d.country = m.second_team  and d.runs=6 then 1 else 0 end ) sixes_by_team_b,
    (sum(case when d.country = m.second_team then  d.runs else 0 end ) + sum(case when d.country = m.second_team then  d.extra_runs else 0 end ) ) as total_runs_scored_BY_TEAM_B,
    sum(case when d.country = m.second_team and player_out is not null then  1 else 0 end ) as wicket_lost_by_team_b,
    tw.team_id as toss_winner_team_id,
    m.toss_decision as toss_decision,
    m.match_result as match_result,
    mw.team_id as winner_team_id
from 
    cricket.clean.match_detail_clean m
    join date_dim dd on m.event_date = dd.full_dt
    join team_dim ftd on m.first_team = ftd.team_name 
    join team_dim std on m.second_team = std.team_name 
    join match_type_dim mtd on m.match_type = mtd.match_type
    join venue_dim vd on m.venue = vd.venue_name and m.city = vd.city
    join cricket.clean.delivery_clean_tbl d  on d.match_type_number = m.match_type_number 
    join team_dim tw on m.toss_winner = tw.team_name 
    join team_dim mw on m.winner= mw.team_name 
    group by
        m.match_type_number,
        date_id,
        first_team_id,
        second_team_id,
        match_type_id,
        venue_id,
        total_overs,
        toss_winner_team_id,
        toss_decision,
        match_result,
        winner_team_id;



--Delivery Fact Table
CREATE or replace TABLE delivery_fact (
    match_id INT ,
    team_id INT,
    bowler_id INT,
    batter_id INT,
    non_striker_id INT,
    over INT,
    runs INT,
    extra_runs INT,
    extra_type VARCHAR(255),
    player_out VARCHAR(255),
    player_out_kind VARCHAR(255),

    CONSTRAINT fk_del_match_id FOREIGN KEY (match_id) REFERENCES match_fact (match_id),
    CONSTRAINT fk_del_team FOREIGN KEY (team_id) REFERENCES team_dim (team_id),
    CONSTRAINT fk_bowler FOREIGN KEY (bowler_id) REFERENCES player_dim (player_id),
    CONSTRAINT fk_batter FOREIGN KEY (batter_id) REFERENCES player_dim (player_id),
    CONSTRAINT fk_stricker FOREIGN KEY (non_striker_id) REFERENCES player_dim (player_id)
);


insert into cricket.consumption.delivery_fact
select 
    d.match_type_number as match_id,
    td.team_id,
    bpd.player_id as bower_id, 
    spd.player_id batter_id, 
    nspd.player_id as non_stricker_id,
    d.over,
    d.runs,
    case when d.extra_runs is null then 0 else d.extra_runs end as extra_runs,
    case when d.extra_type is null then 'None' else d.extra_type end as extra_type,
    case when d.player_out is null then 'None' else d.player_out end as player_out,
    case when d.player_out_kind is null then 'None' else d.player_out_kind end as player_out_kind
from 
    cricket.clean.delivery_clean_tbl d
    join match_fact mf on d.match_type_number=mf.match_id
    join team_dim td on d.country = td.team_name
    join player_dim bpd on d.bowler = bpd.player_name
    join player_dim spd on d.batter = spd.player_name
    join player_dim nspd on d.non_striker = nspd.player_name;

