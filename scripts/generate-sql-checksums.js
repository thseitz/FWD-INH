#!/usr/bin/env node

/**
 * SQL Checksum Generator
 * 
 * Generates SHA-256 checksums for all SQL files and adds hash banners to generated type files.
 * This ensures runtime SQL matches codegen SQL as per pgTyped-Slonik architecture requirements.
 * 
 * Usage:
 *   node scripts/generate-sql-checksums.js
 *   npm run db:checksums
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Configuration
const CONFIG = {
  QUERIES_DIR: 'apps/api/src/app/database/queries',
  TYPES_DIR: 'apps/api/src/app/database/types',
  CHECKSUM_FILE: 'apps/api/src/app/database/sql-checksums.json'
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

function logSuccess(message) {
  log(`✅ ${message}`, colors.green);
}

function logError(message) {
  log(`❌ ${message}`, colors.red);
}

function logInfo(message) {
  log(`ℹ️ ${message}`, colors.blue);
}

// Generate SHA-256 hash for file content
function generateHash(content) {
  // Normalize whitespace to ensure consistent hashing
  const normalizedContent = content
    .replace(/\r\n/g, '\n')  // Convert CRLF to LF
    .replace(/\s+$/gm, '')   // Remove trailing whitespace
    .trim();                 // Remove leading/trailing whitespace
  
  return crypto.createHash('sha256').update(normalizedContent, 'utf8').digest('hex');
}

// Find all SQL files recursively
function findSqlFiles(dir) {
  let sqlFiles = [];
  const items = fs.readdirSync(dir);
  
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    
    if (stat.isDirectory()) {
      sqlFiles = sqlFiles.concat(findSqlFiles(fullPath));
    } else if (item.endsWith('.sql')) {
      sqlFiles.push(fullPath);
    }
  }
  
  return sqlFiles;
}

// Generate checksums for all SQL files
function generateChecksums() {
  const sqlFiles = findSqlFiles(CONFIG.QUERIES_DIR);
  const checksums = {};
  
  log(`${colors.bold}Generating checksums for ${sqlFiles.length} SQL files...${colors.reset}`);
  
  for (const filePath of sqlFiles) {
    try {
      const content = fs.readFileSync(filePath, 'utf8');
      const hash = generateHash(content);
      const relativePath = path.relative(process.cwd(), filePath);
      
      checksums[relativePath] = {
        hash,
        file: path.basename(filePath),
        lastModified: fs.statSync(filePath).mtime.toISOString(),
        size: content.length
      };
      
      logSuccess(`${path.basename(filePath)} -> ${hash.substring(0, 12)}...`);
    } catch (error) {
      logError(`Failed to process ${filePath}: ${error.message}`);
    }
  }
  
  return checksums;
}

// Add hash banner to type file
function addHashBannerToTypeFile(typeFilePath, sqlHash, sqlFile) {
  if (!fs.existsSync(typeFilePath)) {
    return false;
  }
  
  try {
    const content = fs.readFileSync(typeFilePath, 'utf8');
    
    // Check if hash banner already exists
    const hashBannerRegex = /\/\* HASH: [a-f0-9]+ \*\//;
    const newHashBanner = `/* HASH: ${sqlHash} */`;
    
    let updatedContent;
    if (hashBannerRegex.test(content)) {
      // Replace existing hash banner
      updatedContent = content.replace(hashBannerRegex, newHashBanner);
    } else {
      // Add new hash banner at the top
      const firstImportIndex = content.indexOf('import');
      if (firstImportIndex !== -1) {
        updatedContent = content.slice(0, firstImportIndex) + 
                        newHashBanner + '\n' + 
                        content.slice(firstImportIndex);
      } else {
        updatedContent = newHashBanner + '\n' + content;
      }
    }
    
    fs.writeFileSync(typeFilePath, updatedContent, 'utf8');
    return true;
  } catch (error) {
    logError(`Failed to update hash banner in ${typeFilePath}: ${error.message}`);
    return false;
  }
}

// Update all type files with hash banners
function updateTypeFilesWithHashes(checksums) {
  if (!fs.existsSync(CONFIG.TYPES_DIR)) {
    logError(`Types directory does not exist: ${CONFIG.TYPES_DIR}`);
    return { updated: 0, failed: 0 };
  }
  
  const typeFiles = fs.readdirSync(CONFIG.TYPES_DIR).filter(f => f.endsWith('.types.ts'));
  let updated = 0;
  let failed = 0;
  
  log(`${colors.bold}Updating ${typeFiles.length} type files with hash banners...${colors.reset}`);
  
  for (const typeFile of typeFiles) {
    const baseName = path.basename(typeFile, '.types.ts');
    
    // Find corresponding SQL file checksum
    let correspondingHash = null;
    let correspondingSqlFile = null;
    
    for (const [sqlPath, checksum] of Object.entries(checksums)) {
      const sqlBaseName = path.basename(sqlPath, '.sql');
      if (sqlBaseName.toLowerCase() === baseName.toLowerCase()) {
        correspondingHash = checksum.hash;
        correspondingSqlFile = sqlPath;
        break;
      }
    }
    
    if (!correspondingHash) {
      logError(`No corresponding SQL file found for ${typeFile}`);
      failed++;
      continue;
    }
    
    const typeFilePath = path.join(CONFIG.TYPES_DIR, typeFile);
    if (addHashBannerToTypeFile(typeFilePath, correspondingHash, correspondingSqlFile)) {
      logSuccess(`Updated ${typeFile} with hash ${correspondingHash.substring(0, 12)}...`);
      updated++;
    } else {
      failed++;
    }
  }
  
  return { updated, failed };
}

// Save checksums to file
function saveChecksums(checksums) {
  const checksumData = {
    generated: new Date().toISOString(),
    totalFiles: Object.keys(checksums).length,
    checksums
  };
  
  // Ensure directory exists
  const checksumDir = path.dirname(CONFIG.CHECKSUM_FILE);
  if (!fs.existsSync(checksumDir)) {
    fs.mkdirSync(checksumDir, { recursive: true });
  }
  
  fs.writeFileSync(CONFIG.CHECKSUM_FILE, JSON.stringify(checksumData, null, 2), 'utf8');
  logSuccess(`Saved checksums to ${CONFIG.CHECKSUM_FILE}`);
}

// Main execution
async function main() {
  log(colors.bold + colors.blue + '='.repeat(80) + colors.reset);
  log(colors.bold + colors.blue + '  SQL CHECKSUM GENERATION' + colors.reset);
  log(colors.bold + colors.blue + '='.repeat(80) + colors.reset);
  
  try {
    // Step 1: Generate checksums for all SQL files
    logInfo('Step 1: Generating SQL file checksums...');
    const checksums = generateChecksums();
    
    if (Object.keys(checksums).length === 0) {
      logError('No SQL files found to process');
      process.exit(1);
    }
    
    // Step 2: Update type files with hash banners
    logInfo('Step 2: Adding hash banners to type files...');
    const { updated, failed } = updateTypeFilesWithHashes(checksums);
    
    // Step 3: Save checksum manifest
    logInfo('Step 3: Saving checksum manifest...');
    saveChecksums(checksums);
    
    // Summary
    log(`\n${colors.bold}${colors.green}=`.repeat(80) + colors.reset);
    log(`${colors.bold}${colors.green}  CHECKSUM GENERATION COMPLETE${colors.reset}`);
    log(`${colors.bold}${colors.green}=`.repeat(80) + colors.reset);
    
    log(`${colors.bold}SUMMARY:${colors.reset}`);
    log(`✅ SQL files processed: ${colors.green}${Object.keys(checksums).length}${colors.reset}`);
    log(`✅ Type files updated: ${colors.green}${updated}${colors.reset}`);
    if (failed > 0) {
      log(`❌ Type files failed: ${colors.red}${failed}${colors.reset}`);
    }
    
    if (failed === 0) {
      log(`\n${colors.bold}${colors.green}🎉 All SQL files have checksums and type files have hash banners!${colors.reset}`);
    } else {
      process.exit(1);
    }
    
  } catch (error) {
    logError(`Unexpected error: ${error.message}`);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main().catch(error => {
    logError(`Fatal error: ${error.message}`);
    process.exit(1);
  });
}

module.exports = {
  generateHash,
  generateChecksums,
  addHashBannerToTypeFile,
  updateTypeFilesWithHashes,
  saveChecksums
};