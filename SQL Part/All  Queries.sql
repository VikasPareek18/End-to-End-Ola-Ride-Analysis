select 
pickup_zone,
round(sum(booking_value), 2) as total_revenue
from rides
where booking_status = 'Success'
group by pickup_zone
order by total_revenue desc

select
vehicle_type,
round(avg(booking_value), 2) as avg_value
from rides
where booking_status = 'Success'
group by vehicle_type
order by avg_value desc

select top 3
pickup_zone,
round(sum(booking_value), 2) as total_revenue
from rides
where booking_status = 'Success'
group by pickup_zone
order by total_revenue desc

select
day_of_week,
round(sum(booking_value), 2) as total_revenue
from rides
where booking_status = 'Success'
group by day_of_week
order by case day_of_week
	when 'Monday' then 1
	when 'Tuesday' then 2
	when 'Wednesday' then 3
	when 'Thursday' then 4
	when 'Friday' then 5
	when 'Saturday' then 6
	when 'Sunday' then 7
	end

select
hour,
round(sum(booking_value), 2) as total_revenue_per_hour
from rides
where booking_status = 'Success'
group by hour
order by hour asc

select
pickup_zone,
round(cast(avg(case
	when is_completed = 0 then 1.0
	else 0.0 end) as FLOAT) * 100, 2) as cancellation_ratio
from rides
group by pickup_zone

SELECT
    pickup_zone,
    ROUND(AVG(CASE WHEN booking_status IN ('Cancelled by Customer', 'Cancelled by Driver') THEN 1.0 
	ELSE 0.0 END) * 100, 2) AS true_cancellation_rate_pct
FROM rides
GROUP BY pickup_zone
ORDER BY true_cancellation_rate_pct DESC;


select
reason_cancel_customer,
count(*) as total_count
from rides
where booking_status = 'Cancelled by Customer'
group by reason_cancel_customer
order by total_count desc

select
reason_cancel_driver,
count(*) as total_count
from rides
where booking_status = 'Cancelled by Driver'
group by reason_cancel_driver
order by total_count desc

select
customer_id,
count(*) number_of_rides
from rides
group by customer_id
having count(*) >= 2
order by count(*) desc

with cte_classify as (
	select
	customer_id,
	count(*) as number_of_rides
	from rides
	group by customer_id )
select
avg(case	
	when number_of_rides = 1 then 0.0
	else 1.0 end) * 100 as customer_repeat_percentage
from cte_classify

select top 10
customer_id,
round(sum(booking_value), 2) as total_spend_by_customer
from rides
where is_completed = 1
group by customer_id
order by total_spend_by_customer desc


select
pickup_zone,
round(avg(customer_rating), 2) as avg_rating
from rides
group by pickup_zone
order by avg_rating

select
pickup_zone,
round(avg(driver_ratings), 2) as avg_driver_ratings
from rides
group by pickup_zone
order by avg_driver_ratings desc

select
pickup_zone,
round(avg(avg_vtat), 2) as avg_vtat_ratings
from rides
group by pickup_zone
order by avg_vtat_ratings desc

select
pickup_zone,
avg(case
	when booking_status = 'Incomplete' then 1.0
	else 0.0 end) * 100 as incomplete_rate
from rides
group by pickup_zone
order by incomplete_rate desc


select
cast(ride_datetime as DATE) as ride_date,
count(*) as cnt
from rides
group by cast(ride_datetime as DATE)
order by ride_date asc

with cte_classifyday as (
	select
	day_of_week,
	booking_value,
	case
		when day_of_week in ('Saturday', 'Sunday') then 'Weekend'
		else 'Weekday' end as classify_day
	from rides)
select
classify_day,
round(avg(booking_value), 2) as avg_booking_value
from cte_classifyday
group by classify_day
order by avg_booking_value desc

with cte_count as (
select
pickup_zone,
hour,
count(*) as ride_count
from rides
group by pickup_zone, hour),
cte2 as (
select
*,
row_number() over(partition by pickup_zone order by ride_count desc) as rnk
from cte_count)
select 
pickup_zone,
hour,
ride_count
from cte2
where rnk = 1


with cte_daily as (
	select
	cast(ride_datetime as date) as ride_date,
	sum(booking_value) as daily_revenue
	from rides
	where is_completed = 1
	group by cast(ride_datetime as date))
select
ride_date,
daily_revenue,
round(sum(daily_revenue) over (order by ride_date), 2) as running_total_revenue
from cte_daily
order by ride_date

with cte_daily as (
	select
	cast(ride_datetime as date) as ride_date,
	sum(booking_value) as daily_revenue
	from rides
	where is_completed = 1
	group by cast(ride_datetime as date))
select
ride_date,
daily_revenue,
lag(daily_revenue, 1) over(order by ride_date) as lag1,
coalesce((daily_revenue - lag(daily_revenue, 1) over(order by ride_date))/(lag(daily_revenue, 1) over(order by ride_date)), 0) * 100 as change_percentage
from cte_daily

with cte_rank as (
select
pickup_zone,
sum(booking_value) as total_revenue
from rides
where is_completed = 1
group by pickup_zone)
select
pickup_zone,
dense_rank() over(order by total_revenue desc) as dnk,
rank() over(order by total_revenue desc) as rnk
from cte_rank

select
customer_id,
min(ride_datetime) as first_ride,
max(ride_datetime) as lst_ride,
datediff(day, min(ride_datetime), max(ride_datetime)) as days_between
from rides
group by customer_id
order by days_between desc


with cte_zone_revenue as (
select
pickup_zone,
sum(booking_value) as zone_revenue
from rides
where is_completed = 1
group by pickup_zone)
select
pickup_zone,
zone_revenue,
round(zone_revenue * 100 / sum(zone_revenue) over(), 2) as pct_of_total_revenue
from cte_zone_revenue
order by pct_of_total_revenue desc

select distinct
pickup_zone,
round(percentile_cont(0.5) within group (order by booking_value) over(partition by pickup_zone), 2) as median_booking_value
from rides
where is_completed = 1
order by pickup_zone


SELECT
    customer_id,
    COUNT(*) AS distinct_vehicle_types,
    STRING_AGG(vehicle_type, ', ') AS vehicle_types_used
FROM
(
    SELECT DISTINCT customer_id, vehicle_type
    FROM rides
) AS t
GROUP BY customer_id
HAVING COUNT(*) > 2;


with cte_rides as (select
cast(ride_datetime as date) as ride_date,
count(*) as total_rides
from rides
group by cast(ride_datetime as date))
select
ride_date,
total_rides,
avg(total_rides) over(order by ride_date rows between 2 preceding and current row) as rolling_avg
from cte_rides

select
payment_method,
count(*) as ride_counts,
round(sum(booking_value), 2) as total_revenue
from rides
where is_completed = 1
group by payment_method
order by ride_counts desc

with cte_count as (
select
pickup_zone,
hour,
count(*) as ride_count
from rides
group by pickup_zone, hour ),
cte_rank as (
select
pickup_zone,
hour,
ride_count,
row_number() over(partition by pickup_zone order by ride_count asc) as rn
from cte_count)
select pickup_zone, hour, ride_count
from cte_rank
where rn = 1
order by pickup_zone