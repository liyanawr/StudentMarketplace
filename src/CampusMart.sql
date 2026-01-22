-- =========================================================
-- 1. REFRESH SCHEMA (DROP IN CORRECT ORDER)
-- =========================================================
DROP TABLE ratings;
DROP TABLE orders;
DROP TABLE cart;
DROP TABLE items;
DROP TABLE categories;
DROP TABLE users;

-- =========================================================
-- 2. USERS
-- =========================================================
CREATE TABLE users (
    user_id           INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
    identification_no VARCHAR(20) NOT NULL UNIQUE,
    id_type           VARCHAR(15), 
    name              VARCHAR(100) NOT NULL, 
    password          VARCHAR(100) NOT NULL,
    phone_number      VARCHAR(20), 
    is_seller         BOOLEAN DEFAULT FALSE, 
    payment_qr        VARCHAR(255),
    PRIMARY KEY (user_id)
);

-- =========================================================
-- 3. CATEGORIES
-- =========================================================
CREATE TABLE categories (
    category_id   INT NOT NULL PRIMARY KEY, 
    category_name VARCHAR(50) NOT NULL
);

INSERT INTO categories (category_id, category_name) VALUES 
(1, 'Textbooks'), 
(2, 'Electronics'), 
(3, 'Clothing'), 
(4, 'Food'), 
(5, 'Others');

-- =========================================================
-- 4. ITEMS
-- =========================================================
CREATE TABLE items (
    item_id     INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
    item_name   VARCHAR(100) NOT NULL, 
    description VARCHAR(500), 
    price       DOUBLE NOT NULL,                 -- unit price
    status      VARCHAR(20) DEFAULT 'Available', 
    item_photo  VARCHAR(255), 
    date_posted DATE DEFAULT CURRENT_DATE, 
    seller_id   INT NOT NULL, 
    category_id INT, 
    qty         INT DEFAULT 1,
    PRIMARY KEY (item_id), 
    FOREIGN KEY (seller_id) REFERENCES users(user_id), 
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- =========================================================
-- 5. CART
-- =========================================================
CREATE TABLE cart (
    cart_id INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
    user_id INT NOT NULL, 
    item_id INT NOT NULL, 
    qty     INT DEFAULT 1,
    PRIMARY KEY (cart_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id), 
    FOREIGN KEY (item_id) REFERENCES items(item_id)
);

-- =========================================================
-- 6. ORDERS  ✅ FIXED
--   - price is DOUBLE (subtotal)
--   - qty is REQUIRED
-- =========================================================
CREATE TABLE orders (
    order_id       INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
    buyer_id       INT NOT NULL,
    item_id        INT NOT NULL,
    qty            INT NOT NULL,
    price          DOUBLE NOT NULL,               -- SUBTOTAL (unit × qty)
    seller_id      INT NOT NULL,
    order_date     DATE DEFAULT CURRENT_DATE,
    status         VARCHAR(20) DEFAULT 'Pending',
    payment_method VARCHAR(20)
        CHECK (payment_method IN ('COD', 'QR')),
    PRIMARY KEY (order_id),
    FOREIGN KEY (buyer_id) REFERENCES users(user_id),
    FOREIGN KEY (item_id) REFERENCES items(item_id),
    FOREIGN KEY (seller_id) REFERENCES users(user_id)
);

-- =========================================================
-- 7. RATINGS
-- =========================================================
CREATE TABLE ratings (
    rating_id INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
    order_id  INT NOT NULL UNIQUE, 
    score     INT NOT NULL, 
    comment   VARCHAR(500), 
    PRIMARY KEY (rating_id), 
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- =========================================================
-- 8. INSERT USERS (Password: 123)
-- =========================================================
INSERT INTO users (identification_no, id_type, name, password, phone_number, is_seller, payment_qr) VALUES 
('2023000111',   'STUDENT', 'Nurul Afifah',     '123', '0123456789', TRUE,  'qr_afifah.png'),
('2023000222',   'STUDENT', 'Nur Tarnia',       '123', '0198887776', TRUE,  'qr_tarnia.png'),
('990101141122', 'PUBLIC',  'Umairah Suhana',   '123', '0112233445', TRUE,  'qr_umairah.png'),
('2023000444',   'STUDENT', 'Afrina Rasyiqah',  '123', '0171122334', TRUE,  NULL),
('2023000555',   'STUDENT', 'Haziq Hakim',      '123', '0133445566', FALSE, NULL),
('950102103344', 'PUBLIC',  'Farhana Yasmin',   '123', '0188776655', FALSE, NULL),
('2023000777',   'STUDENT', 'Adam Harith',      '123', '0100998877', FALSE, NULL),
('950505105566', 'PUBLIC',  'Nadiratul Liyana', '123', '0165554433', FALSE, NULL);

-- =========================================================
-- 9. INSERT ITEMS
-- =========================================================
INSERT INTO items (item_name, description, price, status, item_photo, seller_id, category_id, qty) VALUES 
('Java Programming 10th Ed',    'Clean pages. Best for CSC584.',               45.0,  'Available', 'java.jpg',      1, 1, 1),
('Logitech Mouse M650',         'Wireless, silent clicks.',                   120.0, 'Available', 'mouse.jpg',     2, 2, 1),
('Baju Kurung Silk Pink',       'Size S. Worn once.',                          65.0,  'Available', 'kurung.jpg',    3, 3, 1),
('Calculus Notes',              'Handwritten, very complete.',                15.0,  'Available', 'notes.jpg',     4, 1, 1),
('Lab Coat Size M',             'Used only 1 semester.',                      30.0,  'Available', 'coat.jpg',      4, 3, 1),
('Premium Choco Chip Cookies',  'Freshly baked, study snack.',                15.0,  'Available', 'cookies.jpg',   1, 4, 10),
('Faber-Castell Pencil Set',    'Needle Grip 0.5mm set.',                     12.0,  'Available', 'pencil.jpg',    4, 5, 5),
('University Physics 11th Ed',  'Young & Freedman guide.',                    55.0,  'Available', 'physics.jpg',   2, 1, 1),
('Casio Scientific Calculator', 'Model FC-991MS Engineering.',                65.0,  'Available', 'calc.jpg',      2, 2, 1),
('Jisulife Handheld Fan',       'Portable 3-speed USB fan.',                  35.0,  'Available', 'fan.jpg',       3, 2, 2),
('3-Way Extension Plug',        'LWD Surge Protector 2m.',                    25.0,  'Available', 'plug.jpg',      4, 2, 1),
('Magnetic Tablet Case',        'Slim folio, auto-sleep.',                    20.0,  'Available', 'case.jpg',      4, 2, 1),
('Brown Suede Sneakers',        'Size 42. Classic look.',                     85.0,  'Available', 'shoes.jpg',     1, 3, 1),
('Foldable Laptop Bed Desk',    'Cup and tablet holder.',                     30.0,  'Available', 'desk.jpg',      3, 5, 1),
('Classic Denim Jacket',        'Size M, unisex. Premium.',                   50.0,  'Available', 'jacket.jpg',    1, 3, 1),
('Tiramisu',                    'Fresh homemade Italian dessert.',            15.0,  'Available', 'tiramisu.jpg',  1, 4, 4),
('Brownies',                    'Rich and fudgy chocolate brownies.',         12.0,  'Available', 'brownies.jpg',  1, 4, 5);

-- =========================================================
-- 10. CART (TEST DATA)
-- =========================================================
INSERT INTO cart (user_id, item_id, qty) VALUES 
(5, 16, 2), 
(5, 17, 3),
(5, 7, 4);

-- =========================================================
-- 11. ORDERS + RATINGS (TEST DATA) 
-- =========================================================
INSERT INTO orders (buyer_id, item_id, qty, price, seller_id, payment_method, status)
VALUES (8, 1, 1, 45.0, 1, 'QR', 'Completed');

INSERT INTO ratings (order_id, score, comment)
VALUES (1, 5, 'Fast delivery, book looks brand new!');

INSERT INTO orders (buyer_id, item_id, qty, price, seller_id, payment_method, status)
VALUES (5, 2, 1, 120.0, 2, 'QR', 'Pending');

INSERT INTO orders (buyer_id, item_id, qty, price, seller_id, payment_method, status)
VALUES (6, 3, 1, 65.0, 3, 'QR', 'Completed');

INSERT INTO ratings (order_id, score, comment)
VALUES (3, 4, 'Baju cantik sangat, puas hati!');
