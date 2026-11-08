# AWS Deployment Plan — HelpWise

One region (pick whichever is closest — e.g. `ap-southeast-1` Singapore), one EC2 instance, one
database-equivalent (MongoDB in a container on the instance, since LibreChat's default stack uses
MongoDB — no RDS needed for this project unless we add a relational piece later), one S3 bucket.
No multi-account, no Kubernetes, no fine-tuning — per the brief's "practical limits" (Section 1.3).

## Order of operations (do not skip the budget alert)

1. **AWS Budgets alert** (Section 6.2 — "set an AWS Budgets alert on day one"). See `budget-plan.md`.
2. **IAM user for daily work** (never use root) — console + programmatic access, policy in
   `iam-policy-student-ops.json`. Enable MFA on this user (WS-D #1).
3. **S3 bucket** — holds the 6 invented IT-helpdesk KB documents. Versioning on (WS-C #3).
4. **Systems Manager Parameter Store** — `GOOGLE_KEY`, `JWT_SECRET`, `CREDS_KEY`, etc. as
   SecureString parameters, never in code (WS-D #3).
5. **EC2 instance** (Ubuntu 22.04/24.04 LTS, t3.micro or t3.small — small is plenty per brief).
   Security group: 22 (SSH, restricted to my IP), 80 + 443 (public, for the app).
   User-data script: `ec2-user-data.sh` — installs Docker, pulls this repo + LibreChat, reads
   secrets from Parameter Store, brings up the stack.
6. **HTTPS** — either ACM + an Application Load Balancer, or simpler: Caddy/nginx with Let's
   Encrypt on the instance itself pointed at a domain, or CloudFront in front of the instance.
   Start simple: Caddy reverse-proxying to the LibreChat container on port 3080, auto-TLS via
   Let's Encrypt, given we have (or will register) a domain name or use a dynamic-DNS-style
   subdomain. (Decision recorded once we pick a domain — see Section WS-A #3 in the main brief.)
7. **CloudWatch** dashboard + 6 alarms + SNS email subscription (WS-B) — Week 2–3.
8. **IAM/CloudTrail hardening, backups, automations, fault injection** — Weeks 3–4, per the main
   project plan in the top-level README.

## Cost guardrail
- Budget: track actual AWS spend in `budget-plan.md`, alert at the thresholds set there.
- Everything is tagged `Project=SAM10`, `Owner=mark-santos` for traceability (Section 6.2).
- Shut down (not just stop paying attention to) anything not actively being used/graded, and
  before end of term per Section 6.2.
