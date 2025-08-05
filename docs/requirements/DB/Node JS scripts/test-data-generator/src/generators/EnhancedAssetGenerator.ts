import { faker } from '@faker-js/faker';
import { TestAsset, AssetCategory } from '../types';

/**
 * Enhanced Asset Generator for Forward Inheritance Platform
 * 
 * Generates realistic assets across all 13 categories with proper 
 * wealth distribution and category-specific metadata
 */
export class EnhancedAssetGenerator {
  
  /**
   * Generate assets across all 13 categories for realistic wealth distribution
   */
  generateAssets(
    count: number,
    tenantId: string,
    ffcId: string,
    createdByPersonaId: string,
    scenario: 'high_net_worth' | 'mass_affluent' | 'mixed' = 'mixed'
  ): TestAsset[] {
    const assets: TestAsset[] = [];
    
    // Determine wealth level for this set of assets
    const wealthLevel = this.determineWealthLevel(scenario);
    
    // Generate assets with realistic distribution across categories
    const distribution = this.getAssetDistribution(wealthLevel);
    
    for (const [category, percentage] of Object.entries(distribution)) {
      const categoryCount = Math.floor(count * percentage);
      for (let i = 0; i < categoryCount; i++) {
        const asset = this.generateAssetByCategory(
          category as AssetCategory,
          tenantId,
          ffcId,
          createdByPersonaId,
          wealthLevel
        );
        assets.push(asset);
      }
    }
    
    return assets;
  }

  /**
   * PUBLIC: Generate a single asset by category (for stored procedure integration)
   */
  generateAssetByCategory(
    category: AssetCategory,
    tenantId: string,
    ffcId: string,
    createdByPersonaId: string,
    wealthLevel: 'high_net_worth' | 'mass_affluent'
  ): TestAsset {
    const baseAsset = {
      tenant_id: tenantId,
      ffc_id: ffcId,
      category,
      currency: 'USD',
      created_by_persona_id: createdByPersonaId,
      created_at: this.generateAssetCreationDate(),
      updated_at: new Date()
    };

    switch (category) {
      case 'personal_directives':
        return { ...baseAsset, ...this.generatePersonalDirectives(wealthLevel) };
      case 'trust':
        return { ...baseAsset, ...this.generateTrust(wealthLevel) };
      case 'will':
        return { ...baseAsset, ...this.generateWill(wealthLevel) };
      case 'personal_property':
        return { ...baseAsset, ...this.generatePersonalProperty(wealthLevel) };
      case 'operational_property':
        return { ...baseAsset, ...this.generateOperationalProperty(wealthLevel) };
      case 'inventory':
        return { ...baseAsset, ...this.generateInventory(wealthLevel) };
      case 'real_estate':
        return { ...baseAsset, ...this.generateRealEstate(wealthLevel) };
      case 'life_insurance':
        return { ...baseAsset, ...this.generateLifeInsurance(wealthLevel) };
      case 'financial_accounts':
        return { ...baseAsset, ...this.generateFinancialAccount(wealthLevel) };
      case 'recurring_income':
        return { ...baseAsset, ...this.generateRecurringIncome(wealthLevel) };
      case 'digital_assets':
        return { ...baseAsset, ...this.generateDigitalAssets(wealthLevel) };
      case 'ownership_interests':
        return { ...baseAsset, ...this.generateOwnershipInterests(wealthLevel) };
      case 'loans':
        return { ...baseAsset, ...this.generateLoans(wealthLevel) };
      default:
        throw new Error(`Unknown asset category: ${category}`);
    }
  }

  private determineWealthLevel(scenario: 'high_net_worth' | 'mass_affluent' | 'mixed'): 'high_net_worth' | 'mass_affluent' {
    if (scenario === 'mixed') {
      // 30% high net worth, 70% mass affluent for test coverage
      return faker.datatype.boolean(0.3) ? 'high_net_worth' : 'mass_affluent';
    }
    return scenario;
  }

  private getAssetDistribution(wealthLevel: 'high_net_worth' | 'mass_affluent'): Record<AssetCategory, number> {
    if (wealthLevel === 'high_net_worth') {
      return {
        'financial_accounts': 0.25,    // 25% - Diverse investment portfolio
        'real_estate': 0.20,           // 20% - Multiple properties
        'ownership_interests': 0.15,   // 15% - Business interests
        'trust': 0.10,                 // 10% - Estate planning trusts
        'personal_property': 0.08,     // 8% - Art, jewelry, collectibles
        'life_insurance': 0.06,        // 6% - High-value policies
        'loans': 0.05,                 // 5% - HEI, interfamily loans
        'operational_property': 0.04,  // 4% - Luxury vehicles, boats
        'will': 0.03,                  // 3% - Complex estate documents
        'personal_directives': 0.02,   // 2% - Legal directives
        'recurring_income': 0.01,      // 1% - Royalties, patents
        'digital_assets': 0.005,       // 0.5% - Crypto, domains
        'inventory': 0.005             // 0.5% - Business inventory
      };
    } else {
      return {
        'financial_accounts': 0.35,    // 35% - Primary focus
        'real_estate': 0.25,           // 25% - Home + maybe rental
        'life_insurance': 0.12,        // 12% - Term/whole life
        'personal_property': 0.10,     // 10% - Household items
        'operational_property': 0.08,  // 8% - Cars, equipment
        'will': 0.04,                  // 4% - Basic estate planning
        'personal_directives': 0.03,   // 3% - Healthcare directives
        'loans': 0.02,                 // 2% - Mortgages, loans
        'trust': 0.005,                // 0.5% - Simple trusts
        'ownership_interests': 0.005,  // 0.5% - Small business
        'recurring_income': 0.003,     // 0.3% - Side income
        'digital_assets': 0.001,       // 0.1% - Minimal crypto
        'inventory': 0.001             // 0.1% - Personal inventory
      };
    }
  }

  // Asset Category Generators

  private generatePersonalDirectives(wealthLevel: string) {
    const types = ['power_of_attorney', 'healthcare_directive', 'living_will', 'hipaa_authorization', 'guardianship_designation'];
    const type = faker.helpers.arrayElement(types);
    const displayNames: Record<string, string> = {
      'power_of_attorney': 'Power of Attorney',
      'healthcare_directive': 'Healthcare Directive', 
      'living_will': 'Living Will',
      'hipaa_authorization': 'HIPAA Authorization',
      'guardianship_designation': 'Guardianship Designation'
    };
    
    return {
      name: `${displayNames[type]} - ${faker.person.lastName()} Family`,
      description: `${displayNames[type]} document for estate planning`,
      estimated_value: 0, // Legal documents have no monetary value
      category_specific_data: {
        directive_type: type,
        attorney: faker.person.fullName(),
        law_firm: `${faker.person.lastName()} & Associates`,
        execution_date: faker.date.past({ years: 5 }),
        state_jurisdiction: faker.location.state(),
        status: 'executed'
      }
    };
  }

  private generateTrust(wealthLevel: string) {
    const trustTypes = wealthLevel === 'high_net_worth' 
      ? ['revocable', 'irrevocable', 'charitable', 'generation_skipping', 'asset_protection']
      : ['revocable', 'living', 'special_needs'];
    
    const trustType = faker.helpers.arrayElement(trustTypes);
    const baseValue = wealthLevel === 'high_net_worth' 
      ? faker.number.int({ min: 500000, max: 50000000 })
      : faker.number.int({ min: 50000, max: 2000000 });

    return {
      name: `${faker.person.lastName()} Family ${trustType.replace('_', ' ')} Trust`,
      description: `${trustType.replace('_', ' ')} trust established for estate planning purposes`,
      estimated_value: baseValue,
      category_specific_data: {
        trust_type: trustType,
        trustee: faker.person.fullName(),
        successor_trustee: faker.person.fullName(),
        beneficiaries: Array.from({ length: faker.number.int({ min: 1, max: 4 }) }, () => faker.person.fullName()),
        establishment_date: faker.date.past({ years: 10 }),
        tax_id: faker.string.numeric(9),
        is_revocable: trustType === 'revocable' || trustType === 'living'
      }
    };
  }

  private generateWill(wealthLevel: string) {
    return {
      name: `Last Will and Testament - ${faker.person.fullName()}`,
      description: 'Legal document outlining distribution of assets upon death',
      estimated_value: 0,
      category_specific_data: {
        executor: faker.person.fullName(),
        alternate_executor: faker.person.fullName(),
        witnesses: [faker.person.fullName(), faker.person.fullName()],
        execution_date: faker.date.past({ years: 3 }),
        attorney: faker.person.fullName(),
        includes_trust: wealthLevel === 'high_net_worth' ? faker.datatype.boolean(0.8) : faker.datatype.boolean(0.2),
        status: 'executed'
      }
    };
  }

  private generatePersonalProperty(wealthLevel: string) {
    const items = wealthLevel === 'high_net_worth'
      ? [
          { type: 'art', minValue: 50000, maxValue: 5000000 },
          { type: 'jewelry', minValue: 25000, maxValue: 1000000 },
          { type: 'precious_metals', minValue: 10000, maxValue: 500000 },
          { type: 'collectibles', minValue: 15000, maxValue: 200000 },
          { type: 'furniture', minValue: 5000, maxValue: 100000 }
        ]
      : [
          { type: 'jewelry', minValue: 1000, maxValue: 25000 },
          { type: 'furniture', minValue: 2000, maxValue: 15000 },
          { type: 'collectibles', minValue: 100, maxValue: 5000 },
          { type: 'precious_metals', minValue: 500, maxValue: 10000 }
        ];

    const item = faker.helpers.arrayElement(items);
    const value = faker.number.int({ min: item.minValue, max: item.maxValue });

    return {
      name: `${item.type.replace('_', ' ')} - ${faker.commerce.productName()}`,
      description: faker.commerce.productDescription(),
      estimated_value: value,
      category_specific_data: {
        property_type: item.type,
        acquisition_date: faker.date.past({ years: 10 }),
        appraised_value: value,
        appraisal_date: faker.date.recent({ days: 365 }),
        storage_location: faker.location.city(),
        insurance_coverage: value * faker.number.float({ min: 0.8, max: 1.2 }),
        condition: faker.helpers.arrayElement(['excellent', 'very_good', 'good', 'fair'])
      }
    };
  }

  private generateOperationalProperty(wealthLevel: string) {
    const vehicles = wealthLevel === 'high_net_worth'
      ? [
          { type: 'vehicle', brands: ['BMW', 'Mercedes-Benz', 'Audi', 'Lexus'], minValue: 80000, maxValue: 300000 },
          { type: 'yacht', brands: ['Sunseeker', 'Azimut', 'Princess'], minValue: 500000, maxValue: 10000000 },
          { type: 'boat', brands: ['Sea Ray', 'Boston Whaler', 'Bayliner'], minValue: 100000, maxValue: 2000000 }
        ]
      : [
          { type: 'vehicle', brands: ['Toyota', 'Honda', 'Ford', 'Chevrolet', 'Nissan'], minValue: 15000, maxValue: 80000 },
          { type: 'boat', brands: ['Sea Ray', 'Boston Whaler', 'Bayliner'], minValue: 20000, maxValue: 150000 },
          { type: 'equipment', brands: ['Caterpillar', 'John Deere', 'Kubota'], minValue: 10000, maxValue: 100000 }
        ];

    const vehicle = faker.helpers.arrayElement(vehicles);
    const brand = faker.helpers.arrayElement(vehicle.brands);
    const value = faker.number.int({ min: vehicle.minValue, max: vehicle.maxValue });

    return {
      name: `${faker.date.recent({ days: 3650 }).getFullYear()} ${brand} ${faker.vehicle.model()}`,
      description: `${vehicle.type} - ${brand}`,
      estimated_value: value,
      category_specific_data: {
        property_type: vehicle.type,
        make: brand,
        model: faker.vehicle.model(),
        year: faker.date.recent({ days: 3650 }).getFullYear(),
        vin_or_serial: faker.vehicle.vin(),
        condition: faker.helpers.arrayElement(['operational', 'needs_repair', 'excellent']),
        purchase_date: faker.date.past({ years: 8 }),
        purchase_price: value * faker.number.float({ min: 1.0, max: 1.8 })
      }
    };
  }

  private generateInventory(wealthLevel: string) {
    const inventoryTypes = ['tool', 'appliance', 'fixture', 'supply', 'equipment', 'material'];
    const type = faker.helpers.arrayElement(inventoryTypes);
    const value = wealthLevel === 'high_net_worth'
      ? faker.number.int({ min: 100000, max: 5000000 })
      : faker.number.int({ min: 5000, max: 100000 });

    return {
      name: `${type.replace('_', ' ')} Inventory - ${faker.company.name()}`,
      description: `Business inventory of ${type}s`,
      estimated_value: value,
      category_specific_data: {
        inventory_type: type,
        quantity: faker.number.int({ min: 10, max: 1000 }),
        unit_cost: value / faker.number.int({ min: 10, max: 100 }),
        location: faker.location.city(),
        last_inventory_date: faker.date.recent({ days: 90 })
      }
    };
  }

  private generateRealEstate(wealthLevel: string) {
    const propertyTypes = wealthLevel === 'high_net_worth'
      ? ['primary_residence', 'secondary_residence', 'rental', 'commercial', 'vacant_land']
      : ['primary_residence', 'rental', 'vacant_land'];

    const propertyType = faker.helpers.arrayElement(propertyTypes);
    const baseValue = wealthLevel === 'high_net_worth'
      ? faker.number.int({ min: 500000, max: 20000000 })
      : faker.number.int({ min: 150000, max: 1500000 });

    return {
      name: `${propertyType.replace('_', ' ')} - ${faker.location.streetAddress()}`,
      description: `${propertyType.replace('_', ' ')} property`,
      estimated_value: baseValue,
      category_specific_data: {
        property_type: propertyType,
        address: {
          street: faker.location.streetAddress(),
          city: faker.location.city(),
          state: faker.location.state(),
          zip: faker.location.zipCode()
        },
        square_footage: faker.number.int({ min: 1000, max: 10000 }),
        lot_size: faker.number.float({ min: 0.1, max: 5.0 }),
        year_built: faker.number.int({ min: 1950, max: 2023 }),
        bedrooms: faker.number.int({ min: 2, max: 8 }),
        bathrooms: faker.number.int({ min: 1, max: 6 }),
        purchase_date: faker.date.past({ years: 15 }),
        mortgage_balance: baseValue * faker.number.float({ min: 0, max: 0.8 })
      }
    };
  }

  private generateLifeInsurance(wealthLevel: string) {
    const policyTypes = ['term', 'whole_life', 'universal', 'variable'];
    const policyType = faker.helpers.arrayElement(policyTypes);
    const faceValue = wealthLevel === 'high_net_worth'
      ? faker.number.int({ min: 1000000, max: 50000000 })
      : faker.number.int({ min: 100000, max: 2000000 });

    return {
      name: `${policyType.replace('_', ' ')} Life Insurance Policy`,
      description: `${policyType.replace('_', ' ')} life insurance policy`,
      estimated_value: policyType === 'term' ? 0 : faceValue * 0.3, // Cash value for permanent policies
      category_specific_data: {
        policy_type: policyType,
        face_value: faceValue,
        cash_value: policyType === 'term' ? 0 : faceValue * faker.number.float({ min: 0.1, max: 0.4 }),
        premium_amount: faceValue * faker.number.float({ min: 0.005, max: 0.03 }),
        beneficiaries: Array.from({ length: faker.number.int({ min: 1, max: 3 }) }, () => faker.person.fullName()),
        policy_number: faker.string.alphanumeric(10),
        insurance_company: faker.company.name() + ' Insurance',
        issue_date: faker.date.past({ years: 10 })
      }
    };
  }

  private generateFinancialAccount(wealthLevel: string) {
    const accountTypes = wealthLevel === 'high_net_worth'
      ? ['investment', 'bank', 'retirement', 'trust_account', 'private_wealth']
      : ['bank', 'investment', 'retirement', 'college_savings'];

    const accountType = faker.helpers.arrayElement(accountTypes);
    const balance = wealthLevel === 'high_net_worth'
      ? faker.number.int({ min: 100000, max: 25000000 })
      : faker.number.int({ min: 5000, max: 500000 });

    return {
      name: `${accountType.replace('_', ' ')} Account - ${faker.finance.accountName()}`,
      description: `${accountType.replace('_', ' ')} account`,
      estimated_value: balance,
      category_specific_data: {
        account_type: accountType,
        institution: faker.company.name() + ' Financial',
        account_number: faker.finance.accountNumber(),
        current_balance: balance,
        interest_rate: faker.number.float({ min: 0.01, max: 0.08 }),
        opened_date: faker.date.past({ years: 10 }),
        is_joint_account: faker.datatype.boolean(0.3)
      }
    };
  }

  private generateRecurringIncome(wealthLevel: string) {
    const incomeTypes = wealthLevel === 'high_net_worth'
      ? ['royalties', 'rental_income', 'dividend_income', 'trust_distributions', 'business_income']
      : ['rental_income', 'dividend_income', 'part_time_income'];

    const incomeType = faker.helpers.arrayElement(incomeTypes);
    const monthlyAmount = wealthLevel === 'high_net_worth'
      ? faker.number.int({ min: 5000, max: 100000 })
      : faker.number.int({ min: 500, max: 5000 });

    return {
      name: `${incomeType.replace('_', ' ')} - Monthly Income`,
      description: `Recurring ${incomeType.replace('_', ' ')}`,
      estimated_value: monthlyAmount * 12, // Annual value
      category_specific_data: {
        income_type: incomeType,
        monthly_amount: monthlyAmount,
        frequency: 'monthly',
        source: faker.company.name(),
        start_date: faker.date.past({ years: 5 }),
        is_guaranteed: faker.datatype.boolean(0.6)
      }
    };
  }

  private generateDigitalAssets(wealthLevel: string) {
    const assetTypes = ['cryptocurrency', 'domain_name', 'intellectual_property', 'nft', 'digital_media'];
    const assetType = faker.helpers.arrayElement(assetTypes);
    const value = wealthLevel === 'high_net_worth'
      ? faker.number.int({ min: 10000, max: 5000000 })
      : faker.number.int({ min: 100, max: 50000 });

    return {
      name: `${assetType.replace('_', ' ')} - ${faker.internet.domainName()}`,
      description: `Digital ${assetType.replace('_', ' ')} asset`,
      estimated_value: value,
      category_specific_data: {
        asset_type: assetType,
        platform: faker.company.name(),
        wallet_address: assetType === 'cryptocurrency' ? faker.finance.ethereumAddress() : undefined,
        registration_date: faker.date.past({ years: 3 }),
        renewal_date: faker.date.future({ years: 2 }),
        blockchain_network: assetType === 'cryptocurrency' || assetType === 'nft' ? 'ethereum' : undefined
      }
    };
  }

  private generateOwnershipInterests(wealthLevel: string) {
    const interestTypes = ['business', 'partnership', 'franchise', 'timeshare', 'mineral_rights'];
    const interestType = faker.helpers.arrayElement(interestTypes);
    const value = wealthLevel === 'high_net_worth'
      ? faker.number.int({ min: 500000, max: 50000000 })
      : faker.number.int({ min: 10000, max: 500000 });

    return {
      name: `${interestType.replace('_', ' ')} Interest - ${faker.company.name()}`,
      description: `Ownership interest in ${interestType.replace('_', ' ')}`,
      estimated_value: value,
      category_specific_data: {
        interest_type: interestType,
        entity_name: faker.company.name(),
        ownership_percentage: faker.number.float({ min: 5, max: 100 }),
        shares_owned: faker.number.int({ min: 100, max: 10000 }),
        formation_date: faker.date.past({ years: 10 }),
        tax_id: faker.string.numeric(9)
      }
    };
  }

  private generateLoans(wealthLevel: string) {
    const loanTypes = ['hei_loan', 'interfamily_loan', 'mortgage', 'business_loan', 'personal_loan'];
    const loanType = faker.helpers.arrayElement(loanTypes);
    const amount = wealthLevel === 'high_net_worth'
      ? faker.number.int({ min: 100000, max: 10000000 })
      : faker.number.int({ min: 10000, max: 500000 });

    return {
      name: `${loanType.replace('_', ' ')} - ${faker.finance.accountName()}`,
      description: `${loanType.replace('_', ' ')} obligation`,
      estimated_value: amount, // Positive value (outstanding loan amount), liability nature handled by category
      category_specific_data: {
        loan_type: loanType,
        original_amount: amount,
        current_balance: amount * faker.number.float({ min: 0.1, max: 1.0 }),
        interest_rate: faker.number.float({ min: 0.02, max: 0.15 }),
        lender: loanType === 'interfamily_loan' ? faker.person.fullName() : faker.company.name() + ' Bank',
        origination_date: faker.date.past({ years: 10 }),
        maturity_date: faker.date.future({ years: 15 }),
        monthly_payment: amount * faker.number.float({ min: 0.005, max: 0.02 })
      }
    };
  }

  private generateAssetCreationDate(): Date {
    return faker.date.recent({ days: 365 });
  }
}