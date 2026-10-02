#!/bin/sh
# Lab 5 — simulated service controller
# Usage: sh svc.sh {start|stop|restart|status} <service>
action="${1:-}"
service="${2:-}"

usage() {
    echo "Usage: $0 {start|stop|restart|status} <service>" >&2
    exit 2
}

[ -n "$service" ] || usage
pidfile="/tmp/$service.pid"

case "$action" in
    start)
        if [ -f "$pidfile" ]; then
            echo "$service already running (pid $(cat "$pidfile"))"
        else
            echo "$$" > "$pidfile"
            echo "$service started (pid $$)"
        fi
        ;;
    stop)
        if [ -f "$pidfile" ]; then
            rm -f "$pidfile"
            echo "$service stopped"
        else
            echo "$service is not running"
        fi
        ;;
    restart)
        sh "$0" stop "$service"
        sh "$0" start "$service"
        ;;
    status)
        if [ -f "$pidfile" ]; then
            echo "$service is RUNNING (pid $(cat "$pidfile"))"
        else
            echo "$service is STOPPED"
            exit 3
        fi
        ;;
    *)
        usage
        ;;
esac
