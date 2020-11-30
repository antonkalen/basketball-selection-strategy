# Load targets and related packages ---------------------------------------

library(targets)
library(tarchetypes)
library(fs)


# Set target options ------------------------------------------------------

tar_option_set(packages = c("here", "readr", "fs", "dplyr", "tidyr"))


# Source all functions in the R folder ------------------------------------

dir_walk(here::here("R"), source)


# Set parameters for the analysis -----------------------------------------

params <- list(
  debut_age_cut = 25,
  senior_max_rank = 1000,
  youth_max_rank = 800,
  min_nr_champs = 3,
  min_generations = 5
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
  tar_file(last_senior_champ_file, here("data-raw", "players_last_senior_championships.csv")),
  tar_target(raw_last_senior_champ, read_csv(last_senior_champ_file)),
  ## Country youth participation
  tar_file(country_participations_file, here("data-raw", "country_participations.csv")),
  tar_target(country_participations, read_csv(country_participations_file)),
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
  ),
  # Clean data
  ## Player data
  tar_target(
    player_data,
    clean_player_data(
      raw_player_data = raw_players,
       country_rankings = ranking,
       country_partic = country_participations,
       latent_classes = classes,
       min_nr_champs = params$min_nr_champs,
       senior_max_rank = params$senior_max_rank,
       youth_max_rank = params$youth_max_rank,
       debut_age_cut = params$debut_age_cut
    )
  ),
  tar_target(country_data, make_country_data(player_data = player_data))
)


# Run targets pipeline ----------------------------------------------------

tar_pipeline(pipeline)