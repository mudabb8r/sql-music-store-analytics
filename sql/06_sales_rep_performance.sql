-- 06 Sales support rep performance
-- Skills: JOIN across Employee -> Customer -> Invoice, RANK()
SELECT
    e.FirstName || ' ' || e.LastName                 AS sales_rep,
    COUNT(DISTINCT c.CustomerId)                     AS customers,
    COUNT(i.InvoiceId)                               AS invoices,
    ROUND(SUM(i.Total), 2)                           AS revenue,
    ROUND(AVG(i.Total), 2)                           AS avg_invoice,
    RANK() OVER (ORDER BY SUM(i.Total) DESC)         AS revenue_rank
FROM Employee AS e
JOIN Customer AS c ON c.SupportRepId = e.EmployeeId
JOIN Invoice  AS i ON i.CustomerId   = c.CustomerId
GROUP BY e.EmployeeId
ORDER BY revenue DESC;
