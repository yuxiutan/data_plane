# Layer A — Topic Map

Kafka (Redpanda) topics used by Layer A and downstream (Layer 0, Layer B).

## Topics

| Topic                         | Producer        | Consumer(s)     | Retention (guidance) |
|------------------------------|-----------------|-----------------|----------------------|
| `events.raw.syslog`          | Logstash        | Logstash (→ PG) | 7–14d                |
| `events.raw.http`            | Logstash        | Logstash (→ PG) | 7–14d                |
| `events.raw.mqtt`            | Logstash / bridge | Logstash (→ PG) | 7–14d                |
| `events.norm.security`       | (future norm.)  | Layer 0 / B     | 14–30d               |
| `signals.layer0.risk_inputs` | Layer 0         | Layer B         | 30d                  |
| `results.layerb.hypothesis`  | Layer B         | Downstream      | 30d+                 |

## Partition Key

Use a composite key for ordering and locality:

- **Key**: `tenant_id + ":" + entity_id`  
  Example: `tenant1:host-abc`.

## Creating Topics

Use `scripts/create-topics.sh` (run with `rpk` inside the Redpanda container or with `KAFKA_BOOTSTRAP=localhost:19092` if `rpk` is installed on the host). See [deployments/layerA/README.md](../deployments/layerA/README.md).
