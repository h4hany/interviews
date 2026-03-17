# Event-Driven Architecture Interview Questions

## 1. What is Event-Driven Architecture (EDA)?

**Answer:**
Event-Driven Architecture is a software architecture pattern where services communicate through events. Services produce and consume events asynchronously, enabling loose coupling and scalability.

## 2. What are the benefits of Event-Driven Architecture?

**Answer:**
- Loose coupling between services
- Scalability and performance
- Real-time responsiveness
- Resilience and fault tolerance
- Flexibility and extensibility

## 3. What is an Event?

**Answer:**
An Event is a significant occurrence or state change in a system that other services might be interested in.

## 4. What is the difference between Event and Message?

**Answer:**
- **Event**: Something that happened (past tense), notification of state change.
- **Message**: Request or command (present/future tense), instruction to do something.

## 5. What is Event Producer?

**Answer:**
Event Producer is a service that generates and publishes events when something significant happens.

## 6. What is Event Consumer?

**Answer:**
Event Consumer is a service that subscribes to and processes events.

## 7. What is Event Broker?

**Answer:**
Event Broker is middleware that receives events from producers and delivers them to consumers (Kafka, RabbitMQ, AWS EventBridge).

## 8. What is the difference between Event Streaming and Message Queuing?

**Answer:**
- **Event Streaming**: Continuous stream of events, multiple consumers, replay capability (Kafka).
- **Message Queuing**: Point-to-point delivery, one consumer per message (RabbitMQ).

## 9. What is Pub/Sub (Publish-Subscribe)?

**Answer:**
Pub/Sub is a messaging pattern where publishers send messages to topics/channels, and subscribers receive messages from topics they're subscribed to.

## 10. What is Event Sourcing?

**Answer:**
Event Sourcing stores all changes to application state as a sequence of events, enabling time travel and audit trails.

## 11. What is the difference between Event Sourcing and Event-Driven Architecture?

**Answer:**
- **Event Sourcing**: Storage pattern, events are source of truth.
- **Event-Driven Architecture**: Communication pattern, services communicate via events.

## 12. What is CQRS (Command Query Responsibility Segregation)?

**Answer:**
CQRS separates read and write operations, using different models for commands (writes) and queries (reads), often combined with Event Sourcing.

## 13. What is Event Store?

**Answer:**
Event Store is a database optimized for storing events, supporting event sourcing patterns.

## 14. What is Event Replay?

**Answer:**
Event Replay processes events again from the event store, useful for rebuilding state or creating new projections.

## 15. What is Event Versioning?

**Answer:**
Event Versioning manages schema evolution of events, ensuring backward compatibility as event structures change.

## 16. What is Event Choreography?

**Answer:**
Event Choreography is a decentralized approach where services coordinate through events without a central orchestrator.

## 17. What is Event Orchestration?

**Answer:**
Event Orchestration uses a central orchestrator to coordinate service interactions through events.

## 18. What is the difference between Choreography and Orchestration?

**Answer:**
- **Choreography**: Decentralized, services react to events independently.
- **Orchestration**: Centralized, orchestrator coordinates workflow.

## 19. What is Saga Pattern in Event-Driven Architecture?

**Answer:**
Saga Pattern manages distributed transactions using a sequence of events, with compensation events for rollback.

## 20. What is Eventual Consistency?

**Answer:**
Eventual Consistency means that all services will eventually have consistent data, but not immediately (common in EDA).

## 21. What is the difference between Strong Consistency and Eventual Consistency?

**Answer:**
- **Strong Consistency**: All services see same data immediately (ACID).
- **Eventual Consistency**: Services eventually converge to same state (BASE).

## 22. What is Event Ordering?

**Answer:**
Event Ordering ensures events are processed in the correct sequence, important for maintaining data consistency.

## 23. What is Idempotency in Events?

**Answer:**
Idempotency ensures processing the same event multiple times produces the same result, preventing duplicate processing.

## 24. What is Event Deduplication?

**Answer:**
Event Deduplication prevents processing duplicate events, typically using event IDs and idempotent consumers.

## 25. What is Dead Letter Queue (DLQ)?

**Answer:**
DLQ stores events that couldn't be processed after multiple retries, enabling manual investigation and reprocessing.

## 26. What is Event Schema Registry?

**Answer:**
Event Schema Registry stores and manages event schemas, ensuring compatibility between producers and consumers.

## 27. What is the difference between Event Stream and Event Log?

**Answer:**
- **Event Stream**: Continuous flow of events (Kafka).
- **Event Log**: Append-only log of events (Event Store).

## 28. What is Event Filtering?

**Answer:**
Event Filtering allows consumers to subscribe only to relevant events, reducing processing overhead.

## 29. What is Event Transformation?

**Answer:**
Event Transformation converts events from one format to another, enabling integration between different systems.

## 30. What is Event Routing?

**Answer:**
Event Routing determines which consumers receive which events, based on routing rules or patterns.

## 31. What is the difference between Event-Driven and Request-Response?

**Answer:**
- **Event-Driven**: Asynchronous, decoupled, push-based.
- **Request-Response**: Synchronous, coupled, pull-based.

## 32. What is Event Sourcing vs Traditional Database?

**Answer:**
- **Event Sourcing**: Stores events, rebuilds state from events.
- **Traditional Database**: Stores current state, overwrites previous state.

## 33. What is Projection in Event Sourcing?

**Answer:**
Projection is a read model built from events, optimized for specific queries (materialized view).

## 34. What is Snapshot in Event Sourcing?

**Answer:**
Snapshot is a saved state at a point in time, used to speed up rebuilding state from events.

## 35. What is Event-Driven Architecture Best Practices?

**Answer:**
- Design events for business meaning
- Ensure idempotency
- Version events carefully
- Use event schemas
- Implement dead letter queues
- Monitor event processing
- Handle eventual consistency
- Use appropriate event broker
- Design for failure
- Document event contracts

## 36. What is the difference between Event and Command?

**Answer:**
- **Event**: Something that happened (notification).
- **Command**: Request to do something (instruction).

## 37. What is Event Bus?

**Answer:**
Event Bus is infrastructure that routes events from producers to consumers (can be message broker or custom implementation).

## 38. What is Event-Driven Microservices?

**Answer:**
Event-Driven Microservices combine microservices architecture with event-driven communication, enabling scalable, decoupled systems.

## 39. What is Change Data Capture (CDC)?

**Answer:**
CDC captures database changes as events, enabling event-driven integration with existing systems.

## 40. What is the difference between Event Sourcing and Change Data Capture?

**Answer:**
- **Event Sourcing**: Events are primary source, application generates events.
- **CDC**: Events derived from database changes, database is source of truth.


