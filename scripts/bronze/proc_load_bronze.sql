USE NovaMart_DW;

-- Truncate Tables
TRUNCATE bronze_crm_cust;
TRUNCATE bronze_crm_prd;
TRUNCATE bronze_crm_sales;
TRUNCATE bronze_erp_loc;
TRUNCATE bronze_erp_cust;
TRUNCATE bronze_erp_cat;

ALTER TABLE bronze_crm_prd
MODIFY prd_start_dt DATE;

ALTER TABLE bronze_crm_prd
MODIFY prd_end_dt DATE;

-- Load CRM Customer
LOAD DATA LOCAL INFILE 'D:/SQL Warehouse/datasets/source_crm/cust_infoo.csv'
INTO TABLE bronze_crm_cust
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
 @cst_id,
 @cst_key,
 @cst_firstname,
 @cst_lastname,
 @cst_marital_status,
 @cst_gndr,
 @cst_create_date
)
SET
cst_id            = TRIM(@cst_id),
cst_key           = TRIM(@cst_key),
cst_firstname     = TRIM(@cst_firstname),
cst_lastname      = TRIM(@cst_lastname),
cst_marital_status= TRIM(@cst_marital_status),
cst_gndr          = TRIM(@cst_gndr),
cst_create_date   = STR_TO_DATE(
                       TRIM(REPLACE(@cst_create_date,'\r','')),
                       '%Y-%m-%d'
                   );



-- Load CRM Product
LOAD DATA LOCAL INFILE 'D:/SQL Warehouse/datasets/source_crm/prd_info.csv'
INTO TABLE bronze_crm_prd
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Load CRM Sales
LOAD DATA LOCAL INFILE 'D:/SQL Warehouse/datasets/source_crm/sales_details.csv'
INTO TABLE bronze_crm_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load ERP Location
LOAD DATA LOCAL INFILE 'D:/SQL Warehouse/datasets/source_erp/loc_a101.csv'
INTO TABLE bronze_erp_loc
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load ERP Customer
LOAD DATA LOCAL INFILE 'D:/SQL Warehouse/datasets/source_erp/cust_az12.csv'
INTO TABLE bronze_erp_cust
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load ERP Category
LOAD DATA LOCAL INFILE 'D:/SQL Warehouse/datasets/source_erp/px_cat_g1v2.csv'
INTO TABLE bronze_erp_cat
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW TABLES FROM novamart_dw;

SELECT * FROM bronze_crm_cust;
SELECT * FROM bronze_crm_prd;
SELECT * FROM bronze_crm_sales;
SELECT * FROM bronze_erp_cat;
SELECT * FROM bronze_erp_cust;
SELECT * FROM bronze_erp_loc;