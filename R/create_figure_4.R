create_figure_4 <- function(country_data,
                            model_posteriors,
                            model_moderated_posteriors,
                            theme) {
  
  # Merge posterior predictive draws
  model_posteriors_merged <- dplyr::bind_rows(
    "Not controlled" = model_posteriors,
    "Controlled for number of licenced players" = model_moderated_posteriors,
    .id = "model"
  )
  
  # Format posterior predictive draws
  model_posteriors_clean <- model_posteriors %>% 
    dplyr::mutate(
      category = dplyr::case_when(
        gender == "Men" & grepl("senior", .category) ~ "Men's Senior Ranking Points",
        gender == "Men" & grepl("youth", .category) ~ "Men's Youth Ranking Points",
        gender == "Women" & grepl("senior", .category) ~ "Women's Senior Ranking Points",
        gender == "Women" & grepl("youth", .category) ~ "Women's Youth Ranking Points"
      )
    )
  
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
  model_posteriors_clean %>% 
    ggplot2::ggplot(ggplot2::aes(x = nr_youth_m, y = .value)) +
    ggplot2::geom_point(data = country_data_clean, alpha = 1, size = 1.5, shape = 16, color = "Gray30") +
    ggdist::stat_lineribbon(
      .width = c(.66, .95),
      mapping = ggplot2::aes(fill = "Not controlled", color = "Not controlled"),
      alpha = .3
    ) +
    ggdist::stat_lineribbon(
      data = model_moderated_posteriors_clean,
      .width = c(.66, .95),
      mapping = ggplot2::aes(fill = "Controlled for number of licenced players", color = "Controlled for number of licenced players"),
      alpha = .3
    ) +
    ggplot2::facet_wrap(~ category, scales = "free", dir = "v") +
    ggplot2::scale_y_continuous(limits = c(0,.85), n.breaks = 5, name = "Standardized ranking points") +
    ggplot2::scale_x_continuous(limits = c(8,20), n.breaks = 4, name = "Number of youth players per generation") +
    ggplot2::scale_fill_manual(
      name = "",
      values = c("Not controlled" = "#636363", "Controlled for number of licenced players" = "#2171b5")
    ) +
    ggplot2::scale_color_manual(
      name = "",
      values = c("Not controlled" = "#636363", "Controlled for number of licenced players" = "#08306b")
    ) +
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