clean_licenced_players <- function(licenced_players) {
  
  licenced_players %>% 
    dplyr::select(
      gender,
      country,
      players_lic = licenced_players_tot
    ) %>% 
    dplyr::mutate(
      players_lic_log_std = scale(log1p(players_lic))
    )
  
}
