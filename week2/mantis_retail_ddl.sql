--DDL for OLTP Schema:
CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(255) UNIQUE NOT NULL,
    phone           VARCHAR(30),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stores (
    store_id        SERIAL PRIMARY KEY,
    store_name      VARCHAR(150) NOT NULL,
    location        VARCHAR(255),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(200) NOT NULL,
    description     TEXT,
    price           NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL,
    store_id        INT NOT NULL,
    order_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status    VARCHAR(30) DEFAULT 'PENDING',
    total_amount    NUMERIC(12,2) DEFAULT 0,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),

    CONSTRAINT fk_orders_store
        FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

CREATE TABLE order_items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INT NOT NULL,
    product_id      INT NOT NULL,
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    line_total      NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,

    CONSTRAINT fk_items_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,

    CONSTRAINT fk_items_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_store ON orders(store_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

--DDL for OLAP Star Schema:
--Dim_customer table:
CREATE TABLE dim_customer (
    customer_key    SERIAL PRIMARY KEY,
    customer_id     INT,
    full_name       VARCHAR(200),
    email           VARCHAR(255),
    phone           VARCHAR(30)
);
--dim_product table:
CREATE TABLE dim_product (
    product_key     SERIAL PRIMARY KEY,
    product_id      INT, 
    product_name    VARCHAR(200),
    description     TEXT,
    price           NUMERIC(10,2)
);

--dim_store table:
CREATE TABLE dim_store (
    store_key       SERIAL PRIMARY KEY,
    store_id        INT,  
    store_name      VARCHAR(150),
    location        VARCHAR(255)
);


--dim_date table:
CREATE TABLE dim_date (
    date_key        INT PRIMARY KEY,   
    full_date       DATE NOT NULL,
    day             INT,
    month           INT,
    month_name      VARCHAR(20),
    quarter         INT,
    year            INT,
    week_of_year    INT,
    is_weekend      BOOLEAN
);

--fact_sales table:
CREATE TABLE fact_sales (
    sales_key       BIGSERIAL PRIMARY KEY,
    date_key        INT NOT NULL,
    customer_key    INT NOT NULL,
    product_key     INT NOT NULL,
    store_key       INT NOT NULL,
    quantity        INT NOT NULL,
    unit_price      NUMERIC(10,2) NOT NULL,
    total_sales     NUMERIC(12,2) NOT NULL,
    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    CONSTRAINT fk_fact_customer
        FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    CONSTRAINT fk_fact_product
        FOREIGN KEY (product_key) REFERENCES dim_product(product_key),

    CONSTRAINT fk_fact_store
        FOREIGN KEY (store_key) REFERENCES dim_store(store_key)
   );
