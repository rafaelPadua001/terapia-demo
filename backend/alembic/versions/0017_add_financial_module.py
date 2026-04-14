"""add financial module tables

Revision ID: 0017_add_financial_module
Revises: 0016_add_user_phone_specialty
Create Date: 2026-04-14
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision = "0017_add_financial_module"
down_revision = "0016_add_user_phone_specialty"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "financial_accounts",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("clinic_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("name", sa.String(length=255), nullable=False),
        sa.Column("type", sa.String(length=30), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("metadata", sa.JSON(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["clinic_id"], ["clinics.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_financial_accounts_clinic_id", "financial_accounts", ["clinic_id"])

    op.create_table(
        "financial_transactions",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("clinic_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("patient_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("guardian_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("description", sa.String(length=255), nullable=False),
        sa.Column("amount", sa.Float(), nullable=False),
        sa.Column("status", sa.String(length=30), nullable=False, server_default=sa.text("'pending'")),
        sa.Column("due_date", sa.DateTime(), nullable=False),
        sa.Column("paid_at", sa.DateTime(), nullable=True),
        sa.Column("payment_method", sa.String(length=30), nullable=False, server_default=sa.text("'pix'")),
        sa.Column("account_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("external_id", sa.String(length=255), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.text("now()")),
        sa.ForeignKeyConstraint(["account_id"], ["financial_accounts.id"]),
        sa.ForeignKeyConstraint(["clinic_id"], ["clinics.id"]),
        sa.ForeignKeyConstraint(["guardian_id"], ["guardians.id"]),
        sa.ForeignKeyConstraint(["patient_id"], ["patients.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_financial_transactions_clinic_id", "financial_transactions", ["clinic_id"])
    op.create_index("ix_financial_transactions_patient_id", "financial_transactions", ["patient_id"])
    op.create_index("ix_financial_transactions_guardian_id", "financial_transactions", ["guardian_id"])
    op.create_index("ix_financial_transactions_account_id", "financial_transactions", ["account_id"])
    op.create_index("ix_financial_transactions_status", "financial_transactions", ["status"])
    op.create_index("ix_financial_transactions_due_date", "financial_transactions", ["due_date"])


def downgrade() -> None:
    op.drop_index("ix_financial_transactions_due_date", table_name="financial_transactions")
    op.drop_index("ix_financial_transactions_status", table_name="financial_transactions")
    op.drop_index("ix_financial_transactions_account_id", table_name="financial_transactions")
    op.drop_index("ix_financial_transactions_guardian_id", table_name="financial_transactions")
    op.drop_index("ix_financial_transactions_patient_id", table_name="financial_transactions")
    op.drop_index("ix_financial_transactions_clinic_id", table_name="financial_transactions")
    op.drop_table("financial_transactions")

    op.drop_index("ix_financial_accounts_clinic_id", table_name="financial_accounts")
    op.drop_table("financial_accounts")
