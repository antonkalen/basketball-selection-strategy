# Load targets and related packages ---------------------------------------

library(targets)
library(tarchetypes)
library(fs)


# Set target options ------------------------------------------------------

tar_option_set(packages = c("here", "readr", "fs", "dplyr", "tidyr"))


# Source all functions in the R folder ------------------------------------

# dir_walk(here::here("R"), source)


# Set parameters for the analysis -----------------------------------------

params <- list(
  debut_age_cut = 25,
  senior_max_rank = 1000,
  youth_max_rank = 800,
  min_nr_championship = 3
)


# Define targets pipeline -------------------------------------------------

pipeline <- list(
  # Load parameters
  tar_target(params, params),
  # Load raw data files
  ## Players
  tar_file(players_file, here("data-raw", "players.csv")),
  tar_target(raw_players, read_csv(players_file, col_types = "cicciiiiiiiiiiiii")),
  ## Country ranking
  tar_files(ranking_files, dir_ls(here("data-raw"), regexp = "ranking")),
  tar_target(ranking, read_csv(ranking_files), pattern = map(ranking_files)),
  ## Last championships
  tar_file(last_senior_champ_file, here("data-raw", "last_senior_champ.csv")),
  tar_target(raw_last_senior_champ, read_csv(last_senior_champ_file)),
  ## Country youth participation
  tar_file(country_participation_file, here("data-raw", "country_participations.csv")),
  tar_target(country_participation, read_csv(country_participation_file)),
  ## Latent classes
  tar_files(classes_files, dir_ls(here("data-raw"), regexp = "4classes")),
  tar_target(
    classes,
    read_delim(
      classes_files, 
      delim = " ",
      col_names = FALSE,
      col_types = "nnnnnnnn"
    ),
    pattern = map(classes_files)
  )
)


# Run targets pipeline ----------------------------------------------------

tar_pipeline(pipeline)