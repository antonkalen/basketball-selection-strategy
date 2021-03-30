# List of targets for reading all raw data from "data-raw"-folder.

read_raw_data <- list(
  
  # Read raw player data from last senior championships ---------------------
  
  tar_file(
    name = senior_players_file,
    command = here("data-raw", "players_last_senior_championships.csv")
  ),
  
  tar_target(
    name = raw_senior_players,
    command = read_csv(senior_players_file)
  ),
  
  
  # Read raw player data ----------------------------------------------------
  
  tar_file(players_file, here("data-raw", "players.csv")),
  tar_target(raw_players, read_csv(players_file, col_types = "cicciiiiiiiiiiiii")),
  

  # Read country ranking ----------------------------------------------------
  
  tar_files(ranking_files, dir_ls(here("data-raw"), regexp = "ranking")),
  tar_target(ranking, read_csv(ranking_files), pattern = map(ranking_files)),

  
  # Read data on number of licensed players ---------------------------------

  tar_file(licenced_players_file, here("data-raw", "nr-licenced-players.csv")),
  tar_target(licenced_players, read_csv(licenced_players_file)),
  

  # Read data on countries participation in youth championships ------------
  
  tar_file(country_participations_file, here("data-raw", "country_participations.csv")),
  tar_target(country_participations, read_csv(country_participations_file))
  
)
