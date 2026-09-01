#!/bin/bash
# Dev MySQL for SnowIsland on port 3307, managed as a macOS LaunchAgent
# (com.snowisland.devmysql). The system MySQL on 3306 is untouched.
# Usage: ./scripts/local-mysql.sh start|stop|status|client
set -e

MYSQL_HOME=/usr/local/mysql
# NOTE: must not be a hidden (dot) directory — InnoDB's undo-tablespace scan
# skips hidden paths, which breaks every restart with "Can't create UNDO tablespace".
DATADIR="$HOME/snowisland-mysql-data"
SOCKET="$DATADIR/mysql.sock"
PORT=3307
LABEL=com.snowisland.devmysql
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

case "${1:-}" in
  start)
    if "$MYSQL_HOME/bin/mysqladmin" --no-defaults -uroot --socket="$SOCKET" ping >/dev/null 2>&1; then
      echo "Already running on port $PORT."
      exit 0
    fi
    launchctl bootstrap "gui/$(id -u)" "$PLIST" 2>/dev/null || launchctl kickstart "gui/$(id -u)/$LABEL"
    for i in $(seq 1 20); do
      sleep 1
      if "$MYSQL_HOME/bin/mysqladmin" --no-defaults -uroot --socket="$SOCKET" ping >/dev/null 2>&1; then
        echo "Dev MySQL started on port $PORT (datadir: $DATADIR)."
        exit 0
      fi
    done
    echo "Failed to start; see $DATADIR/mysqld.err" >&2
    exit 1
    ;;
  stop)
    launchctl bootout "gui/$(id -u)/$LABEL"
    echo "Stopped (will not auto-restart until 'start' or next login)."
    ;;
  status)
    if "$MYSQL_HOME/bin/mysqladmin" --no-defaults -uroot --socket="$SOCKET" ping >/dev/null 2>&1; then
      echo "Running on port $PORT."
    else
      echo "Not running."
    fi
    ;;
  client)
    exec "$MYSQL_HOME/bin/mysql" --no-defaults -uroot --socket="$SOCKET" --default-character-set=utf8mb4 snowisland
    ;;
  *)
    echo "Usage: $0 start|stop|status|client" >&2
    exit 1
    ;;
esac
