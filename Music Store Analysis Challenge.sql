--Q. Who is the senior most empployee based on job title?

SELECT FIRST_NAME,
	LAST_NAME,
	TITLE
FROM EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1;

--Q. Which countries have the most Invoices?

SELECT COUNT(*) AS TOTAL_INVOICES,
	BILLING_COUNTRY
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY TOTAL_INVOICES DESC;

--Q. What are top 3 values of total invoice

SELECT TOTAL
FROM INVOICE
ORDER BY TOTAL DESC
LIMIT 3;

--Q.Which city has the best customers? We would like to throw a promotional Music
--Festival in the city we made the most money. Write a query that returns one city that
--has the highest sum of invoice totals. Return both the city name & sum of all invoice
--totals

SELECT BILLING_CITY,
	SUM(TOTAL) AS SUM_INVOICES
FROM INVOICE
GROUP BY BILLING_CITY
ORDER BY SUM(TOTAL) DESC
LIMIT 1;

--Who is the best customer? The customer who has spent the most money will be
--declared the best customer. Write a query that returns the person who has spent the
--most money

SELECT I.CUSTOMER_ID,
	C.FIRST_NAME,
	C.LAST_NAME,
	SUM(I.TOTAL) AS MONEY_SPENT
FROM INVOICE I
INNER JOIN CUSTOMER C ON I.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY I.CUSTOMER_ID,
	C.FIRST_NAME,
	C.LAST_NAME
ORDER BY SUM(I.TOTAL) DESC
LIMIT 1;

--Write query to return the email, first name, last name, & Genre of all Rock Music
--listeners. Return your list ordered alphabetically by email starting with A

SELECT C.EMAIL,
	C.FIRST_NAME,
	C.LAST_NAME,
	G.NAME AS GENRE_NAME
FROM CUSTOMER C
INNER JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
INNER JOIN INVOICE_LINE IL ON I.INVOICE_ID = IL.INVOICE_ID
INNER JOIN TRACK T ON IL.TRACK_ID = T.TRACK_ID
INNER JOIN GENRE G ON T.GENRE_ID = G.GENRE_ID
WHERE G.NAME = 'Rock'
GROUP BY C.EMAIL,
	C.FIRST_NAME,
	C.LAST_NAME,
	G.NAME
ORDER BY C.EMAIL ASC;

--Let's invite the artists who have written the most rock music in our dataset. Write a
--query that returns the Artist name and total track count of the top 10 rock bands

SELECT AR.NAME AS ARTIST_NAMEORBAND,
	(COUNT(AR.ARTIST_ID)) AS TOTAL_ROCK_MUSIC
FROM ARTIST AR
INNER JOIN ALBUM AL ON AR.ARTIST_ID = AL.ALBUM_ID
INNER JOIN TRACK T ON AL.ALBUM_ID = T.ALBUM_ID
INNER JOIN GENRE G ON T.GENRE_ID = G.GENRE_ID 
WHERE G.NAME LIKE 'Rock'
GROUP BY AR.NAME
ORDER BY (COUNT(AR.ARTIST_ID)) DESC
LIMIT 10;

--Return all the track names that have a song length longer than the average song length.
--Return the Name and Milliseconds for each track. Order by the song length with the
--longest songs listed first

SELECT NAME,
	MILLISECONDS
FROM TRACK
WHERE MILLISECONDS >
		(SELECT AVG(MILLISECONDS) AS AVG_SONG_LENGTH
			FROM TRACK)
ORDER BY MILLISECONDS DESC;

--Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent
 WITH TOP_SELLING_ARTIST AS
	(SELECT ARTIST.ARTIST_ID AS ARTIST_ID,
			ARTIST.NAME AS ARTIST_NAME,
			SUM(INVOICE_LINE.UNIT_PRICE * INVOICE_LINE.QUANTITY) AS TOTAL_SALES
		FROM INVOICE_LINE
		JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
		JOIN ALBUM ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID
		JOIN ARTIST ON ARTIST.ARTIST_ID = ALBUM.ARTIST_ID
		GROUP BY 1
		ORDER BY 3 DESC
		LIMIT 1)
SELECT C.CUSTOMER_ID,
	C.FIRST_NAME,
	C.LAST_NAME,
	TA.ARTIST_NAME,
	SUM(IL.UNIT_PRICE * IL.QUANTITY) AS AMOUNT_SPENT
FROM INVOICE I
JOIN CUSTOMER C ON C.CUSTOMER_ID = I.CUSTOMER_ID
JOIN INVOICE_LINE IL ON IL.INVOICE_ID = I.INVOICE_ID
JOIN TRACK T ON T.TRACK_ID = IL.TRACK_ID
JOIN ALBUM ALB ON ALB.ALBUM_ID = T.ALBUM_ID
JOIN TOP_SELLING_ARTIST TA ON TA.ARTIST_ID = ALB.ARTIST_ID
GROUP BY 1,2,
	3,4
ORDER BY 5 DESC;

--We want to find out the most popular music Genre for each country. We determine the
--most popular genre as the genre with the highest amount of purchases. Write a query
--that returns each country along with the top Genre. For countries where the maximum
--number of purchases is shared return all Genres
 WITH POPULAR_GENRE AS
	(SELECT COUNT(IL.QUANTITY) AS PURCHASES,
			C.COUNTRY,
			G.NAME,
			G.GENRE_ID,
			ROW_NUMBER() OVER(PARTITION BY C.COUNTRY
																					ORDER BY COUNT(IL.QUANTITY) DESC) AS ROW_NO
		FROM INVOICE_LINE AS IL
		JOIN INVOICE I ON I.INVOICE_ID = IL.INVOICE_ID
		JOIN TRACK T ON T.TRACK_ID = I.INVOICE_ID
		JOIN GENRE G ON G.GENRE_ID = T.GENRE_ID
		JOIN CUSTOMER C ON C.CUSTOMER_ID = I.CUSTOMER_ID
		GROUP BY 2,3,
			4
		ORDER BY 2 ASC, 1 DESC)
SELECT *
FROM POPULAR_GENRE
WHERE ROW_NO <= 1;

--Write a query that determines the customer that has spent the most on music for each
--country. Write a query that returns the country along with the top customer and how
--much they spent. For countries where the top amount spent is shared, provide all
--customers who spent this amount
WITH CUSTOMER_WITH_COUNTRY AS
	(SELECT C.CUSTOMER_ID,
			C.FIRST_NAME,
			C.LAST_NAME,
			I.BILLING_COUNTRY,
			SUM(I.TOTAL) AS TOTAL_SPENT,
			ROW_NUMBER() OVER(PARTITION BY BILLING_COUNTRY
																					ORDER BY SUM(TOTAL) DESC) AS ROW_NO
		FROM CUSTOMER C
		JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
		GROUP BY 1,2,
			3,4
		ORDER BY 4 ASC, 5 DESC)
SELECT *
FROM CUSTOMER_WITH_COUNTRY
WHERE ROW_NO <= 1;