import os
import sys
from sqlalchemy import create_engine, text

sys.path.append(os.path.join(os.path.dirname(__file__), "..", "backend"))

from app.core.config import settings  # noqa: E402


def main():
    print("Testando config...")
    print(f"DATABASE_URL: {settings.database_url}")
    print("Conectando no banco...")
    engine = create_engine(settings.database_url, pool_pre_ping=True)
    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))
    print("OK: Conexao com PostgreSQL estabelecida")


if __name__ == "__main__":
    main()
