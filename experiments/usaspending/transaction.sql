COPY (
SELECT regexp_replace(recipient_unique_id, '[,\n]', ' ', 'g') AS recipient_unique_id
, transaction_id                       
, action_date                          
, last_modified_date                   
, fiscal_year                          
, award_id                             
, generated_pragmatic_obligation       
, total_obligation                     
, total_subsidy_cost                   
, total_loan_value                     
, total_obl_bin                        
, federal_action_obligation            
, original_loan_subsidy_cost           
, face_value_loan_guarantee            
, recipient_id                         
, recipient_hash                       
, awarding_agency_id                   
, funding_agency_id                    
, regexp_replace(type, '[,\n]', ' ', 'g') AS type
, regexp_replace(action_type, '[,\n]', ' ', 'g') AS action_type
, regexp_replace(award_category, '[,\n]', ' ', 'g') AS award_category
, regexp_replace(fain, '[,\n]', ' ', 'g') AS fain
, regexp_replace(uri, '[,\n]', ' ', 'g') AS uri
, regexp_replace(piid, '[,\n]', ' ', 'g') AS piid
, regexp_replace(transaction_description, '[,\n]', ' ', 'g') AS transaction_description
, regexp_replace(modification_number, '[,\n]', ' ', 'g') AS modification_number
, regexp_replace(pop_country_code, '[,\n]', ' ', 'g') AS pop_country_code
, regexp_replace(pop_country_name, '[,\n]', ' ', 'g') AS pop_country_name
, regexp_replace(pop_state_code, '[,\n]', ' ', 'g') AS pop_state_code
, regexp_replace(pop_county_code, '[,\n]', ' ', 'g') AS pop_county_code
, regexp_replace(pop_county_name, '[,\n]', ' ', 'g') AS pop_county_name
, regexp_replace(pop_zip5, '[,\n]', ' ', 'g') AS pop_zip5
, regexp_replace(pop_congressional_code, '[,\n]', ' ', 'g') AS pop_congressional_code
, regexp_replace(recipient_location_country_code, '[,\n]', ' ', 'g') AS recipient_location_country_code
, regexp_replace(recipient_location_country_name, '[,\n]', ' ', 'g') AS recipient_location_country_name
, regexp_replace(recipient_location_state_code, '[,\n]', ' ', 'g') AS recipient_location_state_code
, regexp_replace(recipient_location_county_code, '[,\n]', ' ', 'g') AS recipient_location_county_code
, regexp_replace(recipient_location_county_name, '[,\n]', ' ', 'g') AS recipient_location_county_name
, regexp_replace(recipient_location_congressional_code, '[,\n]', ' ', 'g') AS recipient_location_congressional_code
, regexp_replace(recipient_location_zip5, '[,\n]', ' ', 'g') AS recipient_location_zip5
, regexp_replace(naics_code, '[,\n]', ' ', 'g') AS naics_code
, regexp_replace(naics_description, '[,\n]', ' ', 'g') AS naics_description
, regexp_replace(product_or_service_code, '[,\n]', ' ', 'g') AS product_or_service_code
, regexp_replace(product_or_service_description, '[,\n]', ' ', 'g') AS product_or_service_description
, regexp_replace(pulled_from, '[,\n]', ' ', 'g') AS pulled_from
, regexp_replace(type_of_contract_pricing, '[,\n]', ' ', 'g') AS type_of_contract_pricing
, regexp_replace(type_set_aside, '[,\n]', ' ', 'g') AS type_set_aside
, regexp_replace(extent_competed, '[,\n]', ' ', 'g') AS extent_competed
, regexp_replace(cfda_number, '[,\n]', ' ', 'g') AS cfda_number
, regexp_replace(cfda_title, '[,\n]', ' ', 'g') AS cfda_title
, regexp_replace(recipient_name, '[,\n]', ' ', 'g') AS recipient_name
, regexp_replace(parent_recipient_unique_id, '[,\n]', ' ', 'g') AS parent_recipient_unique_id
, regexp_replace(business_categories, '[,\n]', ' ', 'g') AS business_categories
, regexp_replace(awarding_toptier_agency_name, '[,\n]', ' ', 'g') AS awarding_toptier_agency_name
, regexp_replace(funding_toptier_agency_name, '[,\n]', ' ', 'g') AS funding_toptier_agency_name
, regexp_replace(awarding_subtier_agency_name, '[,\n]', ' ', 'g') AS awarding_subtier_agency_name
, regexp_replace(funding_subtier_agency_name, '[,\n]', ' ', 'g') AS funding_subtier_agency_name
, regexp_replace(awarding_toptier_agency_abbreviation, '[,\n]', ' ', 'g') AS awarding_toptier_agency_abbreviation
, regexp_replace(funding_toptier_agency_abbreviation, '[,\n]', ' ', 'g') AS funding_toptier_agency_abbreviation
, regexp_replace(awarding_subtier_agency_abbreviation, '[,\n]', ' ', 'g') AS awarding_subtier_agency_abbreviation
, regexp_replace(funding_subtier_agency_abbreviation, '[,\n]', ' ', 'g') AS funding_subtier_agency_abbreviation

FROM universal_transaction_matview
--ORDER BY recipient_unique_id
LIMIT 10
)
to STDOUT With CSV HEADER DELIMITER ',';
