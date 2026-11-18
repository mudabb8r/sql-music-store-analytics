-- 05 Revenue and share by genre
-- Skills: JOIN, aggregation, percentage of total with a window function
SELECT
    g.Name                                                                  AS genre,
    SUM(il.Quantity)                                                        AS tracks_sold,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2)                               AS revenue,
    ROUND(100.0 * SUM(il.UnitPrice * il.Quantity)
          / SUM(SUM(il.UnitPrice * il.Quantity)) OVER (), 1)                AS pct_of_revenue
FROM InvoiceLine AS il
JOIN Track AS t ON t.TrackId = il.TrackId
JOIN Genre AS g ON g.GenreId = t.GenreId
GROUP BY g.Name
ORDER BY revenue DESC;
