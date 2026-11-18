-- 08 Top 10 artists by revenue
-- Skills: JOIN chain Artist -> Album -> Track -> InvoiceLine, LIMIT
SELECT
    ar.Name                                     AS artist,
    COUNT(DISTINCT al.AlbumId)                  AS albums_sold_from,
    SUM(il.Quantity)                            AS tracks_sold,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2)   AS revenue
FROM InvoiceLine AS il
JOIN Track  AS t  ON t.TrackId  = il.TrackId
JOIN Album  AS al ON al.AlbumId = t.AlbumId
JOIN Artist AS ar ON ar.ArtistId = al.ArtistId
GROUP BY ar.ArtistId
ORDER BY revenue DESC
LIMIT 10;
