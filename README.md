# Zenith BookStore Database

## MEMBERS
2. Jane Mutegi - janealxvassistant@gmail.com
1. Sophy Naliaka - sofiawaf05@gmail.com
2. Rodney Aminga - greyheartv@gmail.com

## Overview
The **BookStore** database is a MySQL relational database designed for managing an online bookstore with a focus on an African (primarily Kenyan) context. It supports inventory management, customer management, order processing, and order tracking. The database includes sample data reflecting African based names, addresses, and culturally relevant books.

### Key Features
- **Tables**: 14 tables covering books, authors, customers, orders, addresses, and more.
- **Sample Data**: Includes 10 customers, 6 books, 6 addresses, and 10 orders, with a Kenyan/African focus.
- **Relationships**: Enforced with foreign key constraints for data integrity.
- **Indexes**: Added for performance optimization on frequently queried columns.
- **User Roles**: Admin, read-only, and employee users with appropriate privileges.
- **Sample Queries**: 10 queries demonstrating common use cases.

## Database Structure

### Tables and Relationships
- **country**: Stores countries (e.g., Kenya, Uganda). Referenced by `publisher` and `address`.
- **book_language**: Stores languages (e.g., English, Swahili). Referenced by `book`.
- **publisher**: Stores publishers (e.g., East African Educational Publishers). References `country`.
- **book**: Stores book details (ISBN, name, price, stock). References `publisher` and `book_language`.
- **author**: Stores author details (name, email).
- **book_author**: Junction table linking books and authors.
- **address_status**: Stores address statuses (e.g., Current, Billing).
- **address**: Stores customer addresses (e.g., Kenyatta Avenue, Nairobi). References `country`.
- **customer**: Stores customer details (e.g., Wanjiku Muthoni).
- **customer_address**: Junction table linking customers to addresses. References `customer`, `address`, and `address_status`.
- **shipping_method**: Stores shipping methods (e.g., Standard, Express).
- **order_status**: Stores order statuses (e.g., Pending, Shipped).
- **cust_order**: Stores customer orders. References `customer`, `shipping_method`, and `address`.
- **order_line**: Stores order items (books ordered). References `cust_order` and `book`.
- **order_history**: Stores order status history. References `cust_order` and `order_status`.

### Schema Details
- **Primary Keys**: Used to uniquely identify records (e.g., `book_isbn`, `customer_id`).
- **Foreign Keys**: Enforce referential integrity (e.g., `ON DELETE CASCADE` for `book_author`).
- **Indexes**: Added on frequently queried columns (e.g., `customer.email`, `book.book_name`).
- **Constraints**: Checks for non-negative values (e.g., `unit_price >= 0`).

### Prerequisites
- MySQL server 
- MySQL client (MySQL Workbench)

There is a word document that explains further the details of the project (**Zenith Group Database Project**)

We also have a pictorial represention of the tables with their relationships in the drrawio file (**BookStore.drawio**)

**Just clone the repository to have all these documents to review. We would love to hear your feedack!**

