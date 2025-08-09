#!/usr/bin/env node
"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const commander_1 = require("commander");
const chalk_1 = __importDefault(require("chalk"));
const ora_1 = __importDefault(require("ora"));
const StoredProcTestDataGenerator_1 = require("./StoredProcTestDataGenerator");
const dotenv = __importStar(require("dotenv"));
// Load environment variables from .env file
dotenv.config();
const program = new commander_1.Command();
// Default configuration
const defaultDbConfig = {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'fwd_db',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'password'
};
program
    .name('forward-scenario-generator')
    .description('Generate Forward Inheritance Platform test scenario: 10 FFCs with comprehensive asset coverage')
    .version('1.0.0');
program
    .command('generate')
    .description('Generate the Forward test scenario')
    .option('--db-host <host>', 'Database host', defaultDbConfig.host)
    .option('--db-port <port>', 'Database port', (value) => parseInt(value), defaultDbConfig.port)
    .option('--db-name <name>', 'Database name', defaultDbConfig.database)
    .option('--db-user <user>', 'Database user', defaultDbConfig.user)
    .option('--db-password <password>', 'Database password', defaultDbConfig.password)
    .action(async (options) => {
    const spinner = (0, ora_1.default)('Initializing Forward test scenario generator...').start();
    try {
        const dbConfig = {
            host: options.dbHost,
            port: options.dbPort,
            database: options.dbName,
            user: options.dbUser,
            password: options.dbPassword
        };
        // Debug: Log the actual config being used
        console.log('Debug - Database config:', {
            host: dbConfig.host,
            port: dbConfig.port,
            database: dbConfig.database,
            user: dbConfig.user,
            password: dbConfig.password ? '***HIDDEN***' : 'undefined'
        });
        spinner.text = 'Connecting to database...';
        const generator = new StoredProcTestDataGenerator_1.StoredProcTestDataGenerator(dbConfig);
        spinner.text = 'Generating Forward test scenario...';
        console.log(chalk_1.default.blue('\n🚀 Forward Inheritance Platform Test Scenario'));
        console.log(chalk_1.default.cyan('   📋 Generating 10 FFCs with 3-5 members each'));
        console.log(chalk_1.default.cyan('   💰 Ensuring all 13 asset categories are covered multiple times'));
        console.log(chalk_1.default.cyan('   🔧 Using stored procedures from architecture.md\n'));
        const stats = await generator.generateForwardTestScenario();
        await generator.close();
        spinner.succeed('Forward test scenario completed!');
        // Display detailed results
        console.log(chalk_1.default.green('\n✅ Forward Test Scenario Summary:'));
        console.log(chalk_1.default.blue(`📊 Tenant: ${stats.tenants}`));
        console.log(chalk_1.default.blue(`👥 Personas: ${stats.personas}`));
        console.log(chalk_1.default.blue(`🏠 Forward Family Circles: ${stats.ffcs}`));
        console.log(chalk_1.default.blue(`💰 Assets: ${stats.assets}`));
        console.log(chalk_1.default.blue(`🔗 Asset Ownerships: ${stats.ownerships}`));
        console.log(chalk_1.default.blue(`🔐 Asset Permissions: ${stats.permissions}`));
        console.log(chalk_1.default.blue(`👨‍👩‍👧‍👦 FFC Memberships: ${stats.memberships}`));
        console.log(chalk_1.default.yellow(`⏱️  Execution Time: ${stats.executionTime}ms\n`));
        // Calculate insights
        const avgMembersPerFfc = Math.round(stats.personas / stats.ffcs);
        const avgAssetsPerFfc = Math.round(stats.assets / stats.ffcs);
        const estimatedTotalValue = stats.assets * 250000; // Conservative estimate
        console.log(chalk_1.default.green('📈 Scenario Statistics:'));
        console.log(chalk_1.default.cyan(`👨‍👩‍👧‍👦 Average Members per FFC: ${avgMembersPerFfc}`));
        console.log(chalk_1.default.cyan(`💼 Average Assets per FFC: ${avgAssetsPerFfc}`));
        console.log(chalk_1.default.cyan(`💵 Estimated Total Portfolio Value: $${estimatedTotalValue.toLocaleString()}`));
        console.log(chalk_1.default.cyan(`🎯 Asset Coverage: All 13 categories included multiple times`));
        console.log(chalk_1.default.green('\n🎯 Asset Categories Covered:'));
        const categories = [
            '1. Personal Directives (POA, Healthcare, HIPAA)',
            '2. Trusts (Revocable, Irrevocable, Charitable)',
            '3. Wills (Last Will & Testament)',
            '4. Personal Property (Art, Jewelry, Collectibles)',
            '5. Operational Property (Vehicles, Boats, Equipment)',
            '6. Inventory (Business Assets, Materials)',
            '7. Real Estate (Primary, Secondary, Commercial)',
            '8. Life Insurance (Term, Whole, Universal)',
            '9. Financial Accounts (Bank, Investment, Retirement)',
            '10. Recurring Income (Royalties, Rental Income)',
            '11. Digital Assets (Crypto, Domains, NFTs)',
            '12. Ownership Interests (Business, Partnerships)',
            '13. Loans (HEI, Interfamily, Mortgages)'
        ];
        categories.forEach(cat => console.log(chalk_1.default.blue(`   ${cat}`)));
        console.log(chalk_1.default.green('\n✨ Test Scenario Ready!'));
        console.log(chalk_1.default.yellow('The database now contains comprehensive test data for:'));
        console.log(chalk_1.default.yellow('• Forward Family Circle functionality'));
        console.log(chalk_1.default.yellow('• Asset management across all categories'));
        console.log(chalk_1.default.yellow('• Ownership and permission systems'));
        console.log(chalk_1.default.yellow('• Multi-generational family structures'));
        console.log(chalk_1.default.yellow('• Realistic wealth distribution patterns\n'));
    }
    catch (error) {
        spinner.fail('Forward test scenario generation failed!');
        console.error(chalk_1.default.red('❌ Error:'), error);
        process.exit(1);
    }
});
program
    .command('clean')
    .description('Clean Forward test scenario data')
    .option('--db-host <host>', 'Database host', defaultDbConfig.host)
    .option('--db-port <port>', 'Database port', (value) => parseInt(value), defaultDbConfig.port)
    .option('--db-name <name>', 'Database name', defaultDbConfig.database)
    .option('--db-user <user>', 'Database user', defaultDbConfig.user)
    .option('--db-password <password>', 'Database password', defaultDbConfig.password)
    .option('--confirm', 'Skip confirmation prompt')
    .action(async (options) => {
    if (!options.confirm) {
        console.log(chalk_1.default.yellow('⚠️  This will delete ALL Forward test scenario data!'));
        console.log(chalk_1.default.yellow('   Use --confirm flag to skip this prompt.'));
        return;
    }
    const spinner = (0, ora_1.default)('Cleaning Forward test scenario data...').start();
    try {
        const dbConfig = {
            host: options.dbHost,
            port: options.dbPort,
            database: options.dbName,
            user: options.dbUser,
            password: options.dbPassword
        };
        const generator = new StoredProcTestDataGenerator_1.StoredProcTestDataGenerator(dbConfig);
        await generator.cleanTestData();
        await generator.close();
        spinner.succeed('Forward test scenario data cleaned successfully!');
        console.log(chalk_1.default.green('✅ All Forward test data has been removed from the database.'));
    }
    catch (error) {
        spinner.fail('Failed to clean Forward test scenario data!');
        console.error(chalk_1.default.red('❌ Error:'), error);
        process.exit(1);
    }
});
program
    .command('info')
    .description('Display information about the Forward test scenario')
    .action(() => {
    console.log(chalk_1.default.blue('\n🏗️  Forward Inheritance Platform Test Scenario\n'));
    console.log(chalk_1.default.green('🎯 Scenario Overview:'));
    console.log(chalk_1.default.cyan('• Generates exactly 10 Forward Family Circles (FFCs)'));
    console.log(chalk_1.default.cyan('• Each FFC has 3-5 members (35-50 total personas)'));
    console.log(chalk_1.default.cyan('• Comprehensive coverage of all 13 asset categories'));
    console.log(chalk_1.default.cyan('• Realistic family structures and wealth distributions'));
    console.log(chalk_1.default.cyan('• Uses stored procedures from architecture.md'));
    console.log(chalk_1.default.green('\n🔧 Technical Features:'));
    console.log(chalk_1.default.cyan('• Database-first architecture with stored procedures'));
    console.log(chalk_1.default.cyan('• Proper multi-tenant data isolation'));
    console.log(chalk_1.default.cyan('• Asset-level ownership and permissions'));
    console.log(chalk_1.default.cyan('• Audit trails for all operations'));
    console.log(chalk_1.default.cyan('• Cultural diversity (85% English, 15% Spanish)'));
    console.log(chalk_1.default.green('\n💰 Asset Distribution:'));
    console.log(chalk_1.default.cyan('• Financial Accounts: Primary wealth storage'));
    console.log(chalk_1.default.cyan('• Real Estate: Residential and commercial properties'));
    console.log(chalk_1.default.cyan('• Business Interests: Ownership stakes and partnerships'));
    console.log(chalk_1.default.cyan('• Estate Planning: Trusts, wills, directives'));
    console.log(chalk_1.default.cyan('• Personal Assets: Art, jewelry, vehicles'));
    console.log(chalk_1.default.cyan('• Modern Assets: Cryptocurrency, digital assets'));
    console.log(chalk_1.default.green('\n📝 Usage Examples:'));
    console.log(chalk_1.default.blue('# Generate the complete Forward test scenario'));
    console.log('npm run build && node dist/forward-scenario.js generate\n');
    console.log(chalk_1.default.blue('# Clean test data'));
    console.log('npm run build && node dist/forward-scenario.js clean --confirm\n');
    console.log(chalk_1.default.blue('# Custom database connection'));
    console.log('npm run build && node dist/forward-scenario.js generate --db-host myhost --db-name mydb\n');
});
// Error handling
program.parseAsync(process.argv).catch((error) => {
    console.error(chalk_1.default.red('❌ Unexpected error:'), error);
    process.exit(1);
});
// Display help if no command provided
if (!process.argv.slice(2).length) {
    program.outputHelp();
    console.log(chalk_1.default.yellow('\n💡 Run "info" command for detailed scenario information.'));
}
