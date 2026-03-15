CREATE TABLE users (
user_id INT PRIMARY KEY,
name VARCHAR(100),
city VARCHAR(100),
signup_date DATE
);

CREATE TABLE restaurants (
restaurant_id INT PRIMARY KEY,
name VARCHAR(150),
city VARCHAR(100),
cuisine VARCHAR(100),
rating FLOAT
);

CREATE TABLE orders (
order_id INT PRIMARY KEY,
user_id INT,
restaurant_id INT,
order_date DATE,
amount INT,
status VARCHAR(20)
);

CREATE TABLE payments (
payment_id INT PRIMARY KEY,
order_id INT,
payment_method VARCHAR(50),
payment_status VARCHAR(20)
);

CREATE TABLE order_items (
item_id INT PRIMARY KEY,
order_id INT,
item_name VARCHAR(150),
quantity INT,
price INT
);
