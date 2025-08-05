#!/usr/bin/env node

import { Command } from 'commander';
import chalk from 'chalk';
import ora from 'ora';
import { StoredProcTestDataGenerator } from './StoredProcTestDataGenerator';
import { DatabaseConfig } from './types';

const program = new Command();

// Default configuration
const defaultDbConfig: DatabaseConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'forward_inheritance',
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
    const spinner = ora('Initializing Forward test scenario generator...').start();
    
    try {
      const dbConfig: DatabaseConfig = {
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
      const generator = new StoredProcTestDataGenerator(dbConfig);

      spinner.text = 'Generating Forward test scenario...';
      console.log(chalk.blue('\n🚀 Forward Inheritance Platform Test Scenario'));
      console.log(chalk.cyan('   📋 Generating 10 FFCs with 3-5 members each'));
      console.log(chalk.cyan('   💰 Ensuring all 13 asset categories are covered multiple times'));
      console.log(chalk.cyan('   🔧 Using stored procedures from architecture.md\n'));

      const stats = await generator.generateForwardTestScenario();

      await generator.close();
      spinner.succeed('Forward test scenario completed!');

      // Display detailed results
      console.log(chalk.green('\n✅ Forward Test Scenario Summary:'));
      console.log(chalk.blue(`📊 Tenant: ${stats.tenants}`));
      console.log(chalk.blue(`👥 Personas: ${stats.personas}`));
      console.log(chalk.blue(`🏠 Forward Family Circles: ${stats.ffcs}`));
      console.log(chalk.blue(`💰 Assets: ${stats.assets}`));
      console.log(chalk.blue(`🔗 Asset Ownerships: ${stats.ownerships}`));
      console.log(chalk.blue(`🔐 Asset Permissions: ${stats.permissions}`));
      console.log(chalk.blue(`👨‍👩‍👧‍👦 FFC Memberships: ${stats.memberships}`));
      console.log(chalk.yellow(`⏱️  Execution Time: ${stats.executionTime}ms\n`));

      // Calculate insights
      const avgMembersPerFfc = Math.round(stats.personas / stats.ffcs);
      const avgAssetsPerFfc = Math.round(stats.assets / stats.ffcs);
      const estimatedTotalValue = stats.assets * 250000; // Conservative estimate

      console.log(chalk.green('📈 Scenario Statistics:'));
      console.log(chalk.cyan(`👨‍👩‍👧‍👦 Average Members per FFC: ${avgMembersPerFfc}`));
      console.log(chalk.cyan(`💼 Average Assets per FFC: ${avgAssetsPerFfc}`));
      console.log(chalk.cyan(`💵 Estimated Total Portfolio Value: $${estimatedTotalValue.toLocaleString()}`));
      console.log(chalk.cyan(`🎯 Asset Coverage: All 13 categories included multiple times`));

      console.log(chalk.green('\n🎯 Asset Categories Covered:'));
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
      categories.forEach(cat => console.log(chalk.blue(`   ${cat}`)));

      console.log(chalk.green('\n✨ Test Scenario Ready!'));
      console.log(chalk.yellow('The database now contains comprehensive test data for:'));
      console.log(chalk.yellow('• Forward Family Circle functionality'));
      console.log(chalk.yellow('• Asset management across all categories'));
      console.log(chalk.yellow('• Ownership and permission systems'));
      console.log(chalk.yellow('• Multi-generational family structures'));
      console.log(chalk.yellow('• Realistic wealth distribution patterns\n'));

    } catch (error) {
      spinner.fail('Forward test scenario generation failed!');
      console.error(chalk.red('❌ Error:'), error);
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
      console.log(chalk.yellow('⚠️  This will delete ALL Forward test scenario data!'));
      console.log(chalk.yellow('   Use --confirm flag to skip this prompt.'));
      return;
    }

    const spinner = ora('Cleaning Forward test scenario data...').start();
    
    try {
      const dbConfig: DatabaseConfig = {
        host: options.dbHost,
        port: options.dbPort,
        database: options.dbName,
        user: options.dbUser,
        password: options.dbPassword
      };

      const generator = new StoredProcTestDataGenerator(dbConfig);
      await generator.cleanTestData();
      await generator.close();
      
      spinner.succeed('Forward test scenario data cleaned successfully!');
      console.log(chalk.green('✅ All Forward test data has been removed from the database.'));

    } catch (error) {
      spinner.fail('Failed to clean Forward test scenario data!');
      console.error(chalk.red('❌ Error:'), error);
      process.exit(1);
    }
  });

program
  .command('info')
  .description('Display information about the Forward test scenario')
  .action(() => {
    console.log(chalk.blue('\n🏗️  Forward Inheritance Platform Test Scenario\n'));
    
    console.log(chalk.green('🎯 Scenario Overview:'));
    console.log(chalk.cyan('• Generates exactly 10 Forward Family Circles (FFCs)'));
    console.log(chalk.cyan('• Each FFC has 3-5 members (35-50 total personas)'));
    console.log(chalk.cyan('• Comprehensive coverage of all 13 asset categories'));
    console.log(chalk.cyan('• Realistic family structures and wealth distributions'));
    console.log(chalk.cyan('• Uses stored procedures from architecture.md'));
    
    console.log(chalk.green('\n🔧 Technical Features:'));
    console.log(chalk.cyan('• Database-first architecture with stored procedures'));
    console.log(chalk.cyan('• Proper multi-tenant data isolation'));
    console.log(chalk.cyan('• Asset-level ownership and permissions'));
    console.log(chalk.cyan('• Audit trails for all operations'));
    console.log(chalk.cyan('• Cultural diversity (85% English, 15% Spanish)'));
    
    console.log(chalk.green('\n💰 Asset Distribution:'));
    console.log(chalk.cyan('• Financial Accounts: Primary wealth storage'));
    console.log(chalk.cyan('• Real Estate: Residential and commercial properties'));
    console.log(chalk.cyan('• Business Interests: Ownership stakes and partnerships'));
    console.log(chalk.cyan('• Estate Planning: Trusts, wills, directives'));
    console.log(chalk.cyan('• Personal Assets: Art, jewelry, vehicles'));
    console.log(chalk.cyan('• Modern Assets: Cryptocurrency, digital assets'));
    
    console.log(chalk.green('\n📝 Usage Examples:'));
    console.log(chalk.blue('# Generate the complete Forward test scenario'));
    console.log('npm run build && node dist/forward-scenario.js generate\n');
    
    console.log(chalk.blue('# Clean test data'));
    console.log('npm run build && node dist/forward-scenario.js clean --confirm\n');
    
    console.log(chalk.blue('# Custom database connection'));
    console.log('npm run build && node dist/forward-scenario.js generate --db-host myhost --db-name mydb\n');
  });

// Error handling
program.parseAsync(process.argv).catch((error) => {
  console.error(chalk.red('❌ Unexpected error:'), error);
  process.exit(1);
});

// Display help if no command provided
if (!process.argv.slice(2).length) {
  program.outputHelp();
  console.log(chalk.yellow('\n💡 Run "info" command for detailed scenario information.'));
}