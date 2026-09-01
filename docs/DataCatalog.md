# Data Catalog For Gold Layer 🥇 
## Overview 
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of
dimension and fact tables.
### 1. gold.dim_customer 
* **Purpose:** Stores customer details enriched with demographic and geographic data.
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `customer_key` | INT | Surrogate key uniquely identifying each customer record in the dimension table. |
| `customer_id` | INT | Unique numerical identifier assigned to each customer. |
| `customer_number` | NVARCHAR(50) | Alphanumeric identifier representing the customer. |
| `first_name` | NVARCHAR(50) | The customer's first name. |
| `last_name` | NVARCHAR(50) | The customer's last name or family name. |
| `marital_status` | NVARCHAR(50) | The marital status of the customer. |
| `gender` | NVARCHAR(50) | The gender of the customer. |
| `country` | NVARCHAR(50) | The country of residence for the customer. |
| `birthdate` | DATE | The customer's birthdate , Formatted as YYYY-MM-DD ex:2000-01-12. |
| `create_date` | DATE | The date when the customer record was created. |
---
### 2. gold.dim_product
* **Purpose:** Provides information about the product and it's categorical data.
* **Columns:**
 
| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `product_key` | INT | Surrogate key uniquely identifying each product record in the product dimension table. |
| `product_id` | INT | Unique numerical identifier assigned to each product for internal tracking. |
| `product_number` | NVARCHAR(50) | A structured alphanumeric code representing the product often used for categorization . |
| `product_name` | NVARCHAR(50) | The  descriptive name of  product , including type, color and size. |
| `category_id` | NVARCHAR(50) | unique identifier representing the category for each product, linking it  to it's high-level classification. |
| `category` | NVARCHAR(50) | The boarder classification of the product(ex:Components, Bikes,...). |
| `sub_category` | NVARCHAR(50) | The more detailed classification for each product within category , such as product type .|
| `product_line` | NVARCHAR(50) | The product_line or series to which the product belongs(ex:Road, Mountain,...). | 
| `maintenance` | NVARCHAR(50) | indicates whether the product require maintenance or not (ex:'Yes','No') . |
| `cost` | INT | The base price of the product measured by monetary units. |
| `start_date` | DATE | The date when the product became available for sale, stored in.  |
---
### 2. gold.fact_sales 
* **Purpose:**  Stores transactional sales and provides business metrics and measures for Analytical purposes .
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `order_number ` | NVARCHAR(50) | A unique alphanumeric identifier for each sales order. |
| `product_key` | INT | Surrogate key linking the order to the product dimension table.   |
| `customer_key` | INT | Surrogate key linking the order to the customer dimension table . |
| `order_date` | DATE | The date when the order was placed. |
| `shipping_date` | DATE | The date when the order was shipped to the customer. |
| `due_date` | DATE | The date when the order payment was due . |
| `quantity` | INT | The number of units of the product ordered for line item (ex:1,...). |
| `price` | INT | The price per unit of the product for the  line item,in whole currancy (ex: 25,...).  |
| `sales_amount` | INT | The total monetary value for sales for the line item ,in whole currancy (ex: 25,...). |
---
