"""add email confirmation to users

Revision ID: 0013_add_email_confirmation
Revises: 0012_appointment_is_confirmed
Create Date: 2026-03-19
"""

from alembic import op
from sqlalchemy import inspect
import sqlalchemy as sa


revision = "0013_add_email_confirmation"
down_revision = "0012_appointment_is_confirmed"
branch_labels = None
depends_on = None


def upgrade() -> None:
    conn = op.get_bind()
    inspector = inspect(conn)
    columns = [col["name"] for col in inspector.get_columns("users")]

    if "email_is_confirmed" not in columns:
        op.add_column(
            "users",
            sa.Column("email_is_confirmed", sa.Boolean(), nullable=False, server_default="false"),
        )


def downgrade() -> None:
    conn = op.get_bind()
    inspector = inspect(conn)
    columns = [col["name"] for col in inspector.get_columns("users")]

    if "email_is_confirmed" in columns:
        op.drop_column("users", "email_is_confirmed")
