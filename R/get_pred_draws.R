get_nr_youth_ranking_pred_draws <- function(country_data, model) {
  
  # Make data grid
  center <- attr(country_data$nr_youth_m_std, "scaled:center")
  scale <- attr(country_data$nr_youth_m_std, "scaled:scale")
  
  data_grid <- country_data %>% 
      group_by(gender) %>% 
      tidyr::expand(
        nr_youth_m = seq(min(nr_youth_m), max(nr_youth_m), length.out = 30),
        nr_youth_cv_std = 0
      ) %>% 
      dplyr::transmute(
        gender,
        nr_youth_m_std = (nr_youth_m - center) / scale,
        nr_youth_m,
        nr_youth_cv_std
      )
  
  # Get draws
  data_grid %>% 
    tidybayes::add_fitted_draws(model = model)
}

nr_youth_ranking_lic_players_draws <- function(country_data, model) {
  
  # Make data grid
  center <- attr(country_data$nr_youth_m_std, "scaled:center")
  scale <- attr(country_data$nr_youth_m_std, "scaled:scale")
  
  data_grid <- country_data %>% 
    group_by(gender) %>% 
    tidyr::expand(
      nr_youth_m = seq(min(nr_youth_m), max(nr_youth_m), length.out = 30),
      nr_youth_cv_std = 0,
      players_lic_log_std = 0,
    ) %>% 
    dplyr::transmute(
      gender,
      nr_youth_m_std = (nr_youth_m - center) / scale,
      nr_youth_m,
      nr_youth_cv_std,
      players_lic_log_std
    )
  
  # Get draws
  data_grid %>% 
    tidybayes::add_fitted_draws(model = model)
}



get_nr_youth_senior_generation_pred_draws <- function(generation_data, model) {
  
  # Make data grid
  center <- attr(generation_data$nr_youth_std, "scaled:center")
  scale <- attr(generation_data$nr_youth_std, "scaled:scale")
  
  data_grid <- generation_data %>% 
    group_by(gender) %>% 
    tidyr::expand(
      nr_youth = seq(min(nr_youth), max(nr_youth), length.out = 30),
      country = "new"
    ) %>% 
    dplyr::transmute(
      gender,
      nr_youth_std = (nr_youth - center) / scale,
      nr_youth,
      country
    )
  
  # Get draws
  data_grid %>% 
    tidybayes::add_fitted_draws(model = model, re_formula = NA)
}