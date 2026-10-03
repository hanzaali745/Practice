"""setup.py — everything Elasticsearch needs before data arrives (idempotent; runs as a one-shot container).

  * passwords for the built-in kibana_system user
  * ILM policy (rollover daily, delete after 14 days) + data stream template with ECS mappings
  * least-privilege roles and users: logstash_writer (append only), log_alerter (read), dev (read + Kibana)
"""
import base64
import json
import os
import time
import urllib.error
import urllib.request

ES = os.environ.get("ES_URL", "http://elasticsearch:9200")
AUTH = base64.b64encode(f"elastic:{os.environ['ELASTIC_PASSWORD']}".encode()).decode()
PATTERNS = ["logs-demoapp-*", "logs-nginx-*"]


def es(method: str, path: str, body: dict | None = None) -> dict:
    req = urllib.request.Request(ES + path, method=method, data=json.dumps(body).encode() if body else None,
                                 headers={"Authorization": f"Basic {AUTH}", "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)


def step(name: str, method: str, path: str, body: dict | None = None) -> None:
    es(method, path, body)
    print(f"✅ {name}", flush=True)


for _ in range(90):
    try:
        es("GET", "/_cluster/health?wait_for_status=yellow&timeout=5s")
        break
    except (urllib.error.URLError, OSError):
        time.sleep(2)

step("kibana_system password", "POST", "/_security/user/kibana_system/_password",
     {"password": os.environ["KIBANA_PASSWORD"]})

step("ILM policy logs-demo-14d", "PUT", "/_ilm/policy/logs-demo-14d", {"policy": {"phases": {
    "hot": {"actions": {"rollover": {"max_age": "1d", "max_primary_shard_size": "10gb"}}},
    "delete": {"min_age": "14d", "actions": {"delete": {}}}}}})

keyword = {"type": "keyword"}
step("data stream template logs-demo", "PUT", "/_index_template/logs-demo", {
    "index_patterns": PATTERNS, "data_stream": {}, "priority": 500,
    "template": {
        "settings": {"number_of_replicas": 0, "index.lifecycle.name": "logs-demo-14d"},
        "mappings": {"properties": {
            "@timestamp": {"type": "date"}, "message": {"type": "text"},
            "log": {"properties": {"level": keyword}},
            "service": {"properties": {"name": keyword, "version": keyword}},
            "host": {"properties": {"name": keyword}},
            "container": {"properties": {"name": keyword}},
            "url": {"properties": {"path": keyword, "original": keyword}},
            "http": {"properties": {"request": {"properties": {"method": keyword}},
                                    "response": {"properties": {"status_code": {"type": "short"}}}}},
            "event": {"properties": {"duration": {"type": "long"}}},
            "client": {"properties": {"ip": {"type": "ip"}}},
            "user_agent": {"properties": {"original": keyword}}}}}})

step("role logstash_writer", "PUT", "/_security/role/logstash_writer", {
    "cluster": ["monitor"],
    "indices": [{"names": PATTERNS, "privileges": ["create_doc", "auto_configure"]}]})
step("role logs_reader", "PUT", "/_security/role/logs_reader", {
    "indices": [{"names": PATTERNS, "privileges": ["read", "view_index_metadata"]}],
    "applications": [{"application": "kibana-.kibana",
                      "privileges": ["feature_discover.read", "feature_dashboard.read"], "resources": ["*"]}]})
step("user logstash_internal", "PUT", "/_security/user/logstash_internal",
     {"password": os.environ["LOGSTASH_PASSWORD"], "roles": ["logstash_writer"]})
step("user log_alerter", "PUT", "/_security/user/log_alerter",
     {"password": os.environ["ALERTER_PASSWORD"], "roles": ["logs_reader"]})
step("user dev", "PUT", "/_security/user/dev",
     {"password": os.environ["DEV_PASSWORD"], "roles": ["logs_reader"], "full_name": "A Developer"})
