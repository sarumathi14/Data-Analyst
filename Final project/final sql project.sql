use Retail_Sales_analysis;
## Inner Join for Order Details 
SELECT 
    o.order_id,
    o.order_date,
    o.customer_id,
    o.store_id,
    o.staff_id,
    oi.item_id,
    oi.product_id,
    p.product_name,
    p.category_id,
    c.category_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    oi.`Total price` AS total_price
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN categories c ON p.category_id = c.category_id
ORDER BY o.order_id, oi.item_id;
## Total Sales by Store 
SELECT 
    s.store_id,
    s.store_name,
    ROUND(SUM(oi.`Total price`), 2) AS total_sales
FROM stores s
INNER JOIN orders o ON s.store_id = o.store_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY s.store_id, s.store_name
ORDER BY total_sales DESC;
##Top 5 Selling Products
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;
## Customer Purchase Summary
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders_placed,
    SUM(oi.quantity) AS total_items_purchased,
    ROUND(SUM(oi.`Total price`), 2) AS total_revenue
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_revenue DESC;
## Segment Customers by Total Spend
SELECT 
    customer_id,
    customer_name,
    total_spend,
    CASE 
        WHEN total_spend < 500 THEN 'Low'
        WHEN total_spend BETWEEN 500 AND 2000 THEN 'Medium'
        WHEN total_spend > 2000 THEN 'High'
    END AS spending_bracket
FROM (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COALESCE(ROUND(SUM(oi.`Total price`), 2), 0) AS total_spend
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name
) AS customer_spending
ORDER BY total_spend DESC;
##Staff Performance Analysis
SELECT 
    st.staff_id,
    CONCAT(st.first_name, ' ', st.last_name) AS staff_name,
    st.store_id,
    s.store_name,
    COUNT(DISTINCT o.order_id) AS orders_handled,
    ROUND(SUM(oi.`Total price`), 2) AS total_revenue_generated
FROM staffs st
INNER JOIN orders o ON st.staff_id = o.staff_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN stores s ON st.store_id = s.store_id
WHERE o.order_status = 'completed'  -- Changed to a valid status
GROUP BY 
    st.staff_id, 
    st.first_name, 
    st.last_name, 
    st.store_id, 
    s.store_name
ORDER BY total_revenue_generated DESC;
## Stock Alert Query
-- If store_id exists in stocks
-- Check if you have an inventory or stock_keeping table
SELECT 
    p.product_id,
    p.product_name,
    i.quantity AS stock_quantity,
    'Company-wide Stock' AS stock_location
FROM stocks i
INNER JOIN products p ON i.product_id = p.product_id
WHERE i.quantity < 10
ORDER BY i.quantity ASC;
select*from stores;
select*from orders;
select * from customer_segments;
select*from order_items;