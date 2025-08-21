-- ================================================================
-- Forward Inheritance Platform - Schema Relationships (Phase 2)
-- Adds all foreign key constraints and initial data
-- Must be run AFTER schema_structure.sql
-- ================================================================

-- ================================================================
-- FOREIGN KEY CONSTRAINTS
-- ================================================================

-- ================================================================
-- Section 1: Tenant Relationships (No dependencies)
-- ================================================================

-- media_storage
ALTER TABLE media_storage ADD CONSTRAINT fk_media_storage_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- document_metadata
ALTER TABLE document_metadata ADD CONSTRAINT fk_document_metadata_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- users
ALTER TABLE users ADD CONSTRAINT fk_users_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- personas
ALTER TABLE personas ADD CONSTRAINT fk_personas_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- fwd_family_circles
ALTER TABLE fwd_family_circles ADD CONSTRAINT fk_ffc_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- phone_number
ALTER TABLE phone_number ADD CONSTRAINT fk_phone_number_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- email_address
ALTER TABLE email_address ADD CONSTRAINT fk_email_address_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- address
ALTER TABLE address ADD CONSTRAINT fk_address_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- social_media
ALTER TABLE social_media ADD CONSTRAINT fk_social_media_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- usage_email
ALTER TABLE usage_email ADD CONSTRAINT fk_usage_email_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- usage_phone
ALTER TABLE usage_phone ADD CONSTRAINT fk_usage_phone_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- usage_address
ALTER TABLE usage_address ADD CONSTRAINT fk_usage_address_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- usage_social_media
ALTER TABLE usage_social_media ADD CONSTRAINT fk_usage_social_media_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- contact_info
ALTER TABLE contact_info ADD CONSTRAINT fk_contact_info_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- ffc_personas
ALTER TABLE ffc_personas ADD CONSTRAINT fk_ffc_personas_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- user_roles
ALTER TABLE user_roles ADD CONSTRAINT fk_user_roles_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- user_permissions
ALTER TABLE user_permissions ADD CONSTRAINT fk_user_permissions_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- ffc_invitations
ALTER TABLE ffc_invitations ADD CONSTRAINT fk_ffc_invitations_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- invitation_verification_attempts
ALTER TABLE invitation_verification_attempts ADD CONSTRAINT fk_invitation_verification_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- assets
ALTER TABLE assets ADD CONSTRAINT fk_assets_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- asset_persona
ALTER TABLE asset_persona ADD CONSTRAINT fk_asset_persona_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- user_sessions
ALTER TABLE user_sessions ADD CONSTRAINT fk_user_sessions_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- audit_log
ALTER TABLE audit_log ADD CONSTRAINT fk_audit_log_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- audit_events
ALTER TABLE audit_events ADD CONSTRAINT fk_audit_events_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- pii_processing_jobs
ALTER TABLE pii_processing_jobs ADD CONSTRAINT fk_pii_processing_jobs_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- masking_configurations
ALTER TABLE masking_configurations ADD CONSTRAINT fk_masking_configurations_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- pii_access_logs
ALTER TABLE pii_access_logs ADD CONSTRAINT fk_pii_access_logs_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- advisor_companies
ALTER TABLE advisor_companies ADD CONSTRAINT fk_advisor_companies_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- builder_io_integrations
ALTER TABLE builder_io_integrations ADD CONSTRAINT fk_builder_io_integrations_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- quiltt_integrations
ALTER TABLE quiltt_integrations ADD CONSTRAINT fk_quiltt_integrations_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- real_estate_provider_integrations
ALTER TABLE real_estate_provider_integrations ADD CONSTRAINT fk_real_estate_provider_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- ================================================================
-- Section 2: Self-Referential Constraints
-- ================================================================

-- users self-references
ALTER TABLE users ADD CONSTRAINT fk_users_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE users ADD CONSTRAINT fk_users_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- asset_categories hierarchy
ALTER TABLE asset_categories ADD CONSTRAINT fk_asset_categories_parent 
    FOREIGN KEY (parent_category_id) REFERENCES asset_categories(id);

-- wills superseding
ALTER TABLE wills ADD CONSTRAINT fk_wills_superseded_by 
    FOREIGN KEY (superseded_by_will_id) REFERENCES wills(id);

-- ================================================================
-- Section 3: Core Entity Relationships
-- ================================================================

-- users to contact tables
ALTER TABLE users ADD CONSTRAINT fk_users_primary_email 
    FOREIGN KEY (primary_email_id) REFERENCES email_address(id);
ALTER TABLE users ADD CONSTRAINT fk_users_primary_phone 
    FOREIGN KEY (primary_phone_id) REFERENCES phone_number(id);

-- personas relationships
ALTER TABLE personas ADD CONSTRAINT fk_personas_user 
    FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE personas ADD CONSTRAINT fk_personas_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE personas ADD CONSTRAINT fk_personas_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- fwd_family_circles relationships
ALTER TABLE fwd_family_circles ADD CONSTRAINT fk_ffc_owner_user 
    FOREIGN KEY (owner_user_id) REFERENCES users(id);
ALTER TABLE fwd_family_circles ADD CONSTRAINT fk_ffc_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE fwd_family_circles ADD CONSTRAINT fk_ffc_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- ================================================================
-- Section 4: Contact Information Relationships
-- ================================================================

-- email_address audit
ALTER TABLE email_address ADD CONSTRAINT fk_email_address_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE email_address ADD CONSTRAINT fk_email_address_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- usage_email relationships
ALTER TABLE usage_email ADD CONSTRAINT fk_usage_email_email 
    FOREIGN KEY (email_id) REFERENCES email_address(id);

-- usage_phone relationships
ALTER TABLE usage_phone ADD CONSTRAINT fk_usage_phone_phone 
    FOREIGN KEY (phone_id) REFERENCES phone_number(id);

-- usage_address relationships
ALTER TABLE usage_address ADD CONSTRAINT fk_usage_address_address 
    FOREIGN KEY (address_id) REFERENCES address(id);

-- usage_social_media relationships
ALTER TABLE usage_social_media ADD CONSTRAINT fk_usage_social_media_social 
    FOREIGN KEY (social_media_id) REFERENCES social_media(id);
ALTER TABLE usage_social_media ADD CONSTRAINT fk_usage_social_media_recovery_email 
    FOREIGN KEY (recovery_email_id) REFERENCES email_address(id);
ALTER TABLE usage_social_media ADD CONSTRAINT fk_usage_social_media_recovery_phone 
    FOREIGN KEY (recovery_phone_id) REFERENCES phone_number(id);

-- contact_info relationships
ALTER TABLE contact_info ADD CONSTRAINT fk_contact_info_primary_email 
    FOREIGN KEY (primary_email_id) REFERENCES email_address(id);
ALTER TABLE contact_info ADD CONSTRAINT fk_contact_info_primary_phone 
    FOREIGN KEY (primary_phone_id) REFERENCES phone_number(id);
ALTER TABLE contact_info ADD CONSTRAINT fk_contact_info_primary_address 
    FOREIGN KEY (primary_address_id) REFERENCES address(id);

-- ================================================================
-- Section 5: Media and Document Relationships
-- ================================================================

-- media_storage relationships
ALTER TABLE media_storage ADD CONSTRAINT fk_media_storage_uploaded_by 
    FOREIGN KEY (uploaded_by) REFERENCES users(id);

-- document_metadata relationships
ALTER TABLE document_metadata ADD CONSTRAINT fk_document_metadata_media_storage 
    FOREIGN KEY (media_storage_id) REFERENCES media_storage(id);
ALTER TABLE document_metadata ADD CONSTRAINT fk_document_metadata_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE document_metadata ADD CONSTRAINT fk_document_metadata_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- ================================================================
-- Section 6: FFC and Persona Relationships
-- ================================================================

-- ffc_personas relationships
ALTER TABLE ffc_personas ADD CONSTRAINT fk_ffc_personas_ffc 
    FOREIGN KEY (ffc_id) REFERENCES fwd_family_circles(id);
ALTER TABLE ffc_personas ADD CONSTRAINT fk_ffc_personas_persona 
    FOREIGN KEY (persona_id) REFERENCES personas(id);
ALTER TABLE ffc_personas ADD CONSTRAINT fk_ffc_personas_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE ffc_personas ADD CONSTRAINT fk_ffc_personas_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- ================================================================
-- Section 7: RBAC Relationships
-- ================================================================

-- role_permissions relationships
ALTER TABLE role_permissions ADD CONSTRAINT fk_role_permissions_role 
    FOREIGN KEY (role_id) REFERENCES user_roles(id);
ALTER TABLE role_permissions ADD CONSTRAINT fk_role_permissions_permission 
    FOREIGN KEY (permission_id) REFERENCES user_permissions(id);
ALTER TABLE role_permissions ADD CONSTRAINT fk_role_permissions_granted_by 
    FOREIGN KEY (granted_by) REFERENCES users(id);

-- user_role_assignments relationships
ALTER TABLE user_role_assignments ADD CONSTRAINT fk_user_role_assignments_user 
    FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE user_role_assignments ADD CONSTRAINT fk_user_role_assignments_role 
    FOREIGN KEY (role_id) REFERENCES user_roles(id);
ALTER TABLE user_role_assignments ADD CONSTRAINT fk_user_role_assignments_ffc 
    FOREIGN KEY (ffc_id) REFERENCES fwd_family_circles(id);
ALTER TABLE user_role_assignments ADD CONSTRAINT fk_user_role_assignments_assigned_by 
    FOREIGN KEY (assigned_by) REFERENCES users(id);
ALTER TABLE user_role_assignments ADD CONSTRAINT fk_user_role_assignments_revoked_by 
    FOREIGN KEY (revoked_by) REFERENCES users(id);
ALTER TABLE user_role_assignments ADD CONSTRAINT fk_user_role_assignments_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE user_role_assignments ADD CONSTRAINT fk_user_role_assignments_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- ================================================================
-- Section 8: Invitation Relationships
-- ================================================================

-- ffc_invitations relationships
ALTER TABLE ffc_invitations ADD CONSTRAINT fk_ffc_invitations_ffc 
    FOREIGN KEY (ffc_id) REFERENCES fwd_family_circles(id);
ALTER TABLE ffc_invitations ADD CONSTRAINT fk_ffc_invitations_inviter_user 
    FOREIGN KEY (inviter_user_id) REFERENCES users(id);
ALTER TABLE ffc_invitations ADD CONSTRAINT fk_ffc_invitations_invitee_email 
    FOREIGN KEY (invitee_email_id) REFERENCES email_address(id);
ALTER TABLE ffc_invitations ADD CONSTRAINT fk_ffc_invitations_invitee_phone 
    FOREIGN KEY (invitee_phone_id) REFERENCES phone_number(id);
ALTER TABLE ffc_invitations ADD CONSTRAINT fk_ffc_invitations_approved_by 
    FOREIGN KEY (approved_by_user_id) REFERENCES users(id);
ALTER TABLE ffc_invitations ADD CONSTRAINT fk_ffc_invitations_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE ffc_invitations ADD CONSTRAINT fk_ffc_invitations_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- invitation_verification_attempts relationships
ALTER TABLE invitation_verification_attempts ADD CONSTRAINT fk_invitation_verification_invitation 
    FOREIGN KEY (invitation_id) REFERENCES ffc_invitations(id);
ALTER TABLE invitation_verification_attempts ADD CONSTRAINT fk_invitation_verification_phone 
    FOREIGN KEY (phone_id) REFERENCES phone_number(id);

-- ================================================================
-- Section 9: Asset Relationships
-- ================================================================

-- asset_categories audit
ALTER TABLE asset_categories ADD CONSTRAINT fk_asset_categories_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE asset_categories ADD CONSTRAINT fk_asset_categories_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- assets relationships
ALTER TABLE assets ADD CONSTRAINT fk_assets_category 
    FOREIGN KEY (category_id) REFERENCES asset_categories(id);
ALTER TABLE assets ADD CONSTRAINT fk_assets_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE assets ADD CONSTRAINT fk_assets_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- asset_persona relationships
ALTER TABLE asset_persona ADD CONSTRAINT fk_asset_persona_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE asset_persona ADD CONSTRAINT fk_asset_persona_persona 
    FOREIGN KEY (persona_id) REFERENCES personas(id);
ALTER TABLE asset_persona ADD CONSTRAINT fk_asset_persona_transfer_to 
    FOREIGN KEY (transfer_on_death_to_persona_id) REFERENCES personas(id);
ALTER TABLE asset_persona ADD CONSTRAINT fk_asset_persona_ownership_document 
    FOREIGN KEY (ownership_document_id) REFERENCES media_storage(id);
ALTER TABLE asset_persona ADD CONSTRAINT fk_asset_persona_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE asset_persona ADD CONSTRAINT fk_asset_persona_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- asset_permissions relationships
ALTER TABLE asset_permissions ADD CONSTRAINT fk_asset_permissions_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE asset_permissions ADD CONSTRAINT fk_asset_permissions_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE asset_permissions ADD CONSTRAINT fk_asset_permissions_persona 
    FOREIGN KEY (persona_id) REFERENCES personas(id);
ALTER TABLE asset_permissions ADD CONSTRAINT fk_asset_permissions_granted_by 
    FOREIGN KEY (granted_by_persona_id) REFERENCES personas(id);

-- ================================================================
-- Section 10: Asset Type Specific Relationships
-- ================================================================

-- personal_directives relationships
ALTER TABLE personal_directives ADD CONSTRAINT fk_personal_directives_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE personal_directives ADD CONSTRAINT fk_personal_directives_principal 
    FOREIGN KEY (principal_persona_id) REFERENCES personas(id);
ALTER TABLE personal_directives ADD CONSTRAINT fk_personal_directives_agent 
    FOREIGN KEY (agent_persona_id) REFERENCES personas(id);
ALTER TABLE personal_directives ADD CONSTRAINT fk_personal_directives_agent_email 
    FOREIGN KEY (agent_email_id) REFERENCES email_address(id);
ALTER TABLE personal_directives ADD CONSTRAINT fk_personal_directives_agent_phone 
    FOREIGN KEY (agent_phone_id) REFERENCES phone_number(id);
ALTER TABLE personal_directives ADD CONSTRAINT fk_personal_directives_successor1 
    FOREIGN KEY (successor_agent_1_persona_id) REFERENCES personas(id);
ALTER TABLE personal_directives ADD CONSTRAINT fk_personal_directives_successor2 
    FOREIGN KEY (successor_agent_2_persona_id) REFERENCES personas(id);
ALTER TABLE personal_directives ADD CONSTRAINT fk_personal_directives_primary_doc 
    FOREIGN KEY (primary_document_id) REFERENCES media_storage(id);
ALTER TABLE personal_directives ADD CONSTRAINT fk_personal_directives_revocation_doc 
    FOREIGN KEY (revocation_document_id) REFERENCES media_storage(id);
ALTER TABLE personal_directives ADD CONSTRAINT fk_personal_directives_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE personal_directives ADD CONSTRAINT fk_personal_directives_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- trusts relationships
ALTER TABLE trusts ADD CONSTRAINT fk_trusts_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE trusts ADD CONSTRAINT fk_trusts_grantor 
    FOREIGN KEY (grantor_persona_id) REFERENCES personas(id);
ALTER TABLE trusts ADD CONSTRAINT fk_trusts_trustee 
    FOREIGN KEY (trustee_persona_id) REFERENCES personas(id);
ALTER TABLE trusts ADD CONSTRAINT fk_trusts_trustee_email 
    FOREIGN KEY (trustee_email_id) REFERENCES email_address(id);
ALTER TABLE trusts ADD CONSTRAINT fk_trusts_trustee_phone 
    FOREIGN KEY (trustee_phone_id) REFERENCES phone_number(id);
ALTER TABLE trusts ADD CONSTRAINT fk_trusts_successor1 
    FOREIGN KEY (successor_trustee_1_persona_id) REFERENCES personas(id);
ALTER TABLE trusts ADD CONSTRAINT fk_trusts_successor2 
    FOREIGN KEY (successor_trustee_2_persona_id) REFERENCES personas(id);
ALTER TABLE trusts ADD CONSTRAINT fk_trusts_document 
    FOREIGN KEY (trust_document_id) REFERENCES media_storage(id);
ALTER TABLE trusts ADD CONSTRAINT fk_trusts_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE trusts ADD CONSTRAINT fk_trusts_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- wills relationships
ALTER TABLE wills ADD CONSTRAINT fk_wills_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE wills ADD CONSTRAINT fk_wills_testator 
    FOREIGN KEY (testator_persona_id) REFERENCES personas(id);
ALTER TABLE wills ADD CONSTRAINT fk_wills_executor 
    FOREIGN KEY (executor_persona_id) REFERENCES personas(id);
ALTER TABLE wills ADD CONSTRAINT fk_wills_executor_email 
    FOREIGN KEY (executor_email_id) REFERENCES email_address(id);
ALTER TABLE wills ADD CONSTRAINT fk_wills_executor_phone 
    FOREIGN KEY (executor_phone_id) REFERENCES phone_number(id);
ALTER TABLE wills ADD CONSTRAINT fk_wills_successor1 
    FOREIGN KEY (successor_executor_1_persona_id) REFERENCES personas(id);
ALTER TABLE wills ADD CONSTRAINT fk_wills_successor2 
    FOREIGN KEY (successor_executor_2_persona_id) REFERENCES personas(id);
ALTER TABLE wills ADD CONSTRAINT fk_wills_document 
    FOREIGN KEY (will_document_id) REFERENCES media_storage(id);
ALTER TABLE wills ADD CONSTRAINT fk_wills_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE wills ADD CONSTRAINT fk_wills_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- personal_property relationships
ALTER TABLE personal_property ADD CONSTRAINT fk_personal_property_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE personal_property ADD CONSTRAINT fk_personal_property_storage_address 
    FOREIGN KEY (storage_address_id) REFERENCES address(id);
ALTER TABLE personal_property ADD CONSTRAINT fk_personal_property_insurance_phone 
    FOREIGN KEY (insurance_contact_phone_id) REFERENCES phone_number(id);
ALTER TABLE personal_property ADD CONSTRAINT fk_personal_property_insurance_email 
    FOREIGN KEY (insurance_contact_email_id) REFERENCES email_address(id);
ALTER TABLE personal_property ADD CONSTRAINT fk_personal_property_receipt_doc 
    FOREIGN KEY (receipt_document_id) REFERENCES media_storage(id);
ALTER TABLE personal_property ADD CONSTRAINT fk_personal_property_appraisal_doc 
    FOREIGN KEY (appraisal_document_id) REFERENCES media_storage(id);
ALTER TABLE personal_property ADD CONSTRAINT fk_personal_property_certificate 
    FOREIGN KEY (certificate_of_authenticity_id) REFERENCES media_storage(id);
ALTER TABLE personal_property ADD CONSTRAINT fk_personal_property_vet_contact 
    FOREIGN KEY (pet_veterinarian_contact_id) REFERENCES contact_info(id);
ALTER TABLE personal_property ADD CONSTRAINT fk_personal_property_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE personal_property ADD CONSTRAINT fk_personal_property_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- operational_property relationships
ALTER TABLE operational_property ADD CONSTRAINT fk_operational_property_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE operational_property ADD CONSTRAINT fk_operational_property_storage_address 
    FOREIGN KEY (storage_address_id) REFERENCES address(id);
ALTER TABLE operational_property ADD CONSTRAINT fk_operational_property_insurance_phone 
    FOREIGN KEY (insurance_contact_phone_id) REFERENCES phone_number(id);
ALTER TABLE operational_property ADD CONSTRAINT fk_operational_property_insurance_email 
    FOREIGN KEY (insurance_contact_email_id) REFERENCES email_address(id);
ALTER TABLE operational_property ADD CONSTRAINT fk_operational_property_service_contact 
    FOREIGN KEY (service_provider_contact_id) REFERENCES contact_info(id);
ALTER TABLE operational_property ADD CONSTRAINT fk_operational_property_title_doc 
    FOREIGN KEY (title_document_id) REFERENCES media_storage(id);
ALTER TABLE operational_property ADD CONSTRAINT fk_operational_property_registration_doc 
    FOREIGN KEY (registration_document_id) REFERENCES media_storage(id);
ALTER TABLE operational_property ADD CONSTRAINT fk_operational_property_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE operational_property ADD CONSTRAINT fk_operational_property_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- inventory relationships
ALTER TABLE inventory ADD CONSTRAINT fk_inventory_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE inventory ADD CONSTRAINT fk_inventory_storage_address 
    FOREIGN KEY (storage_address_id) REFERENCES address(id);
ALTER TABLE inventory ADD CONSTRAINT fk_inventory_supplier_contact 
    FOREIGN KEY (supplier_contact_id) REFERENCES contact_info(id);
ALTER TABLE inventory ADD CONSTRAINT fk_inventory_supplier_email 
    FOREIGN KEY (supplier_email_id) REFERENCES email_address(id);
ALTER TABLE inventory ADD CONSTRAINT fk_inventory_supplier_phone 
    FOREIGN KEY (supplier_phone_id) REFERENCES phone_number(id);
ALTER TABLE inventory ADD CONSTRAINT fk_inventory_list_doc 
    FOREIGN KEY (inventory_list_document_id) REFERENCES media_storage(id);
ALTER TABLE inventory ADD CONSTRAINT fk_inventory_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE inventory ADD CONSTRAINT fk_inventory_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- real_estate relationships
ALTER TABLE real_estate ADD CONSTRAINT fk_real_estate_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE real_estate ADD CONSTRAINT fk_real_estate_property_address 
    FOREIGN KEY (property_address_id) REFERENCES address(id);
ALTER TABLE real_estate ADD CONSTRAINT fk_real_estate_insurance_email 
    FOREIGN KEY (insurance_contact_email_id) REFERENCES email_address(id);
ALTER TABLE real_estate ADD CONSTRAINT fk_real_estate_insurance_phone 
    FOREIGN KEY (insurance_contact_phone_id) REFERENCES phone_number(id);
ALTER TABLE real_estate ADD CONSTRAINT fk_real_estate_hoa_contact 
    FOREIGN KEY (hoa_contact_id) REFERENCES contact_info(id);
ALTER TABLE real_estate ADD CONSTRAINT fk_real_estate_deed_doc 
    FOREIGN KEY (deed_document_id) REFERENCES media_storage(id);
ALTER TABLE real_estate ADD CONSTRAINT fk_real_estate_survey_doc 
    FOREIGN KEY (survey_document_id) REFERENCES media_storage(id);
ALTER TABLE real_estate ADD CONSTRAINT fk_real_estate_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE real_estate ADD CONSTRAINT fk_real_estate_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- life_insurance relationships
ALTER TABLE life_insurance ADD CONSTRAINT fk_life_insurance_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE life_insurance ADD CONSTRAINT fk_life_insurance_insured 
    FOREIGN KEY (insured_persona_id) REFERENCES personas(id);
ALTER TABLE life_insurance ADD CONSTRAINT fk_life_insurance_owner 
    FOREIGN KEY (policy_owner_persona_id) REFERENCES personas(id);
ALTER TABLE life_insurance ADD CONSTRAINT fk_life_insurance_agent_contact 
    FOREIGN KEY (agent_contact_id) REFERENCES contact_info(id);
ALTER TABLE life_insurance ADD CONSTRAINT fk_life_insurance_insurer_email 
    FOREIGN KEY (insurer_contact_email_id) REFERENCES email_address(id);
ALTER TABLE life_insurance ADD CONSTRAINT fk_life_insurance_insurer_phone 
    FOREIGN KEY (insurer_contact_phone_id) REFERENCES phone_number(id);
ALTER TABLE life_insurance ADD CONSTRAINT fk_life_insurance_policy_doc 
    FOREIGN KEY (policy_document_id) REFERENCES media_storage(id);
ALTER TABLE life_insurance ADD CONSTRAINT fk_life_insurance_beneficiary_doc 
    FOREIGN KEY (beneficiary_designation_document_id) REFERENCES media_storage(id);
ALTER TABLE life_insurance ADD CONSTRAINT fk_life_insurance_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE life_insurance ADD CONSTRAINT fk_life_insurance_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- financial_accounts relationships
ALTER TABLE financial_accounts ADD CONSTRAINT fk_financial_accounts_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE financial_accounts ADD CONSTRAINT fk_financial_accounts_institution_email 
    FOREIGN KEY (institution_contact_email_id) REFERENCES email_address(id);
ALTER TABLE financial_accounts ADD CONSTRAINT fk_financial_accounts_institution_phone 
    FOREIGN KEY (institution_contact_phone_id) REFERENCES phone_number(id);
ALTER TABLE financial_accounts ADD CONSTRAINT fk_financial_accounts_advisor_email 
    FOREIGN KEY (advisor_email_id) REFERENCES email_address(id);
ALTER TABLE financial_accounts ADD CONSTRAINT fk_financial_accounts_advisor_phone 
    FOREIGN KEY (advisor_phone_id) REFERENCES phone_number(id);
ALTER TABLE financial_accounts ADD CONSTRAINT fk_financial_accounts_advisor_contact 
    FOREIGN KEY (advisor_contact_id) REFERENCES contact_info(id);
ALTER TABLE financial_accounts ADD CONSTRAINT fk_financial_accounts_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE financial_accounts ADD CONSTRAINT fk_financial_accounts_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- recurring_income relationships
ALTER TABLE recurring_income ADD CONSTRAINT fk_recurring_income_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE recurring_income ADD CONSTRAINT fk_recurring_income_contact_email 
    FOREIGN KEY (contact_email_id) REFERENCES email_address(id);
ALTER TABLE recurring_income ADD CONSTRAINT fk_recurring_income_contact_phone 
    FOREIGN KEY (contact_phone_id) REFERENCES phone_number(id);
ALTER TABLE recurring_income ADD CONSTRAINT fk_recurring_income_contract_doc 
    FOREIGN KEY (contract_document_id) REFERENCES media_storage(id);
ALTER TABLE recurring_income ADD CONSTRAINT fk_recurring_income_payment_history_doc 
    FOREIGN KEY (payment_history_document_id) REFERENCES media_storage(id);
ALTER TABLE recurring_income ADD CONSTRAINT fk_recurring_income_deposit_account 
    FOREIGN KEY (deposit_account_id) REFERENCES financial_accounts(id);
ALTER TABLE recurring_income ADD CONSTRAINT fk_recurring_income_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE recurring_income ADD CONSTRAINT fk_recurring_income_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- digital_assets relationships
ALTER TABLE digital_assets ADD CONSTRAINT fk_digital_assets_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE digital_assets ADD CONSTRAINT fk_digital_assets_recovery_email 
    FOREIGN KEY (recovery_email_id) REFERENCES email_address(id);
ALTER TABLE digital_assets ADD CONSTRAINT fk_digital_assets_recovery_phone 
    FOREIGN KEY (recovery_phone_id) REFERENCES phone_number(id);
ALTER TABLE digital_assets ADD CONSTRAINT fk_digital_assets_backup_codes_doc 
    FOREIGN KEY (backup_codes_document_id) REFERENCES media_storage(id);
ALTER TABLE digital_assets ADD CONSTRAINT fk_digital_assets_registration_doc 
    FOREIGN KEY (registration_document_id) REFERENCES media_storage(id);
ALTER TABLE digital_assets ADD CONSTRAINT fk_digital_assets_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE digital_assets ADD CONSTRAINT fk_digital_assets_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- ownership_interests relationships
ALTER TABLE ownership_interests ADD CONSTRAINT fk_ownership_interests_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE ownership_interests ADD CONSTRAINT fk_ownership_interests_contact_email 
    FOREIGN KEY (primary_contact_email_id) REFERENCES email_address(id);
ALTER TABLE ownership_interests ADD CONSTRAINT fk_ownership_interests_contact_phone 
    FOREIGN KEY (primary_contact_phone_id) REFERENCES phone_number(id);
ALTER TABLE ownership_interests ADD CONSTRAINT fk_ownership_interests_contact_address 
    FOREIGN KEY (primary_contact_address_id) REFERENCES address(id);
ALTER TABLE ownership_interests ADD CONSTRAINT fk_ownership_interests_formation_doc 
    FOREIGN KEY (formation_document_id) REFERENCES media_storage(id);
ALTER TABLE ownership_interests ADD CONSTRAINT fk_ownership_interests_operating_doc 
    FOREIGN KEY (operating_agreement_document_id) REFERENCES media_storage(id);
ALTER TABLE ownership_interests ADD CONSTRAINT fk_ownership_interests_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE ownership_interests ADD CONSTRAINT fk_ownership_interests_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- loans relationships
ALTER TABLE loans ADD CONSTRAINT fk_loans_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE loans ADD CONSTRAINT fk_loans_lender_persona 
    FOREIGN KEY (lender_persona_id) REFERENCES personas(id);
ALTER TABLE loans ADD CONSTRAINT fk_loans_lender_email 
    FOREIGN KEY (lender_contact_email_id) REFERENCES email_address(id);
ALTER TABLE loans ADD CONSTRAINT fk_loans_lender_phone 
    FOREIGN KEY (lender_contact_phone_id) REFERENCES phone_number(id);
ALTER TABLE loans ADD CONSTRAINT fk_loans_borrower_contact 
    FOREIGN KEY (borrower_contact_id) REFERENCES contact_info(id);
ALTER TABLE loans ADD CONSTRAINT fk_loans_collection_agency 
    FOREIGN KEY (collection_agency_contact_id) REFERENCES contact_info(id);
ALTER TABLE loans ADD CONSTRAINT fk_loans_agreement_doc 
    FOREIGN KEY (loan_agreement_document_id) REFERENCES media_storage(id);
ALTER TABLE loans ADD CONSTRAINT fk_loans_promissory_doc 
    FOREIGN KEY (promissory_note_document_id) REFERENCES media_storage(id);
ALTER TABLE loans ADD CONSTRAINT fk_loans_payment_history_doc 
    FOREIGN KEY (payment_history_document_id) REFERENCES media_storage(id);
ALTER TABLE loans ADD CONSTRAINT fk_loans_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE loans ADD CONSTRAINT fk_loans_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- ================================================================
-- Section 11: Security and Session Relationships
-- ================================================================

-- user_sessions relationships
ALTER TABLE user_sessions ADD CONSTRAINT fk_user_sessions_user 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE user_sessions ADD CONSTRAINT fk_user_sessions_revoked_by 
    FOREIGN KEY (revoked_by) REFERENCES users(id);

-- user_mfa_settings relationships
ALTER TABLE user_mfa_settings ADD CONSTRAINT fk_user_mfa_settings_user 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE user_mfa_settings ADD CONSTRAINT fk_user_mfa_settings_mfa_phone 
    FOREIGN KEY (mfa_phone_id) REFERENCES phone_number(id);
ALTER TABLE user_mfa_settings ADD CONSTRAINT fk_user_mfa_settings_mfa_email 
    FOREIGN KEY (mfa_email_id) REFERENCES email_address(id);
ALTER TABLE user_mfa_settings ADD CONSTRAINT fk_user_mfa_settings_target_phone 
    FOREIGN KEY (target_phone_id) REFERENCES phone_number(id);
ALTER TABLE user_mfa_settings ADD CONSTRAINT fk_user_mfa_settings_target_email 
    FOREIGN KEY (target_email_id) REFERENCES email_address(id);
ALTER TABLE user_mfa_settings ADD CONSTRAINT fk_user_mfa_settings_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE user_mfa_settings ADD CONSTRAINT fk_user_mfa_settings_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- password_reset_tokens relationships
ALTER TABLE password_reset_tokens ADD CONSTRAINT fk_password_reset_tokens_user 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- user_login_history relationships
ALTER TABLE user_login_history ADD CONSTRAINT fk_user_login_history_user 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE user_login_history ADD CONSTRAINT fk_user_login_history_session 
    FOREIGN KEY (session_id) REFERENCES user_sessions(id);

-- ================================================================
-- Section 12: Audit and Compliance Relationships
-- ================================================================

-- audit_log relationships
ALTER TABLE audit_log ADD CONSTRAINT fk_audit_log_user 
    FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE audit_log ADD CONSTRAINT fk_audit_log_persona 
    FOREIGN KEY (persona_id) REFERENCES personas(id);
ALTER TABLE audit_log ADD CONSTRAINT fk_audit_log_session 
    FOREIGN KEY (session_id) REFERENCES user_sessions(id);

-- audit_events relationships
ALTER TABLE audit_events ADD CONSTRAINT fk_audit_events_user 
    FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE audit_events ADD CONSTRAINT fk_audit_events_session 
    FOREIGN KEY (session_id) REFERENCES user_sessions(id);
ALTER TABLE audit_events ADD CONSTRAINT fk_audit_events_resolved_by 
    FOREIGN KEY (resolved_by) REFERENCES users(id);

-- pii_detection_rules relationships
ALTER TABLE pii_detection_rules ADD CONSTRAINT fk_pii_detection_rules_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE pii_detection_rules ADD CONSTRAINT fk_pii_detection_rules_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- pii_processing_jobs relationships
ALTER TABLE pii_processing_jobs ADD CONSTRAINT fk_pii_processing_jobs_scheduled_by 
    FOREIGN KEY (scheduled_by) REFERENCES users(id);

-- masking_configurations relationships
ALTER TABLE masking_configurations ADD CONSTRAINT fk_masking_configurations_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE masking_configurations ADD CONSTRAINT fk_masking_configurations_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- pii_access_logs relationships
ALTER TABLE pii_access_logs ADD CONSTRAINT fk_pii_access_logs_user 
    FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE pii_access_logs ADD CONSTRAINT fk_pii_access_logs_document 
    FOREIGN KEY (document_id) REFERENCES media_storage(id);
ALTER TABLE pii_access_logs ADD CONSTRAINT fk_pii_access_logs_session 
    FOREIGN KEY (session_id) REFERENCES user_sessions(id);
ALTER TABLE pii_access_logs ADD CONSTRAINT fk_pii_access_logs_reviewed_by 
    FOREIGN KEY (reviewed_by) REFERENCES users(id);

-- ================================================================
-- Section 13: Translation and Localization Relationships
-- ================================================================

-- translations relationships
ALTER TABLE translations ADD CONSTRAINT fk_translations_verified_by 
    FOREIGN KEY (verified_by) REFERENCES users(id);
ALTER TABLE translations ADD CONSTRAINT fk_translations_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE translations ADD CONSTRAINT fk_translations_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- user_language_preferences relationships
ALTER TABLE user_language_preferences ADD CONSTRAINT fk_user_language_preferences_user 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- ================================================================
-- Section 14: Integration Relationships
-- ================================================================

-- advisor_companies relationships
ALTER TABLE advisor_companies ADD CONSTRAINT fk_advisor_companies_primary_email 
    FOREIGN KEY (primary_email_id) REFERENCES email_address(id);
ALTER TABLE advisor_companies ADD CONSTRAINT fk_advisor_companies_primary_phone 
    FOREIGN KEY (primary_phone_id) REFERENCES phone_number(id);
ALTER TABLE advisor_companies ADD CONSTRAINT fk_advisor_companies_primary_address 
    FOREIGN KEY (primary_address_id) REFERENCES address(id);
ALTER TABLE advisor_companies ADD CONSTRAINT fk_advisor_companies_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE advisor_companies ADD CONSTRAINT fk_advisor_companies_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- quiltt_integrations relationships
ALTER TABLE quiltt_integrations ADD CONSTRAINT fk_quiltt_integrations_persona 
    FOREIGN KEY (persona_id) REFERENCES personas(id);

-- quiltt_webhook_logs relationships
ALTER TABLE quiltt_webhook_logs ADD CONSTRAINT fk_quiltt_webhook_logs_persona 
    FOREIGN KEY (persona_id) REFERENCES personas(id);
ALTER TABLE quiltt_webhook_logs ADD CONSTRAINT fk_quiltt_webhook_logs_integration 
    FOREIGN KEY (integration_id) REFERENCES quiltt_integrations(id);

-- quiltt_sessions relationships
ALTER TABLE quiltt_sessions ADD CONSTRAINT fk_quiltt_sessions_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);
ALTER TABLE quiltt_sessions ADD CONSTRAINT fk_quiltt_sessions_persona 
    FOREIGN KEY (persona_id) REFERENCES personas(id);

-- financial_accounts Quiltt relationships
ALTER TABLE financial_accounts ADD CONSTRAINT fk_financial_accounts_quiltt_integration 
    FOREIGN KEY (quiltt_integration_id) REFERENCES quiltt_integrations(id);

-- real_estate_sync_logs relationships
ALTER TABLE real_estate_sync_logs ADD CONSTRAINT fk_real_estate_sync_logs_integration 
    FOREIGN KEY (integration_id) REFERENCES real_estate_provider_integrations(id);
ALTER TABLE real_estate_sync_logs ADD CONSTRAINT fk_real_estate_sync_logs_property 
    FOREIGN KEY (property_id) REFERENCES real_estate(id);

-- ================================================================
-- INDEXES FOR FOREIGN KEYS
-- PostgreSQL doesn't automatically create indexes for foreign keys
-- These are critical for query performance
-- ================================================================

-- Tenant foreign key indexes (most important - used in all queries)
CREATE INDEX idx_media_storage_tenant_id ON media_storage(tenant_id);
CREATE INDEX idx_document_metadata_tenant_id ON document_metadata(tenant_id);
CREATE INDEX idx_users_tenant_id ON users(tenant_id);
CREATE INDEX idx_personas_tenant_id ON personas(tenant_id);
CREATE INDEX idx_ffc_tenant_id ON fwd_family_circles(tenant_id);
CREATE INDEX idx_phone_tenant_id ON phone_number(tenant_id);
CREATE INDEX idx_email_tenant_id ON email_address(tenant_id);
CREATE INDEX idx_address_tenant_id ON address(tenant_id);
CREATE INDEX idx_social_media_tenant_id ON social_media(tenant_id);
CREATE INDEX idx_usage_email_tenant_id ON usage_email(tenant_id);
CREATE INDEX idx_usage_phone_tenant_id ON usage_phone(tenant_id);
CREATE INDEX idx_usage_address_tenant_id ON usage_address(tenant_id);
CREATE INDEX idx_usage_social_media_tenant_id ON usage_social_media(tenant_id);
CREATE INDEX idx_contact_info_tenant_id ON contact_info(tenant_id);
CREATE INDEX idx_ffc_personas_tenant_id ON ffc_personas(tenant_id);
CREATE INDEX idx_user_roles_tenant_id ON user_roles(tenant_id);
CREATE INDEX idx_user_permissions_tenant_id ON user_permissions(tenant_id);
CREATE INDEX idx_ffc_invitations_tenant_id ON ffc_invitations(tenant_id);
CREATE INDEX idx_invitation_verification_tenant_id ON invitation_verification_attempts(tenant_id);
CREATE INDEX idx_assets_tenant_id ON assets(tenant_id);
CREATE INDEX idx_asset_persona_tenant_id ON asset_persona(tenant_id);
CREATE INDEX idx_user_sessions_tenant_id ON user_sessions(tenant_id);

-- User relationship indexes
CREATE INDEX idx_personas_user_id ON personas(user_id);
CREATE INDEX idx_ffc_owner_user_id ON fwd_family_circles(owner_user_id);
CREATE INDEX idx_users_primary_email_id ON users(primary_email_id);
CREATE INDEX idx_users_primary_phone_id ON users(primary_phone_id);

-- FFC relationship indexes
CREATE INDEX idx_ffc_personas_ffc_id ON ffc_personas(ffc_id);
CREATE INDEX idx_ffc_personas_persona_id ON ffc_personas(persona_id);
CREATE INDEX idx_ffc_invitations_ffc_id ON ffc_invitations(ffc_id);

-- Asset relationship indexes
-- Assets are owned by personas through the asset_persona junction table
-- No direct owner_id column on assets table
CREATE INDEX idx_asset_persona_asset_id ON asset_persona(asset_id);
CREATE INDEX idx_asset_persona_persona_id ON asset_persona(persona_id);

-- Add unique constraint for asset_persona to support ON CONFLICT in transfer_ownership_add_target.sql
ALTER TABLE asset_persona ADD CONSTRAINT uk_asset_persona_asset_persona UNIQUE (asset_id, persona_id);

CREATE INDEX idx_document_metadata_media_storage_id ON document_metadata(media_storage_id);

-- Contact relationship indexes
CREATE INDEX idx_usage_email_email_id ON usage_email(email_id);
CREATE INDEX idx_usage_phone_phone_id ON usage_phone(phone_id);
CREATE INDEX idx_usage_address_address_id ON usage_address(address_id);
CREATE INDEX idx_usage_social_media_social_media_id ON usage_social_media(social_media_id);

-- Entity relationship indexes for polymorphic relationships
CREATE INDEX idx_usage_email_entity_type_id ON usage_email(entity_type, entity_id);
CREATE INDEX idx_usage_phone_entity_type_id ON usage_phone(entity_type, entity_id);
CREATE INDEX idx_usage_address_entity_type_id ON usage_address(entity_type, entity_id);
CREATE INDEX idx_usage_social_media_entity_type_id ON usage_social_media(entity_type, entity_id);

-- Permission relationship indexes
CREATE INDEX idx_user_role_assignments_user_id ON user_role_assignments(user_id);
CREATE INDEX idx_user_role_assignments_role_id ON user_role_assignments(role_id);
CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission_id ON role_permissions(permission_id);

-- Session and audit indexes
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_audit_log_user_id ON audit_log(user_id);
CREATE INDEX idx_audit_log_entity_type_id ON audit_log(entity_type, entity_id);

-- Invitation indexes
CREATE INDEX idx_invitation_verification_invitation_id ON invitation_verification_attempts(invitation_id);
CREATE INDEX idx_ffc_invitations_phone_id ON ffc_invitations(invitee_phone_id);
-- Removed idx_ffc_invitations_status - already created in script 2 line 2735

-- Additional performance indexes for common queries
CREATE INDEX idx_users_cognito_user_id ON users(cognito_user_id);
CREATE INDEX idx_media_storage_processing_status ON media_storage(processing_status);
CREATE INDEX idx_document_metadata_document_type ON document_metadata(document_type);
CREATE INDEX idx_assets_category_id ON assets(category_id);
CREATE INDEX idx_ffc_personas_role ON ffc_personas(ffc_role);

-- Quiltt integration indexes
CREATE INDEX idx_quiltt_integrations_persona_id ON quiltt_integrations(persona_id);
CREATE INDEX idx_quiltt_integrations_quiltt_user_id ON quiltt_integrations(quiltt_user_id);
CREATE INDEX idx_financial_accounts_quiltt_integration ON financial_accounts(quiltt_integration_id);
CREATE INDEX idx_financial_accounts_quiltt_account_id ON financial_accounts(quiltt_account_id);
CREATE INDEX idx_financial_accounts_is_quiltt_connected ON financial_accounts(is_quiltt_connected);
CREATE INDEX idx_quiltt_sessions_persona_id ON quiltt_sessions(persona_id);
CREATE INDEX idx_quiltt_sessions_expires_at ON quiltt_sessions(expires_at);
CREATE INDEX idx_quiltt_sessions_is_used ON quiltt_sessions(is_used);
CREATE INDEX idx_quiltt_webhook_logs_integration_id ON quiltt_webhook_logs(integration_id);
CREATE INDEX idx_quiltt_webhook_logs_event_type ON quiltt_webhook_logs(event_type);
CREATE INDEX idx_quiltt_webhook_logs_processing_status ON quiltt_webhook_logs(processing_status);

-- ================================================================
-- EVENT SOURCING RELATIONSHIPS
-- ================================================================

-- event_store relationships
ALTER TABLE event_store ADD CONSTRAINT fk_event_store_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

ALTER TABLE event_store ADD CONSTRAINT fk_event_store_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);

-- event_snapshots relationships
ALTER TABLE event_snapshots ADD CONSTRAINT fk_event_snapshots_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- event_projections relationships
ALTER TABLE event_projections ADD CONSTRAINT fk_event_projections_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- ================================================================
-- SUBSCRIPTION AND PAYMENT RELATIONSHIPS
-- ================================================================

-- Plans relationships
ALTER TABLE plans ADD CONSTRAINT fk_plans_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

ALTER TABLE plans ADD CONSTRAINT fk_plans_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);

ALTER TABLE plans ADD CONSTRAINT fk_plans_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- Plan seats relationships
ALTER TABLE plan_seats ADD CONSTRAINT fk_plan_seats_plan 
    FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE;

-- Subscriptions relationships
ALTER TABLE subscriptions ADD CONSTRAINT fk_subscriptions_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

ALTER TABLE subscriptions ADD CONSTRAINT fk_subscriptions_ffc 
    FOREIGN KEY (ffc_id) REFERENCES fwd_family_circles(id) ON DELETE CASCADE;

ALTER TABLE subscriptions ADD CONSTRAINT fk_subscriptions_plan 
    FOREIGN KEY (plan_id) REFERENCES plans(id);

ALTER TABLE subscriptions ADD CONSTRAINT fk_subscriptions_owner 
    FOREIGN KEY (owner_user_id) REFERENCES users(id);

ALTER TABLE subscriptions ADD CONSTRAINT fk_subscriptions_payer 
    FOREIGN KEY (payer_id) REFERENCES users(id);

ALTER TABLE subscriptions ADD CONSTRAINT fk_subscriptions_advisor 
    FOREIGN KEY (advisor_id) REFERENCES users(id);

-- Seat assignments relationships
ALTER TABLE seat_assignments ADD CONSTRAINT fk_seat_assignments_subscription 
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE;

ALTER TABLE seat_assignments ADD CONSTRAINT fk_seat_assignments_persona 
    FOREIGN KEY (persona_id) REFERENCES personas(id);

ALTER TABLE seat_assignments ADD CONSTRAINT fk_seat_assignments_payer 
    FOREIGN KEY (payer_id) REFERENCES users(id);

ALTER TABLE seat_assignments ADD CONSTRAINT fk_seat_assignments_invitation 
    FOREIGN KEY (invitation_id) REFERENCES ffc_invitations(id);

-- Payment methods relationships
ALTER TABLE payment_methods ADD CONSTRAINT fk_payment_methods_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

ALTER TABLE payment_methods ADD CONSTRAINT fk_payment_methods_user 
    FOREIGN KEY (user_id) REFERENCES users(id);

-- Services relationships
ALTER TABLE services ADD CONSTRAINT fk_services_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

-- Service purchases relationships
ALTER TABLE service_purchases ADD CONSTRAINT fk_service_purchases_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

ALTER TABLE service_purchases ADD CONSTRAINT fk_service_purchases_service 
    FOREIGN KEY (service_id) REFERENCES services(id);

ALTER TABLE service_purchases ADD CONSTRAINT fk_service_purchases_ffc 
    FOREIGN KEY (ffc_id) REFERENCES fwd_family_circles(id);

ALTER TABLE service_purchases ADD CONSTRAINT fk_service_purchases_purchaser 
    FOREIGN KEY (purchaser_user_id) REFERENCES users(id);

ALTER TABLE service_purchases ADD CONSTRAINT fk_service_purchases_payment_method 
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id);

-- Payments relationships
ALTER TABLE payments ADD CONSTRAINT fk_payments_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

ALTER TABLE payments ADD CONSTRAINT fk_payments_payer 
    FOREIGN KEY (payer_id) REFERENCES users(id);

ALTER TABLE payments ADD CONSTRAINT fk_payments_payment_method 
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id);

-- Note: reference_id is polymorphic, so no FK constraint

-- General ledger relationships
ALTER TABLE general_ledger ADD CONSTRAINT fk_general_ledger_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

ALTER TABLE general_ledger ADD CONSTRAINT fk_general_ledger_reconciled_by 
    FOREIGN KEY (reconciled_by) REFERENCES users(id);

-- Note: reference_id is polymorphic, so no FK constraint

-- Refunds relationships
ALTER TABLE refunds ADD CONSTRAINT fk_refunds_tenant 
    FOREIGN KEY (tenant_id) REFERENCES tenants(id);

ALTER TABLE refunds ADD CONSTRAINT fk_refunds_payment 
    FOREIGN KEY (payment_id) REFERENCES payments(id);

ALTER TABLE refunds ADD CONSTRAINT fk_refunds_initiated_by 
    FOREIGN KEY (initiated_by) REFERENCES users(id);

-- Stripe events (no foreign keys needed - standalone table)

-- Subscription transitions relationships
ALTER TABLE subscription_transitions ADD CONSTRAINT fk_subscription_transitions_subscription 
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE;

ALTER TABLE subscription_transitions ADD CONSTRAINT fk_subscription_transitions_from_plan 
    FOREIGN KEY (from_plan_id) REFERENCES plans(id);

ALTER TABLE subscription_transitions ADD CONSTRAINT fk_subscription_transitions_to_plan 
    FOREIGN KEY (to_plan_id) REFERENCES plans(id);

ALTER TABLE subscription_transitions ADD CONSTRAINT fk_subscription_transitions_initiated_by 
    FOREIGN KEY (initiated_by) REFERENCES users(id);

-- Update ffc_invitations to support seat assignments
ALTER TABLE ffc_invitations 
    ADD COLUMN IF NOT EXISTS seat_type seat_type_enum,
    ADD COLUMN IF NOT EXISTS subscription_id UUID;

-- Add foreign key for subscription_id
ALTER TABLE ffc_invitations 
    ADD CONSTRAINT fk_ffc_invitations_subscription 
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;

-- ================================================================
-- INITIAL DATA INSERTS
-- ================================================================

-- Insert default Forward tenant (ID = 1)
INSERT INTO tenants (id, name, display_name, primary_color, secondary_color, is_active) VALUES
(1, 'forward-inheritance', 'Forward Inheritance Platform', '#1f2937', '#3b82f6', true);

-- Insert the 13 asset categories
INSERT INTO asset_categories (name, code, description, sort_order) VALUES
('Personal Directives', 'personal_directives', 'Power of Attorney, Healthcare Directive/Living will, Letter of Intent/Family Directive, HIPAA Authorization', 1),
('Trust', 'trust', 'Trust documents and agreements', 2),
('Will', 'will', 'Will documents', 3),
('Personal Property', 'personal_property', 'Jewelry, Precious Metals, Collectibles, Pets/Animals, Art, Furniture', 4),
('Operational Property', 'operational_property', 'Vehicles, Boats/Yacht, Equipment/Machinery, Appliances/Gear', 5),
('Inventory', 'inventory', 'Business inventory and fixtures', 6),
('Real Estate', 'real_estate', 'Property and Real Estate holdings', 7),
('Life Insurance', 'life_insurance', 'Life Insurance policies', 8),
('Financial Accounts', 'financial_accounts', 'Investments, Bank accounts, Retirement Accounts, College Savings', 9),
('Recurring Income', 'recurring_income', 'Royalties and recurring income streams', 10),
('Digital Assets', 'digital_assets', 'Intellectual Property, Digital Assets', 11),
('Ownership Interests', 'ownership_interests', 'Business and Franchise ownership', 12),
('Loans', 'loans', 'HEI and Interfamily Loans', 13);

-- Insert default free plan for Forward tenant
INSERT INTO plans (
    tenant_id, 
    plan_code, 
    plan_name, 
    plan_description,
    plan_type, 
    base_price, 
    billing_frequency,
    features,
    ui_config,
    status,
    is_public,
    sort_order
) VALUES (
    1,
    'FAMILY_UNLIMITED_FREE',
    'Family Unlimited Free',
    'Free forever plan with unlimited family members',
    'free',
    0.00,
    'lifetime',
    '{"unlimited_members": true, "basic_features": true, "document_storage": "5GB", "asset_tracking": true}'::jsonb,
    '{"hide_seat_management": true, "hide_billing_section": true, "show_unlimited_badge": true, "badge_text": "Unlimited Pro Members"}'::jsonb,
    'active',
    true,
    1
);

-- Get the plan ID for seat configuration
DO $$
DECLARE
    v_plan_id UUID;
BEGIN
    SELECT id INTO v_plan_id FROM plans WHERE plan_code = 'FAMILY_UNLIMITED_FREE' AND tenant_id = 1;
    
    -- Insert unlimited pro seats for free plan
    INSERT INTO plan_seats (
        plan_id,
        seat_type,
        included_quantity, -- NULL means unlimited
        max_quantity, -- NULL means unlimited
        additional_seat_price,
        features
    ) VALUES (
        v_plan_id,
        'pro',
        NULL, -- Unlimited included
        NULL, -- Unlimited max
        0.00,
        '{"all_features": true}'::jsonb
    );
END $$;

-- Insert Estate Capture Service
INSERT INTO services (
    tenant_id,
    service_code,
    service_name,
    service_description,
    price,
    service_type,
    features,
    delivery_timeline,
    status,
    is_public,
    sort_order
) VALUES (
    1,
    'ESTATE_CAPTURE_SERVICE',
    'Estate Capture Service',
    'Professional document capture and organization service for your estate planning documents',
    299.00,
    'one_time',
    '{"document_scanning": true, "professional_organization": true, "secure_storage": true, "expert_review": true}'::jsonb,
    '5-7 business days',
    'active',
    true,
    1
);

-- ================================================================
-- UI COLLECTION MASK SEED DATA
-- ================================================================

-- Insert entity mappings for all asset tables
INSERT INTO ui_entity (entity_code, table_name) VALUES
  ('ASSETS', 'assets'),
  ('DIRECTIVES', 'personal_directives'),
  ('TRUSTS', 'trusts'),
  ('WILLS', 'wills'),
  ('PERSONAL', 'personal_property'),
  ('OPERATIONAL', 'operational_property'),
  ('INVENTORY', 'inventory'),
  ('REALESTATE', 'real_estate'),
  ('INSURANCE', 'life_insurance'),
  ('ACCOUNTS', 'financial_accounts'),
  ('INCOME', 'recurring_income'),
  ('DIGITAL', 'digital_assets'),
  ('INTERESTS', 'ownership_interests'),
  ('LOANS', 'loans')
ON CONFLICT DO NOTHING;

-- Main Assets Table UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('ASSETS', 'name', 'mandatory', 'text', 1, 'Asset name/title'),
  ('ASSETS', 'description', 'mandatory', 'text', 2, 'Asset description'),
  ('ASSETS', 'estimated_value', 'mandatory', 'currency', 3, 'Current estimated value'),
  ('ASSETS', 'currency_code', 'mandatory', 'currency_code', 4, 'Currency (USD, EUR, etc)'),
  ('ASSETS', 'last_valued_date', 'mandatory', 'date', 5, 'Date of valuation');

-- Personal Directives UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('DIRECTIVES', 'directive_type', 'mandatory', 'enum', 1, 'power_of_attorney|healthcare_directive|living_will|hipaa_authorization|guardianship_designation|family_directive'),
  ('DIRECTIVES', 'directive_subtype', 'mandatory', 'text', 2, 'Specific directive subtype'),
  ('DIRECTIVES', 'agent_name', 'mandatory', 'text', 3, 'Agent/representative name'),
  ('DIRECTIVES', 'agent_email_address', 'mandatory', 'email', 4, 'Agent email contact (normalized)'),
  ('DIRECTIVES', 'agent_phone_number', 'mandatory', 'phone', 5, 'Agent phone contact (normalized)'),
  ('DIRECTIVES', 'successor_agent_1_name', 'mandatory', 'text', 6, 'First successor agent'),
  ('DIRECTIVES', 'healthcare_wishes', 'mandatory', 'text', 7, 'Healthcare preferences'),
  ('DIRECTIVES', 'life_support_preferences', 'mandatory', 'text', 8, 'Life support decisions'),
  ('DIRECTIVES', 'execution_date', 'mandatory', 'date', 9, 'Document execution date'),
  ('DIRECTIVES', 'state_of_execution', 'mandatory', 'text', 10, 'State where executed'),
  ('DIRECTIVES', 'notarized', 'mandatory', 'enum', 11, 'yes|no'),
  ('DIRECTIVES', 'witnesses', 'mandatory', 'int', 12, 'Number of witnesses');

-- Trusts UI Mask  
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('TRUSTS', 'trust_type', 'mandatory', 'enum', 1, 'revocable|irrevocable|living|testamentary|charitable|special_needs|generation_skipping|asset_protection'),
  ('TRUSTS', 'trust_name', 'mandatory', 'text', 2, 'Official trust name'),
  ('TRUSTS', 'grantor_name', 'mandatory', 'text', 3, 'Trust grantor/settlor'),
  ('TRUSTS', 'trustee_name', 'mandatory', 'text', 4, 'Current trustee name'),
  ('TRUSTS', 'trustee_email_address', 'mandatory', 'email', 5, 'Trustee email contact (normalized)'),
  ('TRUSTS', 'trustee_phone_number', 'mandatory', 'phone', 6, 'Trustee phone contact (normalized)'),
  ('TRUSTS', 'successor_trustee_name', 'mandatory', 'text', 7, 'Successor trustee'),
  ('TRUSTS', 'establishment_date', 'mandatory', 'date', 8, 'Trust creation date'),
  ('TRUSTS', 'state_of_establishment', 'mandatory', 'text', 9, 'Governing state law'),
  ('TRUSTS', 'trust_purpose', 'mandatory', 'text', 10, 'Purpose/objectives');

-- Wills UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('WILLS', 'will_type', 'mandatory', 'enum', 1, 'primary|secondary|codicil|holographic|joint'),
  ('WILLS', 'testator_name', 'mandatory', 'text', 2, 'Person making the will'),
  ('WILLS', 'executor_name', 'mandatory', 'text', 3, 'Primary executor name'),
  ('WILLS', 'executor_email_address', 'mandatory', 'email', 4, 'Executor email contact (normalized)'),
  ('WILLS', 'executor_phone_number', 'mandatory', 'phone', 5, 'Executor phone contact (normalized)'),
  ('WILLS', 'successor_executor_name', 'mandatory', 'text', 6, 'Backup executor'),
  ('WILLS', 'execution_date', 'mandatory', 'date', 7, 'Will signing date'),
  ('WILLS', 'state_of_execution', 'mandatory', 'text', 8, 'State where executed'),
  ('WILLS', 'witnesses', 'mandatory', 'int', 9, 'Number of witnesses'),
  ('WILLS', 'notarized', 'mandatory', 'enum', 10, 'yes|no');

-- Personal Property UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('PERSONAL', 'property_type', 'mandatory', 'enum', 1, 'jewelry|precious_metals|collectibles|art|furniture|pets_animals|books|clothing|electronics'),
  ('PERSONAL', 'property_subtype', 'mandatory', 'text', 2, 'Specific item category'),
  ('PERSONAL', 'item_name', 'mandatory', 'text', 3, 'Specific item name'),
  ('PERSONAL', 'brand_manufacturer', 'mandatory', 'text', 4, 'Brand or maker'),
  ('PERSONAL', 'model_style', 'mandatory', 'text', 5, 'Model or style info'),
  ('PERSONAL', 'material_composition', 'mandatory', 'text', 6, 'Materials used'),
  ('PERSONAL', 'dimensions', 'mandatory', 'text', 7, 'Size/dimensions'),
  ('PERSONAL', 'weight', 'mandatory', 'real', 8, 'Weight if applicable'),
  ('PERSONAL', 'purchase_date', 'mandatory', 'date', 9, 'Date acquired'),
  ('PERSONAL', 'purchase_price', 'mandatory', 'currency', 10, 'Original purchase price'),
  ('PERSONAL', 'current_location_address', 'mandatory', 'text', 11, 'Where item is kept (normalized)');

-- Operational Property UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('OPERATIONAL', 'property_type', 'mandatory', 'enum', 1, 'vehicle|boat|aircraft|equipment|machinery|tools'),
  ('OPERATIONAL', 'property_subtype', 'mandatory', 'text', 2, 'Specific type'),
  ('OPERATIONAL', 'make', 'mandatory', 'text', 3, 'Manufacturer/brand'),
  ('OPERATIONAL', 'model', 'mandatory', 'text', 4, 'Model name/number'),
  ('OPERATIONAL', 'year', 'mandatory', 'year', 5, 'Year manufactured'),
  ('OPERATIONAL', 'vin_serial_number', 'mandatory', 'text', 6, 'VIN or serial number'),
  ('OPERATIONAL', 'registration_number', 'mandatory', 'text', 7, 'License/registration'),
  ('OPERATIONAL', 'condition', 'mandatory', 'enum', 8, 'excellent|very_good|good|fair|poor'),
  ('OPERATIONAL', 'mileage_hours', 'mandatory', 'int', 9, 'Usage measurement'),
  ('OPERATIONAL', 'purchase_date', 'mandatory', 'date', 10, 'Date acquired'),
  ('OPERATIONAL', 'purchase_price', 'mandatory', 'currency', 11, 'Original cost');

-- Inventory UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('INVENTORY', 'inventory_type', 'mandatory', 'enum', 1, 'business_stock|collections|commodities|raw_materials|finished_goods'),
  ('INVENTORY', 'inventory_subtype', 'mandatory', 'text', 2, 'Specific inventory category'),
  ('INVENTORY', 'item_description', 'mandatory', 'text', 3, 'Detailed description'),
  ('INVENTORY', 'quantity', 'mandatory', 'int', 4, 'Number of items'),
  ('INVENTORY', 'unit_of_measure', 'mandatory', 'enum', 5, 'each|pounds|kilograms|tons|gallons|liters|cubic_feet'),
  ('INVENTORY', 'cost_per_unit', 'mandatory', 'currency', 6, 'Cost per unit'),
  ('INVENTORY', 'market_value_per_unit', 'mandatory', 'currency', 7, 'Current market value per unit'),
  ('INVENTORY', 'storage_location_address', 'mandatory', 'text', 8, 'Where inventory is stored (normalized)'),
  ('INVENTORY', 'condition', 'mandatory', 'enum', 9, 'excellent|good|fair|poor|damaged'),
  ('INVENTORY', 'last_inventory_date', 'mandatory', 'date', 10, 'Last physical count');

-- Real Estate UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('REALESTATE', 'property_type', 'mandatory', 'enum', 1, 'primary_residence|investment_property|commercial|vacant_land|rental_property'),
  ('REALESTATE', 'property_subtype', 'mandatory', 'text', 2, 'Specific property type'),
  ('REALESTATE', 'address_line_1', 'mandatory', 'text', 3, 'Property street address (normalized)'),
  ('REALESTATE', 'address_line_2', 'mandatory', 'text', 4, 'Address line 2 (normalized)'),
  ('REALESTATE', 'city', 'mandatory', 'text', 5, 'City (normalized)'),
  ('REALESTATE', 'state_province', 'mandatory', 'text', 6, 'State/Province (normalized)'),
  ('REALESTATE', 'postal_code', 'mandatory', 'zip', 7, 'ZIP/Postal code (normalized)'),
  ('REALESTATE', 'country', 'mandatory', 'text', 8, 'Country (normalized)'),
  ('REALESTATE', 'parcel_number', 'mandatory', 'text', 9, 'Tax parcel number'),
  ('REALESTATE', 'lot_size_acres', 'mandatory', 'real', 10, 'Lot size in acres'),
  ('REALESTATE', 'building_size_sqft', 'mandatory', 'int', 11, 'Building square footage'),
  ('REALESTATE', 'bedrooms', 'mandatory', 'int', 12, 'Number of bedrooms'),
  ('REALESTATE', 'bathrooms', 'mandatory', 'real', 13, 'Number of bathrooms'),
  ('REALESTATE', 'year_built', 'mandatory', 'year', 14, 'Year constructed'),
  ('REALESTATE', 'ownership_type', 'mandatory', 'enum', 15, 'fee_simple|leasehold|life_estate|joint_tenancy|tenancy_in_common');

-- Life Insurance UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('INSURANCE', 'policy_type', 'mandatory', 'enum', 1, 'term|whole_life|universal|variable|variable_universal'),
  ('INSURANCE', 'insurance_company', 'mandatory', 'text', 2, 'Insurance company name'),
  ('INSURANCE', 'policy_number', 'mandatory', 'text', 3, 'Policy number'),
  ('INSURANCE', 'insured_name', 'mandatory', 'text', 4, 'Insured person name'),
  ('INSURANCE', 'beneficiary_primary', 'mandatory', 'text', 5, 'Primary beneficiary'),
  ('INSURANCE', 'beneficiary_contingent', 'mandatory', 'text', 6, 'Contingent beneficiary'),
  ('INSURANCE', 'coverage_amount', 'mandatory', 'currency', 7, 'Death benefit amount'),
  ('INSURANCE', 'annual_premium', 'mandatory', 'currency', 8, 'Annual premium cost'),
  ('INSURANCE', 'policy_start_date', 'mandatory', 'date', 9, 'Policy effective date'),
  ('INSURANCE', 'premium_payment_frequency', 'mandatory', 'enum', 10, 'monthly|quarterly|semi_annually|annually'),
  ('INSURANCE', 'agent_name', 'mandatory', 'text', 11, 'Insurance agent name'),
  ('INSURANCE', 'agent_email_address', 'mandatory', 'email', 12, 'Agent email contact (normalized)'),
  ('INSURANCE', 'agent_phone_number', 'mandatory', 'phone', 13, 'Agent phone contact (normalized)');

-- Financial Accounts UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('ACCOUNTS', 'institution_name', 'mandatory', 'text', 1, 'Bank/Financial institution'),
  ('ACCOUNTS', 'account_type', 'mandatory', 'enum', 2, 'checking|savings|money_market|cd|investment|retirement|college_savings'),
  ('ACCOUNTS', 'account_number_last_four', 'mandatory', 'text', 3, 'Last 4 digits of account'),
  ('ACCOUNTS', 'routing_number_last_four', 'mandatory', 'text', 4, 'Last 4 digits of routing'),
  ('ACCOUNTS', 'account_title', 'mandatory', 'text', 5, 'Account title/name'),
  ('ACCOUNTS', 'date_opened', 'mandatory', 'date', 6, 'Account opening date'),
  ('ACCOUNTS', 'current_balance', 'mandatory', 'currency', 7, 'Current account balance'),
  ('ACCOUNTS', 'balance_as_of_date', 'mandatory', 'date', 8, 'Balance date'),
  ('ACCOUNTS', 'institution_contact_email_address', 'mandatory', 'email', 9, 'Institution email contact (normalized)'),
  ('ACCOUNTS', 'institution_contact_phone_number', 'mandatory', 'phone', 10, 'Institution phone contact (normalized)');

-- Recurring Income UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('INCOME', 'income_type', 'mandatory', 'enum', 1, 'royalties|pension|rental_income|social_security|dividends|interest|annuity'),
  ('INCOME', 'income_source', 'mandatory', 'text', 2, 'Source description'),
  ('INCOME', 'payer_name', 'mandatory', 'text', 3, 'Who pays the income'),
  ('INCOME', 'payer_address_line_1', 'mandatory', 'text', 4, 'Payer address (normalized)'),
  ('INCOME', 'payer_email_address', 'mandatory', 'email', 5, 'Payer email contact (normalized)'),
  ('INCOME', 'payer_phone_number', 'mandatory', 'phone', 6, 'Payer phone contact (normalized)'),
  ('INCOME', 'payment_amount', 'mandatory', 'currency', 7, 'Payment amount'),
  ('INCOME', 'payment_frequency', 'mandatory', 'enum', 8, 'weekly|bi_weekly|monthly|quarterly|semi_annually|annually'),
  ('INCOME', 'payment_start_date', 'mandatory', 'date', 9, 'When payments began'),
  ('INCOME', 'payment_end_date', 'mandatory', 'date', 10, 'When payments end');

-- Digital Assets UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('DIGITAL', 'asset_type', 'mandatory', 'enum', 1, 'cryptocurrency|intellectual_property|domain_name|digital_account|nft|software_license'),
  ('DIGITAL', 'asset_subtype', 'mandatory', 'text', 2, 'Specific asset subtype'),
  ('DIGITAL', 'asset_name', 'mandatory', 'text', 3, 'Asset name/identifier'),
  ('DIGITAL', 'platform_service', 'mandatory', 'text', 4, 'Platform or service'),
  ('DIGITAL', 'wallet_address', 'mandatory', 'text', 5, 'Wallet/account identifier'),
  ('DIGITAL', 'access_credentials', 'mandatory', 'text', 6, 'Access method/credentials'),
  ('DIGITAL', 'recovery_information', 'mandatory', 'text', 7, 'Recovery keys/phrases'),
  ('DIGITAL', 'quantity_amount', 'mandatory', 'real', 8, 'Quantity or amount'),
  ('DIGITAL', 'acquisition_date', 'mandatory', 'date', 9, 'Date acquired'),
  ('DIGITAL', 'acquisition_cost', 'mandatory', 'currency', 10, 'Original cost');

-- Ownership Interests UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('INTERESTS', 'interest_type', 'mandatory', 'enum', 1, 'business_equity|partnership|franchise|joint_venture|cooperative'),
  ('INTERESTS', 'entity_name', 'mandatory', 'text', 2, 'Business entity name'),
  ('INTERESTS', 'entity_type', 'mandatory', 'enum', 3, 'corporation|llc|partnership|sole_proprietorship|trust'),
  ('INTERESTS', 'ownership_percentage', 'mandatory', 'real', 4, 'Percentage owned'),
  ('INTERESTS', 'number_of_shares', 'mandatory', 'int', 5, 'Shares/units owned'),
  ('INTERESTS', 'share_class', 'mandatory', 'text', 6, 'Class of shares'),
  ('INTERESTS', 'valuation_method', 'mandatory', 'enum', 7, 'book_value|market_value|appraised_value|revenue_multiple|asset_based'),
  ('INTERESTS', 'acquisition_date', 'mandatory', 'date', 8, 'Date acquired'),
  ('INTERESTS', 'acquisition_cost', 'mandatory', 'currency', 9, 'Original investment'),
  ('INTERESTS', 'voting_rights', 'mandatory', 'enum', 10, 'full_voting|limited_voting|non_voting|super_voting');

-- Loans UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('LOANS', 'loan_type', 'mandatory', 'enum', 1, 'hei|interfamily|mortgage|personal|business|student|auto'),
  ('LOANS', 'lender_name', 'mandatory', 'text', 2, 'Lender name'),
  ('LOANS', 'borrower_name', 'mandatory', 'text', 3, 'Borrower name'),
  ('LOANS', 'loan_amount', 'mandatory', 'currency', 4, 'Original loan amount'),
  ('LOANS', 'outstanding_balance', 'mandatory', 'currency', 5, 'Current balance owed'),
  ('LOANS', 'interest_rate', 'mandatory', 'real', 6, 'Interest rate percentage'),
  ('LOANS', 'loan_term_years', 'mandatory', 'int', 7, 'Loan term in years'),
  ('LOANS', 'monthly_payment', 'mandatory', 'currency', 8, 'Monthly payment amount'),
  ('LOANS', 'origination_date', 'mandatory', 'date', 9, 'Loan start date'),
  ('LOANS', 'maturity_date', 'mandatory', 'date', 10, 'Loan end date'),
  ('LOANS', 'lender_contact_email_address', 'mandatory', 'email', 11, 'Lender email contact (normalized)'),
  ('LOANS', 'lender_contact_phone_number', 'mandatory', 'phone', 12, 'Lender phone contact (normalized)');

-- ================================================================
-- VIEWS FOR DATA VALIDATION
-- ================================================================

-- View to check Quiltt integration consistency
CREATE VIEW v_quiltt_integration_status AS
SELECT 
    qi.id as integration_id,
    qi.persona_id,
    p.first_name || ' ' || p.last_name as persona_name,
    qi.quiltt_user_id,
    qi.quiltt_connection_id,
    qi.connection_status,
    qi.is_active,
    COUNT(fa.id) as connected_accounts_count,
    qi.last_sync_at,
    qi.sync_status
FROM quiltt_integrations qi
JOIN personas p ON qi.persona_id = p.id
LEFT JOIN financial_accounts fa ON fa.quiltt_integration_id = qi.id
GROUP BY qi.id, qi.persona_id, p.first_name, p.last_name, qi.quiltt_user_id, 
         qi.quiltt_connection_id, qi.connection_status, qi.is_active, 
         qi.last_sync_at, qi.sync_status;

-- View to check financial accounts with Quiltt data
CREATE VIEW v_quiltt_financial_accounts AS
SELECT 
    fa.id as asset_id,
    a.name as asset_name,
    fa.institution_name,
    fa.account_type,
    fa.current_balance,
    fa.is_quiltt_connected,
    fa.quiltt_account_id,
    fa.last_quiltt_sync_at,
    qi.quiltt_user_id,
    qi.connection_status,
    p.first_name || ' ' || p.last_name as owner_name
FROM financial_accounts fa
JOIN assets a ON fa.asset_id = a.id
LEFT JOIN quiltt_integrations qi ON fa.quiltt_integration_id = qi.id
LEFT JOIN asset_persona ap ON a.id = ap.asset_id AND ap.ownership_type = 'owner'
LEFT JOIN personas p ON ap.persona_id = p.id
WHERE fa.is_quiltt_connected = TRUE;

-- ================================================================
-- END OF SCHEMA RELATIONSHIPS FILE
-- ================================================================