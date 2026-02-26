# TASKS — Coding Agent

Active coding tasks. See [SOCO_emissions_project_strucuture.md](SOCO_emissions_project_strucuture.md) for phase plan and pending analytical decisions that may block tasks below.

---

## Blocking — Requires Human Decision First

- [ ] **Apply methane leakage correction to grid emissions factors.** Blocked pending resolution of leakage rate in PLAN section of `docs/SOCO_emissions_migration_doc.md`. Once rate is confirmed, apply upstream correction to SOCO hourly emissions factors. EPA eGRID baseline uses ~1.4%; satellite-central is 2.9%; adds ~0.05–0.08 lbs CO₂e/kWh to gas-heavy hours. Peak corrections when resolved: 1.563 → ~1.62, evening: 1.434 → ~1.48.

---

## Phase 0 — Data Infrastructure

- [ ] **Pull EIA-930 SOCO 2018–2023.** Use existing `pull_soco()` in `soco_emissions.Rmd`. Run year by year. Flag fuel category inconsistencies across years — 2018–2019 may be missing `OES`, `SNB`, storage categories. Build crosswalk table.
    - - Stratify by Vogtle regime, not pooled average: pre-Vogtle (2018–2022), post-Vogtle (2024–present). Unit 3 online July 2023, Unit 4 April 2024.Nuclear baseload ~15% higher post-Vogtle; pooling misrepresents current dispatch.
- [ ] **Download OGE v0.5.0 SOCO subset.** Source: Zenodo, CC-BY-4.0. Align fuel categories with EIA-930. Note: OGE stops at 2022; post-2022 validation will rely on EIA-930 only.
- [ ] **Download eGRID SOCO emission factors.** EPA eGRID. Extract SOCO-specific stack emission rates (CO₂, CH₄, N₂O by fuel type).
- [ ] **Set up project file structure.** Fresh R project — do not edit old Rmd files. Old scripts (`ga_dispatch_emissions_analysis.Rmd`, `corrected_emissions_analysis.Rmd`, `emissions_analysis_integrated_v13.Rmd`) are reference only.
- [ ] **Export and assess Enphase data.** Identify clean date range post-January 23, 2026. Flag configuration noise period. No export data until PTO — pipeline design only until then.

---

## Analysis 1 — Household Emissions (Phase 1)

- [ ] **Recalculate all derived emissions values with GWP-20 = 82.5.** Previous scripts used 84. Affects: peak grid emissions, net battery benefit, annual system benefit, cost-effectiveness. Update all downstream calculated values.
- [ ] **Replace IRP dispatch with EIA-930 empirical hourly fuel mix.** Validate 2–6 PM gas peaker window against actual 2024 dispatch data.
- [ ] **Calculate hypothetical customer cost-effectiveness.** 1-battery ($27,134) and 2-battery ($35,134) scenarios. Need single-battery annual benefit estimate derived from empirical dispatch.

---

## Figures / Visualization

- [ ] **Fix radiative forcing inversion bug.** `calculate_radiative_forcing()` showed solar+battery with MORE forcing than baseline — physically impossible. Double-subtraction or mishandled gas vs electric components. Verify fix in current script version before assuming resolved.
- [ ] **Fix temporal arbitrage emissions line (dual y-axis).** Grid emissions (1.2–1.6 lbs/kWh) plotted on 0–6 kW y-axis makes 30% variation invisible. Implement dual y-axes: left = power (kW), right = emissions (lbs/kWh).
- [ ] **Add full electrification scenario to radiative forcing plot.** Third trajectory: heat pump + solar + battery. Currently only baseline and solar+battery are plotted.
- [ ] **Fix DPI.** Set `knitr::opts_chunk$set(dpi = 300)` globally. Previous output was 150 DPI; iPad Pro requires 300.

---

## Report Output

- [ ] **Emissions report v1 (static).** Render PDF/HTML from corrected emissions analysis. No visible code. Nature-style numbered citations. Exclude street address; include house profile data. For hosting on personal website.
