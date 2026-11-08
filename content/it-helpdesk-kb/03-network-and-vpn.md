# Network & VPN — Cobalt Dynamics IT Helpdesk

*Invented content for a student project.*

## Connecting to the office network
- Office Wi-Fi: network "CobaltDynamics-Staff", authenticate with your CD-SSO credentials
  (WPA2-Enterprise). Guest Wi-Fi ("CobaltDynamics-Guest") does not reach internal systems.

## VPN (remote access)
- Working remotely requires the Cobalt VPN client, connecting to `vpn.cobaltdynamics.example`.
- First-time setup: install the client from the internal Software Catalogue, sign in with CD-SSO,
  approve the MFA push.
- VPN sessions time out after 10 hours of inactivity — just reconnect, no ticket needed.

## Common VPN problems
- "Authentication failed": check your password hasn't expired (see `01-account-and-access.md`);
  confirm your MFA app's clock is in sync (mismatched device time breaks MFA approval).
- Connects but can't reach internal tools: usually a stale DNS cache — restart the VPN client
  fully (not just reconnect) before logging a ticket.
- Very slow over VPN: expected for large file transfers from home internet; try the office Wi-Fi
  or a wired connection first.

## Requesting firewall / network changes
- Any new inbound/outbound rule (e.g. a vendor integration) requires a ticket under "Network & VPN"
  with business justification; network changes are reviewed weekly, not same-day.
