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

-- EDA

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

-- ---------------------------
-- Project Tasks
-- ---------------------------

-- Task 1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT 
	track,
	stream
FROM
	spotify
WHERE 
	stream > 1000000000;

-- Task 2. List all albums along with their respective artists.

SELECT 
	DISTINCT album,
	artist
FROM spotify;

-- Task 3. Get the total number of comments for tracks where licensed = TRUE.

SELECT 
	SUM(comments) as total_comments
FROM 
	spotify
WHERE 
	licensed = 'TRUE';

-- Task 4. Find all tracks that belong to the album type single.

SELECT
	*
FROM
	spotify
WHERE
	album_type = 'single';

-- Task 5. Count the total number of tracks by each artist.

SELECT
	DISTINCT artist,
	COUNT(track) as total_tracks
FROM
	spotify
GROUP by artist;	

-- Task 6. Calculate the average danceability of tracks in each album.

SELECT 
	DISTINCT album,
	AVG(danceability) as avg_danceability
FROM
	spotify
GROUP BY
	album
ORDER BY 2 DESC;

-- Task 7.Find the top 5 tracks with the highest energy values.

SELECT
	track,
	MAX(energy)
FROM
	spotify
GROUP by 1
ORDER by 2 DESC
LIMIT 5;

-- Task 8.List all tracks along with their views and likes where official_video = TRUE.

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

-- Task 9.For each album, calculate the total views of all associated tracks.

SELECT
	album,
	track,
	SUM(views)
FROM
	spotify
GROUP BY album, track;

-- Task 10.Retrieve the track names that have been streamed on Spotify more than YouTube.

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
	
-- Task 11. Find the top 3 most-viewed tracks for each artist using window functions.

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

-- Task 12. Write a query to find tracks where the liveness score is above the average.

SELECT
	track,
	artist,
	liveness
FROM
	spotify
WHERE
	liveness >(SELECT AVG(liveness) FROM spotify);

-- Task 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

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
	
-- Task 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT 
	track,
	energy/liveness as energy_to_liveness
FROM
	spotify
WHERE
	energy/liveness > 1.2;

-- Task 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

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
ORDER BY total_views DESC
