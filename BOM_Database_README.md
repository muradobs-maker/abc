# Bill of Materials (BOM) Database System

A comprehensive database schema for managing Bill of Materials in manufacturing and product development environments.

## Overview

This BOM database system supports:
- Multi-level BOMs with parent-child relationships
- Version control for BOMs
- Component sourcing and supplier management
- Cost tracking and rollup calculations
- Change history and audit trails
- Where-used analysis
- BOM comparison between versions

## Database Schema

### Core Tables

1. **`products`** - Master catalog of all parts, components, and assemblies
2. **`bom_headers`** - BOM versions and metadata
3. **`bom_items`** - Individual line items in each BOM
4. **`suppliers`** - Vendor/supplier information
5. **`bom_change_history`** - Audit trail for BOM changes

### Key Features

- **Multi-level BOMs**: Support for complex assemblies with sub-assemblies
- **Version Control**: Track different versions of BOMs with effective dates
- **Cost Rollup**: Automatic calculation of assembly costs from component costs
- **Supplier Management**: Link components to suppliers with contact information
- **Change Tracking**: Complete audit trail of all BOM modifications
- **Flexible Classification**: Categorize parts as purchased, manufactured, or assembly

## Setup Instructions

### 1. Create Database
```sql
-- Create a new PostgreSQL database
CREATE DATABASE bom_system;
```

### 2. Run Schema Creation
```bash
# Execute the schema file
psql -d bom_system -f bom_schema.sql
```

### 3. Load Sample Data (Optional)
```bash
# Load sample data for testing
psql -d bom_system -f bom_sample_data.sql
```

## Usage Examples

### Basic Queries

#### Get BOM for a Product
```sql
SELECT 
    p.part_number as parent_part,
    c.part_number as component_part,
    c.name as component_name,
    bi.quantity,
    c.cost,
    (bi.quantity * c.cost) as extended_cost
FROM bom_headers bh
JOIN products p ON bh.product_id = p.id
JOIN bom_items bi ON bh.id = bi.bom_header_id
JOIN products c ON bi.component_id = c.id
WHERE p.part_number = 'DEVICE-001'
    AND bh.status = 'active'
ORDER BY bi.find_number;
```

#### Multi-level BOM Explosion
The system includes recursive queries to "explode" multi-level BOMs, showing all components at all levels with proper quantities.

#### Where-Used Analysis
Find all assemblies that use a specific component:
```sql
SELECT 
    c.part_number as component,
    p.part_number as used_in_assembly,
    bi.quantity
FROM products c
JOIN bom_items bi ON c.id = bi.component_id
JOIN bom_headers bh ON bi.bom_header_id = bh.id
JOIN products p ON bh.product_id = p.id
WHERE c.part_number = 'RES-100K-0805'
    AND bh.status = 'active';
```

### Advanced Features

#### Cost Rollup
Calculate total cost of assemblies including all sub-components.

#### BOM Comparison
Compare different versions of the same BOM to identify changes.

#### Change History
Track all modifications with timestamps and user information.

## File Structure

- `bom_schema.sql` - Complete database schema with tables, indexes, and triggers
- `bom_queries.sql` - Collection of useful queries for common BOM operations
- `bom_sample_data.sql` - Sample data for testing and demonstration
- `BOM_Database_README.md` - This documentation file

## Sample Data

The sample data includes:
- Electronic components (resistors, capacitors, microcontrollers)
- PCB assemblies with reference designators
- Complete device with enclosure and fasteners
- Multiple BOM versions showing evolution
- Supplier information with contact details

### Sample Products
- `DEVICE-001` - Complete smart controller device
- `PCB-ASSY-V1` - PCB assembly (sub-assembly)
- Various electronic components and hardware

## Key Concepts

### Product Types
- **Purchased Parts**: Components bought from suppliers
- **Manufactured Parts**: Parts made in-house
- **Assemblies**: Products made from other components

### BOM Hierarchy
```
DEVICE-001 (Top Level)
├── PCB-ASSY-V1 (Sub-assembly)
│   ├── PCB-MAIN-V1
│   ├── IC-MCU-STM32
│   ├── RES-100K-0805 (Qty: 10)
│   └── CAP-10UF-0805 (Qty: 5)
├── CASE-PLASTIC
└── SCREW-M3-10 (Qty: 4)
```

### Version Control
- Each BOM can have multiple versions (V1.0, V1.1, etc.)
- Versions have effective dates and status (draft, active, obsolete)
- Changes are tracked in the history table

## Performance Considerations

- Indexes are created on frequently queried columns
- Recursive queries for multi-level BOMs may be resource-intensive for very deep structures
- Consider partitioning for very large datasets
- Regular maintenance of statistics for optimal query performance

## Extension Possibilities

- Integration with ERP systems
- CAD file associations
- Inventory level tracking
- Lead time management
- Approved vendor lists
- Cost history tracking
- Manufacturing routing integration

## Best Practices

1. **Naming Conventions**: Use consistent part numbering schemes
2. **Version Control**: Always create new versions rather than modifying active BOMs
3. **Data Integrity**: Maintain referential integrity between products and BOMs
4. **Change Management**: Document all changes with proper reasoning
5. **Regular Audits**: Review and validate BOM accuracy periodically