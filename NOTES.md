# Solar Energy Decision Framework

Residential solar+battery climate impact analysis for a property in Decatur, GA (Atlanta metro). The project quantifies emissions reduction benefits and cost-effectiveness of a 6.6kW solar system with battery storage, using rigorous methodology that distinguishes this from marketing-grade analysis.

## System Specifications

- **Solar:** 15 × Maxeon 440W panels, 6.6kW DC, Enphase microinverters
- **Battery:** 2 × Enphase IQ Battery 5P (10kWh total, 8.5kWh usable at 15% reserve)
- **Controller:** Enphase IQ System Controller 3
- **Output:** 3.84kW continuous per battery (7.68kW total parallel)
- **Status:** Installed, awaiting Georgia Power PTO/meter interconnection

### Cost Scenarios (toggle in analysis)

| Scenario | 1 Battery (5kWh) | 2 Batteries (10kWh) | Notes |
|----------|-------------------|----------------------|-------|
| **Personal** | — | $28,934 | Includes $1,800 service upgrade; 2nd battery free (installer compensation) |
| **Hypothetical customer** | $27,134 | $35,134 | No service upgrade, 2nd battery at ~$8k market price |

No federal tax credits apply (deadline passed 12/31/2025).

## Grid & Emissions Context

- **Utility:** Georgia Power, under SOCO (Southern Company Services) balancing authority
- **Solar compensation:** Georgia Power Solar Buy Back / RNR-Instantaneous Netting. Export credit ~7.2¢/kWh (3.2¢ avoided cost + 4¢ PSC adder for 2026). 10kW system cap. NOT in the closed RNR-Monthly Netting pilot (capped at 5,000 customers, full since July 2021).
- **Rate plan impact:** Emissions analysis is rate-plan-independent. Financial savings should be modeled across Standard Service and Nights & Weekends rate structures (TODO: pull current $/kWh for each plan).
- **Key insight:** Solar generation (2-6 PM) overlaps with gas peaker dispatch hours. Battery extends methane avoidance to evening peak (6-10 PM). This temporal arbitrage is the core climate value proposition — not average grid displacement.

### Critical Emissions Parameters

**Input parameters (require citations):**

| Parameter | Value | Source |
|-----------|-------|--------|
| Methane leakage rate | 4.5% | ⚠️ **NEEDS VERIFICATION** — see TODO.md. Attributed to TROPOMI but may be synthesized midpoint. Nesser et al. (2024), *Atmos. Chem. Phys.*, 24, 5069–5091. https://doi.org/10.5194/acp-24-5069-2024 |
| Methane GWP-20 (fossil) | 82.5 ± 25.8 | IPCC AR6 WG1, Chapter 7, Table 7.15 (CH₄-fossil row) |
| EPA baseline leakage | 2.5% | EPA GHGI; Alvarez et al. found ~60% undercount |
| Supply chain leakage (ground-based) | 2.3% | Alvarez, R.A. et al. (2018). "Assessment of methane emissions from the U.S. oil and gas supply chain." *Science*, 361, 186–188. https://doi.org/10.1126/science.aar7204 |

**Calculated values (methodology documented in scripts):**

| Parameter | Value | Derived from |
|-----------|-------|--------------|
| Peak grid emissions | ~1.48 lbs CO2e/kWh | SOCO hourly gen mix × fuel emissions factors × TROPOMI correction |
| Clean grid emissions (1-6 AM) | ~1.13 lbs CO2e/kWh | Same methodology, baseload hours |
| Net battery benefit | 0.30 lbs CO2e/kWh | (peak − clean) × roundtrip efficiency |
| Annual system benefit | 2.94 tons CO2e | System production profile × hourly emissions factors |
| Cost-effectiveness (personal) | $1,194/ton CO2e | $28,934 / 2.94 tons / 10 years |
| Cost-effectiveness (hypothetical, 1 bat) | Needs calc | $27,134 / [1-bat benefit] / 10 years |
| Cost-effectiveness (hypothetical, 2 bat) | Needs calc | $35,134 / 2.94 tons / 10 years |

## SOCO Grid Data

Georgia Power operates within the SOCO (Southern Company Services) balancing authority — an integrated grid covering Georgia Power, Alabama Power, and Mississippi Power. There is no Georgia-only generation mix; electrons from Alabama coal plants and Georgia gas plants serve Atlanta interchangeably. All grid emissions analysis must use SOCO-level data, not Georgia Power-specific generation.

### EIA-930 API

Primary data source for actual hourly generation by fuel type. Replaces IRP-based theoretical dispatch with observed patterns.

- **API:** EIA Open Data v2 — https://www.eia.gov/opendata/
- **BA code:** SOCO
- **R package:** `EIAapi` for direct queries
- **Data available:** Hourly net generation by source (coal, gas, nuclear, solar, wind, hydro), hourly demand, interchange flows
- **History:** Full generation mix since July 2018
- **Bulk downloads:** 6-month CSVs at https://www.eia.gov/electricity/gridmonitor/
- **API key:** Required (free registration)

### Additional Sources

- **WattTime API** — Real-time marginal emissions rates for SOCO. Free for research/personal use. More granular than EIA-930.
- **GridStatus.io** — User-friendly EIA-930 visualization. Good for exploration.

### Vogtle Nuclear Impact

Vogtle Units 3 and 4 (operational July 2023 and April 2024) added 2,200 MW zero-carbon nuclear baseload to SOCO, reducing overall grid emissions ~10-12%. This increased the clean-dirty emissions spread, making nighttime grid charging for batteries more valuable for temporal arbitrage.

### Two-Track Analysis Framework

**Track 1 — Historical emissions analysis** (refines existing scripts):
- Pull actual SOCO hourly data by month from EIA-930
- Replace IRP theoretical dispatch with observed generation mix
- Validate the 2-6 PM gas peaker window against real dispatch
- Calculate monthly-varying grid emissions factors

**Track 2 — Real-time battery optimization** (future, builds on Track 1):
- Weather forecast → predicted load → optimal daily battery dispatch
- Conditional hybrid: historical monthly averages as baseline, forecast adjustments for daily operations
- Maximize temporal arbitrage using predicted grid conditions
- Feeds TOU-as-emissions-proxy schedules in Enphase app

## Validated House Profile

These values are cross-validated across Emporia Vue, Ecobee, and Georgia Power billing data (0% discrepancy on overlapping periods):

- **Electricity:** 6,540 kWh/year
- **Natural gas:** 500 therms/year → 15 therms cooking / 175 therms water heating / 310 therms HVAC
- **Saved in:** `output/house_profile.RData`

## Project Structure

```
solar/
├── data/           # Raw data: Emporia (5 resolutions), Ecobee (monthly), GA Power, gas bills
│   └── ecobee/     # Monthly thermostat runtime CSVs
├── scripts/        # Active R Markdown analysis scripts
├── output/         # Generated data, .RData files, summary tables
└── figures/        # Generated plots
```

### Active Scripts

- `house_component_v11.Rmd` — Data processing, gas allocation, generates `house_profile.RData`. Complete and validated.
- `emissions_analysis_integrated_v13.Rmd` — Most recent emissions analysis with supply chain factors. In progress.
- `corrected_emissions_analysis.Rmd` — Emissions analysis with corrected temporal arbitrage and radiative forcing. Produces presentation output.
- `ga_dispatch_emissions_analysis.Rmd` — SOCO hourly dispatch modeling and peaker identification.

### Data Sources

- **Emporia Vue:** Circuit-level electrical monitoring. Files prefixed `C9CD28-Ridgedale_electrical_meter-` at 1SEC, 1MIN, 15MIN, 1H, 1DAY resolutions.
- **Ecobee:** 5-minute HVAC runtime with multi-zone temps. Monthly CSVs in `data/ecobee/`. Note: CSV parsing requires manual column handling due to header quirks.
- **Georgia Power:** Billing in both `.xlsx` and `.csv` formats. Cost and energy files cover 2023-09-09 through 2025-09-06.
- **Natural gas:** Single CSV from provider.

## Coding Conventions

- **Language:** R with R Markdown for reproducible analysis
- **Plotting:** ggplot2 preferred. Base R acceptable for small standalone scripts.
- **R Markdown:** Useful for chunked analysis workflows. Keep code chunks focused.
- **Citations:** Nature-style numbered superscripts in presentation outputs
- **Paths:** Use `file.path()` with relative paths from project root. Scripts set `wd <- dirname(getwd())` to get project root from `scripts/`.
- **Package management:** Use `f.ipak()` function pattern for install-if-missing
- **Output format:** PDF and HTML for iPad presentation. Code hidden in output; methodology documented separately.
- **No synthetic data.** All analysis uses actual monitored data. Flag when assumptions substitute for measurements.

## TOU-as-Emissions-Proxy Strategy

The Enphase Enlighten app optimizes battery dispatch based on electricity rates. We exploit this by mapping emissions intensity to fake $/kWh rates, so the system charges during clean grid hours and discharges during dirty hours automatically. Winter and summer schedules differ. The app supports 16+ rate periods for hour-by-hour granularity. Known bug: app crashes on complex summer schedules.

## Communication & Style

- Direct, technical responses. No superlatives, no sales language.
- Question assumptions. Flag data quality issues.
- Bounds-based economic analysis, not point predictions.
- Present trade-offs objectively — support decision-making, not advocacy.
- When uncertain, say so. Prefer conservative estimates.

## Current Goals

1. **Emissions report v1 (static)** — Render presentation-quality PDF/HTML from corrected emissions analysis. No code visible, Nature-style citations. Exclude street address but include house profile data. Will be hosted as static page on personal website.
2. **Emissions report v2 (interactive)** — Add sliders for parameter exploration (methane leakage rate, battery count, rate plan, etc.). Web-hosted.
3. **SOCO grid integration** (next) — Implement Track 1: pull actual EIA-930 hourly data to validate/replace IRP-based dispatch assumptions in emissions scripts. See SOCO Grid Data section.
4. **Weather-forecast optimization** (future) — Implement Track 2: forecast-driven daily battery TOU schedules. See SOCO Grid Data section.

## Recent Sessions
See [CHANGELOG.md](CHANGELOG.md) for full history.

### 2026-02-05 — Session 1
- Audited scripts, set up session logging, committed project docs
