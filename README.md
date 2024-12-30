# Social media sentiment analysis using sql

## Overview
This project involves a comprehensive analysis of sentiment on various social media platform. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives
* Analyze the sentiment in turms of platforms, country and time period.
* Identify the most common hashtags and sentiment type.
* List and analyze platforms based on years, months, countries, and engagement.
* Explore and categorize comments based on platforms and sentiment type.

## Used tool
PostgreSQL

## Schema
```sql
DROP TABLE IF EXISTS social;
CREATE TABLE social (
    index SERIAL PRIMARY KEY,
    text_posted_by_user TEXT,
    sentiment VARCHAR(50),
    timestamp TEXT,
    users VARCHAR(100),
    platform VARCHAR(50),
    hashtags TEXT,
    retweets INT,
    likes INT,
    country VARCHAR(100),
    year INT,
    month INT,
    day INT,
    hour INT
);
```
## Business Problems and Solutions

### 1.List the countries and number of posts where the sentiment score is negative.
```sql
SELECT 
    country,
    COUNT(*) AS negative_posts
FROM 
    social
WHERE 
    TRIM(BOTH E'\u00A0' FROM TRIM(sentiment)) = 'Negative'	
GROUP BY 
    country
ORDER BY 
    negative_posts DESC;
```
### 2.Identify the platform with the highest total engagement.
```sql
SELECT 
    platform,
    SUM(retweets + likes) AS total_engagement
FROM 
    social
GROUP BY 
    platform
ORDER BY 
    total_engagement DESC
LIMIT 1;
```
### 3.List the platforms along with their total engagement.
```sql
SELECT 
    platform,
    SUM(retweets + likes) AS total_engagement
FROM 
    social
GROUP BY 
    platform
ORDER BY 
    total_engagement DESC;
```
### 4.Identify and list the users by the count of there contents.
```sql
SELECT 
    users,
    COUNT(*) AS post_count
FROM 
    social
GROUP BY 
    users
ORDER BY 
    post_count DESC;
```
### 5.Identify the hour of the day with the highest average sentiment score.
```sql
WITH sentiment_scores AS (
    SELECT 
        "sentiment",
        ROW_NUMBER() OVER (ORDER BY "sentiment") AS sentiment_score
    FROM 
        (SELECT DISTINCT "sentiment" FROM social) AS distinct_sentiments
),
hourly_scores AS (
    SELECT 
        s."hour",
        sc.sentiment_score
    FROM 
        social s
    JOIN 
        sentiment_scores sc
    ON 
        s."sentiment" = sc."sentiment"
)
SELECT 
    "hour",
    AVG(sentiment_score) AS avg_sentiment_score
FROM 
    hourly_scores
GROUP BY 
    "hour"
ORDER BY 
    avg_sentiment_score DESC
LIMIT 1;
```
### 6.List hashtags that appear more than one time in posts with a positive sentiment.
```sql
WITH exploded_hashtags AS (
    SELECT 
        UNNEST(STRING_TO_ARRAY("hashtags", ' ')) AS hashtag
    FROM 
        social
    WHERE 
        LOWER(trim("sentiment")) = 'positive' -- Ensures case-insensitive matching
)
SELECT 
    hashtag,
    COUNT(*) AS usage_count
FROM 
    exploded_hashtags
WHERE hashtag != ''	
GROUP BY 
    hashtag
HAVING COUNT(*) > 1
ORDER BY 
    usage_count DESC
;
```
### 7.Find the most frequently used hashtag for each sentiment.
```sql
WITH exploded_hashtags AS (
    SELECT 
        sentiment,
        UNNEST(STRING_TO_ARRAY(hashtags, ' ')) AS hashtag
    FROM 
        social
),
hashtag_counts AS (
    SELECT 
        sentiment,
        hashtag,
        COUNT(*) AS usage_count
    FROM 
        exploded_hashtags
	WHERE hashtag != ''		
    GROUP BY 
        sentiment, hashtag
),
ranked_hashtags AS (
    SELECT 
        sentiment,
        hashtag,
        usage_count,
        RANK() OVER (PARTITION BY sentiment ORDER BY usage_count DESC) AS rank
    FROM 
        hashtag_counts
)
SELECT 
    sentiment,
    hashtag,
    usage_count
FROM 
    ranked_hashtags
WHERE 
    rank = 1;
```
### 8.Calculate the rolling average of engagement (retweets + likes) for each country based on the timestamp.
```sql
SELECT 
    country,
    timestamp,
    (retweets + likes) AS engagement,
    ROUND(AVG(retweets + likes) OVER (PARTITION BY country ORDER BY timestamp DESC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS rolling_avg_engagement
FROM 
    social
ORDER BY 
    country;
```
### 9.Rank sentiments based on their average engagement for each platform.
```sql
SELECT 
    platform,
    sentiment,
    ROUND(AVG(retweets + likes),2) AS avg_engagement,
    RANK() OVER (PARTITION BY platform ORDER BY AVG(retweets + likes) DESC) AS rank
FROM 
    social
GROUP BY 
    platform, sentiment
ORDER BY 
    platform, rank;
```
### 10.Find the hour with the highest number of positive sentiment posts.
```sql
SELECT 
    hour,
    COUNT(*) AS positive_sentiment_count
FROM 
    social
WHERE 
    LOWER(sentiment) = 'positive'
GROUP BY 
    hour
ORDER BY 
    positive_sentiment_count DESC
LIMIT 1;
```
### 11.Calculate the total engagement (retweets + likes) for each month and identify trends.
```sql
SELECT 
    year,
    month,
    SUM(retweets + likes) AS total_engagement
FROM 
    social
GROUP BY 
    year, month
ORDER BY 
    year DESC, month DESC;
```
### 12.List all posts with engagement (retweets + likes) above the platform average.
```sql
WITH PlatformAverage AS (
    SELECT 
        platform,
        ROUND(AVG(retweets + likes),2) AS avg_engagement
    FROM 
        social
    GROUP BY 
        platform
)

SELECT 
    s.text_posted_by_user,
    s.users,
    s.platform,
    (s.retweets + s.likes) AS total_engagement,
    p.avg_engagement
FROM 
    social s
JOIN 
    PlatformAverage p ON s.platform = p.platform
WHERE 
    (s.retweets + s.likes) > p.avg_engagement
ORDER BY 
    s.platform, total_engagement DESC;
```
### 13.Calculate the average engagement (retweets + likes) per sentiment for each country.
```sql
SELECT 
    country,
    sentiment,
    ROUND(AVG(retweets + likes),2) AS avg_engagement
FROM 
    social
GROUP BY 
    country, sentiment
ORDER BY 
    avg_engagement DESC;
```
### 14.Examine changes in sentiment over time for each platform to detect shifts in user mood or content reception.
```sql
SELECT 
    year,
    month,
    platform,
    sentiment,
    COUNT(*) AS sentiment_count
FROM 
    social
GROUP BY 
    year, month, platform, sentiment
ORDER BY 
    year DESC, month DESC,sentiment_count DESC;
```
### 15.Compare the monthly engagement and sentiment across different platforms to identify which platform performs best in various regions.
```sql
SELECT 
    platform,
    country,
    EXTRACT(MONTH FROM timestamp) AS month,
    SUM(retweets + likes) AS total_engagement,
    STRING_AGG(DISTINCT sentiment, ', ') AS sentiments_expressed
FROM 
    social
GROUP BY 
    platform, country, EXTRACT(MONTH FROM timestamp)
ORDER BY 
    country, platform, total_engagement DESC;
```

## Findings and Conclusion
* Content Distribution: The dataset contains a various range of social media platform data.
* Common sentiment: Insights into the most common sentiments provide an understanding of the users mood change.
* Geographical Insights: The top countries and their average sentiment by the time period to inderstand the flow.
* Categorization: Categorizing comments based on specific keywords helps in understanding the nature of sentiment for every platform.
  
This analysis provides a comprehensive view of Social media sentiment and can help in making marketing strategys and decision-making for product based companies.

