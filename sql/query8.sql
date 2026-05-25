WITH all_orders AS (
SELECT time::DATE AS date, COUNT(order_id) AS orders FROM user_actions
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action='cancel_order')
GROUP BY date
ORDER BY date
),
first_user_dates AS (
    SELECT
        user_id,
        MIN(time::DATE) AS first_order_date
    FROM user_actions
    WHERE order_id NOT IN (
        SELECT order_id
        FROM user_actions
        WHERE action = 'cancel_order'
    )
    GROUP BY user_id
),

first_orders1 AS (
SELECT
    first_order_date AS date,
    COUNT(user_id) AS first_orders
FROM first_user_dates
GROUP BY first_order_date
ORDER BY date)
,
first_visits AS (
    SELECT
        user_id,
        MIN(time::DATE) AS first_date
    FROM user_actions
    GROUP BY user_id
),
new_users_orders AS (
SELECT
    u.time::DATE AS date,
    COUNT(u.order_id) AS new_users_orders
FROM user_actions u
JOIN first_visits f USING(user_id)
WHERE u.order_id NOT IN (
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
)
AND u.time::DATE = f.first_date
GROUP BY u.time::DATE
ORDER BY u.time::DATE)

SELECT date, orders, first_orders, new_users_orders,
ROUND(((first_orders::decimal) / orders) * 100, 2) AS first_orders_share,
ROUND(((new_users_orders::decimal) / orders) * 100, 2) AS new_users_orders_share
FROM all_orders JOIN first_orders1  USING (date)
JOIN new_users_orders USING (date)
