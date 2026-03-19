"""add patient email

Revision ID: 0011_patient_email
Revises: 0010_expand_varchar_sizes
Create Date: 2026-03-19
"""

from alembic import op
from sqlalchemy import inspect
import sqlalchemy as sa


revision = "0011_patient_email"
down_revision = "0010_expand_varchar_sizes"
branch_labels = None
depends_on = None


def upgrade() -> None:
    conn = op.get_bind()
    inspector = inspect(conn)
    columns = [col["name"] for col in inspector.get_columns("patients")]

    if "email" not in columns:
        op.add_column("patients", sa.Column("email", sa.String(length=255), nullable=True))


def downgrade() -> None:
    conn = op.get_bind()
    inspector = inspect(conn)
    columns = [col["name"] for col in inspector.get_columns("patients")]

    if "email" in columns:
        op.drop_column("patients", "email")
