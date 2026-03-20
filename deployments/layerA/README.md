# Layer A — Data Plane / Ingestion Plane

Layer A: **ingest → normalize → route → persist**. No inference; Layer B (GPU) consumes Kafka only.

## Architecture (ASCII)

```
  [Syslog] [HTTP] [Agents]          [EdgeX (optional)]
       │      │       │                      │
       ▼      ▼       ▼                      ▼
  ┌─────────────────────────┐         ┌─────────────┐
  │      Logstash           │         │ MQTT → EMQX │
  │ UDP:5140  HTTP:8088     │         └──────┬──────┘
  └───────────┬─────────────┘                │
              │                              │
              ▼                              ▼
  ┌───────────────────────────────────────────────────┐
  │              Redpanda (Kafka 9092)                 │
  │  events.raw.syslog | .http | .mqtt | .norm.*       │
  └───────────┬───────────────────────────────────────┘
              │
              ├──► Logstash pipeline 30 ──► Postgres (normalized_events)
              │
              ▼
  Layer 0 / Layer B (consumers)
```

## How to Run

```bash
cd deployments/layerA
cp .env.example .env   # optional
docker compose up -d
```

With EdgeX (optional):

```bash
docker compose --profile edgex up -d
```

## Create Kafka Topics

After Redpanda is healthy:

```bash
docker compose exec redpanda rpk topic create events.raw.syslog --brokers redpanda:9092 --partitions 6
docker compose exec redpanda rpk topic create events.raw.http   --brokers redpanda:9092 --partitions 6
docker compose exec redpanda rpk topic create events.raw.mqtt   --brokers redpanda:9092 --partitions 6
# Optional: events.norm.security, signals.layer0.risk_inputs, results.layerb.hypothesis
docker compose exec redpanda rpk topic list --brokers redpanda:9092
```

Or run the script (from `deployments/layerA` with stack up):

```bash
./scripts/create-topics.sh
```

(If `rpk` is not on PATH, the script uses `docker compose exec redpanda rpk`; set `COMPOSE_FILE` if not in `deployments/layerA`.)

## Postgres: Create Table

Connect to Postgres and run:

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS normalized_events (
  id BIGSERIAL PRIMARY KEY,
  event_id UUID DEFAULT gen_random_uuid(),
  ts TIMESTAMPTZ NOT NULL,
  tenant_id TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  source TEXT,
  event_type TEXT,
  severity INT,
  confidence REAL,
  fields JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_norm_events_entity_ts
ON normalized_events(tenant_id, entity_id, ts DESC);
```

Optional (for future pipeline metrics):

```sql
CREATE TABLE IF NOT EXISTS pipeline_metrics (
  id BIGSERIAL PRIMARY KEY,
  pipeline_id TEXT NOT NULL,
  ts TIMESTAMPTZ NOT NULL,
  events_in BIGINT DEFAULT 0,
  events_out BIGINT DEFAULT 0,
  failures BIGINT DEFAULT 0
);
```

Example connection:

```bash
docker compose exec postgres psql -U layera -d layera -c "$(cat <<'SQL'
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE IF NOT EXISTS normalized_events (
  id BIGSERIAL PRIMARY KEY,
  event_id UUID DEFAULT gen_random_uuid(),
  ts TIMESTAMPTZ NOT NULL,
  tenant_id TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  source TEXT,
  event_type TEXT,
  severity INT,
  confidence REAL,
  fields JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_norm_events_entity_ts ON normalized_events(tenant_id, entity_id, ts DESC);
SQL
)"
```

## URLs

| Service           | URL |
|-------------------|-----|
| Redpanda Console  | http://localhost:8080 |
| EMQX Dashboard     | http://localhost:18083 |
| Grafana            | http://localhost:3000 (admin / admin) |
| Prometheus         | http://localhost:9090 |
| Logstash metrics   | http://localhost:9600 (JSON API) |

## Smoke Tests

**Syslog:**

```bash
./scripts/send-test-syslog.sh
```

**HTTP (JSON):**

```bash
./scripts/send-test-http.sh
```

Then check:

- Redpanda Console → topic `events.raw.syslog` or `events.raw.http`.
- Postgres: `SELECT * FROM normalized_events ORDER BY created_at DESC LIMIT 5;`

**Health check:**

```bash
./scripts/health-check.sh
# With EdgeX: ./scripts/health-check.sh --edgex
```

## How Layer 0 and Layer B Consume

- **Layer 0** reads `normalized_events` (or in the future consumes `signals.layer0.risk_inputs`).
- **Layer B** consumes `events.raw.*` or `events.norm.*` topics and writes to `results.layerb.hypothesis`.

See [docs/LAYER_A_ARCHITECTURE.md](../../docs/LAYER_A_ARCHITECTURE.md), [docs/LAYER_A_TOPIC_MAP.md](../../docs/LAYER_A_TOPIC_MAP.md).

## TODO: Hardening to Production

- **DLQ**: Dead-letter topic and pipeline for failed/filtered events.
- **Schema registry**: Redpanda or Confluent schema registry for event schemas.
- **Auth**: SASL/SSL for Kafka; TLS and auth for EMQX, Postgres, Grafana.
- **TLS**: Enable TLS for MQTT, HTTP intake, and internal service-to-service where required.
- **Logstash**: Add Prometheus exporter or sidecar for pipeline events in/out and failure counts.
- **Retention**: Configure topic retention per [LAYER_A_TOPIC_MAP.md](../../docs/LAYER_A_TOPIC_MAP.md) (e.g. 7–14d raw, 30d+ results).
