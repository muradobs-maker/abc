-- Oracle APEX BOM Application Export
-- Application ID: 100
-- Application Name: Bill of Materials Management
-- Version: 1.0

prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050000 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2021.04.15'
,p_release=>'21.1.0.00.10'
,p_default_workspace_id=>1234567890
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'BOM_USER'
);
end;
/

-- Application Definition
prompt --application/create_application
begin
wwv_flow_api.create_application(
 p_id=>100
,p_owner=>'BOM_USER'
,p_name=>'Bill of Materials Management'
,p_alias=>'BOM_MGMT'
,p_page_view_logging=>'YES'
,p_page_protection_enabled_y_n=>'Y'
,p_checksum_salt=>'BOM_SALT_2024'
,p_bookmark_checksum_function=>'SH1'
,p_compatibility_mode=>'21.1'
,p_flow_language=>'en'
,p_flow_language_derived_from=>'FLOW_PRIMARY_LANGUAGE'
,p_allow_feedback=>'Y'
,p_date_format=>'DS'
,p_timestamp_format=>'DS'
,p_direction_right_to_left=>'N'
,p_flow_image_prefix => wwv_flow_string.join(wwv_flow_t_varchar2(
'#APP_IMAGES#'))
,p_authentication=>'PLUGIN'
,p_authentication_id=>wwv_flow_api.id(12345678901234567890)
,p_application_tab_set=>1
,p_logo_type=>'T'
,p_logo_text=>'BOM Management'
,p_public_url_prefix=>'https://apex.oracle.com/pls/apex/'
,p_on_demand_process_prefix=>'ORA_WWV_APP_'
,p_proxy_server=> wwv_flow_string.join(wwv_flow_t_varchar2(
'PROXY_URL'))
,p_no_proxy_domains=> wwv_flow_string.join(wwv_flow_t_varchar2(
'localhost',
'127.0.0.1',
'company.com'))
,p_flow_version=>'1.0'
,p_flow_status=>'AVAILABLE_W_EDIT_LINK'
,p_flow_unavailable_text=>'This application is currently unavailable at this time.'
,p_exact_substitutions_only=>'Y'
,p_browser_cache=>'N'
,p_browser_frame=>'D'
,p_rejoin_existing_sessions=>'N'
,p_csv_encoding=>'Y'
,p_auto_time_zone=>'N'
,p_substitution_string_01=>'APP_NAME'
,p_substitution_value_01=>'Bill of Materials Management'
,p_last_updated_by=>'BOM_USER'
,p_last_upd_yyyymmddhh24miss=>'20240101120000'
,p_file_prefix => nvl(wwv_flow_application_install.get_static_app_file_prefix,100)
,p_files_version=>3
,p_ui_type_name => null
);
end;
/

-- Page 1: Dashboard
prompt --application/pages/page_00001
begin
wwv_flow_api.create_page(
 p_id=>1
,p_user_interface_id=>wwv_flow_api.id(12345678901234567890)
,p_name=>'BOM Dashboard'
,p_alias=>'HOME'
,p_step_title=>'Bill of Materials Dashboard'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_last_updated_by=>'BOM_USER'
,p_last_upd_yyyymmddhh24miss=>'20240101120000'
);

-- Dashboard Cards Region
wwv_flow_api.create_page_plug(
 p_id=>wwv_flow_api.id(1001)
,p_plug_name=>'Dashboard Cards'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_api.id(12345678901234567890)
,p_plug_display_sequence=>10
,p_plug_display_point=>'BODY'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ''Products'' as card_title,',
'       COUNT(*) as card_value,',
'       ''Total products in catalog'' as card_subtitle,',
'       ''fa-cube'' as card_icon',
'FROM products',
'WHERE active_flag = ''Y''',
'UNION ALL',
'SELECT ''Active BOMs'' as card_title,',
'       COUNT(*) as card_value,',
'       ''Active bill of materials'' as card_subtitle,',
'       ''fa-list-alt'' as card_icon',
'FROM bom_header',
'WHERE status = ''ACTIVE''',
'UNION ALL',
'SELECT ''Categories'' as card_title,',
'       COUNT(*) as card_value,',
'       ''Product categories'' as card_subtitle,',
'       ''fa-tags'' as card_icon',
'FROM product_categories',
'WHERE active_flag = ''Y''',
'UNION ALL',
'SELECT ''Components'' as card_title,',
'       COUNT(*) as card_value,',
'       ''Total BOM components'' as card_subtitle,',
'       ''fa-cogs'' as card_icon',
'FROM bom_components'))
,p_plug_source_type=>'NATIVE_CARDS'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
end;
/

-- Page 2: Products
prompt --application/pages/page_00002
begin
wwv_flow_api.create_page(
 p_id=>2
,p_user_interface_id=>wwv_flow_api.id(12345678901234567890)
,p_name=>'Products'
,p_alias=>'PRODUCTS'
,p_step_title=>'Product Management'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_last_updated_by=>'BOM_USER'
,p_last_upd_yyyymmddhh24miss=>'20240101120000'
);

-- Products Interactive Report
wwv_flow_api.create_page_plug(
 p_id=>wwv_flow_api.id(2001)
,p_plug_name=>'Products'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_api.id(12345678901234567890)
,p_plug_display_sequence=>10
,p_plug_display_point=>'BODY'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT p.product_id,',
'       p.product_code,',
'       p.product_name,',
'       p.description,',
'       pc.category_name,',
'       p.product_type,',
'       u.uom_code,',
'       p.standard_cost,',
'       p.list_price,',
'       p.lead_time_days,',
'       p.active_flag,',
'       p.revision',
'FROM products p',
'LEFT JOIN product_categories pc ON p.category_id = pc.category_id',
'LEFT JOIN units_of_measure u ON p.uom_id = u.uom_id',
'ORDER BY p.product_code'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
,p_prn_content_disposition=>'ATTACHMENT'
,p_prn_document_header=>'APEX'
,p_prn_units=>'INCHES'
,p_prn_paper_size=>'LETTER'
,p_prn_width=>11
,p_prn_height=>8.5
,p_prn_orientation=>'HORIZONTAL'
,p_prn_page_header=>'Products Report'
,p_prn_page_footer_font_color=>'#000000'
,p_prn_page_footer_font_family=>'Helvetica'
,p_prn_page_footer_font_weight=>'normal'
,p_prn_page_footer_font_size=>'12'
,p_prn_header_bg_color=>'#EEEEEE'
,p_prn_header_font_color=>'#000000'
,p_prn_header_font_family=>'Helvetica'
,p_prn_header_font_weight=>'bold'
,p_prn_header_font_size=>'10'
,p_prn_body_bg_color=>'#FFFFFF'
,p_prn_body_font_color=>'#000000'
,p_prn_body_font_family=>'Helvetica'
,p_prn_body_font_weight=>'normal'
,p_prn_body_font_size=>'10'
,p_prn_border_width=>.5
,p_prn_page_header_alignment=>'CENTER'
,p_prn_page_footer_alignment=>'CENTER'
,p_prn_border_color=>'#666666'
);
end;
/

-- Page 3: BOM Management
prompt --application/pages/page_00003
begin
wwv_flow_api.create_page(
 p_id=>3
,p_user_interface_id=>wwv_flow_api.id(12345678901234567890)
,p_name=>'BOM Management'
,p_alias=>'BOM_MGMT'
,p_step_title=>'Bill of Materials Management'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_last_updated_by=>'BOM_USER'
,p_last_upd_yyyymmddhh24miss=>'20240101120000'
);

-- BOM Header Region
wwv_flow_api.create_page_plug(
 p_id=>wwv_flow_api.id(3001)
,p_plug_name=>'BOM Headers'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_api.id(12345678901234567890)
,p_plug_display_sequence=>10
,p_plug_display_point=>'BODY'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT bh.bom_id,',
'       bh.bom_number,',
'       p.product_code,',
'       p.product_name,',
'       bh.revision,',
'       bh.bom_type,',
'       bh.status,',
'       bh.effective_date,',
'       bh.disable_date,',
'       bh.description',
'FROM bom_header bh',
'JOIN products p ON bh.product_id = p.product_id',
'ORDER BY bh.bom_number'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);

-- BOM Components Region
wwv_flow_api.create_page_plug(
 p_id=>wwv_flow_api.id(3002)
,p_plug_name=>'BOM Components'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_api.id(12345678901234567890)
,p_plug_display_sequence=>20
,p_plug_display_point=>'BODY'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT bc.component_id,',
'       bh.bom_number,',
'       bc.sequence_number,',
'       cp.product_code as component_code,',
'       cp.product_name as component_name,',
'       bc.quantity,',
'       u.uom_code,',
'       bc.reference_designator,',
'       bc.find_number,',
'       bc.notes',
'FROM bom_components bc',
'JOIN bom_header bh ON bc.bom_id = bh.bom_id',
'JOIN products cp ON bc.component_product_id = cp.product_id',
'LEFT JOIN units_of_measure u ON bc.uom_id = u.uom_id',
'WHERE (:P3_BOM_ID IS NULL OR bh.bom_id = :P3_BOM_ID)',
'ORDER BY bh.bom_number, bc.sequence_number'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
end;
/

-- Page 4: BOM Explosion
prompt --application/pages/page_00004
begin
wwv_flow_api.create_page(
 p_id=>4
,p_user_interface_id=>wwv_flow_api.id(12345678901234567890)
,p_name=>'BOM Explosion'
,p_alias=>'BOM_EXPLOSION'
,p_step_title=>'BOM Explosion View'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_last_updated_by=>'BOM_USER'
,p_last_upd_yyyymmddhh24miss=>'20240101120000'
);

-- BOM Tree Region
wwv_flow_api.create_page_plug(
 p_id=>wwv_flow_api.id(4001)
,p_plug_name=>'BOM Tree Structure'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_api.id(12345678901234567890)
,p_plug_display_sequence=>10
,p_plug_display_point=>'BODY'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT product_id,',
'       product_code,',
'       product_name,',
'       component_product_id,',
'       component_code,',
'       component_name,',
'       quantity,',
'       uom_code,',
'       bom_level,',
'       LPAD('' '', (bom_level-1)*4, '' '') || component_code as indented_component,',
'       reference_designator,',
'       find_number,',
'       notes',
'FROM v_bom_explosion',
'WHERE (:P4_PRODUCT_ID IS NULL OR product_id = :P4_PRODUCT_ID)',
'ORDER BY product_id, sort_path'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
end;
/

-- Page 5: BOM Costing
prompt --application/pages/page_00005
begin
wwv_flow_api.create_page(
 p_id=>5
,p_user_interface_id=>wwv_flow_api.id(12345678901234567890)
,p_name=>'BOM Costing'
,p_alias=>'BOM_COSTING'
,p_step_title=>'BOM Cost Analysis'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_last_updated_by=>'BOM_USER'
,p_last_upd_yyyymmddhh24miss=>'20240101120000'
);

-- BOM Cost Summary
wwv_flow_api.create_page_plug(
 p_id=>wwv_flow_api.id(5001)
,p_plug_name=>'BOM Cost Summary'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_api.id(12345678901234567890)
,p_plug_display_sequence=>10
,p_plug_display_point=>'BODY'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT bom_number,',
'       product_code,',
'       product_name,',
'       COUNT(*) as component_count,',
'       SUM(extended_cost) as total_cost,',
'       AVG(unit_cost) as avg_component_cost,',
'       MAX(extended_cost) as highest_cost_component',
'FROM v_bom_costing',
'GROUP BY bom_number, product_code, product_name',
'ORDER BY total_cost DESC'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);

-- Detailed Cost Breakdown
wwv_flow_api.create_page_plug(
 p_id=>wwv_flow_api.id(5002)
,p_plug_name=>'Detailed Cost Breakdown'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_api.id(12345678901234567890)
,p_plug_display_sequence=>20
,p_plug_display_point=>'BODY'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT bom_number,',
'       sequence_number,',
'       component_code,',
'       component_name,',
'       quantity,',
'       uom_code,',
'       unit_cost,',
'       extended_cost,',
'       ROUND((extended_cost / SUM(extended_cost) OVER (PARTITION BY bom_number)) * 100, 2) as cost_percentage,',
'       reference_designator,',
'       find_number',
'FROM v_bom_costing',
'WHERE (:P5_BOM_NUMBER IS NULL OR bom_number = :P5_BOM_NUMBER)',
'ORDER BY bom_number, extended_cost DESC'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
end;
/

-- Navigation Menu
prompt --application/shared_components/navigation/lists/navigation_menu
begin
wwv_flow_api.create_list(
 p_id=>wwv_flow_api.id(6001)
,p_name=>'Navigation Menu'
,p_list_status=>'PUBLIC'
);

wwv_flow_api.create_list_item(
 p_id=>wwv_flow_api.id(6002)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'Dashboard'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-dashboard'
,p_list_item_current_type=>'TARGET_PAGE'
);

wwv_flow_api.create_list_item(
 p_id=>wwv_flow_api.id(6003)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'Products'
,p_list_item_link_target=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-cube'
,p_list_item_current_type=>'TARGET_PAGE'
);

wwv_flow_api.create_list_item(
 p_id=>wwv_flow_api.id(6004)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'BOM Management'
,p_list_item_link_target=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-list-alt'
,p_list_item_current_type=>'TARGET_PAGE'
);

wwv_flow_api.create_list_item(
 p_id=>wwv_flow_api.id(6005)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'BOM Explosion'
,p_list_item_link_target=>'f?p=&APP_ID.:4:&SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-sitemap'
,p_list_item_current_type=>'TARGET_PAGE'
);

wwv_flow_api.create_list_item(
 p_id=>wwv_flow_api.id(6006)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>'BOM Costing'
,p_list_item_link_target=>'f?p=&APP_ID.:5:&SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-dollar'
,p_list_item_current_type=>'TARGET_PAGE'
);
end;
/

-- Application Items
prompt --application/shared_components/logic/application_items
begin
wwv_flow_api.create_flow_item(
 p_id=>wwv_flow_api.id(7001)
,p_name=>'G_USER_ID'
,p_protection_level=>'I'
);

wwv_flow_api.create_flow_item(
 p_id=>wwv_flow_api.id(7002)
,p_name=>'G_COMPANY_NAME'
,p_protection_level=>'I'
);
end;
/

-- Application Processes
prompt --application/shared_components/logic/application_processes
begin
wwv_flow_api.create_flow_process(
 p_id=>wwv_flow_api.id(8001)
,p_process_sequence=>1
,p_process_point=>'AFTER_LOGIN'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Set User Context'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'    :G_USER_ID := :APP_USER;',
'    :G_COMPANY_NAME := ''BOM Management System'';',
'END;'))
,p_process_clob_language=>'PLSQL'
);
end;
/

-- Finalize Application
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/

-- Installation Notes
PROMPT 
PROMPT ====================================================
PROMPT Oracle APEX BOM Application Installation Complete
PROMPT ====================================================
PROMPT 
PROMPT Application Details:
PROMPT - Application ID: 100
PROMPT - Application Name: Bill of Materials Management  
PROMPT - Alias: BOM_MGMT
PROMPT 
PROMPT Pages Created:
PROMPT 1. Dashboard - Overview of system statistics
PROMPT 2. Products - Product catalog management
PROMPT 3. BOM Management - BOM header and component management
PROMPT 4. BOM Explosion - Hierarchical BOM structure view
PROMPT 5. BOM Costing - Cost analysis and breakdown
PROMPT 
PROMPT Next Steps:
PROMPT 1. Import this application into your APEX workspace
PROMPT 2. Run the database setup scripts (01, 02, 03)
PROMPT 3. Configure authentication as needed
PROMPT 4. Customize themes and templates
PROMPT 5. Add additional validation and business rules
PROMPT 
PROMPT For support and documentation, refer to the user guide
PROMPT ====================================================