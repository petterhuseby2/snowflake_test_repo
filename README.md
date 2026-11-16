# snowflake_petter

CI/CD for TEAM_A mot Snowflake med GitHub Actions og OIDC (workload identity).

## Innhold

| Mappe / fil | Hva |
|---|---|
| `ingest/` | Snowpark-procedure `APP.LOAD_DATA` (Python) |
| `streamlit/` | Streamlit-appen `APP.TEAM_A_DASHBOARD` |
| `.github/workflows/deploy.yml` | Deploy til dev på PR, til prod ved merge til `main` |
| `.github/workflows/test-connection.yml` | Manuell test av OIDC-tilkoblingen |
| `scripts/` | Test i eget skjema i dev før PR (`dev-deploy.sh`, `dev-cleanup.sh`) |

## Miljøer

| GitHub environment | Database | Rolle | Warehouse |
|---|---|---|---|
| `dev` | `TEAM_A_DEV` | `TEAM_A_DEV_DEPLOYER` | `TEAM_A_DEV_WH` |
| `prod` | `TEAM_A_PROD` | `TEAM_A_PROD_DEPLOYER` | `TEAM_A_PROD_WH` |

Variablene `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_DATABASE`, `SNOWFLAKE_ROLE` og
`SNOWFLAKE_WAREHOUSE` ligger i hvert environment. Ingen secrets trengs.

## Test i eget skjema før PR

```bash
./scripts/dev-deploy.sh     # deployer til TEAM_A_DEV.DEV_<NAVN>_* og kjører LOAD_DATA
./scripts/dev-cleanup.sh    # sletter de personlige skjemaene
```

Krever en Snowflake CLI-tilkobling med rollen `TEAM_A_DEVELOPER`.

## Arbeidsflyt

```bash
git checkout main && git pull
git checkout -b feature/min-endring
# gjør endringene
git status
git add -A
git commit -m "Beskrivelse av endringen"
git push -u origin feature/min-endring
gh pr create --fill --base main
gh pr checks --watch          # deploy-dev mot TEAM_A_DEV
gh pr merge --squash --delete-branch
gh run watch                  # deploy-prod mot TEAM_A_PROD
```

## Test tilkoblingen

```bash
gh workflow run test-connection.yml -f environment=dev
gh run watch
```
