# Oracle APEX Bill of Materials (BOM) Application

This project contains a complete Oracle APEX application for managing Bill of Materials (BOM) with hierarchical product structures.

## Features

- **Product Management**: Create and manage products with detailed specifications
- **BOM Structure**: Define hierarchical bill of materials with parent-child relationships
- **Component Tracking**: Track components, quantities, and costs
- **Interactive Reports**: View and manage BOMs with drill-down capabilities
- **Cost Calculation**: Automatic cost rollup from components to finished products
- **Search & Filter**: Advanced search and filtering capabilities

## Database Structure

- `PRODUCTS`: Master product catalog
- `BOM_HEADER`: BOM header information
- `BOM_COMPONENTS`: BOM line items and components
- `PRODUCT_CATEGORIES`: Product categorization
- `UNITS_OF_MEASURE`: Unit of measure reference

## Installation

1. Run the database setup scripts in order:
   - `01_create_tables.sql`
   - `02_create_sequences.sql`
   - `03_sample_data.sql`
2. Import the APEX application from `bom_application.sql`
3. Configure application settings as needed

## Directory Structure

```
/database/
  ├── 01_create_tables.sql
  ├── 02_create_sequences.sql
  └── 03_sample_data.sql
/apex/
  └── bom_application.sql
/documentation/
  └── user_guide.md
```
