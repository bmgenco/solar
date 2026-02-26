Residential solar+battery emissions analysis project.

# Session Start
1. Read [docs/tasks.md](docs/tasks.md) and [docs/CHANGELOG.md](docs/CHANGELOG.md).

# During Session
- [docs/NOTES.md](docs/NOTES.md) has domain context if the need arises.
- [docs/SOCO_emissions_project_strucuture.md](docs/SOCO_emissions_project_strucuture.md) has project phase plan, methodology decisions, and citations — read when starting a new phase or making architectural decisions.

# Session End
- Update CHANGELOG.md with what was done.
- Commit when asked. Main branch only.

# Environment
- **R** (primary): R 4.3.3. Knit via `Rscript -e "rmarkdown::render('scripts/FILENAME.Rmd')"`
- **Python:** Anaconda base. Dedicated conda env if needed.
- **Git:** Main branch, multiple machines.

# Conventions
- R Markdown, ggplot2, relative paths via `file.path()`.
- No synthetic data. Flag assumptions.

