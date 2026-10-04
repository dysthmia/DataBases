-- Блок A
-- 1
SELECT p.model, p.maker, c.name AS category
FROM product AS p
JOIN category AS c ON c.id = p.category_id;
-- 2
SELECT 
p.model, 
p.maker, 
c.name AS category, 
pc.speed, 
pc.ram, 
pc.hd, 
pc.price
FROM product AS p
JOIN category AS c ON c.id = p.category_id
JOIN pc ON pc.product_id = p.id;
-- 3
SELECT
p.model, 
p.maker, 
c.name AS category, 
l.speed, 
l.ram, 
l.hd, 
l.screen,
l.price
FROM product AS p
JOIN category AS c ON c.id = p.category_id
JOIN laptop AS l ON l.product_id = p.id
WHERE l.screen >= 14 AND l.price > 70000
ORDER BY price ASC;
-- 4
SELECT 
p.model, 
p.maker,
CASE 
    WHEN pr.is_color = TRUE 
        THEN 'цветной' 
    ELSE 'черно-белый' 
END AS color_type, 
pr.print_type,
pr.price
FROM product AS p 
JOIN printer AS pr ON pr.product_id = p.id
ORDER BY price ASC;
-- 5
SELECT
    model,
    type, 
    COALESCE(CAST(price AS VARCHAR), 'не указана') AS price
    FROM (
        SELECT p.model, p.type, l.price
        FROM product AS p
        JOIN laptop AS l ON l.product_id = p.id

        UNION ALL

        SELECT p.model, p.type, pr.price
        FROM product AS p
        JOIN printer AS pr ON pr.product_id = p.id

        UNION ALL

        SELECT p.model, p.type, pc.price
        FROM product AS p
        JOIN pc ON pc.product_id = p.id
    )  
ORDER BY price ASC;
-- 6
SELECT 
    p.model,
    l.price,
    p.quantity
FROM product p
JOIN category c ON p.category_id = c.id
JOIN laptop l ON p.id = l.product_id
WHERE c.name = 'Игровые ноутбуки'
ORDER BY l.price DESC;

-- Блок B
-- 7
SELECT 
    o.id            AS order_id,
    o.status,
    o.created_at,
    o.comment,
    c.full_name     AS customer_name,
    c.email         AS customer_email
FROM orders AS o
JOIN customer AS c ON o.customer_id = c.id
ORDER BY o.created_at DESC;
-- 8
SELECT 
    p.model                         AS model,
    oi.quantity                     AS quantity,
    oi.price                        AS price,
    (oi.quantity * oi.price)        AS all_price
FROM order_item oi
JOIN product p ON p.id = oi.product_id
WHERE oi.order_id = 9
ORDER BY p.model;
-- 9
SELECT 
    o.id AS order_id,
    a.city,
    a.street,
    a.building
FROM orders AS o
JOIN address AS a ON o.address_id = a.id;
-- 10
SELECT 
    c.email AS customer_email,
    o.id AS order_id,
    p.model AS product_model
FROM customer AS c
JOIN orders AS o ON c.id = o.customer_id
JOIN order_item AS oi ON o.id = oi.order_id
JOIN product AS p ON oi.product_id = p.id
WHERE c.email = 'ivanov@example.com';
-- 11
SELECT 
    DISTINCT o.id,
    p.maker
FROM orders AS o
JOIN order_item AS oi ON oi.order_id = o.id
JOIN product AS p  ON p.id = oi.product_id
WHERE p.maker = 'Alfa'
ORDER BY o.id;
-- 12
SELECT o.id, o.created_at, c.full_name, a.city
FROM orders o
JOIN customer c ON c.id = o.customer_id
JOIN address a  ON a.id = o.address_id
WHERE o.created_at >= '2026-03-01'
  AND o.created_at <  '2026-04-01'
ORDER BY o.created_at;
-- 13
SELECT DISTINCT p.model, p.maker, p.type
FROM address a
JOIN orders o      ON o.address_id = a.id
JOIN order_item oi ON oi.order_id = o.id
JOIN product p     ON p.id = oi.product_id
WHERE a.city = 'Москва'
ORDER BY p.model;

-- Блок C
-- 14
SELECT child.name AS category,
       COALESCE(parent.name, '— корень —') AS parent_category
FROM category child LEFT JOIN category parent -- мы используем одну таблицу дважды
ON parent.id = child.parent_id                -- ищем и соединяем id
ORDER BY parent.name NULLS FIRST, child.name; -- сортировка по имени родителя
-- 15
SELECT 
    c3.name AS category,
    c2.name AS parent,
    c1.name AS grandparent
FROM category c3
JOIN category c2 ON c2.id = c3.parent_id
JOIN category c1 ON c1.id = c2.parent_id
ORDER BY c1.name, c2.name, c3.name;

-- Блок D
-- 17. Города клиентов, куда не доставляли
SELECT city FROM address
EXCEPT
SELECT a.city FROM address a JOIN orders o ON o.address_id = a.id;


-- 18. Производители, выпускающие и ПК, и принтеры
SELECT maker FROM product WHERE type = 'PC'
INTERSECT
SELECT maker FROM product WHERE type = 'Printer'
ORDER BY 1;


-- 19. Производители с ноутбуками, но без ПК (EXCEPT)
SELECT maker FROM product WHERE type = 'Laptop'
EXCEPT
SELECT maker FROM product WHERE type = 'PC'
ORDER BY 1;


-- 20. То же через LEFT JOIN ... IS NULL
SELECT DISTINCT lap.maker
FROM product lap
LEFT JOIN product pcs
       ON pcs.maker = lap.maker AND pcs.type = 'PC'
WHERE lap.type = 'Laptop'
  AND pcs.id IS NULL
ORDER BY 1;