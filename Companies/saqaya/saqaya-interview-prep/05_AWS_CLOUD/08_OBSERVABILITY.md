# Observability and Monitoring on AWS

## 1. Amazon CloudWatch

The central hub for monitoring and management in AWS.

### Core Features
*   **Metrics:** Time-ordered data points. AWS services emit default metrics (e.g., EC2 CPU utilization). You can publish Custom Metrics via the API or CloudWatch Agent.
*   **Logs:** Centralized log aggregation.
    *   *Log Groups:* Logical grouping of logs (e.g., `/aws/lambda/my-function`).
    *   *Log Streams:* Sequence of events from a specific source (e.g., a specific container instance).
*   **Alarms:** Watches a single metric and performs an action (e.g., send an SNS notification, trigger Auto Scaling) if the metric crosses a threshold over a specific time period.
*   **CloudWatch Logs Insights:** A powerful, purpose-built query language to search and analyze log data interactively. Crucial for debugging production incidents.
*   **Contributor Insights:** Analyzes high-cardinality data to find top talkers (e.g., identifying the specific IP addresses generating the most 5xx errors on an API Gateway).

## 2. AWS CloudTrail

Governance, compliance, and operational auditing.

*   **What it does:** Records every API call made in your AWS account (via console, CLI, SDKs, or other AWS services).
*   **Use Case:** Answering "Who did what, when, and from where?" Essential for security investigations.
*   **Trails:** Deliver log files to an S3 bucket for long-term retention and analysis via Athena.

## 3. AWS X-Ray (Distributed Tracing)

Helps developers analyze and debug distributed applications, such as those built using a microservices architecture.

*   **How it works:** You instrument your application using the X-Ray SDK. It adds a "trace ID" to HTTP requests that propagates through your system.
*   **Features:** Provides a Service Map showing the relationships between services and highlights bottlenecks, latency, and failure rates (HTTP 4xx/5xx).

## 4. Third-Party Tooling Ecosystem

While CloudWatch is native, many enterprises use third-party tools for superior UI, cross-cloud capabilities, and advanced analytics.

*   **Datadog:** Comprehensive APM, infrastructure monitoring, and log management. Highly integrated with AWS.
*   **New Relic:** Strong APM capabilities.
*   **Prometheus / Grafana:** Popular open-source stack, especially in EKS/Kubernetes environments. AWS offers managed versions (AMP/AMG).

## 5. Best Practices for Observability

*   **Structured Logging:** Always log in JSON format. It allows tools like CloudWatch Logs Insights or Datadog to parse log fields as queryable attributes.
*   **Metric Design (RED Method):** For request-driven services, monitor:
    *   *Rate:* Requests per second.
    *   *Errors:* Number of failed requests.
    *   *Duration:* Request latency (percentiles: p90, p99, rather than averages).
*   **Actionable Alerts:** Don't alert on CPU utilization unless it impacts users. Alert on user-facing symptoms (e.g., elevated error rates, high latency).
*   **Runbooks:** Every alert must have a linked runbook explaining what the alert means and the steps an on-call engineer should take to mitigate it.

## 6. Interview Questions

**Q: A critical microservice is experiencing intermittent high latency. Walk me through how you would use AWS tools to debug this in production.**
A: 
1. I'd start with **CloudWatch Dashboards** to identify when the latency spikes started and check system-level metrics (CPU, Memory, Network I/O) on the compute layer (ECS/EC2).
2. If system metrics look normal, I would look at **X-Ray traces** to see the service map. This will show me exactly which downstream dependency (e.g., a specific database query, an external API, or another microservice) is causing the delay.
3. Once I pinpoint the failing component, I would use **CloudWatch Logs Insights** to query the structured application logs around the specific timestamp, filtering for `level=error` or high execution times to find the specific code path failing.

**Q: What is the difference between CloudWatch and CloudTrail?**
A: CloudWatch is for performance monitoring and operational logging of your *applications and infrastructure* (e.g., CPU usage, application logs, memory). CloudTrail is for security auditing and governance of your *AWS account itself*; it records API calls (e.g., who deleted an S3 bucket, who modified a security group).

**Q: You want to ensure that no developer can launch an EC2 instance without an "Environment" tag. How do you enforce and monitor this?**
A: I would enforce this proactively using an IAM Policy or Service Control Policy (SCP) containing a condition that requires the `aws:RequestTag/Environment` key during the `ec2:RunInstances` action. To monitor and remediate retroactively, I would use AWS Config. I would deploy an AWS Config Rule (using the managed rule `required-tags`) that flags any EC2 instance missing the tag as non-compliant, and optionally trigger a Systems Manager Automation document to terminate the non-compliant resource.
