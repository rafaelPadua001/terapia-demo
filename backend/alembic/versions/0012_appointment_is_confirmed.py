"""add appointment is_confirmed

Revision ID: 0012_appointment_is_confirmed
Revises: 0011_patient_email
Create Date: 2026-03-19
"""

from alembic import op
from sqlalchemy import inspect
import sqlalchemy as sa


revision = "0012_appointment_is_confirmed"
down_revision = "0011_patient_email"
branch_labels = None
depends_on = None


def upgrade() -> None:
    conn = op.get_bind()
    inspector = inspect(conn)
    columns = [col["name"] for col in inspector.get_columns("appointments")]

    if "is_confirmed" not in columns:
        op.add_column(
            "appointments",
            sa.Column("is_confirmed", sa.Boolean(), nullable=False, server_default="false"),
        )
    if "confirmed_at" not in columns:
        op.add_column("appointments", sa.Column("confirmed_at", sa.DateTime(), nullable=True))
    if "confirmed_by" not in columns:
        op.add_column("appointments", sa.Column("confirmed_by", sa.UUID(), nullable=True))
        op.create_foreign_key(
            "fk_appointments_confirmed_by_users",
            "appointments",
            "users",
            ["confirmed_by"],
            ["id"],
        )


def downgrade() -> None:
    conn = op.get_bind()
    inspector = inspect(conn)
    columns = [col["name"] for col in inspector.get_columns("appointments")]

    if "confirmed_by" in columns:
        op.drop_constraint("fk_appointments_confirmed_by_users", "appointments", type_="foreignkey")
        op.drop_column("appointments", "confirmed_by")
    if "confirmed_at" in columns:
        op.drop_column("appointments", "confirmed_at")
    if "is_confirmed" in columns:
        op.drop_column("appointments", "is_confirmed")
