-- check overall data, get overview
SELECT 
id, name, startDate, 
STR_TO_DATE(startDate, '%Y-%m-%d') as start_date,
endDate, odi, t20, test, squads, matches
FROM series;

SELECT COUNT(*) AS total_row_count FROM series;

-- check clean data
SELECT *
FROM series
WHERE (name LIKE '%Pakistan%' OR name LIKE '%Bangladesh%')
  AND name NOT LIKE '%Women%'
  AND name NOT LIKE '%A tour%'
  AND name NOT LIKE '%League%';
  ;
  
  
  
  
--   new table
drop table series_1;
create table series_1 like series;

insert into series_1 select * from series;

-- check new table data
select * from series_1;

SELECT 
id, name, startDate,
endDate, odi, t20, test, squads, matches
FROM series_1
order by startDate;

-- Remove non BD/Pak data, remove women/league/A team, future series
SELECT *
FROM series_1
WHERE startDate < '2024-08-30' AND
(
(name LIKE '%Pakistan%' OR name LIKE '%Bangladesh%')
  AND name NOT LIKE '%Women%'
  AND name NOT LIKE '% A tour%'
  AND name NOT LIKE '%League%'
)
  order by startDate
  ;


DELETE FROM series_1
WHERE NOT (
    startDate < '2024-08-30' AND
    (
        (name LIKE '%Pakistan%' OR name LIKE '%Bangladesh%')
        AND name NOT LIKE '%Women%'
        AND name NOT LIKE '% A tour%'
        AND name NOT LIKE '%League%'
    )
);

SELECT id, startDate FROM series_1 order by startDate desc limit 1;
