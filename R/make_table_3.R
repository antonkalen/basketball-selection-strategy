make_table_3 <- function(model, model_moderator, width) {
  
  model_table_1 <- make_table_3_part(model = model, width = width)
  model_table_2 <- make_table_3_part(model = model_moderator, width = width)
  
  full_table <- model_table_1 %>% 
    dplyr::full_join(
      model_table_2, 
      by = c("gender", "variable"),
      suffix = c("_model", "_moderator_model")
    ) %>% 
    dplyr::arrange(
      stringr::str_detect(variable, "sigma.*"),
      gender,
      match(variable, c("intercept", "nr_youth", "nr_youth_cv", "players_lic", "ranking_points_senior"))
    )
  
  full_table
}

make_table_3_part <- function(model, width) {
  
  # Get draws
  draws_summary <- model %>% 
    tidybayes::gather_draws(`b.*`, `sd.*`, regex = TRUE) %>% 
    ggdist::mean_hdi() %>% 
    dplyr::mutate(.variable = stringr::str_replace(.variable, ":", "."))
  
  # Get probability of direction
  draws_pd <- model %>% 
    bayestestR::p_direction()
  
  draws_joined <- draws_summary %>% 
    dplyr::left_join(draws_pd, by = c(".variable" = "Parameter"))
  
  draws_cleaned <- draws_joined %>% 
    dplyr::mutate(
      gender = dplyr::case_when(
        stringr::str_detect(.variable, "Men") ~ "men",
        stringr::str_detect(.variable, "Women") ~ "women",
        TRUE ~ "men"
      ),
      variable = dplyr::case_when(
        .variable == "sd_gender.country__Intercept" ~ "sigma_intercept",
        .variable == "sd_gender.country__nr_youth_std" ~ "sigma_nr_youth",
        stringr::str_detect(.variable, "Intercept") ~ "intercept",
        stringr::str_detect(.variable, "nr_youth_std") ~ "nr_youth",
        stringr::str_detect(.variable, "players_lic_log_std") ~ "players_lic",
        stringr::str_detect(.variable, "ranking_points_senior_std") ~ "ranking_points_senior",
        TRUE ~ "intercept"
      )
    )
  
  draws_selected <- draws_cleaned %>% 
    dplyr::select(
      gender,
      variable,
      value = .value,
      lower = .lower,
      upper = .upper,
      pd
    )
  
  draws_selected
}
