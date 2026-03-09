# Redis Interview Questions

## 1. What is Redis?

**Answer:**
Redis (Remote Dictionary Server) is an in-memory data structure store used as a database, cache, and message broker. It supports strings, hashes, lists, sets, sorted sets, and more.

## 2. What are the main features of Redis?

**Answer:**
- In-memory storage for fast performance
- Data persistence (RDB snapshots, AOF)
- Replication for high availability
- Pub/Sub messaging
- Lua scripting
- Transactions
- Expiration/TTL support

## 3. What data types does Redis support?

**Answer:**
- **Strings**: Text, numbers, binary data
- **Hashes**: Field-value pairs (like objects)
- **Lists**: Ordered collections of strings
- **Sets**: Unordered collections of unique strings
- **Sorted Sets**: Sets with scores for ordering
- **Bitmaps**: Bit-level operations
- **HyperLogLog**: Probabilistic cardinality estimation
- **Streams**: Log-like data structure

## 4. What is the difference between Redis and Memcached?

**Answer:**
- **Redis**: More features (persistence, replication, data structures, pub/sub), single-threaded, more memory usage.
- **Memcached**: Simpler, multi-threaded, less memory overhead, no persistence.

## 5. What is Redis persistence?

**Answer:**
Redis persistence allows data to survive restarts. Two methods:
- **RDB (Redis Database)**: Point-in-time snapshots
- **AOF (Append Only File)**: Logs every write operation

## 6. What is the difference between RDB and AOF?

**Answer:**
- **RDB**: Faster, smaller files, data loss between snapshots, good for backups.
- **AOF**: More durable, larger files, slower recovery, better for data safety.

## 7. What is Redis replication?

**Answer:**
Redis replication allows a master Redis server to replicate data to one or more replica servers for high availability and read scaling.

## 8. What is Redis Sentinel?

**Answer:**
Redis Sentinel provides high availability by monitoring master and replica instances, automatically failing over if the master fails.

## 9. What is Redis Cluster?

**Answer:**
Redis Cluster provides automatic sharding across multiple Redis nodes, enabling horizontal scaling and high availability.

## 10. What is the difference between Redis Sentinel and Redis Cluster?

**Answer:**
- **Sentinel**: High availability for single master-replica setup, manual sharding.
- **Cluster**: Automatic sharding, multiple masters, built-in high availability.

## 11. What is Redis Pub/Sub?

**Answer:**
Redis Pub/Sub is a messaging system where publishers send messages to channels, and subscribers receive messages from channels they're subscribed to.

### Example:
```bash
# Publisher
PUBLISH news "Breaking news!"

# Subscriber
SUBSCRIBE news
```

## 12. What is a Redis transaction?

**Answer:**
A Redis transaction groups multiple commands into a single atomic operation. Commands are queued and executed together.

### Example:
```bash
MULTI
SET key1 value1
SET key2 value2
EXEC
```

## 13. What is the difference between `MULTI/EXEC` and `WATCH`?

**Answer:**
- **`MULTI/EXEC`**: Groups commands atomically.
- **`WATCH`**: Provides optimistic locking, aborts transaction if watched keys change.

## 14. What is Redis TTL (Time To Live)?

**Answer:**
TTL allows keys to expire automatically after a specified time. Useful for caching and session management.

### Example:
```bash
SET key "value" EX 3600  # Expires in 3600 seconds
TTL key  # Check remaining time
```

## 15. What is the difference between `EXPIRE` and `EXPIREAT`?

**Answer:**
- **`EXPIRE`**: Sets expiration in seconds from now.
- **`EXPIREAT`**: Sets expiration at a specific Unix timestamp.

## 16. What is Redis Lua scripting?

**Answer:**
Redis supports Lua scripting to execute complex operations atomically on the server side, reducing network round trips.

### Example:
```lua
EVAL "return redis.call('GET', KEYS[1])" 1 mykey
```

## 17. What is Redis pipelining?

**Answer:**
Pipelining allows sending multiple commands without waiting for each response, improving performance by reducing network latency.

## 18. What is the difference between `SET` and `SETNX`?

**Answer:**
- **`SET`**: Sets a key-value, overwrites if exists.
- **`SETNX`**: Sets a key-value only if key doesn't exist (atomic operation).

## 19. What is Redis memory optimization?

**Answer:**
- Use appropriate data types
- Set expiration on keys
- Use compression
- Configure maxmemory and eviction policies
- Use Redis hashes for small objects

## 20. What are Redis eviction policies?

**Answer:**
When memory limit is reached, Redis can evict keys:
- **noeviction**: Returns errors (default)
- **allkeys-lru**: Evict least recently used
- **allkeys-lfu**: Evict least frequently used
- **volatile-lru**: Evict LRU among keys with expiration
- **volatile-ttl**: Evict shortest TTL

## 21. What is the difference between `LPUSH` and `RPUSH`?

**Answer:**
- **`LPUSH`**: Adds element to the left (beginning) of list.
- **`RPUSH`**: Adds element to the right (end) of list.

## 22. What is the difference between `SADD` and `ZADD`?

**Answer:**
- **`SADD`**: Adds member to a set (unordered).
- **`ZADD`**: Adds member with score to sorted set (ordered by score).

## 23. What is Redis HyperLogLog?

**Answer:**
HyperLogLog is a probabilistic data structure for estimating the cardinality (unique count) of a set with minimal memory.

### Example:
```bash
PFADD visitors user1 user2 user3
PFCOUNT visitors  # Returns approximate count
```

## 24. What is Redis Streams?

**Answer:**
Redis Streams is a log-like data structure for message queues, similar to Kafka, supporting consumer groups and message acknowledgment.

## 25. What is the difference between `GET` and `MGET`?

**Answer:**
- **`GET`**: Retrieves value of a single key.
- **`MGET`**: Retrieves values of multiple keys in one command.

## 26. What is Redis Bitmaps?

**Answer:**
Bitmaps allow bit-level operations on strings, useful for analytics like user activity tracking.

### Example:
```bash
SETBIT user:1000:2023-01-01 5 1  # Set bit 5
GETBIT user:1000:2023-01-01 5    # Get bit 5
BITCOUNT user:1000:2023-01-01     # Count set bits
```

## 27. What is the difference between `INCR` and `INCRBY`?

**Answer:**
- **`INCR`**: Increments key by 1.
- **`INCRBY`**: Increments key by specified amount.

## 28. What is Redis persistence configuration?

**Answer:**
- **RDB**: `save 900 1` (save if 1 key changed in 900 seconds)
- **AOF**: `appendonly yes` and `appendfsync everysec`

## 29. What is Redis master-replica replication?

**Answer:**
Replicas connect to master, receive write commands, and maintain a copy of the dataset. Replicas can handle read requests.

## 30. What is Redis slow log?

**Answer:**
Slow log records commands that exceed a specified execution time, useful for performance monitoring.

## 31. What is the difference between `KEYS` and `SCAN`?

**Answer:**
- **`KEYS`**: Blocks server, returns all matching keys (avoid in production).
- **`SCAN`**: Non-blocking, cursor-based iteration (safe for production).

## 32. What is Redis connection pooling?

**Answer:**
Connection pooling reuses connections instead of creating new ones for each request, improving performance.

## 33. What is Redis caching patterns?

**Answer:**
- **Cache-Aside**: Application checks cache, loads from DB if miss
- **Write-Through**: Write to cache and DB simultaneously
- **Write-Behind**: Write to cache, async write to DB
- **Refresh-Ahead**: Proactively refresh cache before expiration

## 34. What is Redis distributed locking?

**Answer:**
Distributed locking uses Redis to coordinate access to shared resources across multiple processes/servers.

### Example:
```bash
SET lock:resource "value" EX 10 NX  # Acquire lock
DEL lock:resource  # Release lock
```

## 35. What is Redis performance tuning?

**Answer:**
- Use pipelining
- Use appropriate data structures
- Avoid blocking commands (KEYS, FLUSHALL)
- Configure memory limits
- Use connection pooling
- Monitor slow queries
- Use Lua scripts for complex operations

## 36. What is the difference between `HGET` and `HGETALL`?

**Answer:**
- **`HGET`**: Gets value of a specific field in a hash.
- **`HGETALL`**: Gets all fields and values in a hash.

## 37. What is Redis memory fragmentation?

**Answer:**
Memory fragmentation occurs when Redis can't use freed memory efficiently. Can be reduced by using appropriate data types and setting maxmemory.

## 38. What is Redis benchmarking?

**Answer:**
Redis includes `redis-benchmark` tool to test performance by simulating multiple clients executing commands.

## 39. What is the difference between `EXISTS` and `TYPE`?

**Answer:**
- **`EXISTS`**: Checks if key exists (returns 1 or 0).
- **`TYPE`**: Returns the data type of a key.

## 40. What is Redis security best practices?

**Answer:**
- Use authentication (AUTH)
- Bind to specific interfaces
- Use SSL/TLS
- Disable dangerous commands (FLUSHALL, CONFIG)
- Use firewall rules
- Keep Redis updated
- Use strong passwords

