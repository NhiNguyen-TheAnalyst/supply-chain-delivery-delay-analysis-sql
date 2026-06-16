--Dashboard Export Queries
--Supply Chain Delivery Delay Analysis

--Each query below produces one aggregated table used as a data source for the Tableau dashboard. I run each query individually, then export the result into its own sheet in Excel before connecting to Tableau.

-- Sheet 1,2: delivery_outcomes
-- Feeds: The delay card, Outcome breakdown chart
SELECT 
    label,
    CASE 
        WHEN label = -1 THEN 'Early'
        WHEN label = 0  THEN 'On Time'
        WHEN label = 1  THEN 'Delayed'
    END AS delivery_outcome,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM PortfolioProject..DeliveryData
GROUP BY label
ORDER BY label;

-- Sheet 3: delay_by_shipping_mode
-- Feeds: Delay rate by shipping mode chart (hero chart)
SELECT 
    shipping_mode,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) AS delayed_orders,
    SUM(CASE WHEN label = 0 THEN 1 ELSE 0 END) AS ontime_orders,
    SUM(CASE WHEN label = -1 THEN 1 ELSE 0 END) AS early_orders,
    ROUND(SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct
FROM PortfolioProject..DeliveryData
GROUP BY shipping_mode
ORDER BY delay_rate_pct DESC;

-- Sheet 4: delay_by_shipping_and_market
-- Feeds: Heatmap chart (shipping mode x market)
SELECT 
    shipping_mode,
    market,
    COUNT(*) AS total_orders,
    ROUND(SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct
FROM PortfolioProject..DeliveryData
GROUP BY shipping_mode, market
ORDER BY delay_rate_pct DESC;

-- Sheet 5: delay_by_year
-- Feeds: Delay trend line chart
SELECT 
    YEAR(order_date) AS order_year,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) AS delayed_orders,
    SUM(CASE WHEN label = 0 THEN 1 ELSE 0 END) AS ontime_orders,
    SUM(CASE WHEN label = -1 THEN 1 ELSE 0 END) AS early_orders,
    ROUND(SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct
FROM PortfolioProject..DeliveryData
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- Sheet 6: delay_by_category
-- Feeds: Top 10 categories by delay rate chartSELECT TOP 10
SELECT TOP 10
    category_name, 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct
FROM PortfolioProject..DeliveryData
GROUP BY category_name
ORDER BY delay_rate_pct DESC;
