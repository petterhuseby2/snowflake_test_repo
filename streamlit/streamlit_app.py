import streamlit as st
from snowflake.snowpark.context import get_active_session

session = get_active_session()
db = session.get_current_database()
app_schema = (session.get_current_schema() or "").strip('"').upper()

# Samme regel som i load_data.py: APP -> BRONZE, DEV_PETTER_APP -> DEV_PETTER_BRONZE
prefix = app_schema[: -len("APP")] if app_schema.endswith("APP") else ""
bronze = f"{prefix}BRONZE"

st.title("TEAM_A - dashboard")
st.caption(f"Database: {db} - skjema: {bronze}")

try:
    df = session.table(f"{db}.{bronze}.EKSEMPEL_INGEST").to_pandas()
    st.dataframe(df)
except Exception:
    st.info(f"Tabellen finnes ikke ennå. Kjør CALL {app_schema}.LOAD_DATA(); først.")
