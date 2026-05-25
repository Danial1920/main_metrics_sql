WITH total_users AS (
    SELECT
        time::DATE AS date,
        COUNT(DISTINCT user_id) AS dig_users
    FROM user_actions
    WHERE order_id NOT IN (
        SELECT order_id
        FROM user_actions
        WHERE action = 'cancel_order'
    )
    GROUP BY date
),
daily_user_orders AS (
    SELECT
        date,
        COUNT(user_id) AS users_one_order
    FROM (
        SELECT
            time::DATE AS date,
            user_id,
            COUNT(order_id) AS orders_per_day
        FROM user_actions
        WHERE order_id NOT IN (
            SELECT order_id
            FROM user_actions
            WHERE action = 'cancel_order'
        )
        GROUP BY date, user_id
        HAVING COUNT(order_id) = 1
    ) t1
    GROUP BY date
),

daily_user_orders1 AS (
    SELECT
        date,
        COUNT(user_id) AS users_one_order
    FROM (
        SELECT
            time::DATE AS date,
            user_id,
            COUNT(order_id) AS orders_per_day
        FROM user_actions
        WHERE order_id NOT IN (
            SELECT order_id
            FROM user_actions
            WHERE action = 'cancel_order'
        )
        GROUP BY date, user_id
        HAVING COUNT(order_id) > 1
    ) t1
    GROUP BY date
)


SELECT
    t.date,
    ROUND((COALESCE(d.users_one_order, 0)::DECIMAL / t.dig_users) * 100, 2) AS single_order_users_share,
    ROUND((COALESCE(d1.users_one_order, 0)::DECIMAL / t.dig_users) * 100, 2) AS several_orders_users_share
FROM total_users t
LEFT JOIN daily_user_orders d USING (date)
LEFT JOIN daily_user_orders1 d1 USING(date)
ORDER BY t.date;
