"""rbac users and guardian patients

Revision ID: 0007_rbac_users_guardians
Revises: 0006_guardian_relationship_type
Create Date: 2026-03-18
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = "0007_rbac_users_guardians"
down_revision = "0006_guardian_relationship_type"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("patient_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("users", sa.Column("guardian_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.create_index("ix_users_patient_id", "users", ["patient_id"])
    op.create_index("ix_users_guardian_id", "users", ["guardian_id"])
    op.create_foreign_key("fk_users_patient_id", "users", "patients", ["patient_id"], ["id"])
    op.create_foreign_key("fk_users_guardian_id", "users", "guardians", ["guardian_id"], ["id"])

    op.create_table(
        "guardian_patients",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("guardian_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("patient_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["guardian_id"], ["guardians.id"]),
        sa.ForeignKeyConstraint(["patient_id"], ["patients.id"]),
    )
    op.create_index("ix_guardian_patients_guardian_id", "guardian_patients", ["guardian_id"])
    op.create_index("ix_guardian_patients_patient_id", "guardian_patients", ["patient_id"])
    op.create_unique_constraint(
        "uq_guardian_patients_guardian_id_patient_id",
        "guardian_patients",
        ["guardian_id", "patient_id"],
    )


def downgrade() -> None:
    op.drop_constraint("uq_guardian_patients_guardian_id_patient_id", "guardian_patients", type_="unique")
    op.drop_index("ix_guardian_patients_patient_id", table_name="guardian_patients")
    op.drop_index("ix_guardian_patients_guardian_id", table_name="guardian_patients")
    op.drop_table("guardian_patients")

    op.drop_constraint("fk_users_guardian_id", "users", type_="foreignkey")
    op.drop_constraint("fk_users_patient_id", "users", type_="foreignkey")
    op.drop_index("ix_users_guardian_id", table_name="users")
    op.drop_index("ix_users_patient_id", table_name="users")
    op.drop_column("users", "guardian_id")
    op.drop_column("users", "patient_id")
