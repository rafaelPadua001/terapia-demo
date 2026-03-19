"""add deleted_at

Revision ID: 0002_deleted_at
Revises: 0001_initial
Create Date: 2026-03-17
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = "0002_deleted_at"
down_revision = "0001_initial"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("deleted_at", sa.DateTime(), nullable=True))
    op.add_column("patients", sa.Column("deleted_at", sa.DateTime(), nullable=True))
    op.add_column("guardians", sa.Column("deleted_at", sa.DateTime(), nullable=True))
    op.add_column("anamneses", sa.Column("deleted_at", sa.DateTime(), nullable=True))
    op.add_column("evaluations", sa.Column("deleted_at", sa.DateTime(), nullable=True))
    op.add_column("validations", sa.Column("deleted_at", sa.DateTime(), nullable=True))
    op.add_column("evolutions", sa.Column("deleted_at", sa.DateTime(), nullable=True))


def downgrade() -> None:
    op.drop_column("evolutions", "deleted_at")
    op.drop_column("validations", "deleted_at")
    op.drop_column("evaluations", "deleted_at")
    op.drop_column("anamneses", "deleted_at")
    op.drop_column("guardians", "deleted_at")
    op.drop_column("patients", "deleted_at")
    op.drop_column("users", "deleted_at")
