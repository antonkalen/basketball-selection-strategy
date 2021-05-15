create_figure_5 <- function(generation_data, model, model_moderated, theme) {
  
  # Make data grid
  center <- attr(generation_data$nr_youth_std, "scaled:center")
  scale <- attr(generation_data$nr_youth_std, "scaled:scale")
  
  # Prepare grids for fitting posteriors
  grid <- generation_data %>% 
    dplyr::group_by(gender) %>% 
    tidyr::expand(
      nr_youth = seq(min(nr_youth), max(nr_youth), length.out = 15),
      country = "New",
      players_lic_log_std = 0,
      ranking_points_senior_std = mean(ranking_points_senior_std)
    ) %>% 
    dplyr::mutate(nr_youth_std = (nr_youth - center) / scale) %>% 
    dplyr::ungroup()
  
  country_grid <- generation_data %>% 
    dplyr::group_by(gender, country) %>% 
    tidyr::expand(
      nr_youth = seq(min(nr_youth), max(nr_youth), length.out = 20),
      ranking_points_senior_std,
      players_lic_log_std
    ) %>% 
    dplyr::mutate(nr_youth_std = (nr_youth - center) / scale) %>% 
    dplyr::ungroup()
  
  # Gett fitted draws
  model_country_posteriors <- country_grid %>% 
    tidybayes::add_fitted_draws(model = model_moderated) %>% 
    dplyr::summarise(.value = mean(.value))
  
  model_posteriors <- grid %>% 
    tidybayes::add_fitted_draws(model = model_moderated, allow_new_levels = TRUE, re_formula = NA)
  
  
  # Make plot
  model_posteriors %>% 
    ggplot2::ggplot(ggplot2::aes(x = nr_youth, y = .value)) +
    ggplot2::geom_line(
      data = model_country_posteriors,
      mapping = ggplot2::aes(group = country),
      size = .2,
      alpha = .75
    ) +
    ggdist::stat_lineribbon(show.legend = FALSE, alpha = .3) +
    ggplot2::scale_fill_manual(values = RColorBrewer::brewer.pal(5, "Blues")[3:5]) +
    ggplot2::facet_wrap(~gender) +
    ggplot2::scale_x_continuous(n.breaks = 4, name = "Number of youth players") +
    ggplot2::scale_y_continuous(n.breaks = 4, name = "Number of senior players") +
    theme
  
}