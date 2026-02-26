# SOCO Grid Emissions Analysis — Project Document
**Created:** February 26, 2026  
**Project:** Tagae Solutions — Methane-Inclusive Hourly Grid Emissions  

---

## Pending Decisions (Human)

These block downstream calculations. Resolve before coding tasks that depend on them.

### Methane Leakage Rate

The 4.5% value used in prior scripts is not directly sourced from a single paper and must be resolved before applying upstream corrections to grid emissions factors.

**Status:** Unresolved. Three options:

1. **Find a paper directly supporting 4.5%.** No known candidate currently.
2. **Use Southeast/SOCO-specific rate from Nesser et al. (2024).** Nesser found ~13% upward correction to EPA national total (~2.6%), not 4.5%. Regional breakdowns may exist — check Supplementary Materials for Southeast basin-specific estimates.
3. **Relabel as sensitivity midpoint.** Use bounds approach: Low = 1.4% (EPA GHGI), Central = 2.9% (Nesser/Shen satellite consensus), High = 6–9% (basin-specific, Smith et al. / EDF MethaneAIR). The 4.5% could be retained as an explicit sensitivity midpoint if labeled as such, not as a literature value.

**Recommendation when resolved:** Update methane factor library (see below), then unblock the fugitive methane correction task in TASKS.md.

---

## Plan

### Strategic Priorities

1. **Emissions report v1 (static)** — Presentation-quality PDF/HTML from corrected emissions analysis. No code visible, Nature-style citations, exclude street address. Host on personal website. Blocked on leakage rate resolution + GWP-20 recalculation.

2. **SOCO grid integration (Phase 0–1)** — Pull actual EIA-930 hourly data to replace IRP-based dispatch assumptions. Validate 2–6 PM peaker window empirically.

3. **Emissions report v2 (interactive)** — Add parameter sliders (methane leakage rate, battery count, rate plan). Web-hosted. Follows v1.

4. **Weather-forecast battery optimization (future)** — Track 2: forecast-driven daily battery TOU schedules. Implement after Phase 1 empirical dispatch is validated.

5. **Heat pump conversion analysis (future)** — ~18.1 kWh/day additional load, panel upgrade assessment. Analyze when current gas appliances approach end-of-life.

### Two-Track Analysis Framework

**Track 1 — Historical emissions analysis** (refines existing scripts):
- Pull actual SOCO hourly data by month from EIA-930
- Replace IRP theoretical dispatch with observed generation mix
- Validate the 2–6 PM gas peaker window against real dispatch
- Calculate monthly-varying grid emissions factors

**Track 2 — Real-time battery optimization** (future, builds on Track 1):
- Weather forecast → predicted load → optimal daily battery dispatch
- Conditional hybrid: historical monthly averages as baseline, forecast adjustments for daily operations
- Maximize temporal arbitrage using predicted grid conditions
- Feeds TOU-as-emissions-proxy schedules in Enphase app

### TOU-as-Emissions-Proxy Strategy

The Enphase Enlighten app optimizes battery dispatch based on electricity rates. We exploit this by mapping emissions intensity to fake $/kWh rates, so the system charges during clean grid hours and discharges during dirty hours automatically. Winter and summer schedules differ. The app supports 16+ rate periods for hour-by-hour granularity. Known bug: app crashes on complex summer schedules — contact Enphase support before implementing summer version.

---

## Project Summary

Building methane-inclusive hourly grid emissions analysis for the SOCO (Southern Company) balancing authority. Two parallel analyses:

1. **Household scale (Analysis 1):** Average emissions (XEF) for a 6.6 kW solar + 10 kWh Enphase battery system in Decatur, GA. Goal: quantify actual emissions avoidance and optimize battery dispatch for emissions (cost analysis is secondary).
2. **Community scale (Analysis 2):** Marginal emissions (MEF) for a hypothetical 5–50 MW solar farm. Goal: quantify avoided emissions value of community solar+storage, with side analysis comparing against specific GA Power proposed gas plants (PSC Docket 56298) and generic new-build gas CC/CT benchmarks.

**Novel contribution:** No existing tool (WattTime, Electricity Maps, OGE, Singularity) includes upstream methane at hourly resolution. We bridge atmospheric science (TROPOMI satellite methane observations) with grid carbon accounting (EIA-930 dispatch data), using GWP-20 framing for near-term climate tipping point relevance.

**Deliverable format:** Reproducible R code → figures for website → white paper with methodology written by the analyst (not AI-generated prose). Transparent methodology and citable code are the priority outputs from coding sessions.

---

## Key Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Emissions metric (household) | Average (XEF) | 6.6 kW export too small to shift dispatch |
| Emissions metric (community) | Marginal (MEF) | Farm-scale export displaces marginal generator |
| Methane uncertainty approach | Literature-bounded range (low/central/high) | Papers use different methods/basins/years; bounds more honest than Monte Carlo |
| GWP time horizon | GWP-20 primary, GWP-100 for comparison | Tipping-point framing, consistent with PSC public comment |
| Codebase approach | Start fresh — new scripts built on EIA-930 | Old Rmd files are reference only (valid params but hardcoded dispatch) |
| LCA scope | Fuels from existing infrastructure only | Ignore already-installed generation hardware LCA; community scale adds fuller LCA + new-build comparison |
| Coal source for methane | Include both Appalachian + PRB as bounds | SOCO coal sourcing is mixed/uncertain |
| New gas generator comparison | Docket 56298 specific plants + generic benchmark | Connects to PSC advocacy + generalizable analysis |
| Paper audience | Website figures first → white paper → potentially preprint | Analyst writes prose; code sessions produce methodology + figures |
| Enphase data | Use for pipeline design now; real analysis after PTO | ~1 month data with configuration noise; no export yet |

---

## LCA Scope Clarification

**For existing grid (both analyses):**
- Stack emissions from combustion (CO₂, CH₄, N₂O) — from eGRID/OGE
- Upstream fuel-cycle methane (extraction, processing, transport) — our novel layer
- Do NOT include embodied emissions of already-installed power plants or transmission infrastructure for Analysis 1. Solar equipment full LCA already calculated — leave as is.

**For community-scale solar (Analysis 2 only):**
- Add solar panel + battery manufacturing LCA (factors in old Rmd: panels = 3.23 tCO₂, battery = 0.52 tCO₂)
- Side analysis: Compare lifecycle emissions of proposed GA Power gas expansion (Docket 56298) vs equivalent community solar+storage capacity

**Coal bed methane specifically:**
- Include as placeholder in methane factor library
- Bound with both underground/Appalachian (higher CH₄) and surface/PRB (lower CH₄) rates
- Flag additional gases from coal mining (CO₂ from oxidation, trace N₂O) as placeholders

---

## Data Sources & Status

### Available Now
| Data | Status | Location/Access |
|------|--------|----------------|
| EIA-930 SOCO hourly fuel mix | `pull_soco()` working via httr | API key in R environment; 2024–2025 pulled |
| Emporia circuit-level CSVs | Historical data exists | Previously uploaded; needs hardware reinstalled for current data |
| Enphase Enlighten | Collecting since Jan 23, 2026 | App export; no PTO yet (no grid export) |
| PSC public comment + citations | Filed Feb 12, 2026 | See citation library below |
| IPCC AR6 Table 7.15 | GWP values with uncertainties | Values transcribed below |
| Old Rmd analysis files | Reference only | `ga_dispatch_emissions_analysis.Rmd`, `corrected_emissions_analysis.Rmd`, `emissions_analysis_integrated_v13.Rmd` |

### Need to Acquire
| Data | Source | Priority |
|------|--------|----------|
| EIA-930 SOCO 2018–2023 | Same API, run `pull_soco()` for each year | Phase 0 — immediate |
| Open Grid Emissions (OGE) | Zenodo, CC-BY-4.0, v0.5.0 (2005–2022) | Phase 0 — immediate |
| eGRID SOCO-specific emission factors | EPA eGRID download | Phase 0 |
| WattTime SOCO signal | Free tier API (relative 1–100) | Phase 2 |
| Docket 56298 plant specifications | GA PSC filings | Phase 2 |

---

## Working R Function: `pull_soco()` in `soco_emissions.Rmd`

- Fuel types in 2024: COL, NG, NUC, SUN, WAT, OTH, BAT, PS, OES, SNB, WND, OIL
- 2025 may have additional fuel subcategories — need crosswalk
- 2018–2019 likely missing OES, SNB, storage categories — flag during crosswalk build

---

## Household System Specifications

- **Solar:** 6.6 kW Maxeon panels, Enphase microinverters (Solar Energy Partners install)
- **Battery:** 2 × Enphase IQ Battery 5P (10 kWh total, 8.5 kWh usable at 15% reserve)
- **Controller:** Enphase IQ System Controller 3
- **Annual production estimate:** 6,522 kWh
- **Annual electricity consumption:** ~6,540 kWh (from Emporia data)
- **Gas appliances:** 500 therms/year total — Stove: 15 (3%), Water heater: 175 (35%), HVAC: 310 (62%)
- **Solar producing since:** January 23, 2026
- **PTO status:** Not yet received as of Feb 26, 2026

---

## Methane Emission Factor Library — Structure

### Natural Gas Upstream Leakage (% of production)

| Bound | Rate | Source | Method |
|-------|------|--------|--------|
| Low (EPA inventory) | 1.4% | EPA GHGI 2024 | Bottom-up inventory |
| Central (satellite consensus) | 2.9% | Shen et al. 2022; Nesser et al. 2024 | TROPOMI inversion, national average |
| High (basin-specific) | 6–9% | Smith et al. 2022 (Uinta); EDF MethaneAIR 2024 | Basin-level, includes super-emitters |

Also include: transmission/distribution losses (Alvarez et al. 2018), compressor station emissions, CCS-context leakage (Cownden & Lucquiaud 2024).

Range likely surpasses bottom-up: satellite estimates capture large-leak anomalies statically. Probable working range 2.9–10%; EPA inventory likely too low, but upper bound not yet at consensus.

### Coal Mining Methane (placeholder — needs literature review)

| Source type | Approximate range | Notes |
|-------------|-------------------|-------|
| Surface/PRB | 0.4–1.0 kg CH₄/t coal | Lower methane content |
| Underground/Appalachian | 1.5–4.0 kg CH₄/t coal | Higher, variable by seam |
| Additional gases | CO₂ from oxidation, trace N₂O | Placeholder — quantify in Phase 1b |

SOCO coal sourcing is mixed — use both as bounds.

### GWP Values (IPCC AR6 Table 7.15)

| Metric | CH₄-fossil | Uncertainty (±1σ) |
|--------|------------|-------------------|
| GWP-20 | 82.5 | ±25.8 |
| GWP-100 | 29.8 | ±11 |
| GTP-50 | 13.2 | ±6.1 |
| GTP-100 | 7.5 | ±2.9 |

---

## Citation Library

### Methane Measurements (Satellite/Airborne)
1. Nesser, H. et al. (2024). High-resolution US methane emissions inferred from an inversion of 2019 TROPOMI satellite data. *Atmos. Chem. Phys.* 24, 5069–5091.
2. Shen, L. et al. (2022). Satellite quantification of oil and natural gas methane emissions in the US and Canada including contributions from individual basins. *Atmos. Chem. Phys.* 22, 11203–11215.
3. Smith, M. L. et al. (2022). Declining methane emissions and steady, high leakage rates observed over multiple years in a western US oil/gas production basin. *Sci. Rep.* 12, 1375.
4. Lu, X. et al. (2022). Methane emissions in the United States, Canada, and Mexico: evaluation of national methane emission inventories. *Atmos. Chem. Phys.* 22, 395–418.
5. Lu, X. et al. (2023). Observation-derived 2010–2019 trends in methane emissions and intensities from US oil and gas fields. *PNAS* 120, e2217900120.
6. Worden, J. R. et al. (2022). The 2019 methane budget and uncertainties at 1° resolution. *Atmos. Chem. Phys.* 22, 6811–6841.
7. Environmental Defense Fund (2024). MethaneAIR measurement campaigns. (Grey literature)

### Supply Chain / Lifecycle
8. Alvarez, R. A. et al. (2018). Assessment of methane emissions from the U.S. oil and gas supply chain. *Science* 361, 186–188.
9. Rutherford, J. S. et al. (2021). Closing the methane gap in US oil and natural gas production emissions inventories. *Nat. Commun.* 12, 4715.
10. Cownden, R. & Lucquiaud, M. (2024). Transmission + CCS leakage analysis. *Environ. Sci. Technol.* (ACS est.4c02933)
11. Clean Air Task Force (2024). Analysis of Lifecycle GHG Emissions of Natural Gas and Coal Powered Electricity. (Report)

### GWP / Climate Science
12. IPCC (2021). AR6 WG1, Chapter 7, Table 7.15.
13. Armstrong McKay, D. I. et al. (2022). Exceeding 1.5°C global warming could trigger multiple climate tipping points. *Science* 377, eabn7950.

### Grid Emissions Methodology
14. Elenes, A. G. N. et al. (2022). How well do emission factors approximate emission changes from electricity system models? *Environ. Sci. Technol.* 56, 14701–14712.
15. Kotchen, M. et al. (2022). Why marginal CO₂ emissions are not decreasing for US electricity. *PNAS*.
16. Miller, G. J. et al. (2023). Evaluating the hourly emissions intensity of the US electricity system. *Environ. Res. Lett.* 18, 044020.

### Policy Context
17. Inside Climate News (2026). Georgia Power Gas Expansion Would Drive Significant Climate-Damaging Pollution.
18. Brown, M. A. et al. (2021). A framework for localizing global climate solutions. *PNAS* 118, e2100008118.

---

## Existing Tools Landscape (Use, Don't Rebuild)

| Tool | What it provides | Our use | What it lacks (our gap) |
|------|-----------------|---------|------------------------|
| **Open Grid Emissions (OGE)** | Hourly plant-level CO₂/NOₓ/SO₂ for US BAs, 2005–2022 | Validation baseline, historical depth | Upstream methane; stops at 2022 |
| **EPA eGRID** | Annual plant-level emission factors | SOCO-specific stack emission rates | Hourly resolution; upstream methane |
| **WattTime** | 5-min marginal MOER (CO₂ lbs/MWh) | Timing validation for marginal analysis | Fuel decomposition; upstream methane; free tier = relative only |
| **Electricity Maps** | Global carbon intensity + fuel mix, real-time + forecast | Life-cycle factor comparison | TROPOMI-level methane specificity |
| **Singularity Energy** | Commercial platform behind OGE | Reference methodology | Not open for SOCO specifically |
| **EIA-930** | Hourly generation by fuel type per BA | **Primary input** — fuel mix data | Not emissions (we apply factors); 2018+ only |

---

## Phase Plan

```
Phase 0: Data Infrastructure & Project Scaffolding
  ├── New R project structure (fresh, not editing old Rmd)
  ├── Pull multi-year EIA-930 SOCO data (2018–2025)
  ├── Download OGE SOCO subset, explore and align
  ├── Fuel category crosswalk across years
  ├── Export Enphase data, identify clean date range
  └── Set up reusable data objects / file structure

Phase 1: Analysis 1 — Household Average Emissions
  ├── Empirical hourly fuel mix from EIA-930
  ├── Stack-only average emission intensity (validate vs OGE)
  ├── Methane-inclusive layer (low/central/high bounds)
  ├── Household emissions profile (Emporia baseline + Enphase)
  └── Counterfactual: optimized vs naive battery dispatch

Phase 1b: Methane Factor Library                        [parallel]
  ├── Gas upstream: paper-by-paper leakage rates
  ├── Coal mining: CH₄ + additional gases (Appalachian + PRB bounds)
  ├── Transmission/distribution losses
  ├── GWP-20 and GWP-100 conversion with AR6 uncertainties
  └── Output: reusable R data object + citation table

Phase 2: Analysis 2 — Community Scale Marginal
  ├── Empirical marginal generator identification
  ├── Marginal emission factors (stack + methane)
  ├── WattTime validation
  ├── Community solar avoided emissions
  ├── Fuller LCA for solar+storage system
  └── Side analysis: Docket 56298 plants + generic new-build gas comparison

Phase 3: Figures & White Paper Support
  ├── Publication-quality figures for website
  ├── Citation database (BibTeX)
  ├── Reproducible methodology documentation
  └── Analyst writes prose independently
```

---

## SOCO Grid Reference

- **Balancing authority:** Southern Company Services, Inc. - Trans (SOCO)
- **Territory:** Georgia, Alabama, Mississippi
- **Peak load:** ~37,500 MW (Winter Storm Elliott, Dec 2022)
- **Fleet:** ~44 GW rate-regulated capacity
- **Merit order:** Nuclear (must-run) → Solar (zero cost) → Coal (baseload) → Gas CC → Gas CT (marginal)
- **Key characteristic:** Vertically integrated utility, NOT ISO/RTO. No public market = less dispatch transparency than CAISO/PJM/MISO.
- **Load drivers:** Extremely temperature-sensitive (summer AC, winter electric heat)
- **Recent fleet changes:** Vogtle 3+4 online (nuclear, 2023–2024), coal retirements ongoing, solar buildout accelerating
- **Data implication:** Pre-2023 nuclear baseline differs fundamentally from post-Vogtle. Coal on one-way ramp down. Cannot treat all years as equivalent for dispatch shares.

---

## Previous Chat Transcripts

| Date | Topic | Location |
|------|-------|----------|
| 2026-02-20 | EIA-930 API, SOCO data pull, marginal emissions discussion | `/mnt/transcripts/2026-02-20-19-52-19-eia-930-api-soco-data-pull-marginal-emissions.txt` |
| 2026-02-26 | EIA-930 debugging, timezone fix, weather model architecture, WattTime comparison | `/mnt/transcripts/2026-02-26-17-29-23-soco-eia930-weather-emissions-model.txt` |
| 2026-02-12 | GA PSC public comment on gas expansion (Docket 56298) | `claude.ai/chat/94187ab2-8958-4b5a-8c2f-ab20ca0854e3` |
| 2025-08-06 | EV, solar, and battery storage planning | `claude.ai/chat/68f73ded-4c14-43b7-a831-669af4354148` |
| 2025-09-09 | Solar panel planning, Emporia data analysis | `claude.ai/chat/0ad1aa9f-196d-485e-8a33-696babf540b2` |
