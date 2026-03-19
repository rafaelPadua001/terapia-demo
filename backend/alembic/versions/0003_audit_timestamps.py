"""audit and timestamps

Revision ID: 0003_audit_timestamps
Revises: 0002_deleted_at
Create Date: 2026-03-17
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = "0003_audit_timestamps"
down_revision = "0002_deleted_at"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("patients", sa.Column("created_by", postgresql.UUID(as_uuid=True), nullable=False))
    op.add_column("patients", sa.Column("updated_by", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("patients", sa.Column("updated_at", sa.DateTime(), nullable=True))

    op.add_column("anamneses", sa.Column("updated_by", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("anamneses", sa.Column("updated_at", sa.DateTime(), nullable=True))

    op.add_column("evaluations", sa.Column("updated_by", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("evaluations", sa.Column("updated_at", sa.DateTime(), nullable=True))

    op.add_column("evolutions", sa.Column("updated_by", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("evolutions", sa.Column("updated_at", sa.DateTime(), nullable=True))

    op.create_table(
        "audit_logs",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("clinic_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("action", sa.String(length=100), nullable=False),
        sa.Column("entity", sa.String(length=100), nullable=False),
        sa.Column("entity_id", sa.String(length=64), nullable=False),
        sa.Column("meta", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["clinic_id"], ["clinics.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
    )

    op.create_index("ix_patients_clinic_id", "patients", ["clinic_id"])
    op.create_index("ix_anamneses_clinic_id", "anamneses", ["clinic_id"])
    op.create_index("ix_evaluations_clinic_id", "evaluations", ["clinic_id"])
    op.create_index("ix_evaluations_patient_id", "evaluations", ["patient_id"])
    op.create_index("ix_evaluations_status", "evaluations", ["status"])
    op.create_index("ix_evolutions_clinic_id", "evolutions", ["clinic_id"])


def downgrade() -> None:
    op.drop_index("ix_evolutions_clinic_id", table_name="evolutions")
    op.drop_index("ix_evaluations_status", table_name="evaluations")
    op.drop_index("ix_evaluations_patient_id", table_name="evaluations")
    op.drop_index("ix_evaluations_clinic_id", table_name="evaluations")
    op.drop_index("ix_anamneses_clinic_id", table_name="anamneses")
    op.drop_index("ix_patients_clinic_id", table_name="patients")

    op.drop_table("audit_logs")

    op.drop_column("evolutions", "updated_at")
    op.drop_column("evolutions", "updated_by")
    op.drop_column("evaluations", "updated_at")
    op.drop_column("evaluations", "updated_by")
    op.drop_column("anamneses", "updated_at")
    op.drop_column("anamneses", "updated_by")
    op.drop_column("patients", "updated_at")
    op.drop_column("patients", "updated_by")
    op.drop_column("patients", "created_by")
