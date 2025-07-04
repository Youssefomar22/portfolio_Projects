--Merging Master Database
Select * 

from portofolio..['data 10,4$']

union all

  select *
  from portofolio..['data 11,1,2,5$']

union all

  select *
  from portofolio..['data 3,9$']

union all

  select *
  from portofolio..['data 8$']

union all
  select *
  from portofolio..['data 9$']

union all
select *
from portofolio..['data6-12$']

--Creating Table for the database

create table Alldata 
(
member_casual nvarchar(55), 
rideable_type nvarchar(55),
Started_at datetime,
ended_at datetime
)

--Inserting Data

insert into Alldata
Select member_casual,rideable_type,started_at,ended_at

from portofolio..['data 10,4$']

union all

  select member_casual,rideable_type,started_at,ended_at
  from portofolio..['data 11,1,2,5$']

union all

  select member_casual,rideable_type,started_at,ended_at
  from portofolio..['data 3,9$']

union all

  select member_casual,rideable_type,started_at,ended_at
  from portofolio..['data 8$']

union all
  select member_casual,rideable_type,started_at,ended_at
  from portofolio..['data 9$']

union all
select member_casual,rideable_type,started_at,ended_at
from portofolio..['data6-12$'];





--Exctrcting Month/day/hour from started_at
select member_casual,rideable_type,
MONTH(started_at) as month,
DATENAME (weekday , started_at) as Dayname, --extracting the day name
DATEPART (HOUR, started_at) as hour
from portofolio..Alldata
order by month asc;

--Adding ride length to data
select member_casual,rideable_type,
ABS(Convert(float,ended_at-Started_at )*24*60) as Ride_lentgh -- Float to make the data decimal, (*24*60) to make the data with minutes
from portofolio..Alldata
order by member_casual asc;

--Adding ride_duration_category


select member_casual,rideable_type,
MONTH(started_at) as month,
DATENAME (weekday , started_at) as Dayname,
DATEPART (HOUR, started_at) as hour,
Case
  When ABS(Convert(float,ended_at-Started_at )*24*60) <10 then 'under 10' -- ABS to make sure the datae is positive
  when ABS(Convert(float,ended_at-Started_at )*24*60) >= 10 and  ABS(Convert(float,ended_at-Started_at )*24*60) <30 then '10 to 30' 
  when ABS(Convert(float,ended_at-Started_at )*24*60) >=30 and  ABS(Convert(float,ended_at-Started_at )*24*60) < 60 then '30 to 60'
  else 'over 60'
  end as ride_duration_category
from portofolio..Alldata
order by month asc;

-- Adding Number of rides to the data (aggregating the data)
WITH CategorizedRides AS
(
select member_casual,rideable_type,
MONTH(started_at) as month,
DATENAME (weekday , started_at) as Dayname,
DATEPART (HOUR, started_at) as hour,
Case
  When ABS(Convert(float,ended_at-Started_at )*24*60) <10 then 'under 10'
  when ABS(Convert(float,ended_at-Started_at )*24*60) >= 10 and  ABS(Convert(float,ended_at-Started_at )*24*60) <30 then '10 to 30'
  when ABS(Convert(float,ended_at-Started_at )*24*60) >=30 and  ABS(Convert(float,ended_at-Started_at )*24*60) < 60 then '30 to 60'
  else 'over 60'
  end as ride_duration_category
from portofolio..Alldata
)
SELECT
    member_casual,
    rideable_type,
    month,
    dayname,
    hour,
    Ride_duration_category,
    COUNT(*) AS NumberOfRides -- Corrected COUNT(*) for counting rows per group
FROM
    CategorizedRides
GROUP BY
    member_casual,
    rideable_type,
    month,
    dayname,
    hour,
    Ride_duration_category
ORDER BY
    NumberOfRides DESC;

    --Creating view for visualization
create view Fulldata as
WITH CategorizedRides AS
(
select member_casual,rideable_type,
MONTH(started_at) as month,
DATENAME (weekday , started_at) as Dayname,
DATEPART (HOUR, started_at) as hour,
Case
  When ABS(Convert(float,ended_at-Started_at )*24*60) <10 then 'under 10'
  when ABS(Convert(float,ended_at-Started_at )*24*60) >= 10 and  ABS(Convert(float,ended_at-Started_at )*24*60) <30 then '10 to 30'
  when ABS(Convert(float,ended_at-Started_at )*24*60) >=30 and  ABS(Convert(float,ended_at-Started_at )*24*60) < 60 then '30 to 60'
  else 'over 60'
  end as ride_duration_category
from portofolio..Alldata
)
SELECT
    member_casual,
    rideable_type,
    month,
    dayname,
    hour,
    Ride_duration_category,
    COUNT(*) AS NumberOfRides -- Corrected COUNT(*) for counting rows per group
FROM
    CategorizedRides
GROUP BY
    member_casual,
    rideable_type,
    month,
    dayname,
    hour,
    Ride_duration_category
