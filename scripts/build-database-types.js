#!/usr/bin/env node

/**
 * Database Type Generation and Verification Script
 * 
 * This script ensures that:
 * 1. All SQL files have pgTyped annotations
 * 2. TypeScript types are generated for every SQL file
 * 3. 1:1 mapping between SQL files and type files is maintained
 * 4. Generated types are valid and complete
 * 
 * Usage:
 *   node scripts/build-database-types.js
 *   npm run db:build-types
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const CONFIG = {
  QUERIES_DIR: 'apps/api/src/app/database/queries',
  TYPES_DIR: 'apps/api/src/app/database/types',
  PGTYPED_CONFIG: process.env.NODE_ENV === 'development' && process.env.DOCKER_ENV === 'true' ? 'pgtyped-docker.json' : 'pgtyped-batch.json'
};

// ANSI colors for output
const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  reset: '\x1b[0m',
  bold: '\x1b[1m'
};

function log(message, color = '') {
  console.log(color + message + colors.reset);
}

function logStep(step, description) {
  log(`\n${colors.bold}STEP ${step}: ${description.toUpperCase()}${colors.reset}`);
}

function logError(message) {
  log(`${colors.red}❌ ${message}${colors.reset}`);
}

function logSuccess(message) {
  log(`${colors.green}✅ ${message}${colors.reset}`);
}

function logWarning(message) {
  log(`${colors.yellow}⚠️ ${message}${colors.reset}`);
}

// Count SQL files recursively
function countSqlFiles(dir = CONFIG.QUERIES_DIR) {
  let count = 0;
  
  function countRecursive(currentDir) {
    const items = fs.readdirSync(currentDir);
    for (const item of items) {
      const fullPath = path.join(currentDir, item);
      if (fs.statSync(fullPath).isDirectory()) {
        countRecursive(fullPath);
      } else if (item.endsWith('.sql')) {
        count++;
      }
    }
  }
  
  countRecursive(dir);
  return count;
}

// Check annotation coverage
function checkAnnotations(dir = CONFIG.QUERIES_DIR) {
  let annotatedCount = 0;
  let unannotatedFiles = [];
  
  function checkRecursive(currentDir) {
    const items = fs.readdirSync(currentDir);
    for (const item of items) {
      const fullPath = path.join(currentDir, item);
      if (fs.statSync(fullPath).isDirectory()) {
        checkRecursive(fullPath);
      } else if (item.endsWith('.sql')) {
        const content = fs.readFileSync(fullPath, 'utf8');
        if (content.includes('/* @name')) {
          annotatedCount++;
        } else {
          unannotatedFiles.push(fullPath);
        }
      }
    }
  }
  
  checkRecursive(dir);
  return { annotatedCount, unannotatedFiles };
}

// Generate types using pgTyped
function generateTypes() {
  try {
    execSync(`npx pgtyped -c ${CONFIG.PGTYPED_CONFIG}`, { 
      encoding: 'utf8',
      stdio: 'pipe'
    });
    return true;
  } catch (error) {
    logError(`pgTyped generation failed: ${error.message}`);
    if (error.stdout) console.log(error.stdout);
    if (error.stderr) console.log(error.stderr);
    return false;
  }
}

// Count generated type files
function countTypeFiles() {
  if (!fs.existsSync(CONFIG.TYPES_DIR)) {
    return 0;
  }
  
  return fs.readdirSync(CONFIG.TYPES_DIR)
    .filter(f => f.endsWith('.types.ts'))
    .length;
}

// Validate type file contents
function validateTypeFiles() {
  if (!fs.existsSync(CONFIG.TYPES_DIR)) {
    return { errors: ['Types directory does not exist'], count: 0 };
  }

  const typeFiles = fs.readdirSync(CONFIG.TYPES_DIR).filter(f => f.endsWith('.types.ts'));
  const errors = [];
  
  for (const file of typeFiles) {
    const filePath = path.join(CONFIG.TYPES_DIR, file);
    const content = fs.readFileSync(filePath, 'utf8');
    
    if (!content.includes("import { PreparedQuery } from '@pgtyped/runtime'")) {
      errors.push(`Missing pgtyped import in ${file}`);
    }
    
    if (!content.includes('export interface') && !content.includes('export type')) {
      errors.push(`Missing type definitions in ${file}`);
    }
    
    if (!content.includes('PreparedQuery')) {
      errors.push(`Missing PreparedQuery export in ${file}`);
    }
  }
  
  return { errors, count: typeFiles.length };
}

// Find mismatched files
function findMismatchedFiles() {
  const sqlFiles = new Set();
  const typeFiles = new Set();
  
  function collectSqlNames(dir) {
    const items = fs.readdirSync(dir);
    for (const item of items) {
      const fullPath = path.join(dir, item);
      if (fs.statSync(fullPath).isDirectory()) {
        collectSqlNames(fullPath);
      } else if (item.endsWith('.sql')) {
        sqlFiles.add(path.basename(item, '.sql'));
      }
    }
  }
  
  collectSqlNames(CONFIG.QUERIES_DIR);
  
  if (fs.existsSync(CONFIG.TYPES_DIR)) {
    fs.readdirSync(CONFIG.TYPES_DIR)
      .filter(f => f.endsWith('.types.ts'))
      .forEach(f => typeFiles.add(path.basename(f, '.types.ts')));
  }
  
  const missingTypes = [...sqlFiles].filter(x => !typeFiles.has(x));
  const extraTypes = [...typeFiles].filter(x => !sqlFiles.has(x));
  
  return { missingTypes, extraTypes };
}

// Main execution
async function main() {
  log(colors.bold + colors.blue + '='.repeat(80) + colors.reset);
  log(colors.bold + colors.blue + '  DATABASE TYPE GENERATION & VERIFICATION' + colors.reset);
  log(colors.bold + colors.blue + '='.repeat(80) + colors.reset);
  
  let hasErrors = false;
  
  // Step 1: Count SQL files
  logStep(1, 'SQL File Discovery');
  const totalSqlFiles = countSqlFiles();
  log(`Found ${colors.green}${totalSqlFiles}${colors.reset} SQL files`);
  
  // Step 2: Check annotations
  logStep(2, 'pgTyped Annotation Verification');
  const { annotatedCount, unannotatedFiles } = checkAnnotations();
  
  if (unannotatedFiles.length > 0) {
    logError(`${unannotatedFiles.length} files missing annotations:`);
    unannotatedFiles.forEach(file => log(`  - ${file}`));
    hasErrors = true;
  } else {
    logSuccess(`All ${annotatedCount} SQL files properly annotated`);
  }
  
  // Step 3: Clean and generate types
  logStep(3, 'TypeScript Type Generation');
  
  if (fs.existsSync(CONFIG.TYPES_DIR)) {
    const existingTypes = fs.readdirSync(CONFIG.TYPES_DIR).filter(f => f.endsWith('.types.ts'));
    if (existingTypes.length > 0) {
      log(`Cleaning ${existingTypes.length} existing type files...`);
      existingTypes.forEach(f => fs.unlinkSync(path.join(CONFIG.TYPES_DIR, f)));
    }
  }
  
  log('Generating TypeScript types...');
  if (!generateTypes()) {
    hasErrors = true;
  } else {
    logSuccess('Type generation completed');
  }
  
  // Step 4: Count generated types
  logStep(4, 'Type File Verification');
  const generatedTypes = countTypeFiles();
  log(`Generated ${colors.green}${generatedTypes}${colors.reset} type files`);
  
  // Step 5: Verify 1:1 mapping
  logStep(5, '1:1 Mapping Verification');
  log(`SQL files: ${totalSqlFiles}`);
  log(`Annotations: ${annotatedCount}`);
  log(`Generated types: ${generatedTypes}`);
  
  const perfectMapping = (totalSqlFiles === annotatedCount && annotatedCount === generatedTypes);
  
  if (!perfectMapping) {
    logError('Mapping verification failed');
    hasErrors = true;
    
    const { missingTypes, extraTypes } = findMismatchedFiles();
    
    if (missingTypes.length > 0) {
      logError(`Missing type files (${missingTypes.length}):`);
      missingTypes.forEach(f => log(`  - ${f}.types.ts`));
    }
    
    if (extraTypes.length > 0) {
      logWarning(`Extra type files (${extraTypes.length}):`);
      extraTypes.forEach(f => log(`  - ${f}.types.ts`));
    }
  } else {
    logSuccess('Perfect 1:1 mapping verified');
  }
  
  // Step 6: Validate type content
  logStep(6, 'Type Content Validation');
  const { errors: validationErrors, count: validatedCount } = validateTypeFiles();
  
  if (validationErrors.length > 0) {
    logError(`Type validation failed (${validationErrors.length} errors):`);
    validationErrors.forEach(error => log(`  - ${error}`));
    hasErrors = true;
  } else {
    logSuccess(`All ${validatedCount} type files validated`);
  }
  
  // Final summary
  log(`\n${colors.bold}${hasErrors ? colors.red : colors.green}` + '='.repeat(80) + colors.reset);
  log(`${colors.bold}${hasErrors ? colors.red : colors.green}  ${hasErrors ? 'BUILD FAILED' : 'BUILD SUCCESSFUL'}${colors.reset}`);
  log(`${colors.bold}${hasErrors ? colors.red : colors.green}` + '='.repeat(80) + colors.reset);
  
  if (!hasErrors) {
    log(`${colors.bold}VERIFICATION SUMMARY:${colors.reset}`);
    log(`✅ SQL Files: ${colors.green}${totalSqlFiles}${colors.reset}`);
    log(`✅ Annotations: ${colors.green}${annotatedCount}${colors.reset}`);
    log(`✅ Type Files: ${colors.green}${generatedTypes}${colors.reset}`);
    log(`✅ 1:1 Mapping: ${colors.green}VERIFIED${colors.reset}`);
    log(`✅ Content: ${colors.green}VALIDATED${colors.reset}`);
    log(`\n${colors.bold}${colors.green}🎉 Ready for NestJS + Slonik integration!${colors.reset}`);
  }
  
  process.exit(hasErrors ? 1 : 0);
}

// Run if called directly
if (require.main === module) {
  main().catch(error => {
    logError(`Unexpected error: ${error.message}`);
    process.exit(1);
  });
}

module.exports = {
  main,
  countSqlFiles,
  checkAnnotations,
  generateTypes,
  countTypeFiles,
  validateTypeFiles,
  findMismatchedFiles
};