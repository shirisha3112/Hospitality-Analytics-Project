-- 1. Total Revenue The total income generated from all successful bookings and stays.

SELECT SUM(revenue_realized) AS total_revenue 
FROM fact_bookings 
WHERE booking_status = 'Checked Out';

-- 2. Occupancy Rate The percentage of available rooms that are occupied during a specific time period.
SELECT 
    (SUM(successful_bookings) * 100.0) / SUM(capacity) AS occupancy_rate
FROM fact_aggregated_bookings;


-- 3. Cancellation Rate The proportion of bookings that were canceled before check-in.
SELECT 
    (SUM(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS cancellation_rate 
FROM fact_bookings;


-- 4. Total Bookings The total number of reservations made, regardless of their final status.
SELECT COUNT(*) AS total_bookings 
FROM fact_bookings;

-- 5. Utilized Capacity A measure of how effectively the available room capacity is being used.
SELECT 
    SUM(successful_bookings) AS total_utilized_capacity,
    SUM(capacity) AS total_available_capacity,
    (SUM(successful_bookings) * 100.0) / SUM(capacity) AS utilized_capacity_percentage
FROM fact_aggregated_bookings;

-- 6. Trend Analysis (Weekly Revenue & Bookings Trend) Observing and evaluating how key metrics like revenue and occupancy change over time.
SELECT 
    dd.mmm_yy AS month_name,
    COUNT(fb.booking_id) AS total_bookings,
    SUM(fb.revenue_realized) AS total_revenue,
    ROUND((SUM(fab.successful_bookings) * 100.0) / SUM(fab.capacity), 2) AS occupancy_rate_percentage
FROM dim_date dd
LEFT JOIN fact_bookings fb ON STR_TO_DATE(fb.check_in_date, '%Y-%m-%d') = STR_TO_DATE(dd.date, '%d-%b-%y')
LEFT JOIN fact_aggregated_bookings fab ON fab.check_in_date = dd.date
GROUP BY dd.mmm_yy
ORDER BY STR_TO_DATE(dd.mmm_yy, '%b %y');

-- 7. Weekday & Weekend Revenue and Booking Comparison of booking volume and revenue generation between weekdays and weekends.
SELECT 
    dd.day_type, 
    COUNT(fb.booking_id) AS total_bookings, 
    SUM(fb.revenue_realized) AS total_revenue
FROM fact_bookings fb
JOIN dim_date dd ON STR_TO_DATE(fb.check_in_date, '%Y-%m-%d') = STR_TO_DATE(dd.date, '%d-%b-%y')
GROUP BY dd.day_type;

-- 8. Revenue by State & Hotel (City & Property Breakdown) Breakdown of total revenue generated, segmented by hotel location and property.
SELECT 
    dh.city, 
    dh.property_name, 
    SUM(fb.revenue_realized) AS total_revenue
FROM fact_bookings fb
JOIN dim_hotels dh ON fb.property_id = dh.property_id
WHERE fb.booking_status = 'Checked Out'
GROUP BY dh.city, dh.property_name
ORDER BY total_revenue DESC;

-- 9. Class Wise Revenue Revenue segmented by room category (e.g., Standard, Elite, Premium, Presidential).
SELECT 
    dr.room_class, 
    SUM(fb.revenue_realized) AS class_revenue
FROM fact_bookings fb
JOIN dim_rooms dr ON fb.room_category = dr.room_id
WHERE fb.booking_status = 'Checked Out'
GROUP BY dr.room_class
ORDER BY class_revenue DESC;

-- 10. Checked Out / Cancel / No Show (Status-Based Breakdown) Status-based categorization of bookings, indicating guest behavior or booking outcome.
SELECT 
    booking_status, 
    COUNT(*) AS status_count,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_bookings)) AS percentage
FROM fact_bookings
GROUP BY booking_status;

-- 11. Weekly Trend – Key Metrics (Detailed Weekly View with Occupancy) Weekly insights into key performance indicators such as revenue, bookings, and occupancy.
SELECT 
    dd.week_no,
    COUNT(fb.booking_id) AS total_bookings,
    SUM(fb.revenue_realized) AS total_revenue,
    ROUND((SUM(fab.successful_bookings) * 100.0) / SUM(fab.capacity), 2) AS occupancy_rate_percentage
FROM dim_date dd
LEFT JOIN fact_bookings fb ON STR_TO_DATE(fb.check_in_date, '%Y-%m-%d') = STR_TO_DATE(dd.date, '%d-%b-%y')
LEFT JOIN fact_aggregated_bookings fab ON fab.check_in_date = dd.date
GROUP BY dd.week_no
ORDER BY dd.week_no;