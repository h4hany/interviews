# RabbitMQ Interview Questions

## 1. What is RabbitMQ?

**Answer:**
RabbitMQ is an open-source message broker that implements the Advanced Message Queuing Protocol (AMQP). It facilitates asynchronous communication between services.

## 2. What is a message broker?

**Answer:**
A message broker is middleware that enables applications to communicate by sending and receiving messages asynchronously, decoupling producers and consumers.

## 3. What are the main components of RabbitMQ?

**Answer:**
- **Producer**: Application that sends messages
- **Queue**: Buffer that stores messages
- **Consumer**: Application that receives messages
- **Exchange**: Routes messages to queues
- **Binding**: Link between exchange and queue
- **Connection**: TCP connection to RabbitMQ
- **Channel**: Lightweight connection for operations

## 4. What is an Exchange in RabbitMQ?

**Answer:**
An Exchange receives messages from producers and routes them to queues based on routing rules. It doesn't store messages.

## 5. What are the types of Exchanges in RabbitMQ?

**Answer:**
- **Direct**: Routes to queues with matching routing key
- **Topic**: Routes based on pattern matching routing key
- **Fanout**: Broadcasts to all bound queues (ignores routing key)
- **Headers**: Routes based on message headers (ignores routing key)

## 6. What is the difference between Direct and Topic exchanges?

**Answer:**
- **Direct Exchange**: Exact match of routing key (e.g., "order.created" → queue with binding "order.created").
- **Topic Exchange**: Pattern matching with wildcards (e.g., "order.*" matches "order.created", "order.updated").

## 7. What is a Queue in RabbitMQ?

**Answer:**
A Queue is a buffer that stores messages until they are consumed. Messages are delivered to consumers in FIFO order.

## 8. What is a Binding in RabbitMQ?

**Answer:**
A Binding is a link between an Exchange and a Queue, defining routing rules (routing key or pattern).

## 9. What is the difference between durable and non-durable queues?

**Answer:**
- **Durable Queue**: Survives broker restart, messages are persisted.
- **Non-durable Queue**: Deleted on broker restart, messages are lost.

## 10. What is message acknowledgment in RabbitMQ?

**Answer:**
Message acknowledgment confirms that a consumer has successfully processed a message. If not acknowledged, the message is redelivered.

## 11. What is the difference between auto-ack and manual ack?

**Answer:**
- **Auto-ack**: Message is automatically acknowledged when delivered (risky, message lost if consumer crashes).
- **Manual ack**: Consumer must explicitly acknowledge (safer, message redelivered if consumer crashes).

## 12. What is message persistence in RabbitMQ?

**Answer:**
Message persistence ensures messages survive broker restarts by storing them on disk. Requires durable queue and persistent message.

## 13. What is a Dead Letter Exchange (DLX)?

**Answer:**
A DLX is an exchange where messages are sent when they are rejected, expire, or exceed queue length limit.

## 14. What is message TTL in RabbitMQ?

**Answer:**
TTL (Time To Live) sets expiration time for messages. Expired messages are sent to DLX or discarded.

## 15. What is queue TTL in RabbitMQ?

**Answer:**
Queue TTL sets expiration time for the queue itself. Empty queue is deleted after TTL expires.

## 16. What is the difference between `basic_publish` and `basic_consume`?

**Answer:**
- **`basic_publish`**: Producer sends message to exchange.
- **`basic_consume`**: Consumer subscribes to queue and receives messages.

## 17. What is prefetch count in RabbitMQ?

**Answer:**
Prefetch count limits the number of unacknowledged messages a consumer can receive, ensuring fair distribution among consumers.

## 18. What is the difference between `basic_get` and `basic_consume`?

**Answer:**
- **`basic_get`**: Polls queue for a single message (pull model).
- **`basic_consume`**: Subscribes to queue and receives messages automatically (push model).

## 19. What is RabbitMQ clustering?

**Answer:**
RabbitMQ clustering connects multiple nodes to form a single logical broker, providing high availability and load distribution.

## 20. What is RabbitMQ mirroring?

**Answer:**
Mirroring replicates queues across multiple nodes in a cluster, ensuring high availability if a node fails.

## 21. What is the difference between clustering and federation?

**Answer:**
- **Clustering**: Nodes in same network, shared state, low latency.
- **Federation**: Connects brokers across networks, asynchronous replication, higher latency.

## 22. What is RabbitMQ management plugin?

**Answer:**
The management plugin provides a web UI for monitoring and managing RabbitMQ (queues, exchanges, connections, etc.).

## 23. What is message routing key?

**Answer:**
A routing key is a message attribute used by exchanges to determine which queues should receive the message.

## 24. What is the difference between `mandatory` and `immediate` flags?

**Answer:**
- **`mandatory`**: Message returned if no queue is bound (prevents message loss).
- **`immediate`**: Message returned if no consumer is available (deprecated).

## 25. What is connection and channel in RabbitMQ?

**Answer:**
- **Connection**: TCP connection to RabbitMQ server (expensive to create).
- **Channel**: Lightweight connection within a connection (cheap, used for operations).

## 26. What is RabbitMQ priority queue?

**Answer:**
Priority queue delivers messages with higher priority first. Requires `x-max-priority` argument.

## 27. What is message ordering in RabbitMQ?

**Answer:**
RabbitMQ guarantees message ordering within a single queue, but not across multiple queues or consumers.

## 28. What is the difference between `basic_reject` and `basic_nack`?

**Answer:**
- **`basic_reject`**: Rejects a single message.
- **`basic_nack`**: Rejects one or multiple messages, supports batch rejection.

## 29. What is RabbitMQ lazy queues?

**Answer:**
Lazy queues store messages on disk immediately, reducing memory usage for large queues.

## 30. What is RabbitMQ sharding?

**Answer:**
Sharding plugin distributes messages across multiple queues, improving throughput for high-volume scenarios.

## 31. What is the difference between `exchange.declare` and `queue.declare`?

**Answer:**
- **`exchange.declare`**: Creates an exchange.
- **`queue.declare`**: Creates a queue.

## 32. What is RabbitMQ virtual hosts?

**Answer:**
Virtual hosts provide logical separation and isolation of resources (exchanges, queues, users) within a single broker.

## 33. What is message compression in RabbitMQ?

**Answer:**
Message compression reduces network bandwidth by compressing message payloads before sending.

## 34. What is RabbitMQ performance tuning?

**Answer:**
- Use connection pooling
- Use channels efficiently
- Set appropriate prefetch count
- Use lazy queues for large queues
- Enable message compression
- Use clustering for high availability
- Monitor queue lengths

## 35. What is the difference between `basic_publish` with and without routing key?

**Answer:**
Routing key is required for Direct and Topic exchanges. Fanout exchange ignores routing key.

## 36. What is RabbitMQ message properties?

**Answer:**
Message properties are metadata (headers, priority, TTL, correlation ID, reply-to) attached to messages.

## 37. What is request-reply pattern in RabbitMQ?

**Answer:**
Request-reply pattern uses correlation ID and reply-to queue to implement RPC-style communication.

## 38. What is RabbitMQ best practices?

**Answer:**
- Use durable queues and persistent messages for critical data
- Always acknowledge messages manually
- Set appropriate prefetch count
- Use Dead Letter Exchanges for error handling
- Monitor queue lengths and consumer lag
- Use connection and channel pooling
- Implement retry logic for failed messages

## 39. What is the difference between `queue.bind` and `queue.unbind`?

**Answer:**
- **`queue.bind`**: Binds queue to exchange with routing key.
- **`queue.unbind`**: Unbinds queue from exchange.

## 40. What is RabbitMQ message deduplication?

**Answer:**
Message deduplication prevents processing duplicate messages, typically implemented using message IDs and idempotent consumers.


