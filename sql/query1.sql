WITH
min_date_per_users AS(
SELECT user_id AS new_users, MIN(time::DATE) AS f_u_date
FROM user_actions
GROUP BY user_id
ORDER BY user_id
),
min_date_per_courier AS (
SELECT courier_id AS new_couriers  , MIN(time::DATE) AS f_c_date
FROM courier_actions
GROUP BY courier_id
ORDER BY courier_id
),
subq1 AS (
SELECT f_u_date AS date, COUNT(DISTINCT new_users) AS new_users, COUNT(DISTINCT new_couriers) AS new_couriers
FROM min_date_per_users JOIN min_date_per_courier ON min_date_per_users.f_u_date = min_date_per_courier.f_c_date
GROUP BY date)

SELECT date, new_users, new_couriers ,
SUM(new_users) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)::INTEGER AS total_users,
SUM(new_couriers) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)::INTEGER AS total_couriers
FROM subq1
ORDER BY date
