#!/usr/bin/env bash
# Shared helpers for the BDT Hive experiment runners.
# Each step shows its code on one screen, then runs it on the next screen,
# pausing so a screenshot can be taken. Everything is also logged.

SHOT=0
LOGDIR="$HOME/bdt/logs"; mkdir -p "$LOGDIR"
Y='\e[1;33m'; C='\e[1;36m'; G='\e[1;32m'; D='\e[2m'; N='\e[0m'

banner() {   # banner "Step title"
  clear
  printf "${Y}%s${N}\n" "$EXP_TITLE"
  printf "${C}%s${N}\n\n" "$1"
  printf "\n===== %s | %s =====\n" "$EXP_TITLE" "$1" >> "$LOG"
}
pause() {
  if [ "${NOPAUSE:-0}" = 1 ]; then return; fi
  printf "\n${D}[ screenshot $((++SHOT)) - take it, then press Enter ]${N}"
  read -r _
}
show_code() {   # show_code file...
  for f in "$@"; do
    printf "${G}\$ cat -n %s${N}\n" "$f"
    cat -n "$f"; echo
  done
}
run() {         # run command args...   (echoes the exact command, then runs it)
  printf "${G}\$ %s${N}\n" "$*"
  printf '$ %s\n' "$*" >> "$LOG"
  "$@" 2>&1 | tee -a "$LOG"
  return "${PIPESTATUS[0]}"
}
sub() {        # sub "heading" -> sub-heading on the same screen
  printf "\n${C}--- %s ---${N}\n" "$1"; printf "\n--- %s ---\n" "$1" >> "$LOG"
}
hql() {         # hql step.sql   -> runs a HiveQL file in verbose mode (echoes every query)
  run hive -v --hivevar datadir="$PWD/data" -f "$1"
}
screen() {      # screen N "title"  -> returns 1 (skip) when restarting from a later screen
  [ "${FROM:-1}" -gt "$1" ] && return 1
  SHOT=$(( $1 - 1 )); banner "Part $1 : $2"
}
runsh() {       # runsh "pipeline" -> echoes and runs a shell pipeline
  printf "${G}\$ %s${N}\n" "$1"; printf '$ %s\n' "$1" >> "$LOG"
  bash -c "$1" 2>&1 | tee -a "$LOG"
}
pigrun() {      # pigrun script.pig  -> shows the script, then runs it on the cluster (MapReduce mode)
  printf "${G}\$ cat %s${N}\n" "$1"; cat "$1"; cat "$1" >> "$LOG"; echo
  run pig -x mapreduce -4 "$HOME/bdt/pig/log4j.properties" -f "$1"
}
