# Browsertrix Docker Compose Setup

This Docker Compose setup allows you to run the entire Browsertrix application stack locally for development and testing purposes.

## Prerequisites

- Docker and Docker Compose installed on your system
- At least 4GB of available RAM
- At least 10GB of available disk space

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/yaniber/browsertrix.git
   cd browsertrix
   ```

2. Start all services:
   ```bash
   docker compose up -d
   ```

3. Wait for all services to start (this may take a few minutes on first run)

4. Access the application:
   - Frontend: http://localhost:8080
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/redoc

## Services

The Docker Compose setup includes the following services:

- **Frontend** (port 8080): React/Lit-based web interface served by Nginx
- **Backend** (port 8000): FastAPI-based Python API server
- **Emails** (port 3000): Node.js email service for notifications
- **MongoDB** (port 27017): Database for storing application data
- **Redis** (port 6379): Cache and message broker for background jobs

## Default Credentials

- **Admin User**: 
  - Email: admin@localhost
  - Password: admin

- **MongoDB**:
  - Username: admin
  - Password: password

## Development

For development, you can mount local source code and enable hot reloading:

```bash
# Start services in development mode
docker compose up -d

# View logs
docker compose logs -f

# Restart a specific service
docker compose restart backend

# Stop all services
docker compose down

# Stop all services and remove volumes
docker compose down -v
```

## Environment Variables

You can customize the setup by modifying the `.env.development` file or creating your own `.env` file with the following variables:

- `MONGO_INITDB_ROOT_USERNAME`: MongoDB admin username
- `MONGO_INITDB_ROOT_PASSWORD`: MongoDB admin password
- `JWT_SECRET`: Secret key for JWT token generation
- `SUPERUSER_EMAIL`: Default admin user email
- `SUPERUSER_PASSWORD`: Default admin user password
- `API_BASE_URL`: Backend API URL for frontend

## Troubleshooting

### Services not starting
- Check if ports 8080, 8000, 3000, 27017, and 6379 are available
- Ensure Docker has enough resources allocated

### Database connection errors
- Wait for MongoDB to fully initialize (usually 30-60 seconds)
- Check MongoDB logs: `docker compose logs mongo`

### Build errors
- Ensure you have enough disk space
- Try rebuilding: `docker compose build --no-cache`
- **SSL Certificate Issues**: In some environments, you may encounter SSL certificate verification errors during builds. This is often due to corporate firewalls or security policies.

### Permission errors
- On Linux/macOS, you may need to adjust file permissions:
  ```bash
  sudo chown -R $USER:$USER .
  ```

### Known Issues
- The backend service depends on a GitHub repository (`stream-zip`) which may cause build issues in restricted environments
- First-time builds may take 10-15 minutes depending on your internet connection
- MongoDB initialization can take up to 2 minutes on slower systems

## Data Persistence

Data is persisted in Docker volumes:
- `mongo_data`: MongoDB database files
- `redis_data`: Redis data files

To completely reset the application data:
```bash
docker compose down -v
docker compose up -d
```