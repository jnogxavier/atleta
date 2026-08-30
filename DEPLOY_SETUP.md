# Deployment Setup Guide

## Environment Variables Setup

Kamal is configured to read environment variables from a `.env` file in the project root.

### 1. Create the .env file

Copy the example file and fill in your actual values:

```bash
cp .env.example .env
```

### 2. Edit the .env file

Open `.env` and update the values:

```bash
# GitHub Container Registry Personal Access Token
KAMAL_REGISTRY_PASSWORD=ghp_YOUR_ACTUAL_TOKEN_HERE

# Database connection (production server - replace with your actual values)
DATABASE_URL=postgres://username:password@host:5432/database_name
```

### 3. Get Your GitHub Token (if you don't have one)

1. Go to: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Give it a name like: "Kamal Deploy Token"
4. Select expiration: **No expiration** (or custom)
5. Check these scopes:
   - ✅ `write:packages` (allows pushing to GitHub Container Registry)
   - ✅ `read:packages` (allows pulling from GitHub Container Registry)
   - ✅ `delete:packages` (optional - for cleaning up old images)
6. Click **"Generate token"**
7. Copy the token (starts with `ghp_...`) and paste it in your `.env` file

### 4. Important Security Notes

- **NEVER** commit the `.env` file to git (it's already in `.gitignore`)
- The `.env` file contains sensitive credentials
- Keep your GitHub token secure and rotate it periodically

## Deploy

Once your `.env` file is configured:

```bash
kamal deploy
```

Kamal will automatically load secrets from `.env` via the `.kamal/secrets` script.

## How it Works

According to Kamal's documentation, the `.kamal/secrets` file:
1. Reads `RAILS_MASTER_KEY` from `config/master.key`
2. Reads `DATABASE_URL` and `KAMAL_REGISTRY_PASSWORD` from `.env`
3. Outputs these values for Kamal to use

**Important:** Secret variables are stored in an env file on the host server (not passed directly to docker run), making them invisible in logs and docker inspect.
