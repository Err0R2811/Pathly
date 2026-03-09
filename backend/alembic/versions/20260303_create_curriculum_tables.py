"""Alembic migration to create curriculum tables.
Generated automatically for task implementation.
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = "20260303_create_curriculum_tables"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "roadmaps",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("user_id", sa.String(), nullable=False),
        sa.Column("skill_name", sa.String(), nullable=False),
        sa.Column("domain_type", sa.String(), nullable=False),
        sa.Column("verification_score", sa.Integer()),
        sa.Column("created_at", sa.String()),
    )
    op.create_table(
        "modules",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("roadmap_id", sa.String(), sa.ForeignKey("roadmaps.id"), nullable=False),
        sa.Column("module_name", sa.String(), nullable=False),
        sa.Column("level", sa.String(), nullable=False),
        sa.Column("difficulty_score", sa.Integer()),
        sa.Column("verification_alignment_score", sa.Integer()),
        sa.Column("estimated_hours", sa.Integer()),
        sa.Column("pedagogical_basis", sa.String()),
    )
    op.create_table(
        "research_sources",
        sa.Column("id", sa.String(), primary_key=True),
        sa.Column("module_id", sa.String(), sa.ForeignKey("modules.id"), nullable=False),
        sa.Column("title", sa.String()),
        sa.Column("doi", sa.String()),
        sa.Column("url", sa.String()),
        sa.Column("abstract", sa.String()),
        sa.Column("embedding", sa.JSON()),
    )


def downgrade():
    op.drop_table("research_sources")
    op.drop_table("modules")
    op.drop_table("roadmaps")
