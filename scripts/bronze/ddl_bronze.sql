USE NovaMart_DW;

-- Drop tables if exist
DROP TABLE IF EXISTS bronze_crm_cust;
DROP TABLE IF EXISTS bronze_crm_prd;
DROP TABLE IF EXISTS bronze_crm_sales;
DROP TABLE IF EXISTS bronze_erp_loc;
DROP TABLE IF EXISTS bronze_erp_cust;
DROP TABLE IF EXISTS bronze_erp_cat;

-- CRM Customer Info
CREATE TABLE bronze_crm_cust (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);

-- CRM Product Info
CREATE TABLE bronze_crm_prd (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

-- CRM Sales Details
CREATE TABLE bronze_crm_sales (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

-- ERP Location
CREATE TABLE bronze_erp_loc (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);

-- ERP Customer
CREATE TABLE bronze_erp_cust (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50)
);

-- ERP Product Category
CREATE TABLE bronze_erp_cat (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50)
);
