-- Oracle APEX BOM Application - Sample Data Script
-- Version: 1.0
-- Created: 2024

-- Insert Units of Measure
INSERT INTO units_of_measure (uom_code, uom_name, description) VALUES
('EA', 'Each', 'Individual unit');
INSERT INTO units_of_measure (uom_code, uom_name, description) VALUES
('LB', 'Pound', 'Weight in pounds');
INSERT INTO units_of_measure (uom_code, uom_name, description) VALUES
('KG', 'Kilogram', 'Weight in kilograms');
INSERT INTO units_of_measure (uom_code, uom_name, description) VALUES
('FT', 'Feet', 'Length in feet');
INSERT INTO units_of_measure (uom_code, uom_name, description) VALUES
('M', 'Meter', 'Length in meters');
INSERT INTO units_of_measure (uom_code, uom_name, description) VALUES
('L', 'Liter', 'Volume in liters');
INSERT INTO units_of_measure (uom_code, uom_name, description) VALUES
('GAL', 'Gallon', 'Volume in gallons');
INSERT INTO units_of_measure (uom_code, uom_name, description) VALUES
('SQ_FT', 'Square Feet', 'Area in square feet');
INSERT INTO units_of_measure (uom_code, uom_name, description) VALUES
('HR', 'Hour', 'Time in hours');
INSERT INTO units_of_measure (uom_code, uom_name, description) VALUES
('SET', 'Set', 'Set of items');

-- Insert Product Categories
INSERT INTO product_categories (category_code, category_name, description) VALUES
('ELEC', 'Electronics', 'Electronic components and assemblies');
INSERT INTO product_categories (category_code, category_name, description) VALUES
('MECH', 'Mechanical', 'Mechanical parts and assemblies');
INSERT INTO product_categories (category_code, category_name, description) VALUES
('RAW', 'Raw Materials', 'Raw materials and consumables');
INSERT INTO product_categories (category_code, category_name, description) VALUES
('FAST', 'Fasteners', 'Screws, bolts, nuts, washers');
INSERT INTO product_categories (category_code, category_name, description) VALUES
('CHEM', 'Chemicals', 'Adhesives, solvents, coatings');
INSERT INTO product_categories (category_code, category_name, description) VALUES
('PKG', 'Packaging', 'Boxes, labels, protective materials');

-- Insert subcategories
INSERT INTO product_categories (category_code, category_name, description, parent_category_id) VALUES
('PCB', 'Printed Circuit Boards', 'PCBs and electronic boards', 1);
INSERT INTO product_categories (category_code, category_name, description, parent_category_id) VALUES
('IC', 'Integrated Circuits', 'Microprocessors, memory, logic ICs', 1);
INSERT INTO product_categories (category_code, category_name, description, parent_category_id) VALUES
('CONN', 'Connectors', 'Electrical connectors and cables', 1);
INSERT INTO product_categories (category_code, category_name, description, parent_category_id) VALUES
('HOUS', 'Housings', 'Enclosures and mechanical housings', 2);
INSERT INTO product_categories (category_code, category_name, description, parent_category_id) VALUES
('GEAR', 'Gears', 'Gears and transmission components', 2);

-- Insert Products
-- Finished Products
INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('WIDGET-100', 'Electronic Widget Model 100', 'Advanced electronic widget with LCD display', 1, 1, 'MANUFACTURED', 125.50, 199.99, 14);

INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('SENSOR-A1', 'Temperature Sensor Assembly', 'High precision temperature sensor with digital output', 1, 1, 'MANUFACTURED', 45.75, 89.99, 10);

INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('MOTOR-CTRL', 'Motor Controller Unit', 'Variable speed motor controller with safety features', 1, 1, 'MANUFACTURED', 89.25, 149.99, 12);

-- Sub-assemblies
INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('PCB-MAIN-100', 'Main PCB Assembly Widget 100', 'Main circuit board for Widget 100', 7, 1, 'MANUFACTURED', 35.00, 0, 7);

INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('LCD-DISPLAY', 'LCD Display Module', '2.4 inch color LCD display module', 1, 1, 'PURCHASED', 12.50, 0, 5);

INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('HOUSING-100', 'Plastic Housing Widget 100', 'Injection molded ABS housing', 10, 1, 'MANUFACTURED', 8.75, 0, 10);

INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('KEYPAD-4X4', '4x4 Membrane Keypad', 'Waterproof membrane keypad', 1, 1, 'PURCHASED', 6.25, 0, 3);

-- Components and Raw Materials
INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('PCB-BARE-100', 'Bare PCB Widget 100', '4-layer FR4 PCB, 100mm x 80mm', 7, 1, 'PURCHASED', 4.50, 0, 14);

INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('MCU-ARM32', 'ARM Cortex-M4 Microcontroller', '32-bit ARM microcontroller, 512KB Flash', 8, 1, 'PURCHASED', 8.95, 0, 8);

INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('RES-10K-1%', '10K Ohm Resistor 1%', '10K ohm 1/4W 1% metal film resistor', 1, 1, 'PURCHASED', 0.05, 0, 2);

INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('CAP-100UF', '100uF Electrolytic Capacitor', '100uF 25V electrolytic capacitor', 1, 1, 'PURCHASED', 0.15, 0, 2);

INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('CONN-USB-C', 'USB-C Connector', 'USB Type-C connector, right angle', 9, 1, 'PURCHASED', 1.25, 0, 5);

INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('SCREW-M3X8', 'M3x8mm Phillips Screw', 'Stainless steel Phillips head screw', 4, 1, 'PURCHASED', 0.08, 0, 1);

INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('GASKET-RUBBER', 'Rubber Gasket', 'Silicone rubber gasket for housing seal', 3, 1, 'PURCHASED', 0.45, 0, 3);

INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('LABEL-WARNING', 'Warning Label', 'Safety warning label, adhesive backed', 6, 1, 'PURCHASED', 0.12, 0, 2);

INSERT INTO products (product_code, product_name, description, category_id, uom_id, product_type, standard_cost, list_price, lead_time_days) VALUES
('SOLDER-PASTE', 'Lead-Free Solder Paste', 'SAC305 lead-free solder paste', 5, 3, 'PURCHASED', 125.00, 0, 7);

-- Insert BOM Headers
INSERT INTO bom_header (bom_number, product_id, revision, bom_type, status, description, lot_size) VALUES
('BOM-WIDGET100-001', 1000, '1.0', 'MANUFACTURING', 'ACTIVE', 'Manufacturing BOM for Electronic Widget Model 100', 1);

INSERT INTO bom_header (bom_number, product_id, revision, bom_type, status, description, lot_size) VALUES
('BOM-PCB-MAIN-001', 1003, '1.0', 'MANUFACTURING', 'ACTIVE', 'Manufacturing BOM for Main PCB Assembly', 1);

INSERT INTO bom_header (bom_number, product_id, revision, bom_type, status, description, lot_size) VALUES
('BOM-HOUSING-001', 1005, '1.0', 'MANUFACTURING', 'ACTIVE', 'Manufacturing BOM for Plastic Housing', 1);

-- Insert BOM Components for Widget 100
INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, reference_designator, find_number, notes) VALUES
(1, 10, 1003, 1, 1, 'A1', '001', 'Main PCB Assembly');

INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, reference_designator, find_number, notes) VALUES
(1, 20, 1004, 1, 1, 'LCD1', '002', 'LCD Display Module');

INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, reference_designator, find_number, notes) VALUES
(1, 30, 1005, 1, 1, 'H1', '003', 'Main Housing');

INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, reference_designator, find_number, notes) VALUES
(1, 40, 1006, 1, 1, 'KP1', '004', 'User Interface Keypad');

INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, reference_designator, find_number, notes) VALUES
(1, 50, 1013, 4, 1, 'S1-S4', '005', 'Housing screws');

INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, reference_designator, find_number, notes) VALUES
(1, 60, 1014, 1, 1, 'G1', '006', 'Sealing gasket');

INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, reference_designator, find_number, notes) VALUES
(1, 70, 1015, 2, 1, 'L1,L2', '007', 'Safety labels');

-- Insert BOM Components for Main PCB Assembly
INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, reference_designator, find_number, notes) VALUES
(2, 10, 1007, 1, 1, 'PCB1', '001', 'Bare PCB');

INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, reference_designator, find_number, notes) VALUES
(2, 20, 1008, 1, 1, 'U1', '002', 'Main microcontroller');

INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, reference_designator, find_number, notes) VALUES
(2, 30, 1009, 15, 1, 'R1-R15', '003', 'Pull-up resistors');

INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, reference_designator, find_number, notes) VALUES
(2, 40, 1010, 8, 1, 'C1-C8', '004', 'Decoupling capacitors');

INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, reference_designator, find_number, notes) VALUES
(2, 50, 1011, 1, 1, 'J1', '005', 'USB connector');

INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, scrap_factor, reference_designator, find_number, notes) VALUES
(2, 60, 1016, 0.02, 3, 0.05, 'PASTE', '006', 'Solder paste for SMT assembly');

-- Insert BOM Components for Housing (simple example)
INSERT INTO bom_components (bom_id, sequence_number, component_product_id, quantity, uom_id, reference_designator, find_number, notes) VALUES
(3, 10, 1014, 1, 1, 'G1', '001', 'Molded gasket groove');

-- Create some views for easier BOM management
CREATE OR REPLACE VIEW v_bom_explosion AS
WITH bom_tree AS (
    -- Level 0: Top level products
    SELECT 
        bh.bom_id,
        bh.product_id,
        p.product_code,
        p.product_name,
        bc.component_product_id,
        cp.product_code as component_code,
        cp.product_name as component_name,
        bc.quantity,
        u.uom_code,
        bc.sequence_number,
        bc.reference_designator,
        bc.find_number,
        bc.notes,
        1 as bom_level,
        bh.product_id || '.' || bc.sequence_number as sort_path
    FROM bom_header bh
    JOIN products p ON bh.product_id = p.product_id
    JOIN bom_components bc ON bh.bom_id = bc.bom_id
    JOIN products cp ON bc.component_product_id = cp.product_id
    LEFT JOIN units_of_measure u ON bc.uom_id = u.uom_id
    WHERE bh.status = 'ACTIVE'
    
    UNION ALL
    
    -- Recursive: Sub-assemblies
    SELECT 
        bt.bom_id,
        bt.product_id,
        bt.product_code,
        bt.product_name,
        bc.component_product_id,
        cp.product_code as component_code,
        cp.product_name as component_name,
        bt.quantity * bc.quantity as quantity,
        u.uom_code,
        bc.sequence_number,
        bc.reference_designator,
        bc.find_number,
        bc.notes,
        bt.bom_level + 1 as bom_level,
        bt.sort_path || '.' || bc.sequence_number as sort_path
    FROM bom_tree bt
    JOIN bom_header bh ON bt.component_product_id = bh.product_id
    JOIN bom_components bc ON bh.bom_id = bc.bom_id
    JOIN products cp ON bc.component_product_id = cp.product_id
    LEFT JOIN units_of_measure u ON bc.uom_id = u.uom_id
    WHERE bh.status = 'ACTIVE'
    AND bt.bom_level < 10  -- Prevent infinite recursion
)
SELECT * FROM bom_tree
ORDER BY product_id, sort_path;

-- Create view for BOM costing
CREATE OR REPLACE VIEW v_bom_costing AS
SELECT 
    bh.bom_id,
    bh.bom_number,
    p.product_code,
    p.product_name,
    bc.sequence_number,
    cp.product_code as component_code,
    cp.product_name as component_name,
    bc.quantity,
    u.uom_code,
    cp.standard_cost as unit_cost,
    bc.quantity * cp.standard_cost as extended_cost,
    bc.reference_designator,
    bc.find_number
FROM bom_header bh
JOIN products p ON bh.product_id = p.product_id
JOIN bom_components bc ON bh.bom_id = bc.bom_id
JOIN products cp ON bc.component_product_id = cp.product_id
LEFT JOIN units_of_measure u ON bc.uom_id = u.uom_id
WHERE bh.status = 'ACTIVE'
ORDER BY bh.bom_id, bc.sequence_number;

COMMIT;

PROMPT Sample data inserted successfully!
PROMPT 
PROMPT Summary:
PROMPT - 10 Units of Measure
PROMPT - 11 Product Categories (6 main + 5 sub-categories)
PROMPT - 16 Products (3 finished goods, 4 sub-assemblies, 9 components)
PROMPT - 3 BOM Headers
PROMPT - 16 BOM Components
PROMPT - 2 Views created for BOM explosion and costing
PROMPT