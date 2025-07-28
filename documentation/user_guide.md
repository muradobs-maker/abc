# Oracle APEX Bill of Materials (BOM) Application - User Guide

## Table of Contents
1. [Introduction](#introduction)
2. [System Requirements](#system-requirements)
3. [Installation Guide](#installation-guide)
4. [Application Overview](#application-overview)
5. [User Interface Guide](#user-interface-guide)
6. [Feature Documentation](#feature-documentation)
7. [Troubleshooting](#troubleshooting)
8. [FAQ](#faq)

## Introduction

The Oracle APEX Bill of Materials (BOM) Application is a comprehensive solution for managing product structures, components, and cost analysis in manufacturing environments. This application provides hierarchical BOM management with multi-level explosion capabilities, cost rollup, and detailed reporting.

### Key Features
- **Product Catalog Management**: Maintain master product data with categories and specifications
- **Hierarchical BOM Structure**: Define and manage multi-level bill of materials
- **BOM Explosion**: View complete product structures with recursive component breakdown
- **Cost Analysis**: Calculate and analyze product costs at all levels
- **Interactive Reporting**: Flexible reports with search, filter, and export capabilities
- **Audit Trail**: Track all changes with user and timestamp information

## System Requirements

### Database Requirements
- Oracle Database 12c or higher
- Oracle APEX 20.1 or higher
- Minimum 100MB of database storage
- PL/SQL execution privileges

### Browser Requirements
- Chrome 80+, Firefox 75+, Safari 13+, Edge 80+
- JavaScript enabled
- Minimum screen resolution: 1024x768

## Installation Guide

### Step 1: Database Setup

1. **Connect to your Oracle database** as a user with CREATE TABLE privileges:
   ```sql
   sqlplus username/password@database
   ```

2. **Run the database scripts in order**:
   ```sql
   @database/01_create_tables.sql
   @database/02_create_sequences.sql
   @database/03_sample_data.sql
   ```

3. **Verify installation**:
   ```sql
   SELECT COUNT(*) FROM products;
   SELECT COUNT(*) FROM bom_header;
   ```

### Step 2: APEX Application Import

1. **Log into APEX workspace** as a developer
2. **Navigate to App Builder**
3. **Click "Import"**
4. **Select the application file**: `apex/bom_application.sql`
5. **Follow the import wizard**:
   - Choose "Reuse Application ID 100" or assign new ID
   - Set parsing schema to your database user
   - Click "Install Application"

### Step 3: Post-Installation Configuration

1. **Set Authentication** (if required):
   - Go to Shared Components > Authentication Schemes
   - Configure according to your organization's requirements

2. **Test the Application**:
   - Run the application
   - Verify all pages load correctly
   - Check sample data is visible

## Application Overview

### Navigation Structure
The application consists of five main pages accessible through the navigation menu:

1. **Dashboard** - Overview and key metrics
2. **Products** - Product catalog management
3. **BOM Management** - BOM header and component maintenance
4. **BOM Explosion** - Hierarchical structure view
5. **BOM Costing** - Cost analysis and reporting

### Data Model Overview
```
PRODUCTS (Master Data)
    ↓
BOM_HEADER (BOM Definitions)
    ↓
BOM_COMPONENTS (Component Details)
    ↓
Recursive relationship for sub-assemblies
```

## User Interface Guide

### Dashboard Page
The dashboard provides a high-level overview of the system with key performance indicators:

- **Products Card**: Total number of active products
- **Active BOMs Card**: Number of active bill of materials
- **Categories Card**: Product category count
- **Components Card**: Total BOM components

### Products Page
Interactive report showing all products with the following columns:
- Product Code, Name, Description
- Category, Product Type, Unit of Measure
- Standard Cost, List Price, Lead Time
- Active Flag, Revision

**Available Actions**:
- Search and filter products
- Sort by any column
- Export to Excel/PDF
- Create new products (if edit privileges granted)

### BOM Management Page
Two-section page for managing BOMs:

**BOM Headers Section**:
- Lists all BOM headers with product information
- Shows BOM number, revision, type, status
- Effective and disable dates

**BOM Components Section**:
- Shows components for selected BOM
- Displays sequence, component details, quantities
- Reference designators and find numbers

### BOM Explosion Page
Hierarchical view of complete product structures:
- Tree-like display with indentation showing BOM levels
- Recursive expansion of sub-assemblies
- Quantity rollup calculations
- Full traceability from top-level to lowest component

### BOM Costing Page
Two-section cost analysis:

**Cost Summary Section**:
- Total cost per BOM
- Component count and average costs
- Highest cost component identification

**Detailed Cost Breakdown Section**:
- Line-by-line cost details
- Extended costs and percentages
- Cost contribution analysis

## Feature Documentation

### Product Management

#### Creating Products
1. Navigate to Products page
2. Click "Create" button
3. Fill required fields:
   - Product Code (unique identifier)
   - Product Name
   - Category and Unit of Measure
   - Product Type (Manufactured/Purchased/Phantom)
4. Set cost and lead time information
5. Save the product

#### Product Types
- **Manufactured**: Items produced in-house
- **Purchased**: Items bought from suppliers
- **Phantom**: Logical groupings (not physically stocked)

### BOM Creation and Management

#### Creating a New BOM
1. Go to BOM Management page
2. Create BOM Header:
   - Select parent product
   - Set BOM type and revision
   - Define effective dates
3. Add Components:
   - Set sequence numbers
   - Select component products
   - Enter quantities and units
   - Add reference designators

#### BOM Types
- **Manufacturing**: Production BOMs for shop floor
- **Engineering**: Design BOMs for development
- **Costing**: BOMs specifically for cost analysis

### BOM Explosion Analysis

#### Using the BOM Explosion
1. Navigate to BOM Explosion page
2. Select a product from the filter
3. View the complete structure:
   - Level 1 shows direct components
   - Level 2+ shows sub-assembly components
   - Quantities are automatically calculated

#### Understanding BOM Levels
- **Level 0**: Top-level finished product
- **Level 1**: Direct components of finished product
- **Level 2+**: Components of sub-assemblies

### Cost Analysis

#### Cost Rollup Methodology
The system calculates costs using:
- Component standard costs
- Quantity requirements
- Scrap and yield factors
- Recursive calculation for sub-assemblies

#### Cost Reports
- **Summary View**: Total costs by BOM
- **Detailed View**: Line-by-line cost breakdown
- **Percentage Analysis**: Cost contribution by component

## Troubleshooting

### Common Issues

#### "Table or view does not exist" Error
**Cause**: Database objects not created properly
**Solution**: Re-run the database setup scripts in order

#### "No data found" on Reports
**Cause**: Sample data not loaded or filters too restrictive
**Solution**: 
1. Check if sample data was loaded: `SELECT COUNT(*) FROM products;`
2. Clear all filters on the report
3. Re-run sample data script if needed

#### Performance Issues
**Cause**: Large datasets or missing indexes
**Solution**:
1. Check if indexes were created: `SELECT * FROM user_indexes WHERE table_name LIKE 'BOM%';`
2. Consider adding additional indexes for frequently filtered columns
3. Limit BOM explosion depth for very deep structures

#### Authentication Problems
**Cause**: Authentication scheme misconfiguration
**Solution**:
1. Check authentication scheme settings
2. Verify user has access to parsing schema
3. Test with APEX workspace credentials

### Error Messages

#### "Recursive BOM detected"
This occurs when a component references its parent, creating a circular reference.
**Solution**: Review BOM structure and remove circular references.

#### "Invalid quantity"
Quantity must be positive and numeric.
**Solution**: Enter valid positive numbers for quantities.

## FAQ

### General Questions

**Q: Can I modify the sample data?**
A: Yes, the sample data is provided for demonstration. You can modify or delete it as needed.

**Q: How many BOM levels are supported?**
A: The system supports up to 10 levels by default. This can be modified in the recursive query.

**Q: Can I import data from other systems?**
A: Yes, you can use Oracle's data loading tools or create custom import processes.

### Technical Questions

**Q: How do I backup the BOM data?**
A: Use Oracle's export utilities:
```sql
expdp username/password@database schemas=BOM_USER directory=DATA_PUMP_DIR dumpfile=bom_backup.dmp
```

**Q: Can I customize the application?**
A: Yes, the APEX application can be customized. Make sure to export your changes before upgrades.

**Q: How do I add new fields to products?**
A: 
1. Add columns to the PRODUCTS table
2. Update the APEX application pages
3. Modify reports and forms as needed

### Business Questions

**Q: How are costs calculated for phantom items?**
A: Phantom items pass through their component costs without adding their own cost.

**Q: Can I have multiple BOMs for one product?**
A: Yes, you can have different BOM types (Manufacturing, Engineering, Costing) for the same product.

**Q: How do I handle revision control?**
A: Use the revision field and effective/disable dates to manage BOM versions.

## Support and Maintenance

### Regular Maintenance Tasks
1. **Monitor database growth**: Check table sizes regularly
2. **Update statistics**: Run DBMS_STATS.GATHER_SCHEMA_STATS periodically
3. **Review audit data**: Archive old audit records if needed
4. **Backup data**: Regular database backups

### Getting Help
- Check Oracle APEX documentation
- Review application logs for error details
- Contact your database administrator for database issues
- Refer to Oracle support for complex technical problems

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Application Version**: 1.0