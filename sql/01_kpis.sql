-- 01 Headline KPIs for the whole store
-- Skills: aggregate functions, COUNT(DISTINCT)
SELECT
    ROUND(SUM(i.Total), 2)                         AS total_revenue,
    COUNT(*)                                       AS invoices,
    COUNT(DISTINCT i.CustomerId)                   AS customers,
    ROUND(AVG(i.Total), 2)                         AS avg_invoice_value,
    (SELECT SUM(Quantity) FROM InvoiceLine)        AS tracks_sold
FROM Invoice AS i;
