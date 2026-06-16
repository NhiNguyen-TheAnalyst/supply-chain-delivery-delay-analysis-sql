-- Data audit
-- Check for nulls in critical columns
SELECT 
	SUM(CASE WHEN label is null then 1 else 0 end) as null_labels,
	SUM(CASE WHEN shipping_mode is null then 1 else 0 end) as null_shipping,
	SUM(CASE WHEN market is null then 1 else 0 end) as null_market
FROM PortfolioProject..DeliveryData;

-- Check for duplicate
SELECT order_item_id, COUNT(*) AS count
FROM PortfolioProject..DeliveryData
GROUP BY order_item_id
HAVING COUNT(*)>1;

-- There are duplicate order_item_id, now it is essential to check whether the duplicate rows are identical, or they have different values
SELECT 
    order_item_id,
    order_id,
    product_name,
    shipping_mode,
    label,
    COUNT(*) AS count
FROM PortfolioProject..DeliveryData
GROUP BY order_item_id, order_id, product_name, shipping_mode, label
HAVING COUNT(*) > 1;

-- Data analysis
-- Breakdown of breakdown of delivery outcomes
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
-- Finding: 19.47% on time and 22.8% early, 58% of all orders in this dataset experienced delivery delays — meaning more than half of customers did not receive their orders on time. This is not an edge case, it is the norm.

-- Breakdown of orders distributed across shipping modes
SELECT 
    shipping_mode,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM PortfolioProject..DeliveryData
GROUP BY shipping_mode
ORDER BY total_orders DESC;
-- Finding: Standard Class: 58.63%, 2nd Class: 21.11%, 1st Class: 15.3%, Same Day: 4.8% - a typical distribution with budget-friendliest options being most popular and least cost saving at the bottom

-- Breakdown of orders distributed across markets
SELECT 
    market,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM PortfolioProject..DeliveryData
GROUP BY market
ORDER BY total_orders DESC;
-- Finding: Top 3 markets are EU (29.44%), LATAM (28.39%), Pacific Asia (22.63%), the bottom are USCA (13.67%) and Africa (5.88%)

-- Top 10 product categories by order volume
SELECT 
    TOP 10
    category_name,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM PortfolioProject..DeliveryData
GROUP BY category_name
ORDER BY total_orders DESC;
-- Finding: Top 3 are cleats, men's footwear and women's apparel taking up to nearly 40% - easy to deliver. The next 7 categories are either sports/ indoor, outdoor activities related or electronics - not portable, difficult to fulfill

-- Breakdown of customer segments
SELECT 
    customer_segment,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM PortfolioProject..DeliveryData
GROUP BY customer_segment
ORDER BY total_orders DESC;
-- Finding: Cosumer accounts for more than half customer pool (53.59%), then comes Corporate 29.6% and home office 16.81%

-- Order volume by year
SELECT 
    YEAR(order_date) AS order_year,
    COUNT(*) AS total_orders
FROM PortfolioProject..DeliveryData
GROUP BY YEAR(order_date)
ORDER BY order_year;
-- Finding: Order volume declined steadily over years, most significant drop occured in 2018 (4662 to only 166 orders, a decrease of 96%)

-- Order volume by order status
SELECT 
    order_status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM PortfolioProject..DeliveryData
GROUP BY order_status
ORDER BY total_orders DESC;
-- Finding: 24.6% orders are pending payment, near 30% orders are poorly managed (pending, closed, on hold and payment review) - meaning more than half share of total orders are in trouble

-- Delay rate by order status
SELECT 
    order_status,
    COUNT(*) AS total_orders,
    ROUND(SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct
FROM PortfolioProject..DeliveryData
GROUP BY order_status
ORDER BY delay_rate_pct DESC;
-- Finding: Despite order status differences, delay rate remains in 51% to 59%

-- Delay rate by shipping mode
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
-- Finding: All shippping mode sees a significant delay rate, most noticable is 1st class with 98%, 2nd class with 77%, same day and standard class are 53% and 41% in turn. This means either the shipping mode itself is the problem or 1st and 2nd class are chosen for orders that are already difficult to fulfill

-- Delay rate by market
SELECT 
    market,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct
FROM PortfolioProject..DeliveryData
GROUP BY market
ORDER BY delay_rate_pct DESC;
-- Finding: All markets share a similar delay rate between 57% and 59%, so market is not driving delay rate

-- Delay rate by shipping mode and market
SELECT 
    shipping_mode,
    market,
    COUNT(*) AS total_orders,
    ROUND(SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct
FROM PortfolioProject..DeliveryData
GROUP BY shipping_mode, market
ORDER BY delay_rate_pct DESC;
-- Finding: Shipping mode is definitely a major factor causing a delay regarless of market as it show similar trends with table of delay rate by shipping mode

-- Delay rate by customer segment
SELECT 
    customer_segment,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct
FROM PortfolioProject..DeliveryData
GROUP BY customer_segment
ORDER BY delay_rate_pct DESC;
--Finding: there is a similar rate across segments (57% to 58%), customer segment is not a driver factor

-- Delay rate by product category (top 10 worst)
SELECT TOP 10
    category_name, 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct
FROM PortfolioProject..DeliveryData
GROUP BY category_name
ORDER BY delay_rate_pct DESC;
-- Finding: Delay rate are highest among Strength Training which is indeed hard to fulfill, however the others are sports shoes and goods, toys, pet supplies - posing a question to why rate is still high even though these items are light, portable. The reason may lie in delivery agent's capability and poor structure of shipping operation (business itself needs to optimize SOP)

-- Delay rate by product category and shipping mode
SELECT 
    category_name, shipping_mode,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct
FROM PortfolioProject..DeliveryData
GROUP BY category_name, shipping_mode
ORDER BY delay_rate_pct DESC;
-- Finding: 1st class and 2nd class are dominant in the delay rate range from 66% to 100% - shipping mode is driving the delay rate

-- Delay rate change year over year
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
-- Finding: Delay rate does not change much over years, often in the range of 57% to 58%, 2018 is the year of highest delay rate with 60%. 2018 data appears incomplete with only 166 orders recorded, suggesting the dataset was cut off in mid 2018. Year-over-year trend analysis is therefore limited to 2015–2017.

--Delay rate by payment type
SELECT 
    payment_type,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(SUM(CASE WHEN label = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct
FROM PortfolioProject..DeliveryData
GROUP BY payment_type
ORDER BY delay_rate_pct DESC;
-- There is not much of a difference in delay rate across payment types

--Average profit per order by delivery outcome
SELECT 
    CASE 
        WHEN label = -1 THEN 'Early'
        WHEN label = 0  THEN 'On Time'
        WHEN label = 1  THEN 'Delayed'
    END AS delivery_outcome,
    COUNT(*) AS total_orders,
    ROUND(AVG(TRY_CAST(order_profit_per_order AS FLOAT)), 2) AS avg_profit,
    ROUND(AVG(TRY_CAST(order_item_discount_rate AS FLOAT)), 4) AS avg_discount_rate
FROM PortfolioProject..DeliveryData
GROUP BY label
ORDER BY label;
-- Finding: Regardless of delivery outcome, avg profit of total orders is between 21 and 24 while avg discount rate is 0.1

-- RECOMMENDATION:
-- Urgently audit First Class and Second Class shipping operations: With 98% and 77% delay rates respectively, these modes are systematically failing customers choosing these modes are paying a premium expecting faster, more reliable delivery, yet are experiencing the worst outcomes. The company is selling a promise it cannot keep. The immediate priority should be to audit whether external logistics vendors are involved in these modes and where the breakdown occurs. Until root causes are identified and resolved, these modes should be suspended or transparently relabeled to avoid failing customer trust.
-- Investigate warehouse and dispatch operations for light product categories: High delay rates among portable, easy-to-ship products such as sports shoes, toys, and pet supplies suggest the bottleneck is not in product handling but in upstream warehouse and dispatch processes. If heavy, complex items like strength training equipment delay due to handling difficulty, that is understandable but delays on lightweight items point to structural inefficiencies in order processing and dispatch scheduling that apply across the board. A full SOP review is recommended.
-- Reframe the business risk of delays beyond short-term financials: Average profit per order remains stable between $21–$24 regardless of delivery outcome, which may give leadership a false sense that delays are not costly. However, the true cost lies in customer retention, a customer who paid for First Class shipping and received their order late is unlikely to return. With 58% of all orders delayed across four years and no improvement trend, this is a systemic loyalty risk that does not show up in per-order profit figures but will compound into revenue decline over time.
-- Treat 2018 data as a signal worth investigating: Order volume dropped 96% in 2018 compared to prior years, from over 4,600 orders to just 166. If it is not an imcompete dataset, it could indicate customer churn resulting from sustained poor delivery performance finally reaching a tipping point.