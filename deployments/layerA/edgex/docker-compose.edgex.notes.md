# EdgeX Profile — Compose Notes

All EdgeX services are defined in the **main** `docker-compose.yml` under `profiles: [edgex]`. There is no separate `docker-compose.edgex.yml`; use:

```bash
docker compose --profile edgex up -d
```

- **Network**: EdgeX services join the same `layera` network so they can reach `emqx`, `redpanda`, etc.
- **Ports**: EdgeX Postgres uses 5433 to avoid conflict with Layer A Postgres (5432).
- **MQTT**: `MESSAGEBUS_HOST=emqx`, `MESSAGEBUS_PORT=1883` so EdgeX uses Layer A's EMQX.
- **Export**: App-service-configurable is configured to publish to `tcp://emqx:1883` topic `edgex/events`. If the image does not support the `mqtt-export` profile out of the box, add a custom profile or mount configuration (see EdgeX App Service Configurable docs).
