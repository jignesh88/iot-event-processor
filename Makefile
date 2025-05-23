.PHONY: build test clean docker-build docker-up docker-down deploy terraform-plan terraform-apply

# Variables
GOOS ?= linux
GOARCH ?= amd64
PROJECT_NAME = iot-event-processor
VERSION ?= $(shell git describe --tags --always --dirty)
BUILD_TIME = $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
LDFLAGS = -X main.version=$(VERSION) -X main.buildTime=$(BUILD_TIME)

# Build targets
build: build-reformer build-calculator build-api build-lambda build-generator

build-reformer:
	@echo "Building reformer..."
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -ldflags "$(LDFLAGS)" -o bin/reformer ./cmd/reformer

build-calculator:
	@echo "Building view calculator..."
	CGO_ENABLED=1 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -ldflags "$(LDFLAGS)" -o bin/view-calculator ./cmd/view-calculator

build-api:
	@echo "Building API gateway..."
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -ldflags "$(LDFLAGS)" -o bin/api-gateway ./cmd/api-gateway

build-lambda:
	@echo "Building blackboard controller..."
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o bin/blackboard-controller ./cmd/blackboard-controller

build-generator:
	@echo "Building data generator..."
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -ldflags "$(LDFLAGS)" -o bin/data-generator ./cmd/data-generator

# Test targets
test:
	@echo "Running tests..."
	go test -v -race -coverprofile=coverage.out ./...

test-unit:
	@echo "Running unit tests..."
	go test -v -race -short ./...

test-integration:
	@echo "Running integration tests..."
	go test -v -race -tags=integration ./tests/integration/...

test-performance:
	@echo "Running performance tests..."
	go test -v -race -tags=performance ./tests/performance/...

# Docker targets
docker-build:
	@echo "Building Docker images..."
	docker build -f scripts/docker/Dockerfile.reformer -t $(PROJECT_NAME)/reformer:$(VERSION) .
	docker build -f scripts/docker/Dockerfile.calculator -t $(PROJECT_NAME)/view-calculator:$(VERSION) .
	docker build -f scripts/docker/Dockerfile.api -t $(PROJECT_NAME)/api-gateway:$(VERSION) .

docker-up:
	@echo "Starting Docker Compose stack..."
	docker-compose up -d

docker-down:
	@echo "Stopping Docker Compose stack..."
	docker-compose down

docker-logs:
	@echo "Showing Docker Compose logs..."
	docker-compose logs -f

# Terraform targets
terraform-init:
	@echo "Initializing Terraform..."
	cd terraform && terraform init

terraform-plan:
	@echo "Planning Terraform deployment..."
	cd terraform && terraform plan

terraform-apply:
	@echo "Applying Terraform deployment..."
	cd terraform && terraform apply -auto-approve

terraform-destroy:
	@echo "Destroying Terraform deployment..."
	cd terraform && terraform destroy -auto-approve

# Linting and formatting
lint:
	@echo "Running golangci-lint..."
	golangci-lint run

fmt:
	@echo "Formatting Go code..."
	go fmt ./...

# Dependencies
deps:
	@echo "Downloading dependencies..."
	go mod download
	go mod tidy

# Clean
clean:
	@echo "Cleaning up..."
	rm -rf bin/
	rm -f coverage.out
	docker system prune -f

# Performance testing with k6
perf-test:
	@echo "Running performance tests with k6..."
	k6 run scripts/k6/load-test.js

stress-test:
	@echo "Running stress tests with k6..."
	k6 run scripts/k6/stress-test.js

# Development helpers
dev-setup: deps docker-up
	@echo "Development environment ready!"
	@echo "Grafana: http://localhost:3000 (admin/admin)"
	@echo "Prometheus: http://localhost:9090"
	@echo "MinIO: http://localhost:9001 (minioadmin/minioadmin)"
	@echo "API Gateway: http://localhost:8080"

dev-clean: docker-down clean

# Generate mocks
generate-mocks:
	@echo "Generating mocks..."
	go generate ./...

# Build for all platforms
build-all:
	@echo "Building for all platforms..."
	GOOS=linux GOARCH=amd64 make build
	GOOS=linux GOARCH=arm64 make build
	GOOS=darwin GOARCH=amd64 make build
	GOOS=darwin GOARCH=arm64 make build
	GOOS=windows GOARCH=amd64 make build

# Help
help:
	@echo "Available targets:"
	@echo "  build          - Build all applications"
	@echo "  test           - Run all tests"
	@echo "  docker-build   - Build Docker images"
	@echo "  docker-up      - Start development environment"
	@echo "  docker-down    - Stop development environment"
	@echo "  terraform-*    - Terraform operations"
	@echo "  lint           - Run linters"
	@echo "  perf-test      - Run performance tests"
	@echo "  dev-setup      - Setup development environment"
	@echo "  help           - Show this help"