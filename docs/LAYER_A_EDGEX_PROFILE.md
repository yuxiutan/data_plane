# Layer A — EdgeX Optional Profile

EdgeX Foundry is an **optional** compose profile (`edgex`) for Layer A. It acts as a southbound adapter / edge gateway: device events can be published to **EMQX** (Layer A’s MQTT broker) and then ingested via the same pipeline (e.g. MQTT→Kafka or HTTP intake).

## Role

- **Not** the backbone: the backbone is Redpanda (Kafka) and Logstash.
- **Optional**: only started with `docker compose --profile edgex up -d`.
- **Southbound**: EdgeX device services and app-service publish to EMQX; Layer A ingests from EMQX (e.g. via bridge or webhook) into `events.raw.mqtt` and `normalized_events`.

## Services (profile=edgex)

- **edgex-database** — Postgres for EdgeX (port 5433).
- **edgex-core-keeper** — Registry.
- **edgex-core-metadata**, **edgex-core-data**, **edgex-core-command**.
- **edgex-app-service-configurable** — MQTT export to `tcp://emqx:1883`, topic `edgex/events`.
- **edgex-device-virtual** — Test device.

EdgeX uses Layer A’s EMQX for message bus and export; no separate MQTT broker.

## Integrating EdgeX Events into Layer A

1. **MQTT**: Events appear on EMQX topic `edgex/events`. Use an MQTT→Kafka bridge or EMQX rules to feed Logstash (e.g. HTTP) or produce to `events.raw.mqtt`.
2. **HTTP**: Configure EdgeX app-service with HTTP export to `http://logstash:8088` and payload with `source=edgex` so events land in `events.raw.http` and then `normalized_events`.

See [deployments/layerA/edgex/README.md](../deployments/layerA/edgex/README.md) for run instructions and extension notes.
