-- 03 Revenue by customer country, with each country's share of the total
-- Skills: JOIN, GROUP BY, window over the whole result (SUM() OVER ())
SELECT
    c.Country                                                   AS country,
    COUNT(DISTINCT c.CustomerId)                                AS customers,
    ROUND(SUM(i.Total), 2)                                      AS revenue,
    ROUND(SUM(i.Total) / COUNT(DISTINCT c.CustomerId), 2)       AS revenue_per_customer,
    ROUND(100.0 * SUM(i.Total) / SUM(SUM(i.Total)) OVER (), 1)  AS pct_of_total
FROM Invoice  AS i
JOIN Customer AS c ON c.CustomerId = i.CustomerId
GROUP BY c.Country
ORDER BY revenue DESC;
