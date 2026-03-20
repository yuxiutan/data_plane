# EdgeX Optional Profile for Layer A

EdgeX Foundry runs as an **optional** compose profile (`edgex`). When enabled, it acts as a southbound adapter / edge gateway: device events are published to **EMQX** (Layer A's MQTT broker) so they can flow into the same ingestion pipeline (e.g. via MQTT webhook to Logstash or direct Kafka producer).

## Enabling EdgeX

```bash
docker compose --profile edgex up -d
```

This starts (in addition to core Layer A):

- **edgex-database** — Postgres for EdgeX metadata (port 5433)
- **edgex-core-keeper** — EdgeX 3.x registry
- **edgex-core-metadata**, **edgex-core-data**, **edgex-core-command**
- **edgex-app-service-configurable** — MQTT export to `tcp://emqx:1883`, topic `edgex/events`
- **edgex-device-virtual** — Virtual device for testing

EdgeX uses Layer A's **EMQX** for both internal message bus and export. No separate MQTT broker is run.

## Integrating with Layer A

1. **MQTT**: EdgeX app-service publishes device events to EMQX topic `edgex/events`. To ingest into Kafka/Postgres you can:
   - Use EMQX rules to republish to a topic consumed by a small bridge that writes to Logstash HTTP, or
   - Run an MQTT-to-Kafka bridge (e.g. Kafka Connect MQTT source) that reads from `edgex/events` and produces to `events.raw.mqtt`.
2. **HTTP**: Alternatively, have EdgeX app-service use the HTTP export profile and POST to Logstash `http://logstash:8088` with `source=edgex`.

## Extending

- Add more device services (e.g. Modbus, REST) by adding services under `profiles: [edgex]` in `docker-compose.yml`.
- To use a different MQTT export topic or broker, set `BINDING_MQTTEXPORT_PARAMETERS_TOPIC` and `BINDING_MQTTEXPORT_PARAMETERS_BROKERADDRESS` for `edgex-app-service-configurable`.
- If the image does not ship the `mqtt-export` profile, configure the pipeline via environment (e.g. `WRITABLE_PIPELINE_EXECUTIONORDER` and `WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_*`) or mount a custom `configuration.yaml`.

See [LAYER_A_EDGEX_PROFILE.md](../../../docs/LAYER_A_EDGEX_PROFILE.md) for architecture and topic mapping.
