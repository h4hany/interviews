# Apache Kafka Interview Questions

## 1. What is Apache Kafka?

**Answer:**
Apache Kafka is a distributed streaming platform used for building real-time data pipelines and streaming applications. It's designed for high throughput and scalability.

## 2. What are the main use cases of Kafka?

**Answer:**
- Real-time data streaming
- Event sourcing
- Log aggregation
- Message queuing
- Activity tracking
- Stream processing

## 3. What are the core concepts of Kafka?

**Answer:**
- **Producer**: Publishes messages to topics
- **Consumer**: Subscribes to topics and reads messages
- **Topic**: Category/feed name for messages
- **Partition**: Ordered sequence of messages within a topic
- **Broker**: Kafka server that stores data
- **Cluster**: Collection of brokers
- **Consumer Group**: Group of consumers working together

## 4. What is a Topic in Kafka?

**Answer:**
A Topic is a category or feed name to which messages are published. Topics are partitioned and replicated across brokers.

## 5. What is a Partition in Kafka?

**Answer:**
A Partition is an ordered, immutable sequence of messages within a topic. Partitions enable parallelism and scalability.

## 6. What is the difference between Topic and Partition?

**Answer:**
- **Topic**: Logical category for messages.
- **Partition**: Physical division of a topic for parallel processing and scalability.

## 7. What is a Broker in Kafka?

**Answer:**
A Broker is a Kafka server that stores data and serves clients. A Kafka cluster consists of multiple brokers.

## 8. What is replication in Kafka?

**Answer:**
Replication creates copies of partitions across multiple brokers for fault tolerance and high availability.

## 9. What is a Leader and Follower in Kafka?

**Answer:**
- **Leader**: Handles all read/write requests for a partition.
- **Follower**: Replicates data from leader, becomes leader if leader fails.

## 10. What is a Consumer Group in Kafka?

**Answer:**
A Consumer Group is a set of consumers that work together to consume messages from topics. Each message is consumed by only one consumer in the group.

## 11. What is the difference between Consumer and Consumer Group?

**Answer:**
- **Consumer**: Single instance that reads messages.
- **Consumer Group**: Multiple consumers sharing work, ensuring each message is processed once.

## 12. What is offset in Kafka?

**Answer:**
Offset is a unique identifier for each message within a partition. Consumers track their position using offsets.

## 13. What is the difference between `earliest` and `latest` offset?

**Answer:**
- **`earliest`**: Start from the beginning of the partition.
- **`latest`**: Start from the end (only new messages).

## 14. What is Kafka Producer?

**Answer:**
A Producer is an application that publishes messages to Kafka topics. It can choose which partition to send messages to.

## 15. What is the difference between synchronous and asynchronous producer?

**Answer:**
- **Synchronous**: Waits for acknowledgment before sending next message (slower, more reliable).
- **Asynchronous**: Sends messages without waiting (faster, less reliable).

## 16. What is producer acknowledgment (acks) in Kafka?

**Answer:**
- **`acks=0`**: No acknowledgment (fastest, may lose data).
- **`acks=1`**: Leader acknowledgment (balanced).
- **`acks=all`**: All replicas acknowledgment (safest, slowest).

## 17. What is idempotent producer in Kafka?

**Answer:**
Idempotent producer ensures exactly-once semantics by preventing duplicate messages even if producer retries.

## 18. What is Kafka Consumer?

**Answer:**
A Consumer reads messages from Kafka topics. Consumers can be part of a consumer group for parallel processing.

## 19. What is the difference between `poll()` and `commit()` in Kafka?

**Answer:**
- **`poll()`**: Fetches messages from Kafka.
- **`commit()`**: Commits offset, marking messages as processed.

## 20. What is auto-commit in Kafka?

**Answer:**
Auto-commit automatically commits offsets at regular intervals. Simpler but may cause duplicate processing.

## 21. What is manual commit in Kafka?

**Answer:**
Manual commit gives control over when offsets are committed, enabling exactly-once processing.

## 22. What is rebalancing in Kafka?

**Answer:**
Rebalancing redistributes partitions among consumers when consumers join or leave a consumer group.

## 23. What is the difference between eager and cooperative rebalancing?

**Answer:**
- **Eager Rebalancing**: Stops all consumers, redistributes partitions (causes downtime).
- **Cooperative Rebalancing**: Incremental rebalancing without stopping consumers (better).

## 24. What is Kafka Streams?

**Answer:**
Kafka Streams is a library for building stream processing applications that read from and write to Kafka topics.

## 25. What is Kafka Connect?

**Answer:**
Kafka Connect is a framework for connecting Kafka with external systems (databases, file systems, etc.) using connectors.

## 26. What is the difference between Source Connector and Sink Connector?

**Answer:**
- **Source Connector**: Imports data from external system to Kafka.
- **Sink Connector**: Exports data from Kafka to external system.

## 27. What is Kafka Schema Registry?

**Answer:**
Schema Registry stores and manages Avro schemas, ensuring compatibility between producers and consumers.

## 28. What is the difference between Avro and JSON in Kafka?

**Answer:**
- **Avro**: Binary format, schema evolution, smaller size, better performance.
- **JSON**: Human-readable, larger size, no schema enforcement.

## 29. What is Kafka retention policy?

**Answer:**
Retention policy determines how long messages are kept. Can be time-based (e.g., 7 days) or size-based (e.g., 1GB).

## 30. What is log compaction in Kafka?

**Answer:**
Log compaction keeps only the latest value for each key, useful for maintaining current state of keyed data.

## 31. What is the difference between `delete` and `compact` retention?

**Answer:**
- **Delete**: Removes old messages based on time/size.
- **Compact**: Keeps latest value per key, removes older values.

## 32. What is Kafka partition assignment strategy?

**Answer:**
Partition assignment strategies determine how partitions are distributed among consumers:
- Range
- Round Robin
- Sticky
- Cooperative Sticky

## 33. What is the difference between `Range` and `Round Robin` assignment?

**Answer:**
- **Range**: Assigns consecutive partitions to consumers (may cause imbalance).
- **Round Robin**: Distributes partitions evenly (better balance).

## 34. What is Kafka exactly-once semantics?

**Answer:**
Exactly-once semantics ensures each message is processed exactly once, preventing duplicates and data loss.

## 35. What is the difference between at-least-once and exactly-once?

**Answer:**
- **At-least-once**: Messages may be processed multiple times (duplicates possible).
- **Exactly-once**: Each message processed exactly once (no duplicates, no loss).

## 36. What is Kafka transaction?

**Answer:**
Kafka transactions enable atomic writes across multiple partitions, ensuring all-or-nothing semantics.

## 37. What is the difference between `enable.idempotence` and transactions?

**Answer:**
- **Idempotence**: Prevents duplicates within a single partition.
- **Transactions**: Ensures atomicity across multiple partitions.

## 38. What is Kafka performance tuning?

**Answer:**
- Increase partition count for parallelism
- Tune batch size and linger time
- Use compression (snappy, gzip, lz4)
- Optimize consumer fetch size
- Use appropriate replication factor
- Monitor broker resources

## 39. What is the difference between `max.poll.records` and `fetch.min.bytes`?

**Answer:**
- **`max.poll.records`**: Maximum records returned per poll.
- **`fetch.min.bytes`**: Minimum bytes to fetch before returning.

## 40. What is Kafka best practices?

**Answer:**
- Use appropriate number of partitions
- Set proper replication factor (at least 3)
- Use idempotent producers
- Implement proper error handling
- Monitor consumer lag
- Use schema registry for data contracts
- Set appropriate retention policies
- Use compression for efficiency

## 41. What is consumer lag in Kafka?

**Answer:**
Consumer lag is the difference between the latest offset and the consumer's current offset, indicating how far behind the consumer is.

## 42. What is the difference between `seek()` and `seekToBeginning()`?

**Answer:**
- **`seek()`**: Seeks to a specific offset.
- **`seekToBeginning()`**: Seeks to the beginning of all assigned partitions.

## 43. What is Kafka partitioner?

**Answer:**
A Partitioner determines which partition a message should be sent to. Default is round-robin or key-based.

## 44. What is the difference between keyed and non-keyed messages?

**Answer:**
- **Keyed Messages**: Same key goes to same partition (enables ordering per key).
- **Non-keyed Messages**: Distributed round-robin (no ordering guarantee).

## 45. What is Kafka MirrorMaker?

**Answer:**
MirrorMaker replicates data between Kafka clusters, useful for disaster recovery and multi-datacenter setups.

## 46. What is the difference between MirrorMaker and MirrorMaker 2?

**Answer:**
- **MirrorMaker**: Simple replication, manual configuration.
- **MirrorMaker 2**: Improved with automatic offset translation, topic renaming, better monitoring.

## 47. What is Kafka security?

**Answer:**
Kafka security includes:
- SSL/TLS encryption
- SASL authentication (PLAIN, SCRAM, GSSAPI)
- ACLs (Access Control Lists)
- Authorization

## 48. What is the difference between `PLAIN` and `SCRAM` SASL?

**Answer:**
- **PLAIN**: Simple username/password (less secure).
- **SCRAM**: Salted Challenge Response (more secure, recommended).

## 49. What is Kafka monitoring?

**Answer:**
Kafka monitoring includes:
- Broker metrics (CPU, memory, disk)
- Topic metrics (throughput, lag)
- Consumer group metrics (lag, offset)
- JVM metrics

## 50. What is the difference between `__consumer_offsets` and regular topics?

**Answer:**
- **`__consumer_offsets`**: Internal topic storing consumer group offsets.
- **Regular Topics**: User-created topics for application data.

