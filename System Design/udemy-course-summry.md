# System Design — Study Q&A

> All questions and answers from the interactive study app, organized by category.

---

## 📦 Databases & CAP Theorem

**Q01. What does ACID stand for, and what does each letter mean?**
Atomicity (entire transaction succeeds or fails completely), Consistency (rules are consistently applied), Isolation (no
transaction affected by another in-progress transaction), Durability (committed data persists even if the system
crashes).

---

**Q02. What is 'Atomicity' in ACID, and why does it matter?**
Atomicity means a database transaction either fully completes or fully rolls back — no partial writes. This prevents '
half-baked' data from being committed when part of a complex operation fails.

---

**Q03. What does 'Consistency' mean in ACID vs the CAP Theorem?**
In ACID, consistency means database rules (constraints) are always enforced. In CAP, consistency means you always read
the latest write immediately. These are two completely different definitions.

---

**Q04. What is 'Isolation' in ACID?**
Isolation ensures that concurrent transactions don't interfere with each other. While one transaction is writing data,
another cannot modify that same data simultaneously, preventing race conditions.

---

**Q05. What does 'Durability' mean in ACID, and when would you NOT need it?**
Durability guarantees that committed data survives system crashes (written to persistent storage). In-memory caches are
not durable, but they're still useful for speed — durability isn't always required.

---

**Q06. What are the three letters in the CAP Theorem, and what do they represent?**
C = Consistency (you always read the most recent write), A = Availability (no single point of failure that can go down),
P = Partition Tolerance (you can horizontally scale/shard the data).

---

**Q07. What is the core trade-off stated by the CAP Theorem?**
You can only achieve TWO of the three properties — Consistency, Availability, and Partition Tolerance — at the same
time. You must choose which two matter most for your requirements.

---

**Q08. Where does MySQL fall on the CAP Theorem, and why?**
MySQL favors Consistency + Availability, giving up Partition Tolerance. It has strong consistency (single host writes),
high availability (few failure points), but it's hard to horizontally partition/shard.

---

**Q09. Where does Cassandra fall on the CAP Theorem?**
Cassandra favors Availability + Partition Tolerance (A+P), giving up Consistency. It uses a ring structure with no
single primary, so it scales horizontally and has no single point of failure, but data replication causes eventual
consistency.

---

**Q10. Where do MongoDB and DynamoDB fall on the CAP Theorem, and why?**
They favor Consistency + Partition Tolerance (C+P), giving up Availability. They have a single primary node that is a
potential point of failure, but elect a new primary automatically within seconds.

---

**Q11. What is 'eventual consistency'?**
In distributed databases, it takes time for data written to one node to propagate to all other nodes. During that
window, some reads may return stale data. The system eventually becomes consistent — but not immediately.

---

**Q12. What is denormalized data, and what are its trade-offs?**
Denormalized data duplicates information across rows to enable single-query lookups without joins. Advantage: faster
reads, fewer DB hits. Disadvantage: updates are hard (must change every row), wastes storage, risk of data going out of
sync.

---

**Q13. What is normalized data, and when is it preferable?**
Normalized data stores each piece of information once and uses references (foreign keys) to relate tables. Advantages:
less storage, easy updates in one place. It's the right default starting point — only denormalize when performance
demands it.

---

**Q14. What is database sharding, and why is it used?**
Sharding (horizontal partitioning) splits a database across multiple servers (shards), each holding a subset of the
data. A router/hash function determines which shard to query. It allows virtually infinite horizontal scaling.

---

**Q15. What is the 'celebrity problem' (hotspot problem) in sharded databases?**
When a hash-based shard stores data for an extremely popular entity (e.g., a celebrity), that shard gets
disproportionately high traffic. Modern systems monitor traffic per shard and repartition dynamically to balance load.

---

**Q16. What is re-sharding, and why is it challenging?**
Re-sharding is the process of redistributing data across shards when you add or remove servers. It requires moving data
between hosts in a fault-tolerant way while the system is live — a complex and potentially risky operation.

---

**Q17. What is the difference between a warm standby and a hot standby database?**
Warm standby: a secondary DB with replication enabled — data is copied continuously, but it isn't actively serving
reads. Hot standby: real-time replication and the backup also handles read traffic; immediate failover with near-zero
data loss.

---

**Q18. What is a cold standby database?**
A cold standby relies on periodic backups to a separate server. When the primary fails, you restore the backup to the
standby and redirect traffic. It's the cheapest option but has the most downtime and potential data loss.

---

**Q19. What is a multi-primary database setup?**
Multiple database nodes all accept both reads AND writes simultaneously. No reliance on replication to sync writes — the
application writes to all primaries directly. When one fails, others continue without interruption.

---

**Q20. What is HDFS, and what is it used for?**
HDFS (Hadoop Distributed File System) is an open-source distributed storage system. It breaks files into blocks,
replicates them across multiple servers and racks for fault tolerance, and is typically used for storing massive
datasets in big data/analytics workloads.

---

**Q21. What is the role of the HDFS Name Node?**
The Name Node is the master coordinator that tracks which blocks of each file are stored on which data nodes. Clients
contact it first to find where data lives, then fetch data directly from the relevant data nodes.

---

**Q22. What does 'NoSQL' actually mean in practice?**
It stands for 'Not Only SQL.' NoSQL databases are designed for horizontal scalability and flexible schemas. Most still
support SQL as a query interface but avoid complex joins across shards. Best used with simple key-value lookups.

---

## ⚖️ Scaling

**Q23. What is the difference between vertical scaling and horizontal scaling?**
Vertical scaling = bigger machine (more CPU/RAM). Horizontal scaling = more machines with load distributed across them.
Vertical scaling has a hard ceiling; horizontal scaling is theoretically infinite but requires stateless design.

---

**Q24. What is a load balancer, and why is it essential for horizontal scaling?**
A load balancer distributes incoming requests across a fleet of servers using strategies like round-robin or
capacity-aware routing. It enables horizontal scaling and removes single points of failure — if one server dies, others
take over.

---

**Q25. What does 'stateless' mean for web servers, and why does it matter for horizontal scaling?**
A stateless server doesn't store any user session data locally. Any request from any user can go to any server. This is
required for horizontal scaling because the load balancer can route requests to different servers without breaking the
experience.

---

**Q26. What is geo-routing, and why is it used?**
Geo-routing uses DNS tricks to send users to the server fleet physically closest to them (e.g., North American users →
North American data center). It reduces latency and also provides resiliency — if one region fails, traffic can route to
another.

---

**Q27. How do message queues help with scaling?**
Message queues decouple producers and consumers of data. If downstream consumers (e.g., fraud detection) get backed up,
messages sit in the queue rather than being lost. This prevents cascading failures and allows independent scaling of
each side.

---

**Q28. What is the difference between SQS-style queues and pub/sub systems?**
SQS-style queues have one producer and one consumer. Pub/Sub (publish-subscribe) allows multiple consumers to subscribe
and each receive the same message — useful when many downstream services need the same event (e.g., order placed).

---

**Q29. What is partition tolerance in the CAP Theorem, and why is it almost always required?**
Partition tolerance means the system can scale horizontally (add more nodes/shards). For truly massive systems, you MUST
be able to add capacity. This is typically non-negotiable, forcing you to choose between consistency or availability as
the trade-off.

---

## 🗄️ Caching & CDN

**Q30. What is the primary purpose of a caching layer, and when does it help the most?**
Caching stores frequently accessed database results in memory so you avoid expensive disk reads. It helps most when
reads >> writes, because writes invalidate the cache. A cache that is constantly invalidated provides little benefit.

---

**Q31. What is an LRU cache, and how does it work?**
Least Recently Used cache evicts the item that hasn't been accessed for the longest time. Implemented with a HashMap (
for O(1) lookup) + a doubly linked list (to track recency). Accessing an item moves it to the front; eviction pulls from
the tail.

---

**Q32. What is a Least Frequently Used (LFU) cache?**
LFU tracks how often each key is accessed over time, not just recency. Keys with the lowest access count are evicted
first. More predictive than LRU but more complex to implement — better when you have a small cache and clear usage
frequency patterns.

---

**Q33. What is FIFO eviction in a cache?**
FIFO (First In, First Out) evicts the item that was added to the cache earliest, regardless of how often it's been
accessed. Simple to implement but often suboptimal — recently added popular items could be evicted before old stale
ones.

---

**Q34. What is the cold-start (cold cache) problem?**
When a cache layer starts up with an empty cache, every request flows through to the database until the cache warms up.
At massive scale, this initial burst can crash the database. Solution: pre-warm the cache using replayed logs before
exposing it to live traffic.

---

**Q35. What is the 'celebrity problem' in caching (hotspot)?**
A cache server that stores data for an extremely popular entity (e.g., a famous actor) receives disproportionate
traffic. Solution: intelligent load-aware routing rather than naive key hashing, or replicating hot items across
multiple cache servers.

---

**Q36. What is the difference between Memcached and Redis?**
Memcached is simple, fast, and proven — a pure in-memory key-value store. Redis has more features: persistence
snapshots, replication, transactions, pub/sub, and advanced data structures. Redis is more popular today but more
complex.

---

**Q37. What is ElastiCache, and when would you use it?**
ElastiCache is AWS's fully managed Redis or Memcached service. You don't manage servers. It's most efficient when your
entire stack is on AWS, placing the cache in the same data centers as your application servers for minimal latency.

---

**Q38. What is a CDN (Content Delivery Network), and what does it cache?**
A CDN is a geographically distributed fleet of edge servers that cache static content (HTML, CSS, JS, images, videos)
close to end users. It reduces latency by serving content from a server physically near the user instead of a distant
origin server.

---

**Q39. What are the main CDN providers mentioned, and what is a key trade-off of CDNs?**
AWS CloudFront, Google Cloud CDN, Microsoft Azure CDN, Akamai, Cloudflare. Key trade-off: CDNs are expensive. Network
bandwidth and server costs across global edge locations add up fast — especially for large video files. Be selective
about what you cache.

---

**Q40. What is cache expiration policy, and why does it matter?**
Expiration policy determines how long data stays in the cache before being considered stale. Too long: users see
outdated data. Too short: cache provides no benefit. The right TTL depends on how frequently the underlying data
changes.

---

## 🧮 Algorithms & Data Structures

**Q41. What is Big O notation, and what does O(n) mean?**
Big O notation describes the worst-case time or space complexity of an algorithm as input size grows. O(n) means the
operation scales linearly — if you have n items, you may need to visit all n of them (e.g., linear search in a linked
list).

---

**Q42. What is a linked list, and what is its access complexity?**
A linked list is a dynamic data structure where each node holds a value and a pointer to the next node. Access is O(n) —
you must traverse from the head. Insertion at the head is O(1); insertion at the tail is O(n) without a tail pointer.

---

**Q43. What is the difference between a singly linked list and a doubly linked list?**
Singly linked: each node has only a 'next' pointer. Doubly linked: each node has both 'next' and 'previous' pointers.
Doubly linked lists allow O(1) insertion at both head AND tail (with pointers to both), and are useful for LRU caches.

---

**Q44. What is a binary search tree, and what is its average access complexity?**
A BST is an ordered tree where left children < parent < right children. Average access is O(log n) — each comparison
halves the search space. Worst case is O(n) if the tree degenerates into a linked list (e.g., inserting data in sorted
order).

---

**Q45. What is a self-balancing binary search tree, and when is it useful?**
It automatically rearranges itself during insertions to stay balanced, maintaining O(log n) operations. Useful when you
have infrequent inserts but need very fast, large-scale lookups — guarantees the worst-case degeneration to a linked
list never occurs.

---

**Q46. What is a hash table, and why is it important for system design?**
A hash table uses a hash function to map a key to a bucket, enabling O(1) average lookup, insert, and delete. In
distributed systems, the same concept scales to a fleet: hash a key to determine which server stores the data — O(1)
routing across thousands of machines.

---

**Q47. What is a hash collision, and how is it handled?**
A hash collision occurs when two keys hash to the same bucket. It can be handled by storing a linked list (or BST for
many collisions) within the bucket. Quality of the hash function and number of buckets are critical for performance.

---

**Q48. What is Breadth-First Search (BFS) vs Depth-First Search (DFS)?**
BFS explores all neighbors of a node before going deeper (level-by-level). DFS follows one path all the way to the end
before backtracking. For massively deep graphs like the web, BFS is preferred — DFS would follow one path forever.

---

**Q49. What is the Big O complexity of graph traversal (BFS or DFS)?**
O(V + E) — you must visit every Vertex and every Edge to fully traverse a graph. There's no shortcut; since graphs are
unordered, you can't binary-search or skip vertices.

---

**Q50. What is linear search vs binary search?**
Linear search: start at the beginning and check each item — O(n). Binary search: requires sorted data, starts in the
middle, and halves the search space each step — O(log n). Always sort first if you'll be searching repeatedly.

---

**Q51. What are the best sorting algorithms and their complexities?**
Insertion Sort: O(n) best case, O(n²) worst. Merge Sort: O(n log n) always — best for large datasets. Quicksort: O(n log
n) average, O(n²) worst with bad pivot. Bubble Sort: O(n²) — never use this in production.

---

**Q52. What is an inverted index, and how does it power search engines?**
An inverted index maps keywords to a ranked list of document IDs containing that keyword. When a user searches, you look
up the keyword → get the ranked list → return results. This is the core data structure behind all search engines.

---

**Q53. What is TF-IDF, and what problem does it solve?**
TF-IDF (Term Frequency × Inverse Document Frequency) measures how important a word is to a specific document compared to
the entire corpus. It avoids ranking common words (the, and, a) highly by penalizing words that appear in many
documents.

---

**Q54. What is PageRank?**
Google's original ranking algorithm. A page's importance is based on how many other pages link to it (backlinks),
weighted by the importance of those linking pages. Inspired by academic citation counts. Modern Google uses deep
learning instead.

---

## ☁️ Cloud Services

**Q55. What is Amazon S3, and what is it primarily used for?**
S3 (Simple Storage Service) is AWS's object store — a massive, durable place to store any raw data (files, logs,
backups, media). It offers 11 nines of durability. Used as the foundation for data lakes and as input for analytics
pipelines.

---

**Q56. What is a Data Lake?**
A data lake is a massive repository of raw, unstructured data (CSV, JSON, log files) in object storage (like S3). Unlike
a database, it doesn't impose schema upfront. You apply structure later with tools like AWS Glue, then query with Athena
or Redshift.

---

**Q57. What is AWS Glue, and what problem does it solve?**
AWS Glue crawls data in S3, infers a schema, and creates a catalog that allows SQL tools (like Athena) to query raw
files as if they were a structured database. It 'imparts structure onto structureless data.'

---

**Q58. What is Amazon Athena?**
Athena is a serverless SQL query engine that runs queries directly against data stored in S3. You pay per query, don't
manage servers, and use standard SQL. It works on top of AWS Glue's schema catalog.

---

**Q59. What is Amazon Kinesis?**
Kinesis is AWS's managed data streaming service — similar to Kafka. It ingests real-time data streams (e.g., server
logs, clickstreams) and routes them to destinations (S3, Redshift, Lambda) for storage or analysis.

---

**Q60. What is AWS EMR, and what does it enable?**
EMR (Elastic MapReduce) is a managed cluster service for running Apache Spark, Hadoop, and other big data frameworks.
Instead of configuring a cluster yourself, you say 'I want a Spark cluster with N nodes' and AWS provisions it for you.

---

**Q61. What is Amazon DynamoDB?**
DynamoDB is AWS's serverless NoSQL key-value database. It scales horizontally with no server management, offers
different consistency modes (eventually consistent or strongly consistent), and integrates natively with other AWS
services.

---

**Q62. What is Amazon Redshift?**
Redshift is AWS's managed data warehouse — a petabyte-scale SQL database optimized for analytics queries. Redshift
Spectrum extends it to query raw data in S3 directly, bridging the gap between a data lake and a structured warehouse.

---

**Q63. What is hybrid cloud, and why might a company use it?**
Hybrid cloud combines on-premises (private) data centers with public cloud providers. It allows elastic scaling using
the cloud while keeping sensitive/regulated data on-premises. A secure bridge connects the two environments.

---

**Q64. What is multi-cloud, and why might it be used?**
Multi-cloud means using more than one public cloud provider (e.g., AWS + Azure). It's a risk management strategy — if
one provider has an outage or account issues, systems on other providers continue running.

---

## 🏗️ Design Patterns

**Q65. What does 'working backwards from the customer' mean in system design?**
Instead of starting with a technology and hoping it meets requirements, you start with the customer experience you need
to deliver, then determine what technologies and architecture are required to achieve it. This is Amazon's core design
philosophy.

---

**Q66. What is the difference between serverless and traditional server architectures?**
With traditional servers, you provision, configure, and maintain specific machines. Serverless (Lambda, Athena,
DynamoDB) abstracts away all server management — you just deploy code or run queries and pay per usage. Serverless
scales automatically.

---

**Q67. What are SLAs (Service Level Agreements), and what does '3-nines' mean?**
SLAs define contractual promises about system performance. '3-nines' = 99.9% availability — means up to 8.76 hours of
downtime per year. '6-nines' = 99.9999% — only ~30 seconds of downtime per year. Higher nines require more redundancy
and cost.

---

**Q68. Why is 99% availability often unacceptable?**
99% availability allows 3.65 days of downtime per year. For customer-facing systems, that is completely unacceptable.
Most production systems target at least 3–4 nines (99.9%–99.99%), requiring thoughtful redundancy in every component.

---

**Q69. What are 'hot', 'cool', and 'cold' storage tiers?**
Hot storage: fastest, most expensive, highly available (e.g., standard S3). Cool storage: slightly slower/cheaper, for
less frequently accessed data. Cold storage: cheapest (e.g., S3 Glacier), for archival — takes hours or days to
retrieve.

---

**Q70. What is partitioning data in a data lake, and why does it matter?**
Organizing data into folder structures based on query patterns (e.g., year/month/day) dramatically speeds up queries by
allowing the system to skip irrelevant partitions. Work backwards from how data will be queried to design the partition
scheme.

---

**Q71. When should you choose simplicity over complexity in a system design?**
Always prefer the simplest solution that meets requirements. Complex distributed systems are expensive to build and
operate. Only add complexity when simpler approaches demonstrably can't scale to the requirements. Simplicity reduces
operational burden.

---

**Q72. What is a forward index vs an inverted index?**
Forward index: maps document IDs → list of keywords in that document. Inverted index: maps keywords → ranked list of
document IDs. You build the forward index first during document processing, then invert it to create the search index.

---

## 🔧 Resiliency

**Q73. What are the levels of failure you need to plan for in large systems?**
Single server failure, rack failure, entire data center failure, entire region failure. Each requires different
redundancy strategies. Servers in a rack can fail together; racks can lose power; data centers can be hit by natural
disasters; regions can have network outages.

---

**Q74. What does it mean to be 'rack aware' in distributed storage?**
Rack awareness means the system intelligently distributes data replicas across different physical racks. If all replicas
of a data block are in the same rack and the rack loses power, all replicas are lost simultaneously. Cross-rack
placement prevents this.

---

**Q75. What is over-provisioning, and why is it necessary for resiliency?**
Over-provisioning means maintaining more server capacity than normal traffic requires. If a region fails and its traffic
reroutes to surviving regions, those regions must have enough excess capacity to absorb the load without degrading.

---

**Q76. What are availability zones, and how do they help?**
Availability zones (used by AWS and other providers) are distinct physical locations within a region with independent
power, cooling, and networking. Spreading servers across availability zones protects against data center-level failures.

---

**Q77. What is a single point of failure (SPOF)?**
A component whose failure would cause the entire system to fail. Examples: a single database host, a single load
balancer, a single config server. In high-availability design, every SPOF must have a backup ready to take over
automatically.

---

**Q78. How does MongoDB handle primary node failure?**
MongoDB replica sets keep secondary nodes ready. When the primary fails, the surviving secondaries automatically elect a
new primary. This takes only seconds but technically means there's brief downtime — which is why CAP classifies it as
giving up Availability.

---

**Q79. What is Cassandra's approach to eliminating single points of failure?**
Cassandra uses a ring architecture where any node can act as the primary entry point. There is no designated master. If
any node fails, requests simply route to other nodes. The trade-off is eventual consistency as data propagates through
the ring.

---

## 🎤 Interview Skills

**Q80. What is the single most important thing to do during a system design interview?**
Think out loud. Don't stay silent while you think. The interviewer wants to see your thought process, not just the final
answer. Talking lets them steer you in the right direction and demonstrates how you approach problems collaboratively.

---

**Q81. What should you do first when given a system design question?**
Repeat the question back, then ask clarifying questions to define requirements: scale (users, traffic, data volume),
latency requirements, availability needs, and budget constraints. Don't start designing until you've aligned on what
you're actually building.

---

**Q82. What is 'behavioral interviewing', and how do you prepare for it?**
Behavioral interviewing asks you to tell stories about past experiences rather than hypothetical scenarios ('Tell me
about a time when...'). Prepare specific stories demonstrating perseverance, initiative, handling conflict, and learning
new technologies independently.

---

**Q83. Why do interviewers value perseverance over technical knowledge?**
Technology changes rapidly — specific knowledge becomes obsolete. The ability to learn new things independently, solve
novel problems, and push through challenges without giving up is rare and far more valuable in the long term.

---

**Q84. What does 'working backwards' look like in a system design interview?**
Start by asking what customer experience you're delivering and at what scale. Define what the API needs to look like
from the client's perspective. Then figure out what infrastructure, databases, and services are needed to power that
API — not the reverse.

---

**Q85. How should you handle feedback or challenges from the interviewer?**
Do NOT get defensive. Acknowledge the concern, incorporate the feedback, and improve your design. Interviewers are
evaluating what it's like to work with you every day. Defensiveness is a major red flag.

---

**Q86. What should you do if you don't know something during the interview?**
Say 'I don't know' honestly — don't fake it. But don't stop there. Ask questions, reason through the problem, show
curiosity and willingness to work toward a solution collaboratively. Admitting ignorance + perseverance is what gets
people hired.

---

**Q87. What notation should you use for system design diagrams?**
There's no universal standard. Simple boxes with labeled arrows works fine. What matters is that you explain what each
component does. If drawing 'database' as a box, clarify that it represents a horizontally scaled distributed system, not
a single host.

---

**Q88. What company values matter in tech interviews (e.g., Amazon)?**
Companies like Amazon publish their values (e.g., 'Leadership Principles'). Study them. Interviewers evaluate you
against these values. Have concrete stories ready that demonstrate each principle (customer obsession, ownership, invent
and simplify, etc.).

---

**Q89. Why should you practice coding at a whiteboard, even before interviews?**
Writing code while someone watches is very different from coding in your IDE. It's stressful and unfamiliar if you've
never done it. Practice with a friend watching you solve problems on a whiteboard to get comfortable before your actual
interviews.

---

## 📊 Big Data & Apache Spark

**Q90. What is Apache Spark, and what problems does it solve?**
Spark is a distributed data processing framework that replaced MapReduce. It's faster (in-memory caching), more
flexible (Python, Scala, SQL, ML), and automatically optimizes parallel execution across a cluster using a DAG. Used for
batch and streaming analytics.

---

**Q91. What is Spark's main advantage over MapReduce?**
Spark allows you to write SQL or high-level Python/Scala code, which it automatically translates into optimized parallel
operations. MapReduce required manual low-level map/reduce logic. Spark claims up to 100× faster performance via
in-memory processing.

---

**Q92. What is Spark Streaming / Structured Streaming?**
Spark Streaming processes real-time data as a continuously arriving stream. It integrates with Kafka, Kinesis, and other
sources, and continuously applies transformations and writes results to destinations — enabling real-time analytics
pipelines.

---

**Q93. What is MLLib in Spark?**
MLLib is Spark's built-in machine learning library. It includes classification, regression, clustering, and
collaborative filtering algorithms that are automatically distributed across a Spark cluster — enabling ML on datasets
too large for a single machine.

---

**Q94. What is the driver program and executor in Spark's architecture?**
The driver program contains your code (what to process and how). It communicates with the cluster manager, which
distributes work to executor processes running on individual cluster nodes. Each executor runs tasks on its assigned
data partition.

---

**Q95. What is Spark NOT suitable for?**
OLTP (Online Transaction Processing) — real-time, low-latency, user-facing queries. Spark is a batch/streaming analytics
tool, not a database you expose directly to end users. Output from Spark should go into a proper database for
user-facing queries.

---

## 🤖 Generative AI & RAG

**Q96. What is Retrieval-Augmented Generation (RAG), and what problem does it solve?**
RAG gives LLMs access to external, up-to-date data at query time by retrieving relevant documents and injecting them
into the prompt as context. This reduces hallucinations, reduces token costs (vs. injecting all data), and avoids
retraining when data changes.

---

**Q97. What is an embedding vector?**
An embedding is a high-dimensional vector representation of text that captures semantic meaning. Texts with similar
meanings have embeddings that are close to each other in this high-dimensional space — enabling semantic (meaning-based)
search rather than keyword matching.

---

**Q98. What is a vector database, and why is it used in RAG systems?**
A vector database stores text data alongside its embedding vectors, enabling fast semantic search (find the most similar
embeddings to a query vector). Examples: Pinecone, Weaviate, Chroma. Most regular databases (Elasticsearch, PostgreSQL,
Redis) now also support vector search.

---

**Q99. What is an 'agentic AI' or 'LLM Agent'?**
An agentic AI is an LLM that can access external tools (APIs, databases, browsers) to answer questions. The LLM decides
autonomously which tool to call based on the query, calls it, receives the result, and integrates it into its response.

---

**Q100. What is the Model Context Protocol (MCP)?**
MCP is a standard developed by Anthropic for connecting tools to AI agents. It defines how to describe a tool's
capabilities, inputs, and outputs in a standard way, making it easier to build interoperable AI agent systems.

---

**Q101. What is fine-tuning an LLM?**
Fine-tuning continues training a base model on your own domain-specific data (prompt + ideal response pairs). It adapts
the model's behavior to your use case. More expensive than RAG but embeds knowledge directly into the model weights.

---

**Q102. What does 'context window' mean for LLMs, and how can it be used architecturally?**
The context window is the maximum amount of text an LLM can process in a single request. You can inject domain data
directly into the prompt context (as an alternative to RAG), but this gets expensive since you're billed per token for
all that injected text.

---

**Q103. How should AI systems be integrated into larger architectures?**
The AI subsystem is just one component in a larger system. It should sit behind a load balancer and fleet of application
servers. Add a caching layer (responses can be expensive and repeated queries can be cached). Don't expose API
credentials directly to end users.

---

*Total: 103 questions across 10 categories.*
