# AWS Fundamentals for Technical Leads

## 1. AWS Global Infrastructure

### What it is
AWS's physical infrastructure is divided globally into Regions, Availability Zones (AZs), Local Zones, and Edge Locations.

*   **Regions:** A physical location around the world where AWS clusters data centers. Regions are isolated from one another.
*   **Availability Zones (AZs):** One or more discrete data centers within a region with redundant power, networking, and connectivity. They are connected via high-bandwidth, low-latency networking.
*   **Edge Locations:** Part of the CloudFront (CDN) network to cache content closer to users to reduce latency.

### Why & How it works
*   **High Availability (HA):** Deploying across multiple AZs ensures that if a data center goes down (due to power failure, natural disaster), the application remains available.
*   **Low Latency:** Choosing a region close to users decreases network latency.
*   **Data Sovereignty:** Keeping data in specific regions to comply with local laws (e.g., GDPR).

### Production Behavior & Failure Modes
*   **AZ Failures:** AZ failures are rare but happen. Applications must be designed to tolerate AZ loss without downtime (e.g., using multi-AZ RDS, Auto Scaling Groups across AZs).
*   **Region Failures:** Even rarer. Requires disaster recovery strategies like active-active multi-region or pilot light across regions using Route 53 routing.

### Interview Questions
**Q: How do you design an application to withstand an entire AZ failure?**
A: Deploy compute resources in an Auto Scaling Group spanning at least two AZs. Place an Application Load Balancer in front of them, also configured for multiple AZs. Use a managed database like RDS configured for Multi-AZ, which maintains a synchronous standby replica in another AZ and handles automatic failover.

## 2. AWS Organizations and Account Structure

### What it is
AWS Organizations provides central governance and management across multiple AWS accounts.

### Deep Dive: Multi-Account Strategy
Instead of putting all workloads in a single account, production setups use multiple accounts.

*   **Management Account:** Used only for billing and organization management. No workloads.
*   **Security Account:** Centralizes CloudTrail logs, GuardDuty, and cross-account IAM roles for security audits.
*   **Shared Services Account:** Centralized CI/CD pipelines, golden AMIs, DNS.
*   **Workload Accounts (Dev, Staging, Prod):** Separate accounts for different environments to ensure strict isolation.

### Service Control Policies (SCPs)
SCPs are JSON policies that specify the maximum available permissions for an organization, organizational unit (OU), or account.
*   *Example Use Case:* Prevent any account from leaving the organization, or restrict regions where resources can be deployed to ensure compliance.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RequireMicroEC2InstanceType",
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringNotEquals": {
          "ec2:InstanceType": "t2.micro"
        }
      }
    }
  ]
}
```

## 3. AWS Well-Architected Framework

A set of best practices for designing and operating reliable, secure, efficient, and cost-effective systems in the cloud.

1.  **Operational Excellence:** Running and monitoring systems to deliver business value. (Use Infrastructure as Code, observability).
2.  **Security:** Protecting information and systems. (IAM least privilege, encryption at rest and in transit).
3.  **Reliability:** Ability of a system to recover from failures and mitigate disruptions. (Multi-AZ, decoupling components).
4.  **Performance Efficiency:** Using compute resources efficiently. (Right-sizing, serverless, autoscaling).
5.  **Cost Optimization:** Avoiding unnecessary costs. (Reserved instances, spot instances, lifecycle policies).
6.  **Sustainability:** Minimizing the environmental impacts of running cloud workloads.

## 4. Shared Responsibility Model

Security *of* the cloud vs Security *in* the cloud.

*   **AWS Responsibility (Security OF the cloud):** Physical security of data centers, hardware, hypervisors, network infrastructure.
*   **Customer Responsibility (Security IN the cloud):** OS patching (for EC2), IAM configuration, network security groups, data encryption, application security.
*   *Nuance:* For managed services like S3 or RDS, AWS handles the OS and patching, but the customer still handles access control (IAM/Bucket policies) and data classification/encryption configurations.

## 5. Pricing Model

*   **Compute:** Pay for what you use (per second/hour).
*   **Storage:** Pay per GB/month.
*   **Data Transfer:** Data transfer *INTO* AWS is generally free. Data transfer *OUT* of AWS (to the internet) is charged. Data transfer *BETWEEN* AZs and regions incurs costs.

### Interview Questions
**Q: You noticed a spike in AWS data transfer costs. Where would you look to optimize this?**
A: I'd use AWS Cost Explorer to identify the service causing the spike. Common culprits are cross-AZ data transfer (e.g., EC2 instances in AZ-a talking heavily to RDS in AZ-b) or large volumes of data leaving AWS to the internet via an ALB or NAT Gateway. Optimizations include keeping traffic within the same AZ when possible, using VPC endpoints (PrivateLink) instead of NAT Gateways for AWS services (like S3), and using CloudFront to cache outbound traffic.
