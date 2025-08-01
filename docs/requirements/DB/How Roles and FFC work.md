● Based on the architecture analysis, here's how the role system enables a persona to be an FFC Owner in one FFC and FFC Member in another:

  🔑 Multi-Tenancy Role Assignment Architecture

  Key Table: user_role_assignments

  The critical mechanism is the ffc_id field in the user_role_assignments table:

  CREATE TABLE user_role_assignments (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES users(id),
      role_id UUID NOT NULL REFERENCES user_roles(id),

      -- 🎯 THIS IS THE KEY: FFC-SCOPED ASSIGNMENTS
      ffc_id UUID NOT NULL REFERENCES family_financial_circles(id),

      assigned_by UUID NOT NULL REFERENCES users(id),
      is_active BOOLEAN DEFAULT TRUE,
      expires_at TIMESTAMP WITH TIME ZONE,

      -- Prevents duplicate role assignments per FFC
      UNIQUE(user_id, role_id, ffc_id)
  );

  How Multi-FFC Roles Work

  🔄 Same User, Different Roles, Different FFCs:

  -- Example: John Smith can have different roles in different FFCs
  INSERT INTO user_role_assignments VALUES
  -- John is FFC Owner in the Smith Family FFC
  ('john-uuid', 'ffc_owner-role-uuid', 'smith-family-ffc-uuid'),

  -- John is FFC Member in the Johnson Family FFC (married into family)
  ('john-uuid', 'ffc_member-role-uuid', 'johnson-family-ffc-uuid'),

  -- John is FFC Viewer in the Business Partners FFC
  ('john-uuid', 'ffc_viewer-role-uuid', 'business-partners-ffc-uuid');

  🏗️ Architecture Components

  1. User Roles Table (System-Wide Roles)
  CREATE TABLE user_roles (
      id UUID PRIMARY KEY,
      name VARCHAR(100), -- 'ffc_owner', 'ffc_member', 'ffc_viewer', etc.
      display_name VARCHAR(200),
      hierarchy_level INTEGER,
      is_system_role BOOLEAN
  );

  System Roles Available:
  - platform_admin - Full platform access
  - ffc_owner - Full control within specific FFC
  - ffc_admin - Administrative access within specific FFC
  - ffc_member - Standard member access within specific FFC
  - ffc_viewer - Read-only access within specific FFC

  2. Dual Role System
  The architecture actually has two complementary role systems:

  A. User Role Assignments (Platform Access Control)
  - Controls what a user can do at the platform level
  - Scoped by FFC via ffc_id field

  B. FFC Persona Roles (Business Logic Roles)
  CREATE TABLE ffc_personas (
      ffc_id UUID REFERENCES ffcs(id),
      persona_id UUID REFERENCES personas(id),
      role ffc_role_enum, -- 'owner', 'beneficiary', 'non_beneficiary'
      UNIQUE(ffc_id, persona_id)
  );

  🔐 Permission Verification Function

  The system uses this function to check permissions in specific FFCs:

  CREATE OR REPLACE FUNCTION verify_user_permissions(
      p_user_id UUID,
      p_ffc_id UUID,  -- 🎯 FFC-specific permission check
      p_permission_name VARCHAR(100)
  ) RETURNS BOOLEAN AS $$
  BEGIN
      -- Check if user has permission in THIS specific FFC
      SELECT TRUE INTO v_has_permission
      FROM user_role_assignments ura
      JOIN user_roles ur ON ur.id = ura.role_id
      WHERE ura.user_id = p_user_id
      AND ura.ffc_id = p_ffc_id  -- 🔑 FFC-scoped check
      AND ura.is_active = TRUE;

      RETURN COALESCE(v_has_permission, FALSE);
  END;
  $$;

  🛡️ Row-Level Security Enforcement

  RLS policies ensure users only see data from FFCs they have access to:

  CREATE POLICY assets_ffc_isolation ON assets
  FOR ALL TO authenticated_users
  USING (
      ffc_id IN (
          SELECT ffc_id
          FROM user_role_assignments
          WHERE user_id = current_setting('app.current_user_id')::UUID
          AND is_active = TRUE
      )
  );

  📋 Real-World Example

  Scenario: John Smith is part of multiple family circles

  Smith Family FFC (john-uuid):
  - user_role_assignments: john-uuid + ffc_owner + smith-ffc-uuid
  - Result: John can create assets, invite members, manage FFC

  Johnson Family FFC (wife's family):
  - user_role_assignments: john-uuid + ffc_member + johnson-ffc-uuid
  - Result: John can view assets he's granted access to, cannot manage FFC

  Business Partnership FFC:
  - user_role_assignments: john-uuid + ffc_viewer + business-ffc-uuid
  - Result: John has read-only access to shared business assets

  🎯 Key Benefits

  ✅ True Multi-Tenancy: Each FFC is completely isolated
  ✅ Flexible Permissions: Same user, different roles per FFC
  ✅ Scalable: Supports complex family structures and relationships✅ Secure: Row-level security prevents cross-FFC data leakage
  ✅ Auditable: All role assignments tracked with timestamps and assignment history

  The ffc_id field in user_role_assignments is the cornerstone that enables this flexible, secure multi-tenant role system where users can     
   have different levels of access and responsibility across multiple Family Financial Circles.