"""migrate guardians to n n patient relationships

Revision ID: 0015_patient_guardians_nn
Revises: 0014_guardian_patients_cascade
Create Date: 2026-03-19
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect, text


revision = "0015_patient_guardians_nn"
down_revision = "0014_guardian_patients_cascade"
branch_labels = None
depends_on = None


def _table_exists(inspector, table_name: str) -> bool:
    return table_name in inspector.get_table_names()


def _column_names(inspector, table_name: str) -> list[str]:
    return [column["name"] for column in inspector.get_columns(table_name)]


def _drop_fk_constraints(inspector, table_name: str) -> None:
    for fk in inspector.get_foreign_keys(table_name):
        if fk.get("name"):
            op.drop_constraint(fk["name"], table_name, type_="foreignkey")


def _drop_indexes(inspector, table_name: str) -> None:
    for index in inspector.get_indexes(table_name):
        if index.get("name"):
            op.drop_index(index["name"], table_name=table_name)


def upgrade() -> None:
    conn = op.get_bind()
    inspector = inspect(conn)

    if _table_exists(inspector, "guardian_patients") and not _table_exists(inspector, "patient_guardians"):
        op.rename_table("guardian_patients", "patient_guardians")
        inspector = inspect(conn)

    if not _table_exists(inspector, "patient_guardians"):
        op.create_table(
            "patient_guardians",
            sa.Column("patient_id", sa.UUID(), nullable=False),
            sa.Column("guardian_id", sa.UUID(), nullable=False),
            sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.text("now()")),
            sa.ForeignKeyConstraint(["patient_id"], ["patients.id"], ondelete="CASCADE"),
            sa.ForeignKeyConstraint(["guardian_id"], ["guardians.id"], ondelete="CASCADE"),
            sa.PrimaryKeyConstraint("patient_id", "guardian_id"),
        )
        inspector = inspect(conn)

    columns = _column_names(inspector, "patient_guardians")

    if "id" in columns:
        pk = inspector.get_pk_constraint("patient_guardians")
        if pk.get("name"):
            op.drop_constraint(pk["name"], "patient_guardians", type_="primary")
        unique_constraints = inspector.get_unique_constraints("patient_guardians")
        for constraint in unique_constraints:
            if set(constraint.get("column_names") or []) == {"guardian_id", "patient_id"} and constraint.get("name"):
                op.drop_constraint(constraint["name"], "patient_guardians", type_="unique")
        op.create_primary_key("pk_patient_guardians", "patient_guardians", ["patient_id", "guardian_id"])
        op.drop_column("patient_guardians", "id")
        inspector = inspect(conn)
        columns = _column_names(inspector, "patient_guardians")

    if "created_at" not in columns:
        op.add_column(
            "patient_guardians",
            sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.text("now()")),
        )

    _drop_fk_constraints(inspector, "patient_guardians")
    op.create_foreign_key(
        "fk_patient_guardians_patient_id",
        "patient_guardians",
        "patients",
        ["patient_id"],
        ["id"],
        ondelete="CASCADE",
    )
    op.create_foreign_key(
        "fk_patient_guardians_guardian_id",
        "patient_guardians",
        "guardians",
        ["guardian_id"],
        ["id"],
        ondelete="CASCADE",
    )

    inspector = inspect(conn)
    _drop_indexes(inspector, "patient_guardians")
    op.create_index("ix_patient_guardians_patient_id", "patient_guardians", ["patient_id"])
    op.create_index("ix_patient_guardians_guardian_id", "patient_guardians", ["guardian_id"])

    guardian_columns = _column_names(inspector, "guardians")
    if "patient_id" in guardian_columns:
        conn.execute(
            text(
                """
                INSERT INTO patient_guardians (patient_id, guardian_id, created_at)
                SELECT g.patient_id, g.id, now()
                FROM guardians g
                WHERE g.patient_id IS NOT NULL
                ON CONFLICT (patient_id, guardian_id) DO NOTHING
                """
            )
        )
        fk_names = [fk["name"] for fk in inspector.get_foreign_keys("guardians") if "patient_id" in (fk.get("constrained_columns") or []) and fk.get("name")]
        for fk_name in fk_names:
            op.drop_constraint(fk_name, "guardians", type_="foreignkey")
        op.drop_column("guardians", "patient_id")


def downgrade() -> None:
    conn = op.get_bind()
    inspector = inspect(conn)

    guardian_columns = _column_names(inspector, "guardians")
    if "patient_id" not in guardian_columns:
        op.add_column("guardians", sa.Column("patient_id", sa.UUID(), nullable=True))
        op.create_foreign_key("fk_guardians_patient_id", "guardians", "patients", ["patient_id"], ["id"])
        conn.execute(
            text(
                """
                UPDATE guardians g
                SET patient_id = pg.patient_id
                FROM (
                    SELECT guardian_id, min(patient_id) AS patient_id
                    FROM patient_guardians
                    GROUP BY guardian_id
                ) pg
                WHERE pg.guardian_id = g.id
                """
            )
        )

    if _table_exists(inspector, "patient_guardians") and not _table_exists(inspector, "guardian_patients"):
        op.rename_table("patient_guardians", "guardian_patients")
