make_table_1 <- function(model, model_moderator, width) {
  
  model_table_1 <- make_table_1_part(model = model, width = width)
  model_table_2 <- make_table_1_part(model = model_moderator, width = width)
  
  full_table <- model_table_1 %>% 
    dplyr::full_join(
      model_table_2, 
      by = c("outcome", "gender", "variable"),
      suffix = c("_model", "_moderator_model")
    ) %>% 
    dplyr::arrange(
      match(outcome, c("senior", "youth")),
      gender,
      match(variable, c("intercept", "nr_youth_m", "nr_youth_cv", "players_lic", "phi"))
    )

  full_table
}

make_table_1_part <- function(model, width) {
  
  # Get draws
  draws_summary <- model %>% 
    tidybayes::gather_draws(`b.*`, regex = TRUE) %>% 
    ggdist::mean_hdi() %>% 
    mutate(.variable = stringr::str_replace(.variable, ":", "."))
  
  # Get probability of direction
  draws_pd <- model %>% 
    bayestestR::p_direction()
  
  draws_joined <- draws_summary %>% 
    dplyr::left_join(draws_pd, by = c(".variable" = "Parameter"))
  
  draws_cleaned <- draws_joined %>% 
    mutate(
      gender = dplyr::case_when(
        stringr::str_detect(.variable, "Men") ~ "men",
        stringr::str_detect(.variable, "Women") ~ "women",
        TRUE ~ "men"
      ),
      outcome = stringr::str_extract(.variable, "senior|youth"),
      variable = dplyr::case_when(
        stringr::str_detect(.variable, "Intercept") ~ "intercept",
        stringr::str_detect(.variable, "nr_youth_m") ~ "nr_youth_m",
        stringr::str_detect(.variable, "nr_youth_cv") ~ "nr_youth_cv",
        stringr::str_detect(.variable, "players_lic_log_std") ~ "players_lic",
        stringr::str_detect(.variable, "phi") ~ "phi",
        TRUE ~ "intercept"
      )
    )
  
  draws_selected <- draws_cleaned %>% 
    select(
      outcome,
      gender,
      variable,
      value = .value,
      lower = .lower,
      upper = .upper,
      pd
    )
  
  draws_selected
}
