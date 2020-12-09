# Packages -----------------------------------------------------------------
library(EpiNow2, quietly = TRUE)
library(data.table, quietly = TRUE)
library(future, quietly = TRUE)
library(here, quietly = TRUE)

argv <- commandArgs(TRUE)
state_filt <- if (length(argv) >= 1) argv[1] else ""
states_dir <- if (length(argv) >= 2) argv[2] else "states"
#target_date <- if (length(argv) >= 3) argv[3] else "latest"
target_date <- if (length(argv) >= 3) argv[3] else as.character(Sys.Date()) 
target_date <- "latest"
# Set target date ---------------------------------------------------------
#target_date <- as.character(Sys.Date())

# Update delays -----------------------------------------------------------
generation_time <- readRDS(here::here("data", "delays", "generation_time.rds"))
incubation_period <- readRDS(here::here("data", "delays", "incubation_period.rds"))
reporting_delay <- readRDS(here::here("data", "delays", "onset_to_report.rds"))

# Get cases  ---------------------------------------------------------------
cases <- data.table::fread(file.path(states_dir, state_filt, "data", "cases", paste0(target_date, ".csv")))
cases <- cases[, .(region = as.character(city), date = as.Date(date), 
                   confirm = case_inc)]
data.table::setorder(cases, region, date)

# # Set up cores -----------------------------------------------------
plan("multiprocess", gc = TRUE, earlySignal = TRUE)
no_cores <- 1 

target_folder <- here::here(states_dir, state_filt, "data", "rt-samples")
summary_dir <- here::here(states_dir, state_filt, "data", "rt", target_date) 
if (!dir.exists(target_folder)) dir.create(target_folder)
if (!dir.exists(summary_dir)) dir.create(summary_dir, recursive = TRUE)

target_date <- as.character(Sys.Date())

# Run Rt estimation -------------------------------------------------------
regional_epinow(reported_cases = cases,
                generation_time = generation_time, 
                delays = delay_opts(incubation_period, reporting_delay),
                backcalc = backcalc_opts(rt_window = 3, prior_window = 8*7),
                rt = NULL,  horizon = 7,
                obs = obs_opts(scale = list(mean = 0.1, sd = 0.025)),
                stan = stan_opts(samples = 2000, warmup = 250, chains = 2,
                                 max_execution_time = 2*60*60, 
                                 control = list(adapt_delta = 0.95)),
                # assume 10% of cases reported
                output = c("region", "summary", "timing", "plot"),
                target_date = target_date,
		#target_date = NULL,
                #target_folder = here::here("data", "rt", "samples"), 
                target_folder = target_folder, 
		summary_args = list(#summary_dir = here::here("data", "rt", 
                                    #                         target_date),
                                    summary_dir = summary_dir,
                                    all_regions = FALSE),
                #logs = "logs/cases"
		logs = file.path(states_dir, state_filt, "logs"),
		verbose = TRUE
)

#regional_epinow(reported_cases = cases, 
                #method = "approximate",
                #method = "exact",
#		generation_time = generation_time, 
#                delays = list(incubation_period, reporting_delay),
                #stan_args = list(trials = 5), 
#		stan_args = list(warmup = 500, cores = no_cores,
#                                            chains = ifelse(no_cores <= 4, 4, no_cores)),
				 #),
#                samples = 2000, 
#                horizon = 7, 
#                burn_in = 14, 
#                output = c("region", "summary", "timing"),
#                future_rt = "latest",
                #target_folder = here::here("data", "rt-samples"), 
#                target_folder = target_folder, 
#                summary_args = list(#summary_dir = here::here("data", "rt", target_date),
#               	                    summary_dir = summary_dir,
#                                    all_regions = FALSE),
#                logs = file.path(states_dir, state_filt, "logs"),
                #max_execution_time = 60 * 20
#                max_execution_time = 10800 
#)

