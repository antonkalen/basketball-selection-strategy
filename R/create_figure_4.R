create_figure_4 <- function(country_data,
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
    theme
  
}
