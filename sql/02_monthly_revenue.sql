-- 02 Monthly revenue with running total and month-over-month change
-- Skills: CTE, date functions, window functions (SUM OVER, LAG)
WITH monthly AS (
    SELECT
        strftime('%Y-%m', InvoiceDate) AS month,
        ROUND(SUM(Total), 2)           AS revenue,
        COUNT(*)                       AS invoices
    FROM Invoice
    GROUP BY month
)
SELECT
    month,
    revenue,
    invoices,
    ROUND(SUM(revenue) OVER (ORDER BY month), 2)                        AS running_total,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2)              AS change_vs_prev_month,
    ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_3m_avg
FROM monthly
ORDER BY month;
