-- Query 1: Get an overview of the 'series' table data
SELECT 
    id, 
    name, 
    startDate, 
    STR_TO_DATE(startDate, '%Y-%m-%d') AS start_date, -- Convert startDate to proper date format
    endDate, 
    odi, 
    t20, 
    test, 
    squads, 
    matches
FROM 
    series;

-- Query 2: Count the total number of rows in the 'series' table
SELECT 
    COUNT(*) AS total_row_count 
FROM 
    series;

-- Query 3: Fetch cleaned data by filtering out series that are not relevant to Pakistan or Bangladesh
SELECT *
FROM 
    series
WHERE 
    (name LIKE '%Pakistan%' OR name LIKE '%Bangladesh%')  -- Include only Pakistan or Bangladesh series
    AND name NOT LIKE '%Women%'                           -- Exclude women's matches
    AND name NOT LIKE '%A tour%'                          -- Exclude A team tours
    AND name NOT LIKE '%League%';                         -- Exclude league matches

-- Drop the existing 'series_1' table if it exists
DROP TABLE IF EXISTS series_1;

-- Create a new table 'series_1' with the same structure as 'series'
CREATE TABLE series_1 LIKE series;

-- Insert all records from 'series' into 'series_1'
INSERT INTO series_1 
SELECT * 
FROM series;

-- Check if data was copied to the new 'series_1' table
SELECT * 
FROM series_1;

-- Query 4: Check and order data by start date in 'series_1'
SELECT 
    id, 
    name, 
    startDate,
    endDate, 
    odi, 
    t20, 
    test, 
    squads, 
    matches
FROM 
    series_1
ORDER BY 
    startDate;

-- Query 5: Remove irrelevant data, keep only Pakistan/Bangladesh, and filter by date (no future series)
SELECT *
FROM 
    series_1
WHERE 
    startDate < '2024-08-30'  -- Exclude future series
    AND (
        (name LIKE '%Pakistan%' OR name LIKE '%Bangladesh%')  -- Include only Pakistan or Bangladesh series
        AND name NOT LIKE '%Women%'                           -- Exclude women's matches
        AND name NOT LIKE '% A tour%'                         -- Exclude A team tours
        AND name NOT LIKE '%League%'                          -- Exclude league matches
    )
ORDER BY 
    startDate;

-- Query 6: Permanently delete rows that do not match Pakistan/Bangladesh series before 2024-08-30
DELETE FROM 
    series_1
WHERE 
    NOT (
        startDate < '2024-08-30'  -- Exclude future series
        AND (
            (name LIKE '%Pakistan%' OR name LIKE '%Bangladesh%')  -- Include only Pakistan or Bangladesh series
            AND name NOT LIKE '%Women%'                           -- Exclude women's matches
            AND name NOT LIKE '% A tour%'                         -- Exclude A team tours
            AND name NOT LIKE '%League%'                          -- Exclude league matches
        )
    );

-- Query 7: Get the most recent series (by startDate) from 'series_1'
SELECT 
    id, 
    startDate 
FROM 
    series_1 
ORDER BY 
    startDate DESC 
LIMIT 1;
