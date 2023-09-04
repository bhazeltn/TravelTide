// What Columns have Null other than sessions.trip_id

SELECT
    SUM(CASE WHEN session_id IS NULL THEN 1 ELSE 0 END) AS session_id_nulls,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS user_id_nulls,
    SUM(CASE WHEN session_start IS NULL THEN 1 ELSE 0 END) AS session_start_nulls,
    SUM(CASE WHEN session_end IS NULL THEN 1 ELSE 0 END) AS session_end_nulls,
    SUM(CASE WHEN flight_discount IS NULL THEN 1 ELSE 0 END) AS flight_discount_nulls,
    SUM(CASE WHEN hotel_discount IS NULL THEN 1 ELSE 0 END) AS hotel_discount_nulls,
    SUM(CASE WHEN flight_discount_amount IS NULL THEN 1 ELSE 0 END) AS flight_discount_amount_nulls,
    SUM(CASE WHEN hotel_discount_amount IS NULL THEN 1 ELSE 0 END) AS hotel_discount_amount_nulls,
    SUM(CASE WHEN flight_booked IS NULL THEN 1 ELSE 0 END) AS flight_booked_nulls,
    SUM(CASE WHEN hotel_booked IS NULL THEN 1 ELSE 0 END) AS hotel_booked_nulls,
    SUM(CASE WHEN page_clicks IS NULL THEN 1 ELSE 0 END) AS page_clicks_nulls,
    SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END) AS cancellation_nulls
FROM sessions


// How many page_clicks are there on average across all browsing sessions?

SELECT ROUND(AVG(page_clicks)) AS avg_page_clicks
FROM sessions

// Shortest Browsing session that resulted in a booking

SELECT MIN(session_end - session_start) AS shortest_session_time
FROM sessions
WHERE flight_booked = True OR hotel_booked = True

// Verify the query for the cohort definiton

SELECT user_id, COUNT(session_id) AS session_count
FROM sessions
WHERE session_start > '2023-01-04'
GROUP BY user_id
HAVING COUNT(session_id) > 7;

// Aggregate data by user_id

WITH CohortUsers AS (
    SELECT user_id
    FROM sessions
    WHERE session_start > '2023-01-04'
    GROUP BY user_id
    HAVING COUNT(session_id) > 7
)

SELECT 
    s.user_id,
    COUNT(DISTINCT s.session_id) AS total_sessions,
    SUM(CASE WHEN s.flight_booked = TRUE THEN 1 ELSE 0 END) AS total_flights_booked,
    SUM(CASE WHEN s.hotel_booked = TRUE THEN 1 ELSE 0 END) AS total_hotels_booked,
    AVG(s.page_clicks) AS avg_page_clicks,
    SUM(CASE WHEN s.cancellation = TRUE THEN 1 ELSE 0 END) AS total_cancellations,
    AVG(s.flight_discount_amount) AS avg_flight_discount,
    AVG(s.hotel_discount_amount) AS avg_hotel_discount
FROM sessions s
JOIN CohortUsers cu ON s.user_id = cu.user_id
WHERE s.session_start > '2023-01-04'
GROUP BY s.user_id;