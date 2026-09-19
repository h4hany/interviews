# Relational Databases on AWS

## 1. Amazon RDS (Relational Database Service)

A managed service that makes it easy to set up, operate, and scale a relational database in the cloud.

### High Availability: Multi-AZ
*   **How it works:** AWS synchronously replicates the data to a standby instance in a different Availability Zone (AZ).
*   **Failover:** If the primary DB instance fails (hardware failure, storage failure, AZ outage), RDS automatically promotes the standby to primary. The DNS endpoint remains the same, but it points to the new primary's IP address.
*   **Use case:** Mandatory for production environments to ensure High Availability (HA) and Disaster Recovery (DR) within a region.

### Scaling: Read Replicas
*   **How it works:** Uses PostgreSQL's native asynchronous replication to create one or more read-only copies of your database.
*   **Use case:** Offloading read traffic (e.g., heavy BI reporting, analytical queries) from the primary database to improve write performance.
*   **Multi-Region:** Read Replicas can be created in a different AWS Region for cross-region DR or serving read traffic closer to global users.

### Storage Types
*   **General Purpose SSD (gp2/gp3):** Cost-effective storage acceptable for most workloads. Performance is linked to volume size in gp2, decoupled in gp3.
*   **Provisioned IOPS SSD (io1/io2):** Designed for high-performance, I/O-intensive workloads (e.g., OLTP systems) requiring consistent, low-latency performance. You specify the exact IOPS you need.

### Backups and Recovery
*   **Automated Backups:** Daily full snapshots + continuous transaction log backups.
*   **Point-in-Time Recovery (PITR):** You can restore a database to any specific second during your retention period (up to 35 days). This creates a *new* DB instance; it does not overwrite the existing one.

## 2. Amazon Aurora PostgreSQL

A MySQL and PostgreSQL-compatible relational database built specifically for the cloud.

### Architecture Difference from RDS
*   Instead of standard EBS volumes, Aurora uses a distributed, fault-tolerant, self-healing storage system that auto-scales up to 128TB.
*   Data is replicated 6 ways across 3 AZs automatically (even without compute replicas).
*   **Performance:** Generally faster than standard RDS due to its log-structured storage engine optimized for cloud networks.

### Features
*   **Aurora Replicas:** Up to 15 replicas (RDS supports 5). Replicas share the same underlying storage as the primary, meaning replication lag is typically in milliseconds.
*   **Aurora Serverless (v2):** Scales compute capacity automatically based on load. Perfect for unpredictable or spiky workloads.

## 3. Amazon RDS Proxy

A fully managed, highly available database proxy for RDS.

*   **Why use it:** Lambda functions (and other serverless compute) can quickly exhaust database connections because each concurrent execution might open a new connection.
*   **How it works:** RDS Proxy establishes a pool of database connections and multiplexes application connections across that pool. It also improves failover times by automatically connecting to the new primary instance during a Multi-AZ failover without relying on DNS propagation.

## 4. Monitoring & Maintenance

*   **Performance Insights:** A database performance tuning tool. It helps you identify database bottlenecks by visualizing load across active sessions, SQL queries, waits, and hosts.
*   **Maintenance Windows:** A weekly 30-minute block you define where AWS can apply pending modifications or software patches. *Note: Multi-AZ configurations minimize downtime during patching by patching the standby first, failing over, and then patching the old primary.*
*   **Major Version Upgrades:** Requires manual initiation. Often involves downtime. It's recommended to test the upgrade on a snapshot restore first.

## 5. Interview Questions

**Q: Your RDS PostgreSQL database is hitting 100% CPU utilization during reporting hours. How do you architect a solution?**
A: I would deploy an RDS Read Replica. I would then configure our reporting application to point to the Read Replica's endpoint instead of the primary DB. This offloads the heavy read queries, freeing up the primary DB's CPU for transactional writes.

**Q: You are migrating a 5TB on-premises PostgreSQL database to AWS with near-zero downtime. Describe your strategy.**
A: I would use AWS Database Migration Service (DMS). First, I'd provision an Aurora PostgreSQL cluster as the target. Using DMS, I'd set up a Full Load + Change Data Capture (CDC) task. DMS will perform the initial bulk load while capturing ongoing transactions. Once the initial load is complete and the CDC is in sync (replication lag is near zero), we can schedule a cutover window. During cutover, we stop writes to the on-prem DB, wait for DMS to flush the final changes, update DNS/app configs to point to Aurora, and turn on the application.
