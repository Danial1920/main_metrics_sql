WITH upd_orders AS (
SELECT creation_time::DATE AS date, order_id, unnest(product_ids) AS product_id
FROM orders
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action='cancel_order')
),
revenue_of_day AS (
SELECT date,  SUM(price) AS revenue
FROM upd_orders JOIN products USING (product_id)
GROUP BY date
ORDER BY date
),
unique_users AS (
SELECT time::date AS date,
COUNT(DISTINCT user_id) AS u_users
FROM user_actions
GROUP BY date
),
revenue_per_user AS (
SELECT date,
ROUND(revenue::decimal / u_users, 2) AS arpu
FROM unique_users JOIN revenue_of_day USING(date)
),
paying_users AS (
SELECT time::DATE AS date, user_id, COUNT(order_id)
FROM user_actions
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action='cancel_order')
GROUP BY date, user_id
HAVING COUNT(order_id) >= 1
),
paying_u_per_day AS (
SELECT date, COUNT(user_id) AS cnt_p_u
FROM paying_users
GROUP BY date
),
revenue_per_paying_users AS (
SELECT date,
ROUND(revenue::decimal / cnt_p_u, 2) AS arppu
FROM paying_u_per_day JOIN revenue_of_day USING(date)
),
total_ord AS (
SELECT time::DATE AS date,
COUNT(DISTINCT order_id) AS all_ord
FROM user_actions
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action='cancel_order')
GROUP BY date
),
average_ord_val AS (
SELECT date,
ROUND(revenue::decimal / all_ord, 2) AS aov
FROM total_ord JOIN revenue_of_day USING(date)
)
SELECT date, arpu, arppu, aov
FROM revenue_per_user JOIN revenue_per_paying_users USING(date) JOIN average_ord_val USING(date)
ORDER BY date
