// Load environment variables and run compiled backend
const fs = require('fs');
const { spawn } = require('child_process');
const path = require('path');

// Load .env.local file
const envFile = path.join(__dirname, '.env.local');
if (fs.existsSync(envFile)) {
  const envContent = fs.readFileSync(envFile, 'utf8');
  const lines = envContent.split('\n');
  
  lines.forEach(line => {
    line = line.trim();
    if (line && !line.startsWith('#') && line.includes('=')) {
      const [key, ...valueParts] = line.split('=');
      const value = valueParts.join('=');
      process.env[key] = value;
      console.log(`Set ${key}=${value}`);
    }
  });
}

// Run the compiled backend
const backendPath = path.join(__dirname, 'dist/apps/api/apps/api/src/main.js');
console.log(`\nStarting compiled backend: ${backendPath}`);

const child = spawn('node', [backendPath], {
  stdio: 'inherit',
  env: process.env
});

child.on('error', (error) => {
  console.error('Failed to start backend:', error);
});

child.on('exit', (code) => {
  console.log(`Backend exited with code ${code}`);
});