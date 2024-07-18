-- This program contains all the SQL code used for EDA on the 2015 GOP Debate Tweets Sentiment Analysis 
-- Data 650
-- Theodore Fitch
-- Last updated 16JUL24

-- DATA LOAD VALIDATION

-- Check the rows count to ensure proper data load
SELECT count(*) num_rows
  FROM FIRST_GOP_DEBATE;
  


-- SYSIBM.SYSTABLES to see all tables uploaded, the creator, the time created, and column count
 SELECT  NAME, CREATOR, CTIME, COLCOUNT
   FROM  SYSIBM.SYSTABLES
  WHERE  CREATOR ='TYG86489'; 
  


-- SYSIBM.SYSCOLUMNS to check metadata about each variable
SELECT  NAME, TBNAME, TBCREATOR, COLTYPE, NULLS, LENGTH
  FROM  SYSIBM.SYSCOLUMNS 
 WHERE  TBCREATOR='TYG86489'
   AND  TBNAME='FIRST_GOP_DEBATE';
  


-- Check for duplicate rows based on a unique identifier (assuming 'ID' is a unique identifier in the dataset)
SELECT ID, COUNT(*)
FROM FIRST_GOP_DEBATE
GROUP BY ID
HAVING COUNT(*) > 1;



-- Retrieve the first few rows of the table to verify data integrity and types
SELECT *
FROM FIRST_GOP_DEBATE
FETCH FIRST 10 ROWS ONLY;



-- EDA

-- Query to count how many times each candidate is mentioned in column B (candidate) and order the results by the count of mentions
SELECT candidate, COUNT(*) AS mention_count
FROM FIRST_GOP_DEBATE
GROUP BY candidate
ORDER BY mention_count DESC;




-- Query for # of rows for each sentiment level (excluding nulls)
SELECT 
    sentiment, 
    COUNT(*) AS Sentiment_Count
FROM 
    FIRST_GOP_DEBATE
WHERE 
    sentiment IS NOT NULL
GROUP BY 
    sentiment
ORDER BY 
    Sentiment_Count DESC;




-- Query to return the candidate name, number of negative, positive, neutral mentions, and total mentions for each candidate
SELECT 
    candidate AS Candidate_Name, 
    SUM(CASE WHEN sentiment = 'Negative' THEN 1 ELSE 0 END) AS Negative_Mentions,
    SUM(CASE WHEN sentiment = 'Positive' THEN 1 ELSE 0 END) AS Positive_Mentions,
    SUM(CASE WHEN sentiment = 'Neutral' THEN 1 ELSE 0 END) AS Neutral_Mentions,
    COUNT(*) AS Total_Mentions
FROM 
    FIRST_GOP_DEBATE
GROUP BY 
    candidate
ORDER BY 
    Total_Mentions DESC;




-- Query to find the most retweeted tweet count for each candidate and the average retweet count for each candidate
SELECT 
    candidate AS Candidate_Name, 
    MAX(retweet_count) AS Most_Retweeted_Tweet_Count,
    AVG(retweet_count) AS Average_Retweet_Count
FROM 
    FIRST_GOP_DEBATE
GROUP BY 
    candidate
ORDER BY 
    Most_Retweeted_Tweet_Count DESC;





-- Query to calculate the average number of retweets and favorites for each sentiment category
SELECT 
    SENTIMENT, 
    AVG(RETWEET_COUNT) AS Average_Retweets
FROM 
    FIRST_GOP_DEBATE
GROUP BY 
    SENTIMENT
ORDER BY 
    SENTIMENT;



-- Query to find the most active day (with the highest number of tweets) for each candidate
SELECT 
    CANDIDATE AS Candidate_Name, 
    LEFT(TWEET_CREATED, LOCATE(' ', TWEET_CREATED) - 1) AS Tweet_Date, 
    COUNT(*) AS Total_Tweets
FROM 
    FIRST_GOP_DEBATE
GROUP BY 
    CANDIDATE, LEFT(TWEET_CREATED, LOCATE(' ', TWEET_CREATED) - 1)
ORDER BY 
    Candidate_Name, Total_Tweets DESC;



-- Query to find the top 10 most retweeted tweets
SELECT 
    id, 
    candidate, 
    sentiment, 
    retweet_count,
    text
FROM 
    FIRST_GOP_DEBATE
ORDER BY 
    retweet_count DESC
FETCH FIRST 10 ROWS ONLY;


-- Query to count the number of missing (NULL) values for each variable in the dataset
SELECT 
    'ID' AS Column_Name, 
    COUNT(*) - COUNT(ID) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'CANDIDATE' AS Column_Name, 
    COUNT(*) - COUNT(CANDIDATE) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'CANDIDATE_CONFIDENCE' AS Column_Name, 
    COUNT(*) - COUNT(CANDIDATE_CONFIDENCE) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'RELEVANT_YN' AS Column_Name, 
    COUNT(*) - COUNT(RELEVANT_YN) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'RELEVANT_YN_CONFIDENCE' AS Column_Name, 
    COUNT(*) - COUNT(RELEVANT_YN_CONFIDENCE) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'SENTIMENT' AS Column_Name, 
    COUNT(*) - COUNT(SENTIMENT) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'SENTIMENT_CONFIDENCE' AS Column_Name, 
    COUNT(*) - COUNT(SENTIMENT_CONFIDENCE) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'SUBJECT_MATTER' AS Column_Name, 
    COUNT(*) - COUNT(SUBJECT_MATTER) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'SUBJECT_MATTER_CONFIDENCE' AS Column_Name, 
    COUNT(*) - COUNT(SUBJECT_MATTER_CONFIDENCE) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'CANDIDATE_GOLD' AS Column_Name, 
    COUNT(*) - COUNT(CANDIDATE_GOLD) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'NAME' AS Column_Name, 
    COUNT(*) - COUNT(NAME) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'RELEVANT_YN_GOLD' AS Column_Name, 
    COUNT(*) - COUNT(RELEVANT_YN_GOLD) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'RETWEET_COUNT' AS Column_Name, 
    COUNT(*) - COUNT(RETWEET_COUNT) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'SENTIMENT_GOLD' AS Column_Name, 
    COUNT(*) - COUNT(SENTIMENT_GOLD) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'SUBJECT_MATTER_GOLD' AS Column_Name, 
    COUNT(*) - COUNT(SUBJECT_MATTER_GOLD) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'TEXT' AS Column_Name, 
    COUNT(*) - COUNT(TEXT) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'TWEET_COORD' AS Column_Name, 
    COUNT(*) - COUNT(TWEET_COORD) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'TWEET_CREATED' AS Column_Name, 
    COUNT(*) - COUNT(TWEET_CREATED) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'TWEET_ID' AS Column_Name, 
    COUNT(*) - COUNT(TWEET_ID) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'TWEET_LOCATION' AS Column_Name, 
    COUNT(*) - COUNT(TWEET_LOCATION) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE

UNION ALL

SELECT 
    'USER_TIMEZONE' AS Column_Name, 
    COUNT(*) - COUNT(USER_TIMEZONE) AS Missing_Values
FROM 
    FIRST_GOP_DEBATE;

