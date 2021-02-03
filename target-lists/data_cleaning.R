data_cleaning <- list(

# Clean data of senior players in last championships ----------------------
  
  tar_target(
    name = senior_players,
    command = clean_senior_players(senior_player_data_raw = raw_senior_players)
  ),

  
# Create information of which generations should be included --------------

  tar_target(
    name = inclusion_data,
    command = make_inclusion_data(
      country_participations = country_participations,
      min_nr_champs = data_params$min_nr_champs,
      min_generations = data_params$min_generations
    )
  ),

# Clean ranking data ------------------------------------------------------

  tar_target(
    name = ranking_data,
    command = clean_rankings(
      rankings = ranking,
      senior_max_rank = data_params$senior_max_rank,
      youth_max_rank = data_params$youth_max_rank,
      incl_countries = inclusion_data
    )
  ),

# Clean licenced players data ---------------------------------------------

tar_target(
  name = licenced_players_data,
  command = clean_licenced_players(licenced_players = licenced_players)
),


# Create player level data ------------------------------------------------

  tar_target(
    name = player_data,
    command = make_player_data(
      raw_player_data = raw_players,
      inclusion_data = inclusion_data,
      ranking_data = ranking_data,
      licenced_players_data = licenced_players_data,
      debut_age_cut = data_params$debut_age_cut
    )
  ),
  # Save to data folder
  tar_target(
    name = player_data_write,
    command = save_csv(player_data, file = here("data", "player_data.csv")),
    format = "file"
  ),


# Create generation level data --------------------------------------------

  tar_target(
    name = generation_data,
    command = make_generation_data(player_data = player_data)
  ),
  # Save to data folder
  tar_target(
    name = generation_data_write,
    command = save_csv(generation_data, file = here("data", "generation_data.csv")),
    format = "file"
  ),


# Create country level data -----------------------------------------------

  tar_target(
    name = country_data,
    command = make_country_data(generation_data = generation_data)
  ),
  # Save to data folder
  tar_target(
    name = country_data_write,
    command = save_csv(country_data, file = here("data", "country_data.csv")),
    format = "file"
  )
)