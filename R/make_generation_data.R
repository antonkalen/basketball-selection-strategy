#' Make generation level data
#'
#' @param player_data 
#'
#' @return
#' @export
#'
#' @examples
make_generation_data <- function(player_data) {

  generation_data <- player_data %>% 
    dplyr::group_by(gender, country, birth_year) %>% 
    dplyr::summarise(
      dplyr::across(ranking_senior:players_lic_log_std, unique),
      nr_youth = n(),
      nr_senior = sum(senior),
      .groups = "drop"
    )
  
  # Transform proportion of players to senior, to avoid 0's
  generation_data_trans <- generation_data %>% 
    dplyr::mutate(
      nr_youth_std = scale(nr_youth),
    ) %>% 
    tidyr::drop_na(players_lic_log_std)
  
  ## Add back scaled attributes
  attr(generation_data_trans$players_lic_log_std, "scaled:center") <- attr(player_data$players_lic_log_std, "scaled:center")
  attr(generation_data_trans$players_lic_log_std, "scaled:scale") <- attr(player_data$players_lic_log_std, "scaled:scale")
  
  # Return transformed data
  generation_data_trans
}