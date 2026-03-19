"""fix alembic version column size

Revision ID: 0009_fix_alembic_version_size
Revises: 0008_appointments_fields
Create Date: 2026-03-18
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = "0009_fix_alembic_version_size"
down_revision = "0008_appointments_fields"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.alter_column(
        "alembic_version",
        "version_num",
        type_=sa.String(length=64),
    )


def downgrade() -> None:
    op.alter_column(
        "alembic_version",
        "version_num",
        type_=sa.String(length=32),
    )
