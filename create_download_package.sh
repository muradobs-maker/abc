#!/bin/bash

# Oracle APEX BOM Application - Download Package Creator
# This script creates a complete downloadable package

echo "=================================================="
echo "Oracle APEX BOM Application - Package Creator"
echo "=================================================="

# Set package name and version
PACKAGE_NAME="oracle_apex_bom_application"
VERSION="1.0"
DATE=$(date +%Y%m%d)
PACKAGE_FILE="${PACKAGE_NAME}_v${VERSION}_${DATE}.zip"

echo "Creating package: $PACKAGE_FILE"
echo ""

# Create temporary directory for package
TEMP_DIR="temp_package"
mkdir -p $TEMP_DIR

echo "Copying files to package directory..."

# Copy all required files maintaining structure
cp install.sql $TEMP_DIR/
cp README.md $TEMP_DIR/
cp DOWNLOAD_PACKAGE.md $TEMP_DIR/

# Copy database files
mkdir -p $TEMP_DIR/database
cp database/*.sql $TEMP_DIR/database/

# Copy APEX files
mkdir -p $TEMP_DIR/apex
cp apex/*.sql $TEMP_DIR/apex/

# Copy documentation
mkdir -p $TEMP_DIR/documentation
cp documentation/*.md $TEMP_DIR/documentation/

echo "Files copied successfully!"
echo ""

# Create the zip package
echo "Creating zip archive..."
cd $TEMP_DIR
zip -r ../$PACKAGE_FILE . -x "*.git*" "*.DS_Store*"
cd ..

# Clean up temporary directory
rm -rf $TEMP_DIR

echo ""
echo "=================================================="
echo "Package created successfully!"
echo "=================================================="
echo "Package file: $PACKAGE_FILE"
echo "Package size: $(du -h $PACKAGE_FILE | cut -f1)"
echo ""

# Display package contents
echo "Package contents:"
unzip -l $PACKAGE_FILE

echo ""
echo "=================================================="
echo "Download Instructions:"
echo "=================================================="
echo "1. Download the file: $PACKAGE_FILE"
echo "2. Extract to your desired location"
echo "3. Follow installation instructions in README.md"
echo "4. Run: sqlplus user/pass@db @install.sql"
echo "5. Import apex/bom_application.sql via APEX admin"
echo ""
echo "Total installation time: 5-10 minutes"
echo "=================================================="