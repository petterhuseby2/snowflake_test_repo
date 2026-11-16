from snowflake.snowpark import Session


def layer_schema(session: Session, layer: str) -> str:
    """Skjema for et medaljonglag.

    Kjører koden i APP (dev/prod via GitHub), brukes BRONZE/SILVER/GOLD.
    Kjører den i et personlig skjema, f.eks. DEV_PETTER_APP, brukes
    DEV_PETTER_BRONZE osv.
    """
    current = (session.get_current_schema() or "").strip('"').upper()
    prefix = current[: -len("APP")] if current.endswith("APP") else ""
    return f"{prefix}{layer}"


def main(session: Session) -> str:
    db = session.get_current_database()
    table = f"{db}.{layer_schema(session, 'BRONZE')}.EKSEMPEL_INGEST"

    df = session.create_dataframe(
        [[1, "første rad"], [2, "andre rad"]],
        schema=["ID", "VERDI"],
    )
    df.write.mode("overwrite").save_as_table(table)

    return f"Lastet {df.count()} rader til {table}"
