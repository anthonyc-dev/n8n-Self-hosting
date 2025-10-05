# N8N Self-Hosting Setup with Docker, Nginx, and PostgreSQL

This repository contains a complete self-hosting setup for n8n (workflow automation tool) using Docker Compose, Nginx as a reverse proxy, and PostgreSQL as the database.

## 🏗️ Architecture

- **N8N**: Workflow automation platform (latest version)
- **PostgreSQL 15**: Database for storing workflows, executions, and user data
- **Nginx**: Reverse proxy with SSL termination
- **Let's Encrypt**: Automatic SSL certificate management

## 📋 Prerequisites

- Docker and Docker Compose installed
- Domain name pointing to your server (for SSL setup)
- Ports 80, 443, and 5678 available

## 🚀 Quick Start

### Option 1: Clone from GitHub

#### 1. Clone the Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/n8n-selfhost.git
cd n8n-selfhost
```

#### 2. Environment Configuration

Create a `.env` file in the root directory with the following variables:

```bash
# Database Configuration
DB_POSTGRESDB_USER=n8n_user
DB_POSTGRESDB_PASSWORD=your_secure_password
DB_POSTGRESDB_DATABASE=n8n

# N8N Configuration
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_admin_password
N8N_HOST=0.0.0.0
N8N_PORT=5678
WEBHOOK_URL=https://n8n.yourdomain.com
```

#### 3. Domain Configuration

Update the nginx configuration file (`nginx/conf.d/n8n.conf`) and replace `n8n.yourdomain.com` with your actual domain name.

#### 4. Start the Services

```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps
```

#### 5. SSL Certificate Setup (First Time Only)

```bash
# Install certbot in nginx container
docker-compose exec nginx sh -c "apt-get update && apt-get install -y certbot python3-certbot-nginx"

# Generate SSL certificate
docker-compose exec nginx certbot --nginx -d n8n.yourdomain.com

# Test certificate renewal
docker-compose exec nginx certbot renew --dry-run
```

### Option 2: Manual Setup

If you prefer to set up manually without cloning:

#### 1. Download Files

Download or copy the following files to your server:

- `docker-compose.yml`
- `nginx/conf.d/n8n.conf`
- Create the `nginx/certbot/` directory

#### 2. Follow Steps 2-5 from Option 1

## 📤 GitHub Deployment Guide

### Publishing to GitHub

#### 1. Initialize Git Repository

```bash
# Initialize git repository (if not already done)
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial n8n self-hosting setup"
```

#### 2. Create GitHub Repository

1. Go to [GitHub](https://github.com) and create a new repository
2. Name it `n8n-selfhost` (or your preferred name)
3. **Don't** initialize with README, .gitignore, or license (since you already have files)

#### 3. Push to GitHub

```bash
# Add GitHub remote (replace with your actual repository URL)
git remote add origin https://github.com/yourusername/n8n-selfhost.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### GitHub Repository Best Practices

#### 1. Create .env.example

Create a `.env.example` file with placeholder values:

```bash
# Database Configuration
DB_POSTGRESDB_USER=n8n_user
DB_POSTGRESDB_PASSWORD=change_this_password
DB_POSTGRESDB_DATABASE=n8n

# N8N Configuration
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=change_this_password
N8N_HOST=0.0.0.0
N8N_PORT=5678
WEBHOOK_URL=https://n8n.yourdomain.com
```

#### 2. Create .gitignore

```gitignore
# Environment files
.env
.env.local
.env.production

# SSL certificates
nginx/certbot/live/
nginx/certbot/accounts/

# Logs
*.log
logs/

# Database backups
*.sql
backups/

# OS files
.DS_Store
Thumbs.db
```

#### 3. Add GitHub Actions (Optional)

Create `.github/workflows/deploy.yml` for automated deployment:

```yaml
name: Deploy N8N

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Deploy to server
        uses: appleboy/ssh-action@v0.1.5
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /path/to/n8n-selfhost
            git pull origin main
            docker-compose down
            docker-compose up -d
```

### Server Setup for GitHub Deployment

#### 1. Prepare Server

```bash
# Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone your repository
git clone https://github.com/yourusername/n8n-selfhost.git
cd n8n-selfhost
```

#### 2. Configure Domain

```bash
# Update nginx configuration with your domain
sed -i 's/n8n.yourdomain.com/your-actual-domain.com/g' nginx/conf.d/n8n.conf

# Create .env file
nano .env  # Add your configuration
```

#### 3. Deploy

```bash
# Start services
docker-compose up -d

# Setup SSL (first time only)
docker-compose exec nginx sh -c "apt-get update && apt-get install -y certbot python3-certbot-nginx"
docker-compose exec nginx certbot --nginx -d your-actual-domain.com
```

## 🌐 Accessing N8N

### Local Access (Development)

- **URL**: `http://localhost:5678`
- **Direct access** to n8n container (bypasses nginx)

### Domain Access (Production)

- **HTTP**: `http://n8n.yourdomain.com` (automatically redirects to HTTPS)
- **HTTPS**: `https://n8n.yourdomain.com`
- **Access through nginx reverse proxy with SSL**

### Login Credentials

Use the credentials you set in your `.env` file:

- Username: `admin` (or your custom username)
- Password: Your configured admin password

## 🗄️ Database Access

### Connect to PostgreSQL Database

```bash
# Connect to PostgreSQL container
docker exec -it n8n-selfhost-postgres-1 psql -U n8n_user -d n8n
```

### Common Database Queries

#### View All Workflows

```sql
SELECT id, name, active, created_at, updated_at
FROM workflow_entity
ORDER BY created_at DESC;
```

#### View Workflow Executions

```sql
SELECT id, workflow_id, mode, status, started_at, finished_at
FROM execution_entity
ORDER BY started_at DESC
LIMIT 10;
```

#### View User Information

```sql
SELECT id, email, first_name, last_name, created_at
FROM user
ORDER BY created_at DESC;
```

#### View All Executions for a Specific Workflow

```sql
SELECT id, mode, status, started_at, finished_at, data
FROM execution_entity
WHERE workflow_id = 'your_workflow_id'
ORDER BY started_at DESC;
```

#### View Failed Executions

```sql
SELECT id, workflow_id, mode, status, started_at, finished_at, data
FROM execution_entity
WHERE status = 'error'
ORDER BY started_at DESC;
```

#### Count Executions by Status

```sql
SELECT status, COUNT(*) as count
FROM execution_entity
GROUP BY status;
```

### Database Backup

```bash
# Create a backup
docker exec n8n-selfhost-postgres-1 pg_dump -U n8n_user n8n > n8n_backup_$(date +%Y%m%d_%H%M%S).sql

# Restore from backup
docker exec -i n8n-selfhost-postgres-1 psql -U n8n_user -d n8n < your_backup_file.sql
```

## 🔧 Management Commands

### View Logs

```bash
# View all service logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f n8n
docker-compose logs -f postgres
docker-compose logs -f nginx
```

### Restart Services

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart n8n
```

### Update N8N

```bash
# Pull latest n8n image
docker-compose pull n8n

# Restart n8n service
docker-compose up -d n8n
```

### Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: This will delete all data)
docker-compose down -v
```

## 📁 Directory Structure

```
n8n-selfhost/
├── docker-compose.yml          # Main Docker Compose configuration
├── .env                        # Environment variables (create this)
├── nginx/
│   ├── conf.d/
│   │   └── n8n.conf           # Nginx reverse proxy configuration
│   └── certbot/               # SSL certificates storage
└── README.md                  # This documentation
```

## 🔒 Security Considerations

1. **Change default passwords** in the `.env` file
2. **Use strong passwords** for database and n8n authentication
3. **Keep SSL certificates updated** (automated with Let's Encrypt)
4. **Regular backups** of your database
5. **Monitor logs** for suspicious activity
6. **Update n8n regularly** to get security patches

## 🐛 Troubleshooting

### Common Issues

#### N8N Not Accessible

```bash
# Check if n8n container is running
docker-compose ps

# Check n8n logs
docker-compose logs n8n
```

#### Database Connection Issues

```bash
# Check PostgreSQL logs
docker-compose logs postgres

# Test database connection
docker-compose exec postgres psql -U n8n_user -d n8n -c "SELECT 1;"
```

#### SSL Certificate Issues

```bash
# Check nginx configuration
docker-compose exec nginx nginx -t

# Renew SSL certificate manually
docker-compose exec nginx certbot renew
```

#### Port Conflicts

```bash
# Check which processes are using ports
netstat -tulpn | grep :80
netstat -tulpn | grep :443
netstat -tulpn | grep :5678
```

### Reset Everything

```bash
# Stop all services and remove volumes (WARNING: Deletes all data)
docker-compose down -v

# Remove all images
docker-compose down --rmi all

# Start fresh
docker-compose up -d
```

## 📊 Monitoring

### Resource Usage

```bash
# View resource usage
docker stats

# View container resource usage
docker stats n8n-selfhost-n8n-1
docker stats n8n-selfhost-postgres-1
docker stats n8n-selfhost-nginx-1
```

### Health Checks

```bash
# Check n8n health
curl -f http://localhost:5678/healthz || echo "N8N is down"

# Check database health
docker-compose exec postgres pg_isready -U n8n_user
```

## 🔄 Maintenance

### Regular Tasks

1. **Weekly**: Check logs for errors
2. **Monthly**: Update n8n to latest version
3. **Quarterly**: Review and rotate passwords
4. **As needed**: Backup database before major changes

### Updates

```bash
# Update all services
docker-compose pull
docker-compose up -d

# Update only n8n
docker-compose pull n8n
docker-compose up -d n8n
```

---

## 📞 Support

For issues related to:

- **N8N**: Check [n8n documentation](https://docs.n8n.io/)
- **Docker**: Check [Docker documentation](https://docs.docker.com/)
- **PostgreSQL**: Check [PostgreSQL documentation](https://www.postgresql.org/docs/)

---

**Note**: Replace `n8n.yourdomain.com` with your actual domain name in all configuration files before deployment.
