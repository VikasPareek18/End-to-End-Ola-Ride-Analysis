CREATE DATABASE ola_analytics
GO

USE ola_analytics
GO

CREATE TABLE rides (
	ride_id VARCHAR(15) PRIMARY KEY,
	booking_id VARCHAR(20),
	ride_datetime DATETIME,
	day_of_week VARCHAR(10),
	hour INT,
	booking_status VARCHAR(20),
	customer_id VARCHAR(20),
	vehicle_type VARCHAR(30),
	pickup_location VARCHAR(20),
	drop_location VARCHAR(20),
	pickup_zone VARCHAR(10),
	drop_zone VARCHAR(10),
	avg_vtat FLOAT,
	avg_ctat FLOAT,
	cancelled_by_customer INT,
	reason_cancel_customer VARCHAR(100),
	cancelled_by_driver INT,
	reason_cancel_driver VARCHAR(100),
	incomplete_rides INT,
	incomplete_reason VARCHAR(100),
	booking_value FLOAT,
	payment_method VARCHAR(30),
	ride_distance FLOAT,
	driver_ratings FLOAT,
	customer_rating FLOAT,
	is_completed BIT,
);
GO
