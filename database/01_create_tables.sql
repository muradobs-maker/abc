-- Oracle APEX BOM Application - Table Creation Script
-- Version: 1.0
-- Created: 2024

-- Drop tables if they exist (in reverse dependency order)
DROP TABLE bom_components CASCADE CONSTRAINTS;
DROP TABLE bom_header CASCADE CONSTRAINTS;
DROP TABLE products CASCADE CONSTRAINTS;
DROP TABLE product_categories CASCADE CONSTRAINTS;
DROP TABLE units_of_measure CASCADE CONSTRAINTS;

-- Create Units of Measure table
CREATE TABLE units_of_measure (
    uom_id          NUMBER(10) PRIMARY KEY,
    uom_code        VARCHAR2(10) NOT NULL UNIQUE,
    uom_name        VARCHAR2(50) NOT NULL,
    description     VARCHAR2(200),
    active_flag     CHAR(1) DEFAULT 'Y' CHECK (active_flag IN ('Y', 'N')),
    created_date    DATE DEFAULT SYSDATE,
    created_by      VARCHAR2(100) DEFAULT USER,
    updated_date    DATE DEFAULT SYSDATE,
    updated_by      VARCHAR2(100) DEFAULT USER
);

-- Create Product Categories table
CREATE TABLE product_categories (
    category_id     NUMBER(10) PRIMARY KEY,
    category_code   VARCHAR2(20) NOT NULL UNIQUE,
    category_name   VARCHAR2(100) NOT NULL,
    description     VARCHAR2(500),
    parent_category_id NUMBER(10),
    active_flag     CHAR(1) DEFAULT 'Y' CHECK (active_flag IN ('Y', 'N')),
    created_date    DATE DEFAULT SYSDATE,
    created_by      VARCHAR2(100) DEFAULT USER,
    updated_date    DATE DEFAULT SYSDATE,
    updated_by      VARCHAR2(100) DEFAULT USER,
    CONSTRAINT fk_category_parent FOREIGN KEY (parent_category_id) 
        REFERENCES product_categories(category_id)
);

-- Create Products table
CREATE TABLE products (
    product_id      NUMBER(10) PRIMARY KEY,
    product_code    VARCHAR2(50) NOT NULL UNIQUE,
    product_name    VARCHAR2(200) NOT NULL,
    description     VARCHAR2(1000),
    category_id     NUMBER(10),
    uom_id          NUMBER(10),
    product_type    VARCHAR2(20) DEFAULT 'MANUFACTURED' 
                    CHECK (product_type IN ('MANUFACTURED', 'PURCHASED', 'PHANTOM')),
    standard_cost   NUMBER(15,4) DEFAULT 0,
    list_price      NUMBER(15,4) DEFAULT 0,
    lead_time_days  NUMBER(5) DEFAULT 0,
    min_stock_qty   NUMBER(15,4) DEFAULT 0,
    max_stock_qty   NUMBER(15,4) DEFAULT 0,
    active_flag     CHAR(1) DEFAULT 'Y' CHECK (active_flag IN ('Y', 'N')),
    revision        VARCHAR2(10) DEFAULT '1.0',
    drawing_number  VARCHAR2(100),
    specification   CLOB,
    created_date    DATE DEFAULT SYSDATE,
    created_by      VARCHAR2(100) DEFAULT USER,
    updated_date    DATE DEFAULT SYSDATE,
    updated_by      VARCHAR2(100) DEFAULT USER,
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) 
        REFERENCES product_categories(category_id),
    CONSTRAINT fk_product_uom FOREIGN KEY (uom_id) 
        REFERENCES units_of_measure(uom_id)
);

-- Create BOM Header table
CREATE TABLE bom_header (
    bom_id          NUMBER(10) PRIMARY KEY,
    bom_number      VARCHAR2(50) NOT NULL UNIQUE,
    product_id      NUMBER(10) NOT NULL,
    revision        VARCHAR2(10) DEFAULT '1.0',
    bom_type        VARCHAR2(20) DEFAULT 'MANUFACTURING' 
                    CHECK (bom_type IN ('MANUFACTURING', 'ENGINEERING', 'COSTING')),
    status          VARCHAR2(20) DEFAULT 'ACTIVE' 
                    CHECK (status IN ('ACTIVE', 'INACTIVE', 'PENDING', 'OBSOLETE')),
    effective_date  DATE DEFAULT SYSDATE,
    disable_date    DATE,
    lot_size        NUMBER(15,4) DEFAULT 1,
    description     VARCHAR2(500),
    created_date    DATE DEFAULT SYSDATE,
    created_by      VARCHAR2(100) DEFAULT USER,
    updated_date    DATE DEFAULT SYSDATE,
    updated_by      VARCHAR2(100) DEFAULT USER,
    CONSTRAINT fk_bom_product FOREIGN KEY (product_id) 
        REFERENCES products(product_id),
    CONSTRAINT chk_bom_dates CHECK (disable_date IS NULL OR disable_date > effective_date)
);

-- Create BOM Components table
CREATE TABLE bom_components (
    component_id    NUMBER(10) PRIMARY KEY,
    bom_id          NUMBER(10) NOT NULL,
    sequence_number NUMBER(5) NOT NULL,
    component_product_id NUMBER(10) NOT NULL,
    quantity        NUMBER(15,6) NOT NULL,
    uom_id          NUMBER(10),
    scrap_factor    NUMBER(5,4) DEFAULT 0,
    yield_factor    NUMBER(5,4) DEFAULT 1,
    operation_seq   NUMBER(5),
    reference_designator VARCHAR2(100),
    find_number     VARCHAR2(20),
    notes           VARCHAR2(1000),
    optional_flag   CHAR(1) DEFAULT 'N' CHECK (optional_flag IN ('Y', 'N')),
    phantom_flag    CHAR(1) DEFAULT 'N' CHECK (phantom_flag IN ('Y', 'N')),
    effective_date  DATE DEFAULT SYSDATE,
    disable_date    DATE,
    created_date    DATE DEFAULT SYSDATE,
    created_by      VARCHAR2(100) DEFAULT USER,
    updated_date    DATE DEFAULT SYSDATE,
    updated_by      VARCHAR2(100) DEFAULT USER,
    CONSTRAINT fk_component_bom FOREIGN KEY (bom_id) 
        REFERENCES bom_header(bom_id) ON DELETE CASCADE,
    CONSTRAINT fk_component_product FOREIGN KEY (component_product_id) 
        REFERENCES products(product_id),
    CONSTRAINT fk_component_uom FOREIGN KEY (uom_id) 
        REFERENCES units_of_measure(uom_id),
    CONSTRAINT uk_bom_sequence UNIQUE (bom_id, sequence_number),
    CONSTRAINT chk_component_dates CHECK (disable_date IS NULL OR disable_date > effective_date),
    CONSTRAINT chk_quantity_positive CHECK (quantity > 0),
    CONSTRAINT chk_scrap_factor CHECK (scrap_factor >= 0 AND scrap_factor < 1),
    CONSTRAINT chk_yield_factor CHECK (yield_factor > 0 AND yield_factor <= 1)
);

-- Create indexes for performance
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_code ON products(product_code);
CREATE INDEX idx_products_name ON products(product_name);
CREATE INDEX idx_bom_header_product ON bom_header(product_id);
CREATE INDEX idx_bom_header_number ON bom_header(bom_number);
CREATE INDEX idx_bom_components_bom ON bom_components(bom_id);
CREATE INDEX idx_bom_components_product ON bom_components(component_product_id);
CREATE INDEX idx_bom_components_seq ON bom_components(bom_id, sequence_number);

-- Add comments to tables and columns
COMMENT ON TABLE units_of_measure IS 'Reference table for units of measure';
COMMENT ON TABLE product_categories IS 'Hierarchical product categories';
COMMENT ON TABLE products IS 'Master product catalog';
COMMENT ON TABLE bom_header IS 'Bill of Materials header information';
COMMENT ON TABLE bom_components IS 'Bill of Materials component details';

COMMENT ON COLUMN products.product_type IS 'MANUFACTURED: Made in-house, PURCHASED: Bought from vendor, PHANTOM: Logical grouping';
COMMENT ON COLUMN bom_header.bom_type IS 'MANUFACTURING: Production BOM, ENGINEERING: Design BOM, COSTING: Cost rollup BOM';
COMMENT ON COLUMN bom_components.scrap_factor IS 'Expected scrap percentage (0.0 to 0.99)';
COMMENT ON COLUMN bom_components.yield_factor IS 'Expected yield percentage (0.01 to 1.0)';
COMMENT ON COLUMN bom_components.phantom_flag IS 'Y if component is a phantom assembly';

COMMIT;

PROMPT Tables created successfully!