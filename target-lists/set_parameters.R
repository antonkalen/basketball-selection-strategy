# List of targets and likewise for defining user defined parameters and options


# Create lists of user defined parameters ---------------------------------

set_parameters <- list(
  
  # Parameters related to data cleaning
  tar_target(
    name = data_params,
    command = list(
      
      # Max age for making senior debut
      debut_age_cut = 25,
      
      # Maximal possible ranking points
      senior_max_rank = 1000,
      youth_max_rank = 800,
      
      # Minimal number of championships for generation to be included
      min_nr_champs = 3,
      
      # Minimal number of generations for a country to be included (by gender)
      min_generations = 5
    )
  ),
  
  # Parameters related to analyses
  tar_target(
    name = model_params,
    command = list(
      
      # Number of iterations to run
      iter = 10000,
      
      # Number of chains to run
      chains = 4
      
      # Compatibility interval width
    )
  ),
  
  # Plot theme
  tar_target(
    name = plot_theme,
    command = ggplot2::theme_minimal(base_size = 12) + 
      ggplot2::theme(
        axis.title = ggplot2::element_text(size = 10),
        panel.border = ggplot2::element_rect(fill = NA),
        panel.grid = ggplot2::element_blank(),
        legend.position = 'bottom',
        legend.title = ggplot2::element_blank(),
        plot.margin = ggplot2::margin(0,0,0,0,"pt"),
        axis.ticks.length = ggplot2::unit(2,"pt"),
        axis.ticks = ggplot2::element_line(colour = "gray30"),
        panel.spacing.x = ggplot2::unit(2, "lines"),
        panel.spacing.y = ggplot2::unit(1.5, "lines")
      )
  )
)