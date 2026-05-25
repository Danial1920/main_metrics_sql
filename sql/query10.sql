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
total_revenue_of_day AS (
SELECT date,
SUM(revenue) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_revenue
FROM revenue_of_day
),
change_of_day AS (
SELECT date,
ROUND(((revenue - LAG(revenue, 1) OVER(ORDER BY date))::decimal / LAG(revenue, 1) OVER())*100, 2) AS revenue_change
FROM revenue_of_day
)

SELECT date, revenue, total_revenue, revenue_change
FROM revenue_of_day JOIN total_revenue_of_day USING(date)
JOIN change_of_day USING(date)
ORDER BY date
