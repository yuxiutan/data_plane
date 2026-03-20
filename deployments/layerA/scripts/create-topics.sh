#!/usr/bin/env bash
# Create Kafka topics for Layer A using rpk.
# Usage:
#   From deployments/layerA (stack already up):
#     docker compose exec redpanda rpk topic create events.raw.syslog --brokers redpanda:9092 --partitions 6
#   Or run this script inside the redpanda container (copy-paste or mount):
#     docker compose exec redpanda bash -c 'for t in events.raw.syslog events.raw.http events.raw.mqtt events.norm.security signals.layer0.risk_inputs results.layerb.hypothesis; do rpk topic create $t --brokers redpanda:9092 --partitions 6; done; rpk topic list --brokers redpanda:9092'
#   From host with rpk installed: KAFKA_BOOTSTRAP=localhost:19092 ./scripts/create-topics.sh

set -e
BROKERS="${KAFKA_BOOTSTRAP:-redpanda:9092}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"

run_rpk() {
  if command -v rpk &>/dev/null; then
    rpk "$@"
  else
    docker compose -f "$COMPOSE_FILE" exec -T redpanda rpk "$@"
  fi
}

run_rpk topic create events.raw.syslog --brokers "$BROKERS" --partitions 6 2>/dev/null || true
run_rpk topic create events.raw.http   --brokers "$BROKERS" --partitions 6 2>/dev/null || true
run_rpk topic create events.raw.mqtt   --brokers "$BROKERS" --partitions 6 2>/dev/null || true
run_rpk topic create events.norm.security       --brokers "$BROKERS" --partitions 6 2>/dev/null || true
run_rpk topic create signals.layer0.risk_inputs --brokers "$BROKERS" --partitions 6 2>/dev/null || true
run_rpk topic create results.layerb.hypothesis  --brokers "$BROKERS" --partitions 6 2>/dev/null || true

echo "Topics created (or already exist). List:"
run_rpk topic list --brokers "$BROKERS"
