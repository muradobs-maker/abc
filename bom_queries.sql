-- Common BOM Database Queries
-- These queries demonstrate how to work with the Bill of Materials system

-- 1. Get complete BOM for a product (single level)
SELECT 
    p.part_number as parent_part,
    p.name as parent_name,
    bh.version,
    bi.find_number,
    c.part_number as component_part,
    c.name as component_name,
    bi.quantity,
    bi.unit_of_measure,
    bi.reference_designator,
    c.cost,
    (bi.quantity * c.cost) as extended_cost
FROM bom_headers bh
JOIN products p ON bh.product_id = p.id
JOIN bom_items bi ON bh.id = bi.bom_header_id
JOIN products c ON bi.component_id = c.id
WHERE p.part_number = 'YOUR_PART_NUMBER'
    AND bh.status = 'active'
ORDER BY bi.find_number;

-- 2. Multi-level BOM explosion (recursive query)
WITH RECURSIVE bom_explosion AS (
    -- Base case: top-level product
    SELECT 
        p.id as product_id,
        p.part_number,
        p.name,
        0 as level,
        bi.component_id,
        c.part_number as component_part,
        c.name as component_name,
        bi.quantity,
        bi.quantity as total_quantity,
        ARRAY[p.part_number] as path
    FROM products p
    JOIN bom_headers bh ON p.id = bh.product_id
    JOIN bom_items bi ON bh.id = bi.bom_header_id
    JOIN products c ON bi.component_id = c.id
    WHERE p.part_number = 'YOUR_PART_NUMBER'
        AND bh.status = 'active'
    
    UNION ALL
    
    -- Recursive case: sub-assemblies
    SELECT 
        be.component_id as product_id,
        c.part_number,
        c.name,
        be.level + 1,
        bi.component_id,
        comp.part_number as component_part,
        comp.name as component_name,
        bi.quantity,
        be.total_quantity * bi.quantity as total_quantity,
        be.path || c.part_number
    FROM bom_explosion be
    JOIN products c ON be.component_id = c.id
    JOIN bom_headers bh ON c.id = bh.product_id
    JOIN bom_items bi ON bh.id = bi.bom_header_id
    JOIN products comp ON bi.component_id = comp.id
    WHERE bh.status = 'active'
        AND c.is_assembly = TRUE
        AND NOT (c.part_number = ANY(be.path)) -- Prevent infinite loops
)
SELECT 
    level,
    REPEAT('  ', level) || component_part as indented_part,
    component_name,
    quantity,
    total_quantity,
    path
FROM bom_explosion
ORDER BY path, level;

-- 3. Where-used query (find all assemblies that use a specific component)
SELECT 
    c.part_number as component_part,
    c.name as component_name,
    p.part_number as parent_part,
    p.name as parent_name,
    bh.version,
    bi.quantity,
    bi.reference_designator
FROM products c
JOIN bom_items bi ON c.id = bi.component_id
JOIN bom_headers bh ON bi.bom_header_id = bh.id
JOIN products p ON bh.product_id = p.id
WHERE c.part_number = 'YOUR_COMPONENT_PART'
    AND bh.status = 'active'
ORDER BY p.part_number;

-- 4. BOM cost rollup
WITH RECURSIVE cost_rollup AS (
    -- Base case: purchased parts (no BOM)
    SELECT 
        p.id,
        p.part_number,
        p.name,
        COALESCE(p.cost, 0) as unit_cost,
        0 as level
    FROM products p
    WHERE p.is_purchased = TRUE
        AND p.is_assembly = FALSE
    
    UNION ALL
    
    -- Recursive case: assemblies
    SELECT 
        p.id,
        p.part_number,
        p.name,
        COALESCE(p.cost, 0) + COALESCE(SUM(cr.unit_cost * bi.quantity), 0) as unit_cost,
        MAX(cr.level) + 1 as level
    FROM products p
    JOIN bom_headers bh ON p.id = bh.product_id
    JOIN bom_items bi ON bh.id = bi.bom_header_id
    JOIN cost_rollup cr ON bi.component_id = cr.id
    WHERE bh.status = 'active'
        AND p.is_assembly = TRUE
    GROUP BY p.id, p.part_number, p.name, p.cost
)
SELECT 
    part_number,
    name,
    unit_cost,
    level
FROM cost_rollup
ORDER BY level DESC, part_number;

-- 5. BOM comparison between versions
SELECT 
    COALESCE(v1.component_part, v2.component_part) as component_part,
    COALESCE(v1.component_name, v2.component_name) as component_name,
    v1.quantity as version1_qty,
    v2.quantity as version2_qty,
    CASE 
        WHEN v1.component_part IS NULL THEN 'Added in V2'
        WHEN v2.component_part IS NULL THEN 'Removed in V2'
        WHEN v1.quantity != v2.quantity THEN 'Quantity Changed'
        ELSE 'No Change'
    END as change_type
FROM (
    SELECT 
        c.part_number as component_part,
        c.name as component_name,
        bi.quantity
    FROM bom_headers bh
    JOIN bom_items bi ON bh.id = bi.bom_header_id
    JOIN products c ON bi.component_id = c.id
    WHERE bh.product_id = (SELECT id FROM products WHERE part_number = 'YOUR_PART_NUMBER')
        AND bh.version = 'V1'
) v1
FULL OUTER JOIN (
    SELECT 
        c.part_number as component_part,
        c.name as component_name,
        bi.quantity
    FROM bom_headers bh
    JOIN bom_items bi ON bh.id = bi.bom_header_id
    JOIN products c ON bi.component_id = c.id
    WHERE bh.product_id = (SELECT id FROM products WHERE part_number = 'YOUR_PART_NUMBER')
        AND bh.version = 'V2'
) v2 ON v1.component_part = v2.component_part
WHERE COALESCE(v1.quantity, 0) != COALESCE(v2.quantity, 0)
    OR v1.component_part IS NULL 
    OR v2.component_part IS NULL
ORDER BY component_part;

-- 6. Find components with no supplier
SELECT 
    part_number,
    name,
    category,
    cost
FROM products
WHERE supplier_id IS NULL
    AND is_purchased = TRUE
    AND active = TRUE
ORDER BY category, part_number;

-- 7. BOM summary with totals
SELECT 
    p.part_number,
    p.name,
    bh.version,
    COUNT(bi.id) as total_components,
    SUM(bi.quantity * c.cost) as total_material_cost,
    AVG(c.cost) as avg_component_cost,
    MAX(bi.quantity) as max_quantity
FROM products p
JOIN bom_headers bh ON p.id = bh.product_id
JOIN bom_items bi ON bh.id = bi.bom_header_id
JOIN products c ON bi.component_id = c.id
WHERE bh.status = 'active'
GROUP BY p.part_number, p.name, bh.version
ORDER BY total_material_cost DESC;