● 🔐 Users and Roles: Understanding the RBAC System

  The Forward Inheritance platform implements a sophisticated Role-Based Access Control (RBAC) system. Here's how users connect to roles:

  📊 Core Tables and Relationships

  Users → User Role Assignments → User Roles → Role Permissions → User Permissions
    ↓              ↓                    ↓              ↓                    ↓
  WHO         ASSIGNMENTS           WHAT ROLE      WHAT ACCESS         SPECIFIC ACTIONS

  1️⃣ User Roles Table (Role Definitions)

  Defines the available roles in the system:

  CREATE TABLE user_roles (
      id UUID PRIMARY KEY,
      name VARCHAR(100) UNIQUE,        -- 'ffc_owner', 'ffc_member', etc.
      display_name VARCHAR(200),       -- 'FFC Owner', 'FFC Member'
      description TEXT,
      parent_role_id UUID,             -- Role hierarchy
      is_system_role BOOLEAN,          -- Platform-defined vs custom
      is_default_role BOOLEAN,         -- Auto-assigned role
      status VARCHAR(50) DEFAULT 'active'
  );

  System Roles:
  - platform_admin - Full platform access
  - ffc_owner - Full control within specific FFC
  - ffc_admin - Administrative access within FFC
  - ffc_member - Standard member access (default)
  - ffc_viewer - Read-only access

  2️⃣ User Role Assignments (The Key Link)

  This is the critical junction table that connects users to roles within specific FFCs:

  CREATE TABLE user_role_assignments (
      id UUID PRIMARY KEY,
      user_id UUID REFERENCES users(id),
      role_id UUID REFERENCES user_roles(id),

      -- 🎯 THIS IS THE KEY: FFC-SCOPED ASSIGNMENTS
      ffc_id UUID REFERENCES family_financial_circles(id),

      assigned_by UUID REFERENCES users(id),
      assigned_at TIMESTAMP,
      expires_at TIMESTAMP,              -- Time-limited roles
      is_active BOOLEAN DEFAULT TRUE,

      UNIQUE(user_id, role_id, ffc_id)  -- One role per user per FFC
  );

  3️⃣ User Permissions Table

  Defines granular permissions:

  CREATE TABLE user_permissions (
      id UUID PRIMARY KEY,
      name VARCHAR(100) UNIQUE,          -- 'asset.create', 'user.invite'
      display_name VARCHAR(200),
      description TEXT,
      category VARCHAR(50),              -- 'asset', 'user', 'admin'
      is_dangerous BOOLEAN DEFAULT FALSE -- Destructive operations
  );

  4️⃣ Role Permissions (Role-to-Permission Mapping)

  Links roles to their permissions:

  CREATE TABLE role_permissions (
      id UUID PRIMARY KEY,
      role_id UUID REFERENCES user_roles(id),
      permission_id UUID REFERENCES user_permissions(id),

      UNIQUE(role_id, permission_id)
  );

  🔄 How It All Works Together

  Example: John's Multi-FFC Access

  -- John is FFC Owner in Smith Family FFC
  INSERT INTO user_role_assignments
  (user_id, role_id, ffc_id) VALUES
  ('john-uuid', 'ffc_owner-uuid', 'smith-family-ffc-uuid');

  -- John is FFC Member in Johnson Family FFC
  INSERT INTO user_role_assignments
  (user_id, role_id, ffc_id) VALUES
  ('john-uuid', 'ffc_member-uuid', 'johnson-family-ffc-uuid');

  🔍 Permission Verification Function

  The system checks permissions using this pattern:

  CREATE OR REPLACE FUNCTION verify_user_permissions(
      p_user_id UUID,
      p_ffc_id UUID,          -- Context-specific check
      p_permission_name VARCHAR
  ) RETURNS BOOLEAN AS $$
  BEGIN
      SELECT TRUE
      FROM user_role_assignments ura
      JOIN role_permissions rp ON rp.role_id = ura.role_id
      JOIN user_permissions up ON up.id = rp.permission_id
      WHERE ura.user_id = p_user_id
      AND ura.ffc_id = p_ffc_id      -- FFC-scoped check
      AND ura.is_active = TRUE
      AND up.name = p_permission_name;
  END;
  $$;

  📋 Permission Examples by Role

  FFC Owner Permissions:
  - asset.create - Create new assets
  - asset.delete - Delete assets
  - user.invite - Invite new members
  - user.remove - Remove members
  - ffc.settings - Manage FFC settings
  - reports.generate - Generate reports

  FFC Member Permissions:
  - asset.view - View assets (with asset-level permissions)
  - asset.create - Create own assets
  - profile.edit - Edit own profile
  - document.upload - Upload documents

  FFC Viewer Permissions:
  - asset.view - View permitted assets only
  - reports.view - View reports

  🎯 Key Design Features

  1. Multi-Tenancy Support
  - Same user, different roles in different FFCs
  - FFC-scoped permissions prevent cross-contamination

  2. Role Hierarchy
  Platform Admin
      └── FFC Owner
              └── FFC Admin
                      └── FFC Member
                              └── FFC Viewer

  3. Time-Based Assignments
  -- Temporary admin access
  INSERT INTO user_role_assignments
  (user_id, role_id, ffc_id, expires_at) VALUES
  ('user-uuid', 'ffc_admin-uuid', 'ffc-uuid', NOW() + INTERVAL '30 days');

  4. Default Role Assignment
  -- New members automatically get 'ffc_member' role
  CREATE TRIGGER assign_default_role
  AFTER INSERT ON ffc_personas
  FOR EACH ROW
  EXECUTE FUNCTION assign_default_member_role();

  🔒 Security Benefits

  1. Principle of Least Privilege: Users only get permissions they need
  2. Context-Aware: Permissions are FFC-specific
  3. Auditable: All role assignments are tracked
  4. Flexible: Easy to add new roles/permissions
  5. Scalable: Efficient permission checking via database

  📊 Real-World Scenario

  Sarah's Access:
  ├── Smith Family FFC
  │   ├── Role: FFC Owner
  │   └── Can: Create/Edit/Delete all assets, Invite members, Manage settings
  │
  ├── Johnson Trust FFC
  │   ├── Role: FFC Admin
  │   └── Can: Create/Edit assets, View reports, Cannot delete
  │
  └── Aunt Mary's FFC
      ├── Role: FFC Viewer
      └── Can: View permitted assets only

  This RBAC system ensures that users have appropriate access levels across multiple family circles while maintaining security and clear       
  boundaries between different FFCs.