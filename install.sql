-- Oracle APEX BOM Application - Master Installation Script
-- Version: 1.0
-- Created: 2024
--
-- This script installs the complete BOM application database components
-- Run this script as a user with CREATE TABLE, CREATE SEQUENCE, and CREATE TRIGGER privileges
--
-- Usage: sqlplus username/password@database @install.sql

SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON

PROMPT ====================================================
PROMPT Oracle APEX BOM Application Installation
PROMPT ====================================================
PROMPT Starting installation at: 
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') as install_time FROM dual;

PROMPT
PROMPT ====================================================
PROMPT Step 1: Creating Database Tables
PROMPT ====================================================
@@database/01_create_tables.sql

PROMPT
PROMPT ====================================================
PROMPT Step 2: Creating Sequences and Triggers  
PROMPT ====================================================
@@database/02_create_sequences.sql

PROMPT
PROMPT ====================================================
PROMPT Step 3: Loading Sample Data
PROMPT ====================================================
@@database/03_sample_data.sql

PROMPT
PROMPT ====================================================
PROMPT Installation Verification
PROMPT ====================================================

PROMPT Checking table creation...
SELECT table_name, num_rows 
FROM user_tables 
WHERE table_name IN ('UNITS_OF_MEASURE', 'PRODUCT_CATEGORIES', 'PRODUCTS', 'BOM_HEADER', 'BOM_COMPONENTS')
ORDER BY table_name;

PROMPT
PROMPT Checking sequence creation...
SELECT sequence_name, last_number 
FROM user_sequences 
WHERE sequence_name LIKE 'SEQ_%'
ORDER BY sequence_name;

PROMPT
PROMPT Checking sample data...
SELECT 'Units of Measure' as data_type, COUNT(*) as record_count FROM units_of_measure
UNION ALL
SELECT 'Product Categories', COUNT(*) FROM product_categories  
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'BOM Headers', COUNT(*) FROM bom_header
UNION ALL
SELECT 'BOM Components', COUNT(*) FROM bom_components;

PROMPT
PROMPT Checking views...
SELECT view_name FROM user_views WHERE view_name LIKE 'V_BOM%' ORDER BY view_name;

PROMPT
PROMPT ====================================================
PROMPT Installation Summary
PROMPT ====================================================
PROMPT Database installation completed successfully!
PROMPT 
PROMPT Tables Created:
PROMPT - UNITS_OF_MEASURE
PROMPT - PRODUCT_CATEGORIES  
PROMPT - PRODUCTS
PROMPT - BOM_HEADER
PROMPT - BOM_COMPONENTS
PROMPT
PROMPT Views Created:
PROMPT - V_BOM_EXPLOSION
PROMPT - V_BOM_COSTING
PROMPT
PROMPT Sample Data Loaded:
PROMPT - 10 Units of Measure
PROMPT - 11 Product Categories
PROMPT - 16 Products
PROMPT - 3 BOM Headers
PROMPT - 16 BOM Components
PROMPT
PROMPT Next Steps:
PROMPT 1. Import the APEX application from apex/bom_application.sql
PROMPT 2. Configure authentication as needed
PROMPT 3. Review the user guide in documentation/user_guide.md
PROMPT
PROMPT Installation completed at:
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') as completion_time FROM dual;
PROMPT ====================================================

-- Test queries to verify installation
PROMPT
PROMPT ====================================================
PROMPT Sample BOM Structure Query
PROMPT ====================================================
SELECT 
    LPAD(' ', (bom_level-1)*2, ' ') || component_code as indented_structure,
    component_name,
    quantity,
    uom_code
FROM v_bom_explosion 
WHERE product_code = 'WIDGET-100'
ORDER BY sort_path;

PROMPT
PROMPT ====================================================  
PROMPT Sample Cost Analysis Query
PROMPT ====================================================
SELECT 
    bom_number,
    component_code,
    component_name,
    quantity,
    unit_cost,
    extended_cost
FROM v_bom_costing
WHERE bom_number = 'BOM-WIDGET100-001'
ORDER BY extended_cost DESC;

PROMPT
PROMPT Installation verification complete!
PROMPT ====================================================