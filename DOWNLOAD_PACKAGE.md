# Oracle APEX BOM Application - Download Package

## Complete File List for Download

This package contains all the files needed to deploy the Oracle APEX Bill of Materials (BOM) Application.

### 📁 Core Installation Files

#### 1. **install.sql** (Main Installation Script)
- **Purpose**: Master installation script that runs all components in sequence
- **Usage**: `sqlplus username/password@database @install.sql`
- **Size**: 4.0KB
- **Required**: Yes - Start here for complete installation

#### 2. **README.md** (Project Overview)
- **Purpose**: Project documentation and quick start guide
- **Size**: 1.3KB
- **Required**: Yes - Read first for project understanding

### 📁 Database Components (`/database/`)

#### 3. **01_create_tables.sql** (Database Schema)
- **Purpose**: Creates all database tables with constraints and indexes
- **Size**: 6.8KB (153 lines)
- **Tables Created**: 5 tables (UNITS_OF_MEASURE, PRODUCT_CATEGORIES, PRODUCTS, BOM_HEADER, BOM_COMPONENTS)
- **Required**: Yes

#### 4. **02_create_sequences.sql** (Sequences and Triggers)
- **Purpose**: Creates sequences for auto-incrementing IDs and audit triggers
- **Size**: 3.3KB (161 lines)
- **Components**: 5 sequences, 10 triggers
- **Required**: Yes

#### 5. **03_sample_data.sql** (Sample Data and Views)
- **Purpose**: Loads sample data and creates BOM explosion/costing views
- **Size**: 13KB (252 lines)
- **Data**: 16 products, 3 BOMs, 10 UOMs, 11 categories
- **Required**: Optional (recommended for testing)

### 📁 Oracle APEX Application (`/apex/`)

#### 6. **bom_application.sql** (APEX Application Export)
- **Purpose**: Complete Oracle APEX application export file
- **Size**: 16KB (536 lines)
- **Application ID**: 100
- **Pages**: 4 pages (Dashboard, Products, BOM Management, BOM Explosion)
- **Required**: Yes - Import after database setup

### 📁 Documentation (`/documentation/`)

#### 7. **user_guide.md** (Complete User Guide)
- **Purpose**: Comprehensive user documentation
- **Size**: 9.8KB (326 lines)
- **Contents**: Installation, configuration, usage instructions
- **Required**: Recommended

## 📦 Download Instructions

### Option 1: Individual File Download
Download each file separately:
- Right-click on each file and "Save As"
- Maintain the directory structure as shown above

### Option 2: Complete Package Download
Create a zip archive of all files:

```bash
# Create download package
zip -r bom_application_package.zip \
    install.sql \
    README.md \
    database/ \
    apex/ \
    documentation/
```

### Option 3: Git Clone
```bash
git clone <repository-url>
cd bom-application
```

## 🚀 Quick Installation Steps

1. **Download all files** maintaining directory structure
2. **Run database installation**: `sqlplus user/pass@db @install.sql`
3. **Import APEX application**: Import `apex/bom_application.sql` via APEX admin
4. **Configure application** as needed
5. **Read user guide** in `documentation/user_guide.md`

## 📋 File Checksums (for integrity verification)

| File | Size | Type |
|------|------|------|
| install.sql | 4.0KB | Installation Script |
| README.md | 1.3KB | Documentation |
| database/01_create_tables.sql | 6.8KB | Database Schema |
| database/02_create_sequences.sql | 3.3KB | Sequences/Triggers |
| database/03_sample_data.sql | 13KB | Sample Data |
| apex/bom_application.sql | 16KB | APEX Application |
| documentation/user_guide.md | 9.8KB | User Guide |

## 🔧 System Requirements

- **Database**: Oracle 12c or higher
- **APEX**: Version 20.1 or higher
- **Storage**: Minimum 100MB
- **Privileges**: CREATE TABLE, CREATE SEQUENCE, CREATE TRIGGER

## 📞 Support

For installation issues or questions, refer to:
1. `README.md` for quick start
2. `documentation/user_guide.md` for detailed instructions
3. Check database logs for any installation errors

---

**Total Package Size**: ~53KB
**Installation Time**: 5-10 minutes
**Complexity**: Intermediate (requires Oracle DBA knowledge)