-- Rename the table 'match' to 'matches' in the 'da_cricket_data' database
RENAME TABLE da_cricket_data.match TO da_cricket_data.matches;

-- Show the structure of the 'series_1' table
SHOW COLUMNS FROM series_1;

-- Show the structure of the 'matches' table
SHOW COLUMNS FROM matches;

-- Retrieve all records from the 'matches' table
SELECT * FROM matches;

-- Retrieve matches where the status does not contain the word 'won'
SELECT * FROM matches 
WHERE status NOT LIKE '%won%';

-- Drop the existing 'matches_1' table if it exists and create a new one
DROP TABLE IF EXISTS matches_1;
CREATE TABLE matches_1 LIKE matches;

-- Insert all records from 'matches' into 'matches_1'
INSERT INTO matches_1 
SELECT * 
FROM matches;

-- Check the data in 'matches_1' after insertion
SELECT * FROM matches_1;

-- Drop columns 'win_team' and 'win_how' if they exist, and then add them again to track match outcomes
ALTER TABLE matches_1 
DROP COLUMN IF EXISTS win_team, 
DROP COLUMN IF EXISTS win_how;

ALTER TABLE matches_1 
ADD COLUMN win_team TEXT AFTER status, 
ADD COLUMN win_how TEXT AFTER win_team;

-- Scrape match outcomes (win_team and win_how) from the status column where matches are won
SELECT 
    status,
    SUBSTRING_INDEX(status, ' won by ', 1) AS win_team, -- Extract winning team from the 'status'
    SUBSTRING_INDEX(status, ' won by ', -1) AS win_how  -- Extract the winning method (runs/wickets)
FROM 
    matches_1
WHERE 
    status LIKE '% won by %';

-- Handle drawn matches, setting win_team to 'Draw' and win_how to NULL
SELECT 
    status, 
    'Draw' AS win_team, 
    NULL AS win_how
FROM 
    matches_1
WHERE 
    status LIKE '%draw%';

-- Handle matches with no clear winner (e.g., abandoned or tied matches)
SELECT 
    status, 
    NULL AS win_team, 
    NULL AS win_how
FROM 
    matches_1
WHERE 
    status NOT LIKE '% won by %' 
    AND status NOT LIKE '%draw%';

-- Update the 'matches_1' table to populate win_team and win_how from the 'status' column
UPDATE matches_1
SET 
    win_team = SUBSTRING_INDEX(status, ' won by ', 1),  -- Extract winning team
    win_how = SUBSTRING_INDEX(status, ' won by ', -1)  -- Extract the method of victory
WHERE 
    status LIKE '% won by %';

-- Update drawn matches with 'Draw' as the win_team and NULL as win_how
UPDATE matches_1
SET 
    win_team = 'Draw', 
    win_how = NULL
WHERE 
    status LIKE '%draw%';

-- Update matches where there is no winner to set both win_team and win_how to NULL
UPDATE matches_1
SET 
    win_team = NULL, 
    win_how = NULL
WHERE 
    status NOT LIKE '% won by %' 
    AND status NOT LIKE '%draw%';

-- Verify updates: Check the status, win_team, and win_how columns
SELECT 
    status, 
    win_team, 
    win_how 
FROM 
    matches_1;

-- Normalize the 'win_how' values to ensure proper formatting
-- Update cases where 'win_how' has extra text for runs
UPDATE matches_1
SET 
    win_how = CONCAT(TRIM(SUBSTRING_INDEX(win_how, 'runs', 1)), ' runs')  -- Remove unwanted text around 'runs'
WHERE 
    win_how LIKE '%runs% %';

-- Update cases where 'win_how' has extra text for wickets ('wkts')
UPDATE matches_1
SET 
    win_how = CONCAT(TRIM(SUBSTRING_INDEX(win_how, 'wkts', 1)), ' wkts')  -- Handle 'wkts' cases
WHERE 
    win_how LIKE '%wkts% %';

-- Update cases where 'win_how' mentions full 'wickets'
UPDATE matches_1
SET 
    win_how = CONCAT(TRIM(SUBSTRING_INDEX(win_how, 'wickets', 1)), ' wickets')  -- Handle 'wickets' cases
WHERE 
    win_how LIKE '%wickets% %';

-- Standardize abbreviations ('wkts' -> 'wickets')
UPDATE matches_1
SET 
    win_how = REPLACE(win_how, 'wkts', 'wickets')  -- Replace 'wkts' with 'wickets'
WHERE 
    win_how LIKE '%wkts%';

-- Standardize abbreviations ('wkt' -> 'wickets')
UPDATE matches_1
SET 
    win_how = REPLACE(win_how, 'wkt', 'wickets')  -- Replace 'wkt' with 'wickets'
WHERE 
    win_how LIKE '%wkt%';

-- Clean up erroneous text (e.g., 'Day 5: 2nd Session - Pakistan' mistakenly labeled as win_team)
SELECT * FROM matches_1 
WHERE 
    status LIKE '%Day 5: 2nd Session - Pakistan%';

-- Correct the 'win_team' for the erroneous entry
UPDATE matches_1 
SET 
    win_team = 'Pakistan'  -- Set 'Pakistan' as the win_team
WHERE 
    win_team = 'Day 5: 2nd Session - Pakistan';

-- Display all records from 'series_1' and 'matches_1' for review
SELECT * FROM series_1;
SELECT * FROM matches_1;

-- Query to join 'series_1' and 'matches_1', and display relevant match information
SELECT 
    s.id AS series_id,
    s.name AS series_name,
    -- s.startDate,
    -- s.odi,
    -- s.t20,
    -- s.test,
    s.matches,
    m.match_id,
    m.match_name,
    m.match_type,
    -- m.status,
    m.team1,
    m.team2,
    m.win_team,
    m.win_how,
    m.venue,
    m.date
FROM 
    series_1 s
JOIN 
    matches_1 m ON s.id = m.series_id;

-- Query to display the number of matches played by Bangladesh and Pakistan by year
SELECT 
    YEAR(date) AS year,
    SUM(CASE WHEN team1 = 'Bangladesh' OR team2 = 'Bangladesh' THEN 1 ELSE 0 END) AS bangladesh_matches_played,  -- Count Bangladesh matches
    SUM(CASE WHEN team1 = 'Pakistan' OR team2 = 'Pakistan' THEN 1 ELSE 0 END) AS pakistan_matches_played  -- Count Pakistan matches
FROM 
    matches_1
GROUP BY 
    YEAR(date)
ORDER BY 
    year;

-- Queries to check specific venues for matches
-- Retrieve matches played in 'Rawalpindi Cricket Stadium, Rawalpindi'
SELECT * FROM matches_1 
WHERE 
    venue = 'Rawalpindi Cricket Stadium, Rawalpindi';

-- Retrieve matches played in 'Zahur Ahmed Chowdhury Stadium, Chattogram' where Bangladesh played
SELECT * FROM matches_1 
WHERE 
    venue = 'Zahur Ahmed Chowdhury Stadium, Chattogram' 
    AND status LIKE '%Ban%';

-- Retrieve matches played in 'Sylhet International Cricket Stadium, Sylhet' where Bangladesh played
SELECT * FROM matches_1 
WHERE 
    venue = 'Sylhet International Cricket Stadium, Sylhet' 
    AND status LIKE '%Ban%';
