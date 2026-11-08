#!/bin/bash
# EC2 user-data script — HelpWise (Cobalt Dynamics IT Helpdesk)
# Launch an Ubuntu 22.04/24.04 LTS instance with this as "User data" (console: Advanced details).
# It installs Docker, pulls the LibreChat base + our reskin config, reads secrets from Parameter
# Store (never hard-coded here), and brings the stack up automatically on boot.
set -euxo pipefail

REGION="$(curl -s http://169.254.169.254/latest/meta-data/placement/region)"
export AWS_DEFAULT_REGION="$REGION"
APP_DIR=/opt/helpwise
LIBRECHAT_TAG="v0.8.9-rc1"

apt-get update -y
apt-get install -y ca-certificates curl gnupg unzip git

# --- Docker Engine (official repo) ------------------------------------------
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl enable --now docker

# --- AWS CLI v2 ---------------------------------------------------------------
curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

# --- Pull our repo (reskin config, branding, KB content) + LibreChat ----------
mkdir -p "$APP_DIR"
cd "$APP_DIR"
git clone --depth 1 https://github.com/Kishhh19/sam10-helpwise.git repo
git clone --depth 1 --branch "$LIBRECHAT_TAG" https://github.com/LibreChat-AI/LibreChat.git librechat

cp repo/config/librechat.yaml librechat/librechat.yaml
cp repo/config/docker-compose.override.yml librechat/docker-compose.override.yml
mkdir -p librechat/branding/assets
cp repo/branding/assets/*.png repo/branding/assets/logo.svg librechat/branding/assets/

cp librechat/.env.example librechat/.env

# --- Pull secrets from SSM Parameter Store (WS-D #3 — never in code) ----------
get_param() { aws ssm get-parameter --name "$1" --with-decryption --query 'Parameter.Value' --output text; }

GOOGLE_KEY="$(get_param /sam10/helpwise/google_key)"
CREDS_KEY="$(get_param /sam10/helpwise/creds_key)"
CREDS_IV="$(get_param /sam10/helpwise/creds_iv)"
JWT_SECRET="$(get_param /sam10/helpwise/jwt_secret)"
JWT_REFRESH_SECRET="$(get_param /sam10/helpwise/jwt_refresh_secret)"
ADMIN_PANEL_SESSION_SECRET="$(get_param /sam10/helpwise/admin_panel_session_secret)"

ENV_FILE="$APP_DIR/librechat/.env"
sed -i \
  -e "s|^APP_TITLE=.*|APP_TITLE=HelpWise|" \
  -e "s|^GOOGLE_KEY=.*|GOOGLE_KEY=${GOOGLE_KEY}|" \
  -e "s|^# GOOGLE_MODELS=.*|GOOGLE_MODELS=gemini-2.0-flash-001,gemini-2.0-flash-lite-001|" \
  -e "s|^CREDS_KEY=.*|CREDS_KEY=${CREDS_KEY}|" \
  -e "s|^CREDS_IV=.*|CREDS_IV=${CREDS_IV}|" \
  -e "s|^JWT_SECRET=.*|JWT_SECRET=${JWT_SECRET}|" \
  -e "s|^JWT_REFRESH_SECRET=.*|JWT_REFRESH_SECRET=${JWT_REFRESH_SECRET}|" \
  -e "s|^ADMIN_PANEL_SESSION_SECRET=.*|ADMIN_PANEL_SESSION_SECRET=${ADMIN_PANEL_SESSION_SECRET}|" \
  "$ENV_FILE"

# --- Bring up the stack --------------------------------------------------------
cd "$APP_DIR/librechat"
docker compose -f docker-compose.yml -f docker-compose.override.yml up -d

# --- Mark boot-time automation success for CloudWatch Logs (WS-E evidence) ----
logger -t helpwise-bootstrap "HelpWise stack started at $(date -u +%FT%TZ) on $(hostname)"
