#!/usr/bin/env bash
# Layer A health check: core services and optional EdgeX.
# Usage: ./scripts/health-check.sh [--edgex]

set -e
EDGEX=false
for a in "$@"; do
  [ "$a" = "--edgex" ] && EDGEX=true
done

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
ok() { echo -e "${GREEN}OK${NC} $1"; }
fail() { echo -e "${RED}FAIL${NC} $1"; exit 1; }

# Core
curl -sf http://localhost:18083/api/v5/status >/dev/null && ok "EMQX" || fail "EMQX"
curl -sf http://localhost:9090/-/healthy >/dev/null && ok "Prometheus" || fail "Prometheus"
curl -sf http://localhost:3000/api/health >/dev/null && ok "Grafana" || fail "Grafana"
curl -sf http://localhost:9600/_node/stats/pipelines?pretty >/dev/null && ok "Logstash" || fail "Logstash"
curl -sf http://localhost:8080 >/dev/null && ok "Redpanda Console" || fail "Redpanda Console"
# Redpanda (rpk from host may not be installed; check HTTP)
curl -sf http://localhost:9644/v1/status/ready >/dev/null && ok "Redpanda" || fail "Redpanda"
# Postgres (require pg_isready or TCP)
(pg_isready -h localhost -p 5432 -U layera 2>/dev/null) || (nc -z localhost 5432 2>/dev/null) && ok "Postgres" || fail "Postgres"

if [ "$EDGEX" = true ]; then
  curl -sf http://localhost:59880/api/v3/ping >/dev/null && ok "EdgeX Core-Data" || fail "EdgeX Core-Data"
fi

echo "Health check passed."
