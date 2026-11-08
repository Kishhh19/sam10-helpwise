# AWS Budget Alert — set this FIRST, before creating anything billable

Per Section 1.3 / 6.2 of the brief: "Set an AWS Budgets alert on day one, low enough to be useful."

## Values to use

- **Budget name:** `SAM10-HelpWise-Monthly`
- **Budget type:** Cost budget
- **Amount:** **USD 15/month** — one small instance + a little S3/CloudWatch/SNS usage should sit
  well under this; it's tight enough that an alert actually means something went wrong.
- **Alert thresholds** (email to the student's own address):
  - 50% of budgeted amount (actual) — "check nothing is misconfigured"
  - 80% of budgeted amount (actual) — "look now"
  - 100% of budgeted amount (forecasted) — "something is about to overspend"

## Why this number
A t3.micro/t3.small EC2 instance in most regions is roughly $6–10/month if left running 24/7;
S3, Parameter Store, CloudWatch, and SNS at this scale are cents. $15/month gives headroom for an
instance running continuously for the whole project plus incidental usage, while still catching a
real runaway (e.g. an infinite retry loop against the Gemini API, or an oversized instance type).

## One-sentence justification (put this on the website, per the "word about thresholds" note)
"We set the AWS Budget at $15/month because a single small EC2 instance plus light S3/CloudWatch
usage should stay near $8–10/month; $15 leaves headroom without being so loose that a real
misconfiguration goes unnoticed."
