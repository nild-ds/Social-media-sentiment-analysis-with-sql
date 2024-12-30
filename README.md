# Social media sentiment analysis using sql

# Overview
This project involves a comprehensive analysis of sentiment on various social media platform. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

# Objectives
* Analyze the sentiment in turms of platforms, country and time period.
* Identify the most common hashtags and sentiment type.
* List and analyze platforms based on years, months, countries, and engagement.
* Explore and categorize comments based on platforms and sentiment type.

# Schema
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


#
