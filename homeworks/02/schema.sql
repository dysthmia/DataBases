-- =====================================================================
--  Интернет-магазин компьютерной техники «Мегабайт»
--
--  Запуск с нуля:
--      psql -h localhost -U student -d shop -f schema.sql
--
--  Скрипт идемпотентен: его можно выполнять сколько угодно раз,
--  каждый раз получая чистую схему. Данные при этом теряются —
--  наполнение хранится отдельно
--
--  Позже схема будет отрефакторена до версии 2:
--    - производитель переедет в справочник manufacturer
--    - цена переедет из pc/laptop/printer в product
-- =====================================================================

BEGIN;

-- Порядок удаления обратен порядку создания: сначала зависимые таблицы.
-- CASCADE здесь допустим только потому, что это учебный скрипт полного пересоздания.
DROP TABLE IF EXISTS order_item, orders, printer, laptop, pc,
                     product, category, address, customer CASCADE;


-- ---------------------------------------------------------------------
-- Клиенты
-- ---------------------------------------------------------------------
CREATE TABLE customer (
    id         int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email      varchar(255) NOT NULL,
    full_name  varchar(200) NOT NULL,
    phone      varchar(20),                     -- необязателен по ТЗ
    created_at timestamptz  NOT NULL DEFAULT now(),

    -- email — естественный ключ: уникален, но первичным ключом не является
    CONSTRAINT uq_customer_email UNIQUE (email),
    -- примитивная проверка формата; серьёзная валидация — задача приложения
    CONSTRAINT chk_customer_email CHECK (email LIKE '%_@_%.__%'),
    CONSTRAINT chk_customer_name  CHECK (length(trim(full_name)) > 0)
);

COMMENT ON TABLE  customer            IS 'Покупатели магазина';
COMMENT ON COLUMN customer.email      IS 'Логин на сайте, уникален';
COMMENT ON COLUMN customer.created_at IS 'Момент регистрации (UTC внутри, timestamptz)';


-- ---------------------------------------------------------------------
-- Адреса доставки: у клиента их может быть несколько
-- ---------------------------------------------------------------------
CREATE TABLE address (
    id          int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id int          NOT NULL,
    city        varchar(100) NOT NULL,
    street      varchar(150) NOT NULL,
    building    varchar(20)  NOT NULL,
    flat        varchar(20),
    postal_code varchar(10),

    -- адрес не имеет смысла без клиента => CASCADE
    CONSTRAINT fk_address_customer
        FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE
);

COMMENT ON TABLE address IS 'Адреса доставки; удаляются вместе с клиентом';


-- ---------------------------------------------------------------------
-- Дерево категорий произвольной глубины
-- ---------------------------------------------------------------------
CREATE TABLE category (
    id        int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name      varchar(100) NOT NULL,
    parent_id int,

    -- удаление родителя поднимает подкатегории в корень, а не стирает их
    CONSTRAINT fk_category_parent
        FOREIGN KEY (parent_id) REFERENCES category(id) ON DELETE SET NULL,

    -- NULLS NOT DISTINCT (PostgreSQL 15+): без него две корневые категории
    -- с одинаковым именем прошли бы, так как NULL <> NULL
    CONSTRAINT uq_category_name_in_parent UNIQUE NULLS NOT DISTINCT (parent_id, name),

    CONSTRAINT chk_category_name CHECK (length(trim(name)) > 0)
);

COMMENT ON COLUMN category.parent_id IS 'NULL у корневых категорий';


-- ---------------------------------------------------------------------
-- Каталог: общая часть товара
-- ---------------------------------------------------------------------
CREATE TABLE product (
    id          int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    model       varchar(50)  NOT NULL,
    maker       varchar(50)  NOT NULL,   -- гл. 7: переедет в справочник manufacturer
    type        varchar(20)  NOT NULL,
    category_id int          NOT NULL,
    quantity    int          NOT NULL DEFAULT 0,
    is_active   boolean      NOT NULL DEFAULT true,
    created_at  timestamptz  NOT NULL DEFAULT now(),

    CONSTRAINT uq_product_model UNIQUE (model),

    -- категорию с товарами удалить нельзя
    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE RESTRICT,

    CONSTRAINT chk_product_type     CHECK (type IN ('PC', 'Laptop', 'Printer')),
    CONSTRAINT chk_product_quantity CHECK (quantity >= 0),
    CONSTRAINT chk_product_model    CHECK (length(trim(model)) > 0)
);

COMMENT ON TABLE  product           IS 'Каталог: общие атрибуты всех видов техники';
COMMENT ON COLUMN product.type      IS 'Определяет, в какой дочерней таблице лежат характеристики';
COMMENT ON COLUMN product.quantity  IS 'Остаток на складе; не может быть отрицательным';
COMMENT ON COLUMN product.is_active IS 'Снятые с продажи не удаляем — на них ссылается история заказов';


-- ---------------------------------------------------------------------
-- Характеристики по видам техники (таблица на подтип, связь 1:1)
--
-- product_id одновременно первичный и внешний ключ:
--   PRIMARY KEY  -> у товара не больше одной строки характеристик
--   REFERENCES   -> характеристики не существуют без товара
--   ON DELETE CASCADE -> удалили товар, удалились и характеристики
-- ---------------------------------------------------------------------
CREATE TABLE pc (
    product_id int PRIMARY KEY REFERENCES product(id) ON DELETE CASCADE,
    speed      smallint      NOT NULL,   -- МГц
    ram        int           NOT NULL,   -- Мб
    hd         real          NOT NULL,   -- Гб
    cd         varchar(10)   NOT NULL,   -- например '24x'
    price      numeric(10,2),            -- NULL = цена ещё не назначена

    CONSTRAINT chk_pc_speed CHECK (speed > 0),
    CONSTRAINT chk_pc_ram   CHECK (ram   > 0),
    CONSTRAINT chk_pc_hd    CHECK (hd    > 0),
    CONSTRAINT chk_pc_price CHECK (price IS NULL OR price > 0)
);

CREATE TABLE laptop (
    product_id int PRIMARY KEY REFERENCES product(id) ON DELETE CASCADE,
    speed      smallint      NOT NULL,
    ram        int           NOT NULL,
    hd         real          NOT NULL,
    screen     smallint      NOT NULL,   -- диагональ, дюймы
    price      numeric(10,2),

    CONSTRAINT chk_laptop_speed  CHECK (speed  > 0),
    CONSTRAINT chk_laptop_ram    CHECK (ram    > 0),
    CONSTRAINT chk_laptop_hd     CHECK (hd     > 0),
    CONSTRAINT chk_laptop_screen CHECK (screen BETWEEN 7 AND 30),
    CONSTRAINT chk_laptop_price  CHECK (price IS NULL OR price > 0)
);

CREATE TABLE printer (
    product_id int PRIMARY KEY REFERENCES product(id) ON DELETE CASCADE,
    is_color   boolean       NOT NULL,
    print_type varchar(10)   NOT NULL,
    price      numeric(10,2) NOT NULL,   -- по ТЗ у принтера цена обязательна

    CONSTRAINT chk_printer_type  CHECK (print_type IN ('Laser', 'Jet', 'Matrix')),
    CONSTRAINT chk_printer_price CHECK (price > 0)
);


-- ---------------------------------------------------------------------
-- Заказы
--   Имя во множественном числе не случайно: order — зарезервированное слово SQL
--   (ORDER BY). Таблицу можно назвать "order", но тогда кавычки понадобятся всюду.
-- ---------------------------------------------------------------------
CREATE TABLE orders (
    id          int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id int          NOT NULL,
    address_id  int          NOT NULL,
    status      varchar(20)  NOT NULL DEFAULT 'new',
    created_at  timestamptz  NOT NULL DEFAULT now(),
    comment     text,

    -- клиента с заказами удалять нельзя: заказ — финансовый документ
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE RESTRICT,
    CONSTRAINT fk_orders_address
        FOREIGN KEY (address_id)  REFERENCES address(id)  ON DELETE RESTRICT,

    CONSTRAINT chk_orders_status CHECK (
        status IN ('new', 'paid', 'shipped', 'delivered', 'cancelled')
    )

    -- Требование ТЗ «дата заказа не может быть в будущем» ограничением CHECK
    -- не выражается: PostgreSQL требует, чтобы функции в CHECK были IMMUTABLE,
    -- а now() возвращает разное значение при каждом вызове. Попытка написать
    --     CHECK (created_at <= now())
    -- завершится ошибкой:
    --     ERROR: functions in check constraint must be marked IMMUTABLE
    -- Причина: ограничение обязано выполняться всегда, а не только в момент
    -- вставки — иначе после восстановления из дампа данные оказались бы
    -- невалидными. Это правило реализуется триггером (глава 10).
);

COMMENT ON COLUMN orders.status IS 'new -> paid -> shipped -> delivered; cancelled с любой стадии до отправки';


-- ---------------------------------------------------------------------
-- Позиции заказа: связующая таблица M:N с собственными атрибутами
-- ---------------------------------------------------------------------
CREATE TABLE order_item (
    order_id   int           NOT NULL,
    product_id int           NOT NULL,
    quantity   int           NOT NULL,
    price      numeric(10,2) NOT NULL,   -- цена НА МОМЕНТ ПОКУПКИ, не ссылка на текущую

    -- составной естественный ключ: товар не может встречаться в заказе дважды
    CONSTRAINT pk_order_item PRIMARY KEY (order_id, product_id),

    -- позиция не существует без заказа
    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    -- товар, который когда-то продавался, удалять нельзя
    CONSTRAINT fk_order_item_product
        FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE RESTRICT,

    CONSTRAINT chk_order_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_item_price    CHECK (price >= 0)
);

COMMENT ON COLUMN order_item.price IS
    'Зафиксированная цена сделки. Изменение прайса не должно менять сумму старого заказа';

COMMIT;


-- ---------------------------------------------------------------------
-- Проверка: 9 таблиц
-- ---------------------------------------------------------------------
-- \dt
-- SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';
