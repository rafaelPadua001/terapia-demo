"""convert evolution and appointment text fields to jsonb rich text

Revision ID: 0020_rich_text_json_fields
Revises: 0019_add_user_auth_recovery_fields
Create Date: 2026-04-28
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision = "0020_rich_text_json_fields"
down_revision = "0019_add_user_auth_recovery_fields"
branch_labels = None
depends_on = None


EMPTY_DOC = """'{"type":"doc","content":[]}'::jsonb"""


def _text_to_doc_sql(column_name: str) -> str:
    return f"""
    CASE
        WHEN {column_name} IS NULL OR btrim({column_name}) = '' THEN {EMPTY_DOC}
        ELSE jsonb_build_object(
            'type', 'doc',
            'content', jsonb_build_array(
                jsonb_build_object(
                    'type', 'paragraph',
                    'content', jsonb_build_array(
                        jsonb_build_object('type', 'text', 'text', {column_name})
                    )
                )
            )
        )
    END
    """


def upgrade() -> None:
    op.execute(
        f"""
        ALTER TABLE evolutions
        ALTER COLUMN description
        TYPE jsonb
        USING ({_text_to_doc_sql("description")})
        """
    )
    op.execute(
        f"""
        ALTER TABLE appointments
        ALTER COLUMN notes
        TYPE jsonb
        USING ({_text_to_doc_sql("notes")})
        """
    )


def downgrade() -> None:
    op.alter_column(
        "evolutions",
        "description",
        existing_type=postgresql.JSONB(astext_type=sa.Text()),
        type_=sa.Text(),
        postgresql_using="description::text",
        existing_nullable=False,
    )
    op.alter_column(
        "appointments",
        "notes",
        existing_type=postgresql.JSONB(astext_type=sa.Text()),
        type_=sa.String(length=500),
        postgresql_using="notes::text",
        existing_nullable=True,
    )
