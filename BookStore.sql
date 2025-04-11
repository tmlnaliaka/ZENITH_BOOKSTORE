-- Create the database
CREATE DATABASE bookstore;
USE bookstore;

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

-- cust_order
CREATE TABLE cust_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    shipping_method_id INT,
    address_id INT,
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

-- Set up user groups and roles
-- Admin user with full access
CREATE USER 'bookstore_admin'@'localhost' IDENTIFIED BY 'SecurePass123!';
GRANT ALL PRIVILEGES ON bookstore.* TO 'bookstore_admin'@'localhost';

-- Read-only user for reporting
CREATE USER 'bookstore_reader'@'localhost' IDENTIFIED BY 'ReadOnly456!';
GRANT SELECT ON bookstore.* TO 'bookstore_reader'@'localhost';

-- Employee user with limited access (e.g., manage orders, customers)
CREATE USER 'bookstore_employee'@'localhost' IDENTIFIED BY 'Employee789!';
GRANT SELECT, INSERT, UPDATE ON bookstore.cust_order TO 'bookstore_employee'@'localhost';
GRANT SELECT, INSERT, UPDATE ON bookstore.order_line TO 'bookstore_employee'@'localhost';
GRANT SELECT, INSERT, UPDATE ON bookstore.customer TO 'bookstore_employee'@'localhost';
GRANT SELECT ON bookstore.book TO 'bookstore_employee'@'localhost';
GRANT SELECT ON bookstore.shipping_method TO 'bookstore_employee'@'localhost';
GRANT SELECT ON bookstore.order_status TO 'bookstore_employee'@'localhost';

-- Flush privileges to apply changes
FLUSH PRIVILEGES;

-- Sample data for testing
INSERT INTO country (country_name) VALUES ('USA'), ('Canada'), ('UK');
INSERT INTO book_language (language_name) VALUES ('English'), ('Spanish'), ('French');
INSERT INTO publisher (publisher_name, country_id) VALUES ('Penguin Books', 1), ('HarperCollins', 1);
INSERT INTO book (book_isbn, book_name, publisher_id, book_language_id, unit_price, publication_date)
VALUES ('9781234567890', 'Sample Book', 1, 1, 29.99, '2023-01-01');
INSERT INTO author (first_name, last_name, email) VALUES ('John', 'Doe', 'john.doe@example.com');
INSERT INTO book_author (book_isbn, author_id) VALUES ('9781234567890', 1);
INSERT INTO address_status (status_name) VALUES ('Current'), ('Old');
INSERT INTO address (street, city, state, postal_code, country_id)
VALUES ('123 Main St', 'New York', 'NY', '10001', 1);
INSERT INTO customer (first_name, last_name, email, phone)
VALUES ('Jane', 'Smith', 'jane.smith@example.com', '555-1234');
INSERT INTO customer_address (customer_id, address_id, address_status_id) VALUES (1, 1, 1);
INSERT INTO shipping_method (method_name, cost) VALUES ('Standard', 5.99), ('Express', 12.99);
INSERT INTO order_status (status_name) VALUES ('Pending'), ('Shipped'), ('Delivered');
INSERT INTO cust_order (customer_id, order_date, shipping_method_id, address_id)
VALUES (1, NOW(), 1, 1);
INSERT INTO order_line (order_id, book_isbn, quantity, unit_price)
VALUES (1, '9781234567890', 2, 29.99);
INSERT INTO order_history (order_id, order_status_id, status_date)
VALUES (1, 1, NOW());

-- Sample queries to test the database
-- 1. Get all books with their authors
SELECT b.book_name, a.first_name, a.last_name
FROM book b
JOIN book_author ba ON b.book_isbn = ba.book_isbn
JOIN author a ON ba.author_id = a.author_id;

-- 2. Get customer orders with total cost
SELECT o.order_id, c.first_name, c.last_name, SUM(ol.quantity * ol.unit_price) AS total_cost
FROM cust_order o
JOIN customer c ON o.customer_id = c.customer_id
JOIN order_line ol ON o.order_id = ol.order_id
GROUP BY o.order_id, c.first_name, c.last_name;

-- 3. Get order history for a specific order
SELECT o.order_id, os.status_name, oh.status_date
FROM order_history oh
JOIN order_status os ON oh.order_status_id = os.order_status_id
JOIN cust_order o ON oh.order_id = o.order_id
WHERE o.order_id = 1;