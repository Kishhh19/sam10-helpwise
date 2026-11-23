#!/bin/bash
# Switch HelpWise from the retired gemini-2.0-flash models to a current Gemini model.
# Run on the EC2 instance via Systems Manager > Run Command > AWS-RunShellScript.
# Prints only model names; never prints the API key.
set -e
cd /opt/helpwise/librechat

KEY=$(grep '^GOOGLE_KEY=' .env | cut -d= -f2-)
RESP=$(curl -s -w '\n%{http_code}' -H "x-goog-api-key: ${KEY}" \
  "https://generativelanguage.googleapis.com/v1beta/models?pageSize=200")
CODE=$(echo "$RESP" | tail -n1)
echo "Gemini model list HTTP status: $CODE"
if [ "$CODE" != "200" ]; then
  echo "The Gemini key was rejected. Create a new key in Google AI Studio and update /sam10/helpwise/google_key."
  exit 1
fi
MODELS=$(echo "$RESP" | grep -o '"models/[^"]*"' | tr -d '"' | sed 's|^models/||' | sort -u)
echo "Flash models available to this key:"
echo "$MODELS" | grep -i flash || true

pick() { for m in "$@"; do echo "$MODELS" | grep -qx "$m" && { echo "$m"; return; }; done; }
NEWEST_FLASH=$(echo "$MODELS" | grep -E '^gemini-[0-9.]+-flash$' | sort -V | tail -n1)
NEWEST_LITE=$(echo "$MODELS" | grep -E '^gemini-[0-9.]+-flash-lite$' | sort -V | tail -n1)
MAIN=$(pick gemini-3.8-flash gemini-flash-latest "$NEWEST_FLASH" gemini-2.5-flash)
LITE=$(pick gemini-3.8-flash-lite gemini-flash-lite-latest "$NEWEST_LITE" gemini-2.5-flash-lite)
[ -z "$LITE" ] && LITE="$MAIN"
if [ -z "$MAIN" ]; then echo "None of the expected models were found; see the list above."; exit 1; fi
echo "Using: $MAIN (chat), $LITE (titles)"

cp .env ".env.bak-$(date +%Y%m%d%H%M%S)"
cp librechat.yaml "librechat.yaml.bak-$(date +%Y%m%d%H%M%S)"
if grep -q '^GOOGLE_MODELS=' .env; then
  sed -i "s|^GOOGLE_MODELS=.*|GOOGLE_MODELS=${MAIN},${LITE}|" .env
else
  echo "GOOGLE_MODELS=${MAIN},${LITE}" >> .env
fi
sed -i "s|titleModel: .*|titleModel: \"${LITE}\"|" librechat.yaml

docker compose -f docker-compose.yml -f docker-compose.override.yml up -d --force-recreate api
sleep 20
echo "GOOGLE_MODELS now: $(grep '^GOOGLE_MODELS=' .env | cut -d= -f2-)"
echo "Local API status: $(curl -s -o /dev/null -w '%{http_code}' http://localhost:3080/api/config)"
