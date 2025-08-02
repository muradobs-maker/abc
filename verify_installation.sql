-- Oracle APEX BOM Application - Installation Verification Script
-- Run this script after installation to verify everything is working correctly
-- Usage: sqlplus username/password@database @verify_installation.sql

SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON
SET PAGESIZE 50
SET LINESIZE 120

PROMPT ====================================================
PROMPT Oracle APEX BOM Application - Installation Verification
PROMPT ====================================================
PROMPT

-- Check if all tables exist
PROMPT 1. Checking Table Creation...
PROMPT ====================================================
SELECT 
    table_name,
    num_rows,
    CASE 
        WHEN table_name IN ('UNITS_OF_MEASURE', 'PRODUCT_CATEGORIES', 'PRODUCTS', 'BOM_HEADER', 'BOM_COMPONENTS') 
        THEN '✓ Required Table'
        ELSE '? Unknown Table'
    END as status
FROM user_tables 
WHERE table_name IN ('UNITS_OF_MEASURE', 'PRODUCT_CATEGORIES', 'PRODUCTS', 'BOM_HEADER', 'BOM_COMPONENTS')
ORDER BY table_name;

PROMPT
PROMPT 2. Checking Sequences...
PROMPT ====================================================
SELECT 
    sequence_name,
    last_number,
    '✓ Active' as status
FROM user_sequences 
WHERE sequence_name LIKE 'SEQ_%'
ORDER BY sequence_name;

PROMPT
PROMPT 3. Checking Triggers...
PROMPT ====================================================
SELECT 
    trigger_name,
    table_name,
    status,
    CASE 
        WHEN status = 'ENABLED' THEN '✓ Working'
        ELSE '✗ Issue'
    END as verification
FROM user_triggers 
WHERE trigger_name LIKE 'TRG_%'
ORDER BY trigger_name;

PROMPT
PROMPT 4. Checking Views...
PROMPT ====================================================
SELECT 
    view_name,
    '✓ Created' as status
FROM user_views 
WHERE view_name LIKE 'V_BOM%' 
ORDER BY view_name;

PROMPT
PROMPT 5. Data Verification...
PROMPT ====================================================
SELECT 'Units of Measure' as table_name, COUNT(*) as record_count, 
       CASE WHEN COUNT(*) >= 10 THEN '✓ Good' ELSE '⚠ Low' END as status
FROM units_of_measure
UNION ALL
SELECT 'Product Categories', COUNT(*), 
       CASE WHEN COUNT(*) >= 10 THEN '✓ Good' ELSE '⚠ Low' END
FROM product_categories  
UNION ALL
SELECT 'Products', COUNT(*), 
       CASE WHEN COUNT(*) >= 15 THEN '✓ Good' ELSE '⚠ Low' END
FROM products
UNION ALL
SELECT 'BOM Headers', COUNT(*), 
       CASE WHEN COUNT(*) >= 3 THEN '✓ Good' ELSE '⚠ Low' END
FROM bom_header
UNION ALL
SELECT 'BOM Components', COUNT(*), 
       CASE WHEN COUNT(*) >= 15 THEN '✓ Good' ELSE '⚠ Low' END
FROM bom_components;

PROMPT
PROMPT 6. Testing BOM Explosion View...
PROMPT ====================================================
SELECT 
    LPAD(' ', (bom_level-1)*3, ' ') || component_code as "Product Structure",
    component_name,
    TO_CHAR(quantity, '999.99') as qty,
    uom_code
FROM v_bom_explosion 
WHERE product_code = 'WIDGET-100'
AND ROWNUM <= 10
ORDER BY sort_path;

PROMPT
PROMPT 7. Testing BOM Costing View...
PROMPT ====================================================
SELECT 
    component_code,
    component_name,
    TO_CHAR(quantity, '999.99') as qty,
    TO_CHAR(unit_cost, '$999.99') as unit_cost,
    TO_CHAR(extended_cost, '$9999.99') as ext_cost
FROM v_bom_costing
WHERE bom_number LIKE 'BOM-%'
AND ROWNUM <= 10
ORDER BY extended_cost DESC;

PROMPT
PROMPT 8. Constraint Verification...
PROMPT ====================================================
SELECT 
    constraint_name,
    constraint_type,
    table_name,
    status,
    CASE 
        WHEN status = 'ENABLED' THEN '✓ Active'
        ELSE '✗ Disabled'
    END as verification
FROM user_constraints 
WHERE table_name IN ('UNITS_OF_MEASURE', 'PRODUCT_CATEGORIES', 'PRODUCTS', 'BOM_HEADER', 'BOM_COMPONENTS')
AND constraint_type IN ('P', 'R', 'C')
ORDER BY table_name, constraint_type;

PROMPT
PROMPT ====================================================
PROMPT Installation Verification Summary
PROMPT ====================================================

-- Final verification query
WITH verification_summary AS (
    SELECT 'Tables' as component, 
           (SELECT COUNT(*) FROM user_tables 
            WHERE table_name IN ('UNITS_OF_MEASURE', 'PRODUCT_CATEGORIES', 'PRODUCTS', 'BOM_HEADER', 'BOM_COMPONENTS')) as actual,
           5 as expected
    FROM dual
    UNION ALL
    SELECT 'Sequences', 
           (SELECT COUNT(*) FROM user_sequences WHERE sequence_name LIKE 'SEQ_%'),
           5
    FROM dual
    UNION ALL
    SELECT 'Views',
           (SELECT COUNT(*) FROM user_views WHERE view_name LIKE 'V_BOM%'),
           2
    FROM dual
    UNION ALL
    SELECT 'Sample Products',
           (SELECT COUNT(*) FROM products),
           16
    FROM dual
)
SELECT 
    component,
    actual,
    expected,
    CASE 
        WHEN actual >= expected THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status
FROM verification_summary;

PROMPT
PROMPT ====================================================
PROMPT Next Steps:
PROMPT ====================================================
PROMPT 1. If all checks show ✓ PASS, database installation is complete
PROMPT 2. Import the APEX application: apex/bom_application.sql
PROMPT 3. Configure APEX authentication as needed
PROMPT 4. Test the application functionality
PROMPT 5. Review documentation/user_guide.md for usage instructions
PROMPT ====================================================

PROMPT
PROMPT Verification completed at:
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') as completion_time FROM dual;
PROMPT ====================================================