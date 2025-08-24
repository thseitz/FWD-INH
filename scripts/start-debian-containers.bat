@echo off
echo Starting Forward Inheritance Platform - Phase 0
echo.
echo 🐧 DEBIAN CONTAINER ARCHITECTURE:
echo 1. 🗄️  Database: PostgreSQL 17 (Debian bullseye)
echo 2. 🔙 Backend: NestJS API (Node 20 bullseye)  
echo 3. 🎨 Frontend: React + Vite (Node 20 bullseye)
echo 4. 📦 Cache: Redis 7 (bullseye)
echo.

REM Change to project directory
cd /d "C:\Users\bob\github-thseitz\fwd-inh"

echo Building all containers...
docker-compose build

echo.
echo Starting all services...
docker-compose up -d

echo.
echo ✅ Container Status:
docker-compose ps

echo.
echo 🌐 Access Points:
echo   Frontend: http://localhost:4200
echo   Backend API: http://localhost:3001/api
echo   Database: localhost:5432 (fwd_db)
echo   Redis: localhost:6379
echo.
echo 📊 To view logs:
echo   docker-compose logs -f [service-name]
echo.
echo 🛑 To stop all services:
echo   docker-compose down
echo.
pause