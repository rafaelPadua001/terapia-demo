"""add user phone and specialty

Revision ID: 0016_add_user_phone_specialty
Revises: 0015_patient_guardians_nn
Create Date: 2026-04-08
"""

from alembic import op
import sqlalchemy as sa


revision = "0016_add_user_phone_specialty"
down_revision = "0015_patient_guardians_nn"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("phone", sa.String(length=50), nullable=True))
    op.add_column("users", sa.Column("specialty", sa.String(length=255), nullable=True))


def downgrade() -> None:
    op.drop_column("users", "specialty")
    op.drop_column("users", "phone")
