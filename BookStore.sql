-- Create the database
CREATE DATABASE BookStore;
USE BookStore;

-- Create tables
-- country
CREATE TABLE country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

-- book_language
CREATE TABLE book_language (
    book_language_id INT AUTO_INCREMENT PRIMARY KEY,
    language_name VARCHAR(50) NOT NULL UNIQUE
);

-- publisher
CREATE TABLE publisher (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL,
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES country(country_id) ON DELETE SET NULL
);

-- book
CREATE TABLE book (
    book_isbn VARCHAR(13) PRIMARY KEY,
    book_name VARCHAR(100) NOT NULL,
    publisher_id INT,
    book_language_id INT,
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    publication_date DATE,
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0), -- Added stock for inventory management
    FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id) ON DELETE SET NULL,
    FOREIGN KEY (book_language_id) REFERENCES book_language(book_language_id) ON DELETE SET NULL
);

-- author
CREATE TABLE author (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- book_author (junction table)
CREATE TABLE book_author (
    book_isbn VARCHAR(13),
    author_id INT,
    PRIMARY KEY (book_isbn, author_id),
    FOREIGN KEY (book_isbn) REFERENCES book(book_isbn) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES author(author_id) ON DELETE CASCADE
);

-- address_status
CREATE TABLE address_status (
    address_status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

-- address
CREATE TABLE address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    street VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES country(country_id) ON DELETE SET NULL
);

-- customer
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20)
);

-- customer_address (junction table)
CREATE TABLE customer_address (
    customer_id INT,
    address_id INT,
    address_status_id INT,
    PRIMARY KEY (customer_id, address_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE CASCADE,
    FOREIGN KEY (address_status_id) REFERENCES address_status(address_status_id) ON DELETE SET NULL
);

-- shipping_method
CREATE TABLE shipping_method (
    shipping_method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL UNIQUE,
    cost DECIMAL(10,2) NOT NULL CHECK (cost >= 0)
);

-- order_status
CREATE TABLE order_status (
    order_status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

-- cust_order (Modified: total_amount is now a regular column)
CREATE TABLE cust_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    shipping_method_id INT,
    address_id INT,
    total_amount DECIMAL(10,2) DEFAULT 0.00 CHECK (total_amount >= 0), -- Changed to a regular column
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE SET NULL,
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_method(shipping_method_id) ON DELETE SET NULL,
    FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE SET NULL
);

-- order_line
CREATE TABLE order_line (
    order_id INT,
    book_isbn VARCHAR(13),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, book_isbn),
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id) ON DELETE CASCADE,
    FOREIGN KEY (book_isbn) REFERENCES book(book_isbn) ON DELETE CASCADE
);

-- order_history
CREATE TABLE order_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    order_status_id INT,
    status_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id) ON DELETE CASCADE,
    FOREIGN KEY (order_status_id) REFERENCES order_status(order_status_id) ON DELETE SET NULL
);

-- Create indexes for performance
CREATE INDEX idx_customer_email ON customer(email);
CREATE INDEX idx_book_name ON book(book_name);
CREATE INDEX idx_order_date ON cust_order(order_date);
CREATE INDEX idx_book_author_book_isbn ON book_author(book_isbn);
CREATE INDEX idx_customer_address_customer_id ON customer_address(customer_id);

-- Set up user groups and roles
-- Admin user with full access
CREATE USER 'BookStore_admin'@'zenith.com' IDENTIFIED BY 'ZenithAdmin123!';
GRANT ALL PRIVILEGES ON bookstore.* TO 'BookStore_admin'@'zenith.com';

-- Read-only user for reporting
CREATE USER 'BookStore_reader'@'zenith.com' IDENTIFIED BY 'ZenithReader456!';
GRANT SELECT ON bookstore.* TO 'BookStore_reader'@'zenith.com';

-- Employee user with limited access (e.g., manage orders, customers)
CREATE USER 'BookStore_employee'@'zenith.com' IDENTIFIED BY 'ZenithEmployee789!';
GRANT SELECT, INSERT, UPDATE ON bookstore.cust_order TO 'BookStore_employee'@'zenith.com';
GRANT SELECT, INSERT, UPDATE ON bookstore.order_line TO 'BookStore_employee'@'zenith.com';
GRANT SELECT, INSERT, UPDATE ON bookstore.customer TO 'BookStore_employee'@'zenith.com';
GRANT SELECT ON bookstore.book TO 'BookStore_employee'@'zenith.com';
GRANT SELECT ON bookstore.shipping_method TO 'BookStore_employee'@'zenith.com';
GRANT SELECT ON bookstore.order_status TO 'BookStore_employee'@'zenith.com';

-- Flush privileges to apply changes
FLUSH PRIVILEGES;

--  Revoke  specific  privileges  from  employee  user 
REVOKE  INSERT  ,  UPDATE  ON  bookstore.cust_order  FROM  'BookStore_employee'@'zenith.com';

-- 1. Independent Tables
-- Country
INSERT INTO country (country_name) VALUES 
('Kenya'), 
('Uganda'), 
('Tanzania'), 
('South Africa'),
('Nigeria'),
('Ghana');

-- Book Language
INSERT INTO book_language (language_name) VALUES 
('English'), 
('Swahili'), 
('French'), 
('German');

-- Address Status
INSERT INTO address_status (status_name) VALUES 
('Current'), 
('Old'), 
('Billing'), 
('Shipping');

-- Shipping Method
INSERT INTO shipping_method (method_name, cost) VALUES 
('Standard', 5.99), 
('Express', 12.99), 
('Overnight', 19.99), 
('International', 25.99);

-- Order Status
INSERT INTO order_status (status_name) VALUES 
('Pending'), 
('Shipped'), 
('Delivered'), 
('Cancelled');

-- Author
INSERT INTO author (first_name, last_name, email) VALUES 
('Ngũgĩ', 'wa Thiong\'o', 'ngugi.wathiongo@gmail.com'),
('Margaret', 'Ogola', 'margaret.ogola@gmail.com'),
('Isaac', 'Asimov', 'isaac.asimov@gmail.com'),
('Binyavanga', 'Wainaina', 'binyavanga.wainaina@gmail.com'),
('Chinua', 'Achebe', 'chinua.achebe@gmail.com'),
('Ayi Kwei', 'Armah', 'ayi.armah@gmail.com');

-- 2. Tables That Depend on Independent Tables
-- Publisher (depends on country)
INSERT INTO publisher (publisher_name, country_id) VALUES 
('East African Educational Publishers', 1),
('Longhorn Publishers', 1),
('Random House', 2),
('Penguin Random House South Africa', 4),
('Farafina Books', 5),
('Sub-Saharan Publishers', 6);

-- Book (depends on publisher and book_language)
INSERT INTO book (book_isbn, book_name, publisher_id, book_language_id, unit_price, publication_date, stock) VALUES 
('9781234567890', 'The River and the Source', 1, 1, 29.99, '2023-01-01', 50),
('9780987654321', 'Kipepeo cha Historia', 2, 2, 35.99, '2022-06-15', 30),
('9781122334455', 'Sci-Fi Adventure', 3, 1, 24.99, '2023-03-10', 20),
('9785432109876', 'A Grain of Wheat', 1, 1, 19.99, '2021-11-05', 40),
('9789876543210', 'Things Fall Apart', 5, 1, 22.99, '2020-05-20', 60),
('9784567891234', 'The Beautyful Ones Are Not Yet Born', 6, 1, 27.99, '2019-08-12', 35);

-- Book Author (depends on book and author)
INSERT INTO book_author (book_isbn, author_id) VALUES 
('9781234567890', 2),
('9780987654321', 4),
('9781122334455', 3),
('9785432109876', 1),
('9789876543210', 5),
('9784567891234', 6);

-- Address (depends on country)
INSERT INTO address (street, city, state, postal_code, country_id) VALUES 
('Kenyatta Avenue', 'Nairobi', 'Nairobi County', '00100', 1),
('Moi Avenue', 'Mombasa', 'Mombasa County', '80100', 1),
('Kampala Road', 'Kampala', NULL, '256', 2),
('Samora Avenue', 'Dar es Salaam', NULL, '11000', 3),
('Adderley Street', 'Cape Town', 'Western Cape', '8000', 4),
('Herbert Macaulay Way', 'Lagos', 'Lagos State', '101241', 5);

-- Customer (no dependencies)
INSERT INTO customer (first_name, last_name, email, phone) VALUES 
('Wanjiku', 'Muthoni', 'wanjiku.muthoni@gmail.com', '+254712345678'),
('Otieno', 'Ochieng', 'otieno.ochieng@gmail.com', '+254723456789'),
('Akinyi', 'Nyambura', 'akinyi.nyambura@gmail.com', '+254734567890'),
('Kamau', 'Njoroge', 'kamau.njoroge@gmail.com', '+254745678901'),
('Njeri', 'Wambui', 'njeri.wambui@gmail.com', '+254756789012'),
('Achieng', 'Atieno', 'achieng.atieno@gmail.com', '+254767890123'),
('Kipchumba', 'Koech', 'kipchumba.koech@gmail.com', '+254778901234'),
('Fatuma', 'Ali', 'fatuma.ali@gmail.com', '+254789012345'),
('Sipho', 'Ndlovu', 'sipho.ndlovu@gmail.com', '+2348034567890'),
('Chukwuma', 'Okeke', 'chukwuma.okeke@gmail.com', '+2348123456789');

-- 3. Tables That Depend on the Above
-- Customer Address (depends on customer, address, and address_status)
INSERT INTO customer_address (customer_id, address_id, address_status_id) VALUES 
(1, 1, 1),
(2, 1, 1),
(3, 1, 1),
(4, 2, 1),
(5, 2, 1),
(6, 2, 1),
(7, 1, 1),
(8, 1, 1),
(9, 4, 1),
(10, 5, 1);

-- Customer Order (depends on customer, shipping_method, and address)
INSERT INTO cust_order (customer_id, order_date, shipping_method_id, address_id) VALUES 
(1, '2023-10-01 10:00:00', 1, 1),
(2, '2023-10-02 12:30:00', 2, 1),
(3, '2023-10-03 15:45:00', 3, 1),
(4, '2023-10-04 09:20:00', 4, 2),
(5, '2023-10-05 11:00:00', 1, 2),
(6, '2023-10-06 14:20:00', 2, 2),
(7, '2023-10-07 08:30:00', 3, 1),
(8, '2023-10-08 16:10:00', 1, 1),
(9, '2023-10-09 09:45:00', 4, 4),
(10, '2023-10-10 13:00:00', 4, 5);

-- 4. Tables That Depend on the Above
-- Order Line (depends on cust_order and book)
INSERT INTO order_line (order_id, book_isbn, quantity, unit_price) VALUES 
(1, '9781234567890', 2, 29.99),
(1, '9780987654321', 1, 35.99),
(2, '9780987654321', 1, 35.99),
(3, '9781122334455', 1, 24.99),
(4, '9785432109876', 1, 19.99),
(5, '9789876543210', 1, 22.99),
(6, '9784567891234', 1, 27.99),
(7, '9781234567890', 1, 29.99),
(8, '9780987654321', 2, 35.99),
(9, '9785432109876', 1, 19.99),
(10, '9789876543210', 2, 22.99);

-- Order History (depends on cust_order and order_status)
INSERT INTO order_history (order_id, order_status_id, status_date) VALUES 
(1, 1, '2023-10-01 10:00:00'),
(1, 2, '2023-10-02 09:00:00'),
(1, 3, '2023-10-05 14:30:00'),
(2, 1, '2023-10-02 12:30:00'),
(3, 1, '2023-10-03 15:45:00'),
(4, 1, '2023-10-04 09:20:00'),
(5, 1, '2023-10-05 11:00:00'),
(5, 2, '2023-10-06 08:00:00'),
(6, 1, '2023-10-06 14:20:00'),
(7, 1, '2023-10-07 08:30:00'),
(7, 2, '2023-10-08 09:00:00'),
(8, 1, '2023-10-08 16:10:00'),
(9, 1, '2023-10-09 09:45:00'),
(10, 1, '2023-10-10 13:00:00'),
(10, 4, '2023-10-11 10:00:00');

-- 1. Get All Books with Their Authors
SELECT b.book_isbn, b.book_name, a.first_name, a.last_name
FROM book b
JOIN book_author ba ON b.book_isbn = ba.book_isbn
JOIN author a ON ba.author_id = a.author_id
ORDER BY b.book_name;

-- 2. Get Customer Orders with Total Cost (Computed Dynamically)
SELECT o.order_id, c.first_name, c.last_name, o.order_date, 
       SUM(ol.quantity * ol.unit_price) AS total_cost
FROM cust_order o
JOIN customer c ON o.customer_id = c.customer_id
JOIN order_line ol ON o.order_id = ol.order_id
GROUP BY o.order_id, c.first_name, c.last_name, o.order_date
ORDER BY o.order_date;

-- 3. Get Order History for a Specific Customer
SELECT c.first_name, c.last_name, o.order_id, os.status_name, oh.status_date
FROM customer c
JOIN cust_order o ON c.customer_id = o.customer_id
JOIN order_history oh ON o.order_id = oh.order_id
JOIN order_status os ON oh.order_status_id = os.order_status_id
WHERE c.customer_id = 1
ORDER BY oh.status_date;

-- 4. Get All Books Published by a Specific Publisher
SELECT b.book_name, b.unit_price, b.publication_date, p.publisher_name
FROM book b
JOIN publisher p ON b.publisher_id = p.publisher_id
WHERE p.publisher_name = 'East African Educational Publishers'
ORDER BY b.publication_date DESC;

-- 5. Get Total Revenue from All Orders
SELECT SUM(ol.quantity * ol.unit_price) AS total_revenue
FROM order_line ol;

-- 6. Get Books That Are Low in Stock
SELECT book_isbn, book_name, stock
FROM book
WHERE stock < 25
ORDER BY stock ASC;

-- 7. Get the Most Popular Book by Total Quantity Sold
SELECT b.book_isbn, b.book_name, SUM(ol.quantity) AS total_sold
FROM book b
JOIN order_line ol ON b.book_isbn = ol.book_isbn
GROUP BY b.book_isbn, b.book_name
ORDER BY total_sold DESC
LIMIT 1;

-- 8. Get All Customers with Their Addresses
SELECT c.first_name, c.last_name, a.street, a.city, a.state, a.postal_code, 
       ct.country_name, ast.status_name
FROM customer c
JOIN customer_address ca ON c.customer_id = ca.customer_id
JOIN address a ON ca.address_id = a.address_id
JOIN country ct ON a.country_id = ct.country_id
JOIN address_status ast ON ca.address_status_id = ast.address_status_id
ORDER BY c.first_name;

-- 9. Get the Total Number of Books per Language
SELECT bl.language_name, COUNT(b.book_isbn) AS book_count
FROM book_language bl
LEFT JOIN book b ON bl.book_language_id = b.book_language_id
GROUP BY bl.language_name
ORDER BY book_count DESC;

-- 10. Get Orders Shipped Using a Specific Shipping Method
SELECT o.order_id, c.first_name, c.last_name, sm.method_name, sm.cost
FROM cust_order o
JOIN customer c ON o.customer_id = c.customer_id
JOIN shipping_method sm ON o.shipping_method_id = sm.shipping_method_id
WHERE sm.method_name = 'Express'
ORDER BY o.order_date;
