create_figure_5 <- function(country_data, model, model_moderated, theme) {
  
  # Make data grid
  center <- attr(country_data$nr_youth_m_to_senior_std, "scaled:center")
  scale <- attr(country_data$nr_youth_m_to_senior_std, "scaled:scale")
  
  # Prepare grids for fitting posteriors
  grid <- country_data %>% 
    dplyr::group_by(gender) %>% 
    tidyr::expand(
      nr_youth_m_to_senior = seq(min(nr_youth_m_to_senior), max(nr_youth_m_to_senior), length.out = 30),
      nr_youth_cv_to_senior_std = 0,
      country = "New",
      players_lic_log_std = 0,
      ranking_points_senior_std = mean(ranking_points_senior_std)
    ) %>% 
    dplyr::mutate(nr_youth_m_to_senior_std = (nr_youth_m_to_senior - center) / scale) %>% 
    dplyr::ungroup()
  
  # Gett fitted draws
  model_posteriors <- grid %>% 
    tidybayes::add_fitted_draws(model = model, allow_new_levels = TRUE, re_formula = NA)
  
  model_moderated <- grid %>% 
    tidybayes::add_fitted_draws(model = model_moderated, allow_new_levels = TRUE, re_formula = NA)
  
  
  # Make plot
  model_posteriors %>% 
    ggplot2::ggplot(ggplot2::aes(x = nr_youth_m_to_senior, y = .value)) +
    ggplot2::geom_point(
      data = country_data, 
      mapping = ggplot2::aes(y = nr_senior_m),
      alpha = 1, 
      size = 1.5,
      shape = 16,
    ) +
    ggdist::stat_lineribbon(
      .width = c(.66, .95),
      mapping = ggplot2::aes(fill = "Not controlled", color = "Not controlled"),
      alpha = .3
    ) +
    ggdist::stat_lineribbon(
      data = model_moderated,
      .width = c(.66, .95),
      mapping = ggplot2::aes(fill = "Controlled for number of licenced players", color = "Controlled for number of licenced players"),
      alpha = .3
    ) +
    ggplot2::scale_fill_manual(
      name = "",
      values = c("Not controlled" = "#636363", "Controlled for number of licenced players" = "#2171b5")
    ) +
    ggplot2::scale_color_manual(
      name = "",
      values = c("Not controlled" = "#636363", "Controlled for number of licenced players" = "#08306b")
    ) +
    ggplot2::facet_wrap(~gender) +
    ggplot2::scale_x_continuous(n.breaks = 4, name = "Number of youth players per generation") +
    ggplot2::scale_y_continuous(n.breaks = 4, name = "Number of senior players per generation") +
    theme + 
    ggplot2::theme(
      # panel.grid.major = ggplot2::element_blank(),
      panel.spacing.x = ggplot2::unit(2, "lines"),
      panel.spacing.y = ggplot2::unit(1.5, "lines"),
      axis.title = ggplot2::element_text(size = 10),
      axis.ticks.length.y = ggplot2::unit(0,"pt"),
      axis.ticks.y = ggplot2::element_blank(),
      axis.ticks.length.x = ggplot2::unit(0,"pt"),
      axis.ticks.x = ggplot2::element_blank()
    )
  
  
}