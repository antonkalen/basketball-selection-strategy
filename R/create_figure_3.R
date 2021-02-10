create_figure_3 <- function(country_data,
                            model_moderated_posteriors,
                            theme) {
  
  # Format posterior predictive draws
  model_moderated_posteriors_clean <- model_moderated_posteriors %>% 
    dplyr::mutate(
      category = dplyr::case_when(
        gender == "Men" & grepl("senior", .category) ~ "Men's Senior Ranking Points",
        gender == "Men" & grepl("youth", .category) ~ "Men's Youth Ranking Points",
        gender == "Women" & grepl("senior", .category) ~ "Women's Senior Ranking Points",
        gender == "Women" & grepl("youth", .category) ~ "Women's Youth Ranking Points"
      )
    )
  
  # Format observed data
  country_data_clean <- country_data %>% 
    tidyr::pivot_longer(
      cols = c(ranking_points_senior_std, ranking_points_youth_std),
      names_to = ".category",
      values_to = ".value"
    ) %>% 
    dplyr::mutate(
      category = dplyr::case_when(
        gender == "Men" & grepl("senior", .category) ~ "Men's Senior Ranking Points",
        gender == "Men" & grepl("youth", .category) ~ "Men's Youth Ranking Points",
        gender == "Women" & grepl("senior", .category) ~ "Women's Senior Ranking Points",
        gender == "Women" & grepl("youth", .category) ~ "Women's Youth Ranking Points"
      )
    )
  
  # Make plot
  model_moderated_posteriors_clean %>% 
    ggplot2::ggplot(ggplot2::aes(x = nr_youth_m, y = .value)) +
    ggplot2::geom_point(data = country_data_clean, alpha = 1, size = 1.5, shape = 16, color = "Gray30") +
    ggdist::stat_lineribbon(show.legend = FALSE, alpha = .3) +
    ggplot2::scale_fill_manual(values = RColorBrewer::brewer.pal(5, "Blues")[3:5]) +
    ggplot2::facet_wrap(~ category, scales = "free", dir = "v") +
    ggplot2::scale_y_continuous(limits = c(0,.85), n.breaks = 5, name = "Standardized ranking points") +
    ggplot2::scale_x_continuous(limits = c(8,20), n.breaks = 4, name = "Number of youth players per generation") +
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