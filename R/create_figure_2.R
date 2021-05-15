create_figure_2 <- function(generation_data, model_posteriors, width, theme) {
  
  # Calculate predicted mean
  posterior_calc <- model_posteriors %>% 
    group_by(gender, country, .draw) %>% 
    summarise(mean = mean(.prediction)) %>% 
    group_by(gender) %>% 
    mutate(gender_mean = mean(mean)) %>% 
    group_by(gender, country) %>% 
    summarise(prob_pos = mean(mean > gender_mean))
  
  # Merge observed data with model posteriors
  plot_data <- generation_data %>% 
    dplyr::left_join(posterior_calc, by = c("gender", "country")) %>% 
    dplyr::mutate(
      group = dplyr::case_when(
        prob_pos > width ~ "Above",
        prob_pos < (1 - width) ~ "Below",
        TRUE ~ "Average"
      ),
      group = factor(group, levels = c("Above", "Average", "Below"))
    )
  
  # Calculate mean nr players
  mean_nr_players <- generation_data %>% 
    dplyr::group_by(gender, country) %>% 
    dplyr::summarise(nr_youth_m = mean(nr_youth)) %>% 
    summarise(nr_youth_m = mean(nr_youth_m))
  
  # Create plot
  plot_data %>% 
    ggplot2::ggplot(
      ggplot2::aes(
        x = nr_youth,  
        y = tidytext::reorder_within(country, by = nr_youth, within = gender, fun = mean),
        color = group
      )
    ) +
    ggplot2::geom_jitter(alpha = .2, size = 1, height = 0, width = .1, shape = 16, color = "black") +
    ggplot2::geom_vline(
      data = mean_nr_players, 
      mapping = ggplot2::aes(xintercept = nr_youth_m),
      color = "gray30"
    ) +
    ggplot2::stat_summary(
      fun.data = "mean_sdl",
      geom = "linerange",
      fun.args = list(mult = 1),
      size = 1,
      alpha = .75,
    ) +
    ggplot2::stat_summary(
      fun = "mean",
      geom = "point"
    ) +
    ggplot2::facet_wrap(~gender, scales = "free") +
    tidytext::scale_y_reordered(name = NULL) +
    ggplot2::scale_color_brewer(palette = "Dark2") + 
    ggplot2::xlab("Number of youth players per generation") +
    theme + 
    ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
  
}
