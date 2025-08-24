/**
 * SQL Checksum Test Suite
 * 
 * Ensures runtime SQL matches codegen SQL by comparing checksums.
 * This is a critical security and correctness test per pgTyped-Slonik architecture.
 * 
 * Test validates:
 * 1. Every SQL file has a corresponding type file
 * 2. Every type file has a hash banner
 * 3. Hash in type file matches computed hash of SQL file
 * 4. No drift between runtime SQL and generated types
 */

import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';

describe('SQL Checksum Validation', () => {
  const QUERIES_DIR = path.resolve(__dirname, '../queries');
  const TYPES_DIR = path.resolve(__dirname, '../types');
  const CHECKSUM_FILE = path.resolve(__dirname, '../sql-checksums.json');

  // Generate SHA-256 hash for file content (same as generation script)
  function generateHash(content: string): string {
    const normalizedContent = content
      .replace(/\r\n/g, '\n')  // Convert CRLF to LF
      .replace(/\s+$/gm, '')   // Remove trailing whitespace
      .trim();                 // Remove leading/trailing whitespace
    
    return crypto.createHash('sha256').update(normalizedContent, 'utf8').digest('hex');
  }

  // Find all SQL files recursively
  function findSqlFiles(dir: string): string[] {
    let sqlFiles: string[] = [];
    
    if (!fs.existsSync(dir)) {
      return sqlFiles;
    }
    
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

  // Extract hash from type file banner
  function extractHashFromTypeFile(filePath: string): string | null {
    if (!fs.existsSync(filePath)) {
      return null;
    }
    
    const content = fs.readFileSync(filePath, 'utf8');
    const hashMatch = content.match(/\/\* HASH: ([a-f0-9]+) \*\//);
    
    return hashMatch ? hashMatch[1] : null;
  }

  // Get corresponding type file path for SQL file
  function getTypeFileForSql(sqlFilePath: string): string {
    const baseName = path.basename(sqlFilePath, '.sql');
    return path.join(TYPES_DIR, `${baseName}.types.ts`);
  }

  describe('Checksum Infrastructure', () => {
    test('SQL queries directory exists', () => {
      expect(fs.existsSync(QUERIES_DIR)).toBe(true);
    });

    test('Types directory exists', () => {
      expect(fs.existsSync(TYPES_DIR)).toBe(true);
    });

    test('Checksum manifest file exists', () => {
      expect(fs.existsSync(CHECKSUM_FILE)).toBe(true);
    });

    test('Checksum manifest is valid JSON', () => {
      const content = fs.readFileSync(CHECKSUM_FILE, 'utf8');
      expect(() => JSON.parse(content)).not.toThrow();
      
      const manifest = JSON.parse(content);
      expect(manifest).toHaveProperty('generated');
      expect(manifest).toHaveProperty('totalFiles');
      expect(manifest).toHaveProperty('checksums');
      expect(typeof manifest.checksums).toBe('object');
    });
  });

  describe('SQL File Coverage', () => {
    let sqlFiles: string[];
    
    beforeAll(() => {
      sqlFiles = findSqlFiles(QUERIES_DIR);
    });

    test('SQL files are found', () => {
      expect(sqlFiles.length).toBeGreaterThan(0);
    });

    test('Every SQL file has a corresponding type file', () => {
      const missingSqlFiles: string[] = [];
      
      for (const sqlFile of sqlFiles) {
        const typeFile = getTypeFileForSql(sqlFile);
        if (!fs.existsSync(typeFile)) {
          missingSqlFiles.push(path.basename(sqlFile));
        }
      }
      
      expect(missingSqlFiles).toHaveLength(0);
      if (missingSqlFiles.length > 0) {
        console.error('Missing type files for:', missingSqlFiles);
      }
    });
  });

  describe('Type File Hash Banners', () => {
    let sqlFiles: string[];
    
    beforeAll(() => {
      sqlFiles = findSqlFiles(QUERIES_DIR);
    });

    test('Every type file has a hash banner', () => {
      const missingHashes: string[] = [];
      
      for (const sqlFile of sqlFiles) {
        const typeFile = getTypeFileForSql(sqlFile);
        
        if (fs.existsSync(typeFile)) {
          const hash = extractHashFromTypeFile(typeFile);
          if (!hash) {
            missingHashes.push(path.basename(typeFile));
          }
        }
      }
      
      expect(missingHashes).toHaveLength(0);
      if (missingHashes.length > 0) {
        console.error('Type files missing hash banners:', missingHashes);
      }
    });

    test('All hash banners contain valid SHA-256 hashes', () => {
      const invalidHashes: Array<{file: string, hash: string}> = [];
      
      for (const sqlFile of sqlFiles) {
        const typeFile = getTypeFileForSql(sqlFile);
        
        if (fs.existsSync(typeFile)) {
          const hash = extractHashFromTypeFile(typeFile);
          if (hash && !/^[a-f0-9]{64}$/.test(hash)) {
            invalidHashes.push({ 
              file: path.basename(typeFile), 
              hash: hash 
            });
          }
        }
      }
      
      expect(invalidHashes).toHaveLength(0);
      if (invalidHashes.length > 0) {
        console.error('Invalid hash formats:', invalidHashes);
      }
    });
  });

  describe('Checksum Validation (Critical)', () => {
    let sqlFiles: string[];
    
    beforeAll(() => {
      sqlFiles = findSqlFiles(QUERIES_DIR);
    });

    test('Runtime SQL matches codegen SQL for all files', () => {
      const checksumMismatches: Array<{
        file: string;
        sqlHash: string;
        typeHash: string;
      }> = [];
      
      for (const sqlFile of sqlFiles) {
        const typeFile = getTypeFileForSql(sqlFile);
        
        if (!fs.existsSync(typeFile)) {
          continue; // Skip if no type file (caught by previous test)
        }
        
        // Compute current SQL file hash
        const sqlContent = fs.readFileSync(sqlFile, 'utf8');
        const sqlHash = generateHash(sqlContent);
        
        // Extract hash from type file
        const typeHash = extractHashFromTypeFile(typeFile);
        
        if (!typeHash) {
          continue; // Skip if no hash banner (caught by previous test)
        }
        
        // Compare hashes
        if (sqlHash !== typeHash) {
          checksumMismatches.push({
            file: path.basename(sqlFile),
            sqlHash: sqlHash,
            typeHash: typeHash
          });
        }
      }
      
      expect(checksumMismatches).toHaveLength(0);
      
      if (checksumMismatches.length > 0) {
        console.error('❌ CHECKSUM MISMATCHES DETECTED:');
        console.error('This means runtime SQL differs from generated types!');
        console.error('Run: npm run db:checksums to regenerate');
        console.error('');
        checksumMismatches.forEach(mismatch => {
          console.error(`File: ${mismatch.file}`);
          console.error(`  SQL Hash:  ${mismatch.sqlHash}`);
          console.error(`  Type Hash: ${mismatch.typeHash}`);
          console.error('');
        });
        
        throw new Error(
          `Checksum validation failed for ${checksumMismatches.length} files. ` +
          'Runtime SQL does not match generated types. ' +
          'Run "npm run db:checksums" to regenerate checksums.'
        );
      }
    });
  });

  describe('Checksum Manifest Validation', () => {
    test('Manifest checksums match current SQL files', () => {
      const manifest = JSON.parse(fs.readFileSync(CHECKSUM_FILE, 'utf8'));
      const manifestMismatches: Array<{
        file: string;
        currentHash: string;
        manifestHash: string;
      }> = [];
      
      const sqlFiles = findSqlFiles(QUERIES_DIR);
      
      for (const sqlFile of sqlFiles) {
        const relativePath = path.relative(process.cwd(), sqlFile);
        const manifestEntry = manifest.checksums[relativePath];
        
        if (!manifestEntry) {
          continue; // New file not in manifest yet
        }
        
        const currentContent = fs.readFileSync(sqlFile, 'utf8');
        const currentHash = generateHash(currentContent);
        
        if (currentHash !== manifestEntry.hash) {
          manifestMismatches.push({
            file: path.basename(sqlFile),
            currentHash: currentHash,
            manifestHash: manifestEntry.hash
          });
        }
      }
      
      expect(manifestMismatches).toHaveLength(0);
      
      if (manifestMismatches.length > 0) {
        console.error('❌ MANIFEST MISMATCHES DETECTED:');
        console.error('SQL files have changed since last checksum generation');
        console.error('Run: npm run db:checksums to update manifest');
        console.error('');
        manifestMismatches.forEach(mismatch => {
          console.error(`File: ${mismatch.file}`);
          console.error(`  Current:  ${mismatch.currentHash}`);
          console.error(`  Manifest: ${mismatch.manifestHash}`);
          console.error('');
        });
      }
    });
  });

  describe('Security Validation', () => {
    test('No SQL files contain potential injection vectors', () => {
      const suspiciousPatterns = [
        /\$\{\w+\}/g,           // Template literals: ${variable}
        /[^$]\+\s*['"`]/g,      // String concatenation: + "string"
        /['"`]\s*\+/g,          // String concatenation: "string" +
        /eval\s*\(/g,           // eval() calls
        /exec\s*\(/g            // exec() calls
      ];
      
      const suspiciousFiles: Array<{file: string, issues: string[]}> = [];
      const sqlFiles = findSqlFiles(QUERIES_DIR);
      
      for (const sqlFile of sqlFiles) {
        const content = fs.readFileSync(sqlFile, 'utf8');
        const issues: string[] = [];
        
        for (const pattern of suspiciousPatterns) {
          const matches = content.match(pattern);
          if (matches) {
            issues.push(`Pattern: ${pattern.source} (${matches.length} matches)`);
          }
        }
        
        if (issues.length > 0) {
          suspiciousFiles.push({
            file: path.basename(sqlFile),
            issues: issues
          });
        }
      }
      
      expect(suspiciousFiles).toHaveLength(0);
      
      if (suspiciousFiles.length > 0) {
        console.warn('⚠️  POTENTIAL SECURITY ISSUES:');
        suspiciousFiles.forEach(file => {
          console.warn(`File: ${file.file}`);
          file.issues.forEach(issue => console.warn(`  - ${issue}`));
        });
      }
    });
  });
});