-- 1. Weekly Sales Patterns (Dec 2018 – Mar 2019)
-- Insight: Weekly sales fluctuated between $17,000 and $29,000, peaking mid-Jan and late-Feb, with a downward trend in March.
SELECT 
    DATE_TRUNC('week', transaction_date) AS week_start,
    SUM(total_amount) AS weekly_sales
FROM sales_transactions
GROUP BY week_start
ORDER BY week_start;

-- 2. Average Sales Per Transaction by Weekday
-- Insight: Average sales per transaction are highest on Saturdays and Sundays, exceeding $340; weekdays are around $300–$330.
SELECT 
    TRIM(TO_CHAR(transaction_date, 'Day')) AS weekday_name,
    AVG(total_amount) AS avg_sales_per_transaction
FROM sales_transactions
GROUP BY weekday_name
ORDER BY 
    CASE TRIM(TO_CHAR(transaction_date, 'Day'))
        WHEN 'Sunday' THEN 0
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
    END;

-- 3. Weekly Sales by City
-- Insight: Yangon consistently led in weekly sales, followed by Mandalay and Naypyitaw; city ranking remained stable.
SELECT 
    DATE_TRUNC('week', st.transaction_date) AS week_start,
    ci.city_name,
    SUM(st.total_amount) AS weekly_sales
FROM sales_transactions st
JOIN stores s ON st.store_id = s.store_id
JOIN cities ci ON s.city_id = ci.city_id
GROUP BY week_start, ci.city_name
ORDER BY week_start, ci.city_name;

-- 4. Transaction Count by Spending Range and City
-- Insight: $100–$300 range had the highest number of transactions; Yangon dominated, Naypyitaw relatively stronger in >$500.
SELECT 
    ci.city_name,
    CASE 
        WHEN st.total_amount < 100 THEN '< $100'
        WHEN st.total_amount BETWEEN 100 AND 300 THEN '$100–$300'
        WHEN st.total_amount BETWEEN 300 AND 500 THEN '$300–$500'
        ELSE '> $500'
    END AS spending_range,
    COUNT(*) AS transaction_count
FROM sales_transactions st
JOIN stores s ON st.store_id = s.store_id
JOIN cities ci ON s.city_id = ci.city_id
GROUP BY ci.city_name, spending_range
ORDER BY ci.city_name, spending_range;

-- 5. Total Sales by Spending Range and City
-- Insight: >$500 transactions drove the most revenue; Yangon dominated all ranges, followed by Mandalay and Naypyitaw.
SELECT 
    ci.city_name,
    CASE 
        WHEN st.total_amount < 100 THEN '< $100'
        WHEN st.total_amount BETWEEN 100 AND 300 THEN '$100–$300'
        WHEN st.total_amount BETWEEN 300 AND 500 THEN '$300–$500'
        ELSE '> $500'
    END AS spending_range,
    SUM(st.total_amount) AS total_sales
FROM sales_transactions st
JOIN stores s ON st.store_id = s.store_id
JOIN cities ci ON s.city_id = ci.city_id
GROUP BY ci.city_name, spending_range
ORDER BY ci.city_name, spending_range;

-- 6. Total Sales by Product Line
-- Insight: Electronic accessories led with $82,680 in sales; fashion accessories had the lowest.
SELECT 
    pl.product_line_name,
    ROUND(SUM(si.unit_price * si.quantity)::numeric, 2) AS total_sales
FROM sales_items si
JOIN products p ON si.product_id = p.product_id
JOIN product_lines pl ON p.product_line_id = pl.product_line_id
GROUP BY pl.product_line_name
ORDER BY total_sales DESC;

-- 7. Total Quantity Sold by Product Line
-- Insight: Electronic accessories had the highest units sold (1,516); fashion accessories the lowest.
SELECT 
    pl.product_line_name,
    SUM(si.quantity) AS total_quantity
FROM sales_items si
JOIN products p ON si.product_id = p.product_id
JOIN product_lines pl ON p.product_line_id = pl.product_line_id
GROUP BY pl.product_line_name
ORDER BY total_quantity DESC;

-- 8. Total Sales by Customer Type (Members vs. Normal)
-- Insight: Members contributed more than double the sales of normal customers.
SELECT 
    c.customer_type,
    ROUND(SUM(st.total_amount)::numeric, 2) AS total_sales
FROM sales_transactions st
JOIN customers c ON st.customer_id = c.customer_id
GROUP BY c.customer_type;

-- 9. Week over Week Sales Growth
-- Insight: W08–W09 saw major sales growth; Food and Beverages grew 277%.
WITH weekly_sales AS (
    SELECT 
        c.year,
        EXTRACT(WEEK FROM c.transaction_date)::INT AS week,
        SUM(st.total_amount) AS total_sales
    FROM sales_transactions st
    JOIN calendar c ON st.transaction_date = c.transaction_date
    GROUP BY c.year, EXTRACT(WEEK FROM c.transaction_date)
),
sales_with_lag AS (
    SELECT 
        year,
        week,
        total_sales,
        LAG(total_sales) OVER (ORDER BY year, week) AS prev_week_sales
    FROM weekly_sales
)
SELECT 
    year,
    week,
    'W' || LPAD(week::TEXT, 2, '0') AS week_label,
    total_sales,
    prev_week_sales,
    ROUND(
        CASE 
            WHEN prev_week_sales IS NULL THEN NULL
            WHEN prev_week_sales = 0 THEN NULL
            ELSE ((total_sales - prev_week_sales) / prev_week_sales * 100)::numeric
        END, 
    2
    ) AS wow_growth_percent
FROM sales_with_lag
ORDER BY year, week;

-- 10. Relation between Ratings & Spending
-- Insight: Higher transaction sales are slightly associated with higher ratings.
SELECT 
    st.invoice_id,
    st.total_amount,
    f.rating,
    ci.city_name,
    cu.customer_type,
    pm.payment_method,
    pl.product_line_name
FROM sales_transactions st
JOIN financials f ON st.invoice_id = f.invoice_id
JOIN stores s ON st.store_id = s.store_id
JOIN cities ci ON s.city_id = ci.city_id
JOIN customers cu ON st.customer_id = cu.customer_id
JOIN payments pm ON st.payment_method = pm.payment_id
JOIN (
    SELECT DISTINCT 
        si.invoice_id, 
        p.product_line_id
    FROM sales_items si
    JOIN products p ON si.product_id = p.product_id
) fp ON st.invoice_id = fp.invoice_id
JOIN product_lines pl ON fp.product_line_id = pl.product_line_id
WHERE f.rating IS NOT NULL
ORDER BY st.total_amount;

-- 11. Spending Patterns across Weekdays
-- Insight: Member customers spend steadily; normal customers spend more on weekends.
SELECT 
    ci.city_name,
    cu.customer_type,
    c.weekday,
    ROUND(AVG(st.total_amount)::numeric, 2) AS avg_sales_per_transaction
FROM sales_transactions st
JOIN customers cu ON st.customer_id = cu.customer_id
JOIN stores s ON st.store_id = s.store_id
JOIN cities ci ON s.city_id = ci.city_id
JOIN calendar c ON st.transaction_date = c.transaction_date
GROUP BY ci.city_name, cu.customer_type, c.weekday
ORDER BY 
    ci.city_name,
    cu.customer_type,
    CASE c.weekday
        WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
    END;

-- 12. Ratings by Product Line
-- Insight: Health & Beauty holds the highest and improving ratings; Sports & Travel has the lowest and declining.
SELECT 
    ci.city_name,
    pl.product_line_name,
    'W' || LPAD(EXTRACT(WEEK FROM st.transaction_date)::TEXT, 2, '0') AS week,
    c.customer_type,
    ROUND(AVG(f.rating)::numeric, 2) AS avg_rating
FROM financials f
JOIN sales_transactions st ON f.invoice_id = st.invoice_id
JOIN customers c ON st.customer_id = c.customer_id
JOIN stores s ON st.store_id = s.store_id
JOIN cities ci ON s.city_id = ci.city_id
JOIN sales_items si ON st.invoice_id = si.invoice_id
JOIN products p ON si.product_id = p.product_id
JOIN product_lines pl ON p.product_line_id = pl.product_line_id
GROUP BY ci.city_name, pl.product_line_name, week, c.customer_type
ORDER BY week, ci.city_name, pl.product_line_name, c.customer_type;


