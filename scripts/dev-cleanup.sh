#!/usr/bin/env bash
# Sletter dine personlige skjemaer i TEAM_A_DEV (med alt innhold).
# Bruk (fra roten av repoet):  ./scripts/dev-cleanup.sh
set -euo pipefail

DB="${DEV_DATABASE:-TEAM_A_DEV}"
NAME=$(snow sql --format json -q "SELECT REGEXP_REPLACE(UPPER(SPLIT_PART(CURRENT_USER(), '@', 1)), '[^A-Z0-9_]', '_') AS N" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)[0]["N"])')
PREFIX="DEV_${NAME}_"

read -r -p "Slette ${DB}.${PREFIX}BRONZE/SILVER/GOLD/APP med alt innhold? Skriv JA: " SVAR
[ "$SVAR" = "JA" ] || { echo "Avbrutt."; exit 0; }

snow sql -q "
DROP SCHEMA IF EXISTS ${DB}.${PREFIX}BRONZE;
DROP SCHEMA IF EXISTS ${DB}.${PREFIX}SILVER;
DROP SCHEMA IF EXISTS ${DB}.${PREFIX}GOLD;
DROP SCHEMA IF EXISTS ${DB}.${PREFIX}APP;
"
echo "Personlige skjemaer slettet."
