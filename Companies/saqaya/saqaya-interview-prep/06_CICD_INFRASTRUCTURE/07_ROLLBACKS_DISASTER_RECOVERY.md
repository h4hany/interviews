# Rollbacks and Disaster Recovery

## Application Rollback Strategies
Rolling back stateless applications is relatively easy.
- **Container Orchestration (ECS/K8s):** Update the service to point to the previous Docker image tag (e.g., rollback from `v1.2` to `v1.1`).
- **GitOps:** Revert the commit in the infrastructure repository, and the CD agent (ArgoCD) will sync the cluster back to the previous state.
- **Blue-Green:** Flip the load balancer rules back to the Blue environment.

## Disaster Recovery Planning
Planning for catastrophic failure (region outage, ransomware, dropped database).

### Key Metrics
- **RPO (Recovery Point Objective):** Maximum acceptable data loss. (e.g., "We can lose up to 5 minutes of data" dictates backup frequency).
- **RTO (Recovery Time Objective):** Maximum acceptable downtime. (e.g., "We must be back online in 1 hour" dictates backup architecture—tape backups won't cut it).

### Multi-Region Failover (Active-Passive)
- Primary region handles all traffic (e.g., `eu-west-1`).
- Standby region (e.g., `eu-central-1`) runs minimal infrastructure.
- Database uses cross-region read replicas.
- If primary goes down, promote the standby DB to primary, scale up the app tier, and update Route53 DNS to point to the standby region.

## Backup Strategies
1. **Full Backups:** Complete copy of data (slow, large).
2. **Incremental Backups:** Only backup data changed since the *last* backup (fast, smaller).
3. **Point-in-Time Recovery (PITR):** AWS RDS uses continuous archiving of transaction logs (WAL in Postgres) combined with daily snapshots to allow restoring the database to any specific second in the last 35 days.

## Chaos Engineering
Testing DR by intentionally breaking things in production (or staging).
- **Netflix Chaos Monkey:** Randomly terminates EC2 instances to ensure the system is resilient.
- **Game Days:** Scheduled exercises where the team simulates a disaster (e.g., killing the master DB) and practices the recovery runbook.

## Incident Response (During a Rollback/Outage)
1. **Acknowledge & Escalate:** PagerDuty alerts on-call. Create a central communication channel (Slack `#incident-123`).
2. **Mitigate:** Stop the bleeding. Rollback, block bad IPs, etc. (Do not try to fix the root cause immediately if mitigation is faster).
3. **Resolve:** Find and fix the root cause.
4. **Post-Mortem:** Blameless review of what happened. Focus on system failures, not human error. Create action items (Jira tickets) to prevent recurrence.

## Interview Questions
**Q: A developer accidentally drops the production users table. How do you recover?**
A: Rely on AWS RDS Point-in-Time Recovery (PITR). I would initiate a restore to a new database instance specifying the timestamp 1 minute before the drop command was executed. Once the new instance is up, I would update the application's connection string to point to the new DB. (Note: Restoring takes time proportional to the DB size, so RTO will be impacted).

**Q: What is a "Blameless Post-Mortem" and why is it important?**
A: It's an incident review process that assumes everyone involved had good intentions and made the best decisions they could with the information they had. Instead of asking "Why did John break the build?", we ask "Why did the pipeline allow John to break the build?". It fosters a culture of psychological safety, encouraging engineers to report issues early without fear of punishment, leading to stronger, more resilient systems.
