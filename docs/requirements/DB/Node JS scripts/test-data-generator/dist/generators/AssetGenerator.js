"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AssetGenerator = void 0;
const faker_1 = require("@faker-js/faker");
class AssetGenerator {
    /**
     * Generate assets across all 13 categories for realistic wealth distribution
     */
    generateAssets(count, tenantId, ffcId, createdByPersonaId, scenario = 'mixed') {
        const assets = [];
        // Determine wealth level for this set of assets
        const wealthLevel = this.determineWealthLevel(scenario);
        // Generate assets with realistic distribution across categories
        const distribution = this.getAssetDistribution(wealthLevel);
        for (const [category, percentage] of Object.entries(distribution)) {
            const categoryCount = Math.floor(count * percentage);
            for (let i = 0; i < categoryCount; i++) {
                const asset = this.generateAssetByCategory(category, tenantId, ffcId, createdByPersonaId, wealthLevel);
                assets.push(asset);
            }
        }
        return assets;
    }
    determineWealthLevel(scenario) {
        if (scenario === 'mixed') {
            // 20% high net worth, 80% mass affluent (realistic distribution)
            return faker_1.faker.datatype.boolean(0.2) ? 'high_net_worth' : 'mass_affluent';
        }
        return scenario;
    }
    getAssetDistribution(wealthLevel) {
        if (wealthLevel === 'high_net_worth') {
            return {
                'financial_accounts': 0.25, // 25% - Diverse investment portfolio
                'real_estate': 0.20, // 20% - Multiple properties
                'ownership_interests': 0.15, // 15% - Business interests
                'trust': 0.10, // 10% - Estate planning trusts
                'personal_property': 0.08, // 8% - Art, jewelry, collectibles
                'life_insurance': 0.06, // 6% - High-value policies
                'loans': 0.05, // 5% - HEI, interfamily loans
                'operational_property': 0.04, // 4% - Luxury vehicles, boats
                'will': 0.03, // 3% - Complex estate documents
                'personal_directives': 0.02, // 2% - Legal directives
                'recurring_income': 0.01, // 1% - Royalties, patents
                'digital_assets': 0.005, // 0.5% - Crypto, domains
                'inventory': 0.005 // 0.5% - Business inventory
            };
        }
        else {
            return {
                'financial_accounts': 0.35, // 35% - Primary focus
                'real_estate': 0.25, // 25% - Home + maybe rental
                'life_insurance': 0.12, // 12% - Term/whole life
                'personal_property': 0.10, // 10% - Household items
                'operational_property': 0.08, // 8% - Cars, equipment
                'will': 0.04, // 4% - Basic estate planning
                'personal_directives': 0.03, // 3% - Healthcare directives
                'loans': 0.02, // 2% - Mortgages, loans
                'trust': 0.005, // 0.5% - Simple trusts
                'ownership_interests': 0.005, // 0.5% - Small business
                'recurring_income': 0.003, // 0.3% - Side income
                'digital_assets': 0.001, // 0.1% - Minimal crypto
                'inventory': 0.001 // 0.1% - Personal inventory
            };
        }
    }
    generateAssetByCategory(category, tenantId, ffcId, createdByPersonaId, wealthLevel) {
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
    generatePersonalDirectives(wealthLevel) {
        const types = ['POA', 'Healthcare Directive', 'Letter of Intent', 'HIPAA Authorization'];
        const type = faker_1.faker.helpers.arrayElement(types);
        return {
            name: `${type} - ${faker_1.faker.person.lastName()} Family`,
            description: `${type} document for estate planning`,
            estimated_value: 0, // Legal documents have no monetary value
            category_specific_data: {
                document_type: type,
                attorney: faker_1.faker.person.fullName(),
                law_firm: `${faker_1.faker.person.lastName()} & Associates`,
                execution_date: faker_1.faker.date.past({ years: 5 }),
                state_jurisdiction: faker_1.faker.location.state()
            }
        };
    }
    generateTrust(wealthLevel) {
        const trustTypes = wealthLevel === 'high_net_worth'
            ? ['Revocable Living Trust', 'Irrevocable Life Insurance Trust', 'Charitable Remainder Trust', 'Generation-Skipping Trust']
            : ['Revocable Living Trust', 'Special Needs Trust'];
        const trustType = faker_1.faker.helpers.arrayElement(trustTypes);
        const baseValue = wealthLevel === 'high_net_worth'
            ? faker_1.faker.number.int({ min: 500000, max: 50000000 })
            : faker_1.faker.number.int({ min: 50000, max: 2000000 });
        return {
            name: `${faker_1.faker.person.lastName()} Family ${trustType}`,
            description: `${trustType} established for estate planning purposes`,
            estimated_value: baseValue,
            category_specific_data: {
                trust_type: trustType,
                trustee: faker_1.faker.person.fullName(),
                successor_trustee: faker_1.faker.person.fullName(),
                beneficiaries: Array.from({ length: faker_1.faker.number.int({ min: 1, max: 4 }) }, () => faker_1.faker.person.fullName()),
                establishment_date: faker_1.faker.date.past({ years: 10 }),
                tax_id: faker_1.faker.string.numeric(9)
            }
        };
    }
    generateWill(wealthLevel) {
        return {
            name: `Last Will and Testament - ${faker_1.faker.person.fullName()}`,
            description: 'Legal document outlining distribution of assets upon death',
            estimated_value: 0,
            category_specific_data: {
                executor: faker_1.faker.person.fullName(),
                alternate_executor: faker_1.faker.person.fullName(),
                witnesses: [faker_1.faker.person.fullName(), faker_1.faker.person.fullName()],
                execution_date: faker_1.faker.date.past({ years: 3 }),
                attorney: faker_1.faker.person.fullName(),
                includes_trust: wealthLevel === 'high_net_worth' ? faker_1.faker.datatype.boolean(0.8) : faker_1.faker.datatype.boolean(0.2)
            }
        };
    }
    generatePersonalProperty(wealthLevel) {
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
        const item = faker_1.faker.helpers.arrayElement(items);
        const value = faker_1.faker.number.int({ min: item.minValue, max: item.maxValue });
        return {
            name: `${item.type} - ${faker_1.faker.commerce.productName()}`,
            description: faker_1.faker.commerce.productDescription(),
            estimated_value: value,
            category_specific_data: {
                item_type: item.type,
                acquisition_date: faker_1.faker.date.past({ years: 10 }),
                appraised_value: value,
                appraisal_date: faker_1.faker.date.recent({ days: 365 }),
                storage_location: faker_1.faker.location.city(),
                insurance_coverage: value * faker_1.faker.number.float({ min: 0.8, max: 1.2 }),
                condition: faker_1.faker.helpers.arrayElement(['Excellent', 'Very Good', 'Good', 'Fair'])
            }
        };
    }
    generateOperationalProperty(wealthLevel) {
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
        const vehicle = faker_1.faker.helpers.arrayElement(vehicles);
        const brand = faker_1.faker.helpers.arrayElement(vehicle.brands);
        const value = faker_1.faker.number.int({ min: vehicle.minValue, max: vehicle.maxValue });
        return {
            name: `${faker_1.faker.date.recent({ days: 3650 }).getFullYear()} ${brand} ${faker_1.faker.vehicle.model()}`,
            description: `${vehicle.type} - ${brand}`,
            estimated_value: value,
            category_specific_data: {
                vehicle_type: vehicle.type,
                make: brand,
                model: faker_1.faker.vehicle.model(),
                year: faker_1.faker.date.recent({ days: 3650 }).getFullYear(),
                vin: faker_1.faker.vehicle.vin(),
                mileage: faker_1.faker.number.int({ min: 0, max: 200000 }),
                purchase_date: faker_1.faker.date.past({ years: 8 }),
                purchase_price: value * faker_1.faker.number.float({ min: 1.0, max: 1.8 })
            }
        };
    }
    generateInventory(wealthLevel) {
        const inventoryTypes = [
            'Business Inventory',
            'Raw Materials',
            'Finished Goods',
            'Work in Progress',
            'Supplies and Equipment'
        ];
        const type = faker_1.faker.helpers.arrayElement(inventoryTypes);
        const value = wealthLevel === 'high_net_worth'
            ? faker_1.faker.number.int({ min: 100000, max: 5000000 })
            : faker_1.faker.number.int({ min: 5000, max: 100000 });
        return {
            name: `${type} - ${faker_1.faker.company.name()}`,
            description: `${type} for business operations`,
            estimated_value: value,
            category_specific_data: {
                inventory_type: type,
                business_name: faker_1.faker.company.name(),
                last_audit_date: faker_1.faker.date.recent({ days: 365 }),
                audit_firm: `${faker_1.faker.person.lastName()} Accounting`,
                location: faker_1.faker.location.streetAddress()
            }
        };
    }
    generateRealEstate(wealthLevel) {
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
        const property = faker_1.faker.helpers.arrayElement(propertyTypes);
        const value = faker_1.faker.number.int({ min: property.minValue, max: property.maxValue });
        const mortgageBalance = faker_1.faker.datatype.boolean(0.7)
            ? faker_1.faker.number.int({ min: 0, max: value * 0.8 })
            : 0;
        return {
            name: `${property.type} - ${faker_1.faker.location.streetAddress()}`,
            description: `${property.type} located in ${faker_1.faker.location.city()}, ${faker_1.faker.location.state()}`,
            estimated_value: value,
            category_specific_data: {
                property_type: property.type,
                address: faker_1.faker.location.streetAddress(),
                city: faker_1.faker.location.city(),
                state: faker_1.faker.location.state(),
                zip_code: faker_1.faker.location.zipCode(),
                square_footage: faker_1.faker.number.int({ min: 800, max: 8000 }),
                lot_size: faker_1.faker.number.float({ min: 0.1, max: 10, precision: 0.1 }),
                year_built: faker_1.faker.number.int({ min: 1950, max: 2023 }),
                purchase_date: faker_1.faker.date.past({ years: 15 }),
                purchase_price: value * faker_1.faker.number.float({ min: 0.5, max: 1.2 }),
                mortgage_balance: mortgageBalance,
                property_tax_annual: value * faker_1.faker.number.float({ min: 0.008, max: 0.025 }),
                rental_income_monthly: property.type === 'Investment Property' ? faker_1.faker.number.int({ min: 1000, max: 8000 }) : null
            }
        };
    }
    generateLifeInsurance(wealthLevel) {
        const policyTypes = wealthLevel === 'high_net_worth'
            ? ['Whole Life', 'Universal Life', 'Variable Life', 'Term Life']
            : ['Term Life', 'Whole Life', 'Universal Life'];
        const policyType = faker_1.faker.helpers.arrayElement(policyTypes);
        const faceValue = wealthLevel === 'high_net_worth'
            ? faker_1.faker.number.int({ min: 1000000, max: 25000000 })
            : faker_1.faker.number.int({ min: 100000, max: 2000000 });
        const cashValue = ['Whole Life', 'Universal Life', 'Variable Life'].includes(policyType)
            ? faker_1.faker.number.int({ min: 0, max: faceValue * 0.3 })
            : 0;
        return {
            name: `${policyType} Insurance Policy - ${faker_1.faker.company.name()}`,
            description: `${policyType} life insurance policy`,
            estimated_value: cashValue,
            category_specific_data: {
                policy_type: policyType,
                insurance_company: faker_1.faker.company.name(),
                policy_number: faker_1.faker.string.alphanumeric(12),
                face_value: faceValue,
                cash_value: cashValue,
                annual_premium: faceValue * faker_1.faker.number.float({ min: 0.01, max: 0.05 }),
                policy_start_date: faker_1.faker.date.past({ years: 20 }),
                beneficiaries: Array.from({ length: faker_1.faker.number.int({ min: 1, max: 3 }) }, () => ({
                    name: faker_1.faker.person.fullName(),
                    relationship: faker_1.faker.helpers.arrayElement(['Spouse', 'Child', 'Parent', 'Sibling']),
                    percentage: 100 / faker_1.faker.number.int({ min: 1, max: 3 })
                }))
            }
        };
    }
    generateFinancialAccount(wealthLevel) {
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
        const account = faker_1.faker.helpers.arrayElement(accountTypes);
        const multiplier = wealthLevel === 'high_net_worth' ? faker_1.faker.number.float({ min: 2, max: 10 }) : 1;
        const balance = faker_1.faker.number.int({
            min: account.minBalance,
            max: account.maxBalance * multiplier
        });
        return {
            name: `${account.type} - ${faker_1.faker.finance.accountName()}`,
            description: `${account.type} account at ${faker_1.faker.company.name()}`,
            estimated_value: balance,
            category_specific_data: {
                account_type: account.type,
                financial_institution: faker_1.faker.company.name(),
                account_number: faker_1.faker.string.numeric(10),
                routing_number: faker_1.faker.string.numeric(9),
                current_balance: balance,
                interest_rate: faker_1.faker.number.float({ min: 0.01, max: 0.08, precision: 0.001 }),
                opened_date: faker_1.faker.date.past({ years: 10 }),
                monthly_contribution: account.type.includes('401') || account.type.includes('IRA')
                    ? faker_1.faker.number.int({ min: 500, max: 5000 })
                    : null
            }
        };
    }
    generateRecurringIncome(wealthLevel) {
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
        const income = faker_1.faker.helpers.arrayElement(incomeTypes);
        const annualValue = faker_1.faker.number.int({ min: income.minValue, max: income.maxValue });
        return {
            name: `${income.type} - ${faker_1.faker.commerce.productName()}`,
            description: `Recurring income from ${income.type.toLowerCase()}`,
            estimated_value: annualValue,
            category_specific_data: {
                income_type: income.type,
                annual_amount: annualValue,
                payment_frequency: faker_1.faker.helpers.arrayElement(['Monthly', 'Quarterly', 'Semi-Annual', 'Annual']),
                source: faker_1.faker.company.name(),
                start_date: faker_1.faker.date.past({ years: 5 }),
                tax_status: faker_1.faker.helpers.arrayElement(['Taxable', 'Tax-Deferred', 'Tax-Free'])
            }
        };
    }
    generateDigitalAssets(wealthLevel) {
        const digitalTypes = [
            { type: 'Cryptocurrency', symbols: ['BTC', 'ETH', 'ADA', 'SOL', 'MATIC'] },
            { type: 'Domain Names', extensions: ['.com', '.io', '.ai', '.app'] },
            { type: 'NFTs', platforms: ['OpenSea', 'SuperRare', 'Foundation'] },
            { type: 'Intellectual Property', categories: ['Software', 'Patents', 'Trademarks'] }
        ];
        const asset = faker_1.faker.helpers.arrayElement(digitalTypes);
        let value;
        let specificData = {};
        switch (asset.type) {
            case 'Cryptocurrency':
                const symbol = faker_1.faker.helpers.arrayElement(asset.symbols || ['BTC', 'ETH']);
                const amount = faker_1.faker.number.float({ min: 0.1, max: 100, precision: 0.001 });
                value = amount * faker_1.faker.number.int({ min: 100, max: 50000 }); // Simulated crypto price
                specificData = {
                    cryptocurrency: symbol,
                    amount: amount,
                    wallet_address: faker_1.faker.string.alphanumeric(34),
                    exchange: faker_1.faker.helpers.arrayElement(['Coinbase', 'Binance', 'Kraken', 'Cold Storage'])
                };
                break;
            case 'Domain Names':
                const extension = faker_1.faker.helpers.arrayElement(asset.extensions || ['.com', '.net']);
                value = faker_1.faker.number.int({ min: 100, max: 100000 });
                specificData = {
                    domain_name: `${faker_1.faker.internet.domainWord()}${extension}`,
                    registrar: faker_1.faker.helpers.arrayElement(['GoDaddy', 'Namecheap', 'Google Domains']),
                    expiration_date: faker_1.faker.date.future({ years: 5 }),
                    annual_renewal_cost: faker_1.faker.number.int({ min: 10, max: 500 })
                };
                break;
            default:
                value = faker_1.faker.number.int({ min: 1000, max: 50000 });
        }
        return {
            name: `${asset.type} - ${faker_1.faker.commerce.productName()}`,
            description: `Digital asset: ${asset.type}`,
            estimated_value: value,
            category_specific_data: {
                digital_asset_type: asset.type,
                ...specificData,
                acquisition_date: faker_1.faker.date.past({ years: 3 })
            }
        };
    }
    generateOwnershipInterests(wealthLevel) {
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
        const business = faker_1.faker.helpers.arrayElement(businessTypes);
        const value = faker_1.faker.number.int({ min: business.minValue, max: business.maxValue });
        const ownershipPercentage = faker_1.faker.number.float({ min: 5, max: 100, precision: 0.1 });
        return {
            name: `${business.type} - ${faker_1.faker.company.name()}`,
            description: `${ownershipPercentage}% ownership in ${business.type.toLowerCase()}`,
            estimated_value: value,
            category_specific_data: {
                business_type: business.type,
                company_name: faker_1.faker.company.name(),
                ownership_percentage: ownershipPercentage,
                business_address: faker_1.faker.location.streetAddress(),
                industry: faker_1.faker.company.buzzPhrase(),
                valuation_date: faker_1.faker.date.recent({ days: 365 }),
                valuation_method: faker_1.faker.helpers.arrayElement(['Asset Approach', 'Income Approach', 'Market Approach']),
                annual_revenue: value * faker_1.faker.number.float({ min: 0.2, max: 3.0 }),
                investment_date: faker_1.faker.date.past({ years: 8 })
            }
        };
    }
    generateLoans(wealthLevel) {
        const loanTypes = [
            { type: 'HEI Loan', minAmount: 50000, maxAmount: 2000000 },
            { type: 'Interfamily Loan', minAmount: 10000, maxAmount: 500000 },
            { type: 'Business Loan', minAmount: 25000, maxAmount: 5000000 },
            { type: 'Investment Loan', minAmount: 100000, maxAmount: 10000000 },
            { type: 'Personal Loan', minAmount: 5000, maxAmount: 100000 }
        ];
        const loan = faker_1.faker.helpers.arrayElement(loanTypes);
        const multiplier = wealthLevel === 'high_net_worth' ? faker_1.faker.number.float({ min: 2, max: 5 }) : 1;
        const amount = faker_1.faker.number.int({
            min: loan.minAmount,
            max: loan.maxAmount * multiplier
        });
        return {
            name: `${loan.type} - ${faker_1.faker.finance.accountName()}`,
            description: `${loan.type} for financial planning`,
            estimated_value: amount, // Positive value for loans receivable, negative for loans payable
            category_specific_data: {
                loan_type: loan.type,
                principal_amount: amount,
                current_balance: amount * faker_1.faker.number.float({ min: 0.1, max: 1.0 }),
                interest_rate: faker_1.faker.number.float({ min: 0.02, max: 0.12, precision: 0.001 }),
                origination_date: faker_1.faker.date.past({ years: 5 }),
                maturity_date: faker_1.faker.date.future({ years: 10 }),
                lender: loan.type === 'HEI Loan' ? 'Home Equity Investment Company' : faker_1.faker.company.name(),
                payment_frequency: faker_1.faker.helpers.arrayElement(['Monthly', 'Quarterly', 'Interest Only', 'Balloon']),
                collateral: loan.type === 'HEI Loan' ? 'Primary Residence' : faker_1.faker.helpers.arrayElement(['Real Estate', 'Investment Portfolio', 'Business Assets', 'None'])
            }
        };
    }
    generateAssetCreationDate() {
        // Asset creation dates should be recent, with bias toward more recent dates
        return faker_1.faker.date.between({
            from: new Date(Date.now() - 365 * 24 * 60 * 60 * 1000), // 1 year ago
            to: new Date()
        });
    }
}
exports.AssetGenerator = AssetGenerator;
