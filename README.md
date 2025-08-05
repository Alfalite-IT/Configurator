# Alfalite Deployment Guide

This repository contains deployment scripts and configuration for the Alfalite Configurator ecosystem.

## 📋 Overview

The Alfalite ecosystem consists of three main components:
- **Alfalite Configurator** - Main Flutter application (web/mobile/desktop)
- **Alfalite Admin Panel** - Flutter web application for content management
- **Alfalite Server** - Dart backend API server

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Configurator  │    │   Admin Panel   │    │     Server      │
│   (Flutter)     │    │   (Flutter)     │    │    (Dart)       │
│                 │    │                 │    │                 │
│ - Web App       │    │ - Web App       │    │ - REST API      │
│ - Mobile App    │    │ - Content Mgmt  │    │ - Authentication│
│ - Desktop App   │    │ - Product Mgmt  │    │ - Database      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   PostgreSQL    │
                    │   Database      │
                    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (3.8.1 or higher)
- **PostgreSQL** (15 or higher)
- **Docker** (optional, for containerized deployment)
- **Git**

### Environment Setup

1. **Clone the repositories:**
   ```bash
   git clone https://github.com/your-org/alfalite-configurator.git
   git clone https://github.com/your-org/alfalite-admin-panel.git
   git clone https://github.com/your-org/alfalite-server.git
   git clone https://github.com/your-org/alfalite-deployment.git
   ```

2. **Set up environment variables:**
   ```bash
   # Copy example environment files
   cp alfalite-server/.env.example alfalite-server/.env
   
   # Edit the .env file with your configuration
   nano alfalite-server/.env
   ```

## 📁 Repository Structure

```
alfalite-deployment/
├── scripts/
│   ├── build.sh              # Flutter app build script
│   ├── db_setup.sh           # Database setup script
│   └── test_api.sh           # API testing script
├── docker/
│   ├── docker-compose.yml    # Main Docker Compose file
│   ├── docker-compose.prod.yml # Production Docker Compose
│   └── nginx/
│       └── nginx.conf        # Nginx configuration
├── config/
│   ├── .env.example          # Environment variables template
│   └── .env.development      # Development environment
└── README.md                 # This file
```

## 🔧 Configuration

### Environment Variables

#### Server Configuration (.env)
```bash
# Application Environment
ENVIRONMENT=production

# Security
JWT_SECRET_KEY=your_secure_jwt_secret_here

# CORS Configuration
ALLOWED_ORIGINS=https://app.yourdomain.com,https://admin.yourdomain.com

# Database Configuration
DB_HOST=your_db_host
DB_PORT=5432
DB_NAME=alfalite_db
DB_PUBLIC_USER=alfalite_public_user
DB_PUBLIC_PASSWORD=your_public_password
DB_ADMIN_USER=alfalite_admin_user
DB_ADMIN_PASSWORD=your_admin_password

# SMTP Configuration (Required for production)
SMTP_HOST=your_smtp_host
SMTP_PORT=587
SMTP_USERNAME=your_smtp_username
SMTP_PASSWORD=your_smtp_password
COMPANY_EMAIL=noreply@yourdomain.com

# Server Configuration
PORT=8080
```

#### Client Configuration (Build-time)
```bash
# Development
API_BASE_URL=http://localhost:8080
SERVER_BASE_URL=http://localhost:8080
ENVIRONMENT=development

# Production
API_BASE_URL=https://api.yourdomain.com
SERVER_BASE_URL=https://api.yourdomain.com
ENVIRONMENT=production
```

## 🛠️ Build Commands

### Using the Build Script

The `scripts/build.sh` script provides a convenient way to build all applications:

```bash
# Build both apps for development
./scripts/build.sh

# Build specific app for development
./scripts/build.sh -a configurator -e development -p web
./scripts/build.sh -a admin -e development -p web

# Build for production
./scripts/build.sh -a both -e production -p web

# Build for specific platform
./scripts/build.sh -a both -e production -p android
./scripts/build.sh -a both -e production -p ios
./scripts/build.sh -a both -e production -p windows
./scripts/build.sh -a both -e production -p macos
./scripts/build.sh -a both -e production -p linux
```

### Manual Build Commands

#### Main Configurator App
```bash
cd alfalite-configurator

# Development
flutter build web \
  --dart-define=API_BASE_URL=http://localhost:8080 \
  --dart-define=SERVER_BASE_URL=http://localhost:8080 \
  --dart-define=ENVIRONMENT=development

# Production
flutter build web \
  --dart-define=API_BASE_URL=https://api.yourdomain.com \
  --dart-define=SERVER_BASE_URL=https://api.yourdomain.com \
  --dart-define=ENVIRONMENT=production
```

#### Admin Panel
```bash
cd alfalite-admin-panel

# Development
flutter build web \
  --dart-define=API_BASE_URL=http://localhost:8080 \
  --dart-define=SERVER_BASE_URL=http://localhost:8080 \
  --dart-define=ENVIRONMENT=development

# Production
flutter build web \
  --dart-define=API_BASE_URL=https://api.yourdomain.com \
  --dart-define=SERVER_BASE_URL=https://api.yourdomain.com \
  --dart-define=ENVIRONMENT=production
```

## 🐳 Docker Deployment

### Development Environment

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Production Environment

```bash
# Start production services
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Stop production services
docker-compose -f docker-compose.prod.yml down
```

### Docker Compose Configuration

```yaml
version: '3.8'
services:
  database:
    image: postgres:15
    environment:
      POSTGRES_DB: alfalite_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  server:
    build:
      context: ../alfalite-server
      dockerfile: Dockerfile
    environment:
      - JWT_SECRET_KEY=${JWT_SECRET_KEY}
      - DB_HOST=database
      - DB_PORT=5432
      - ALLOWED_ORIGINS=${ALLOWED_ORIGINS}
      - ENVIRONMENT=${ENVIRONMENT}
    depends_on:
      - database
    ports:
      - "8080:8080"

  configurator:
    build:
      context: ../alfalite-configurator
      dockerfile: Dockerfile
      args:
        - API_BASE_URL=${API_BASE_URL}
        - SERVER_BASE_URL=${SERVER_BASE_URL}
    ports:
      - "3000:80"

  admin-panel:
    build:
      context: ../alfalite-admin-panel
      dockerfile: Dockerfile
      args:
        - API_BASE_URL=${API_BASE_URL}
        - SERVER_BASE_URL=${SERVER_BASE_URL}
    ports:
      - "3001:80"

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - server
      - configurator
      - admin-panel

volumes:
  postgres_data:
```

## 🗄️ Database Setup

### Initial Setup

```bash
# Run the database setup script
./scripts/db_setup.sh
```

This script will:
- Create the database and users
- Set up proper permissions
- Seed initial data
- Create admin user (username: `admin`, password: `T3sT2025!`)

### Database Schema

The database includes the following tables:
- `products` - Product catalog
- `users` - User authentication

## 🧪 Testing

### API Testing

```bash
# Test the API endpoints
./scripts/test_api.sh
```

This script tests:
- CORS configuration
- Authentication
- Data validation
- Security middleware

### Manual Testing

```bash
# Test server health
curl http://localhost:8080/health

# Test products endpoint
curl http://localhost:8080/products

# Test authentication
curl -X POST http://localhost:8080/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"T3sT2025!"}'
```

## 🌐 Deployment Environments

### Development
- **Configurator**: http://localhost:3000
- **Admin Panel**: http://localhost:3001
- **Server API**: http://localhost:8080
- **Database**: localhost:5432

### Staging
- **Configurator**: https://staging.alfalite.com
- **Admin Panel**: https://staging-admin.alfalite.com
- **Server API**: https://staging-api.alfalite.com

### Production
- **Configurator**: https://app.alfalite.com
- **Admin Panel**: https://admin.alfalite.com
- **Server API**: https://api.alfalite.com

## 🔒 Security Considerations

### Environment Variables
- Never commit `.env` files to version control
- Use secure secrets management in production
- Rotate JWT secrets regularly
- Use strong database passwords

### CORS Configuration
- Configure `ALLOWED_ORIGINS` for production domains
- Avoid using wildcards (`*`) in production
- Include both HTTP and HTTPS if needed

### SSL/TLS
- Use HTTPS in production
- Configure proper SSL certificates
- Enable HSTS headers
- Use secure cookie settings

## 📊 Monitoring

### Health Checks
```bash
# Server health
curl http://localhost:8080/health

# Database connectivity
docker-compose exec database pg_isready

# Application logs
docker-compose logs -f server
```

### Logging
- Server logs are available via Docker Compose
- Flutter apps log to browser console (web)
- Database logs are available in PostgreSQL

## 🚨 Troubleshooting

### Common Issues

#### Build Failures
```bash
# Clean and rebuild
flutter clean
flutter pub get
./scripts/build.sh
```

#### Database Connection Issues
```bash
# Check database status
docker-compose exec database pg_isready

# Restart database
docker-compose restart database
```

#### CORS Issues
```bash
# Check allowed origins in .env
cat alfalite-server/.env | grep ALLOWED_ORIGINS

# Test CORS
curl -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  -X OPTIONS http://localhost:8080/products
```

#### Port Conflicts
```bash
# Check what's using the ports
lsof -i :8080
lsof -i :3000
lsof -i :3001

# Kill processes if needed
kill -9 <PID>
```

## 📞 Support

For deployment issues:
1. Check the logs: `docker-compose logs -f`
2. Verify environment variables
3. Test individual components
4. Check network connectivity
5. Review security configuration

## 📝 Changelog

### Version 1.0.0
- Initial deployment setup
- Environment configuration for all components
- Docker Compose configuration
- Build scripts for multiple environments
- Database setup automation
- API testing suite

---

**Note**: This deployment guide assumes you have the necessary permissions and access to the required services. Always test in a staging environment before deploying to production.

