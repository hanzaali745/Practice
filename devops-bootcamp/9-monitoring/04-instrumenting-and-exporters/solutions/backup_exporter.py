"""backup_exporter.py — a custom Prometheus exporter written with the official prometheus_client library.

It looks at a backup folder EVERY TIME Prometheus scrapes it (a custom collector), and reports:
  backup_files                          how many backups exist
  backup_latest_timestamp_seconds       when the newest backup was written (alert if it's too old!)
  backup_latest_size_bytes              size of the newest backup (alert if suspiciously small)
  backup_total_size_bytes               disk used by all backups

Usage:  python3 backup_exporter.py /path/to/backups [port]      →  http://localhost:9300/metrics
"""
import sys
import time
from pathlib import Path

from prometheus_client import start_http_server
from prometheus_client.core import REGISTRY, GaugeMetricFamily
from prometheus_client.registry import Collector


class BackupCollector(Collector):
    def __init__(self, folder: Path) -> None:
        self.folder = folder

    def collect(self):
        files = [p for p in self.folder.glob("*") if p.is_file()]
        newest = max(files, key=lambda p: p.stat().st_mtime, default=None)
        labels = [str(self.folder)]

        count = GaugeMetricFamily("backup_files", "Number of backup files.", labels=["folder"])
        count.add_metric(labels, len(files))
        yield count

        total = GaugeMetricFamily("backup_total_size_bytes", "Size of all backups.", labels=["folder"])
        total.add_metric(labels, sum(p.stat().st_size for p in files))
        yield total

        if newest is not None:                      # no backups → no series → absent() alerts can fire
            ts = GaugeMetricFamily("backup_latest_timestamp_seconds", "When the newest backup was written.",
                                   labels=["folder"])
            ts.add_metric(labels, newest.stat().st_mtime)
            yield ts
            size = GaugeMetricFamily("backup_latest_size_bytes", "Size of the newest backup.", labels=["folder"])
            size.add_metric(labels, newest.stat().st_size)
            yield size


def main() -> None:
    folder = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("backups")
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 9300
    if not folder.is_dir():
        sys.exit(f"not a folder: {folder}")
    REGISTRY.register(BackupCollector(folder))
    start_http_server(port)                         # also exports python_* and process_* metrics for free
    print(f"backup exporter for {folder} on :{port}/metrics", flush=True)
    while True:
        time.sleep(3600)


if __name__ == "__main__":
    main()
