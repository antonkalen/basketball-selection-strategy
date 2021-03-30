# Load targets and related packages ---------------------------------------

library(targets)
library(tarchetypes)
library(fs)
library(here)
library(future)

# Set target options ------------------------------------------------------

tar_option_set(
  packages = c(
    "here",
    "readr",
    "fs",
    "dplyr",
    "tidyr",
    "brms",
    "Cairo",
    "tidybayes"
  )
)

options(
  # Run all brms models with Cmdstanr as backend
  brms.backend = "cmdstanr"
)

# Source all functions in the R folder ------------------------------------

dir_walk(here("R"), source)


# Set up parallelization --------------------------------------------------

plan(multisession)


# Source all list of targets ----------------------------------------------

## Targets and likewise to define user defined parameters
source(here("target-lists", "set_parameters.R"))

## Targets for reading the raw data
source(here("target-lists", "read_raw_data.R"))

## Targets for cleaning the data
source(here("target-lists", "data_cleaning.R"))

## Targets for fitting models
source(here("target-lists", "fit_models.R"))

## Targets for cleaning the data
source(here("target-lists", "create_outputs.R"))


# Run targets pipeline ----------------------------------------------------

tar_pipeline(
  set_parameters, 
  read_raw_data, 
  data_cleaning,
  fit_model,
  create_outputs
)
