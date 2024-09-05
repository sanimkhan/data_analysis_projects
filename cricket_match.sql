rename table da_cricket_data.match to da_cricket_data.matches;

SHOW COLUMNS FROM series_1;
SHOW COLUMNS FROM matches;


SELECT * FROM matches;

SELECT * FROM matches where status not like '%won%';

-- create new table
drop table matches_1;
create table matches_1 like matches;
insert into matches_1 select * from matches;
select * from matches_1;


-- add columns to track win
alter table matches_1 drop column win_team, drop column win_how;
alter table matches_1 add column win_team text after status, add column win_how text after win_team;


-- scrap status to win_team and win_how
select status,
SUBSTRING_INDEX(status, ' won by ', 1) as win_team,
SUBSTRING_INDEX(status, ' won by ', -1) as win_how
from matches_1
WHERE status LIKE '% won by %';

select status, 'Draw' as win_team, NULL as win_how
from matches_1
WHERE status LIKE '%draw%';

select status, null as win_team, null as win_how
from matches_1
WHERE status NOT LIKE '% won by %' AND status NOT LIKE '%draw%';


UPDATE matches_1
SET win_team = SUBSTRING_INDEX(status, ' won by ', 1),
    win_how = SUBSTRING_INDEX(status, ' won by ', -1)
WHERE status LIKE '% won by %';

UPDATE matches_1
SET win_team = 'Draw',
    win_how = NULL
WHERE status LIKE '%draw%';

UPDATE matches_1
SET win_team = NULL,
    win_how = NULL
WHERE status NOT LIKE '% won by %' AND status NOT LIKE '%draw%';


select status, win_team, win_how from matches_1
where status like '%run% %'
or status LIKE '%wkts% %'
or status LIKE '%wickets% %'
;


UPDATE matches_1
SET win_how = CONCAT(TRIM(SUBSTRING_INDEX(win_how, 'runs', 1)), ' runs')
WHERE win_how LIKE '%runs% %';


UPDATE matches_1
SET win_how = CONCAT(TRIM(SUBSTRING_INDEX(win_how, 'wkts', 1)), ' wkts')
WHERE win_how LIKE '%wkts% %';

UPDATE matches_1
SET win_how = CONCAT(TRIM(SUBSTRING_INDEX(win_how, 'wickets', 1)), ' wickets')
WHERE win_how LIKE '%wickets% %';

