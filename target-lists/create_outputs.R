create_outputs <- list(
  
  # Create Figures ----------------------------------------------------------
  
  tar_target(
    name = figure_1,
    command = create_figure_1(
      generation_data = generation_data,
      model_posteriors = nr_youth_pred_draws,
      width = .95,
      theme = plot_theme
    ),
    format = "qs"
  ),
  tar_target(
    name = figure_2,
    command = create_figure_2(
      country_data = country_data,
      model = nr_youth_lic_players_mod,
      theme = plot_theme
    ),
    format = "qs"
  ),
  tar_target(
    name = figure_3,
    command = create_figure_3(
      country_data = country_data,
      model_moderated_posteriors = nr_youth_ranking_lic_players_draws,
      theme = plot_theme
    ),
    format = "qs"
  ),
  tar_target(
    name = figure_4,
    command = create_figure_4(
      country_data = country_data,
      model_moderated = nr_youth_senior_lic_players_country_mod,
      theme = plot_theme
    ),
    format = "qs"
  ),
  tar_target(
    name = figure_5,
    command = create_figure_5(
      generation_data = generation_data,
      model_moderated = nr_youth_senior_lic_players_generation_mod,
      theme = plot_theme
    ),
    format = "qs"
  ),
  
  tar_target(
    name = figure_6,
    command = create_figure_6(
      senior_players = senior_players,
      theme = plot_theme
    ),
    format = "qs"
  ),
  

  # Save figures ------------------------------------------------------------

  tar_map(
    values = list(device = c("pdf", "tiff")),

    tar_target(
      name = figure_1_write,
      command = save_figure(
        figure = figure_1,
        path = "output",
        filename = "figure_1",
        device = device,
        scale = 1,
        width = 180,
        height = 140
      ),
      format = "file"
    ),

    tar_target(
      name = figure_2_write,
      command = save_figure(
        figure = figure_2,
        path = "output",
        filename = "figure_2",
        device = device,
        scale = 1,
        width = 180,
        height = 90
      ),
      format = "file"
    ),

    tar_target(
      name = figure_3_write,
      command = save_figure(
        figure = figure_3,
        path = "output",
        filename = "figure_3",
        device = device,
        scale = 1,
        width = 180,
        height = 180
      ),
      format = "file"
    ),
    tar_target(
      name = figure_4_write,
      command = save_figure(
        figure = figure_4,
        path = "output",
        filename = "figure_4",
        device = device,
        scale = 1,
        width = 180,
        height = 90
      ),
      format = "file"
    ),

    tar_target(
      name = figure_5_write,
      command = save_figure(
        figure = figure_5,
        path = "output",
        filename = "figure_5",
        device = device,
        scale = 1,
        width = 180,
        height = 90
      ),
      format = "file"
    ),


    tar_target(
      name = figure_6_write,
      command = save_figure(
        figure = figure_6,
        path = "output",
        filename = "figure_6",
        device = device,
        scale = 1,
        width = 180,
        height = 90
      ),
      format = "file"
    )
  ),

  # Create tables -----------------------------------------------------------
  
  tar_target(
    name = table_1,
    command = make_table_1(
      model = nr_youth_ranking_mod,
      model_moderator = nr_youth_ranking_lic_players_mod,
      width = .95
    )
  ),
  tar_target(
    name = table_2,
    command = make_table_2(
      model = nr_youth_senior_country_mod,
      model_moderator = nr_youth_senior_lic_players_country_mod,
      width = .95
    )
  ),
  tar_target(
    name = table_3,
    command = make_table_3(
      model = nr_youth_senior_generation_mod,
      model_moderator = nr_youth_senior_lic_players_generation_mod,
      width = .95
    )
  ),
  

  # Save tables -------------------------------------------------------------
  
  tar_target(
    name = table_1_write,
    command = save_csv(
      x = table_1,
      file = here::here("output", "table_1.csv")
    )
  ),
  tar_target(
    name = table_2_write,
    command = save_csv(
      x = table_2,
      file = here::here("output", "table_2.csv")
    )
  ),
  tar_target(
    name = table_3_write,
    command = save_csv(
      x = table_3,
      file = here::here("output", "table_3.csv")
    )
  ),
  

  # Save results ------------------------------------------------------------

  tar_render(
    name = results,
    path = "results.Rmd"
  )
)
