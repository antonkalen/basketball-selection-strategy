#' Make player level data
#'
#' @param raw_player_data 
#' @param latent_classes 
#' @param debut_age_cut 
#' @param ranking_data
#' @param inclusion_data 
#'
#' @return
make_player_data <- function(raw_player_data, 
                             debut_age_cut, 
                             ranking_data,
                             licenced_players_data,
                             inclusion_data) {
  
  # Fix country issues in data
  player_country_fixed <- fix_countries(raw_player_data)
  
  # Summarize participation per player
  player_data <- make_player_participation_data(
    player_country_fixed, 
    debut_age_cut
  )
  
  # Filter out players from generations that should not be included
  ## Get important data from inclusion data
  include_gen <- inclusion_data %>% select(gender, country, birth_year, include)
  
  ## Merge inclusion data and filter out players not to be included
  players_filtered <- player_data %>% 
    left_join(include_gen, by = c("gender", "country", "birth_year")) %>% 
    filter(include == TRUE) %>% 
    select(-include)
  
  # Add country ranking
  player_data_ranking <- players_filtered %>% 
    left_join(ranking_data, by = c("gender", "country"))
  
  # Add licenced players data
  player_data_licenced <- player_data_ranking %>% 
    left_join(licenced_players_data, by = c("gender", "country"))
  
  # Return data with classes and ranking added
  player_data_licenced
}



#' Fix country issues.
#' 
#' Recodes England to Great Britain.
#' For players from Scotland who played for Great Britain: get debut age from
#' when they played for Scotland.
#' If players have later tournament played with either Serbia or Montenegro
#' change to that country. If only played for Serbia & Montenegro: exclude.
#' Meaning we have to exclude '88-'90 generations of Serbian and of Montenegro.
#'
#' @param player_data 
#'
#' @return
fix_countries <- function(player_data) {
  
  # Recode England to Great Britain
  # For players from Scotland who played for Great Britain: get debut age from 
  # when they played for Scotland
  # Change Serbia & Montenegro
  # If players have later tournament played with either Serbia or Montenegro,
  # change to that country. If only played for Serbia & Montenegro: exclude.
  # Meaning we have to exclude '88-'90 generations of Serbian and of Montenegro.
  
  players_cleaned_country <- player_data %>% 
    dplyr::group_by(category, player_id, gender, birth_year) %>% 
    dplyr::arrange(debut_year, .by_group = TRUE) %>% 
    dplyr::mutate(
      country = dplyr::case_when(
        country == "England" ~ "Great Britain",
        country == "Serbia & Montenegro" ~ lead(country),
        TRUE ~ country
      ),
      debut_year = dplyr::case_when(
        country == "Great Britain" ~ min(debut_year),
        TRUE ~ debut_year
      )
    ) %>%
    dplyr::group_by(category, player_id, gender, country, birth_year) %>% 
    dplyr::summarise(
      debut_year = min(debut_year),
      dplyr::across(c(birth_month, nr_youth_years:age_20), unique),
      .groups = "drop"
    ) %>% 
    ungroup() %>% 
    dplyr::filter(!is.na(country))
  
  # filter out Serbia and Montenegro born 1988-1990
  players_cleaned_country_filtered <- players_cleaned_country %>% 
    dplyr::filter(!(country %in% c("Serbia", "Montenegro") & birth_year %in% 1988:1990))
  
  players_cleaned_country_filtered
}



#' Make participation data for each player
#'
#' @param player_data 
#' @param debut_age_cut 
#'
#' @return
#' @export
#'
#' @examples
make_player_participation_data <- function(player_data, debut_age_cut) {

  # Get players making senior debut before debut_age_cut age.
  player_data_age_cut <- player_data %>% 
    dplyr::mutate(
      debut_age = debut_year - birth_year,
      debut_age_youth = dplyr::if_else(category == "youth", debut_age, NA_integer_),
      debut_age_senior = dplyr::if_else(category == "senior", debut_age, NA_integer_),
    ) %>% 
    filter(debut_age <= debut_age_cut)
  
  # Add columns if player participated in youth and/or senior.
  player_data_participations <- player_data_age_cut %>% 
    dplyr::group_by(gender, country, birth_year, player_id, birth_month) %>% 
    dplyr::summarise(
      youth = as.integer("youth" %in% category),
      senior = as.integer("senior" %in% category),
      dplyr::across(
        c(nr_youth_years:age_20, debut_age_youth, debut_age_senior), 
        ~dplyr::if_else(all(is.na(.x)), NA_integer_, sum(.x, na.rm = TRUE)),
      ),
      .groups = "drop"
    )
  
  # Remove senior information for players that still have possibility to debut
  # before the max senior debut age
  
  ## Get latest year of senior debut data
  senior_year_max <- max(filter(player_data, category == "senior")$debut_year)
  
  ## Calculate the latest generation that can no longer debut before
  ## max senior debut age
  generation_senior <- senior_year_max - debut_age_cut
  
  ## Replace senior participation and senior debut age with missing if player
  ## still can make senior debut before max senior debut age
  player_particip_cleaned <- player_data_participations %>% 
    dplyr::mutate(
      dplyr::across(
        c(senior, debut_age_senior),
        ~ dplyr::if_else(birth_year > generation_senior, NA_integer_, .x)
      )
    )
  
  # Keep only players that played youth
  player_particip_filtered <- player_particip_cleaned %>% 
    dplyr::filter(youth == 1) %>% 
    dplyr::select(-youth)
  
  # Return cleaned and filtered participation data
  player_particip_filtered
}
