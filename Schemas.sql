-- SCHEMAS of Social table

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