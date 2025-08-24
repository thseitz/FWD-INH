import { useState, useEffect } from 'react';
import './app.css';

export function App() {
  const [message, setMessage] = useState<string>('');
  const [health, setHealth] = useState<{ status: string; timestamp: string } | null>(null);

  useEffect(() => {
    // Test API connection
    const testAPI = async () => {
      try {
        // Get API URL from environment
        const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:3001';
        
        // Test basic API endpoint
        const response = await fetch(`${apiUrl}/api`);
        const data = await response.json();
        setMessage(data.message);

        // Test health endpoint
        const healthResponse = await fetch(`${apiUrl}/api/health`);
        const healthData = await healthResponse.json();
        setHealth(healthData);
      } catch (error) {
        console.error('Failed to connect to API:', error);
        setMessage('Failed to connect to backend API');
      }
    };

    testAPI();
  }, []);

  return (
    <div className="app">
      <header className="app-header">
        <h1>Forward Inheritance Platform</h1>
        <p className="app-subtitle">Phase 0 - Local Development Setup</p>
      </header>

      <main className="app-main">
        <section className="status-section">
          <h2>System Status</h2>
          
          <div className="status-card">
            <h3>Backend API</h3>
            <p className={message ? 'status-success' : 'status-loading'}>
              {message || 'Connecting...'}
            </p>
          </div>

          {health && (
            <div className="status-card">
              <h3>Health Check</h3>
              <p className="status-success">Status: {health.status}</p>
              <p className="status-timestamp">Last checked: {new Date(health.timestamp).toLocaleString()}</p>
            </div>
          )}
        </section>

        <section className="info-section">
          <h2>Development Setup</h2>
          <ul>
            <li>✅ NX Monorepo Structure</li>
            <li>✅ PostgreSQL Database (pg17)</li>
            <li>✅ TypeScript Type Generation</li>
            <li>✅ Docker Container Setup</li>
            <li>✅ NestJS Backend API</li>
            <li>✅ React Frontend with Vite</li>
            <li>⏳ E2E Testing Setup</li>
            <li>⏳ Full Stack Integration</li>
          </ul>
        </section>
      </main>
    </div>
  );
}

export default App;