clean_player_data <- function(raw_player_data = raw_players,
                              country_rankings = ranking,
                              country_partic = country_participations,
                              latent_classes = classes,
                              min_nr_champs = params$min_nr_champs,
                              senior_max_rank = params$senior_max_rank,
                              youth_max_rank = params$youth_max_rank,
                              debut_age_cut = params$debut_age_cut) {
  
  # Fix country issues in data
  player_data <- fix_countries(raw_player_data)
  
  # Summarise participation per player
  # (senior participation only if before debut_age_cut)
  player_data <- make_player_participation_data(player_data, debut_age_cut)
  
  # Add ranking data
  player_data <- add_country_rankings(
    player_data = player_data,
    country_rankings = country_rankings,
    senior_max_rank = senior_max_rank,
    youth_max_rank = youth_max_rank
  )
  
  # Add latent classes
  player_data <- add_latent_classes(
    player_data = player_data,
    latent_classes = latent_classes
  )
  
  # Filter out country-generation combos with too few championships
  filtered_player_data <- filter_player_data(
    player_data = player_data,
    raw_country_participations = country_partic,
    min_nr_champs = min_nr_champs
  )
  # player_data
  filtered_player_data
}


fix_countries <- function(player_data) {
  
  # Recode England to Great Britain
  # For players from Scotland who played for Great Britain: get debut age from 
  # when they played for Scotland
  # Change Serbia & Montenegro
  # If players have later tournament played with either Serbia or Montenegro,
  # change to that country. If only played for Serbia & Montenegro: exclude.
  # Meaning we have to exclude '88-'90 generations of Serbian and of Montenegro.
  
  players_cleaned_country <- player_data %>% 
    group_by(category, player_id, gender, birth_year) %>% 
    arrange(debut_year, .by_group = TRUE) %>% 
    mutate(
      country = case_when(
        country == "England" ~ "Great Britain",
        country == "Serbia & Montenegro" ~ lead(country),
        TRUE ~ country
      ),
      debut_year = case_when(
        country == "Great Britain" ~ min(debut_year),
        TRUE ~ debut_year
      )
    ) %>%
    group_by(category, player_id, gender, country, birth_year) %>% 
    summarise(
      debut_year = min(debut_year),
      across(nr_youth_years:age_20, unique),
      .groups = "drop"
    ) %>% 
    ungroup() %>% 
    filter(!is.na(country))
  
  # filter out Serbia and Montenegro born 1988-1990
  players_cleaned_country_filtered <- players_cleaned_country %>% 
    filter(!(country %in% c("Serbia", "Montenegro") & birth_year %in% 1988:1990))
  
  players_cleaned_country_filtered
}


make_player_participation_data <- function(player_data, debut_age_cut) {
  
  # Get players making senior debut before debut_age_cut age.
  player_data_age_cut <- player_data %>% 
    mutate(
      debut_age = debut_year - birth_year,
      debut_age_youth = if_else(category == "youth", debut_age, NA_integer_),
      debut_age_senior = if_else(category == "senior", debut_age, NA_integer_),
    ) %>% 
    filter(debut_age <= debut_age_cut)
  
  # Add columns if player participated in youth and/or senior.
  player_data_participations <- player_data_age_cut %>% 
    group_by(gender, country, birth_year, player_id) %>% 
    summarise(
      youth = as.integer("youth" %in% category),
      senior = as.integer("senior" %in% category),
      across(
        c(nr_youth_years:age_20, debut_age_youth, debut_age_senior), 
        ~if_else(all(is.na(.x)), NA_integer_, sum(.x, na.rm = TRUE)),
      ),
      .groups = "drop"
    )
  
  player_data_participations
}

add_country_rankings <- function(player_data,
                                 country_rankings,
                                 senior_max_rank,
                                 youth_max_rank) {
  
  # Normalize ranking points
  senior_ranking <- country_rankings %>% 
    filter(category == "senior") %>% 
    mutate(ranking_points = ranking_points / senior_max_rank) %>% 
    select(
      -category, 
      senior_ranking = ranking, 
      senior_ranking_points = ranking_points
    )
  
  youth_ranking <- country_rankings %>% 
    filter(category == "youth") %>% 
    mutate(ranking_points = ranking_points / youth_max_rank) %>% 
    select(
      -category, 
      youth_ranking = ranking, 
      youth_ranking_points = ranking_points
    )
  
  # Add rankings to country data
  # All missing ranking points = 0
  full_player_data <- player_data %>% 
    left_join(senior_ranking, by = c("gender", "country")) %>% 
    left_join(youth_ranking, by = c("gender", "country")) %>% 
    replace_na(list(senior_ranking_points = 0, youth_ranking_points = 0))
  
  full_player_data
}


add_latent_classes <- function(player_data, latent_classes) {
  
  # Select correct columns
  latent_classes <- latent_classes %>% 
    select(last_col(offset = 1:0))
  
  # Rename columns
  names(latent_classes) <- c("class", "player_id")
  
  # Rename classes
  latent_classes <- latent_classes %>% 
    mutate(class = paste("Class", class))
  
  # Join with player data
  player_data %>% 
    left_join(latent_classes, by = "player_id")
}


filter_player_data <- function(player_data, 
                               raw_country_participations, 
                               min_nr_champs) {
  
  # Clean country participation data
  country_participations_cleaned <- clean_country_participations(
    raw_country_participations = raw_country_participations
  )
  
  # Keep country-generations with at least min_nr_championship.
  filtered_country_participations <- country_participations_cleaned %>% 
    filter(nr_championships >= min_nr_champs)
  
  # Filter out country-generations with too few participations.
  filtered_country_data <- player_data %>%
    semi_join(
      filtered_country_participations,
      by = c("gender", "country", "birth_year")
    )
  
  filtered_country_data
}


clean_country_participations <- function(raw_country_participations) {
  
  # Add column of 1's for each championship participated in (all rows)
  # Recode England to Great Britain
  raw_data <- raw_country_participations %>% 
    mutate(
      count = 1,
      country = case_when(
        country == "England" ~ "Great Britain",
        TRUE ~ country
      )
    )
  
  # Expand the data frame to one row per gender, country birth year and age.
  # Create a column marking which category (e.g. U18) each age belong to.
  countries <- raw_data %>% 
    expand(gender, country, birth_year = 1988:1999, age = 16:20) %>% 
    mutate(
      year = birth_year + age,
      category = paste0("U", round((age + .1)/2) * 2)
    )
  
  # Add the column containing 1 for each participated championship, 
  # and fill the rest with 0.
  country_generation_count <-  countries %>% 
    left_join(raw_data, by = c("country", "gender", "year", "category")) %>% 
    replace_na(list(count = 0))
  
  # Put in wide format, with one row per gender, country and generation,
  # with separate columns for each possible championship
  country_generation_wide <- country_generation_count %>% 
    group_by(gender, country, birth_year, category) %>%
    mutate(category = paste(category, row_number(), sep = "_")) %>%
    pivot_wider(
      id_cols = c(gender, country, birth_year), 
      names_from = category, values_from = count
    )
  
  # Sum up the total number of championships for each gender, country, generation
  country_gender_clean <- country_generation_wide %>% 
    rowwise() %>%
    mutate(nr_championships = sum(c(U16_1, U18_1, U18_2, U20_1, U20_2))) %>% 
    ungroup()
  
  country_gender_clean
}