# Makefile for Browsertrix Docker operations

.PHONY: help build up down clean logs pull dev prod test status

# Default target
help:
	@echo "Browsertrix Docker Management"
	@echo "============================="
	@echo ""
	@echo "Development Commands:"
	@echo "  dev        - Start services in development mode"
	@echo "  build      - Build all Docker images"
	@echo "  up         - Start all services"
	@echo "  down       - Stop all services"
	@echo "  clean      - Stop services and remove volumes"
	@echo "  logs       - View logs from all services"
	@echo "  status     - Show status of all services"
	@echo ""
	@echo "Production Commands:"
	@echo "  prod       - Start services using production compose file"
	@echo "  prod-down  - Stop production services"
	@echo ""
	@echo "Utility Commands:"
	@echo "  pull       - Pull latest base images"
	@echo "  test       - Run basic connectivity tests"

# Development environment
dev: build up

# Build all images
build:
	@echo "Building all Docker images..."
	docker compose build

# Start services
up:
	@echo "Starting all services..."
	docker compose up -d

# Stop services
down:
	@echo "Stopping all services..."
	docker compose down

# Clean everything (including volumes)
clean:
	@echo "Stopping services and removing volumes..."
	docker compose down -v
	docker system prune -f

# View logs
logs:
	docker compose logs -f

# Show service status
status:
	@echo "Service Status:"
	@echo "==============="
	docker compose ps
	@echo ""
	@echo "Network Status:"
	@echo "==============="
	docker network ls | grep browsertrix
	@echo ""
	@echo "Volume Status:"
	@echo "=============="
	docker volume ls | grep browsertrix

# Production environment
prod:
	@echo "Starting production environment..."
	docker compose -f docker-compose.prod.yml up -d

prod-down:
	@echo "Stopping production environment..."
	docker compose -f docker-compose.prod.yml down

# Pull latest base images
pull:
	@echo "Pulling latest base images..."
	docker pull mongo:7
	docker pull redis:7-alpine
	docker pull python:3.12-slim
	docker pull node:22-alpine
	docker pull nginx:1.23.2

# Basic connectivity test
test:
	@echo "Running connectivity tests..."
	@echo "Checking if services are responding..."
	@curl -s http://localhost:8080 > /dev/null && echo "✓ Frontend (8080) is responding" || echo "✗ Frontend (8080) not responding"
	@curl -s http://localhost:8000 > /dev/null && echo "✓ Backend (8000) is responding" || echo "✗ Backend (8000) not responding"
	@curl -s http://localhost:3000 > /dev/null && echo "✓ Emails (3000) is responding" || echo "✗ Emails (3000) not responding"

# Docker cleanup
docker-clean:
	@echo "Cleaning up Docker system..."
	docker system prune -a -f
	docker volume prune -f