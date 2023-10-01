
--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Display Table:

SELECT TOP 10
	* 
From
	Trips

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- View columns data type:

USE taxiTrip

SELECT
	COLUMN_NAME,
	DATA_TYPE
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_SCHEMA = 'dbo'
	AND TABLE_NAME = 'Trips';

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Check for missing values:

SELECT
	ID,
    MAX(trip_distance) AS MaxDistance,
    MIN(passenger_count) AS MinPassengerCount,
    AVG(fare_amount) AS AvgFareColumn,
    COUNT(VendorID) AS CountVendor
FROM 
	Trips
GROUP BY 
	ID
HAVING
	COUNT(ID) > 1;

-- No Null row
--------------------------------------------------------------------------------------------------------------------------------------------------------

														
													/* Data Analysing and Exploration */

--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Total trips:

SELECT
	COUNT(*) AS total_trips
FROM
	Trips;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Calculate the total passenger count by each vendor: */

SELECT	
	VendorID,
	COUNT(passenger_count) as passenger_count
FROM 
	Trips
GROUP BY VendorID;

---------------------------------------------------------------------------------------------------------------------------------------------------------
/* Show total trips distance: */

SELECT
	CONCAT(ROUND(SUM(trip_distance), 2), 'km') AS total_trip_distance
FROM
	Trips;

---------------------------------------------------------------------------------------------------------------------------------------------------------
/* Show average trips distance: */

SELECT
	CONCAT(ROUND(AVG(trip_distance), 2), 'km') AS avg_trip_distance
FROM
	Trips;

---------------------------------------------------------------------------------------------------------------------------------------------------------
/* Toatl trips duration */

SELECT
	CONCAT(SUM(DATEDIFF(HOUR, pickup_datetime, dropoff_datetime)), ' Hours') AS Total_trip_duration
FROM 
	Trips;

---------------------------------------------------------------------------------------------------------------------------------------------------------
/* Average trip distance */
SELECT
	CONCAT(AVG(DATEDIFF(MINUTE, pickup_datetime, dropoff_datetime)), ' Mins') AS average_trip_duration
FROM 
	Trips;

---------------------------------------------------------------------------------------------------------------------------------------------------------
/* Show trips split by the hour of the day: */

SELECT 
	DATEPART(HOUR, pickup_datetime) AS hour_of_day,
	trip_seconds,
	trip_distance
FROM
	taxiTrip.dbo.TaxiTrips
ORDER BY 
	hour_of_day;

----------------------------------------------------------------------------------------------------------------------------------------------------------
/* USing CTE to analyse the number of trips and average speed by the hour of the day to calculate the average speed: */

-- Add a new column to calculate the trip seconds between the pickup and dropover time between locations:
ALTER TABLE Trips
ADD trip_seconds INT

UPDATE Trips
SET trip_seconds = DATEDIFF(second, pickup_datetime, dropoff_datetime);

-- Select trip seconds column
SELECT
	trip_seconds
FROM
	Trips



WITH minuteofdayCTE AS
(
SELECT 
	DATEPART(HOUR, pickup_datetime) AS hour_of_day,
	trip_seconds,
	trip_distance
FROM 
	Trips
)
SELECT 
	hour_of_day,
	COUNT(1) AS num_trips,
	ROUND(1440 * SUM(trip_distance) / SUM(trip_seconds), 2) AS average_speed
FROM 
	minuteofdayCTE
GROUP BY
	hour_of_day
ORDER BY 
	hour_of_day ASC;
 
 --------------------------------------------------------------------------------------------------------------------------------------------------------
 /* Compute number of trips, total distance, average distance, minimum distance, and maximum distance for all months: */

SELECT	
	DATENAME(MONTH, pickup_datetime) AS month,
	COUNT(*) AS num_trips,
	ROUND(SUM(trip_distance), 3) AS total_distance,
	ROUND(AVG(trip_distance), 3) AS avg_distance,
	MIN(trip_distance) AS min_distance,
	MAX(trip_distance) AS max_distance
FROM 
	Trips
GROUP BY 
	DATENAME(MONTH, pickup_datetime)
ORDER BY 
	DATENAME(MONTH, pickup_datetime);

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Rank trip distance with individual rows pickup months by overall rank and month rank: */

WITH ranking AS
(
SELECT	
	ID,
	pickup_datetime,
	DATENAME(MONTH, pickup_datetime) AS month,
	trip_distance
FROM 
	Trips
)
SELECT	TOP 10
	*,
	RANK() OVER (ORDER BY trip_distance DESC) AS overall_rank,
	RANK() OVER(PARTITION BY month ORDER BY trip_distance DESC) AS month_rank
FROM 
	ranking
ORDER BY 
	overall_rank;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Analysing the previous and next distance of the trips distance by pickup date and time: */

-- With lead and lag:

SELECT 
	ID,
	pickup_datetime,
	trip_distance,
	LAG(trip_distance) OVER(ORDER BY pickup_datetime) AS prev_distance,
	LEAD(trip_distance) OVER(ORDER BY pickup_datetime) AS next_distance
FROM 
	Trips
ORDER BY 
	pickup_datetime;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Calculate the average trip duration: */

SELECT	
	ID,
	pickup_datetime,
	dropoff_datetime,
	CONCAT(AVG(DATEDIFF(MINUTE, pickup_datetime, dropoff_datetime)), ' minutes') AS average_trip_duration
FROM 
	Trips
GROUP BY
	ID,
	pickup_datetime,
	dropoff_datetime
ORDER BY 
	average_trip_duration DESC;

-- Average trip:
SELECT
	CONCAT(AVG(DATEDIFF(MINUTE, pickup_datetime, dropoff_datetime)), ' Mins') AS average_trip_duration
FROM 
	Trips;
--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Calculate the busiest hours of the day by number of trips: */

SELECT	
	DATEPART(HOUR, pickup_datetime) AS hour_of_day,
	COUNT(*) AS num_trips
FROM 
	taxiTrip.dbo.TaxiTrips
GROUP BY 
	DATEPART(HOUR, pickup_datetime)
ORDER BY 
	num_trips DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------
/*	Find the most common pickup and dropoff location:	*/

-- pickup:

SELECT	
	PULocationID, 
	COUNT(*) AS num_trips
FROM 
	Trips
GROUP BY 
	PULocationID
ORDER BY
	num_trips DESC;

-- dropoff:

SELECT	
	DOLocationID, 
	COUNT(*) AS num_trips
FROM 
	Trips
GROUP BY
	DOLocationID
ORDER BY
	num_trips DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Find the average time taken and sum of trips in minute for trips based on the day of the weeek: */

SELECT	
	DATENAME(WEEKDAY, pickup_datetime) AS day_of_week,
	AVG(DATEDIFF(MINUTE, pickup_datetime, dropoff_datetime)) AS avg_trip_duration,
	SUM(DATEDIFF(MINUTE, pickup_datetime, dropoff_datetime)) AS total_trip_duration
FROM 
	Trips
GROUP BY
	DATENAME(WEEKDAY, pickup_datetime)
ORDER BY
	total_trip_duration DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Determine the most common hour of day for dropoffs at specific location: */

SELECT	
	DOLocationID,
	DATENAME(HOUR, dropoff_datetime) AS hour_of_day,
	COUNT(*) AS num_trips
FROM 
	Trips
GROUP BY
	DOLocationID,
	DATENAME(HOUR, dropoff_datetime)
ORDER BY
	num_trips DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Find the most common payment type for trips: */

SELECT	
	COUNT(*) AS num_trips,
	payment_type
FROM 
	Trips
GROUP BY
	payment_type
ORDER BY
	payment_type;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Filter trips by the year quarters: */

SELECT 
	CASE
		WHEN MONTH(pickup_datetime) BETWEEN 1 AND 3 THEN '1st Quarter'
		WHEN MONTH(pickup_datetime) BETWEEN 4 AND 6 THEN '2nd Quarter'
		WHEN MONTH(pickup_datetime) BETWEEN 7 AND 9 THEN '3rd Quarter'
		WHEN MONTH(pickup_datetime) BETWEEN 10 AND 12 THEN '4th Quarter'
	END AS Quarters,
	SUM(passenger_count) AS num_trips
FROM 
	Trips
GROUP BY
	CASE
		WHEN MONTH(pickup_datetime) BETWEEN 1 AND 3 THEN '1st Quarter'
		WHEN MONTH(pickup_datetime) BETWEEN 4 AND 6 THEN '2nd Quarter'
		WHEN MONTH(pickup_datetime) BETWEEN 7 AND 9 THEN '3rd Quarter'
		WHEN MONTH(pickup_datetime) BETWEEN 10 AND 12 THEN '4th Quarter'
	END
ORDER BY
	Quarters;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Show total count of trips by vendor and payment type: */

SELECT	
	VendorID,
	payment_type,
	COUNT(*) AS num_trips
FROM 
	Trips
GROUP BY
	VendorID,
	payment_type
ORDER BY
	VendorID;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Show trips with the longest trip duration: */

SELECT	
	ID,
	VendorID,
	pickup_datetime,
	dropoff_datetime,
	DATEDIFF(MINUTE, pickup_datetime, dropoff_datetime) AS trip_duration_mins		
FROM 
	Trips
WHERE 
	DATEDIFF(MINUTE, pickup_datetime, dropoff_datetime) > 4
ORDER BY
	trip_duration_mins DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Determine the percentage distribution of payment types: */

SELECT
	payment_type,
	COUNT(*) AS num_trips,
	CAST(100 * COUNT(*) / 
	(
		SELECT CAST(COUNT(*) AS FLOAT) FROM taxiTrip.dbo.TaxiTrips
	) AS DECIMAL (10, 2)) AS percentage
FROM 
	Trips
GROUP BY
	payment_type;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Find the top 10 trips with the highest amount: */

SELECT	TOP 10
	VendorID,
	passenger_count,
	trip_distance,
	trip_seconds,
	RatecodeID,
	PULocationID,
	DOLocationID,
	payment_type,
	fare_amount,
	total_amount

FROM 
	Trips
ORDER BY
	total_amount DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Calculate the average tip amount per hour of day: */

SELECT	
	DATEPART(HOUR, pickup_datetime) AS hour_of_day,
	FORMAT(ROUND(AVG(tip_amount), 2), 'C', 'en-US') AS avg_tip_amount
FROM 
	Trips
GROUP BY
	DATEPART(HOUR, pickup_datetime)
ORDER BY
	avg_tip_amount DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Determine the most common time of day for pickups at specific location: */

SELECT	
	PULocationID,
	DATEPART(HOUR, pickup_datetime) AS hour_of_day,
	COUNT(*) AS num_trips
FROM 
	Trips
GROUP BY
	PULocationID,
	DATEPART(HOUR, pickup_datetime);

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Find the average fare amount by payment type: */

SELECT	
	payment_type,
	FORMAT(ROUND(AVG(fare_amount), 2), 'C', 'en-US') AS avg_fare_amount
FROM 
	Trips
GROUP BY
	payment_type;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Calculate the total passenger count by the day of the weeek: */

SELECT
	DATENAME(WEEKDAY, pickup_datetime) AS day_of_weeek,
	SUM(passenger_count) as average_passenger
FROM 
	Trips
GROUP BY 
	DATENAME(WEEKDAY, pickup_datetime);

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Extracting day of the week from the pickup date: */

SELECT	
	pickup_datetime,
	DATENAME(WEEKDAY, pickup_datetime) AS day_of_week
FROM 
	Trips;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Find the busiest the day of the weeek: */

SELECT	
	DATENAME(WEEKDAY, pickup_datetime) AS day_of_week,
	COUNT(*) AS num_trips
FROM 
	Trips
GROUP BY
	DATENAME(WEEKDAY, pickup_datetime)
ORDER BY 
	num_trips DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Find the busiest the month of the year: */

SELECT	
	DATENAME(MONTH, pickup_datetime) AS month_of_year,
	COUNT(*) AS num_trips
FROM
	Trips
GROUP BY 
	DATENAME(MONTH, pickup_datetime)
ORDER BY 
	num_trips DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Calculate the average total fare amount by each vendor including the improvement surcharge and mta tax: */

SELECT	
	DISTINCT VendorID,
	FORMAT(ROUND(AVG(fare_amount + improvement_surcharge + mta_tax), 2), 'C', 'en-US') AS average_total_fare
FROM
	Trips
GROUP BY 
	VendorID;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Analyse the relationship between improvement surcharge and fare anount: */

SELECT	
	improvement_surcharge,
	FORMAT(ROUND(AVG(fare_amount), 2), 'C', 'en-US') AS average_fare_amount
FROM 
	Trips
GROUP BY
	improvement_surcharge;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Analyse the relationship between mta tax and fare anount: */

SELECT	
	mta_tax,
	FORMAT(ROUND(AVG(fare_amount), 2), 'C', 'en-US') AS average_fare_amount
FROM 
	Trips
WHERE 
	mta_tax IS NOT NULL
GROUP BY 
	mta_tax;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Show the number of trips where tip was recieved and number of trips where there was no tip recieved: */

SELECT	
	COUNT(CASE WHEN tip_amount > 0 THEN 1 END) AS tipRecieved_trips,
	COUNT(CASE WHEN tip_amount = 0 THEN 1 END) AS noTip_trips
FROM 
	Trips;

-----------------------------------------------------------------------------------------------------------------------------------------------------------
/* Average fare and tip amount by trip distnace: */

SELECT
    trip_distance,
    FORMAT(ROUND(AVG(fare_amount), 2), 'C', 'en-US') AS avg_fare_amount,
    FORMAT(ROUND(AVG(tip_amount), 2), 'C', 'en-US') AS avg_tip_amount,
    FORMAT(ROUND(AVG(fare_amount), 2) + ROUND(AVG(tip_amount), 2), 'C', 'en-US') AS total_avg_amount
FROM
    Trips
WHERE 
    tip_amount > 0
GROUP BY 
    trip_distance
ORDER BY
    trip_distance DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------
/* Show total revenue: */

SELECT	
		FORMAT(SUM(total_amount), 'C', 'en-US') AS total_revenue
FROM 
		Trips;

--------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Months by total revenue: */

SELECT
	DATENAME(MONTH, pickup_datetime) AS month_of_year,
	FORMAT(SUM(total_amount), 'C', 'en-US') AS total_revenue
FROM 
	Trips
GROUP BY
	DATENAME(MONTH, pickup_datetime)
ORDER BY
	total_revenue DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Weekdays by total revenue: */

SELECT
	DATENAME(WEEKDAY, pickup_datetime) AS day_of_week,
	FORMAT(SUM(total_amount), 'C', 'en-US') AS total_revenue
FROM 
	Trips
GROUP BY
	DATENAME(WEEKDAY, pickup_datetime)
ORDER BY
	total_revenue DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Hours of day by total revenue: */

SELECT 
	DATEPART(HOUR, pickup_datetime) AS hour_of_day,
	ROUND(SUM(total_amount), 2) AS total_revenue
FROM 
	Trips
GROUP BY
	DATEPART(HOUR, pickup_datetime)
ORDER BY
	total_revenue DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Trips where tolls were paid: */

SELECT 
	COUNT(*)
	tolls_amount
FROM
	Trips
WHERE
	tolls_amount > 0

SELECT DISTINCT
	PULocationID,
	DOLocationID,
	tolls_amount
FROM
	Trips
WHERE
	tolls_amount > 0
ORDER BY
	tolls_amount DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Total amount of tolls paid by each vendor: */
SELECT DISTINCT
	VendorID,
	FORMAT(SUM(tolls_amount), 'C', 'en-US') tolls_paid
FROM
	Trips
GROUP BY
	VendorID;
		
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Total Extra charges paid: */

SELECT
	FORMAT(SUM(extra + tolls_amount + mta_tax + improvement_surcharge),'C', 'en-US') total_extra_charges
FROM
	Trips;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Average Extra charges paid: */

SELECT
	FORMAT(AVG(extra + tolls_amount + mta_tax + improvement_surcharge),'C', 'en-US') total_extra_charges
FROM
	Trips;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Extra charges paid by vendors: */

SELECT
	VendorID,
	FORMAT(SUM(extra + tolls_amount + mta_tax + improvement_surcharge),'C', 'en-US') total_extra_charges
FROM
	Trips
GROUP BY
	VendorID
ORDER BY
	VendorID;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Total revenue by vendors after deducting extra charges: */

SELECT
	VendorID,
	FORMAT(SUM(fare_amount + tip_amount),'C', 'en-US') total_fare_amount,
	FORMAT(SUM(extra + tolls_amount + mta_tax + improvement_surcharge),'C', 'en-US') total_extra_charges,
	FORMAT(SUM(fare_amount + tip_amount) - SUM(extra + tolls_amount + mta_tax + improvement_surcharge),'C', 'en-US') total_revenue
FROM
	Trips
GROUP BY
	VendorID
ORDER BY
	VendorID;