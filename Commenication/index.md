### Question 1:

**How does HTTP differ from WebSockets, and when would you choose one over the other in a backend architecture?**

#### Your Answer:

HTTP (Hypertext Transfer Protocol) is a request-response protocol, where the client sends a request and the server
responds. It is stateless and short-lived, which means that each request is independent, and after receiving the
response, the connection is closed.

WebSockets, on the other hand, provide a full-duplex communication channel over a single, long-lived connection. Once
established, the connection remains open, allowing both the client and server to send messages to each other at any
time.

**When to choose HTTP:**

- When the interaction between client and server is simple and request/response based.
- For traditional web applications, API endpoints, and general browsing.

**When to choose WebSockets:**

- For real-time applications (e.g., chat apps, live notifications, gaming, collaborative tools) where the server and
  client need to exchange data constantly without the overhead of repeatedly opening and closing connections.

---

### Question 2:

**What are the advantages and disadvantages of using Redis for caching in a Rails application?**

#### Your Answer:

**Advantages of Redis for caching:**

- **Speed:** Redis is an in-memory data store, making it very fast for read and write operations.
- **Persistence:** While Redis is primarily an in-memory cache, it supports data persistence to disk, making it suitable
  for scenarios requiring durability.
- **Data Structures:** Redis supports various data structures (strings, lists, sets, sorted sets, hashes, etc.), which
  can be used in advanced caching strategies.
- **Scalability:** Redis can be scaled horizontally by partitioning data across multiple instances.
- **Ease of Integration:** Rails has built-in support for Redis through gems like `redis-rails`, making it easy to set
  up for caching.

**Disadvantages of Redis for caching:**

- **Memory Limitation:** As an in-memory store, Redis is limited by the amount of available memory, making it unsuitable
  for large datasets.
- **Persistence Overhead:** Enabling persistence in Redis can reduce its performance, and in some cases, you might want
  a pure cache without persistence.
- **Single Point of Failure:** If Redis is not set up in a cluster or with proper failover mechanisms, it could become a
  single point of failure for the application.

---

### Question 3:

**What are cache eviction strategies, and how do you decide which strategy to use in a Rails application?**

#### Your Answer:

**Cache eviction strategies:**

1. **Least Recently Used (LRU):** Evicts the least recently accessed items. It's useful when the cache size is limited,
   and you want to remove old or rarely accessed items.
2. **Least Frequently Used (LFU):** Evicts the least frequently accessed items. It ensures that more frequently used
   data remains in the cache.
3. **Time-based (TTL - Time to Live):** Data is evicted after a predefined period. This is useful for data that becomes
   stale after a certain time.
4. **Manual Eviction:** Allows you to manually invalidate or clear cache entries, useful when data changes and you want
   to ensure freshness.
5. **Random:** Randomly evicts cache entries when space is needed. It's not very efficient but can be used for some
   simple use cases.

**How to decide which strategy to use in a Rails app:**

- **LRU** is a good choice when the cache size is fixed, and you want to ensure that the most recently used data is
  retained.
- **LFU** is beneficial when certain data is used much more frequently than others.
- **TTL** is ideal for caching data that has an expiration or that is expected to change periodically (e.g., session
  data, temporary results).
- **Manual eviction** is suitable when you need full control over cache invalidation, especially in dynamic content
  scenarios.

---

### Question 4:

**What is the purpose of using a reverse proxy like Nginx or HAProxy in a Rails application, and how does it relate to
communication protocols like HTTP and WebSockets?**

#### Your Answer:

**Purpose of using a reverse proxy:**

- **Load Balancing:** A reverse proxy like Nginx or HAProxy can distribute incoming HTTP traffic across multiple
  application servers, which helps balance the load and improve performance.
- **Security:** Reverse proxies can hide the details of your backend servers, providing an additional layer of security.
- **SSL Termination:** They can manage SSL encryption, freeing backend servers from the overhead of
  encryption/decryption.
- **Caching:** Reverse proxies can cache static assets (like images, JavaScript, CSS) or even dynamic content, reducing
  the load on backend servers.
- **Compression and Optimizations:** They can also handle request and response compression to reduce bandwidth usage and
  optimize delivery speeds.

**How it relates to HTTP and WebSockets:**

- **HTTP:** Reverse proxies typically handle HTTP traffic and can direct it to different backend servers based on load
  balancing policies or routing rules. They help scale web applications by managing large volumes of HTTP requests.
- **WebSockets:** Nginx and HAProxy can also manage WebSocket connections. WebSockets require long-lived connections,
  and reverse proxies can handle the upgrade process from HTTP to WebSocket protocol and ensure that WebSocket
  connections are properly maintained.

---

### Question 5:

**Can you explain how HTTP/2 improves upon HTTP/1.1, and what impact does it have on Rails applications in terms of
performance?**

#### Your Answer:

**Improvements of HTTP/2 over HTTP/1.1:**

- **Multiplexing:** HTTP/2 allows multiple requests and responses to be sent over a single connection simultaneously,
  whereas HTTP/1.1 handles one request/response pair per connection, leading to head-of-line blocking.
- **Header Compression:** HTTP/2 uses header compression, reducing the overhead of redundant headers sent in each
  request and response, improving performance.
- **Stream Prioritization:** HTTP/2 allows for prioritizing certain requests, ensuring that critical resources load
  faster.
- **Server Push:** HTTP/2 can push resources from the server to the client without the client needing to request them,
  reducing latency for essential assets.

**Impact on Rails applications:**

- **Faster resource loading:** HTTP/2's multiplexing and header compression reduce latency, making Rails applications
  load faster, especially when many assets (CSS, JS, images) need to be loaded.
- **Reduced Connection Overhead:** With HTTP/2's ability to send multiple requests over a single connection, the need
  for opening multiple TCP connections is reduced, saving resources and improving scalability.
- **Improved performance for mobile apps:** HTTP/2 optimizations, especially with server push and header compression,
  benefit mobile applications, which tend to have higher latency and lower bandwidth.

---

### Question 6:

**What are WebSocket subprotocols, and how are they useful in a Rails application that uses Action Cable?**

#### Your Answer:

A WebSocket subprotocol is a protocol negotiated between the client and the server during the handshake process. After
the WebSocket connection is established, subprotocols define specific formats for messages exchanged over that
connection. The subprotocol allows the server and client to communicate in a way that is agreed upon before data
transmission begins.

**How they are useful in Rails (with Action Cable):**

- **Custom Communication Formats:** Subprotocols in WebSockets allow for a structured way to define communication
  patterns. This is especially useful in Action Cable when you want to handle different types of messages or
  interactions,
  such as chat messages, notifications, or updates from the server.
- **Ensuring Compatibility:** If a Rails application requires compatibility with multiple clients or services that may
  need different communication protocols (e.g., JSON, Protocol Buffers), subprotocols help establish the right context
  for
  communication.
- **Action Cable and Subprotocols:** While Action Cable doesn't directly support defining custom subprotocols by
  default, you can use subprotocols to customize how Action Cable channels interpret and manage messages. For instance,
  you can handle different types of data formats and ensure both the client and server understand how to process them.

---

### Question 7:

**How does caching with `Rails.cache` work, and what are the different cache stores you can use in a Rails application?
**

#### Your Answer:

**How `Rails.cache` works:**
`Rails.cache` is an interface provided by Rails to interact with different caching mechanisms. It helps improve the
performance of web applications by temporarily storing frequently accessed data in memory, so it doesn't need to be
fetched from the database or computed every time a request is made. Rails provides several cache stores to choose
from, depending on your application’s needs and infrastructure.

**Cache stores in Rails:**

1. **MemoryStore:** Caches data in memory on a single machine. It is fast but does not scale well in distributed
   environments.
2. **FileStore:** Caches data in files on the local filesystem. This is useful when you need a simple, disk-based
   cache, but it is also limited by the filesystem’s performance.
3. **MemCacheStore:** Uses Memcached as the caching backend, ideal for distributed caching and scaling across
   multiple servers.
4. **RedisCacheStore:** Uses Redis as the caching backend, which supports more advanced features than Memcached,
   such as persistence and more complex data structures.
5. **NullStore:** A dummy store that effectively disables caching, useful for testing or situations where you don’t
   need to cache data.
6. **Custom Store:** Rails allows you to create custom cache stores if you need to integrate a unique caching
   solution.

**Choosing the right store:**

- **MemoryStore** is good for small, single-server applications or testing environments.
- **Redis** or **MemCacheStore** is recommended for larger, distributed applications with high traffic, as they
  provide persistence and can be shared across multiple servers.

---

### Question 8:

**What are some common strategies for invalidating or expiring cache entries in a Rails application?**

#### Your Answer:

**Common strategies for invalidating or expiring cache entries:**

1. **Time-based Expiration (TTL):**
    - You can set a time-to-live (TTL) value for cached entries. Once the TTL expires, the cache entry is
      automatically invalidated.
    - Rails supports TTL using `Rails.cache.fetch` with the `expires_in` option. For
      example, `Rails.cache.fetch('key', expires_in: 10.minutes)`.

2. **Manual Invalidation:**
    - You can manually invalidate cache entries when certain actions occur, such as when a model is updated or
      deleted.
    - For example, after updating a user’s profile, you can expire the cache for their profile page
      using `Rails.cache.delete('user_profile')`.
    - This is useful when you need full control over when the cache is invalidated.

3. **Versioned Keys:**
    - Another strategy is to version cache keys. You increment the version number whenever the cached data changes,
      so the old cache entries become irrelevant.
    - For example, you could store a user’s data under `user_data_v1`, `user_data_v2`, etc., and update the version
      number when the data changes.

4. **Write-through and Read-through Cache:**
    - **Write-through:** Cache is updated when data is written to the database. Every time a write operation occurs,
      it updates the cache automatically.
    - **Read-through:** If the data is not in the cache, it is fetched from the source and automatically stored in
      the cache for future requests.

5. **Cache Sweeping:**
    - This involves explicitly clearing or updating cache entries at certain intervals or under certain conditions,
      often by using background jobs or scheduled tasks. For instance, you can periodically sweep old or irrelevant
      cache entries to prevent them from becoming stale.

6. **Dependency-based Expiration:**
    - Rails supports cache dependencies. For example, if you cache a page that depends on a model, you can set up an
      automatic expiration whenever that model is updated. This ensures that the cache is cleared when data changes.
    - Example: `cache(@user) { render @user }` will expire the cache when `@user` is modified.

    
---

### Question 9:

**What is the purpose of a content delivery network (CDN) in a Rails application, and how does it impact the performance
of assets like images, JavaScript, and CSS?**

#### Your Answer:

**Purpose of a Content Delivery Network (CDN):**
A CDN is a distributed network of servers designed to deliver content to users based on their geographic location. By
caching copies of assets (such as images, JavaScript, and CSS files) in multiple data centers around the world, CDNs
reduce the distance between the user and the content, which improves the speed at which assets are loaded.

**Impact on performance:**

1. **Faster Load Times:** CDNs serve static assets from locations closer to the user, reducing latency and improving
   load times. This is especially beneficial for users located far from the origin server.
2. **Reduced Server Load:** By offloading the delivery of static assets to the CDN, the origin server is freed from
   handling these requests, which reduces load and allows the server to focus on dynamic content generation.
3. **Improved Reliability:** CDNs offer redundancy through their distributed network of servers, meaning if one server
   fails, content can still be delivered from other nearby servers, improving availability.
4. **Bandwidth Savings:** CDNs can handle large volumes of traffic and optimize content delivery, potentially reducing
   bandwidth costs for the application.
5. **Caching:** CDNs provide effective caching strategies for assets, which reduces the need for repeated requests to
   the origin server and decreases response times.
6. **Compression and Optimization:** Many CDNs automatically compress files and optimize images, further improving
   performance.

**How CDNs are used in Rails:**

- Rails can integrate with CDNs for static asset delivery by using gems like `asset_sync` or by configuring Rails' asset
  pipeline (e.g., `config.action_controller.asset_host`) to point to a CDN.
- CDNs can be used to deliver both static assets (images, JavaScript, CSS) and dynamic content such as API responses,
  depending on the configuration.

---

### Question 10:

**What are the potential issues with caching dynamic content in a Rails application, and how can you mitigate these
issues?**

#### Your Answer:

**Potential Issues with Caching Dynamic Content:**

1. **Stale Content:**
    - Caching dynamic content can lead to outdated data being served to users. This occurs when the cache is not
      invalidated or updated when the underlying data changes, causing users to see stale or incorrect information.
    - **Mitigation:** Use cache expiration strategies (e.g., TTL, manual invalidation) to ensure the cache is refreshed
      at appropriate intervals. You can also use versioning of cached data to ensure the cache reflects updates.

2. **Cache Invalidation Complexity:**
    - For dynamic content that is highly personalized or frequently updated (like user dashboards or personalized
      feeds), managing cache invalidation can be difficult. This can result in data being cached for too long or not
      cached at all.
    - **Mitigation:** Implement conditional caching, where data is cached only if it meets certain conditions. Use
      techniques like fragment caching for parts of a page that don’t change often, and expire caches when critical data
      changes.

3. **Data Consistency:**
    - If you cache dynamic content and multiple processes or requests are modifying it concurrently, it can lead to race
      conditions and data inconsistency. For example, different users might receive different cached versions of the
      same content.
    - **Mitigation:** Use atomic operations when modifying cache data. Consider using write-through or write-behind
      caching strategies to maintain consistency between the database and the cache.

4. **Memory and Storage Overhead:**
    - Caching large amounts of dynamic data, especially in high-traffic applications, can lead to significant memory or
      disk usage, potentially causing resource depletion or slower performance.
    - **Mitigation:** Set appropriate cache size limits, evict stale or unused entries using a Least Recently Used (LRU)
      cache strategy, and choose an efficient cache store like Redis to manage large datasets.

5. **Personalized Content Caching:**
    - When content is highly personalized (e.g., user-specific data), caching can become problematic because caching the
      same content for multiple users may not be feasible.
    - **Mitigation:** Use user-specific cache keys for personalized content, ensuring that each user has a unique cache
      entry. You can also use session-based caching where necessary.

6. **Performance Overhead from Cache Lookups:**
    - Frequent cache lookups for highly dynamic data may incur an overhead, especially if the cache store is slow or has
      high latency.
    - **Mitigation:** Optimize cache store performance by using fast cache solutions like Redis or Memcached, and
      minimize cache lookups by employing strategies like lazy loading or intelligent cache population.


