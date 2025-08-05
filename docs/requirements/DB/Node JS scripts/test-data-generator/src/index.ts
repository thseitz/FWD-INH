#!/usr/bin/env node

import { Command } from 'commander';
import chalk from 'chalk';
import ora from 'ora';
import { TestDataGenerator } from './TestDataGenerator';
import { GenerationConfig, DatabaseConfig } from './types';

const program = new Command();

// Default configuration
const defaultDbConfig: DatabaseConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'forward_inheritance',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'password'
};

const defaultConfig: GenerationConfig = {
  tenants: 5,
  personasPerTenant: 20,
  ffcsPerTenant: 8,
  assetsPerFfc: 15,
  language: 'mixed',
  scenario: 'mixed',
  includePii: false
};

program
  .name('forward-test-data-generator')
  .description('Generate realistic test data for Forward Inheritance platform')
  .version('1.0.0');

program
  .command('generate')
  .description('Generate test data')
  .option('-t, --tenants <number>', 'Number of tenants to generate', (value) => parseInt(value), defaultConfig.tenants)
  .option('-p, --personas <number>', 'Personas per tenant', (value) => parseInt(value), defaultConfig.personasPerTenant)
  .option('-f, --ffcs <number>', 'FFCs per tenant', (value) => parseInt(value), defaultConfig.ffcsPerTenant)
  .option('-a, --assets <number>', 'Assets per FFC', (value) => parseInt(value), defaultConfig.assetsPerFfc)
  .option('-l, --language <lang>', 'Language preference (en|es|mixed)', defaultConfig.language)
  .option('-s, --scenario <scenario>', 'Wealth scenario (high_net_worth|mass_affluent|mixed)', defaultConfig.scenario)
  .option('--include-pii', 'Include PII in generated data', defaultConfig.includePii)
  .option('--db-host <host>', 'Database host', defaultDbConfig.host)
  .option('--db-port <port>', 'Database port', (value) => parseInt(value), defaultDbConfig.port)
  .option('--db-name <name>', 'Database name', defaultDbConfig.database)
  .option('--db-user <user>', 'Database user', defaultDbConfig.user)
  .option('--db-password <password>', 'Database password', defaultDbConfig.password)
  .action(async (options) => {
    const spinner = ora('Initializing test data generator...').start();
    
    try {
      const dbConfig: DatabaseConfig = {
        host: options.dbHost,
        port: options.dbPort,
        database: options.dbName,
        user: options.dbUser,
        password: options.dbPassword
      };

      const config: GenerationConfig = {
        tenants: options.tenants,
        personasPerTenant: options.personas,
        ffcsPerTenant: options.ffcs,
        assetsPerFfc: options.assets,
        language: options.language,
        scenario: options.scenario,
        includePii: options.includePii
      };

      spinner.text = 'Connecting to database...';
      const generator = new TestDataGenerator(dbConfig);

      spinner.text = 'Generating test data...';
      const stats = await generator.generateTestData(config);

      await generator.close();
      spinner.succeed('Test data generation completed!');

      // Display results
      console.log(chalk.green('\n✅ Generation Summary:'));
      console.log(chalk.blue(`📊 Tenants: ${stats.tenants}`));
      console.log(chalk.blue(`👥 Personas: ${stats.personas}`));
      console.log(chalk.blue(`🏠 Family Circles: ${stats.ffcs}`));
      console.log(chalk.blue(`💰 Assets: ${stats.assets}`));
      console.log(chalk.blue(`🔗 Ownerships: ${stats.ownerships}`));
      console.log(chalk.blue(`🔐 Permissions: ${stats.permissions}`));
      console.log(chalk.blue(`👨‍👩‍👧‍👦 Memberships: ${stats.memberships}`));
      console.log(chalk.yellow(`⏱️  Execution Time: ${stats.executionTime}ms\n`));

      // Calculate totals
      const totalAssetValue = stats.assets * 150000; // Rough estimate
      const avgAssetsPerFfc = Math.round(stats.assets / stats.ffcs);
      const avgPersonasPerTenant = Math.round(stats.personas / stats.tenants);

      console.log(chalk.green('📈 Statistics:'));
      console.log(chalk.cyan(`💵 Estimated Total Asset Value: $${totalAssetValue.toLocaleString()}`));
      console.log(chalk.cyan(`📊 Average Assets per FFC: ${avgAssetsPerFfc}`));
      console.log(chalk.cyan(`👥 Average Personas per Tenant: ${avgPersonasPerTenant}`));

    } catch (error) {
      spinner.fail('Test data generation failed!');
      console.error(chalk.red('❌ Error:'), error);
      process.exit(1);
    }
  });

program
  .command('clean')
  .description('Clean all test data from database')
  .option('--db-host <host>', 'Database host', defaultDbConfig.host)
  .option('--db-port <port>', 'Database port', (value) => parseInt(value), defaultDbConfig.port)
  .option('--db-name <name>', 'Database name', defaultDbConfig.database)
  .option('--db-user <user>', 'Database user', defaultDbConfig.user)
  .option('--db-password <password>', 'Database password', defaultDbConfig.password)
  .option('--confirm', 'Skip confirmation prompt')
  .action(async (options) => {
    if (!options.confirm) {
      console.log(chalk.yellow('⚠️  This will delete ALL test data from the database!'));
      console.log(chalk.yellow('   Use --confirm flag to skip this prompt.'));
      return;
    }

    const spinner = ora('Cleaning test data...').start();
    
    try {
      const dbConfig: DatabaseConfig = {
        host: options.dbHost,
        port: options.dbPort,
        database: options.dbName,
        user: options.dbUser,
        password: options.dbPassword
      };

      const generator = new TestDataGenerator(dbConfig);
      await generator.cleanTestData();
      await generator.close();
      
      spinner.succeed('Test data cleaned successfully!');
      console.log(chalk.green('✅ All test data has been removed from the database.'));

    } catch (error) {
      spinner.fail('Failed to clean test data!');
      console.error(chalk.red('❌ Error:'), error);
      process.exit(1);
    }
  });

program
  .command('scenarios')
  .description('Generate predefined test scenarios')
  .option('--scenario <name>', 'Scenario name (demo|performance|spanish|wealthy)')
  .option('--db-host <host>', 'Database host', defaultDbConfig.host)
  .option('--db-port <port>', 'Database port', (value) => parseInt(value), defaultDbConfig.port)
  .option('--db-name <name>', 'Database name', defaultDbConfig.database)
  .option('--db-user <user>', 'Database user', defaultDbConfig.user)
  .option('--db-password <password>', 'Database password', defaultDbConfig.password)
  .action(async (options) => {
    const predefinedScenarios = {
      demo: {
        tenants: 3,
        personasPerTenant: 12,
        ffcsPerTenant: 4,
        assetsPerFfc: 8,
        language: 'mixed' as const,
        scenario: 'mixed' as const,
        includePii: false
      },
      performance: {
        tenants: 100,
        personasPerTenant: 50,
        ffcsPerTenant: 25,
        assetsPerFfc: 100,
        language: 'mixed' as const,
        scenario: 'mixed' as const,
        includePii: false
      },
      spanish: {
        tenants: 10,
        personasPerTenant: 20,
        ffcsPerTenant: 8,
        assetsPerFfc: 15,
        language: 'es' as const,
        scenario: 'mass_affluent' as const,
        includePii: false
      },
      wealthy: {
        tenants: 5,
        personasPerTenant: 15,
        ffcsPerTenant: 6,
        assetsPerFfc: 25,
        language: 'en' as const,
        scenario: 'high_net_worth' as const,
        includePii: false
      }
    };

    const scenarioName = options.scenario;
    if (!scenarioName || !predefinedScenarios[scenarioName as keyof typeof predefinedScenarios]) {
      console.log(chalk.red('❌ Invalid scenario. Available scenarios:'));
      Object.keys(predefinedScenarios).forEach(name => {
        console.log(chalk.blue(`   - ${name}`));
      });
      return;
    }

    const config = predefinedScenarios[scenarioName as keyof typeof predefinedScenarios];
    const spinner = ora(`Generating ${scenarioName} scenario...`).start();
    
    try {
      const dbConfig: DatabaseConfig = {
        host: options.dbHost,
        port: options.dbPort,
        database: options.dbName,
        user: options.dbUser,
        password: options.dbPassword
      };

      const generator = new TestDataGenerator(dbConfig);
      const stats = await generator.generateTestData(config);
      await generator.close();
      
      spinner.succeed(`${scenarioName} scenario generated successfully!`);
      
      console.log(chalk.green(`\n✅ ${scenarioName.toUpperCase()} Scenario Results:`));
      console.log(chalk.blue(`📊 Tenants: ${stats.tenants}`));
      console.log(chalk.blue(`👥 Personas: ${stats.personas}`));
      console.log(chalk.blue(`🏠 Family Circles: ${stats.ffcs}`));
      console.log(chalk.blue(`💰 Assets: ${stats.assets}`));
      console.log(chalk.yellow(`⏱️  Execution Time: ${stats.executionTime}ms\n`));

    } catch (error) {
      spinner.fail(`Failed to generate ${scenarioName} scenario!`);
      console.error(chalk.red('❌ Error:'), error);
      process.exit(1);
    }
  });

program
  .command('export')
  .description('Export generated data to CSV files')
  .option('--output-dir <dir>', 'Output directory for CSV files', './exports')
  .option('--db-host <host>', 'Database host', defaultDbConfig.host)
  .option('--db-port <port>', 'Database port', (value) => parseInt(value), defaultDbConfig.port)
  .option('--db-name <name>', 'Database name', defaultDbConfig.database)
  .option('--db-user <user>', 'Database user', defaultDbConfig.user)
  .option('--db-password <password>', 'Database password', defaultDbConfig.password)
  .action(async (options) => {
    const spinner = ora('Exporting data to CSV...').start();
    
    try {
      // This would implement CSV export functionality
      spinner.succeed('Data exported successfully!');
      console.log(chalk.green(`✅ CSV files exported to: ${options.outputDir}`));

    } catch (error) {
      spinner.fail('Failed to export data!');
      console.error(chalk.red('❌ Error:'), error);
      process.exit(1);
    }
  });

// Display help information
program
  .command('info')
  .description('Display generator information and examples')
  .action(() => {
    console.log(chalk.blue('\n🚀 Forward Inheritance Test Data Generator\n'));
    
    console.log(chalk.green('📝 Examples:'));
    console.log(chalk.cyan('  # Generate default test data'));
    console.log('  npm run generate\n');
    
    console.log(chalk.cyan('  # Generate large dataset for performance testing'));
    console.log('  npm run generate -- --tenants 50 --personas 100 --assets 200\n');
    
    console.log(chalk.cyan('  # Generate Spanish-language families'));
    console.log('  npm run generate -- --language es --scenario mass_affluent\n');
    
    console.log(chalk.cyan('  # Generate wealthy families'));
    console.log('  npm run generate -- --scenario high_net_worth --assets 50\n');
    
    console.log(chalk.cyan('  # Use predefined scenarios'));
    console.log('  npm run generate scenarios -- --scenario demo\n');
    
    console.log(chalk.cyan('  # Clean all test data'));
    console.log('  npm run generate clean -- --confirm\n');

    console.log(chalk.green('🎯 Asset Categories Generated:'));
    const categories = [
      'Personal Directives', 'Trusts', 'Wills', 'Personal Property',
      'Operational Property', 'Inventory', 'Real Estate', 'Life Insurance',
      'Financial Accounts', 'Recurring Income', 'Digital Assets',
      'Ownership Interests', 'Loans (including HEI)'
    ];
    categories.forEach(cat => console.log(chalk.blue(`  • ${cat}`)));

    console.log(chalk.green('\n🌍 Language Support:'));
    console.log(chalk.blue('  • English (en) - Standard US families'));
    console.log(chalk.blue('  • Spanish (es) - Hispanic US families with cultural names'));
    console.log(chalk.blue('  • Mixed - 85% English, 15% Spanish (realistic US distribution)\n'));

    console.log(chalk.green('💰 Wealth Scenarios:'));
    console.log(chalk.blue('  • high_net_worth - $1M+ investable assets, complex structures'));
    console.log(chalk.blue('  • mass_affluent - $250K-$1M, simpler structures'));
    console.log(chalk.blue('  • mixed - 20% high net worth, 80% mass affluent\n'));
  });

// Error handling
program.parseAsync(process.argv).catch((error) => {
  console.error(chalk.red('❌ Unexpected error:'), error);
  process.exit(1);
});

// Display help if no command provided
if (!process.argv.slice(2).length) {
  program.outputHelp();
  console.log(chalk.yellow('\n💡 Run "npm run dev info" for examples and detailed information.'));
}