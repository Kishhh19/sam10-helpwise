# HelpWise — IT Helpdesk Assistant for Cobalt Dynamics

**SAM10 — Systems Administration and Maintenance, Final Project**
Student: Mark Laurence Santos
Deployed, operated and documented by one student (working alone — 100% of the work and mark).

## What this is

HelpWise is a reskinned, deployed, and operated chat assistant for **Cobalt Dynamics**, a fictional
software startup. It answers IT-helpdesk style questions — password resets, VPN setup, hardware
requests, onboarding steps — using a small invented knowledge base. Everything about Cobalt Dynamics,
its staff, and its IT policies is invented for this project; **no real people, accounts, or records
are used anywhere.**

This is a Systems Administration course project: the AI model itself is not the point. 80% of the
marks are for running, securing, monitoring, backing up and documenting the system well. See the
project website for the full write-up, system card, infrastructure diagram, and recorded
presentation.

- **Live application:** <https://16-179-35-197.sslip.io>
- **Project website:** <https://project.16-179-35-197.sslip.io>
- **AWS region:** `ap-southeast-2` (Sydney), single EC2 instance `i-00ecc810f659fc312`

## Base system and credit

- **Base system:** [LibreChat](https://github.com/LibreChat-AI/LibreChat) by the LibreChat team
- **License:** MIT (see `vendor/LibreChat-LICENSE`)
- **Version forked from:** v0.8.9-rc1 (as of 2026-11-08)
- **What we changed:** see `branding/`, `config/librechat.yaml`, and the System Card
  (`docs/system-card.md`) for the full original → ours table.

We do **not** modify the LibreChat source code. We configure it (the way it's designed to be
customized): custom `librechat.yaml`, custom `.env`, swapped branding assets mounted over the
defaults, and our own invented content served from AWS S3. This keeps upstream updates possible
and keeps our changes auditable in this repo.

## Repository layout

```
config/       librechat.yaml, .env.example — the actual reskin configuration
branding/     logo, favicon, color tokens — Cobalt Dynamics identity
content/      invented IT-helpdesk knowledge base (goes to S3)
infra/        AWS deployment: diagrams, IaC/CLI scripts, security + monitoring setup
automation/   unattended automations (WS-E: health check, nightly backup), restore test,
              monitoring/alarm setup, HTTPS, encrypted-EBS migration, Gemini model fix
website/      project website source (served at project.16-179-35-197.sslip.io)
docs/         system card, incident report + runbooks (WS-F), final status, presentation script
```

## Weekly log (contribution evidence — required by brief Section 1.3 / 4.1)

| Week | Date | What was done | By |
|------|------|----------------|-----|
| 1 | 2026-11-08 | Chose LibreChat as base; chose Cobalt Dynamics / HelpWise identity; chose Google Gemini (free tier) as the external model; scaffolded repo; wrote reskin config (branding, librechat.yaml, invented KB content) | Mark Laurence Santos (with Claude assisting — see declaration) |
| 2 | 2026-11-09 | Deployed to EC2 (Sydney) with Docker; diagnosed and fixed the WS-F fault (invalid `CREDS_KEY`/`CREDS_IV` crash loop) using Parameter Store SecureStrings; added HTTPS via Caddy; added 2 GiB swap; CloudWatch agent, 14-day log groups, custom metrics, `HelpWise-Operations` dashboard, 8 alarms + SNS email (tested); private encrypted versioned S3 backups with 7-day lifecycle; nightly backup + 5-minute health-check automations; isolated restore test (61 collections, RTO 58 s); multi-region CloudTrail; IMDSv2; moved Docker data to encrypted EBS; GuardDuty attempted (blocked by account plan); wrote incident report and runbooks; built and published project website | Mark Laurence Santos (with Claude and OpenAI Codex assisting — see declaration) |
| 3 | 2026-11-23 | Google retired `gemini-2.0-flash-001` (chats returned HTTP 404); diagnosed from the provider error and switched to `gemini-3.8-flash` / `gemini-flash-lite-latest` via Systems Manager Run Command (`automation/fix-gemini-model.sh`), no SSH and no key exposure; verified chat working; wrote presentation script and slides; moved all automation, website and documentation into this repo | Mark Laurence Santos (with Claude assisting — see declaration) |

*(This table is updated every week as work happens — see Section 1.3 of the brief: "keep a README.md
recording who did what, week by week.")*

## AI-assistance declaration

Per Section 6.1 of the brief: Claude (Anthropic) and, during Week 2, OpenAI Codex were used as
pair-programming/ops assistants — to scaffold configuration, write documentation, and operate AWS and the local
environment under the student's direction and review. The student reviewed and verified all outputs,
commands, and evidence before submission. Nothing LibreChat-related was presented as original work;
the base system and its license are credited above and in the System Card.
