create_figure_2 <- function(country_data, model, theme) {

  # Make data grid
  center <- attr(country_data$players_lic_log_std, "scaled:center")
  scale <- attr(country_data$players_lic_log_std, "scaled:scale")
  
  data_grid <- country_data %>%
    tidyr::drop_na(players_lic) %>% 
    dplyr::group_by(gender) %>%
    tidyr::expand(
      players_lic = seq(min(players_lic), max(players_lic), length.out = 15),
      country = "New"
    ) %>%
    dplyr::transmute(
      gender,
      players_lic_log_std = (log(players_lic) - center) / scale,
      players_lic,
      country
    )
  
  
  # Add draws
  draws <- data_grid %>% 
    tidybayes::add_fitted_draws(model = model, allow_new_levels = TRUE, re_formula = NA)

  # Make plot
  draws %>% 
    ggplot2::ggplot(ggplot2::aes(x = players_lic, y = .value)) +
    ggplot2::geom_point(data = country_data, mapping = ggplot2::aes(y = nr_youth_m), alpha = 1, size = 1.5, shape = 16) +
    ggdist::stat_lineribbon(show.legend = FALSE, alpha = .3) +
    ggplot2::facet_wrap(~ gender, dir = "h") +
    ggplot2::scale_x_log10(label = scales::label_comma(), name = "Number of licensed players") +
    ggplot2::ylab("Number of youth players per generation") +
    ggplot2::scale_fill_manual(values = RColorBrewer::brewer.pal(5, "Blues")[3:5]) +
    theme
}