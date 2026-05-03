"""add therapist professional fields and clinic branding fields

Revision ID: 0021_add_therapist_and_clinic_branding_fields
Revises: 0020_rich_text_json_fields
Create Date: 2026-04-29
"""

from alembic import op
import sqlalchemy as sa


revision = "0021_add_therapist_and_clinic_branding_fields"
down_revision = "0020_rich_text_json_fields"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("cpf", sa.String(length=14), nullable=True))
    op.add_column("users", sa.Column("registration_type", sa.String(length=50), nullable=True))
    op.add_column("users", sa.Column("professional_registration", sa.String(length=20), nullable=True))

    op.add_column("clinics", sa.Column("logo_url", sa.String(length=500), nullable=True))
    op.add_column("clinics", sa.Column("subdomain", sa.String(length=120), nullable=True))
    op.create_unique_constraint("uq_clinics_subdomain", "clinics", ["subdomain"])


def downgrade() -> None:
    op.drop_constraint("uq_clinics_subdomain", "clinics", type_="unique")
    op.drop_column("clinics", "subdomain")
    op.drop_column("clinics", "logo_url")
    op.drop_column("users", "professional_registration")
    op.drop_column("users", "registration_type")
    op.drop_column("users", "cpf")
