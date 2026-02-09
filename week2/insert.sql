INSERT INTO dim_date
(date_key, full_date, day, month, month_name, quarter, year, week_of_year, is_weekend)
VALUES
(20260101, '2026-01-01', 1, 1, 'January', 1, 2026, 1, FALSE),
(20260102, '2026-01-02', 2, 1, 'January', 1, 2026, 1, FALSE),
(20260103, '2026-01-03', 3, 1, 'January', 1, 2026, 1, TRUE),
(20260201, '2026-02-01', 1, 2, 'February', 1, 2026, 5, TRUE),
(20260301, '2026-03-01', 1, 3, 'March', 1, 2026, 9, TRUE),
(20260305, '2026-03-05', 5, 3, 'March', 1, 2026, 9, FALSE),
(20260410, '2026-04-10', 10, 4, 'April', 2, 2026, 15, FALSE),
(20260515, '2026-05-15', 15, 5, 'May', 2, 2026, 20, FALSE);

INSERT INTO dim_customer
(customer_id, full_name, email, phone)
VALUES
(1, 'Ahmed Al-Qahtani', 'ahmed@gmail.com', '0501111111'),
(2, 'Sara Al-Harbi', 'sara@gmail.com', '0502222222'),
(3, 'Khalid Al-Otaibi', 'khalid@gmail.com', '0503333333'),
(4, 'Fahad Al-Mutairi', 'fahad@gmail.com', '0504444444'),
(5, 'Noura Al-Shammari', 'noura@gmail.com', '0505555555'),
(6, 'Abdullah Al-Dosari', 'abdullah@gmail.com', '0506666666');

INSERT INTO dim_product
(product_id, product_name, description, price)
VALUES
(101, 'Laptop', 'Standard laptop', 3500.00),
(102, 'Smartphone', 'Android smartphone', 2500.00),
(103, 'Tablet', '10-inch tablet', 1800.00),
(104, 'Smart Watch', 'Wearable smart device', 1200.00),
(105, 'Wireless Earbuds', 'Bluetooth earbuds', 800.00),
(106, 'Gaming Laptop', 'High performance laptop', 6200.00);

INSERT INTO dim_store
(store_id, store_name, location)
VALUES
(10, 'Riyadh Store', 'Riyadh'),
(20, 'Jeddah Store', 'Jeddah'),
(30, 'Dammam Store', 'Dammam'),
(40, 'Madinah Store', 'Madinah');

INSERT INTO fact_sales
(date_key, customer_key, product_key, store_key,
 quantity, unit_price, total_sales)
VALUES
-- Ahmed – Riyadh
(20260101, 1, 1, 1, 1, 3500.00, 3500.00),
(20260101, 1, 2, 1, 2, 2500.00, 5000.00),

-- Sara – Jeddah
(20260102, 2, 2, 2, 1, 2500.00, 2500.00),
(20260102, 2, 3, 2, 1, 1800.00, 1800.00),

-- Khalid – Riyadh
(20260201, 3, 3, 1, 1, 1800.00, 1800.00),

-- Fahad – Dammam
(20260301, 4, 4, 3, 1, 1200.00, 1200.00),
(20260301, 4, 5, 3, 2, 800.00, 1600.00),

-- Noura – Madinah
(20260305, 5, 6, 4, 1, 6200.00, 6200.00),

-- Abdullah – Riyadh
(20260410, 6, 1, 1, 1, 3500.00, 3500.00),
(20260410, 6, 4, 1, 1, 1200.00, 1200.00),

-- Ahmed – Jeddah
(20260515, 1, 5, 2, 3, 800.00, 2400.00),

-- Sara – Dammam
(20260515, 2, 2, 3, 1, 2500.00, 2500.00),
(20260515, 2, 3, 3, 2, 1800.00, 3600.00);
