-- Sample Data for BOM Database
-- This file contains example data to demonstrate the BOM system

-- Insert suppliers
INSERT INTO suppliers (name, contact_person, email, phone, is_preferred) VALUES
('TechCorp Components', 'John Smith', 'john@techcorp.com', '555-0101', TRUE),
('ElectroSupply Inc', 'Sarah Johnson', 'sarah@electrosupply.com', '555-0102', TRUE),
('MechanicalParts Ltd', 'Mike Wilson', 'mike@mechparts.com', '555-0103', FALSE),
('FastenerWorld', 'Lisa Brown', 'lisa@fastenerworld.com', '555-0104', TRUE);

-- Insert products (components and assemblies)
INSERT INTO products (part_number, name, description, unit_of_measure, cost, weight, category, supplier_id, is_assembly, is_purchased, is_manufactured) VALUES
-- Raw materials and purchased parts
('RES-100K-0805', '100K Ohm Resistor 0805', '100K Ohm 1% 0805 SMD Resistor', 'each', 0.02, 0.001, 'Resistors', 1, FALSE, TRUE, FALSE),
('CAP-10UF-0805', '10uF Capacitor 0805', '10uF 25V X7R 0805 SMD Capacitor', 'each', 0.15, 0.002, 'Capacitors', 1, FALSE, TRUE, FALSE),
('IC-MCU-STM32', 'STM32F103 Microcontroller', 'STM32F103C8T6 32-bit ARM Cortex-M3 MCU', 'each', 3.50, 0.5, 'Microcontrollers', 2, FALSE, TRUE, FALSE),
('PCB-MAIN-V1', 'Main PCB v1.0', 'Main circuit board 2-layer FR4', 'each', 12.00, 15.0, 'PCBs', 3, FALSE, TRUE, FALSE),
('SCREW-M3-10', 'M3x10 Screw', 'M3x10mm Phillips Head Screw', 'each', 0.05, 2.0, 'Fasteners', 4, FALSE, TRUE, FALSE),
('CASE-PLASTIC', 'Plastic Enclosure', 'ABS Plastic Case 100x60x25mm', 'each', 2.50, 45.0, 'Enclosures', 3, FALSE, TRUE, FALSE),

-- Sub-assemblies
('PCB-ASSY-V1', 'PCB Assembly v1.0', 'Populated main PCB assembly', 'each', 0.00, 20.0, 'PCB Assemblies', NULL, TRUE, FALSE, TRUE),

-- Top-level assemblies
('DEVICE-001', 'Smart Controller Device', 'Complete smart controller in enclosure', 'each', 0.00, 75.0, 'Finished Goods', NULL, TRUE, FALSE, TRUE);

-- Insert BOM headers
INSERT INTO bom_headers (product_id, version, revision, effective_date, status, created_by, notes) VALUES
((SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1'), 'V1.0', 1, '2024-01-01', 'active', 'engineer@company.com', 'Initial PCB assembly BOM'),
((SELECT id FROM products WHERE part_number = 'DEVICE-001'), 'V1.0', 1, '2024-01-01', 'active', 'engineer@company.com', 'Complete device BOM');

-- Insert BOM items for PCB Assembly
INSERT INTO bom_items (bom_header_id, component_id, quantity, unit_of_measure, reference_designator, find_number, notes) VALUES
-- PCB Assembly BOM
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1') AND version = 'V1.0'), 
 (SELECT id FROM products WHERE part_number = 'PCB-MAIN-V1'), 1, 'each', '', 1, 'Main circuit board'),
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1') AND version = 'V1.0'), 
 (SELECT id FROM products WHERE part_number = 'IC-MCU-STM32'), 1, 'each', 'U1', 2, 'Main microcontroller'),
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1') AND version = 'V1.0'), 
 (SELECT id FROM products WHERE part_number = 'RES-100K-0805'), 10, 'each', 'R1-R10', 3, 'Pull-up resistors'),
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1') AND version = 'V1.0'), 
 (SELECT id FROM products WHERE part_number = 'CAP-10UF-0805'), 5, 'each', 'C1-C5', 4, 'Decoupling capacitors');

-- Insert BOM items for Complete Device
INSERT INTO bom_items (bom_header_id, component_id, quantity, unit_of_measure, reference_designator, find_number, notes) VALUES
-- Complete Device BOM
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'DEVICE-001') AND version = 'V1.0'), 
 (SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1'), 1, 'each', '', 1, 'Main PCB assembly'),
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'DEVICE-001') AND version = 'V1.0'), 
 (SELECT id FROM products WHERE part_number = 'CASE-PLASTIC'), 1, 'each', '', 2, 'Protective enclosure'),
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'DEVICE-001') AND version = 'V1.0'), 
 (SELECT id FROM products WHERE part_number = 'SCREW-M3-10'), 4, 'each', '', 3, 'Case mounting screws');

-- Insert some change history records
INSERT INTO bom_change_history (bom_header_id, change_type, changed_by, reason) VALUES
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1') AND version = 'V1.0'), 
 'created', 'engineer@company.com', 'Initial BOM creation'),
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'DEVICE-001') AND version = 'V1.0'), 
 'created', 'engineer@company.com', 'Initial device BOM creation');

-- Create some additional sample data for testing
INSERT INTO products (part_number, name, description, unit_of_measure, cost, weight, category, supplier_id, is_assembly, is_purchased, is_manufactured) VALUES
('LED-RED-0805', 'Red LED 0805', 'Red LED 0805 SMD 2V 20mA', 'each', 0.08, 0.001, 'LEDs', 2, FALSE, TRUE, FALSE),
('CONN-USB-C', 'USB-C Connector', 'USB-C Female Connector SMD', 'each', 0.75, 1.2, 'Connectors', 2, FALSE, TRUE, FALSE);

-- Add a second version of the PCB assembly with additional components
INSERT INTO bom_headers (product_id, version, revision, effective_date, status, created_by, notes) VALUES
((SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1'), 'V1.1', 1, '2024-02-01', 'active', 'engineer@company.com', 'Added LED indicator and USB connector');

-- Insert BOM items for PCB Assembly V1.1 (copy from V1.0 plus new items)
INSERT INTO bom_items (bom_header_id, component_id, quantity, unit_of_measure, reference_designator, find_number, notes) VALUES
-- PCB Assembly V1.1 BOM (includes all V1.0 items plus new ones)
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1') AND version = 'V1.1'), 
 (SELECT id FROM products WHERE part_number = 'PCB-MAIN-V1'), 1, 'each', '', 1, 'Main circuit board'),
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1') AND version = 'V1.1'), 
 (SELECT id FROM products WHERE part_number = 'IC-MCU-STM32'), 1, 'each', 'U1', 2, 'Main microcontroller'),
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1') AND version = 'V1.1'), 
 (SELECT id FROM products WHERE part_number = 'RES-100K-0805'), 12, 'each', 'R1-R12', 3, 'Pull-up resistors (added 2 more)'),
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1') AND version = 'V1.1'), 
 (SELECT id FROM products WHERE part_number = 'CAP-10UF-0805'), 5, 'each', 'C1-C5', 4, 'Decoupling capacitors'),
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1') AND version = 'V1.1'), 
 (SELECT id FROM products WHERE part_number = 'LED-RED-0805'), 1, 'each', 'D1', 5, 'Status indicator LED'),
((SELECT id FROM bom_headers WHERE product_id = (SELECT id FROM products WHERE part_number = 'PCB-ASSY-V1') AND version = 'V1.1'), 
 (SELECT id FROM products WHERE part_number = 'CONN-USB-C'), 1, 'each', 'J1', 6, 'USB communication port');