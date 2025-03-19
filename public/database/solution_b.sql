-- 1. Liệt kê tóm tắt thông tin đơn hàng của khách hàng, thông tin hiện thị gồm: mã user, tên user, mã đơn hàng, số đơn hàng
SELECT 
    u.user_id AS 'Mã user',
    u.user_name AS 'Tên user',
    o.order_id AS 'Mã đơn hàng',
    COUNT(o.order_id) AS 'Số đơn hàng'
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.user_name, o.order_id;

-- 2. Liệt kê số lượng các đơn hàng của khách hàng: mã user, tên user, số đơn hàng
SELECT 
    u.user_id AS 'Mã user',
    u.user_name AS 'Tên user',
    COUNT(o.order_id) AS 'Số đơn hàng'
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.user_name;

-- 3. Liệt kê thông tin hoa đơn: mã đơn hàng, số đơn hàng, số sản phẩm
SELECT 
    o.order_id AS 'Mã đơn hàng',
    COUNT(DISTINCT o.order_id) AS 'Số đơn hàng',
    COUNT(od.product_id) AS 'Số sản phẩm'
FROM orders o
LEFT JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_id;

-- 4. Liệt kê thông tin mua hàng của người dùng: tên user, mã đơn hàng, số sản phẩm
SELECT 
    u.user_name AS 'Tên user',
    o.order_id AS 'Mã đơn hàng',
    COUNT(od.product_id) AS 'Số sản phẩm'
FROM users u
JOIN orders o ON u.user_id = o.user_id
LEFT JOIN order_details od ON o.order_id = od.order_id
GROUP BY u.user_name, o.order_id;

-- 5. Liệt kê 7 người dùng có số lượng đơn hàng nhiều nhất, thông tin hiện thị gồm: mã user, tên user, số lượng đơn hàng
SELECT 
    u.user_id AS 'Mã user',
    u.user_name AS 'Tên user',
    COUNT(o.order_id) AS 'Số lượng đơn hàng'
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.user_name
ORDER BY COUNT(o.order_id) DESC
LIMIT 7;

-- 6. Liệt kê 7 người dùng mua sản phẩm có tên: Samsung hoặc Apple trong tên sản phẩm
SELECT 
    u.user_id AS 'Mã user',
    u.user_name AS 'Tên user',
    o.order_id AS 'Mã đơn hàng',
    p.product_name AS 'Tên sản phẩm'
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE p.product_name LIKE '%Samsung%' OR p.product_name LIKE '%Apple%'
LIMIT 7;

-- 7. Liệt kê danh sách mua hàng của user bao gồm giá trị từng món hàng, tổng tiền
SELECT 
    u.user_id AS 'Mã user',
    u.user_name AS 'Tên user',
    o.order_id AS 'Mã đơn hàng',
    p.product_name AS 'Tên sản phẩm',
    p.product_price AS 'Giá trị từng món hàng',
    SUM(p.product_price) AS 'Tổng tiền'
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
GROUP BY u.user_id, u.user_name, o.order_id, p.product_name, p.product_price;

-- 8. Liệt kê danh sách mua hàng của user bao gồm giá trị từng món hàng, tổng tiền. Mỗi user chỉ cho ra 1 đơn hàng có giá trị lớn nhất
WITH RankedOrders AS (
    SELECT 
        u.user_id,
        u.user_name,
        o.order_id,
        SUM(p.product_price) AS total_price,
        ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY SUM(p.product_price) DESC) AS rank
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    GROUP BY u.user_id, u.user_name, o.order_id
)
SELECT 
    u.user_id AS 'Mã user',
    u.user_name AS 'Tên user',
    ro.order_id AS 'Mã đơn hàng',
    p.product_name AS 'Tên sản phẩm',
    p.product_price AS 'Giá trị từng món hàng',
    ro.total_price AS 'Tổng tiền'
FROM RankedOrders ro
JOIN users u ON ro.user_id = u.user_id
JOIN order_details od ON ro.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE ro.rank = 1;

-- 9. Liệt kê danh sách mua hàng của user bao gồm giá trị từng món hàng, tổng tiền, số sản phẩm. Mỗi user chỉ cho ra 1 đơn hàng có giá trị lớn nhất
WITH RankedOrders AS (
    SELECT 
        u.user_id,
        u.user_name,
        o.order_id,
        SUM(p.product_price) AS total_price,
        COUNT(od.product_id) AS product_count,
        ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY SUM(p.product_price) DESC) AS rank
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    GROUP BY u.user_id, u.user_name, o.order_id
)
SELECT 
    u.user_id AS 'Mã user',
    u.user_name AS 'Tên user',
    ro.order_id AS 'Mã đơn hàng',
    p.product_name AS 'Tên sản phẩm',
    p.product_price AS 'Giá trị từng món hàng',
    ro.total_price AS 'Tổng tiền',
    ro.product_count AS 'Số sản phẩm'
FROM RankedOrders ro
JOIN users u ON ro.user_id = u.user_id
JOIN order_details od ON ro.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE ro.rank = 1;

-- 10. Liệt kê danh sách mua hàng của user bao gồm giá trị từng món hàng, tổng tiền, số sản phẩm. Mỗi user chỉ cho ra 1 đơn hàng có số lượng sản phẩm nhiều nhất
WITH RankedOrders AS (
    SELECT 
        u.user_id,
        u.user_name,
        o.order_id,
        SUM(p.product_price) AS total_price,
        COUNT(od.product_id) AS product_count,
        ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY COUNT(od.product_id) DESC) AS rank
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    GROUP BY u.user_id, u.user_name, o.order_id
)
SELECT 
    u.user_id AS 'Mã user',
    u.user_name AS 'Tên user',
    ro.order_id AS 'Mã đơn hàng',
    p.product_name AS 'Tên sản phẩm',
    p.product_price AS 'Giá trị từng món hàng',
    ro.total_price AS 'Tổng tiền',
    ro.product_count AS 'Số sản phẩm'
FROM RankedOrders ro
JOIN users u ON ro.user_id = u.user_id
JOIN order_details od ON ro.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE ro.rank = 1;