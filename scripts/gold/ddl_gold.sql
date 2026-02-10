USE novamart_dw;

DROP VIEW IF EXISTS gold_dim_customers;
CREATE VIEW gold_dim_customers AS
    SELECT
        ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
        ci.cst_id AS customer_id,
        ci.cst_key AS customer_number,
        ci.cst_firstname AS first_name,
        ci.cst_lastname AS last_name,
        la.cntry AS country,
        ci.cst_marital_status AS marital_status,
        CASE
            WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr
            ELSE IFNULL(ca.gen, 'n/a')
        END AS gender,
        ca.bdate AS birthdate,
        ci.cst_create_date AS create_date
    FROM
        silver_crm_cust ci
            LEFT JOIN
        silver_erp_cust ca ON ci.cst_key = ca.cid
            LEFT JOIN
        silver_erp_loc la ON ci.cst_key = la.cid;


DROP VIEW IF EXISTS gold_dim_products;
CREATE VIEW gold_dim_products AS
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY pn.prd_start_dt, pn.prd_key
        ) AS product_key,
        pn.prd_id AS product_id,
        pn.prd_key AS product_number,
        pn.prd_nm AS product_name,
        pn.cat_id AS category_id,
        pc.cat AS category,
        pc.subcat AS subcategory,
        pc.maintenance AS maintenance,
        pn.prd_cost AS cost,
        pn.prd_line AS product_line,
        pn.prd_start_dt AS start_date
    FROM
        silver_crm_prd pn
            LEFT JOIN
        silver_erp_cat pc ON pn.cat_id = pc.id
    WHERE
        pn.prd_end_dt IS NULL;


DROP VIEW IF EXISTS gold_fact_sales;
CREATE VIEW gold_fact_sales AS
    SELECT 
        sd.sls_ord_num AS order_number,
        pr.product_key,
        cu.customer_key,
        sd.sls_order_dt AS order_date,
        sd.sls_ship_dt AS shipping_date,
        sd.sls_due_dt AS due_date,
        sd.sls_sales AS sales_amount,
        sd.sls_quantity AS quantity,
        sd.sls_price AS price
    FROM
        silver_crm_sales sd
            LEFT JOIN
        gold_dim_products pr ON sd.sls_prd_key = pr.product_number
            LEFT JOIN
        gold_dim_customers cu ON sd.sls_cust_id = cu.customer_id;



/* Quality Checks */

SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold_dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold_dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

SELECT * 
FROM gold_fact_sales f
LEFT JOIN gold_dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold_dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;

SELECT COUNT(*) FROM gold_dim_customers;
SELECT COUNT(*) FROM gold_dim_products;
SELECT COUNT(*) FROM gold_fact_sales;

SELECT *FROM gold_dim_customers;
SELECT *FROM gold_dim_products;
SELECT *FROM gold_fact_sales;

SELECT * FROM gold_dim_customers LIMIT 10;
SELECT * FROM gold_dim_products LIMIT 10;
SELECT * FROM gold_fact_sales LIMIT 10;