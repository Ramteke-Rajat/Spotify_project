# Spotify_project
Project Category: Advanced
[Click Here to get Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)

![Spotify Logo](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_logo.jpg)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql
-- Creating the Table = spotify

DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify
(	artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

SELECT * FROM spotify;
```
## Project Steps

### Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

```sql
SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;

SELECT MIN(duration_min) FROM spotify;

SELECT * FROM spotify
WHERE duration_min = 0

-- Duration of a song cannot be 0, hence deleting the records for 0 duration.

DELETE FROM spotify
WHERE duration_min = 0

SELECT COUNT(DISTINCT channel) FROM spotify;

SELECT DISTINCT most_played_on FROM spotify;
```
---

## 15 Project Tasks

Task 1. Retrieve the names of all tracks that have more than 1 billion streams.
```sql
SELECT 
	track,
	stream
FROM
	spotify
WHERE 
	stream > 1000000000;
```

Task 2. List all albums along with their respective artists.
```sql
SELECT 
	DISTINCT album,
	artist
FROM spotify;
```

Task 3. Get the total number of comments for tracks where licensed = TRUE.
```sql
SELECT 
	SUM(comments) as total_comments
FROM 
	spotify
WHERE 
	licensed = 'TRUE';
```

Task 4. Find all tracks that belong to the album type single.
```sql
SELECT
	*
FROM
	spotify
WHERE
	album_type = 'single';
```

Task 5. Count the total number of tracks by each artist.
```sql
SELECT
	DISTINCT artist,
	COUNT(track) as total_tracks
FROM
	spotify
GROUP by artist;
```

Task 6. Calculate the average danceability of tracks in each album.
```sql
SELECT 
	DISTINCT album,
	AVG(danceability) as avg_danceability
FROM
	spotify
GROUP BY
	album
ORDER BY 2 DESC;
```

Task 7.Find the top 5 tracks with the highest energy values.
```sql
SELECT
	track,
	MAX(energy)
FROM
	spotify
GROUP by 1
ORDER by 2 DESC
LIMIT 5;
```
Task 8.List all tracks along with their views and likes where official_video = TRUE.
```sql
SELECT
	track,
	SUM(views) as total_views,
	SUM(likes) as total_likes
FROM
	spotify
WHERE
	official_video = 'true'
GROUP BY track
ORDER BY SUM(views) DESC;
```

Task 9.For each album, calculate the total views of all associated tracks.
```sql
SELECT
	album,
	track,
	SUM(views)
FROM
	spotify
GROUP BY album, track;
```

Task 10.Retrieve the track names that have been streamed on Spotify more than YouTube.
```sql
SELECT * FROM
(
SELECT
	track,
	-- most_played_on,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) as streamed_on_Youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) as streamed_on_Spotify
FROM
	spotify
GROUP by track
) as t1
WHERE streamed_on_Spotify > streamed_on_Youtube
	AND
	streamed_on_Youtube <> 0;
```

Task 11. Find the top 3 most-viewed tracks for each artist using window functions.
```sql
WITH ranking_artist
as
(
SELECT 
	artist,
	track,
	SUM(views),
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as rank
FROM
	spotify
GROUP BY
	artist, track
ORDER BY
	artist, 3 DESC
)
SELECT 
	*
FROM 
	ranking_artist
WHERE 
	rank <= 3;
```

Task 12. Write a query to find tracks where the liveness score is above the average.
```sql
SELECT
	track,
	artist,
	liveness
FROM
	spotify
WHERE
	liveness >(SELECT AVG(liveness) FROM spotify);
```

Task 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
```sql
WITH energy_difference
AS
(
SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energy
FROM 
	spotify
GROUP BY 1
)

SELECT 
	album,
	highest_energy - lowest_energy
FROM
	energy_difference
ORDER BY 2 DESC;
```

Task 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
```sql
SELECT 
	track,
	energy/liveness as energy_to_liveness
FROM
	spotify
WHERE
	energy/liveness > 1.2;
```

Task 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
```sql
WITH sum_of_likes
AS
(
SELECT 
	track,
	SUM(views) as total_views,
	SUM(likes) as total_likes
FROM
	spotify
GROUP BY track
)
SELECT * FROM sum_of_likes
ORDER BY total_views DESC;
```

Here’s an updated section for your **Spotify Advanced SQL Project and Query Optimization** README, focusing on the query optimization task you performed. You can include the specific screenshots and graphs as described.

---

## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **7 ms**
        - Planning time (P.T.): **0.17 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_before_index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX idx_artist ON spotify_tracks(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **0.153 ms**
        - Planning time (P.T.): **0.152 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN After Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_after_index.png)

- **Graphical Performance Comparison**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%203.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%202.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%201.png)

This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---

## Technology Stack
- **Database**: PostgreSQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions
- **Tools**: pgAdmin 4 (or any SQL editor), PostgreSQL (via Homebrew, Docker, or direct installation)

## How to Run the Project
1. Install PostgreSQL and pgAdmin (if not already installed).
2. Set up the database schema and tables using the provided normalization structure.
3. Insert the sample data into the respective tables.
4. Execute SQL queries to solve the listed problems.
5. Explore query optimization techniques for large datasets.

---

## Next Steps
- **Visualize the Data**: Use a data visualization tool like **Tableau** or **Power BI** to create dashboards based on the query results.
- **Expand Dataset**: Add more rows to the dataset for broader analysis and scalability testing.
- **Advanced Querying**: Dive deeper into query optimization and explore the performance of SQL queries on larger datasets.

---

## Contributing
If you would like to contribute to this project, feel free to fork the repository, submit pull requests, or raise issues.

---

## License
This project is licensed under the MIT License.
