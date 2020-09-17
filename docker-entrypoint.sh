#!/bin/bash
# echo commands to the terminal output
set -ex

HADOOP_CMD="$1"
case "$HADOOP_CMD" in

  namenode)
  shift 1
    CMD=(hdfs namenode "$@")
    hdfs namenode -format
    ;;

  datanode)
  shift 1
    CMD=(hdfs datanode "$@")
    ;;

  historyserver)
  shift 1
    CMD=(yarn historyserver "$@")
    ;;

  nodemanager)
  shift 1
    CMD=(yarn nodemanager "$@")
    ;;

  resourcemanager)
  shift 1
    CMD=(yarn resourcemanager "$@")
    ;;

  *)
    echo "Unknown command: $HADOOP_CMD" 1>&2
    exit 1
esac

# Execute the container CMD under tini for better hygiene
env
exec tini -s -- "${CMD[@]}"