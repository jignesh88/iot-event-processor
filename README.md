# IoT Event Processing System

A scalable, cloud-native IoT event processing solution based on the NLIS architecture, designed to handle high-volume IoT data streams with out-of-order event processing capabilities.

## 🚀 Features

- **High-Performance Event Processing**: Handles millions of IoT events per day
- **Out-of-Order Event Handling**: Sophisticated OOO event detection and processing
- **Real-time Analytics**: Live dashboards and metrics for IoT device monitoring
- **Scalable Architecture**: Auto-scaling components based on AWS ECS/Fargate
- **Multi-Event Support**: Temperature, humidity, location, battery, and custom events
- **Comprehensive Monitoring**: Prometheus metrics and Grafana dashboards
- **Fault Tolerance**: Automatic failover and recovery mechanisms

## 🏗️ Architecture

The system implements the View Calculator pattern with three main components:

### 1. Event Reformer
- Orders events by observation time
- Handles out-of-order event detection
- Manages event snapshots for performance
- Publishes ordered events to Kafka

### 2. View Calculator
- Processes ordered events using calculation units
- Maintains aggregated device state in DuckDB
- Generates real-time metrics and alerts
- Creates periodic data snapshots

### 3. Blackboard Controller
- Orchestrates system state transitions
- Manages container roles (live, next, support)
- Handles epoch transitions for OOO events
- Coordinates failover scenarios

## 📋 Prerequisites

- Go 1.21+
- Docker and Docker Compose
- AWS CLI configured
- Terraform 1.0+
- k6 (for performance testing)

## 🛠️ Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/jignesh88/iot-event-processor.git
cd iot-event-processor
```

### 2. Setup Environment
```bash
cp .env.example .env
# Edit .env with your configuration
```

### 3. Start Development Environment
```bash
make dev-setup
```

This will start:
- Kafka cluster
- Redis cache
- MinIO (S3-compatible storage)
- Prometheus monitoring
- Grafana dashboards

### 4. Build and Run Services
```bash
make build
make docker-build
make docker-up
```

### 5. Access Services
- **API Gateway**: http://localhost:8080
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **MinIO**: http://localhost:9001 (minioadmin/minioadmin)

## 📊 API Endpoints

### Events API
```bash
# Submit an IoT event
POST /api/v1/events
{
  "device_id": "device-001",
  "event_type": "temperature",
  "payload": {
    "value": 25.5,
    "unit": "celsius"
  }
}

# Get events
GET /api/v1/events?device_id=device-001&from=2024-01-01T00:00:00Z
```

### Dashboard API
```bash
# Get device overview
GET /api/v1/dashboard/devices

# Get metrics
GET /api/v1/dashboard/metrics

# Get alerts
GET /api/v1/dashboard/alerts
```

### Metrics API
```bash
# Get temperature metrics
GET /api/v1/metrics/temperature?device_id=device-001

# Get location metrics
GET /api/v1/metrics/location?device_id=device-001

# Get battery metrics
GET /api/v1/metrics/battery?device_id=device-001
```

## 🧪 Testing

### Unit Tests
```bash
make test-unit
```

### Integration Tests
```bash
make test-integration
```

### Performance Tests
```bash
# Load testing
make perf-test

# Stress testing
make stress-test
```

### Benchmarks
```bash
go test -bench=. ./tests/performance/
```

## 🚀 Deployment

### AWS Infrastructure
```bash
# Initialize Terraform
make terraform-init

# Plan deployment
make terraform-plan

# Deploy infrastructure
make terraform-apply
```

### Application Deployment
```bash
# Build for production
make build-all

# Deploy services
make deploy
```

## 📈 Monitoring and Observability

### Metrics
The system exposes Prometheus metrics for:
- Event processing rates and latency
- Out-of-order event counts
- View calculator tether length
- System resource usage
- Error rates and alerts

### Dashboards
Pre-configured Grafana dashboards provide:
- Real-time event processing overview
- Device status and health
- Performance metrics
- Alert status

### Logging
Structured JSON logging with configurable levels:
- Debug: Development environments
- Info: Production environments
- Error: Critical issues and failures

## 🔧 Configuration

Configuration is managed through YAML files and environment variables:

```yaml
# configs/prod.yaml
environment: "production"
aws:
  region: "us-west-2"
kafka:
  brokers:
    - "kafka-prod-1.example.com:9092"
    - "kafka-prod-2.example.com:9092"
reformer:
  batch_size: 200
  processing_interval: "500ms"
```

## 🔐 Security

- IAM roles with least privilege access
- Encryption at rest (S3, EBS)
- Encryption in transit (TLS)
- VPC with private subnets
- Security groups with minimal access
- Secrets management via AWS Parameter Store

## 📖 Documentation

- [Architecture Guide](docs/architecture.md)
- [Deployment Guide](docs/deployment.md)
- [API Documentation](docs/api.md)
- [Monitoring Guide](docs/monitoring.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in this repository
- Check the [documentation](docs/)
- Review the [FAQ](docs/faq.md)

## 🙏 Acknowledgments

Based on the NLIS (National Livestock Identification System) architecture patterns and best practices for high-volume event processing systems.

---

**Built with ❤️ for the IoT community**