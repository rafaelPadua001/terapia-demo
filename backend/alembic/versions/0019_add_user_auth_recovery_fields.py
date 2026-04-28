"""add user auth recovery fields

Revision ID: 0019_add_user_auth_recovery_fields
Revises: 0018_create_notifications
Create Date: 2026-04-28
"""

from alembic import op
import sqlalchemy as sa


revision = "0019_add_user_auth_recovery_fields"
down_revision = "0018_create_notifications"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("first_login", sa.Boolean(), nullable=False, server_default=sa.text("false")))
    op.add_column(
        "users",
        sa.Column("has_seen_tutorial", sa.Boolean(), nullable=False, server_default=sa.text("false")),
    )
    op.add_column("users", sa.Column("reset_token_hash", sa.String(length=255), nullable=True))
    op.add_column("users", sa.Column("reset_token_expiration", sa.DateTime(), nullable=True))
    op.alter_column("users", "first_login", server_default=None)
    op.alter_column("users", "has_seen_tutorial", server_default=None)


def downgrade() -> None:
    op.drop_column("users", "reset_token_expiration")
    op.drop_column("users", "reset_token_hash")
    op.drop_column("users", "has_seen_tutorial")
    op.drop_column("users", "first_login")
