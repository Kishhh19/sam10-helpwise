# SYSTEM CARD: HelpWise — Cobalt Dynamics IT Helpdesk Assistant

## 1. What it does
HelpWise answers everyday IT-helpdesk questions for a fictional software company, Cobalt Dynamics —
password resets, VPN setup, hardware requests, onboarding/offboarding steps, software licensing,
and where to report a security incident. It is a Q&A assistant over a small invented knowledge base,
not a ticketing system: it tells staff the process and who to contact, it does not take action on
accounts or tickets itself.

## 2. Who uses it, and who must not
- **Intended users:** Cobalt Dynamics staff (fictional, for this project) asking routine IT
  questions.
- **Explicitly NOT for:** medical, legal or financial advice; any decision about a real,
  identifiable person (hiring, discipline, access approval, grading); real account actions
  (it cannot reset a password or unlock an account — it only explains the process).

## 3. Base system
- **Name and version:** LibreChat v0.8.9-rc1
- **Source URL:** https://github.com/LibreChat-AI/LibreChat
- **Author:** The LibreChat team / contributors
- **Licence:** MIT (permissive, commercial use and modification allowed with attribution)
- **What it did originally:** A general-purpose, self-hostable ChatGPT-style web UI supporting many
  model providers, file uploads, RAG, and multi-user accounts — with no fixed identity or domain.

## 4. What we changed (the reskin)

| Part | Original | Ours | Why we changed it |
|------|----------|------|--------------------|
| Name/branding | "LibreChat", default blue/green logo | "HelpWise" for Cobalt Dynamics, hexagon logo (cobalt blue + amber) | Required identity reskin; nothing in the UI should look like stock LibreChat |
| Data/content | No built-in knowledge base | 6 invented IT-helpdesk KB documents (account/access, hardware, network/VPN, onboarding/offboarding, software/licensing, security incidents), served from S3 | Required "data" reskin element; gives the assistant real, checkable domain knowledge |
| Wording/prompts | Generic "Welcome to LibreChat" | Custom welcome message naming Cobalt Dynamics and example question categories | Required domain-language reskin element |
| Interface | Generic favicon/logo assets | Swapped logo.svg + all favicon sizes | Part of the identity reskin |
| AWS services | None (self-hosted, no cloud ties) | Reads KB content from S3; secrets in Systems Manager Parameter Store; CloudWatch monitoring; RDS/backup — see Infrastructure Design | Required AWS integration beyond static hosting |

## 5. Data
- **Where it came from (source, licence):** 100% invented by the student for this project.
- **Anything personal in it:** No — all invented. No real names, employee IDs, addresses, or case
  notes anywhere in the knowledge base or test questions.
- **Anything sent to a third-party AI service:** The user's question text and the relevant KB
  excerpt are sent to Google's Gemini API (free tier) to generate the answer. This is invented
  content only — no real personal data is ever sent.

## 6. How good is it
*(To be completed in Week 2–3 once the system is deployed and tested — brief requires at least one
honest accuracy number from a real evaluation, e.g. "correct on N of 10 test questions".)*

## 7. How it is served
- **Where it runs:** AWS EC2 (single instance, one region), served over HTTPS.
- **The model behind it:** Google Gemini, free tier (`gemini-2.0-flash-001` / `-lite-001`), via a
  student-held free API key — not hosted on AWS, no AWS AI service used.
- **What happens if the model or service is unavailable:** The chat UI itself stays reachable;
  a new message will show a visible error if Gemini's API is unreachable or the free-tier quota is
  exhausted. There is no automatic fallback model configured.

## 8. Limitations and risks
- **What it cannot do:** take real action on any account, ticket, or access request; answer
  questions outside the 6 KB topics reliably (it will say so or answer generically rather than
  making something up — this is a known limitation, not guaranteed-perfect grounding); handle real
  employee or customer data.
- **What could go wrong with the data:** none of the KB content is sensitive (it's all invented),
  so the main risk is simply giving an unhelpful or generic answer outside its KB scope.
- **What a user must always check themselves:** for anything involving a real account, access
  grant, or security incident, the user must follow up with an actual human (see
  `06-security-incidents.md`) — HelpWise only explains the process.

## 9. Operational summary
- **Where the code lives:** this Git repository (see `README.md`).
- **How often it is backed up:** see `docs/backup-and-restore.md` (Week 3).
- **How we know it is healthy:** CloudWatch dashboard + 6 alarms, emailing the operator (Week 3).
- **Who to contact:** Mark Laurence Santos (student operator) — this is a student project, not a
  production service.
