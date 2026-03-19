"""guardian patients cascade

Revision ID: 0014_guardian_patients_cascade
Revises: 0013_add_email_confirmation
Create Date: 2026-03-19
"""

from alembic import op
from sqlalchemy import inspect


revision = "0014_guardian_patients_cascade"
down_revision = "0013_add_email_confirmation"
branch_labels = None
depends_on = None


def upgrade() -> None:
    conn = op.get_bind()
    inspector = inspect(conn)
    foreign_keys = inspector.get_foreign_keys("guardian_patients")

    for fk in foreign_keys:
        if fk["constrained_columns"] == ["guardian_id"] and fk["name"]:
            op.drop_constraint(fk["name"], "guardian_patients", type_="foreignkey")
        if fk["constrained_columns"] == ["patient_id"] and fk["name"]:
            op.drop_constraint(fk["name"], "guardian_patients", type_="foreignkey")

    op.create_foreign_key(
        "fk_guardian_patients_guardian_id_cascade",
        "guardian_patients",
        "guardians",
        ["guardian_id"],
        ["id"],
        ondelete="CASCADE",
    )
    op.create_foreign_key(
        "fk_guardian_patients_patient_id_cascade",
        "guardian_patients",
        "patients",
        ["patient_id"],
        ["id"],
        ondelete="CASCADE",
    )


def downgrade() -> None:
    conn = op.get_bind()
    inspector = inspect(conn)
    foreign_keys = {fk["name"] for fk in inspector.get_foreign_keys("guardian_patients") if fk["name"]}

    if "fk_guardian_patients_guardian_id_cascade" in foreign_keys:
        op.drop_constraint("fk_guardian_patients_guardian_id_cascade", "guardian_patients", type_="foreignkey")
    if "fk_guardian_patients_patient_id_cascade" in foreign_keys:
        op.drop_constraint("fk_guardian_patients_patient_id_cascade", "guardian_patients", type_="foreignkey")
