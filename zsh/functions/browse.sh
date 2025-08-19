#!/bin/zsh

browse() {
  local SERVICE=$1
  shift

  local URL=""
  case "$SERVICE" in
    gcloud)
      local SUBSERVICE=$1
      shift
      case "$SUBSERVICE" in
        logs)
          local PROJECT="" QUERY=""
          while [[ $# -gt 0 ]]; do
            case $1 in
              -project) PROJECT=$2; shift 2;;
              -query) QUERY=$2; shift 2;;
              *) shift;;
            esac
          done
          URL="https://console.cloud.google.com/logs/query;query=${QUERY}?project=${PROJECT}"
          ;;
        bigquery)
          local PROJECT=""
          while [[ $# -gt 0 ]]; do
            case $1 in
              -project) PROJECT=$2; shift 2;;
              *) shift;;
            esac
          done
          URL="https://console.cloud.google.com/bigquery?project=${PROJECT}"
          ;;
        spanner)
          local PROJECT="" INSTANCE="" DB=""
          while [[ $# -gt 0 ]]; do
            case $1 in
              -project) PROJECT=$2; shift 2;;
              -instance) INSTANCE=$2; shift 2;;
              -database) DB=$2; shift 2;;
              *) shift;;
            esac
          done
          URL="https://console.cloud.google.com/spanner/instances/${INSTANCE}/databases/${DB}?project=${PROJECT}"
          ;;
        *)
          echo "Unknown gcloud subservice: $SUBSERVICE"
          return 1
          ;;
      esac
      ;;
    github)
      local ORG="" REPO=""
      while [[ $# -gt 0 ]]; do
        case $1 in
          -org) ORG=$2; shift 2;;
          -repository) REPO=$2; shift 2;;
          *) shift;;
        esac
      done
      URL="https://github.com/${ORG}/${REPO}"
      ;;
    *)
      echo "Unknown service: $SERVICE"
      return 1
      ;;
  esac

  # ブラウザで開く
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open "$URL"
  else
    xdg-open "$URL"
  fi
}
