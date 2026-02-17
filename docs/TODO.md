# Solar Project — TODO

## Critical / Blocking

- [ ] **Verify 4.5% methane leakage rate.** Currently attributed to "Nesser et al. 2024 TROPOMI" but Nesser found ~13% upward correction to EPA national total (~2.6%), not 4.5%. The 4.5% appears to be a synthesized midpoint between Alvarez (3.7%) and EDF MethaneAIR (9.2%), not a direct literature value. Need to either: (a) find a paper directly supporting 4.5%, (b) extract Southeast/SOCO-specific leakage from Nesser's regional data, or (c) relabel as sensitivity midpoint. All calculated values downstream (peak grid emissions, annual benefit, cost-effectiveness) depend on this input.

- [ ] **Recalculate all derived emissions values with GWP-20 = 82.5.** Previous scripts used 84. Affects: peak grid emissions, net battery benefit, annual system benefit, cost-effectiveness. See CLAUDE.md calculated values table.

## Analysis Tasks

- [ ] **Calculate hypothetical customer cost-effectiveness.** 1-battery ($27,134) and 2-battery ($35,134) scenarios. Need single-battery annual benefit estimate.

- [ ] **Pull Georgia Power rate schedules.** Standard Service and Nights & Weekends current $/kWh rates for financial savings modeling.

- [ ] **EIA-930 API setup.** Register for API key, test SOCO hourly data pull in R. Validate modeled dispatch against actual 2024 hourly generation.

## Figures / Visualization (some may already be resolved in current scripts — verify before fixing)

- [ ] **Radiative forcing curves inverted.** `calculate_radiative_forcing()` had a bug where solar+battery showed MORE forcing than baseline (physically impossible — double-subtraction or mishandled gas vs electric components). Fix was attempted in chat but unclear if validated in current script versions.

- [ ] **Temporal arbitrage emissions line appears flat.** Grid emissions (1.2–1.6 lbs/kWh) plotted on 0–6 kW y-axis makes 30% variation invisible. Fix: dual y-axes (left: power kW, right: emissions lbs/kWh). May or may not be in current scripts.

- [ ] **Full electrification scenario missing from radiative forcing plot.** Only baseline and solar+battery were plotted. Need third trajectory showing heat pump + solar + battery.

- [ ] **DPI too low for iPad presentation.** Was 150 DPI; should be 300 DPI for iPad Pro (264 PPI). Fix: `knitr::opts_chunk$set(dpi = 300)`.

- [ ] **Fugitive methane not applied to grid emissions factors.** EPA eGRID factors use 2.5% leakage. TROPOMI 4.5% adds ~0.05–0.08 lbs CO2e/kWh to gas-heavy hours. Peak corrections: 1.563 → ~1.62, evening: 1.434 → ~1.48. Makes temporal arbitrage more valuable. Related to methane leakage verification (see Critical).

## Report / Output

- [ ] **Emissions report v1 (static).** Render presentation PDF/HTML. No code, Nature citations, exclude address. Host on personal website.

- [ ] **Emissions report v2 (interactive).** Add parameter sliders (leakage rate, battery count, rate plan). Web-hosted.

## Future

- [ ] **Weather-forecast battery optimization.** Track 2 — daily TOU schedule updates from weather/grid predictions.

- [ ] **Heat pump conversion analysis.** ~18.1 kWh/day additional load. Panel upgrade assessment.

- [ ] **Enphase summer TOU schedule.** Debug app crash on complex summer schedules. Contact support.
