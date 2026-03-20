#!/usr/bin/env bash
# Send a test HTTP JSON event to Layer A (Logstash HTTP 8088).
# Usage: ./scripts/send-test-http.sh [host]

HOST="${1:-localhost}"
PORT="${HTTP_INTAKE_PORT:-8088}"
URL="http://${HOST}:${PORT}"
BODY='{"tenant_id":"default","entity_id":"test-host","source":"http","event_type":"test","severity":2,"message":"Layer A HTTP test"}'
echo "POST $URL"
curl -s -X POST -H "Content-Type: application/json" -d "$BODY" "$URL"
echo ""
echo "Done. Check events.raw.http and normalized_events in Postgres."
