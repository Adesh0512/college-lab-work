#!/usr/bin/env bash
# Clears Hive locks left behind by killed sessions (fixes DROP/queries that hang forever).
source ~/.bashrc 2>/dev/null
cd "$(dirname "$0")"
if pgrep -f org.apache.hadoop.hive.cli.CliDriver >/dev/null; then
  echo "Stopping running Hive sessions first..."; pkill -f org.apache.hadoop.hive.cli.CliDriver; sleep 3
fi
DERBY=$(ls $HIVE_HOME/lib/derby-*.jar | head -1)
[ -f ClearHiveLocks.class ] || javac ClearHiveLocks.java
java -cp ".:$DERBY" ClearHiveLocks
