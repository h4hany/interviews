# AWS Cost Optimization

## 1. Cloud Financial Management Tools

*   **AWS Cost Explorer:** Visualize, understand, and manage AWS costs and usage over time. Allows filtering by service, region, and tags.
*   **AWS Budgets:** Set custom budgets that alert you when costs or usage exceed (or are forecasted to exceed) your budgeted amount. Alerts can trigger SNS topics or execute automated actions (e.g., stopping EC2 instances).
*   **AWS Trusted Advisor:** Provides real-time guidance to help provision resources following AWS best practices, including a dedicated "Cost Optimization" pillar (e.g., flagging unassociated Elastic IPs, idle RDS instances).
*   **Cost Allocation Tags:** Essential for tracking costs by department, project, or environment (e.g., `Environment: Prod`, `Team: Backend`). These tags appear in the billing console for precise cost attribution.

## 2. Compute Cost Optimization

### Purchasing Models
*   **On-Demand:** Default, most expensive.
*   **Reserved Instances (RIs):** Commit to a specific instance family and region for 1 or 3 years.
*   **Compute Savings Plans:** More flexible than RIs. You commit to a specific *dollar amount* per hour (e.g., $10/hour) for 1 or 3 years. It automatically applies across any EC2 instance family, region, and even Fargate and Lambda. *Highly recommended over RIs for modern workloads.*
*   **Spot Instances:** Up to 90% discount. Use for stateless, fault-tolerant workloads (batch processing, CI/CD, background workers).

### Right-Sizing
Using AWS Compute Optimizer (which uses Machine Learning) to analyze historical utilization metrics and recommend optimal EC2, EBS, and ECS configurations. Downgrading an oversized instance (e.g., `m5.2xlarge` -> `m5.large`) yields immediate savings.

## 3. Storage Cost Optimization (S3 & EBS)

### Amazon S3
*   **Lifecycle Policies:** The single biggest money-saver in S3. Automatically transition older logs or backups to Standard-IA after 30 days, and to Glacier Deep Archive after 90 days.
*   **S3 Intelligent-Tiering:** If access patterns are unpredictable, enable this. AWS automatically moves data to the most cost-effective tier without retrieval fees.
*   **Delete Incomplete Multipart Uploads:** Create a lifecycle rule to abort incomplete multipart uploads after X days. Otherwise, partial uploads consume storage and incur costs invisibly.

### Amazon EBS (Elastic Block Store)
*   **Delete Unattached Volumes:** When an EC2 instance is terminated, the EBS volume might persist if not configured to delete on termination.
*   **Snapshot Lifecycles:** Use Amazon Data Lifecycle Manager (DLM) to automatically clean up old EBS snapshots.
*   **Upgrade to gp3:** `gp3` volumes are up to 20% cheaper than `gp2` and allow provisioning IOPS independent of storage capacity. Always migrate gp2 to gp3.

## 4. Network and Data Transfer Costs

Data transfer *into* AWS is free. Data transfer *out* to the internet or across regions/AZs costs money.

*   **Cross-AZ Traffic:** Chatty microservices spread across AZs incur charges. Optimize by keeping tightly coupled services in the same AZ where possible (balancing against High Availability requirements).
*   **NAT Gateways:** NAT Gateways charge an hourly fee AND a per-GB data processing fee.
    *   *Optimization:* Use VPC Gateway Endpoints for S3 and DynamoDB to route traffic over the AWS backbone for free, bypassing the NAT Gateway.
*   **CloudFront:** Data transfer out from CloudFront to the internet is cheaper than from EC2/ALB to the internet. Cache aggressively.

## 5. Database Cost Optimization

*   **Instance Sizing:** Databases are usually the most expensive component. Right-size instances based on Performance Insights.
*   **RDS Stop/Start:** For Dev/QA environments, script a Lambda function to stop RDS instances on Friday evening and start them on Monday morning.
*   **Aurora Serverless v2:** For databases with unpredictable or spiky workloads, Aurora Serverless scales down during quiet periods, saving costs compared to provisioned capacity.

## 6. Interview Questions

**Q: You just took over as Tech Lead. The AWS bill is very high, and management wants it reduced by 20% in the next month. What are the first 3 things you look at?**
A: 
1. **Unused Resources:** I'd use Trusted Advisor and custom scripts to find and delete unattached EBS volumes, unassociated Elastic IPs, orphaned snapshots, and idle RDS/EC2 instances (especially in Dev/QA environments).
2. **Storage Tiering:** I would review S3 buckets. If there are buckets holding terabytes of logs or backups without Lifecycle Policies, I would immediately implement rules to transition them to Glacier Deep Archive or Intelligent-Tiering. I'd also ensure we are using `gp3` EBS volumes instead of `gp2`.
3. **Compute Savings Plans:** I'd analyze our steady-state compute usage in Cost Explorer. If we have consistent baseline usage across EC2/ECS without commitments, I would recommend purchasing a 1-year Compute Savings Plan to instantly reduce the baseline compute cost by up to 50%.

**Q: We have a heavily utilized internal analytics application running on EC2 in a private subnet. It downloads massive datasets from S3 daily. Our NAT Gateway costs are skyrocketing. How do you fix this?**
A: The high cost is due to the NAT Gateway data processing fees, which charge per GB transferred. Because S3 is an AWS service, we do not need to route this traffic through the public internet via NAT. I would create an S3 VPC Gateway Endpoint and associate it with the private subnet's route table. This routes the S3 traffic over the internal AWS network, entirely bypassing the NAT Gateway. S3 Gateway Endpoints are completely free, so this will drop the NAT Gateway data processing costs for this workflow to zero.
