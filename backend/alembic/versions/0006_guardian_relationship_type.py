"""rename guardian relationship column

Revision ID: 0006_guardian_relationship_type
Revises: 0005_appointments_phone_guardian
Create Date: 2026-03-18
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect

# revision identifiers, used by Alembic.
revision = "0006_guardian_relationship_type"
down_revision = "0005_appointments_phone_guardian"
branch_labels = None
depends_on = None


def upgrade() -> None:
    conn = op.get_bind()
    inspector = inspect(conn)
    columns = [col["name"] for col in inspector.get_columns("guardians")]

    if "relationship_type" in columns and "relationship" in columns:
        op.execute("UPDATE guardians SET relationship_type = relationship WHERE relationship_type IS NULL")
        op.drop_column("guardians", "relationship")
        return
    if "relationship_type" in columns:
        return
    if "relationship" in columns:
        op.alter_column(
            "guardians",
            "relationship",
            new_column_name="relationship_type",
            existing_type=sa.String(length=100),
            existing_nullable=True,
        )
        return

    op.add_column("guardians", sa.Column("relationship_type", sa.String(length=100), nullable=True))


def downgrade() -> None:
    conn = op.get_bind()
    inspector = inspect(conn)
    columns = [col["name"] for col in inspector.get_columns("guardians")]

    if "relationship" in columns and "relationship_type" in columns:
        return
    if "relationship" in columns:
        return
    if "relationship_type" in columns:
        op.alter_column(
            "guardians",
            "relationship_type",
            new_column_name="relationship",
            existing_type=sa.String(length=100),
            existing_nullable=True,
        )
        return

    op.add_column("guardians", sa.Column("relationship", sa.String(length=100), nullable=True))
