```{r ga_power_bill_import}
# Function to load and analyze Georgia Power monthly bill data
load_ga_power_bills <- function(file_path) {
  
  # Load monthly bill data (CSV format)
  bill_data <- read.csv(file_path, stringsAsFactors = FALSE)
  
  # Parse dates
  bill_data$date <- as.Date(bill_data$Date, format = "%Y-%m-%d")
  bill_data$month <- month(bill_data$date)
  bill_data$year <- year(bill_data$date)
  
  # Handle missing Service_Plan column for backwards compatibility
  if(!"Service_Plan" %in% names(bill_data)) {
    bill_data$Service_Plan <- "R-30"  # Default assumption
    cat("Note: Service_Plan not specified, assuming R-30 (standard residential)\n")
  }
  
  # Rate plan definitions for analysis
  rate_plans <- list(
    "R-30" = list(
      name = "Standard Residential",
      time_of_use = FALSE,
      basic_service_charge = 0.4603  # $/day
    ),
    "Smart Usage" = list(
      name = "Smart Usage",
      time_of_use = TRUE,
      basic_service_charge = 0.4603
    ),
    "Overnight Advantage" = list(
      name = "Overnight Advantage (EV Plan)",
      time_of_use = TRUE,
      basic_service_charge = 0.4603
    ),
    "FlatBill" = list(
      name = "FlatBill",
      time_of_use = FALSE,
      basic_service_charge = 0.4603
    )
  )
  
  # Georgia Power rate structure analysis
  bill_data <- bill_data %>%
    mutate(
      # Basic service charge calculation (fixed daily fee)
      days_in_month = days_in_month(date),
      basic_service_charge = 0.4603 * days_in_month,
      
      # Plan-specific analysis
      is_time_of_use = Service_Plan %in% c("Smart Usage", "Overnight Advantage"),
      
      # Separate variable usage charges from fixed charges in "Current Service"
      estimated_usage_charge = Current_Service - basic_service_charge,
      
      # Calculate implied $/kWh rate from usage portion
      implied_rate_per_kwh = if_else(kWh_Used > 0, 
                                     estimated_usage_charge / kWh_Used, 
                                     NA_real_),
      
      # Environmental Compliance Cost Recovery (~12% of base bill per article)
      environmental_pct = if_else(Current_Service > 0, 
                                  Environmental_Fee / Current_Service * 100, 
                                  NA_real_),
      
      # Total fixed fees that solar CANNOT offset
      total_fixed_fees = basic_service_charge + Environmental_Fee + Franchise_Fee,
      
      # Variable charges that solar CAN offset
      solar_offsettable_charges = estimated_usage_charge,
      
      # Percentage of bill that solar can offset
      solar_offset_potential_pct = if_else(Total_Bill > 0,
                                           solar_offsettable_charges / Total_Bill * 100,
                                           NA_real_),
      
      # Season classification for rate analysis
      season = case_when(
        month %in% c(6, 7, 8, 9) ~ "summer",
        month %in% c(12, 1, 2) ~ "winter",
        TRUE ~ "spring_fall"
      ),
      
      # Peak season analysis (June-September per GA Power)
      is_peak_season = month %in% c(6, 7, 8, 9)
    )
  
  # Calculate summary statistics
  cat("=== GEORGIA POWER BILL ANALYSIS ===\n")
  cat("Analysis period:", min(bill_data$date), "to", max(bill_data$date), "\n")
  cat("Total bills analyzed:", nrow(bill_data), "\n")
  
  # Rate plan summary
  plan_summary <- bill_data %>%
    count(Service_Plan, name = "months") %>%
    mutate(percentage = round(months/sum(months)*100, 1))
  
  cat("\nRATE PLAN USAGE:\n")
  print(plan_summary)
  
  # Check for rate plan changes during analysis period
  if(length(unique(bill_data$Service_Plan)) > 1) {
    cat("\nWARNING: Multiple rate plans detected during analysis period!\n")
    cat("This may affect trend analysis and solar projections.\n")
    
    plan_changes <- bill_data %>%
      arrange(date) %>%
      select(date, Service_Plan) %>%
      filter(Service_Plan != lag(Service_Plan, default = first(Service_Plan)))
    
    if(nrow(plan_changes) > 0) {
      cat("Rate plan changes detected:\n")
      print(plan_changes)
    }
  }
  
  # Rest of existing analysis code...
  # [Previous summary statistics and seasonal analysis remain the same]
  
  return(bill_data)
}

# Function to analyze rate plan scenarios for sensitivity analysis
analyze_rate_plan_scenarios <- function(bill_data, kwh_usage_annual) {
  
  # Georgia Power rate plan scenarios for solar analysis
  rate_scenarios <- data.frame(
    plan = c("R-30", "Smart Usage", "Overnight Advantage", "FlatBill"),
    plan_description = c(
      "Standard Residential (tiered rates)",
      "Time-of-Use (peak/off-peak)",
      "EV Plan (super off-peak 11pm-7am)",
      "Fixed monthly amount"
    ),
    basic_monthly = rep(0.4603 * 30.4, 4),  # Average days per month
    estimated_rate_range = c("$0.08-0.15/kWh", "$0.06-0.25/kWh", "$0.04-0.22/kWh", "Fixed"),
    solar_benefit = c("Medium", "High", "Very High", "None"),
    best_for = c(
      "Standard usage patterns",
      "Flexible usage timing",
      "EV owners, night usage",
      "Predictable budgeting"
    )
  )
  
  cat("=== RATE PLAN SENSITIVITY ANALYSIS ===\n")
  cat("Annual kWh for comparison:", kwh_usage_annual, "\n\n")
  
  print(rate_scenarios)
  
  # Solar value by rate plan
  cat("\nSOLAR VALUE BY RATE PLAN:\n")
  cat("1. Time-of-Use plans maximize solar value (peak production during peak rates)\n")
  cat("2. Overnight Advantage: Excellent for solar + battery storage\n")
  cat("3. Standard R-30: Moderate solar benefits\n")
  cat("4. FlatBill: No solar savings potential\n\n")
  
  cat("RECOMMENDATION: If planning solar, consider switching to time-of-use plan\n")
  cat("for maximum savings potential before installation.\n")
  
  return(rate_scenarios)
}

# Enhanced template with service plan options
create_bill_template <- function(start_date = "2023-01-01", months = 12) {
  
  template <- data.frame(
    Date = seq(as.Date(start_date), by = "month", length.out = months),
    Service_Plan = rep("R-30", months),     # R-30, Smart Usage, Overnight Advantage, FlatBill
    kWh_Used = rep(NA, months),
    Current_Service = rep(NA, months),      
    Environmental_Fee = rep(NA, months),    
    Franchise_Fee = rep(NA, months),        
    Sales_Tax = rep(NA, months),            
    Total_Bill = rep(NA, months),
    Peak_kWh = rep(NA, months),            # For time-of-use plans
    Off_Peak_kWh = rep(NA, months),        # For time-of-use plans
    Super_Off_Peak_kWh = rep(NA, months)   # For Overnight Advantage plan
  )
  
  # Calculate summary statistics
  cat("=== GEORGIA POWER BILL ANALYSIS ===\n")
  cat("Analysis period:", min(bill_data$date), "to", max(bill_data$date), "\n")
  cat("Total bills analyzed:", nrow(bill_data), "\n")
  
  # Annual totals
  annual_totals <- bill_data %>%
    summarise(
      total_kwh = sum(kWh_Used, na.rm = TRUE),
      total_bill = sum(Total_Bill, na.rm = TRUE),
      total_fixed_fees = sum(total_fixed_fees, na.rm = TRUE),
      total_offsettable = sum(solar_offsettable_charges, na.rm = TRUE),
      avg_rate = mean(implied_rate_per_kwh, na.rm = TRUE),
      avg_solar_offset_potential = mean(solar_offset_potential_pct, na.rm = TRUE)
    )
  
  cat("\nANNUAL SUMMARY:\n")
  cat("Total kWh:", round(annual_totals$total_kwh, 0), "\n")
  cat("Total bill amount: $", round(annual_totals$total_bill, 2), "\n")
  cat("Total fixed fees: $", round(annual_totals$total_fixed_fees, 2), 
      "(", round(annual_totals$total_fixed_fees/annual_totals$total_bill*100, 1), "% of bill)\n")
  cat("Solar-offsettable charges: $", round(annual_totals$total_offsettable, 2),
      "(", round(annual_totals$total_offsettable/annual_totals$total_bill*100, 1), "% of bill)\n")
  cat("Average effective rate: $", round(annual_totals$avg_rate, 4), "/kWh\n")
  
  # Seasonal analysis
  seasonal_summary <- bill_data %>%
    group_by(season) %>%
    summarise(
      months = n(),
      avg_kwh = mean(kWh_Used, na.rm = TRUE),
      avg_bill = mean(Total_Bill, na.rm = TRUE),
      avg_rate = mean(implied_rate_per_kwh, na.rm = TRUE),
      avg_fixed_fees = mean(total_fixed_fees, na.rm = TRUE),
      .groups = 'drop'
    )
  
  cat("\nSEASONAL BREAKDOWN:\n")
  print(seasonal_summary)
  
  # Solar analysis implications
  cat("\nSOLAR ANALYSIS IMPLICATIONS:\n")
  cat("1. Fixed fees solar CANNOT offset: $", round(annual_totals$total_fixed_fees, 2), "/year\n")
  cat("2. Variable charges solar CAN offset: $", round(annual_totals$total_offsettable, 2), "/year\n")
  cat("3. Maximum potential solar savings: ", 
      round(annual_totals$avg_solar_offset_potential, 1), "% of total bill\n")
  
  # Rate structure insights
  summer_bills <- bill_data %>% filter(is_peak_season)
  winter_bills <- bill_data %>% filter(!is_peak_season)
  
  if(nrow(summer_bills) > 0 && nrow(winter_bills) > 0) {
    cat("4. Summer vs Winter rate difference:\n")
    cat("   Summer avg rate: $", round(mean(summer_bills$implied_rate_per_kwh, na.rm = TRUE), 4), "/kWh\n")
    cat("   Winter avg rate: $", round(mean(winter_bills$implied_rate_per_kwh, na.rm = TRUE), 4), "/kWh\n")
  }
  
  # Environmental fee analysis (should be ~12% per article)
  avg_env_pct <- mean(bill_data$environmental_pct, na.rm = TRUE)
  cat("5. Environmental fee as % of current service:", round(avg_env_pct, 1), 
      "% (article states ~12%)\n")
  
  return(bill_data)
}

# Function to create monthly bill template for manual entry
create_bill_template <- function(start_date = "2023-01-01", months = 12) {
  
  # Create template with correct Georgia Power bill structure
  template <- data.frame(
    Date = seq(as.Date(start_date), by = "month", length.out = months),
    kWh_Used = rep(NA, months),
    Current_Service = rep(NA, months),      # Main charge (includes basic service + usage + fuel)
    Environmental_Fee = rep(NA, months),    # ~12% of current service
    Franchise_Fee = rep(NA, months),        # Municipal franchise fee
    Sales_Tax = rep(NA, months),            # Georgia 4% + local taxes
    Total_Bill = rep(NA, months)
  )
  
  cat("=== GEORGIA POWER BILL TEMPLATE CREATED ===\n")
  cat("Instructions for data entry:\n")
  cat("1. Date: First day of billing month (YYYY-MM-DD)\n")
  cat("2. kWh_Used: Total kWh from your bill\n")
  cat("3. Current_Service: Main 'Current Service' line from bill\n")
  cat("4. Environmental_Fee: 'Environmental Compliance Cost Recovery' line\n")
  cat("5. Franchise_Fee: Municipal franchise fee line\n")
  cat("6. Sales_Tax: Total sales tax charged\n")
  cat("7. Total_Bill: Final amount due\n\n")
  
  cat("Save as CSV and use load_ga_power_bills() to analyze\n")
  
  return(template)
}

# Function to estimate solar savings potential from bill data
estimate_solar_savings <- function(bill_data, solar_production_kwh_annual) {
  
  # Calculate potential savings based on offsettable charges
  annual_offsettable <- sum(bill_data$solar_offsettable_charges, na.rm = TRUE)
  annual_kwh <- sum(bill_data$kWh_Used, na.rm = TRUE)
  
  # Calculate effective rate for solar offset
  effective_offset_rate <- annual_offsettable / annual_kwh
  
  # Solar savings scenarios
  savings_scenarios <- data.frame(
    scenario = c("25% Solar Offset", "50% Solar Offset", "75% Solar Offset", "100% Solar Offset"),
    solar_kwh = c(0.25, 0.50, 0.75, 1.00) * solar_production_kwh_annual,
    annual_savings = c(0.25, 0.50, 0.75, 1.00) * solar_production_kwh_annual * effective_offset_rate,
    remaining_bill = annual_offsettable - (c(0.25, 0.50, 0.75, 1.00) * solar_production_kwh_annual * effective_offset_rate),
    savings_pct = (c(0.25, 0.50, 0.75, 1.00) * solar_production_kwh_annual * effective_offset_rate) / sum(bill_data$Total_Bill, na.rm = TRUE) * 100
  )
  
  # Add fixed fees that remain regardless of solar
  annual_fixed_fees <- sum(bill_data$total_fixed_fees, na.rm = TRUE)
  savings_scenarios$total_remaining_bill <- savings_scenarios$remaining_bill + annual_fixed_fees
  
  cat("=== SOLAR SAVINGS ESTIMATION ===\n")
  cat("Based on effective offset rate: $", round(effective_offset_rate, 4), "/kWh\n")
  cat("Annual fixed fees (unchanged with solar): $", round(annual_fixed_fees, 2), "\n\n")
  
  print(savings_scenarios %>%
          select(scenario, annual_savings, total_remaining_bill, savings_pct) %>%
          mutate(
            annual_savings = paste0("$", round(annual_savings, 0)),
            total_remaining_bill = paste0("$", round(total_remaining_bill, 0)),
            savings_pct = paste0(round(savings_pct, 1), "%")
          ))
  
  return(savings_scenarios)
}

# Example usage:
# bill_template <- create_bill_template("2023-01-01", 12)
# write.csv(bill_template, "ga_power_bills_template.csv", row.names = FALSE)
# bill_data <- load_ga_power_bills("ga_power_bills.csv")
# solar_savings <- estimate_solar_savings(bill_data, 6540)  # Your annual solar production estimate
```