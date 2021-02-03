make_country_data <- function(generation_data) {
  
  # Summarise data
  country_data <- generation_data %>% 
    dplyr::group_by(gender, country) %>% 
    dplyr::summarise(
      dplyr::across(ranking_senior:players_lic_log_std, unique),
      nr_generations = dplyr::n(),
      nr_youth_m = mean(nr_youth),
      nr_youth_cv = 100 * sd(nr_youth) / nr_youth_m,
      .groups = "drop"
    )
  
  # Summarise youth to senior data
  youth_senior_data <- generation_data %>% 
    tidyr::drop_na(nr_senior) %>% 
    dplyr::group_by(gender, country) %>% 
    dplyr::summarise(
      nr_youth_m_to_senior = mean(nr_youth),
      nr_youth_cv_to_senior = 100 * sd(nr_youth) / nr_youth_m_to_senior,
      nr_senior_m = mean(nr_senior)
    )
  
  coutry_data_joined <- country_data %>% 
    dplyr::left_join(youth_senior_data, by = c("gender", "country"))
  
  # Standardise mean and cv
  country_data_std <- coutry_data_joined %>% 
    dplyr::mutate(
      dplyr::across(
        c(nr_youth_m, nr_youth_cv, nr_youth_m_to_senior, nr_youth_cv_to_senior, nr_senior_m), 
        scale,
        .names = "{.col}_std"
      ),
    )
  
  # Add back scaled attributes
  attr(country_data_std$players_lic_log_std, "scaled:center") <- attr(generation_data$players_lic_log_std, "scaled:center")
  attr(country_data_std$players_lic_log_std, "scaled:scale") <- attr(generation_data$players_lic_log_std, "scaled:scale")
  
  # Return transformed data
  country_data_std
}