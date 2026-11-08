# CloudWatch Alarms — HelpWise (WS-B, needs at least 6)

Using the brief's starter set (Appendix A), adapted to our actual services (EC2 + S3, no RDS/ALB
since we're running a single instance with Docker — no load balancer for a project this size).

| # | Service | Metric | Threshold | Period | Why / what we do |
|---|---------|--------|-----------|--------|-------------------|
| 1 | EC2 | `CPUUtilization` | > 85% | 10 min | Stuck process or runaway loop — check the instance |
| 2 | EC2 | `StatusCheckFailed` | > 0 | 1 min | Instance-level problem — look at the instance immediately |
| 3 | EC2 (custom, via CloudWatch agent) | `DiskSpaceUsed` | > 85% | 1 hour | Clean up logs/images or grow the volume |
| 4 | EC2 (custom, via CloudWatch agent) | `MemoryUtilization` | > 90% | 5 min | A memory-hungry process may be about to be OOM-killed |
| 5 | Application (custom metric, from our request log) | `AnswersFailed` | > 5% of requests | 15 min | The app is up but not working |
| 6 | Application (custom metric) | `EmptyAnswer` | > 0 | 30 min | Content is probably missing or unreadable |
| 7 | Billing | Monthly estimated charge | over budget ($15) | 1 day | Switch things off |

That's 7 — one more than the required 6, since we don't have a load balancer or RDS to draw the
"request count" and "DB connections" alarms from in this simple single-instance setup. We note this
trade-off explicitly on the website's Well-Architected review (Performance Efficiency / Cost
Optimization: one region, one small instance, no load balancer, by design).

All alarms notify the `sam10-helpwise-alerts` SNS topic, which emails the student's own inbox
(WS-B #3 — "all alarms emailing your real inbox").

## Custom metrics (#3, #4, #5, #6)
EC2's basic (free) metrics don't include disk or memory — those need the CloudWatch agent
installed on the instance (`amazon-cloudwatch-agent`), or a small script run by cron that calls
`aws cloudwatch put-metric-data`. `AnswersFailed` / `EmptyAnswer` come from a small script that
tails the application's request log (written by our custom logging — see `docs/monitoring.md`,
Week 3) and pushes a count via `put-metric-data` on a schedule (this doubles as one of the two
WS-E automations).
