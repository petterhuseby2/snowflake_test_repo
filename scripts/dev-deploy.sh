#!/usr/bin/env bash
# Deployer koden til dine personlige skjemaer i TEAM_A_DEV, så du kan teste i
# Snowflake før du lager PR. Skjemaene opprettes automatisk første gang:
#   DEV_<NAVN>_BRONZE, DEV_<NAVN>_SILVER, DEV_<NAVN>_GOLD, DEV_<NAVN>_APP
#
# Krever en Snowflake CLI-tilkobling (standard: "default") med rollen
# TEAM_A_DEVELOPER. Se ~/.snowflake/config.toml i guiden.
#
# Bruk (fra roten av repoet):  ./scripts/dev-deploy.sh
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

DB="${DEV_DATABASE:-TEAM_A_DEV}"
WH="${DEV_WAREHOUSE:-TEAM_A_DEV_WH}"

# Personlig prefiks fra Snowflake-brukeren, f.eks. PETTER.HUSEBY@KNOWIT.NO -> DEV_PETTER_HUSEBY_
NAME=$(snow sql --format json -q "SELECT REGEXP_REPLACE(UPPER(SPLIT_PART(CURRENT_USER(), '@', 1)), '[^A-Z0-9_]', '_') AS N" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)[0]["N"])')
PREFIX="DEV_${NAME}_"
echo "Personlige skjemaer: ${DB}.${PREFIX}{BRONZE,SILVER,GOLD,APP}"

# Opprett skjemaene hvis de ikke finnes (gjør ingenting hvis de finnes)
snow sql -q "
CREATE SCHEMA IF NOT EXISTS ${DB}.${PREFIX}BRONZE;
CREATE SCHEMA IF NOT EXISTS ${DB}.${PREFIX}SILVER;
CREATE SCHEMA IF NOT EXISTS ${DB}.${PREFIX}GOLD;
CREATE SCHEMA IF NOT EXISTS ${DB}.${PREFIX}APP;
" >/dev/null

export SNOWFLAKE_DATABASE="$DB"
export SNOWFLAKE_SCHEMA="${PREFIX}APP"
export SNOWFLAKE_WAREHOUSE="$WH"

snow snowpark build --project ingest
snow snowpark deploy --replace --project ingest
snow streamlit deploy --replace --project streamlit

# Røyktest: kjør procedure-en med det personlige APP-skjemaet som gjeldende skjema
snow sql -q "USE WAREHOUSE ${WH}; USE SCHEMA ${DB}.${PREFIX}APP; CALL LOAD_DATA();"

echo
echo "Ferdig. Appen finner du i Snowsight under Projects -> Streamlit -> TEAM_A_DASHBOARD (${DB}.${PREFIX}APP)."
