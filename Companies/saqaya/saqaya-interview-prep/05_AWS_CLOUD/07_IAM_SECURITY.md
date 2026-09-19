# Identity, Security, and Governance

## 1. AWS IAM (Identity and Access Management)

IAM controls who can do what in your AWS environment.

### Core Components
*   **Users & Groups:** Long-term credentials (passwords, access keys). *Best practice:* Avoid IAM Users for human access; use AWS SSO (IAM Identity Center) instead.
*   **Roles:** Temporary credentials assumed by AWS services (EC2, Lambda) or federated users.
*   **Policies:** JSON documents that define permissions (Allow/Deny, Actions, Resources, Conditions).
*   **Trust Relationships (AssumeRole Policy):** Defines *who* or *what* is allowed to assume a role.

### Advanced IAM Concepts
*   **Permission Boundaries:** An advanced feature for delegating IAM management. It sets the *maximum* permissions that an identity-based policy can grant to an IAM entity. It does not grant permissions itself.
*   **Cross-Account Access:** Allowing a role in Account A to access resources in Account B. Requires two things: Account B must trust Account A (Trust Policy on a role in B), and Account A must allow its identity to assume the role in B (Identity Policy in A).

### IAM Evaluation Logic
1.  **Deny always wins.** An explicit deny in any policy (SCP, identity, resource) overrides any allows.
2.  **Default is Deny.** Unless explicitly allowed, actions are denied.
3.  **SCPs -> Resource Policies -> IAM Boundaries -> Session Policies -> Identity Policies.** All applicable layers are evaluated.

## 2. Data Protection

### AWS KMS (Key Management Service)
*   Managed service to create and control cryptographic keys.
*   **Symmetric vs Asymmetric:** Mostly symmetric (AES-256) for data at rest.
*   **Customer Managed Keys (CMK) vs AWS Managed Keys:** CMKs allow you to manage rotation policies and define precise access controls via Key Policies.
*   **Envelope Encryption:** KMS encrypts the plain-text Data Key, generating an encrypted Data Key. Only the encrypted Data Key is stored alongside the cipher text.

### AWS Secrets Manager
*   Securely stores, rotates, and manages credentials (database passwords, API keys).
*   Integrates natively with RDS for automatic password rotation without application downtime.
*   *Alternative:* Systems Manager Parameter Store (SSM). SSM is cheaper/free for standard parameters, but lacks native automatic rotation and cross-account capabilities of Secrets Manager.

## 3. Threat Detection and Edge Protection

*   **AWS WAF (Web Application Firewall):** Protects web apps from common exploits (SQL injection, XSS) and bots. Attaches to ALB, API Gateway, or CloudFront.
*   **AWS Shield:** Managed DDoS protection. Standard is free; Advanced offers higher capacities and cost protection against massive Layer 3/4 attacks.
*   **Amazon GuardDuty:** Intelligent threat detection. Uses machine learning to analyze CloudTrail, VPC Flow Logs, and DNS logs to identify malicious activity (e.g., crypto-mining on EC2, compromised credentials).
*   **AWS Security Hub:** Aggregates security alerts from GuardDuty, Macie, Inspector, and third-party tools into a single pane of glass and checks environments against security standards (CIS benchmarks).

## 4. Interview Questions

**Q: Explain the concept of "Least Privilege" and how you enforce it in AWS.**
A: Least privilege means granting an entity only the permissions strictly required to perform its task, and nothing more. In AWS, I enforce this by writing highly specific IAM JSON policies. Instead of using AWS managed policies like `AmazonS3FullAccess`, I write custom policies that allow specific actions (e.g., `s3:PutObject`, `s3:GetObject`) only on specific ARNs (e.g., `arn:aws:s3:::my-app-bucket/*`). For developers, I use IAM Identity Center with short-lived sessions and Permission Boundaries to ensure they can't escalate their own privileges.

**Q: Your application running on EC2 needs to access an S3 bucket in a different AWS account. How do you configure this securely?**
A: I would use a cross-account IAM Role. In the target account (where the S3 bucket lives), I create an IAM Role with a policy granting access to the S3 bucket. I configure the role's Trust Policy to allow the source account ID to `sts:AssumeRole`. In the source account, I attach an IAM policy to the EC2 instance profile granting it permission to assume the role in the target account. The application code on EC2 then uses the AWS SDK to assume the role and retrieve temporary credentials to access the bucket.

**Q: You found hardcoded database credentials in a configuration file committed to Git. How do you resolve this permanently using AWS?**
A: First, I would immediately rotate the compromised database credentials. Next, I would remove the credentials from the codebase. I would create a secret in AWS Secrets Manager to store the new database username and password. I would configure the application's IAM execution role (e.g., ECS task role or EC2 instance profile) with a policy allowing `secretsmanager:GetSecretValue` for that specific secret ARN. Finally, I would update the application code to fetch the credentials dynamically from Secrets Manager at startup or request time, ensuring secrets are never in plain text again.
