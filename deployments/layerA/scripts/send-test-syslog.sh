#!/usr/bin/env bash
# Send a test syslog message to Layer A (UDP 5140).
# Usage: ./scripts/send-test-syslog.sh [host]

HOST="${1:-localhost}"
PORT="${SYSLOG_PORT:-5140}"
MSG="<134>$(date -u +%Y-%m-%dT%H:%M:%S.000Z) hostname test-app: Layer A syslog test message"
echo "Sending: $MSG"
echo "$MSG" | nc -u -w1 "$HOST" "$PORT" || true
echo "Done. Check events.raw.syslog and normalized_events in Postgres."
