-- ============================================================
--   ZAPEATS ANALYTICS PLATFORM
--   SQL Portfolio Project | MySQL 8.0 | Database: zomato_db
-- ============================================================
--   Author      : Radha
--   Database    : zomato_db
--   Tables Used : users_z, restaurants_z, orders_z,
--                 order_items, payments_z
--
--   Schema Reference
--   ----------------
--   users_z        : user_id, name, city, signup_date
--   restaurants_z  : restaurant_id, name, city, cuisine, rating
--   orders_z       : order_id, user_id, restaurant_id,
--                    order_date, amount, status
--   order_items    : item_id, order_id, item_name,
--                    quantity, price
--   payments_z     : payment_id, order_id,
--                    payment_method, payment_status
-- ============================================================

USE zomato_db;

-- ============================================================
-- SECTION 1: DATABASE EXPLORATION (Queries 1–6)
-- ============================================================

-- Query 1: Row Counts Across All Tables
-- Business Objective: Understand the size and scale of the dataset.
-- Expected Insight: Confirms data was loaded correctly; sets scale expectations.

SELECT 'users_z'       AS table_name, COUNT(*) AS total_rows FROM users_z
UNION ALL
SELECT 'restaurants_z' AS table_name, COUNT(*) AS total_rows FROM restaurants_z
UNION ALL
SELECT 'orders_z'      AS table_name, COUNT(*) AS total_rows FROM orders_z
UNION ALL
SELECT 'order_items'   AS table_name, COUNT(*) AS total_rows FROM order_items
UNION ALL
SELECT 'payments_z'    AS table_name, COUNT(*) AS total_rows FROM payments_z;

-- ─────────────────────────────────────────────────────────────

-- Query 2: Distinct Cities in Users vs Restaurants
-- Business Objective: Compare geographic coverage of users and restaurants.
-- Expected Insight: Reveals if supply (restaurants) matches demand (users) by city.

SELECT
    'users_z'       AS source,
    COUNT(DISTINCT city) AS distinct_cities
FROM users_z
UNION ALL
SELECT
    'restaurants_z' AS source,
    COUNT(DISTINCT city) AS distinct_cities
FROM restaurants_z;

-- ─────────────────────────────────────────────────────────────

-- Query 3: Order Status Distribution
-- Business Objective: Profile all possible order statuses in the system.
-- Expected Insight: Identifies if there are anomalous or unrecognised statuses.

SELECT
    status,
    COUNT(*) AS order_count
FROM orders_z
GROUP BY status
ORDER BY order_count DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 4: Payment Method Distribution
-- Business Objective: Understand how customers prefer to pay.
-- Expected Insight: Guides investment in payment infrastructure.

SELECT
    payment_method,
    COUNT(*) AS usage_count
FROM payments_z
GROUP BY payment_method
ORDER BY usage_count DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 5: Cuisine Type Distribution
-- Business Objective: Identify which cuisines dominate the platform.
-- Expected Insight: Helps prioritise onboarding restaurants of popular cuisines.

SELECT
    cuisine,
    COUNT(*) AS restaurant_count
FROM restaurants_z
GROUP BY cuisine
ORDER BY restaurant_count DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 6: Order Amount Range & Statistical Summary
-- Business Objective: Understand the spread of order values.
-- Expected Insight: Supports pricing strategy and outlier detection.

SELECT
    MIN(amount)                        AS min_order_value,
    MAX(amount)                        AS max_order_value,
    ROUND(AVG(amount), 2)              AS avg_order_value,
    ROUND(SUM(amount) / COUNT(*), 2)   AS mean_check
FROM orders_z;


-- ============================================================
-- SECTION 2: CUSTOMER ANALYSIS (Queries 7–13)
-- ============================================================

-- Query 7: Total Users Per City
-- Business Objective: Identify cities with the highest customer base.
-- Expected Insight: Reveals where to focus marketing and supply expansion.

SELECT
    city,
    COUNT(user_id) AS total_users
FROM users_z
GROUP BY city
ORDER BY total_users DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 8: New User Signups Per Year
-- Business Objective: Track year-over-year user acquisition growth.
-- Expected Insight: Indicates effectiveness of growth campaigns over time.

SELECT
    LEFT(signup_date, 4)    AS signup_year,
    COUNT(user_id)          AS new_users
FROM users_z
GROUP BY signup_year
ORDER BY signup_year;

-- ─────────────────────────────────────────────────────────────

-- Query 9: Users Who Have Never Placed an Order
-- Business Objective: Find dormant users (registered but never ordered).
-- Expected Insight: Target this segment with re-engagement campaigns.

SELECT
    u.user_id,
    u.name,
    u.city,
    u.signup_date
FROM users_z u
LEFT JOIN orders_z o ON u.user_id = o.user_id
WHERE o.order_id IS NULL
ORDER BY u.signup_date;

-- ─────────────────────────────────────────────────────────────

-- Query 10: Top 10 Most Active Customers by Order Count
-- Business Objective: Identify the platform's most loyal customers.
-- Expected Insight: These users are candidates for premium/loyalty programmes.

SELECT
    u.user_id,
    u.name,
    u.city,
    COUNT(o.order_id) AS total_orders
FROM users_z u
INNER JOIN orders_z o ON u.user_id = o.user_id
GROUP BY u.user_id, u.name, u.city
ORDER BY total_orders DESC
LIMIT 10;

-- ─────────────────────────────────────────────────────────────

-- Query 11: Customers Who Ordered from Multiple Cities
-- Business Objective: Detect users ordering from restaurants in different cities.
-- Expected Insight: May reveal tourists, migrant workers, or data quality issues.

SELECT
    u.user_id,
    u.name,
    COUNT(DISTINCT r.city) AS cities_ordered_from
FROM users_z u
INNER JOIN orders_z o    ON u.user_id       = o.user_id
INNER JOIN restaurants_z r ON o.restaurant_id = r.restaurant_id
GROUP BY u.user_id, u.name
HAVING cities_ordered_from > 1
ORDER BY cities_ordered_from DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 12: Average Orders Per User by City
-- Business Objective: Compare engagement depth across cities.
-- Expected Insight: Cities with low avg orders need activation nudges.

SELECT
    u.city,
    COUNT(DISTINCT u.user_id)                             AS total_users,
    COUNT(o.order_id)                                     AS total_orders,
    ROUND(COUNT(o.order_id) / COUNT(DISTINCT u.user_id), 2) AS avg_orders_per_user
FROM users_z u
LEFT JOIN orders_z o ON u.user_id = o.user_id
GROUP BY u.city
ORDER BY avg_orders_per_user DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 13: Users with Only One Order (One-Time Buyers)
-- Business Objective: Identify customers who ordered exactly once.
-- Expected Insight: Key churn risk segment — target with second-order incentives.

SELECT
    u.user_id,
    u.name,
    u.city,
    COUNT(o.order_id) AS order_count
FROM users_z u
INNER JOIN orders_z o ON u.user_id = o.user_id
GROUP BY u.user_id, u.name, u.city
HAVING order_count = 1
ORDER BY u.city;


-- ============================================================
-- SECTION 3: RESTAURANT ANALYSIS (Queries 14–20)
-- ============================================================

-- Query 14: Top 10 Highest-Rated Restaurants
-- Business Objective: Surface the best-performing restaurants on the platform.
-- Expected Insight: Use for homepage featured listings and partner rewards.

SELECT
    restaurant_id,
    name,
    city,
    cuisine,
    rating
FROM restaurants_z
ORDER BY rating DESC
LIMIT 10;

-- ─────────────────────────────────────────────────────────────

-- Query 15: Average Rating by Cuisine Type
-- Business Objective: Determine which cuisines customers rate most highly.
-- Expected Insight: Prioritise high-rated cuisines in marketing materials.

SELECT
    cuisine,
    COUNT(restaurant_id)       AS restaurant_count,
    ROUND(AVG(rating), 2)      AS avg_rating,
    ROUND(MIN(rating), 2)      AS min_rating,
    ROUND(MAX(rating), 2)      AS max_rating
FROM restaurants_z
GROUP BY cuisine
ORDER BY avg_rating DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 16: Number of Restaurants Per City
-- Business Objective: Map supply density of restaurants across cities.
-- Expected Insight: Cities with few restaurants are targets for supply expansion.

SELECT
    city,
    COUNT(restaurant_id)  AS total_restaurants,
    ROUND(AVG(rating), 2) AS avg_city_rating
FROM restaurants_z
GROUP BY city
ORDER BY total_restaurants DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 17: Restaurants with Below-Average Rating
-- Business Objective: Flag underperforming restaurant partners.
-- Expected Insight: Trigger quality improvement programmes or partner review.

SELECT
    restaurant_id,
    name,
    city,
    cuisine,
    rating
FROM restaurants_z
WHERE rating < (SELECT AVG(rating) FROM restaurants_z)
ORDER BY rating ASC;

-- ─────────────────────────────────────────────────────────────

-- Query 18: Most Popular Cuisines by Number of Orders
-- Business Objective: Identify cuisines that drive the most order volume.
-- Expected Insight: Align restaurant onboarding with demand signals.

SELECT
    r.cuisine,
    COUNT(o.order_id) AS total_orders
FROM restaurants_z r
INNER JOIN orders_z o ON r.restaurant_id = o.restaurant_id
GROUP BY r.cuisine
ORDER BY total_orders DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 19: Top Restaurant per City by Order Volume
-- Business Objective: Find the leading restaurant in each city.
-- Expected Insight: Benchmark these leaders for best practices and features.

SELECT
    city,
    restaurant_name,
    total_orders
FROM (
    SELECT
        r.city,
        r.name   AS restaurant_name,
        COUNT(o.order_id) AS total_orders,
        RANK() OVER (PARTITION BY r.city ORDER BY COUNT(o.order_id) DESC) AS rnk
    FROM restaurants_z r
    INNER JOIN orders_z o ON r.restaurant_id = o.restaurant_id
    GROUP BY r.city, r.name
) ranked
WHERE rnk = 1
ORDER BY total_orders DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 20: Restaurants with No Orders Yet
-- Business Objective: Identify onboarded but inactive restaurant partners.
-- Expected Insight: These restaurants need activation support or investigation.

SELECT
    r.restaurant_id,
    r.name,
    r.city,
    r.cuisine,
    r.rating
FROM restaurants_z r
LEFT JOIN orders_z o ON r.restaurant_id = o.restaurant_id
WHERE o.order_id IS NULL
ORDER BY r.city;


-- ============================================================
-- SECTION 4: ORDER ANALYSIS (Queries 21–27)
-- ============================================================

-- Query 21: Total Orders and Revenue by Year
-- Business Objective: Track platform growth across years.
-- Expected Insight: Identifies inflection points in business growth.

SELECT
    LEFT(order_date, 4)   AS order_year,
    COUNT(order_id)       AS total_orders,
    SUM(amount)           AS total_revenue
FROM orders_z
GROUP BY order_year
ORDER BY order_year;

-- ─────────────────────────────────────────────────────────────

-- Query 22: Orders by Status with Revenue Impact
-- Business Objective: Quantify revenue tied to each order status.
-- Expected Insight: Cancelled/pending revenue highlights operational losses.

SELECT
    status,
    COUNT(order_id)       AS order_count,
    SUM(amount)           AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount
FROM orders_z
GROUP BY status
ORDER BY total_amount DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 23: Monthly Order Volume Trend
-- Business Objective: Detect seasonal demand patterns.
-- Expected Insight: Plan staffing, logistics, and promotions around peak months.

SELECT
    LEFT(order_date, 7)   AS order_month,
    COUNT(order_id)       AS total_orders,
    SUM(amount)           AS monthly_revenue
FROM orders_z
GROUP BY order_month
ORDER BY order_month;

-- ─────────────────────────────────────────────────────────────

-- Query 24: High-Value Orders (Above 500)
-- Business Objective: Identify large orders that deserve priority handling.
-- Expected Insight: Premium orders may justify dedicated delivery or packaging.

SELECT
    o.order_id,
    u.name     AS customer_name,
    r.name     AS restaurant_name,
    o.amount,
    o.status,
    o.order_date
FROM orders_z o
INNER JOIN users_z u        ON o.user_id       = u.user_id
INNER JOIN restaurants_z r  ON o.restaurant_id = r.restaurant_id
WHERE o.amount > 500
ORDER BY o.amount DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 25: Cancelled Orders Per Restaurant
-- Business Objective: Pinpoint restaurants with high cancellation rates.
-- Expected Insight: High cancellations damage trust — triggers quality review.

SELECT
    r.restaurant_id,
    r.name            AS restaurant_name,
    r.city,
    COUNT(o.order_id) AS cancelled_orders
FROM restaurants_z r
INNER JOIN orders_z o ON r.restaurant_id = o.restaurant_id
WHERE o.status = 'Cancelled'
GROUP BY r.restaurant_id, r.name, r.city
ORDER BY cancelled_orders DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 26: Orders Placed Per Day of Week (Using DAYNAME)
-- Business Objective: Identify which weekdays have the most orders.
-- Expected Insight: Schedule promotions and delivery staff on high-demand days.

SELECT
    DAYNAME(STR_TO_DATE(order_date, '%Y-%m-%d')) AS day_of_week,
    COUNT(order_id)                              AS total_orders,
    SUM(amount)                                  AS total_revenue
FROM orders_z
GROUP BY day_of_week
ORDER BY FIELD(day_of_week,
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');

-- ─────────────────────────────────────────────────────────────

-- Query 27: Average Order Value Per Restaurant
-- Business Objective: Identify which restaurants command the highest AOV.
-- Expected Insight: High-AOV restaurants attract premium customers.

SELECT
    r.restaurant_id,
    r.name            AS restaurant_name,
    r.cuisine,
    COUNT(o.order_id)       AS total_orders,
    ROUND(AVG(o.amount), 2) AS avg_order_value
FROM restaurants_z r
INNER JOIN orders_z o ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.name, r.cuisine
ORDER BY avg_order_value DESC
LIMIT 15;


-- ============================================================
-- SECTION 5: REVENUE ANALYSIS (Queries 28–33)
-- ============================================================

-- Query 28: Total Platform Revenue
-- Business Objective: Calculate the platform's total gross merchandise value (GMV).
-- Expected Insight: Core KPI for investor reporting and business health.

SELECT
    COUNT(order_id)       AS total_orders,
    SUM(amount)           AS total_gmv,
    ROUND(AVG(amount), 2) AS avg_order_value,
    MIN(amount)           AS min_order,
    MAX(amount)           AS max_order
FROM orders_z
WHERE status = 'Delivered';

-- ─────────────────────────────────────────────────────────────

-- Query 29: Revenue by City (via Restaurant Location)
-- Business Objective: Compare revenue contribution across cities.
-- Expected Insight: Focus operations and marketing on top revenue cities.

SELECT
    r.city,
    COUNT(o.order_id)     AS total_orders,
    SUM(o.amount)         AS total_revenue,
    ROUND(AVG(o.amount), 2) AS avg_order_value
FROM orders_z o
INNER JOIN restaurants_z r ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY total_revenue DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 30: Revenue Contribution by Cuisine
-- Business Objective: Determine which cuisine types drive the most revenue.
-- Expected Insight: Cuisine-level revenue guides partner acquisition strategy.

SELECT
    r.cuisine,
    SUM(o.amount)           AS total_revenue,
    COUNT(o.order_id)       AS total_orders,
    ROUND(AVG(o.amount), 2) AS avg_order_value,
    ROUND(SUM(o.amount) * 100.0 / (SELECT SUM(amount) FROM orders_z), 2) AS revenue_pct
FROM orders_z o
INNER JOIN restaurants_z r ON o.restaurant_id = r.restaurant_id
GROUP BY r.cuisine
ORDER BY total_revenue DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 31: Top 10 Revenue-Generating Restaurants
-- Business Objective: Find the highest-grossing restaurant partners.
-- Expected Insight: VIP partners deserve priority support and co-marketing.

SELECT
    r.restaurant_id,
    r.name            AS restaurant_name,
    r.city,
    r.cuisine,
    SUM(o.amount)     AS total_revenue,
    COUNT(o.order_id) AS total_orders
FROM restaurants_z r
INNER JOIN orders_z o ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.name, r.city, r.cuisine
ORDER BY total_revenue DESC
LIMIT 10;

-- ─────────────────────────────────────────────────────────────

-- Query 32: Year-over-Year Revenue Growth
-- Business Objective: Measure annual revenue growth rate.
-- Expected Insight: Declining growth signals market saturation or competition.

SELECT
    curr.order_year,
    curr.total_revenue,
    prev.total_revenue                                                              AS prev_year_revenue,
    ROUND((curr.total_revenue - prev.total_revenue) * 100.0 / prev.total_revenue, 2) AS yoy_growth_pct
FROM (
    SELECT LEFT(order_date, 4) AS order_year, SUM(amount) AS total_revenue
    FROM orders_z GROUP BY order_year
) curr
LEFT JOIN (
    SELECT LEFT(order_date, 4) AS order_year, SUM(amount) AS total_revenue
    FROM orders_z GROUP BY order_year
) prev ON CAST(curr.order_year AS UNSIGNED) = CAST(prev.order_year AS UNSIGNED) + 1
ORDER BY curr.order_year;

-- ─────────────────────────────────────────────────────────────

-- Query 33: Revenue Lost to Cancelled Orders
-- Business Objective: Quantify revenue impact of cancellations.
-- Expected Insight: Even small cancellation rates represent significant lost GMV.

SELECT
    LEFT(order_date, 4)  AS order_year,
    SUM(CASE WHEN status = 'Cancelled' THEN amount ELSE 0 END)  AS cancelled_revenue,
    SUM(amount)                                                  AS total_potential_revenue,
    ROUND(
        SUM(CASE WHEN status = 'Cancelled' THEN amount ELSE 0 END) * 100.0
        / SUM(amount), 2
    )                                                            AS cancellation_loss_pct
FROM orders_z
GROUP BY order_year
ORDER BY order_year;


-- ============================================================
-- SECTION 6: PAYMENT ANALYSIS (Queries 34–39)
-- ============================================================

-- Query 34: Payment Success vs Failure Rate
-- Business Objective: Measure payment gateway reliability.
-- Expected Insight: High failure rates mean lost revenue and poor UX.

SELECT
    payment_status,
    COUNT(payment_id)                                                      AS total_transactions,
    ROUND(COUNT(payment_id) * 100.0 / (SELECT COUNT(*) FROM payments_z), 2) AS percentage
FROM payments_z
GROUP BY payment_status
ORDER BY total_transactions DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 35: Revenue by Payment Method
-- Business Objective: Link payment methods to order values.
-- Expected Insight: Certain payment methods may skew toward higher-value orders.

SELECT
    p.payment_method,
    COUNT(p.payment_id)       AS transaction_count,
    SUM(o.amount)             AS total_revenue,
    ROUND(AVG(o.amount), 2)   AS avg_order_value
FROM payments_z p
INNER JOIN orders_z o ON p.order_id = o.order_id
GROUP BY p.payment_method
ORDER BY total_revenue DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 36: Failed Payments by Method
-- Business Objective: Identify which payment methods fail most often.
-- Expected Insight: Unreliable methods should be flagged or improved.

SELECT
    payment_method,
    COUNT(payment_id) AS failed_payments
FROM payments_z
WHERE payment_status = 'Failed'
GROUP BY payment_method
ORDER BY failed_payments DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 37: Orders with No Payment Record (Orphan Orders)
-- Business Objective: Detect orders that have no payment entry.
-- Expected Insight: Indicates data pipeline gaps or checkout abandonment.

SELECT
    o.order_id,
    o.user_id,
    o.amount,
    o.status,
    o.order_date
FROM orders_z o
LEFT JOIN payments_z p ON o.order_id = p.order_id
WHERE p.payment_id IS NULL
ORDER BY o.order_date;

-- ─────────────────────────────────────────────────────────────

-- Query 38: Most Preferred Payment Method Per City
-- Business Objective: Understand payment preferences by geography.
-- Expected Insight: Tailor checkout flows and promotions by city.

SELECT
    city,
    payment_method,
    method_count
FROM (
    SELECT
        u.city,
        p.payment_method,
        COUNT(p.payment_id) AS method_count,
        RANK() OVER (PARTITION BY u.city ORDER BY COUNT(p.payment_id) DESC) AS rnk
    FROM payments_z p
    INNER JOIN orders_z o  ON p.order_id  = o.order_id
    INNER JOIN users_z u   ON o.user_id   = u.user_id
    GROUP BY u.city, p.payment_method
) ranked
WHERE rnk = 1
ORDER BY city;

-- ─────────────────────────────────────────────────────────────

-- Query 39: Successful Payment Rate by Method
-- Business Objective: Calculate success rate for each payment method.
-- Expected Insight: Benchmark methods and identify the most reliable ones.

SELECT
    payment_method,
    COUNT(payment_id)                                                         AS total_attempts,
    SUM(CASE WHEN payment_status = 'Paid' THEN 1 ELSE 0 END)                 AS successful,
    ROUND(
        SUM(CASE WHEN payment_status = 'Paid' THEN 1 ELSE 0 END) * 100.0
        / COUNT(payment_id), 2
    )                                                                         AS success_rate_pct
FROM payments_z
GROUP BY payment_method
ORDER BY success_rate_pct DESC;


-- ============================================================
-- SECTION 7: FOOD ITEM ANALYSIS (Queries 40–44)
-- ============================================================

-- Query 40: Top 10 Best-Selling Food Items by Quantity
-- Business Objective: Identify the most ordered items across the platform.
-- Expected Insight: Promote top items and ensure supply chain readiness.

SELECT
    item_name,
    SUM(quantity)  AS total_quantity_sold,
    COUNT(item_id) AS times_ordered
FROM order_items
GROUP BY item_name
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- ─────────────────────────────────────────────────────────────

-- Query 41: Top 10 Items by Revenue Generated
-- Business Objective: Find which food items contribute the most to revenue.
-- Expected Insight: High-revenue items deserve menu prominence and upsell focus.

SELECT
    item_name,
    SUM(quantity * price)         AS total_revenue,
    SUM(quantity)                 AS units_sold,
    ROUND(AVG(price), 2)          AS avg_unit_price
FROM order_items
GROUP BY item_name
ORDER BY total_revenue DESC
LIMIT 10;

-- ─────────────────────────────────────────────────────────────

-- Query 42: Average Price Per Item
-- Business Objective: Understand pricing distribution across menu items.
-- Expected Insight: Identifies premium vs value menu items.

SELECT
    item_name,
    ROUND(AVG(price), 2)  AS avg_price,
    MIN(price)            AS min_price,
    MAX(price)            AS max_price,
    COUNT(item_id)        AS order_frequency
FROM order_items
GROUP BY item_name
ORDER BY avg_price DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 43: Items Ordered with High Quantity (Bulk Orders)
-- Business Objective: Find items frequently ordered in large quantities.
-- Expected Insight: Bulk items may indicate corporate/group orders — a growth segment.

SELECT
    item_name,
    order_id,
    quantity,
    price,
    (quantity * price) AS line_total
FROM order_items
WHERE quantity >= 5
ORDER BY quantity DESC, line_total DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 44: Items Never Repeated (Ordered Only Once)
-- Business Objective: Identify one-time items that failed to retain orders.
-- Expected Insight: May indicate quality issues or mismatched customer expectations.

SELECT
    item_name,
    COUNT(item_id) AS times_ordered
FROM order_items
GROUP BY item_name
HAVING times_ordered = 1
ORDER BY item_name;


-- ============================================================
-- SECTION 8: CUSTOMER SPENDING ANALYSIS (Queries 45–49)
-- ============================================================

-- Query 45: Total Spend Per Customer (Customer Lifetime Value)
-- Business Objective: Rank customers by total money spent on the platform.
-- Expected Insight: CLV ranking drives tiered loyalty rewards strategy.

SELECT
    u.user_id,
    u.name,
    u.city,
    COUNT(o.order_id)     AS total_orders,
    SUM(o.amount)         AS lifetime_spend,
    ROUND(AVG(o.amount), 2) AS avg_order_value
FROM users_z u
INNER JOIN orders_z o ON u.user_id = o.user_id
GROUP BY u.user_id, u.name, u.city
ORDER BY lifetime_spend DESC
LIMIT 20;

-- ─────────────────────────────────────────────────────────────

-- Query 46: Customer Spend Quartile Segmentation
-- Business Objective: Segment customers into Low / Mid / High / Premium tiers.
-- Expected Insight: Enables personalised offers per spending tier.

SELECT
    user_id,
    name,
    city,
    lifetime_spend,
    CASE
        WHEN spend_percentile <= 25 THEN 'Bronze'
        WHEN spend_percentile <= 50 THEN 'Silver'
        WHEN spend_percentile <= 75 THEN 'Gold'
        ELSE 'Platinum'
    END AS customer_tier
FROM (
    SELECT
        u.user_id,
        u.name,
        u.city,
        SUM(o.amount) AS lifetime_spend,
        NTILE(100) OVER (ORDER BY SUM(o.amount)) AS spend_percentile
    FROM users_z u
    INNER JOIN orders_z o ON u.user_id = o.user_id
    GROUP BY u.user_id, u.name, u.city
) segmented
ORDER BY lifetime_spend DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 47: Customers Spending Above Platform Average
-- Business Objective: Identify high-value customers above average spend.
-- Expected Insight: These users are VIPs worth retaining with exclusive perks.

SELECT
    u.user_id,
    u.name,
    u.city,
    SUM(o.amount) AS total_spend
FROM users_z u
INNER JOIN orders_z o ON u.user_id = o.user_id
GROUP BY u.user_id, u.name, u.city
HAVING total_spend > (
    SELECT AVG(user_total)
    FROM (
        SELECT user_id, SUM(amount) AS user_total
        FROM orders_z
        GROUP BY user_id
    ) avg_sub
)
ORDER BY total_spend DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 48: City-Wise Average Customer Spend
-- Business Objective: Compare spending power across cities.
-- Expected Insight: High-spend cities justify premium restaurant partnerships.

SELECT
    u.city,
    COUNT(DISTINCT u.user_id)               AS active_customers,
    SUM(o.amount)                           AS total_city_spend,
    ROUND(AVG(o.amount), 2)                 AS avg_order_value,
    ROUND(SUM(o.amount) / COUNT(DISTINCT u.user_id), 2) AS avg_spend_per_customer
FROM users_z u
INNER JOIN orders_z o ON u.user_id = o.user_id
GROUP BY u.city
ORDER BY avg_spend_per_customer DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 49: Repeat vs One-Time Customer Revenue Split
-- Business Objective: Compare revenue from loyal vs one-time customers.
-- Expected Insight: Retention ROI analysis — value of repeat buyers.

SELECT
    customer_type,
    COUNT(user_id)        AS customer_count,
    SUM(total_spend)      AS segment_revenue,
    ROUND(AVG(total_spend), 2) AS avg_spend
FROM (
    SELECT
        u.user_id,
        SUM(o.amount)     AS total_spend,
        COUNT(o.order_id) AS order_count,
        CASE
            WHEN COUNT(o.order_id) = 1 THEN 'One-Time Buyer'
            ELSE 'Repeat Buyer'
        END AS customer_type
    FROM users_z u
    INNER JOIN orders_z o ON u.user_id = o.user_id
    GROUP BY u.user_id
) classified
GROUP BY customer_type;


-- ============================================================
-- SECTION 9: JOIN-BASED ANALYSIS (Queries 50–55)
-- ============================================================

-- Query 50: Full Order Detail Report (5-Table Join)
-- Business Objective: Build a complete order record from all tables.
-- Expected Insight: Foundation for BI dashboards and detailed reporting.

SELECT
    o.order_id,
    u.name              AS customer_name,
    u.city              AS customer_city,
    r.name              AS restaurant_name,
    r.cuisine,
    o.amount,
    o.status            AS order_status,
    o.order_date,
    p.payment_method,
    p.payment_status
FROM orders_z o
INNER JOIN users_z u        ON o.user_id       = u.user_id
INNER JOIN restaurants_z r  ON o.restaurant_id = r.restaurant_id
LEFT JOIN  payments_z p     ON o.order_id      = p.order_id
ORDER BY o.order_date DESC
LIMIT 100;

-- ─────────────────────────────────────────────────────────────

-- Query 51: Customer Order History with Item Details
-- Business Objective: Show every item a customer ordered in each transaction.
-- Expected Insight: Enables personalised menu recommendations.

SELECT
    u.name            AS customer_name,
    o.order_id,
    o.order_date,
    oi.item_name,
    oi.quantity,
    oi.price,
    (oi.quantity * oi.price) AS line_total,
    o.status
FROM users_z u
INNER JOIN orders_z o      ON u.user_id  = o.user_id
INNER JOIN order_items oi  ON o.order_id = oi.order_id
ORDER BY u.name, o.order_date, oi.item_name
LIMIT 200;

-- ─────────────────────────────────────────────────────────────

-- Query 52: Restaurant Performance Scorecard
-- Business Objective: Combined view of ratings, orders, and revenue per restaurant.
-- Expected Insight: Single scorecard for partner performance reviews.

SELECT
    r.restaurant_id,
    r.name              AS restaurant_name,
    r.city,
    r.cuisine,
    r.rating,
    COUNT(o.order_id)         AS total_orders,
    SUM(o.amount)             AS total_revenue,
    ROUND(AVG(o.amount), 2)   AS avg_order_value,
    SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations
FROM restaurants_z r
LEFT JOIN orders_z o ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.name, r.city, r.cuisine, r.rating
ORDER BY total_revenue DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 53: Customers and Their Favourite Cuisine
-- Business Objective: Find the cuisine each customer orders most.
-- Expected Insight: Drives personalised homepage and notification content.

SELECT
    customer_name,
    customer_city,
    favourite_cuisine,
    cuisine_order_count
FROM (
    SELECT
        u.name          AS customer_name,
        u.city          AS customer_city,
        r.cuisine       AS favourite_cuisine,
        COUNT(o.order_id) AS cuisine_order_count,
        RANK() OVER (PARTITION BY u.user_id ORDER BY COUNT(o.order_id) DESC) AS rnk
    FROM users_z u
    INNER JOIN orders_z o      ON u.user_id       = o.user_id
    INNER JOIN restaurants_z r ON o.restaurant_id = r.restaurant_id
    GROUP BY u.user_id, u.name, u.city, r.cuisine
) ranked
WHERE rnk = 1
ORDER BY cuisine_order_count DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 54: Orders with Both Payment and Item Details
-- Business Objective: Verify order integrity across payment and item records.
-- Expected Insight: Confirms transactional data completeness for auditing.

SELECT
    o.order_id,
    o.order_date,
    o.amount         AS order_amount,
    p.payment_method,
    p.payment_status,
    COUNT(oi.item_id)       AS item_count,
    SUM(oi.quantity)        AS total_items,
    SUM(oi.quantity * oi.price) AS items_subtotal
FROM orders_z o
INNER JOIN payments_z p    ON o.order_id = p.order_id
INNER JOIN order_items oi  ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date, o.amount, p.payment_method, p.payment_status
ORDER BY o.order_date DESC
LIMIT 100;

-- ─────────────────────────────────────────────────────────────

-- Query 55: High-Rating Restaurants with Low Order Volume
-- Business Objective: Find quality restaurants being under-utilised.
-- Expected Insight: These are hidden gems — ideal candidates for featuring campaigns.

SELECT
    r.restaurant_id,
    r.name         AS restaurant_name,
    r.city,
    r.cuisine,
    r.rating,
    COUNT(o.order_id) AS total_orders
FROM restaurants_z r
LEFT JOIN orders_z o ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.name, r.city, r.cuisine, r.rating
HAVING r.rating >= 4.0 AND total_orders < 10
ORDER BY r.rating DESC, total_orders ASC;


-- ============================================================
-- SECTION 10: ADVANCED ANALYSIS (Queries 56–65)
-- ============================================================

-- Query 56: Running Total Revenue Over Time (Window Function)
-- Business Objective: Show cumulative revenue growth month by month.
-- Expected Insight: Visual growth trajectory for executive dashboards.

SELECT
    order_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (ORDER BY order_month ROWS UNBOUNDED PRECEDING) AS running_total
FROM (
    SELECT
        LEFT(order_date, 7)  AS order_month,
        SUM(amount)          AS monthly_revenue
    FROM orders_z
    GROUP BY order_month
) monthly
ORDER BY order_month;

-- ─────────────────────────────────────────────────────────────

-- Query 57: Customer Order Rank Within Their City
-- Business Objective: Rank customers by spend within each city.
-- Expected Insight: City-level leaderboard for targeted loyalty rewards.

SELECT
    city,
    customer_name,
    total_spend,
    RANK() OVER (PARTITION BY city ORDER BY total_spend DESC) AS city_rank
FROM (
    SELECT
        u.city,
        u.name    AS customer_name,
        SUM(o.amount) AS total_spend
    FROM users_z u
    INNER JOIN orders_z o ON u.user_id = o.user_id
    GROUP BY u.user_id, u.name, u.city
) city_spend
ORDER BY city, city_rank;

-- ─────────────────────────────────────────────────────────────

-- Query 58: Month-over-Month Revenue Change (LAG Function)
-- Business Objective: Calculate revenue delta vs prior month.
-- Expected Insight: Identifies months with sudden growth or drops.

SELECT
    order_month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY order_month)        AS prev_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_month))
        * 100.0
        / LAG(monthly_revenue) OVER (ORDER BY order_month), 2
    )                                                       AS mom_growth_pct
FROM (
    SELECT
        LEFT(order_date, 7)  AS order_month,
        SUM(amount)          AS monthly_revenue
    FROM orders_z
    GROUP BY order_month
) monthly
ORDER BY order_month;

-- ─────────────────────────────────────────────────────────────

-- Query 59: Top 3 Items Ordered Per Restaurant (Using RANK)
-- Business Objective: Find each restaurant's top 3 best-selling menu items.
-- Expected Insight: Powers "restaurant specialities" section in the app.

SELECT
    restaurant_name,
    item_name,
    total_quantity,
    item_rank
FROM (
    SELECT
        r.name              AS restaurant_name,
        oi.item_name,
        SUM(oi.quantity)    AS total_quantity,
        RANK() OVER (PARTITION BY r.restaurant_id ORDER BY SUM(oi.quantity) DESC) AS item_rank
    FROM restaurants_z r
    INNER JOIN orders_z o     ON r.restaurant_id = o.restaurant_id
    INNER JOIN order_items oi ON o.order_id      = oi.order_id
    GROUP BY r.restaurant_id, r.name, oi.item_name
) ranked_items
WHERE item_rank <= 3
ORDER BY restaurant_name, item_rank;

-- ─────────────────────────────────────────────────────────────

-- Query 60: Percentage Contribution of Each City to Total Revenue
-- Business Objective: Show each city's revenue share of the platform total.
-- Expected Insight: Concentration risk analysis and geographic revenue split.

SELECT
    r.city,
    SUM(o.amount)   AS city_revenue,
    ROUND(
        SUM(o.amount) * 100.0
        / SUM(SUM(o.amount)) OVER (), 2
    )               AS revenue_share_pct
FROM orders_z o
INNER JOIN restaurants_z r ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY city_revenue DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 61: Customer Retention — Users Who Ordered in Multiple Years
-- Business Objective: Identify customers retained across more than one year.
-- Expected Insight: Multi-year customers are the platform's most loyal cohort.

SELECT
    u.user_id,
    u.name,
    u.city,
    COUNT(DISTINCT LEFT(o.order_date, 4)) AS active_years,
    MIN(LEFT(o.order_date, 4))            AS first_order_year,
    MAX(LEFT(o.order_date, 4))            AS last_order_year
FROM users_z u
INNER JOIN orders_z o ON u.user_id = o.user_id
GROUP BY u.user_id, u.name, u.city
HAVING active_years > 1
ORDER BY active_years DESC, u.name;

-- ─────────────────────────────────────────────────────────────

-- Query 62: Dense Rank of Restaurants by Revenue Within Cuisine
-- Business Objective: Rank restaurants against peers in the same cuisine.
-- Expected Insight: Fair competitive benchmarking within cuisine categories.

SELECT
    cuisine,
    restaurant_name,
    total_revenue,
    DENSE_RANK() OVER (PARTITION BY cuisine ORDER BY total_revenue DESC) AS cuisine_rank
FROM (
    SELECT
        r.cuisine,
        r.name          AS restaurant_name,
        SUM(o.amount)   AS total_revenue
    FROM restaurants_z r
    INNER JOIN orders_z o ON r.restaurant_id = o.restaurant_id
    GROUP BY r.restaurant_id, r.cuisine, r.name
) cuisine_revenue
ORDER BY cuisine, cuisine_rank;

-- ─────────────────────────────────────────────────────────────

-- Query 63: CTE — High Value Customers Who Used UPI
-- Business Objective: Find premium spenders who prefer UPI payments.
-- Expected Insight: Ideal segment for UPI cashback and partnership campaigns.

WITH high_value_customers AS (
    SELECT
        u.user_id,
        u.name,
        u.city,
        SUM(o.amount) AS total_spend
    FROM users_z u
    INNER JOIN orders_z o ON u.user_id = o.user_id
    GROUP BY u.user_id, u.name, u.city
    HAVING total_spend > 1000
),
upi_users AS (
    SELECT DISTINCT o.user_id
    FROM orders_z o
    INNER JOIN payments_z p ON o.order_id = p.order_id
    WHERE p.payment_method = 'UPI'
)
SELECT
    hvc.user_id,
    hvc.name,
    hvc.city,
    hvc.total_spend
FROM high_value_customers hvc
INNER JOIN upi_users uu ON hvc.user_id = uu.user_id
ORDER BY hvc.total_spend DESC;

-- ─────────────────────────────────────────────────────────────

-- Query 64: Order Frequency Bucket Analysis
-- Business Objective: Segment customers by how often they order.
-- Expected Insight: Understand engagement distribution across the user base.

SELECT
    frequency_bucket,
    COUNT(user_id)  AS customer_count,
    SUM(total_orders) AS orders_from_segment
FROM (
    SELECT
        u.user_id,
        COUNT(o.order_id) AS total_orders,
        CASE
            WHEN COUNT(o.order_id) = 1       THEN '1 Order'
            WHEN COUNT(o.order_id) BETWEEN 2 AND 5  THEN '2-5 Orders'
            WHEN COUNT(o.order_id) BETWEEN 6 AND 10 THEN '6-10 Orders'
            ELSE '10+ Orders'
        END AS frequency_bucket
    FROM users_z u
    INNER JOIN orders_z o ON u.user_id = o.user_id
    GROUP BY u.user_id
) bucketed
GROUP BY frequency_bucket
ORDER BY FIELD(frequency_bucket, '1 Order', '2-5 Orders', '6-10 Orders', '10+ Orders');

-- ─────────────────────────────────────────────────────────────

-- Query 65: CTE — Monthly Revenue with 3-Month Moving Average
-- Business Objective: Smooth monthly revenue to remove seasonal noise.
-- Expected Insight: Moving averages reveal true growth trends for reporting.

WITH monthly_revenue AS (
    SELECT
        LEFT(order_date, 7) AS order_month,
        SUM(amount)         AS revenue
    FROM orders_z
    GROUP BY order_month
)
SELECT
    order_month,
    revenue                  AS monthly_revenue,
    ROUND(
        AVG(revenue) OVER (
            ORDER BY order_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    )                        AS moving_avg_3m
FROM monthly_revenue
ORDER BY order_month;

-- ============================================================
-- END OF ZAPEATS SQL PORTFOLIO PROJECT
-- Total Queries: 65
-- Sections: 10
-- Tables Used: users_z, restaurants_z, orders_z,
--              order_items, payments_z
-- All queries verified against actual schema.
-- No CROSS JOINs. No invented columns.
-- Compatible with MySQL 8.0 / MySQL Workbench.
-- ============================================================
