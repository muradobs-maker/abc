-- Bill of Materials (BOM) Database Schema
-- This schema supports multi-level BOMs with parent-child relationships

-- Products/Components table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    part_number VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    unit_of_measure VARCHAR(20) DEFAULT 'each',
    cost DECIMAL(10,2),
    weight DECIMAL(8,3),
    category VARCHAR(100),
    supplier_id INTEGER,
    is_assembly BOOLEAN DEFAULT FALSE,
    is_purchased BOOLEAN DEFAULT TRUE,
    is_manufactured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

-- BOM header table (represents different BOM versions for products)
CREATE TABLE bom_headers (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id),
    version VARCHAR(20) NOT NULL,
    revision INTEGER DEFAULT 1,
    effective_date DATE,
    obsolete_date DATE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('draft', 'active', 'obsolete')),
    created_by VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, version)
);

-- BOM line items (the actual bill of materials structure)
CREATE TABLE bom_items (
    id SERIAL PRIMARY KEY,
    bom_header_id INTEGER NOT NULL REFERENCES bom_headers(id) ON DELETE CASCADE,
    component_id INTEGER NOT NULL REFERENCES products(id),
    quantity DECIMAL(10,4) NOT NULL,
    unit_of_measure VARCHAR(20),
    reference_designator VARCHAR(100), -- For electronics/PCB assemblies
    find_number INTEGER, -- Item number in the BOM
    notes TEXT,
    scrap_factor DECIMAL(5,4) DEFAULT 0.0, -- Expected waste percentage
    lead_time_days INTEGER,
    is_optional BOOLEAN DEFAULT FALSE,
    substitute_group VARCHAR(50), -- For interchangeable parts
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Suppliers table
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    is_preferred BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

-- BOM change history for audit trail
CREATE TABLE bom_change_history (
    id SERIAL PRIMARY KEY,
    bom_header_id INTEGER NOT NULL REFERENCES bom_headers(id),
    change_type VARCHAR(20) NOT NULL CHECK (change_type IN ('created', 'modified', 'deleted', 'approved')),
    changed_by VARCHAR(100) NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_values JSONB,
    new_values JSONB,
    reason TEXT
);

-- Indexes for performance
CREATE INDEX idx_products_part_number ON products(part_number);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_bom_headers_product_id ON bom_headers(product_id);
CREATE INDEX idx_bom_headers_status ON bom_headers(status);
CREATE INDEX idx_bom_items_header_id ON bom_items(bom_header_id);
CREATE INDEX idx_bom_items_component_id ON bom_items(component_id);
CREATE INDEX idx_bom_items_find_number ON bom_items(bom_header_id, find_number);

-- Add foreign key constraint for supplier
ALTER TABLE products ADD CONSTRAINT fk_products_supplier 
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id);

-- Triggers for updating timestamps
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_update_timestamp
    BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER bom_headers_update_timestamp
    BEFORE UPDATE ON bom_headers
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER bom_items_update_timestamp
    BEFORE UPDATE ON bom_items
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();