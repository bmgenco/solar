# Solar Project — Domain Context

Residential solar+battery climate impact analysis, Decatur GA. Methane-inclusive hourly grid emissions for SOCO balancing authority.

---

## Project File Structure

```
solar/
├── CLAUDE.md
├── CHANGELOG.md
├── docs/
│   ├── NOTES.md
│   ├── TASKS.md
│   └── SOCO_emissions_project_structure.md
├── data/
│   └── ecobee/     # Monthly thermostat runtime CSVs
├── scripts/        # Active R Markdown analysis scripts
├── output/         # Generated data, .RData files, summary tables
└── figures/        # Generated plots
```

### Active Scripts (reference only — new codebase built fresh on EIA-930)

- `house_component_v11.Rmd` — Data processing, gas allocation, generates `house_profile.RData`. Complete and validated.
- `emissions_analysis_integrated_v13.Rmd` — Most recent emissions analysis with supply chain factors.
- `corrected_emissions_analysis.Rmd` — Corrected temporal arbitrage and radiative forcing.
- `ga_dispatch_emissions_analysis.Rmd` — SOCO hourly dispatch modeling and peaker identification.

---

## Data Sources

- **Emporia Vue:** Circuit-level electrical monitoring. Files prefixed `C9CD28-Ridgedale_electrical_meter-` at 1SEC, 1MIN, 15MIN, 1H, 1DAY resolutions.
- **Ecobee:** 5-minute HVAC runtime with multi-zone temps. Monthly CSVs in `data/ecobee/`. CSV parsing requires manual column handling due to header quirks.
- **Georgia Power:** Billing in `.xlsx` and `.csv`. Cost and energy files cover 2023-09-09 through 2025-09-06.
- **Natural gas:** Single CSV from provider.
- **Enphase Enlighten:** Collecting since Jan 23, 2026. No export data until PTO.
- **EIA-930:** `pull_soco()` in `soco_emissions.Rmd`. API key in R environment.

---

## Coding Conventions

- **Language:** R with R Markdown
- **Plotting:** ggplot2 preferred; base R acceptable for small standalone scripts
- **Paths:** `file.path()` with relative paths from project root. Scripts set `wd <- dirname(getwd())`
- **Package management:** `f.ipak()` pattern for install-if-missing
- **Output format:** PDF and HTML. Code hidden in output; methodology documented separately
- **Citations:** Nature-style numbered superscripts in presentation outputs
- **No synthetic data.** Flag when assumptions substitute for measurements.

---

## Communication & Style

- Direct, technical responses. No superlatives, no sales language.
- Question assumptions. Flag data quality issues.
- Bounds-based economic analysis, not point predictions.
- Present trade-offs objectively — support decision-making, not advocacy.
- When uncertain, say so. Prefer conservative estimates.
