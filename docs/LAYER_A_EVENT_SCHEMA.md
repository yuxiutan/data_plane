# Layer A — NormalizedEvent Schema (v1)

Layer A persists a single **NormalizedEvent v1** contract. All ingested events (syslog, HTTP, MQTT, agent, EdgeX) are normalized to this shape before being written to Postgres and used for routing.

## Schema

```json
{
  "event_id": "uuid",
  "ts": "ISO8601",
  "tenant_id": "string",
  "entity_id": "string",
  "source": "syslog|mqtt|http|agent|edgex",
  "event_type": "string",
  "severity": 0,
  "confidence": 0.0,
  "fields": {}
}
```

| Field        | Type   | Description |
|-------------|--------|-------------|
| `event_id`  | UUID   | Unique event identifier (e.g. generated if not provided). |
| `ts`        | string | Event time in ISO8601. |
| `tenant_id` | string | Tenant / org identifier. |
| `entity_id` | string | Entity identifier (host, user, IP, device, etc.). |
| `source`    | string | One of: `syslog`, `mqtt`, `http`, `agent`, `edgex`. |
| `event_type`| string | Event type or category. |
| `severity`  | int    | 0–5 (e.g. 0=unknown, 1=low, 5=critical). |
| `confidence`| float  | 0–1. |
| `fields`    | object | Arbitrary JSON; all other payload as key-value. |

## Guarantees

- **Schema validation** and **append-only persistence** in `normalized_events`.
- **Routing** and **replayability** from Kafka topics.

## Out of Scope for Layer A

- **Infer risk** — done in Layer B or downstream.
- **Infer TTP** — done in Layer B or downstream.
- **Per-entity inference state** — not maintained in Layer A.
