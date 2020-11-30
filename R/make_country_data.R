make_country_data <- function(player_data = player_data) {
  # make dummy variables of classes
  player_data <- player_data %>% 
    mutate(dummy = 1) %>% 
    pivot_wider(
      names_from = class,
      values_from = dummy,
      values_fill = 0,
      names_sort = TRUE
    ) %>% 
    janitor::clean_names()
  
  # Make summary for each gender, country, birth year combination
  country_data <- player_data %>%
    group_by(gender, country, birth_year) %>%
    summarise(
      senior_ranking = unique(senior_ranking),
      senior_ranking_points = unique(senior_ranking_points),
      youth_ranking = unique(youth_ranking),
      youth_ranking_points = unique(youth_ranking_points),
      ranking_points_ratio = senior_ranking_points / youth_ranking_points,
      nr_youth_total = sum(youth),
      nr_youth_only = sum(youth & !senior),
      nr_youth_senior = sum(youth & senior),
      nr_senior_only = sum(!youth & senior),
      nr_senior_total = sum(senior),
      prop_youth_senior = nr_youth_senior / nr_youth_total,
      across(starts_with("class"), sum),
      .groups = "drop",
    )
  
  country_data <- country_data %>% 
    mutate(ranking_points_ratio = na_if(ranking_points_ratio, Inf))
  
  country_data
}
