# Deployment Notes for Logic Legends App

## Setup Complete ✅

Created a demo Node.js + TypeScript + Express application to test your Blue-Green deployment infrastructure.

## Project Structure

```
logic-legends-app/
├── src/
│   ├── index.ts              # Main Express server
│   └── database/
│       └── schema.sql        # PostgreSQL schema
├── package.json              # Dependencies
├── tsconfig.json             # TypeScript config
├── README.md                 # App documentation
└── env.example.txt           # Environment variables template
```

## What the App Does

- **Health Check** endpoint: `/health`
- **API Status** endpoint: `/api/status` (checks DB connection)
- **Users API**: `/api/users` (GET/POST)
- PostgreSQL database with sample data

## Installation

Run these commands on a machine with Node.js installed:

```bash
cd logic-legends-app
npm install
npm run build
npm start
```

## Deployment Flow

When you run `terraform apply`, the buildspec.yml will:

1. Clone code from your GitHub repo (`logic-legends` repository)
2. Run `npm ci` to install dependencies
3. Run `npm run build` to compile TypeScript
4. Create `app.zip` package
5. Upload to S3
6. Trigger CodeDeploy
7. Deploy to Green EC2 instances

## Important Notes

- The demo app expects environment variables to be set on EC2
- Make sure your RDS database is created and schema is deployed
- The app uses PM2 for process management (configured in ecosystem.config.js)

