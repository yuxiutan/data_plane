-- Layer A Postgres init: normalized_events table
-- Run once: docker compose exec -T postgres psql -U layera -d layera < init-db.sql

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

-- Optional: pipeline metrics (for future use)
CREATE TABLE IF NOT EXISTS pipeline_metrics (
  id BIGSERIAL PRIMARY KEY,
  pipeline_id TEXT NOT NULL,
  ts TIMESTAMPTZ NOT NULL,
  events_in BIGINT DEFAULT 0,
  events_out BIGINT DEFAULT 0,
  failures BIGINT DEFAULT 0
);
