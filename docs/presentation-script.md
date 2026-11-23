# HelpWise: SAM10 Final Project Presentation Script

Target length: about 8–10 minutes. Check the length limit in `SAM10_Final_Project_Guidelines.pdf` and trim if needed.
**[SCREEN: ...]** = what to show. Everything else = what to say.

---

## Before you hit record

- Open these tabs, already signed in:
  1. https://16-179-35-197.sslip.io (HelpWise)
  2. https://project.16-179-35-197.sslip.io (project website)
  3. AWS Console (region **Sydney / ap-southeast-2**): EC2, CloudWatch, S3, CloudTrail, IAM
- Close anything that shows secrets: `.env` files, Parameter Store values, `.pem` keys, API keys, email inbox with other mail.
- In Parameter Store, show only parameter **names**, never "Show decrypted value".
- Check both sites load (HTTP 200, padlock shows).

---

## 1. Introduction (≈30 sec)

**[SCREEN: Project website home page]**

> Hi, I'm Mark Laurence M. Santos, and this is my SAM10 Systems Administration and Maintenance final project: **HelpWise, an IT Helpdesk Assistant for Cobalt Dynamics**.
>
> HelpWise is a customized LibreChat deployment running on AWS. The goal of this project wasn't just to deploy an app. It was to **operate it properly**: monitoring, alerting, backups and recovery, security hardening, automation, and diagnosing a real fault.

---

## 2. Architecture overview (≈1 min)

**[SCREEN: Infrastructure diagram on the project website]**

> Here's the architecture.
>
> - Everything runs on a single **EC2 t3.micro instance** in the **Sydney region**.
> - The application runs as **seven Docker containers**: the LibreChat API, MongoDB, and the supporting services.
> - **Caddy** is the reverse proxy in front, providing **HTTPS with a trusted TLS certificate**.
> - Only ports **80 and 443** are public. **SSH is limited to a single IP address**, and the **database ports are not exposed** to the internet.
> - Application and database data live on an **encrypted EBS volume**.
> - Secrets are stored in **Systems Manager Parameter Store** as SecureString values, not in the code.
> - Monitoring is done with **CloudWatch**, alerts go out through **SNS email**, backups go to **S3**, and **CloudTrail** records account activity.

---

## 3. Live application demo (≈1 min)

**[SCREEN: https://16-179-35-197.sslip.io, then click the padlock]**

> This is HelpWise running live. You can see the connection is secure with a valid certificate.

**[SCREEN: Sign in and ask a sample helpdesk question, e.g. "How do I reset my VPN password?"]**

> It works as an IT helpdesk assistant for employees of Cobalt Dynamics. I'll ask a typical helpdesk question… and it responds.

**[SCREEN: EC2 console → instance `i-00ecc810f659fc312` → Running, status checks 2/2]**

> And here's the EC2 instance behind it, running with both status checks passing.

---

## 4. Monitoring and alerting (≈1.5 min)

**[SCREEN: CloudWatch → Dashboards → `HelpWise-Operations`]**

> For monitoring, I built the **HelpWise-Operations** CloudWatch dashboard. It shows whether the application is healthy, request errors, response time, CPU, memory, disk, swap, network, and EC2 status.
>
> Some of these are **custom metrics**. Every five minutes, an automated health check on the server tests the application and publishes the results to CloudWatch.

**[SCREEN: CloudWatch → Alarms (show all eight)]**

> I set up **eight alarms**, covering things like the application being unhealthy, high CPU, low disk space, high memory, and EC2 status check failures.

**[SCREEN: SNS subscription confirmed + the alarm test email]**

> Alarms notify me by email through **SNS**. To prove it works, I ran a controlled test that pushed an alarm into the ALARM state, and here's the email I received.

**[SCREEN: CloudWatch → Log groups → retention column]**

> System and container logs are sent to CloudWatch Logs with **14-day retention**, so I can investigate problems after they happen.

---

## 5. Backup and recovery (≈1.5 min)

**[SCREEN: S3 → backup bucket → Permissions (Block Public Access ON) → Properties (Versioning, Encryption) → Management (Lifecycle rule)]**

> For backups, MongoDB is backed up **every night** to a **private S3 bucket**. The bucket blocks all public access, has **versioning** and **encryption** turned on, and a **lifecycle rule** keeps backups for **seven days**.
>
> The EC2 instance uses an IAM role that only has access to **this one bucket**, following least privilege.

**[SCREEN: S3 → `mongodb/2026/11/...` → list of backup objects]**

> Here are the backup files the nightly job created on its own.

**[SCREEN: Project website restore-test section / restore-test output]**

> A backup only counts if you can restore it. So I restored the latest backup into a **separate, temporary MongoDB container**, without touching production. It restored **61 collections and the user account**, and took **58 seconds**. That's my measured **recovery time (RTO)**. Because backups run nightly, the **recovery point (RPO)** is about 24 hours.

---

## 6. Security hardening (≈1.5 min)

**[SCREEN: EC2 → Security group inbound rules]**

> For security: the security group only allows web traffic on 80 and 443 from the internet, SSH only from my own IP, and no database ports are open.

**[SCREEN: EC2 instance → Details → IMDSv2 "Required"]**

> The instance requires **IMDSv2**, which protects the instance credentials from certain kinds of attacks.

**[SCREEN: EC2 → Volumes → encrypted volume `vol-036b0510ab52373d2`]**

> Application and database data were moved onto an **encrypted EBS volume** using AWS-managed keys.

**[SCREEN: CloudTrail → Trails → logging ON, multi-region, log file validation ON]**

> **CloudTrail** is enabled across all regions with log file validation, so every management action in the account is recorded and can't be secretly changed.

**[SCREEN: IAM → user `mark-santos` → MFA enabled]**

> I use a named IAM user with **MFA** for daily work instead of root, and there are **no root access keys**.

**[SCREEN: GuardDuty page showing the account restriction message]**

> I also tried to enable **GuardDuty**, but AWS blocked it because of account plan restrictions. I've kept this screenshot as evidence.

---

## 7. Automation (≈45 sec)

**[SCREEN: Project website automation section, or `automation/` folder]**

> The project has **two automations that run without anyone touching them**, both as systemd services on the server:
>
> 1. A **health check every five minutes** that publishes custom metrics to CloudWatch, which the alarms watch.
> 2. A **nightly MongoDB backup** that uploads to S3.
>
> Both have records of successful runs with no manual help.

---

## 8. Fault diagnosis: WS-F (≈1.5 min)

**[SCREEN: Project website incident section / `INCIDENT_REPORT_AND_RUNBOOK.md`]**

> Now the fault I diagnosed. At one point, **HelpWise was completely unreachable**. The server and proxy were fine, but the **LibreChat API container kept crashing** as soon as it started.
>
> I checked the container status and startup logs and found the cause: the **CREDS_KEY and CREDS_IV** values, which LibreChat uses to encrypt credentials, were in the **wrong format**. LibreChat refuses to start when they're invalid.
>
> To fix it, I generated correct values, stored them in **Parameter Store as SecureString parameters**, loaded them on the server without ever printing them, recreated the API container, and confirmed the API returned **HTTP 200**. After that, I added HTTPS with Caddy.
>
> To stop it happening again: secrets stay in Parameter Store and out of source control, secret formats get checked before containers start, the health-check alarm catches an outage, and logs are kept for diagnosis.
>
> I also wrote **runbooks** for an application outage, a failed backup, and a database restore, so someone else could follow the same steps.

---

## 9. Conclusion (≈30 sec)

**[SCREEN: Project website home page]**

> To sum up: HelpWise is running on AWS with HTTPS, monitoring, alarms, tested backups, security hardening, two unattended automations, and a documented fault diagnosis.
>
> The biggest lesson for me was that **deploying an app is the easy part**. Keeping it observable, recoverable and secure is the real work of systems administration.
>
> Thank you for watching.

---

## Don't show on camera

- Any secret value (API keys, CREDS_KEY/CREDS_IV, passwords, `.pem` files)
- Parameter Store decrypted values
- The root account sign-in
- Your personal email inbox beyond the one alarm email
