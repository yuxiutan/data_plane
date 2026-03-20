# Layer A — Architecture

Layer A is the **Data Plane / Ingestion Plane**: ingest → normalize → route → persist. It does **not** perform inference; Layer B (GPU inference) consumes Kafka topics and lives elsewhere.

## High-Level Flow

```
  [Devices / Agents]     [EdgeX (optional)]
         │                        │
         ▼                        ▼
  ┌──────────────┐         ┌─────────────┐
  │ Syslog UDP   │         │ MQTT → EMQX │
  │ HTTP (JSON)  │         └──────┬──────┘
  └──────┬───────┘                │
         │                        │
         ▼                        ▼
  ┌─────────────────────────────────────┐
  │            Logstash                   │
  │  (intake → Kafka raw topics)          │
  │  (Kafka → NormalizedEvent → Postgres) │
  └─────────────────────────────────────┘
         │                        │
         ▼                        ▼
  ┌──────────────┐         ┌─────────────┐
  │   Redpanda   │         │  Postgres   │
  │   (Kafka)    │         │ normalized_ │
  └──────┬───────┘         │   events    │
         │                 └─────────────┘
         │
         ▼
  Layer 0 / Layer B (consumers)
```

## Components

| Component       | Role |
|----------------|------|
| **EMQX**       | MQTT broker; southbound for EdgeX and other MQTT publishers. |
| **Redpanda**   | Kafka-compatible broker; backbone for raw/norm/signals/results topics. |
| **Logstash**   | UDP syslog + HTTP intake → Kafka; Kafka consumer → NormalizedEvent → Postgres. |
| **Postgres**   | Append-only store for `normalized_events` (NormalizedEvent v1). |
| **Prometheus** | Scrapes cAdvisor, node-exporter, Redpanda, EMQX. |
| **Grafana**    | Dashboards over Prometheus (and optional Logstash metrics). |
| **EdgeX**      | Optional profile; publishes device events to EMQX. |

## Boundaries

- **Layer A guarantees**: schema validation, append-only persistence, routing, replayability from Kafka.
- **Layer A does not**: infer risk, infer TTP, or maintain per-entity inference state; that is Layer B’s responsibility.

See [LAYER_A_EVENT_SCHEMA.md](LAYER_A_EVENT_SCHEMA.md), [LAYER_A_TOPIC_MAP.md](LAYER_A_TOPIC_MAP.md), [LAYER_A_OBSERVABILITY.md](LAYER_A_OBSERVABILITY.md), [LAYER_A_EDGEX_PROFILE.md](LAYER_A_EDGEX_PROFILE.md).
