-- БЛОК А

-- Задание 1:
SELECT model AS "модель", maker AS "производитель", type AS "тип" FROM product;
-- Задание 2:
SELECT product_id, price FROM laptop;

-- но вообще более правильно будет написать вот так:
SELECT p.model, l.price
FROM product AS p 
JOIN laptop AS l ON l.product_id = p.id;
-- Задание 3:
SELECT * FROM product WHERE maker = 'Alfa';
-- Задание 4:
SELECT product_id FROM pc WHERE speed >= 3000;

-- более правильное решение
SELECT p.model 
FROM    product AS  p
JOIN    pc      AS  c   ON c.product_id = p.id
WHERE c.speed >= 3000;
-- Задание 5:
SELECT * FROM printer WHERE price < 10000 ORDER BY price ASC;
-- Задание 6:
SELECT * FROM customer WHERE created_at >= '2026-01-01' AND created_at <= '2027-01-01';
-- Задание 7:
SELECT product_id, price FROM laptop ORDER BY price ASC LIMIT 5;

-- БЛОК B

SELECT * FROM product WHERE model LIKE 'PR-%';
SELECT screen FROM laptop WHERE screen IN (14,16);
SELECT * FROM pc WHERE price BETWEEN 45000 AND 90000;
SELECT * FROM customer WHERE phone IS NULL;
SELECT * FROM product WHERE quantity = 0 AND type IN ('PC', 'Laptop');
SELECT id FROM orders 
WHERE status IN ('new', 'paid') 
AND created_at >= '2026-01-01' 
AND created_at < '2027-01-01';
SELECT model, type FROM product WHERE NOT is_active;

-- БЛОК С

-- ЗАДАНИЕ 1

SELECT p.model, l.price, ROUND(l.price * 0.85, 2) AS "цена со скидкой"
FROM product AS p
JOIN laptop AS l ON l.product_id = p.id;
-- ЗАДАНИЕ 2
SELECT maker || '-' || model FROM product;
-- ЗАДАНИЕ 3
SELECT full_name, COALESCE(phone, 'телефон не указан') FROM customer;
-- ЗАДАНИЕ 4
SELECT id, to_char(created_at, 'DD.MM.YYYY') FROM orders;
-- ЗАДАНИЕ 5
SELECT product_id, price, 
    CASE
        WHEN price is NULL THEN 'цена не указана'
        WHEN price < 60000 THEN 'бюджетненько'
        WHEN price < 120000 THEN 'средненько'
        ELSE 'премиум'
    END AS segment
FROM laptop
ORDER BY price;
-- ЗАДАНИЕ 6
SELECT model,
       created_at::date,
       (current_date - created_at::date) AS days_in_catalog
FROM product
ORDER BY days_in_catalog DESC;

-- БЛОК D

-- ЗАДАНИЕ 1
SELECT DISTINCT maker FROM product;
SELECT DISTINCT maker, type FROM product ORDER BY maker, type;

SELECT DISTINCT a.city FROM
address AS a 
JOIN orders AS o ON o.address_id = a.id;



SELECT * FROM product ORDER BY model ASC LIMIT 5 OFFSET 2;