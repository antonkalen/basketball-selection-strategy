create_figure_6 <- function(senior_players, theme) {
  
  # Calculate median debut age
  senior_debut_median <- senior_players %>% 
    dplyr::group_by(gender, played_youth) %>% 
    dplyr::summarise(debut_age = median(senior_debut_age))
  
  # Create plot
  senior_players %>% 
    ggplot2::ggplot(
      ggplot2::aes(
        x = senior_debut_age,
        color = played_youth,
        fill = played_youth)
      ) +
    ggplot2::geom_histogram(binwidth = 1, alpha = .5, position = "identity") +
    ggplot2::geom_vline(
      data = senior_debut_median, 
      mapping = ggplot2::aes(xintercept = debut_age, color = played_youth),
      linetype = "dashed",
      show.legend = FALSE
    ) +
    ggplot2::facet_wrap(~gender) +
    ggplot2::coord_cartesian(xlim = c(14.5, 35.5), ylim = c(-.1, 64), expand = FALSE) +
    ggplot2::scale_color_brewer(palette = "Dark2") +
    ggplot2::scale_fill_brewer(palette = "Dark2") +
    ggplot2::labs(title = NULL, x = "Number of youth players per generation", y = NULL) +
    theme
}



