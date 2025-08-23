-- Data validation for silver.crm_cust_info
-- Data Standardization and Consistency
SELECT
	cst_id,
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 
OR cst_id IS NULL;

SELECT 
	cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

SELECT 
	DISTINCT cst_marital_status
FROM silver.crm_cust_info;

-----------------------------------------------------------

-- Data validation for silver.crm_prd_info
SELECT
	prd_key,
FROM silver.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key,1,5), '-','_') NOT IN
(SELECT DISTINCT id FROM silver.erp_px_cat_g1v2);

SELECT 
	DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check for NULLS or Negative Numbers
SELECT 
	prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check for Invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;

-----------------------------------------------------------

-- Data validation for silver.crm_sales_details table
-- Check for invalid Dates 
SELECT
NULLIF(sls_due_dt,0) AS sls_due_dt,
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0
OR LENGTH(sls_due_dt::VARCHAR) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

-- Check for Invalid Date Orders
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
OR sls_order_dt > sls_due_dt

-- Check Data Consistency between Sales, Quantity and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, Zero or Negative
SELECT
	DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

-----------------------------------------------------------

-- Data validation for silver.erp_cust_az12
-- Data Standardization and Consistency
SELECT
	cid,
	bdate,
	gen
FROM silver.erp_cust_az12
WHERE 
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
		ELSE cid
	END cid,

-- Identify Out-of-Range Dates
SELECT
	DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > NOW();

-- Data Standardization and Consistency
SELECT 
	DISTINCT
	gen
FROM silver.erp_cust_az12

-----------------------------------------------------------

-- Data validation for silver.erp_loc_101
-- Data Standardization and Consistency
SELECT
	cid,
	cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN
(SELECT cst_key FROM silver.crm_cust_info)

SELECT
	DISTINCT
	cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-----------------------------------------------------------

-- Data validation for silver.erp_px_cat_g1v2
-- Check for unwanted Spaces
SELECT
	*
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization and Consistency
SELECT
	DISTINCT
	cat,
	subcat,
	maintenance
FROM silver.erp_px_cat_g1v2;







