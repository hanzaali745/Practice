# ELK Module 03 — Shipping & Parsing Logs 🟡

## 🎯 Objectives
- Ship every container's logs with **Filebeat** (and know the alternatives: Fluent Bit, Elastic Agent)
- Enrich logs with **Docker metadata** and keep only what you need
- Build a **Logstash** pipeline: input → filter → output
- Parse JSON logs directly and plain-text logs with **grok**; fix timestamps with **date**
- Normalise everything to **one schema (ECS)** so app and nginx logs can be searched together
- Find and fix parse failures

## 🧠 Why DevOps engineers care
Logs are written in a dozen formats by apps, web servers, databases and the OS. Getting them all into one searchable
place — reliably, without losing lines, with consistent field names — is the hard part of centralised logging, and it's
DevOps work. The search in Kibana is only as good as the parsing that happened before it.

---

## 📖 Lesson 3.1 — The pipeline in this module

```
 app ×2 (JSON on stdout) ──┐  Docker json-file logs                    ┌─ JSON → fields
                           ├─► /var/lib/docker/containers/*/*.log ──► Filebeat ──► Logstash ┤
 nginx (text on stdout) ───┘          + Docker metadata                          └─ grok → fields ──► Elasticsearch
```
```bash
cd ~/Practice/devops-bootcamp/10-elk/03-shipping-and-parsing/solutions
docker compose up -d --build            # wait ~2 minutes for logs to flow
./verify.sh
```

## 📖 Lesson 3.2 — Filebeat

[`filebeat/filebeat.yml`](solutions/filebeat/filebeat.yml):
```yaml
filebeat.inputs:
  - type: filestream
    id: docker-containers
    paths: ["/var/lib/docker/containers/*/*.log"]
    parsers:
      - container: ~                       # unwrap Docker's own JSON wrapper
processors:
  - add_docker_metadata: ~                 # container.name, image, compose labels
  - drop_event:
      when.not.or:
        - equals: {container.labels.com_docker_compose_service: app}
        - equals: {container.labels.com_docker_compose_service: nginx}
output.logstash:
  hosts: ["logstash:5044"]
```
Filebeat keeps a **registry** (which file, which byte) so it resumes after a restart without losing or duplicating
lines — that's why it has a volume. If Logstash or Elasticsearch is down, it waits and retries (**back-pressure**).

| Shipper | Strengths |
|---------|-----------|
| **Filebeat** | light, Elastic-native, modules for nginx/system/etc. |
| **Fluent Bit** | tiny (C), vendor-neutral, very common on Kubernetes (Module 06) |
| **Elastic Agent** | one agent for logs + metrics + security, managed centrally by Fleet |

## 📖 Lesson 3.3 — Logstash: input → filter → output

[`logstash/pipeline/demo.conf`](solutions/logstash/pipeline/demo.conf):
```ruby
input  { beats { port => 5044 } }
filter {
  if [container][labels][com_docker_compose_service] == "app" {
    json { source => "message" }                       # demo-app already writes ECS JSON
  } else if [container][labels][com_docker_compose_service] == "nginx" {
    grok { match => { "message" => [ '<access log pattern>', '<error log pattern>' ] } }
    date { match => ["[@metadata][ts]", "dd/MMM/yyyy:HH:mm:ss Z", "yyyy/MM/dd HH:mm:ss"] }
    mutate { add_field => { "[service][name]" => "nginx" } }
  }
  mutate { remove_field => ["agent", "ecs", "input"] }
}
output { elasticsearch { hosts => ["http://elasticsearch:9200"]
                         index => "demo-logs-%{[service][name]}-%{+YYYY.MM.dd}" } }
```
Fields under `[@metadata]` are available inside the pipeline but never stored — perfect for temporary values.

## 📖 Lesson 3.4 — Grok

Grok = named regular expressions. `%{PATTERN:field}` captures, `:int` converts:
```
172.20.0.6 - - [03/Oct/2026:07:34:33 +0000] "GET /work?ms=300 HTTP/1.1" 200 65 "-" "Python-urllib/3.12"
%{IPORHOST:[client][ip]} - %{DATA:[user][name]} \[%{HTTPDATE:[@metadata][ts]}\] "%{WORD:[http][request][method]} %{DATA:[url][original]} HTTP/%{NUMBER:[http][version]}" %{NUMBER:[http][response][status_code]:int} ...
```
Lines that match no pattern get a tag (`_grokparsefailure_nginx`) instead of being dropped — **always count them**.
In this lab the first run left 18 unparsed lines: nginx's error-log format (`2026/10/03 07:32:13 [notice] …`). A second
pattern fixed 10 of them; the remaining 8 are start-up messages from the image's entrypoint script. Debug patterns with
Kibana's **Dev Tools → Grok Debugger**.

## 📖 Lesson 3.5 — Parse where?

| Option | When |
|--------|------|
| **App writes JSON** (demo-app) | best: no parsing, no regex to maintain |
| **Logstash** | complex routing, enrichment (lookups, GeoIP), many outputs, heavy parsing |
| **Elasticsearch ingest pipeline** | simple parsing without running Logstash (`grok`, `date`, `rename` processors) |
| **Filebeat/Fluent Bit processors** | light changes at the edge (drop, add fields, decode JSON) |

---

## ⚠️ Common mistakes
- Not mounting the Filebeat registry → duplicates after every restart
- Shipping every container on the host (including the logging stack's own chatty logs)
- Timestamps from ingest time instead of the log line (`date` filter missing) — events appear at the wrong time
- Grok failures silently piling up; one giant regex per format instead of small reusable patterns
- Different field names per team (`status`, `statusCode`, `http_status`) — adopt ECS

---

## 🧪 Labs
Solutions: [`solutions/`](solutions/) — `docker compose up -d --build`, wait 2 minutes, `./verify.sh`.

### Lab 1 ⭐ — Ship it
Run Filebeat reading the Docker log files with the `container` parser and `add_docker_metadata`, sending to Logstash
with a pipeline that only has `input` and `output`. Look at a raw document — which fields did Filebeat add?

### Lab 2 ⭐⭐ — Filter and parse JSON
Drop everything except the `app` and `nginx` services. Parse demo-app's JSON so `http.response.status_code` and
`url.path` become real fields, and the event time comes from the log line.

### Lab 3 ⭐⭐⭐ — Grok nginx
Write the grok pattern for nginx's access log with ECS field names and `:int` conversions, a `date` filter, and a
`log.level` derived from the status code. Count `_grokparsefailure_nginx` documents, find out what they are, and add a
pattern for nginx's error log.

### Lab 4 ⭐⭐ — Index per service and day
Write `demo-logs-<service>-<date>` indices with an index template from Module 02 (installed by a one-shot `setup`
service). Show that one aggregation can count errors across both services because the fields match.

---

## ✅ Checkpoint
- [ ] I can ship container logs with Filebeat, enriched with Docker metadata, and know its registry
- [ ] I can write Logstash pipelines with conditionals, json, grok, date and mutate
- [ ] I count and fix parse failures instead of ignoring them
- [ ] I normalise different sources to ECS so they can be searched together

👉 Next: [Module 04 — Kibana](../04-kibana/README.md)
