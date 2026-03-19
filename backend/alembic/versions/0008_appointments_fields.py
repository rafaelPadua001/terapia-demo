"""appointments fields

Revision ID: 0008_appointments_fields
Revises: 0007_rbac_users_guardian_patients
Create Date: 2026-03-18
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = "0008_appointments_fields"
down_revision = "0007_rbac_users_guardian_patients"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("appointments", sa.Column("date", sa.Date(), nullable=True))
    op.add_column("appointments", sa.Column("time", sa.Time(), nullable=True))
    op.add_column("appointments", sa.Column("type", sa.String(length=100), nullable=True))
    op.add_column("appointments", sa.Column("is_first_visit", sa.Boolean(), nullable=False, server_default=sa.text("false")))
    op.execute("UPDATE appointments SET date = scheduled_at::date, time = scheduled_at::time WHERE scheduled_at IS NOT NULL")
    op.alter_column("appointments", "is_first_visit", server_default=None)


def downgrade() -> None:
    op.drop_column("appointments", "is_first_visit")
    op.drop_column("appointments", "type")
    op.drop_column("appointments", "time")
    op.drop_column("appointments", "date")
