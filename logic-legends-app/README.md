# Logic Legends Demo App

A simple Node.js + TypeScript + Express application for testing Blue-Green deployment infrastructure.

## Features

- ✅ Health check endpoint (`/health`)
- ✅ API status endpoint (`/api/status`)
- ✅ User management endpoints (`/api/users`)
- ✅ PostgreSQL database integration
- ✅ Environment-based configuration
- ✅ PM2 ready for production

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Build TypeScript

```bash
npm run build
```

### 3. Run Locally

```bash
npm run dev
# or
npm start
```

### 4. Test Endpoints

- Health: http://localhost:3000/health
- Status: http://localhost:3000/api/status
- Users: http://localhost:3000/api/users

## Database Setup

### On RDS (Production)

The schema will be automatically created when you connect to the RDS database.

### Local Testing

```bash
# Connect to your PostgreSQL database
psql -U admin -d appdb

# Run schema
\i src/database/schema.sql
```

## Environment Variables

Copy `.env.example` to `.env` and configure:

```env
PORT=3000
DB_HOST=rds-endpoint.rds.amazonaws.com
DB_NAME=appdb
DB_USER=admin
DB_PASSWORD=your-password
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Welcome message |
| GET | `/health` | Health check |
| GET | `/api/status` | API status with DB connection |
| GET | `/api/users` | List all users |
| POST | `/api/users` | Create new user |

## PM2 Configuration

The app is configured to run with PM2 using `ecosystem.config.js`:

```bash
pm2 start ecosystem.config.js
pm2 status
pm2 logs
```

## Deployment

This app is designed to be deployed via:
- AWS CodeBuild (builds and packages)
- AWS CodeDeploy (deploys to EC2)
- PM2 (process manager)

The deployment lifecycle is managed by `appspec.yml` in the root directory.

