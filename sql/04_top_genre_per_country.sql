-- 04 Best-selling genre in each country (ties broken by revenue)
-- Skills: multi-table JOIN (5 tables), CTE, ROW_NUMBER() OVER (PARTITION BY ...)
WITH genre_sales AS (
    SELECT
        c.Country                                   AS country,
        g.Name                                      AS genre,
        SUM(il.Quantity)                            AS tracks_sold,
        ROUND(SUM(il.UnitPrice * il.Quantity), 2)   AS revenue
    FROM InvoiceLine AS il
    JOIN Invoice     AS i ON i.InvoiceId  = il.InvoiceId
    JOIN Customer    AS c ON c.CustomerId = i.CustomerId
    JOIN Track       AS t ON t.TrackId    = il.TrackId
    JOIN Genre       AS g ON g.GenreId    = t.GenreId
    GROUP BY c.Country, g.Name
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY country ORDER BY tracks_sold DESC, revenue DESC) AS rank_in_country
    FROM genre_sales
)
SELECT country, genre, tracks_sold, revenue
FROM ranked
WHERE rank_in_country = 1
ORDER BY tracks_sold DESC;
