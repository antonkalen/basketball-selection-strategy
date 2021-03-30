fit_model <- list(
  # Selection strategy model
    tar_target(
      name = nr_youth_mod,
      command = brm(
        bf(
          nr_youth ~ 1 + gender + (1|gender:country),
          sigma ~ 0 + (1|gender:country)
        ),
        prior = c(
          prior(student_t(3, 0, 3.5), class = sd),
          prior(student_t(3, 0, 3.5), class = sd, dpar = sigma)
        ),
        data = generation_data,
        iter = model_params$iter,
        chains = model_params$chains,
        save_pars = save_pars(all = TRUE)
      )
    ),
    tar_target(
      name = nr_youth_pred_draws,
      command = generation_data %>% 
        tidyr::expand(tidyr::nesting(gender, country, birth_year)) %>% 
        tidybayes::add_predicted_draws(nr_youth_mod),
      format = "fst_tbl"
    ),
    
  # Selection strategy model with licenced players as moderator
  tar_target(
    name = nr_youth_lic_players_mod,
    update(
      object = nr_youth_mod,
      formula. = nr_youth ~ . + gender:players_lic_log_std,
      newdata = generation_data,
      save_pars = save_pars(all = TRUE)
    )
  ),
  tar_target(
    name = nr_youth_lic_players_draws,
    command = generation_data %>% 
      drop_na(players_lic_log_std) %>% 
      tidyr::expand(
        tidyr::nesting(
          gender, 
          country, 
          birth_year, 
          players_lic_log_std = 0,
        )
      ) %>% 
      tidybayes::add_predicted_draws(nr_youth_lic_players_mod),
    format = "fst_tbl"
  ),
    
    
  # Nr youth and ranking
  tar_target(
    name = nr_youth_ranking_mod,
    command = brm(
      bf(
        mvbind(ranking_points_senior_std, ranking_points_youth_std) ~ 1 + 
          gender + gender:nr_youth_m_std + gender:nr_youth_cv_std,
        phi ~ 0 + gender
      ),
      prior = c(
        prior(normal(0, 2.5), class = b, resp = rankingpointsseniorstd),
        prior(normal(0, 2.5), class = b, resp = rankingpointsyouthstd)
      ),
      family = Beta(),
      data = country_data,
      iter = model_params$iter,
      chains = model_params$chains,
      save_pars = save_pars(all = TRUE)
    )
  ),
  tar_target(
    name = nr_youth_ranking_pred_draws,
    command = get_nr_youth_ranking_pred_draws(
      country_data = country_data,
      model = nr_youth_ranking_mod
    ),
    format = "fst_tbl"
  ),
  
  # Nr youth and ranking moderated by nr of licenced players
  tar_target(
    name = nr_youth_ranking_lic_players_mod,
    command = brm(
      bf(
        mvbind(ranking_points_senior_std, ranking_points_youth_std) ~ 1 + 
          gender + gender:nr_youth_m_std + gender:nr_youth_cv_std + gender:players_lic_log_std,
        phi ~ 0 + gender
      ),
      prior = c(
        prior(normal(0, 2.5), class = b, resp = rankingpointsseniorstd),
        prior(normal(0, 2.5), class = b, resp = rankingpointsyouthstd)
      ),
      family = Beta(),
      data = country_data,
      iter = model_params$iter,
      chains = model_params$chains,
      save_pars = save_pars(all = TRUE)
    )
  ),
  tar_target(
    name = nr_youth_ranking_lic_players_draws,
    command = nr_youth_ranking_lic_players_draws(
      country_data = country_data,
      model = nr_youth_ranking_lic_players_mod
    ),
    format = "fst_tbl"
  ),
  
  # Nr youth and senior debut
  tar_target(
    name = nr_youth_senior_country_mod,
    command = brm(
      nr_senior_m ~ 1 + 
        gender + 
        gender:nr_youth_m_to_senior_std + 
        gender:nr_youth_cv_to_senior_std,
      prior = c(
        prior(normal(0, 2.5), class = Intercept),
        prior(normal(0, 2.5), class = b),
        prior(student_t(3, 0, 3.5), class = sigma)
      ),
      data = country_data,
      iter = model_params$iter,
      chains = model_params$chains,
      save_pars = save_pars(all = TRUE)
    )
  ),
  
  tar_target(
    name = nr_youth_senior_lic_players_country_mod,
    command = update(
      object = nr_youth_senior_country_mod,
      formula. = . ~ . + gender:players_lic_log_std + gender:ranking_points_senior_std,
      newdata = country_data
    )
  ),
  
  ## Generation level
  
  tar_target(
    name = nr_youth_senior_generation_mod,
    command = brm(
      nr_senior ~ 1 + gender + gender:nr_youth_std + (1 + nr_youth_std||gender:country),
      prior = c(
        prior(normal(0, 2.5), class = Intercept),
        prior(normal(0, 2.5), class = b),
        prior(student_t(3, 0, 3.5), class = sd)
      ),
      family = poisson(),
      data = generation_data,
      iter = model_params$iter,
      chains = model_params$chains,
      save_pars = save_pars(all = TRUE)
    )
  ),
  
  # Nr youth and senior debut generation moderated by nr of licensed players
  # and senior ranking
  tar_target(
    name = nr_youth_senior_lic_players_generation_mod,
    command = update(
      object = nr_youth_senior_generation_mod,
      formula. = . ~ . + gender:players_lic_log_std + gender:ranking_points_senior_std,
      newdata = generation_data
    )
  )
)