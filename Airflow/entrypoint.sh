#!/usr/bin/env bash
set -e

# Airflow 실행 명령어에 맞는 파라미터 확인
case "$1" in
  "webserver")
    echo "Starting Airflow Webserver..."
    exec airflow webserver
    ;;
  "scheduler")
    echo "Starting Airflow Scheduler..."
    exec airflow scheduler
    ;;
  "worker")
    echo "Starting Airflow Celery Worker..."
    exec airflow celery worker
    ;;
  "triggerer")
    echo "Starting Airflow Triggerer..."
    exec airflow triggerer
    ;;
  "flower")
    echo "Starting Airflow Flower..."
    exec airflow celery flower
    ;;
  *)
    echo "Unknown command: $1"
    echo "Usage: $0 {webserver|scheduler|worker|triggerer|flower}"
    exit 1
    ;;
esac
