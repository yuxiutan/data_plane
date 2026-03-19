# Sensel Dataplane (Layer A)

Data plane / ingestion plane: **ingest → normalize → route → persist**. No inference; downstream layers (Layer 0, Layer B) consume via Kafka.

## Repository structure

```
├── README.md                 # this file (project overview)
├── deployments/
│   └── layerA/               # Layer A stack (Docker Compose)
│       ├── README.md         # Run instructions, URLs, smoke tests
│       ├── docker-compose.yml
│       ├── .env.example
│       ├── init-db.sql
│       ├── logstash/         # config + pipelines
│       ├── observability/    # Prometheus, Grafana, dashboards
│       ├── edgex/            # EdgeX profile notes
│       └── scripts/          # create-topics, health-check, send-test-*
└── docs/
    ├── LAYER_A_ARCHITECTURE.md
    ├── LAYER_A_EVENT_SCHEMA.md
    ├── LAYER_A_TOPIC_MAP.md
    ├── LAYER_A_OBSERVABILITY.md
    └── LAYER_A_EDGEX_PROFILE.md
```

## Quick start

```bash
cd deployments/layerA
cp .env.example .env   # optional
docker compose up -d
```

With optional EdgeX profile:

```bash
docker compose --profile edgex up -d
```

See **[deployments/layerA/README.md](deployments/layerA/README.md)** for:

- Creating Kafka topics and Postgres tables  
- Service URLs (Redpanda Console, EMQX, Grafana, Prometheus)  
- Smoke tests and health checks  

## Docs

| Doc | Description |
|-----|-------------|
| [LAYER_A_ARCHITECTURE.md](docs/LAYER_A_ARCHITECTURE.md) | Components and flow |
| [LAYER_A_EVENT_SCHEMA.md](docs/LAYER_A_EVENT_SCHEMA.md) | NormalizedEvent v1 |
| [LAYER_A_TOPIC_MAP.md](docs/LAYER_A_TOPIC_MAP.md) | Kafka topics and retention |
| [LAYER_A_OBSERVABILITY.md](docs/LAYER_A_OBSERVABILITY.md) | Prometheus & Grafana |
| [LAYER_A_EDGEX_PROFILE.md](docs/LAYER_A_EDGEX_PROFILE.md) | Optional EdgeX profile |

## Layer boundaries

- **Layer A** (this repo): ingestion, normalization, routing, append-only persistence. Guarantees schema and replayability; does not infer risk or TTP.
- **Layer 0 / Layer B**: consume Kafka topics (e.g. `events.raw.*`, `events.norm.*`, `signals.layer0.risk_inputs`) and produce `results.layerb.hypothesis`; live in separate repos.
