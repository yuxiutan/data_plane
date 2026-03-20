# Layer A — Observability

## Stack

- **Prometheus** — scrapes metrics from cAdvisor, node-exporter, Redpanda, EMQX.
- **Grafana** — provisioned with Prometheus datasource and Layer A Overview dashboard.
- **cAdvisor** — container CPU/memory for all services.
- **Node exporter** — host metrics (optional; can be disabled if too heavy).

## Prometheus Scrape Targets

| Job            | Target           | Notes |
|----------------|------------------|--------|
| prometheus     | localhost:9090   | Self. |
| cadvisor       | cadvisor:8080    | Container metrics. |
| node-exporter  | node-exporter:9100 | Host metrics. |
| redpanda       | redpanda:9644    | Path: `/public_metrics`. |
| emqx_stats     | emqx:18083       | Path: `/api/v5/prometheus/stats`. |
| emqx_auth      | emqx:18083       | Path: `/api/v5/prometheus/auth`. |
| emqx_data_integration | emqx:18083 | Path: `/api/v5/prometheus/data_integration`. |

Logstash does not expose a native Prometheus endpoint; use cAdvisor for Logstash container stats. Pipeline events in/out can be added via a Logstash exporter or custom collector (TODO).

## Grafana

- **Datasource**: Prometheus (provisioned).
- **Dashboard**: Layer A Overview — container CPU/mem, Redpanda throughput, consumer lag (if groups exist), EMQX clients and publish rate, and placeholders for Logstash pipeline metrics.

## URLs (default)

- Prometheus: http://localhost:9090  
- Grafana: http://localhost:3000  
- Logstash monitoring API (JSON): http://localhost:9600  
