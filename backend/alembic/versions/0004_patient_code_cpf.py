"""patient_code and cpf

Revision ID: 0004_patient_code_cpf
Revises: 0003_audit_timestamps
Create Date: 2026-03-17
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = "0004_patient_code_cpf"
down_revision = "0003_audit_timestamps"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("patients", sa.Column("patient_code", sa.String(length=20), nullable=True))
    op.add_column("patients", sa.Column("cpf", sa.String(length=11), nullable=True))

    op.execute("CREATE SEQUENCE IF NOT EXISTS patient_code_seq START WITH 1 INCREMENT BY 1")

    op.execute(
        """
        WITH ordered AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY created_at, id) AS rn
            FROM patients
        )
        UPDATE patients p
        SET patient_code = 'PAC-' || LPAD(ordered.rn::text, 6, '0')
        FROM ordered
        WHERE p.id = ordered.id
        """
    )

    op.execute(
        """
        SELECT setval(
            'patient_code_seq',
            COALESCE((SELECT MAX(CAST(SUBSTRING(patient_code, 5) AS INTEGER)) FROM patients), 0) + 1,
            false
        )
        """
    )

    op.alter_column("patients", "patient_code", nullable=False)
    op.create_index("ix_patients_patient_code", "patients", ["patient_code"], unique=True)
    op.create_index("ix_patients_cpf", "patients", ["cpf"], unique=True)


def downgrade() -> None:
    op.drop_index("ix_patients_cpf", table_name="patients")
    op.drop_index("ix_patients_patient_code", table_name="patients")
    op.drop_column("patients", "cpf")
    op.drop_column("patients", "patient_code")
    op.execute("DROP SEQUENCE IF EXISTS patient_code_seq")
