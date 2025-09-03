#!/bin/bash

# Browsertrix Docker Health Check Script
# This script checks if all Browsertrix services are running correctly

echo "🔍 Browsertrix Docker Health Check"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a service is running
check_service() {
    local service_name=$1
    local port=$2
    local path=${3:-""}
    
    echo -n "Checking $service_name (port $port)... "
    
    if curl -s --max-time 5 "http://localhost:$port$path" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ OK${NC}"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        return 1
    fi
}

# Function to check if a Docker container is running
check_container() {
    local container_name=$1
    echo -n "Checking container $container_name... "
    
    if docker ps --format "table {{.Names}}" | grep -q "^$container_name$"; then
        echo -e "${GREEN}✓ Running${NC}"
        return 0
    else
        echo -e "${RED}✗ Not running${NC}"
        return 1
    fi
}

# Check if Docker Compose is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed or not available${NC}"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not available${NC}"
    exit 1
fi

echo "Docker and Docker Compose are available ✓"
echo ""

# Check all containers
echo "📦 Container Status:"
containers=("browsertrix-mongo" "browsertrix-redis" "browsertrix-backend" "browsertrix-emails" "browsertrix-frontend")
all_containers_ok=true

for container in "${containers[@]}"; do
    if ! check_container "$container"; then
        all_containers_ok=false
    fi
done

echo ""

# Check services if containers are running
if $all_containers_ok; then
    echo "🌐 Service Connectivity:"
    
    services_ok=true
    
    # Wait a moment for services to be ready
    echo "Waiting for services to be ready..."
    sleep 5
    
    # Check frontend (should return HTML or redirect)
    if ! check_service "Frontend" 8080; then
        services_ok=false
    fi
    
    # Check backend API (should return JSON)
    if ! check_service "Backend API" 8000 "/api"; then
        services_ok=false
    fi
    
    # Check emails service
    if ! check_service "Email Service" 3000; then
        services_ok=false
    fi
    
    echo ""
    
    # Database connectivity
    echo "🗄️ Database Status:"
    echo -n "Checking MongoDB connection... "
    if docker exec browsertrix-mongo mongosh --quiet --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ OK${NC}"
    else
        echo -e "${RED}✗ FAIL${NC}"
        services_ok=false
    fi
    
    echo -n "Checking Redis connection... "
    if docker exec browsertrix-redis redis-cli ping | grep -q "PONG"; then
        echo -e "${GREEN}✓ OK${NC}"
    else
        echo -e "${RED}✗ FAIL${NC}"
        services_ok=false
    fi
    
    echo ""
    
    # Summary
    if $services_ok; then
        echo -e "${GREEN}🎉 All services are healthy!${NC}"
        echo ""
        echo "You can now access Browsertrix at:"
        echo "  • Frontend: http://localhost:8080"
        echo "  • Backend API: http://localhost:8000"
        echo "  • API Docs: http://localhost:8000/redoc"
        exit 0
    else
        echo -e "${YELLOW}⚠️ Some services are not responding properly${NC}"
        echo ""
        echo "Troubleshooting steps:"
        echo "1. Check container logs: docker compose logs -f"
        echo "2. Wait a few more minutes for services to fully start"
        echo "3. Check the DOCKER.md file for more troubleshooting tips"
        exit 1
    fi
else
    echo -e "${RED}❌ Some containers are not running${NC}"
    echo ""
    echo "Please start the services first:"
    echo "  docker compose up -d"
    echo ""
    echo "Then check container logs:"
    echo "  docker compose logs -f"
    exit 1
fi