-- Total Orders
SELECT COUNT(*) FROM orders;

-- Total Revenue
SELECT SUM(amount)
FROM orders
WHERE status='Delivered';

-- Top Customers
SELECT user_id, SUM(amount) AS total_spent
FROM orders
GROUP BY user_id
ORDER BY total_spent DESC
LIMIT 10;

-- Most Ordered Items
SELECT item_name, SUM(quantity) AS total_orders
FROM order_items
GROUP BY item_name
ORDER BY total_orders DESC;

-- Payment Method Usage
SELECT payment_method, COUNT(*)
FROM payments
GROUP BY payment_method;
