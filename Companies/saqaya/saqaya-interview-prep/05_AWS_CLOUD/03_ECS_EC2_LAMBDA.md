# Compute on AWS: EC2, ECS, and Lambda

## 1. Amazon EC2 (Elastic Compute Cloud)

### Instance Purchasing Options
*   **On-Demand:** Pay by the second. Use for short-term, spiky, or unpredictable workloads.
*   **Reserved Instances (RI) / Savings Plans:** 1 or 3-year commitment for massive discounts (up to 72%). Use for steady-state usage.
*   **Spot Instances:** Bidding on spare AWS capacity. Up to 90% off, but AWS can reclaim the instance with a 2-minute warning.
    *   *Production use:* CI/CD runners, batch processing, background workers, stateless web tiers via Auto Scaling Groups configured with mixed instances policies.

### Placement Groups
Control how instances are placed on physical underlying hardware.
*   **Cluster:** Packs instances close together inside an AZ for low-latency network performance (e.g., HPC, big data).
*   **Spread:** Strictly places instances on distinct underlying hardware/racks to reduce correlated failures (e.g., critical Cassandra nodes).
*   **Partition:** Spreads instances across logical partitions (racks) within an AZ. Good for HDFS, Kafka.

## 2. Amazon ECS (Elastic Container Service)

A highly scalable, fast container management service.

### Launch Types
1.  **EC2 Launch Type:** You manage a cluster of EC2 instances. ECS schedules containers onto them. You handle patching, scaling the EC2 instances, and AMI updates.
2.  **AWS Fargate:** Serverless compute for containers. You don't manage any underlying EC2 instances. You specify CPU/Memory for the container, and AWS runs it.

### ECS Concepts
*   **Task Definition:** A JSON blueprint for your application (Docker image, CPU/RAM, IAM roles, env vars).
*   **Task:** A running instance of a Task Definition.
*   **Service:** Ensures a specified number of Tasks are running constantly, handles registering tasks with a Load Balancer, and manages deployments (rolling updates).

### ECS Service Discovery
ECS integrates with AWS Cloud Map. It allows microservices to discover each other via DNS or API calls using friendly names instead of IP addresses.

### Terraform Example: ECS Fargate Service
```hcl
resource "aws_ecs_task_definition" "app" {
  family                   = "my-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "app-container"
    image     = "nginx:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}
```

## 3. Amazon EKS (Elastic Kubernetes Service)
Managed Kubernetes. Use EKS when you already have Kubernetes expertise, need cloud-agnostic tooling, or require the extensive K8s ecosystem (Helm, Istio). EKS is more complex to manage than ECS but offers more flexibility.

## 4. AWS Lambda

Serverless, event-driven compute.

### Deep Dive: Cold Starts
*   **What:** The delay in executing a function when it is invoked for the first time or after a period of inactivity. AWS has to download your code, start an execution environment, and run initialization code.
*   **Mitigation:**
    *   Use Provisioned Concurrency (keeps environments pre-warmed).
    *   Optimize initialization code (lazy load dependencies).
    *   Choose languages with fast startup times (Go, Rust, Node.js > Java, C#).

### Concurrency and Scaling
*   Lambda scales automatically based on incoming events.
*   **Reserved Concurrency:** Guarantees a specific number of instances are available for a function, AND caps the maximum scale so it doesn't consume all account-level concurrency.

### Event Source Mapping (ESM)
Lambda reads events from services like SQS, Kinesis, or DynamoDB Streams. The ESM polls the service and invokes your function synchronously with a batch of records.
*   *Failure Mode:* If processing a batch fails, the ESM will retry until it succeeds or data expires, potentially blocking the shard/queue. Use DLQs or BisectBatchOnFunctionError.

## 5. Comparison: When to use which?

| Use Case | Recommended Compute | Why? |
| :--- | :--- | :--- |
| Event-driven, glue logic, API backends with variable traffic | **Lambda** | Pay per invocation, zero maintenance, scales instantly. |
| Containerized microservices, steady traffic, lower ops overhead | **ECS with Fargate** | Don't want to manage servers, predictable pricing compared to Lambda at very high volume. |
| Complex distributed systems, multi-cloud strategy, extensive ecosystem | **EKS** | K8s standard, complex orchestration, service mesh. |
| Legacy apps, specific OS kernels, specific GPU requirements | **EC2** | Maximum control, lift-and-shift. |

## 6. Interview Questions

**Q: Your team is running a monolithic application on EC2. You want to move to microservices using Docker. Would you choose ECS or EKS, and why?**
A: If the team has no prior Kubernetes experience and the workload is purely on AWS, I would strongly advocate for ECS with Fargate. ECS integrates seamlessly with ALB, IAM, and CloudWatch out of the box, offering a much lower learning curve and operational burden. If the company strategy involves multi-cloud deployments or requires advanced K8s extensions, I would choose EKS, acknowledging the need to train the team and maintain the cluster upgrades.

**Q: We have a Lambda function processing messages from an SQS queue. Under heavy load, the downstream database connection is getting overwhelmed and timing out. How do you fix this?**
A: First, I would set a Reserved Concurrency limit on the Lambda function to throttle its scale-out, acting as a bulkhead to protect the database. Second, I would configure the Lambda function to use RDS Proxy, which pools and shares database connections efficiently. Finally, I'd review the batch size on the Event Source Mapping to ensure we are processing records efficiently.
