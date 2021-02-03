#' Clean senior player data
#'
#' Calculate the senior national team debut age, and makes a factor to indicate
#' if the player had played in youth national team or not.
#'
#' @param senior_player_data_raw The raw data of players from the last senior
#'   championships. Must contain the following columns: - `senior_debut_year`:
#'   Indicating the year the player played his or her first senior national team
#'   game. - `birth_year`: Indicating the year the player was born. -
#'   `played_youth`: Indicating if the player had played any youth championships
#'   (`1`/`TRUE`) or not (`0`/`FALSE`).
#'
#' @return A tibble with the original data, a new column `senior_debut_age`
#'   calculated as `senior_debut_year - birth_year`, and the column
#'   `played_youth` converted into a factor with the values "Played Youth" and
#'   "Senior Only".
clean_senior_players <- function(senior_player_data_raw) {
  senior_player_data_raw %>% 
    dplyr::mutate(
      senior_debut_age = senior_debut_year - birth_year,
      played_youth = factor(
        played_youth, 
        levels = c(1, 0), 
        labels = c("Played Youth", "Senior Only")
      )
    )
}