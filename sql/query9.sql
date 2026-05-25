WITH all_orders AS (
SELECT DATE_PART('hour', creation_time) AS hour, COUNT(DISTINCT order_id) AS successful_orders FROM orders
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action='cancel_order')
GROUP BY hour
),
cancel_orders AS (
SELECT DATE_PART('hour', creation_time) AS hour, COUNT(DISTINCT order_id) AS canceled_orders FROM orders
WHERE order_id IN (SELECT order_id FROM user_actions WHERE action='cancel_order')
GROUP BY hour
),
total_orders AS (
SELECT DATE_PART('hour', creation_time) AS hour, COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY hour
)

SELECT all_orders.hour::integer, successful_orders, canceled_orders,
ROUND((canceled_orders::decimal / total_orders), 3) AS cancel_rate
FROM all_orders JOIN cancel_orders USING(hour) JOIN total_orders USING(hour)
ORDER BY all_orders.hour
