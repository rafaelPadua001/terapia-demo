"""expand varchar sizes

Revision ID: 0010_expand_varchar_sizes
Revises: 0009_fix_alembic_version_size
Create Date: 2026-03-18
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = "0010_expand_varchar_sizes"
down_revision = "0009_fix_alembic_version_size"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.alter_column(
        "users",
        "role",
        existing_type=sa.String(length=50),
        type_=sa.String(length=64),
    )
    op.alter_column(
        "evaluations",
        "status",
        existing_type=sa.String(length=50),
        type_=sa.String(length=64),
    )
    op.alter_column(
        "appointments",
        "status",
        existing_type=sa.String(length=50),
        type_=sa.String(length=64),
    )
    op.alter_column(
        "guardians",
        "relationship_type",
        existing_type=sa.String(length=100),
        type_=sa.String(length=128),
    )


def downgrade() -> None:
    op.alter_column(
        "users",
        "role",
        existing_type=sa.String(length=64),
        type_=sa.String(length=50),
    )
    op.alter_column(
        "evaluations",
        "status",
        existing_type=sa.String(length=64),
        type_=sa.String(length=50),
    )
    op.alter_column(
        "appointments",
        "status",
        existing_type=sa.String(length=64),
        type_=sa.String(length=50),
    )
    op.alter_column(
        "guardians",
        "relationship_type",
        existing_type=sa.String(length=128),
        type_=sa.String(length=100),
    )
