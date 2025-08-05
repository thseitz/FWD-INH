import { faker } from '@faker-js/faker';
import { TestAsset, AssetCategory } from '../types';

export class AssetGenerator {
  
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

  private determineWealthLevel(scenario: 'high_net_worth' | 'mass_affluent' | 'mixed'): 'high_net_worth' | 'mass_affluent' {
    if (scenario === 'mixed') {
      // 20% high net worth, 80% mass affluent (realistic distribution)
      return faker.datatype.boolean(0.2) ? 'high_net_worth' : 'mass_affluent';
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

  private generateAssetByCategory(
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

  // Asset Category Generators

  private generatePersonalDirectives(wealthLevel: string) {
    const types = ['POA', 'Healthcare Directive', 'Letter of Intent', 'HIPAA Authorization'];
    const type = faker.helpers.arrayElement(types);
    
    return {
      name: `${type} - ${faker.person.lastName()} Family`,
      description: `${type} document for estate planning`,
      estimated_value: 0, // Legal documents have no monetary value
      category_specific_data: {
        document_type: type,
        attorney: faker.person.fullName(),
        law_firm: `${faker.person.lastName()} & Associates`,
        execution_date: faker.date.past({ years: 5 }),
        state_jurisdiction: faker.location.state()
      }
    };
  }

  private generateTrust(wealthLevel: string) {
    const trustTypes = wealthLevel === 'high_net_worth' 
      ? ['Revocable Living Trust', 'Irrevocable Life Insurance Trust', 'Charitable Remainder Trust', 'Generation-Skipping Trust']
      : ['Revocable Living Trust', 'Special Needs Trust'];
    
    const trustType = faker.helpers.arrayElement(trustTypes);
    const baseValue = wealthLevel === 'high_net_worth' 
      ? faker.number.int({ min: 500000, max: 50000000 })
      : faker.number.int({ min: 50000, max: 2000000 });

    return {
      name: `${faker.person.lastName()} Family ${trustType}`,
      description: `${trustType} established for estate planning purposes`,
      estimated_value: baseValue,
      category_specific_data: {
        trust_type: trustType,
        trustee: faker.person.fullName(),
        successor_trustee: faker.person.fullName(),
        beneficiaries: Array.from({ length: faker.number.int({ min: 1, max: 4 }) }, () => faker.person.fullName()),
        establishment_date: faker.date.past({ years: 10 }),
        tax_id: faker.string.numeric(9)
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
        includes_trust: wealthLevel === 'high_net_worth' ? faker.datatype.boolean(0.8) : faker.datatype.boolean(0.2)
      }
    };
  }

  private generatePersonalProperty(wealthLevel: string) {
    const items = wealthLevel === 'high_net_worth'
      ? [
          { type: 'Fine Art', minValue: 50000, maxValue: 5000000 },
          { type: 'Jewelry', minValue: 25000, maxValue: 1000000 },
          { type: 'Wine Collection', minValue: 10000, maxValue: 500000 },
          { type: 'Antique Furniture', minValue: 15000, maxValue: 200000 },
          { type: 'Collectibles', minValue: 5000, maxValue: 100000 }
        ]
      : [
          { type: 'Jewelry', minValue: 1000, maxValue: 25000 },
          { type: 'Electronics', minValue: 500, maxValue: 10000 },
          { type: 'Furniture', minValue: 2000, maxValue: 15000 },
          { type: 'Collectibles', minValue: 100, maxValue: 5000 },
          { type: 'Musical Instruments', minValue: 500, maxValue: 10000 }
        ];

    const item = faker.helpers.arrayElement(items);
    const value = faker.number.int({ min: item.minValue, max: item.maxValue });

    return {
      name: `${item.type} - ${faker.commerce.productName()}`,
      description: faker.commerce.productDescription(),
      estimated_value: value,
      category_specific_data: {
        item_type: item.type,
        acquisition_date: faker.date.past({ years: 10 }),
        appraised_value: value,
        appraisal_date: faker.date.recent({ days: 365 }),
        storage_location: faker.location.city(),
        insurance_coverage: value * faker.number.float({ min: 0.8, max: 1.2 }),
        condition: faker.helpers.arrayElement(['Excellent', 'Very Good', 'Good', 'Fair'])
      }
    };
  }

  private generateOperationalProperty(wealthLevel: string) {
    const vehicles = wealthLevel === 'high_net_worth'
      ? [
          { type: 'Luxury Car', brands: ['BMW', 'Mercedes-Benz', 'Audi', 'Lexus'], minValue: 80000, maxValue: 300000 },
          { type: 'Yacht', brands: ['Sunseeker', 'Azimut', 'Princess'], minValue: 500000, maxValue: 10000000 },
          { type: 'Private Jet', brands: ['Gulfstream', 'Bombardier', 'Cessna'], minValue: 2000000, maxValue: 50000000 },
          { type: 'Classic Car', brands: ['Ferrari', 'Porsche', 'Aston Martin'], minValue: 100000, maxValue: 2000000 }
        ]
      : [
          { type: 'Car', brands: ['Toyota', 'Honda', 'Ford', 'Chevrolet', 'Nissan'], minValue: 15000, maxValue: 80000 },
          { type: 'Motorcycle', brands: ['Harley-Davidson', 'Honda', 'Yamaha'], minValue: 8000, maxValue: 40000 },
          { type: 'Boat', brands: ['Sea Ray', 'Boston Whaler', 'Bayliner'], minValue: 20000, maxValue: 150000 },
          { type: 'RV', brands: ['Winnebago', 'Thor', 'Forest River'], minValue: 50000, maxValue: 300000 }
        ];

    const vehicle = faker.helpers.arrayElement(vehicles);
    const brand = faker.helpers.arrayElement(vehicle.brands);
    const value = faker.number.int({ min: vehicle.minValue, max: vehicle.maxValue });

    return {
      name: `${faker.date.recent({ days: 3650 }).getFullYear()} ${brand} ${faker.vehicle.model()}`,
      description: `${vehicle.type} - ${brand}`,
      estimated_value: value,
      category_specific_data: {
        vehicle_type: vehicle.type,
        make: brand,
        model: faker.vehicle.model(),
        year: faker.date.recent({ days: 3650 }).getFullYear(),
        vin: faker.vehicle.vin(),
        mileage: faker.number.int({ min: 0, max: 200000 }),
        purchase_date: faker.date.past({ years: 8 }),
        purchase_price: value * faker.number.float({ min: 1.0, max: 1.8 })
      }
    };
  }

  private generateInventory(wealthLevel: string) {
    const inventoryTypes = [
      'Business Inventory',
      'Raw Materials',
      'Finished Goods',
      'Work in Progress',
      'Supplies and Equipment'
    ];

    const type = faker.helpers.arrayElement(inventoryTypes);
    const value = wealthLevel === 'high_net_worth'
      ? faker.number.int({ min: 100000, max: 5000000 })
      : faker.number.int({ min: 5000, max: 100000 });

    return {
      name: `${type} - ${faker.company.name()}`,
      description: `${type} for business operations`,
      estimated_value: value,
      category_specific_data: {
        inventory_type: type,
        business_name: faker.company.name(),
        last_audit_date: faker.date.recent({ days: 365 }),
        audit_firm: `${faker.person.lastName()} Accounting`,
        location: faker.location.streetAddress()
      }
    };
  }

  private generateRealEstate(wealthLevel: string) {
    const propertyTypes = wealthLevel === 'high_net_worth'
      ? [
          { type: 'Primary Residence', minValue: 800000, maxValue: 15000000 },
          { type: 'Vacation Home', minValue: 500000, maxValue: 8000000 },
          { type: 'Investment Property', minValue: 300000, maxValue: 5000000 },
          { type: 'Commercial Property', minValue: 1000000, maxValue: 50000000 },
          { type: 'Land', minValue: 100000, maxValue: 10000000 }
        ]
      : [
          { type: 'Primary Residence', minValue: 200000, maxValue: 800000 },
          { type: 'Investment Property', minValue: 150000, maxValue: 600000 },
          { type: 'Vacation Home', minValue: 100000, maxValue: 500000 },
          { type: 'Land', minValue: 25000, maxValue: 200000 }
        ];

    const property = faker.helpers.arrayElement(propertyTypes);
    const value = faker.number.int({ min: property.minValue, max: property.maxValue });
    const mortgageBalance = faker.datatype.boolean(0.7) 
      ? faker.number.int({ min: 0, max: value * 0.8 }) 
      : 0;

    return {
      name: `${property.type} - ${faker.location.streetAddress()}`,
      description: `${property.type} located in ${faker.location.city()}, ${faker.location.state()}`,
      estimated_value: value,
      category_specific_data: {
        property_type: property.type,
        address: faker.location.streetAddress(),
        city: faker.location.city(),
        state: faker.location.state(),
        zip_code: faker.location.zipCode(),
        square_footage: faker.number.int({ min: 800, max: 8000 }),
        lot_size: faker.number.float({ min: 0.1, max: 10, precision: 0.1 }),
        year_built: faker.number.int({ min: 1950, max: 2023 }),
        purchase_date: faker.date.past({ years: 15 }),
        purchase_price: value * faker.number.float({ min: 0.5, max: 1.2 }),
        mortgage_balance: mortgageBalance,
        property_tax_annual: value * faker.number.float({ min: 0.008, max: 0.025 }),
        rental_income_monthly: property.type === 'Investment Property' ? faker.number.int({ min: 1000, max: 8000 }) : null
      }
    };
  }

  private generateLifeInsurance(wealthLevel: string) {
    const policyTypes = wealthLevel === 'high_net_worth'
      ? ['Whole Life', 'Universal Life', 'Variable Life', 'Term Life']
      : ['Term Life', 'Whole Life', 'Universal Life'];

    const policyType = faker.helpers.arrayElement(policyTypes);
    const faceValue = wealthLevel === 'high_net_worth'
      ? faker.number.int({ min: 1000000, max: 25000000 })
      : faker.number.int({ min: 100000, max: 2000000 });

    const cashValue = ['Whole Life', 'Universal Life', 'Variable Life'].includes(policyType)
      ? faker.number.int({ min: 0, max: faceValue * 0.3 })
      : 0;

    return {
      name: `${policyType} Insurance Policy - ${faker.company.name()}`,
      description: `${policyType} life insurance policy`,
      estimated_value: cashValue,
      category_specific_data: {
        policy_type: policyType,
        insurance_company: faker.company.name(),
        policy_number: faker.string.alphanumeric(12),
        face_value: faceValue,
        cash_value: cashValue,
        annual_premium: faceValue * faker.number.float({ min: 0.01, max: 0.05 }),
        policy_start_date: faker.date.past({ years: 20 }),
        beneficiaries: Array.from({ length: faker.number.int({ min: 1, max: 3 }) }, () => ({
          name: faker.person.fullName(),
          relationship: faker.helpers.arrayElement(['Spouse', 'Child', 'Parent', 'Sibling']),
          percentage: 100 / faker.number.int({ min: 1, max: 3 })
        }))
      }
    };
  }

  private generateFinancialAccount(wealthLevel: string) {
    const accountTypes = [
      { type: 'Checking', minBalance: 5000, maxBalance: 100000 },
      { type: 'Savings', minBalance: 10000, maxBalance: 500000 },
      { type: 'Investment', minBalance: 25000, maxBalance: 10000000 },
      { type: '401(k)', minBalance: 50000, maxBalance: 2000000 },
      { type: 'IRA', minBalance: 25000, maxBalance: 1000000 },
      { type: 'Roth IRA', minBalance: 10000, maxBalance: 500000 },
      { type: 'Brokerage', minBalance: 100000, maxBalance: 50000000 },
      { type: '529 College Savings', minBalance: 5000, maxBalance: 300000 }
    ];

    const account = faker.helpers.arrayElement(accountTypes);
    const multiplier = wealthLevel === 'high_net_worth' ? faker.number.float({ min: 2, max: 10 }) : 1;
    const balance = faker.number.int({ 
      min: account.minBalance, 
      max: account.maxBalance * multiplier 
    });

    return {
      name: `${account.type} - ${faker.finance.accountName()}`,
      description: `${account.type} account at ${faker.company.name()}`,
      estimated_value: balance,
      category_specific_data: {
        account_type: account.type,
        financial_institution: faker.company.name(),
        account_number: faker.string.numeric(10),
        routing_number: faker.string.numeric(9),
        current_balance: balance,
        interest_rate: faker.number.float({ min: 0.01, max: 0.08, precision: 0.001 }),
        opened_date: faker.date.past({ years: 10 }),
        monthly_contribution: account.type.includes('401') || account.type.includes('IRA') 
          ? faker.number.int({ min: 500, max: 5000 }) 
          : null
      }
    };
  }

  private generateRecurringIncome(wealthLevel: string) {
    const incomeTypes = wealthLevel === 'high_net_worth'
      ? [
          { type: 'Royalties - Patents', minValue: 50000, maxValue: 2000000 },
          { type: 'Royalties - Music/Film', minValue: 25000, maxValue: 5000000 },
          { type: 'Rental Income', minValue: 100000, maxValue: 1000000 },
          { type: 'Dividend Income', minValue: 50000, maxValue: 3000000 },
          { type: 'Trust Distributions', minValue: 100000, maxValue: 5000000 }
        ]
      : [
          { type: 'Rental Income', minValue: 12000, maxValue: 60000 },
          { type: 'Dividend Income', minValue: 1000, maxValue: 25000 },
          { type: 'Side Business Income', minValue: 5000, maxValue: 50000 },
          { type: 'Freelance Income', minValue: 3000, maxValue: 30000 }
        ];

    const income = faker.helpers.arrayElement(incomeTypes);
    const annualValue = faker.number.int({ min: income.minValue, max: income.maxValue });

    return {
      name: `${income.type} - ${faker.commerce.productName()}`,
      description: `Recurring income from ${income.type.toLowerCase()}`,
      estimated_value: annualValue,
      category_specific_data: {
        income_type: income.type,
        annual_amount: annualValue,
        payment_frequency: faker.helpers.arrayElement(['Monthly', 'Quarterly', 'Semi-Annual', 'Annual']),
        source: faker.company.name(),
        start_date: faker.date.past({ years: 5 }),
        tax_status: faker.helpers.arrayElement(['Taxable', 'Tax-Deferred', 'Tax-Free'])
      }
    };
  }

  private generateDigitalAssets(wealthLevel: string) {
    const digitalTypes = [
      { type: 'Cryptocurrency', symbols: ['BTC', 'ETH', 'ADA', 'SOL', 'MATIC'] },
      { type: 'Domain Names', extensions: ['.com', '.io', '.ai', '.app'] },
      { type: 'NFTs', platforms: ['OpenSea', 'SuperRare', 'Foundation'] },
      { type: 'Intellectual Property', categories: ['Software', 'Patents', 'Trademarks'] }
    ];

    const asset = faker.helpers.arrayElement(digitalTypes);
    let value: number;
    let specificData: any = {};

    switch (asset.type) {
      case 'Cryptocurrency':
        const symbol = faker.helpers.arrayElement(asset.symbols || ['BTC', 'ETH']);
        const amount = faker.number.float({ min: 0.1, max: 100, precision: 0.001 });
        value = amount * faker.number.int({ min: 100, max: 50000 }); // Simulated crypto price
        specificData = {
          cryptocurrency: symbol,
          amount: amount,
          wallet_address: faker.string.alphanumeric(34),
          exchange: faker.helpers.arrayElement(['Coinbase', 'Binance', 'Kraken', 'Cold Storage'])
        };
        break;
      case 'Domain Names':
        const extension = faker.helpers.arrayElement(asset.extensions || ['.com', '.net']);
        value = faker.number.int({ min: 100, max: 100000 });
        specificData = {
          domain_name: `${faker.internet.domainWord()}${extension}`,
          registrar: faker.helpers.arrayElement(['GoDaddy', 'Namecheap', 'Google Domains']),
          expiration_date: faker.date.future({ years: 5 }),
          annual_renewal_cost: faker.number.int({ min: 10, max: 500 })
        };
        break;
      default:
        value = faker.number.int({ min: 1000, max: 50000 });
    }

    return {
      name: `${asset.type} - ${faker.commerce.productName()}`,
      description: `Digital asset: ${asset.type}`,
      estimated_value: value,
      category_specific_data: {
        digital_asset_type: asset.type,
        ...specificData,
        acquisition_date: faker.date.past({ years: 3 })
      }
    };
  }

  private generateOwnershipInterests(wealthLevel: string) {
    const businessTypes = wealthLevel === 'high_net_worth'
      ? [
          { type: 'Private Equity', minValue: 1000000, maxValue: 50000000 },
          { type: 'Hedge Fund', minValue: 500000, maxValue: 25000000 },
          { type: 'Real Estate Partnership', minValue: 250000, maxValue: 10000000 },
          { type: 'Operating Business', minValue: 500000, maxValue: 100000000 },
          { type: 'Franchise', minValue: 100000, maxValue: 5000000 }
        ]
      : [
          { type: 'Small Business', minValue: 25000, maxValue: 500000 },
          { type: 'Franchise', minValue: 50000, maxValue: 300000 },
          { type: 'Partnership', minValue: 10000, maxValue: 200000 },
          { type: 'LLC Interest', minValue: 15000, maxValue: 150000 }
        ];

    const business = faker.helpers.arrayElement(businessTypes);
    const value = faker.number.int({ min: business.minValue, max: business.maxValue });
    const ownershipPercentage = faker.number.float({ min: 5, max: 100, precision: 0.1 });

    return {
      name: `${business.type} - ${faker.company.name()}`,
      description: `${ownershipPercentage}% ownership in ${business.type.toLowerCase()}`,
      estimated_value: value,
      category_specific_data: {
        business_type: business.type,
        company_name: faker.company.name(),
        ownership_percentage: ownershipPercentage,
        business_address: faker.location.streetAddress(),
        industry: faker.company.buzzPhrase(),
        valuation_date: faker.date.recent({ days: 365 }),
        valuation_method: faker.helpers.arrayElement(['Asset Approach', 'Income Approach', 'Market Approach']),
        annual_revenue: value * faker.number.float({ min: 0.2, max: 3.0 }),
        investment_date: faker.date.past({ years: 8 })
      }
    };
  }

  private generateLoans(wealthLevel: string) {
    const loanTypes = [
      { type: 'HEI Loan', minAmount: 50000, maxAmount: 2000000 },
      { type: 'Interfamily Loan', minAmount: 10000, maxAmount: 500000 },
      { type: 'Business Loan', minAmount: 25000, maxAmount: 5000000 },
      { type: 'Investment Loan', minAmount: 100000, maxAmount: 10000000 },
      { type: 'Personal Loan', minAmount: 5000, maxAmount: 100000 }
    ];

    const loan = faker.helpers.arrayElement(loanTypes);
    const multiplier = wealthLevel === 'high_net_worth' ? faker.number.float({ min: 2, max: 5 }) : 1;
    const amount = faker.number.int({ 
      min: loan.minAmount, 
      max: loan.maxAmount * multiplier 
    });

    return {
      name: `${loan.type} - ${faker.finance.accountName()}`,
      description: `${loan.type} for financial planning`,
      estimated_value: amount, // Positive value for loans receivable, negative for loans payable
      category_specific_data: {
        loan_type: loan.type,
        principal_amount: amount,
        current_balance: amount * faker.number.float({ min: 0.1, max: 1.0 }),
        interest_rate: faker.number.float({ min: 0.02, max: 0.12, precision: 0.001 }),
        origination_date: faker.date.past({ years: 5 }),
        maturity_date: faker.date.future({ years: 10 }),
        lender: loan.type === 'HEI Loan' ? 'Home Equity Investment Company' : faker.company.name(),
        payment_frequency: faker.helpers.arrayElement(['Monthly', 'Quarterly', 'Interest Only', 'Balloon']),
        collateral: loan.type === 'HEI Loan' ? 'Primary Residence' : faker.helpers.arrayElement(['Real Estate', 'Investment Portfolio', 'Business Assets', 'None'])
      }
    };
  }

  private generateAssetCreationDate(): Date {
    // Asset creation dates should be recent, with bias toward more recent dates
    return faker.date.between({ 
      from: new Date(Date.now() - 365 * 24 * 60 * 60 * 1000), // 1 year ago
      to: new Date()
    });
  }
}