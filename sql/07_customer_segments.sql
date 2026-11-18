-- 07 Customer segmentation (simple RFM: Recency, Frequency, Monetary)
-- Skills: chained CTEs, julianday date math, NTILE() to score customers into quartiles, CASE
WITH last_date AS (
    SELECT MAX(InvoiceDate) AS max_date FROM Invoice
),
rfm AS (
    SELECT
        c.CustomerId,
        c.FirstName || ' ' || c.LastName                                       AS customer,
        c.Country                                                              AS country,
        CAST(julianday((SELECT max_date FROM last_date)) - julianday(MAX(i.InvoiceDate)) AS INT) AS days_since_last_purchase,
        COUNT(i.InvoiceId)                                                     AS purchases,
        ROUND(SUM(i.Total), 2)                                                 AS total_spent
    FROM Customer AS c
    JOIN Invoice  AS i ON i.CustomerId = c.CustomerId
    GROUP BY c.CustomerId
),
scored AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY days_since_last_purchase DESC) AS r_score,  -- 4 = most recent
        NTILE(4) OVER (ORDER BY total_spent)                   AS m_score   -- 4 = highest spend
    FROM rfm
)
SELECT
    customer, country, days_since_last_purchase, purchases, total_spent, r_score, m_score,
    CASE
        WHEN r_score >= 3 AND m_score >= 3 THEN 'Champions'
        WHEN r_score <= 2 AND m_score >= 3 THEN 'At risk (high value, not recent)'
        WHEN r_score >= 3 AND m_score <= 2 THEN 'Recent, low spend'
        ELSE 'Low engagement'
    END AS segment
FROM scored
ORDER BY total_spent DESC;
