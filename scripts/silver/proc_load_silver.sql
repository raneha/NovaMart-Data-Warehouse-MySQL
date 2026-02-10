USE NovaMart_DW;

UPDATE bronze_crm_prd
SET prd_end_dt = NULL
WHERE prd_end_dt = '0000-00-00';

TRUNCATE silver_crm_cust;
INSERT INTO silver_crm_cust
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname),
    TRIM(cst_lastname),
    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END,
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END,
    cst_create_date,
    NOW()
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) rn
    FROM bronze_crm_cust
    WHERE cst_id IS NOT NULL
) t
WHERE rn = 1;

TRUNCATE silver_crm_prd;
INSERT INTO silver_crm_prd
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
    SUBSTRING(prd_key,7) AS prd_key,
    prd_nm,
    IFNULL(prd_cost,0),
    CASE
        WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line))='S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
        ELSE 'n/a'
    END,
    clean_start_dt,
    CASE
        WHEN next_start IS NULL THEN NULL
        ELSE DATE_SUB(next_start, INTERVAL 1 DAY)
    END,
    NOW()
FROM (
    SELECT
        prd_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        CASE
            WHEN prd_start_dt IS NULL THEN NULL
            ELSE DATE(prd_start_dt)
        END AS clean_start_dt,
        LEAD(
            CASE
                WHEN prd_start_dt IS NULL THEN NULL
                ELSE DATE(prd_start_dt)
            END
        ) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS next_start
    FROM bronze_crm_prd
) t;

TRUNCATE silver_crm_sales;
INSERT INTO silver_crm_sales
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    STR_TO_DATE(sls_order_dt,'%Y%m%d'),
    STR_TO_DATE(sls_ship_dt,'%Y%m%d'),
    STR_TO_DATE(sls_due_dt,'%Y%m%d'),
    CASE
        WHEN sls_sales IS NULL OR sls_sales <= 0
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END,
    sls_quantity,
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity,0)
        ELSE sls_price
    END,
    NOW()
FROM bronze_crm_sales;

TRUNCATE silver_erp_cust;
INSERT INTO silver_erp_cust
SELECT
    REPLACE(cid,'NAS',''),
    CASE
        WHEN bdate > CURDATE() THEN NULL
        ELSE bdate
    END,
    CASE
        WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
        ELSE 'n/a'
    END,
    NOW()
FROM bronze_erp_cust;

TRUNCATE silver_erp_loc;
INSERT INTO silver_erp_loc
SELECT
    REPLACE(cid,'-',''),
    CASE
        WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
        ELSE TRIM(cntry)
    END,
    NOW()
FROM bronze_erp_loc;


TRUNCATE silver_erp_cat;
INSERT INTO silver_erp_cat
SELECT
    id,
    cat,
    subcat,
    maintenance,
    NOW()
FROM bronze_erp_cat;


SELECT COUNT(*) FROM silver_crm_prd;
SELECT COUNT(*) FROM silver_crm_sales;
SELECT COUNT(*) FROM silver_crm_cust;

SELECT *FROM silver_crm_prd;
SELECT *FROM silver_crm_sales;
SELECT *FROM silver_crm_cust;