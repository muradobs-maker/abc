-- Oracle APEX BOM Application - Sequences Creation Script
-- Version: 1.0
-- Created: 2024

-- Drop sequences if they exist
DROP SEQUENCE seq_uom_id;
DROP SEQUENCE seq_category_id;
DROP SEQUENCE seq_product_id;
DROP SEQUENCE seq_bom_id;
DROP SEQUENCE seq_component_id;

-- Create sequence for Units of Measure
CREATE SEQUENCE seq_uom_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOMAXVALUE
    MINVALUE 1;

-- Create sequence for Product Categories
CREATE SEQUENCE seq_category_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOMAXVALUE
    MINVALUE 1;

-- Create sequence for Products
CREATE SEQUENCE seq_product_id
    START WITH 1000
    INCREMENT BY 1
    NOCACHE
    NOMAXVALUE
    MINVALUE 1000;

-- Create sequence for BOM Header
CREATE SEQUENCE seq_bom_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOMAXVALUE
    MINVALUE 1;

-- Create sequence for BOM Components
CREATE SEQUENCE seq_component_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOMAXVALUE
    MINVALUE 1;

-- Create triggers for auto-incrementing primary keys

-- Trigger for Units of Measure
CREATE OR REPLACE TRIGGER trg_uom_id
    BEFORE INSERT ON units_of_measure
    FOR EACH ROW
BEGIN
    IF :NEW.uom_id IS NULL THEN
        :NEW.uom_id := seq_uom_id.NEXTVAL;
    END IF;
END;
/

-- Trigger for Product Categories
CREATE OR REPLACE TRIGGER trg_category_id
    BEFORE INSERT ON product_categories
    FOR EACH ROW
BEGIN
    IF :NEW.category_id IS NULL THEN
        :NEW.category_id := seq_category_id.NEXTVAL;
    END IF;
END;
/

-- Trigger for Products
CREATE OR REPLACE TRIGGER trg_product_id
    BEFORE INSERT ON products
    FOR EACH ROW
BEGIN
    IF :NEW.product_id IS NULL THEN
        :NEW.product_id := seq_product_id.NEXTVAL;
    END IF;
END;
/

-- Trigger for BOM Header
CREATE OR REPLACE TRIGGER trg_bom_id
    BEFORE INSERT ON bom_header
    FOR EACH ROW
BEGIN
    IF :NEW.bom_id IS NULL THEN
        :NEW.bom_id := seq_bom_id.NEXTVAL;
    END IF;
    -- Auto-generate BOM number if not provided
    IF :NEW.bom_number IS NULL THEN
        :NEW.bom_number := 'BOM-' || LPAD(:NEW.bom_id, 6, '0');
    END IF;
END;
/

-- Trigger for BOM Components
CREATE OR REPLACE TRIGGER trg_component_id
    BEFORE INSERT ON bom_components
    FOR EACH ROW
BEGIN
    IF :NEW.component_id IS NULL THEN
        :NEW.component_id := seq_component_id.NEXTVAL;
    END IF;
END;
/

-- Create audit triggers for tracking updates
CREATE OR REPLACE TRIGGER trg_uom_audit
    BEFORE UPDATE ON units_of_measure
    FOR EACH ROW
BEGIN
    :NEW.updated_date := SYSDATE;
    :NEW.updated_by := USER;
END;
/

CREATE OR REPLACE TRIGGER trg_category_audit
    BEFORE UPDATE ON product_categories
    FOR EACH ROW
BEGIN
    :NEW.updated_date := SYSDATE;
    :NEW.updated_by := USER;
END;
/

CREATE OR REPLACE TRIGGER trg_product_audit
    BEFORE UPDATE ON products
    FOR EACH ROW
BEGIN
    :NEW.updated_date := SYSDATE;
    :NEW.updated_by := USER;
END;
/

CREATE OR REPLACE TRIGGER trg_bom_header_audit
    BEFORE UPDATE ON bom_header
    FOR EACH ROW
BEGIN
    :NEW.updated_date := SYSDATE;
    :NEW.updated_by := USER;
END;
/

CREATE OR REPLACE TRIGGER trg_bom_component_audit
    BEFORE UPDATE ON bom_components
    FOR EACH ROW
BEGIN
    :NEW.updated_date := SYSDATE;
    :NEW.updated_by := USER;
END;
/

COMMIT;

PROMPT Sequences and triggers created successfully!