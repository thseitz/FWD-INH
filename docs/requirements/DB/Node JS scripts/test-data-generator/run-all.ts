/**
 * Run All Tests
 * Executes the complete test suite in sequence:
 * 1. Populate database with test data
 * 2. Test stored procedures
 * 3. Test SQL files
 */

import chalk from 'chalk';
import { populateDatabase } from './1-populate-database';
import { testStoredProcedures } from './2-test-stored-procedures';
import { testSqlFiles } from './3-test-sql-files';

async function runAllTests() {
  console.log(chalk.blue.bold('\n🚀 Running Complete Test Suite'));
  console.log(chalk.gray('=' .repeat(50)));
  
  const results = {
    dataPopulation: false,
    storedProcedures: { passed: 0, total: 0 },
    sqlFiles: { passed: 0, total: 0 }
  };
  
  try {
    // Step 1: Populate Database
    console.log(chalk.yellow('\n📦 Step 1: Populating Database...'));
    await populateDatabase();
    results.dataPopulation = true;
    console.log(chalk.green('✓ Database populated successfully'));
    
    // Step 2: Test Stored Procedures
    console.log(chalk.yellow('\n🔧 Step 2: Testing Stored Procedures...'));
    const procResults = await testStoredProcedures();
    results.storedProcedures = procResults;
    console.log(chalk.green(`✓ Stored Procedures: ${procResults.passed}/${procResults.total} passed`));
    
    // Step 3: Test SQL Files
    console.log(chalk.yellow('\n📄 Step 3: Testing SQL Files...'));
    const sqlResults = await testSqlFiles();
    results.sqlFiles = sqlResults;
    console.log(chalk.green(`✓ SQL Files: ${sqlResults.passed}/${sqlResults.total} passed`));
    
    // Final Summary
    console.log(chalk.blue.bold('\n📊 Final Test Summary'));
    console.log(chalk.gray('=' .repeat(50)));
    console.log(chalk.green('✓ Data Population: Success'));
    console.log(chalk.green(`✓ Stored Procedures: ${results.storedProcedures.passed}/${results.storedProcedures.total} (${Math.round(results.storedProcedures.passed / results.storedProcedures.total * 100)}%)`));
    console.log(chalk.green(`✓ SQL Files: ${results.sqlFiles.passed}/${results.sqlFiles.total} (${Math.round(results.sqlFiles.passed / results.sqlFiles.total * 100)}%)`));
    
    const totalTests = results.storedProcedures.total + results.sqlFiles.total;
    const totalPassed = results.storedProcedures.passed + results.sqlFiles.passed;
    const overallPercentage = Math.round(totalPassed / totalTests * 100);
    
    console.log(chalk.gray('─' .repeat(50)));
    console.log(chalk.bold(`Overall: ${totalPassed}/${totalTests} tests passed (${overallPercentage}%)`));
    
    if (overallPercentage === 100) {
      console.log(chalk.green.bold('\n🎉 Perfect Score! All tests passed!'));
    } else if (overallPercentage >= 95) {
      console.log(chalk.green.bold('\n✨ Excellent! Nearly all tests passed!'));
    } else {
      console.log(chalk.yellow.bold('\n⚠️ Some tests failed. Review the output above for details.'));
    }
    
  } catch (error) {
    console.error(chalk.red('\n❌ Test suite failed:'), error);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  runAllTests()
    .then(() => process.exit(0))
    .catch(() => process.exit(1));
}

export { runAllTests };