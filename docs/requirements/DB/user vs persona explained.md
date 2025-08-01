👥 Users vs Personas: Understanding the Relationship

  The Forward Inheritance platform uses a two-layer identity model that separates authentication (Users) from business identity
  (Personas). Here's how they work together:

  📋 Core Concept

  User (Authentication) → 1-to-Many → Personas (Business Identity)
           ↓                                    ↓
     Login/Security                    Family Member Identity

  🔐 Users Table (Authentication Layer)

  The users table handles authentication and account security:

  CREATE TABLE users (
      id UUID PRIMARY KEY,
      primary_email_id UUID REFERENCES email_address(id),  -- Login email
      primary_phone_id UUID REFERENCES phone_number(id),   -- MFA phone
      password_hash VARCHAR(255),                          -- Authentication
      email_verified BOOLEAN,                              -- Security verification
      first_name VARCHAR(100),                             -- Basic profile
      last_name VARCHAR(100),
      status VARCHAR(50),                                  -- Account status
      ...
  );

  Purpose:
  - Login credentials
  - Password management
  - Account security (lockouts, MFA)
  - Basic profile information
  - Platform-wide settings

  👤 Personas Table (Business Identity Layer)

  The personas table represents individuals within family circles:

  CREATE TABLE personas (
      id UUID PRIMARY KEY,
      user_id UUID REFERENCES users(id),      -- Links to authentication
      first_name VARCHAR(255),                -- Can differ from user profile
      middle_name VARCHAR(255),
      last_name VARCHAR(255),
      name_suffix VARCHAR(20),
      date_of_birth DATE,
      date_of_death DATE,                     -- Can represent deceased
      is_living BOOLEAN DEFAULT true,
      ...
  );

  Purpose:
  - Represents family members (living or deceased)
  - Holds personal/demographic information
  - Can exist without a user account
  - Links to assets, documents, relationships

  🔗 Key Relationships

  1. User → Personas (One-to-Many)

  A single user account can have multiple personas:

  -- Example: John Smith has multiple personas
  User: john@email.com
  ├── Persona 1: "John Smith" (personal)
  ├── Persona 2: "John Smith - Trustee" (Smith Family Trust)
  └── Persona 3: "John Smith - Executor" (Parent's Estate)

  2. Personas → FFCs (Many-to-Many)

  Personas join Family Financial Circles through ffc_personas:

  CREATE TABLE ffc_personas (
      ffc_id UUID REFERENCES ffcs(id),
      persona_id UUID REFERENCES personas(id),
      role ffc_role_enum,  -- 'owner', 'beneficiary', 'non_beneficiary'
      UNIQUE(ffc_id, persona_id)
  );

  3. Personas → Assets (Ownership)

  Personas own assets through asset_persona_ownership:

  CREATE TABLE asset_persona_ownership (
      asset_id UUID REFERENCES assets(id),
      persona_id UUID REFERENCES personas(id),
      ownership_percentage DECIMAL(5,2),
      ownership_type ownership_type_enum,  -- 'direct', 'trust', 'beneficiary'
  );

  💡 Why This Design?

  1. Deceased Family Members
  - Personas can represent deceased individuals who own assets
  - No user account needed for deceased personas
  - Important for estate planning and inheritance tracking

  2. Multiple Roles
  - Same person can have different roles in different contexts
  - John as individual vs John as trustee
  - Keeps legal/fiduciary roles separate

  3. Privacy & Permissions
  - User controls authentication
  - Persona controls business relationships
  - Different personas can have different visibility/permissions

  4. Professional Representatives
  - Lawyers/advisors can have user accounts
  - Create personas to act on behalf of clients
  - Clear audit trail of who did what in which capacity

  📊 Real-World Example

  Sarah Johnson (User Account)
  │
  ├── Personal Persona: "Sarah Johnson"
  │   ├── Member of: Johnson Family FFC
  │   ├── Owns: 50% of family home
  │   └── Role: FFC Owner
  │
  ├── Professional Persona: "Sarah Johnson, Trustee"
  │   ├── Member of: Johnson Family Trust FFC
  │   ├── Controls: Trust assets
  │   └── Role: Trustee
  │
  └── Representative Persona: "Sarah Johnson, POA for Mom"
      ├── Member of: Mom's Estate FFC
      ├── Manages: Mom's assets
      └── Role: Power of Attorney

  🔑 Key Takeaways

  1. Users = Authentication & Security (WHO can log in)
  2. Personas = Business Identity (WHO owns/controls assets)
  3. One User → Many Personas (different hats/roles)
  4. Personas can exist without users (deceased, minors)
  5. Assets are owned by Personas, not Users
  6. Permissions are granted to Personas within FFCs

  This separation provides maximum flexibility for complex family structures while maintaining security and clear audit trails.