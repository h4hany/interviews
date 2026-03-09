# Microservices Interview Questions

## 1. What are Microservices?

**Answer:**
Microservices is an architectural style where applications are built as a collection of small, independent services that communicate over well-defined APIs. Each service is independently deployable and scalable.

## 2. What are the benefits of Microservices?

**Answer:**
- Independent deployment and scaling
- Technology diversity (different languages/frameworks)
- Fault isolation
- Team autonomy
- Easier to understand and maintain
- Better resource utilization

## 3. What are the challenges of Microservices?

**Answer:**
- Increased complexity
- Network latency
- Data consistency
- Service discovery
- Distributed tracing
- Testing complexity
- Operational overhead

## 4. What is the difference between Monolith and Microservices?

**Answer:**
- **Monolith**: Single deployable unit, all functionality in one codebase.
- **Microservices**: Multiple independent services, each with its own codebase and deployment.

## 5. What is Service Discovery?

**Answer:**
Service Discovery allows services to find and communicate with each other dynamically, without hardcoded addresses.

## 6. What is the difference between Client-Side and Server-Side Service Discovery?

**Answer:**
- **Client-Side**: Client queries service registry and selects instance (Eureka, Consul).
- **Server-Side**: Load balancer queries registry and routes requests (Kubernetes, AWS ELB).

## 7. What is API Gateway?

**Answer:**
API Gateway is a single entry point for clients, handling routing, authentication, rate limiting, and protocol translation.

## 8. What is the difference between API Gateway and Service Mesh?

**Answer:**
- **API Gateway**: External-facing, handles client requests.
- **Service Mesh**: Internal communication, handles service-to-service communication.

## 9. What is Circuit Breaker Pattern?

**Answer:**
Circuit Breaker prevents cascading failures by stopping requests to a failing service and providing fallback responses.

## 10. What is Bulkhead Pattern?

**Answer:**
Bulkhead isolates resources (thread pools, connections) to prevent one service failure from affecting others.

## 11. What is Saga Pattern?

**Answer:**
Saga manages distributed transactions across multiple services using a sequence of local transactions with compensation.

## 12. What is the difference between Choreography and Orchestration Saga?

**Answer:**
- **Choreography**: Services coordinate through events (decentralized).
- **Orchestration**: Central orchestrator coordinates steps (centralized).

## 13. What is Database per Service?

**Answer:**
Each microservice has its own database, ensuring loose coupling and independent scaling.

## 14. What is Event Sourcing?

**Answer:**
Event Sourcing stores state changes as a sequence of events, enabling time travel and audit trails.

## 15. What is CQRS (Command Query Responsibility Segregation)?

**Answer:**
CQRS separates read and write operations, using different models for commands (writes) and queries (reads).

## 16. What is the difference between Synchronous and Asynchronous Communication?

**Answer:**
- **Synchronous**: Request-response, blocking (REST, gRPC).
- **Asynchronous**: Event-driven, non-blocking (Message queues, Event streams).

## 17. What is Distributed Tracing?

**Answer:**
Distributed Tracing tracks requests across multiple services, providing visibility into system behavior and performance.

## 18. What is the difference between Logging and Distributed Tracing?

**Answer:**
- **Logging**: Individual service logs.
- **Distributed Tracing**: End-to-end request tracking across services.

## 19. What is Health Check in Microservices?

**Answer:**
Health checks monitor service availability and readiness, used by load balancers and orchestration platforms.

## 20. What is the difference between Liveness and Readiness Probes?

**Answer:**
- **Liveness**: Service is running (restart if fails).
- **Readiness**: Service is ready to accept traffic (remove from load balancer if fails).

## 21. What is Blue-Green Deployment?

**Answer:**
Blue-Green Deployment maintains two identical environments, switching traffic from old (blue) to new (green) version.

## 22. What is Canary Deployment?

**Answer:**
Canary Deployment gradually rolls out new version to a small percentage of users before full deployment.

## 23. What is Feature Flags?

**Answer:**
Feature Flags enable toggling features without code deployment, allowing gradual rollouts and A/B testing.

## 24. What is Service Mesh?

**Answer:**
Service Mesh provides infrastructure layer for service-to-service communication, handling load balancing, security, and observability.

## 25. What is the difference between Istio and Linkerd?

**Answer:**
- **Istio**: More features, higher complexity, CNCF project.
- **Linkerd**: Simpler, lighter, easier to use.

## 26. What is Container Orchestration?

**Answer:**
Container Orchestration automates deployment, scaling, and management of containerized microservices (Kubernetes, Docker Swarm).

## 27. What is the difference between Microservices and SOA?

**Answer:**
- **SOA**: Enterprise-focused, shared infrastructure, ESB.
- **Microservices**: Application-focused, independent infrastructure, API Gateway.

## 28. What is Bounded Context?

**Answer:**
Bounded Context defines the boundary within which a domain model is valid, aligning with microservice boundaries.

## 29. What is API Versioning?

**Answer:**
API Versioning manages changes to APIs while maintaining backward compatibility (URL versioning, header versioning).

## 30. What is the difference between REST and gRPC?

**Answer:**
- **REST**: HTTP-based, JSON, human-readable, flexible.
- **gRPC**: HTTP/2-based, Protocol Buffers, binary, faster, type-safe.

## 31. What is Message Queue in Microservices?

**Answer:**
Message Queues enable asynchronous communication between services, providing decoupling and reliability (RabbitMQ, Kafka).

## 32. What is Event-Driven Architecture?

**Answer:**
Event-Driven Architecture uses events to trigger and communicate between services, enabling loose coupling and scalability.

## 33. What is the difference between Event Sourcing and CQRS?

**Answer:**
- **Event Sourcing**: Stores events as source of truth.
- **CQRS**: Separates read and write models (can use Event Sourcing).

## 34. What is Service Registry?

**Answer:**
Service Registry maintains a database of available service instances and their locations (Eureka, Consul, etcd).

## 35. What is Configuration Management?

**Answer:**
Configuration Management centralizes configuration for microservices, enabling dynamic updates without redeployment.

## 36. What is the difference between Centralized and Distributed Configuration?

**Answer:**
- **Centralized**: Single source of truth (Config Server).
- **Distributed**: Configuration in each service (config files, environment variables).

## 37. What is API Composition?

**Answer:**
API Composition aggregates data from multiple services to fulfill client requests, avoiding multiple round trips.

## 38. What is Backend for Frontend (BFF)?

**Answer:**
BFF creates separate backend services for different client types (mobile, web), optimizing data for each client.

## 39. What is Strangler Pattern?

**Answer:**
Strangler Pattern gradually migrates from monolith to microservices by replacing functionality incrementally.

## 40. What is Microservices Best Practices?

**Answer:**
- Design around business capabilities
- Decentralize data management
- Implement circuit breakers
- Use API Gateway
- Implement distributed tracing
- Design for failure
- Use containerization
- Implement health checks
- Use asynchronous communication where appropriate
- Monitor and observe services

