Talent selection strategies and relationship with success in European
basketball national team programs
================
2021-05-15

This is repo for the article “Talent selection strategies and
relationship with success in European basketball national team
programs”. All code is written in `R`, uses
[`targets`](https://docs.ropensci.org/targets/) to manage the workflow,
and [`renv`](https://rstudio.github.io/renv) to manage needed packages.

## Re-run the analysis

The easiest way to run the analysis on your local computer is:

1.  Download the full project repository.
2.  Open the project file `basketball-selection-strategy.Rproj` in
    [RStudio](https://rstudio.com),
3.  Run `targets::tar_make()` to re-run the analysis. Or run
    `targets::tar_make_future(workers = parallel::detectCores())` to run
    the analysis on multiple cores.

You can check all parts of the anaylysis pipeline by running
`targets::tar_visnetwork()`.

## Project organisation

The project has the following organisation:

    ├── Readme.md                            # This file which explains the project.
    ├── basketball-selection-strategy.Rproj  # RStudio project file.
    ├── _targets.R                           # The file targets::tar_make() uses to run everything.
    ├── _packages.R                          # Info of packages used (created by targets::tar_renv() for renv to work)
    ├── renv.lock                            # Info of package versions used.
    │
    ├── target-lists                         # Contains the workflows used in the targets-pipeline.
    ├── R                                    # Contains all functions used for the analyses.
    ├── data-raw                             # Contains the raw data used to create the final datasets.
    ├── data                                 # Contains the data and data explanation for the analysis.
    ├── output                               # Contains tables, figures and other results.
    └── renv                                 # Contains files for renv to use correct package versions.

The folders `data` and `target-lists` contains specific readme files
with more detailed information about the data and analysis pipeline,
respectively.
