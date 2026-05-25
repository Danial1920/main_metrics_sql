WITH info_users AS (
SELECT time::DATE as date, COUNT(DISTINCT user_id) AS paying_users FROM user_actions
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
GROUP BY date
ORDER BY date
),
info_couriers AS (
SELECT time::DATE AS date, COUNT(DISTINCT courier_id) AS active_couriers FROM courier_actions
WHERE order_id IN (SELECT order_id FROM courier_actions WHERE action = 'deliver_order')
GROUP BY date
ORDER BY date
)
,
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
GROUP BY date),
total_couriers_users AS (
SELECT date,
SUM(new_users) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)::INTEGER AS total_users,
SUM(new_couriers) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)::INTEGER AS total_couriers
FROM subq1
ORDER BY date)

SELECT date, paying_users, active_couriers,
ROUND((paying_users::decimal / total_users)*100, 2) AS paying_users_share,
ROUND((active_couriers::decimal / total_couriers) *100, 2) AS active_couriers_share
FROM info_users JOIN info_couriers USING(date) JOIN total_couriers_users USING(date)
ORDER BY date
