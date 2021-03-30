Analysis pipeline
================
2021-03-30

This folder contains the steps of the analysis workflow that the
[`targets`](https://docs.ropensci.org/targets/)-package uses to run the
analysis pipeline. The specific actions (called `targets`) are divided
into separate files corresponding to the different steps of the
workflow.

## Files

The steps are divided into the following files, corresponding with the
different steps of the workflow:

    ├── set_parameters    # Defines parameters of the analysis (e.g., nr iterations and CI-level).
    ├── read_raw_data     # Loads the raw input data.
    ├── data_cleaning     # Prepares the raw data inte final datasets for the analysis.
    ├── fit_models        # Fits the models used for the analysis.
    └── create_outputs    # Create the final results, tables and figures.

## Models

In total, eight models were fitted for the analyses:

  - `nr_youth_mod`
  - `nr_youth_lic_players_mod`
  - `nr_youth_ranking_mod`
  - `nr_youth_ranking_lic_players_mod`
  - `nr_youth_senior_country_mod`
  - `nr_youth_senior_lic_players_country_mod`
  - `nr_youth_senior_generation_mod`
  - `nr_youth_senior_lic_players_generation_mod`

### `nr_youth_mod`

Used to model the average amount of youth national team players per
country and generation, as well within-country variation of number of
youth players between the different generations (for each gender).

    ##  Family: gaussian 
    ##   Links: mu = identity; sigma = log 
    ## Formula: nr_youth ~ 1 + gender + (1 | gender:country) 
    ##          sigma ~ 0 + (1 | gender:country)
    ##    Data: generation_data (Number of observations: 762) 
    ## Samples: 4 chains, each with iter = 10000; warmup = 5000; thin = 1;
    ##          total post-warmup samples = 20000
    ## 
    ## Group-Level Effects: 
    ## ~gender:country (Number of levels: 70) 
    ##                     Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
    ## sd(Intercept)           1.69      0.18     1.36     2.08 1.00     5033     9292
    ## sd(sigma_Intercept)     0.92      0.09     0.77     1.11 1.00     2186     4613
    ## 
    ## Population-Level Effects: 
    ##             Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
    ## Intercept      15.65      0.30    15.06    16.24 1.00     3506     5709
    ## genderWomen    -3.24      0.45    -4.10    -2.36 1.00     3922     6289
    ## 
    ## Samples were drawn using sampling(NUTS). For each parameter, Bulk_ESS
    ## and Tail_ESS are effective sample size measures, and Rhat is the potential
    ## scale reduction factor on split chains (at convergence, Rhat = 1).

### `nr_youth_lic_players_mod`

Used to model the moderation effect of number of licensed players on the
average number of youth national team players and within-country
variation of number of players between the different generations (for
each gender).

    ##  Family: gaussian 
    ##   Links: mu = identity; sigma = log 
    ## Formula: nr_youth ~ gender + (1 | gender:country) + gender:players_lic_log_std 
    ##          sigma ~ 0 + (1 | gender:country)
    ##    Data: generation_data (Number of observations: 762) 
    ## Samples: 4 chains, each with iter = 10000; warmup = 5000; thin = 1;
    ##          total post-warmup samples = 20000
    ## 
    ## Group-Level Effects: 
    ## ~gender:country (Number of levels: 70) 
    ##                     Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
    ## sd(Intercept)           1.29      0.16     1.00     1.63 1.00     6673     9956
    ## sd(sigma_Intercept)     0.92      0.08     0.77     1.10 1.00     2632     5318
    ## 
    ## Population-Level Effects: 
    ##                                 Estimate Est.Error l-95% CI u-95% CI Rhat
    ## Intercept                          14.94      0.29    14.36    15.52 1.00
    ## genderWomen                        -2.86      0.40    -3.65    -2.06 1.00
    ## genderMen:players_lic_log_std       1.44      0.34     0.75     2.13 1.00
    ## genderWomen:players_lic_log_std     1.65      0.38     0.91     2.39 1.00
    ##                                 Bulk_ESS Tail_ESS
    ## Intercept                           4965     8736
    ## genderWomen                         5161     8974
    ## genderMen:players_lic_log_std       5885     9406
    ## genderWomen:players_lic_log_std     6654     9943
    ## 
    ## Samples were drawn using sampling(NUTS). For each parameter, Bulk_ESS
    ## and Tail_ESS are effective sample size measures, and Rhat is the potential
    ## scale reduction factor on split chains (at convergence, Rhat = 1).

### `nr_youth_ranking_mod`

Used to model the effect of countries’ average number of youth national
team players per generation and within-country variation of number of
players between the different generations on the youth and senior
ranking points of the country (for each gender).

The model uses a multivariate formula to make subsequent analysis
easier. No correlation between the residuals are modeled and it is
therefore equal to using two univariate models.

    ##  Family: MV(beta, beta) 
    ##   Links: mu = logit; phi = log
    ##          mu = logit; phi = log 
    ## Formula: ranking_points_senior_std ~ 1 + gender + gender:nr_youth_m_std + gender:nr_youth_cv_std 
    ##          phi ~ 0 + gender
    ##          ranking_points_youth_std ~ 1 + gender + gender:nr_youth_m_std + gender:nr_youth_cv_std 
    ##          phi ~ 0 + gender
    ##    Data: country_data (Number of observations: 70) 
    ## Samples: 4 chains, each with iter = 10000; warmup = 5000; thin = 1;
    ##          total post-warmup samples = 20000
    ## 
    ## Population-Level Effects: 
    ##                                                    Estimate Est.Error l-95% CI
    ## rankingpointsseniorstd_Intercept                      -0.98      0.17    -1.31
    ## rankingpointsyouthstd_Intercept                       -2.55      0.28    -3.09
    ## rankingpointsseniorstd_genderWomen                     0.28      0.26    -0.22
    ## rankingpointsseniorstd_genderMen:nr_youth_m_std        0.58      0.15     0.28
    ## rankingpointsseniorstd_genderWomen:nr_youth_m_std      0.27      0.20    -0.13
    ## rankingpointsseniorstd_genderMen:nr_youth_cv_std       0.06      0.17    -0.28
    ## rankingpointsseniorstd_genderWomen:nr_youth_cv_std    -0.04      0.13    -0.30
    ## phi_rankingpointsseniorstd_genderMen                   2.06      0.23     1.59
    ## phi_rankingpointsseniorstd_genderWomen                 1.90      0.25     1.38
    ## rankingpointsyouthstd_genderWomen                      1.08      0.36     0.36
    ## rankingpointsyouthstd_genderMen:nr_youth_m_std         0.61      0.21     0.20
    ## rankingpointsyouthstd_genderWomen:nr_youth_m_std       0.64      0.27     0.12
    ## rankingpointsyouthstd_genderMen:nr_youth_cv_std       -0.05      0.21    -0.48
    ## rankingpointsyouthstd_genderWomen:nr_youth_cv_std     -0.17      0.15    -0.46
    ## phi_rankingpointsyouthstd_genderMen                    1.77      0.26     1.22
    ## phi_rankingpointsyouthstd_genderWomen                  1.83      0.28     1.25
    ##                                                    u-95% CI Rhat Bulk_ESS
    ## rankingpointsseniorstd_Intercept                      -0.66 1.00    25026
    ## rankingpointsyouthstd_Intercept                       -2.00 1.00    19989
    ## rankingpointsseniorstd_genderWomen                     0.80 1.00    22784
    ## rankingpointsseniorstd_genderMen:nr_youth_m_std        0.88 1.00    24300
    ## rankingpointsseniorstd_genderWomen:nr_youth_m_std      0.67 1.00    25168
    ## rankingpointsseniorstd_genderMen:nr_youth_cv_std       0.38 1.00    26345
    ## rankingpointsseniorstd_genderWomen:nr_youth_cv_std     0.22 1.00    26137
    ## phi_rankingpointsseniorstd_genderMen                   2.48 1.00    25287
    ## phi_rankingpointsseniorstd_genderWomen                 2.36 1.00    26070
    ## rankingpointsyouthstd_genderWomen                      1.78 1.00    19881
    ## rankingpointsyouthstd_genderMen:nr_youth_m_std         1.01 1.00    24249
    ## rankingpointsyouthstd_genderWomen:nr_youth_m_std       1.16 1.00    23512
    ## rankingpointsyouthstd_genderMen:nr_youth_cv_std        0.35 1.00    26777
    ## rankingpointsyouthstd_genderWomen:nr_youth_cv_std      0.13 1.00    27350
    ## phi_rankingpointsyouthstd_genderMen                    2.25 1.00    20778
    ## phi_rankingpointsyouthstd_genderWomen                  2.34 1.00    23475
    ##                                                    Tail_ESS
    ## rankingpointsseniorstd_Intercept                      15356
    ## rankingpointsyouthstd_Intercept                       13689
    ## rankingpointsseniorstd_genderWomen                    15376
    ## rankingpointsseniorstd_genderMen:nr_youth_m_std       15453
    ## rankingpointsseniorstd_genderWomen:nr_youth_m_std     15348
    ## rankingpointsseniorstd_genderMen:nr_youth_cv_std      13951
    ## rankingpointsseniorstd_genderWomen:nr_youth_cv_std    13995
    ## phi_rankingpointsseniorstd_genderMen                  14385
    ## phi_rankingpointsseniorstd_genderWomen                13860
    ## rankingpointsyouthstd_genderWomen                     14881
    ## rankingpointsyouthstd_genderMen:nr_youth_m_std        15745
    ## rankingpointsyouthstd_genderWomen:nr_youth_m_std      15583
    ## rankingpointsyouthstd_genderMen:nr_youth_cv_std       14723
    ## rankingpointsyouthstd_genderWomen:nr_youth_cv_std     15680
    ## phi_rankingpointsyouthstd_genderMen                   14177
    ## phi_rankingpointsyouthstd_genderWomen                 15014
    ## 
    ## Samples were drawn using sampling(NUTS). For each parameter, Bulk_ESS
    ## and Tail_ESS are effective sample size measures, and Rhat is the potential
    ## scale reduction factor on split chains (at convergence, Rhat = 1).

### `nr_youth_ranking_lic_players_mod`

Used to model the moderating effect of number of licensed players on the
effect of countries’ average number of youth national team players per
generation and within-country variation of number of players between the
different generations on the youth and senior ranking points of the
country (for each gender).

The model uses a multivariate formula to make subsequent analysis
easier. No correlation between the residuals are modeled and it is
therefore equal to using two univariate models.

    ##  Family: MV(beta, beta) 
    ##   Links: mu = logit; phi = log
    ##          mu = logit; phi = log 
    ## Formula: ranking_points_senior_std ~ 1 + gender + gender:nr_youth_m_std + gender:nr_youth_cv_std + gender:players_lic_log_std 
    ##          phi ~ 0 + gender
    ##          ranking_points_youth_std ~ 1 + gender + gender:nr_youth_m_std + gender:nr_youth_cv_std + gender:players_lic_log_std 
    ##          phi ~ 0 + gender
    ##    Data: country_data (Number of observations: 70) 
    ## Samples: 4 chains, each with iter = 10000; warmup = 5000; thin = 1;
    ##          total post-warmup samples = 20000
    ## 
    ## Population-Level Effects: 
    ##                                                        Estimate Est.Error
    ## rankingpointsseniorstd_Intercept                          -1.09      0.17
    ## rankingpointsyouthstd_Intercept                           -2.67      0.29
    ## rankingpointsseniorstd_genderWomen                        -0.06      0.32
    ## rankingpointsseniorstd_genderMen:nr_youth_m_std            0.40      0.18
    ## rankingpointsseniorstd_genderWomen:nr_youth_m_std         -0.12      0.25
    ## rankingpointsseniorstd_genderMen:nr_youth_cv_std           0.04      0.16
    ## rankingpointsseniorstd_genderWomen:nr_youth_cv_std         0.02      0.13
    ## rankingpointsseniorstd_genderMen:players_lic_log_std       0.38      0.20
    ## rankingpointsseniorstd_genderWomen:players_lic_log_std     0.63      0.26
    ## phi_rankingpointsseniorstd_genderMen                       2.14      0.23
    ## phi_rankingpointsseniorstd_genderWomen                     2.07      0.25
    ## rankingpointsyouthstd_genderWomen                          0.66      0.43
    ## rankingpointsyouthstd_genderMen:nr_youth_m_std             0.46      0.25
    ## rankingpointsyouthstd_genderWomen:nr_youth_m_std           0.27      0.31
    ## rankingpointsyouthstd_genderMen:nr_youth_cv_std           -0.06      0.21
    ## rankingpointsyouthstd_genderWomen:nr_youth_cv_std         -0.13      0.15
    ## rankingpointsyouthstd_genderMen:players_lic_log_std        0.34      0.31
    ## rankingpointsyouthstd_genderWomen:players_lic_log_std      0.77      0.29
    ## phi_rankingpointsyouthstd_genderMen                        1.82      0.27
    ## phi_rankingpointsyouthstd_genderWomen                      2.09      0.29
    ##                                                        l-95% CI u-95% CI Rhat
    ## rankingpointsseniorstd_Intercept                          -1.42    -0.76 1.00
    ## rankingpointsyouthstd_Intercept                           -3.25    -2.09 1.00
    ## rankingpointsseniorstd_genderWomen                        -0.69     0.56 1.00
    ## rankingpointsseniorstd_genderMen:nr_youth_m_std            0.05     0.75 1.00
    ## rankingpointsseniorstd_genderWomen:nr_youth_m_std         -0.61     0.37 1.00
    ## rankingpointsseniorstd_genderMen:nr_youth_cv_std          -0.28     0.34 1.00
    ## rankingpointsseniorstd_genderWomen:nr_youth_cv_std        -0.23     0.27 1.00
    ## rankingpointsseniorstd_genderMen:players_lic_log_std      -0.01     0.77 1.00
    ## rankingpointsseniorstd_genderWomen:players_lic_log_std     0.12     1.13 1.00
    ## phi_rankingpointsseniorstd_genderMen                       1.67     2.57 1.00
    ## phi_rankingpointsseniorstd_genderWomen                     1.55     2.54 1.00
    ## rankingpointsyouthstd_genderWomen                         -0.19     1.50 1.00
    ## rankingpointsyouthstd_genderMen:nr_youth_m_std            -0.03     0.95 1.00
    ## rankingpointsyouthstd_genderWomen:nr_youth_m_std          -0.36     0.88 1.00
    ## rankingpointsyouthstd_genderMen:nr_youth_cv_std           -0.49     0.34 1.00
    ## rankingpointsyouthstd_genderWomen:nr_youth_cv_std         -0.42     0.17 1.00
    ## rankingpointsyouthstd_genderMen:players_lic_log_std       -0.28     0.92 1.00
    ## rankingpointsyouthstd_genderWomen:players_lic_log_std      0.20     1.33 1.00
    ## phi_rankingpointsyouthstd_genderMen                        1.26     2.31 1.00
    ## phi_rankingpointsyouthstd_genderWomen                      1.50     2.64 1.00
    ##                                                        Bulk_ESS Tail_ESS
    ## rankingpointsseniorstd_Intercept                          30744    15580
    ## rankingpointsyouthstd_Intercept                           23562    16235
    ## rankingpointsseniorstd_genderWomen                        18348    15651
    ## rankingpointsseniorstd_genderMen:nr_youth_m_std           25749    15390
    ## rankingpointsseniorstd_genderWomen:nr_youth_m_std         18916    15777
    ## rankingpointsseniorstd_genderMen:nr_youth_cv_std          30011    14444
    ## rankingpointsseniorstd_genderWomen:nr_youth_cv_std        32746    15197
    ## rankingpointsseniorstd_genderMen:players_lic_log_std      26335    16000
    ## rankingpointsseniorstd_genderWomen:players_lic_log_std    19025    16156
    ## phi_rankingpointsseniorstd_genderMen                      30824    14421
    ## phi_rankingpointsseniorstd_genderWomen                    30111    14662
    ## rankingpointsyouthstd_genderWomen                         18604    15537
    ## rankingpointsyouthstd_genderMen:nr_youth_m_std            26335    16032
    ## rankingpointsyouthstd_genderWomen:nr_youth_m_std          21977    16421
    ## rankingpointsyouthstd_genderMen:nr_youth_cv_std           35103    14510
    ## rankingpointsyouthstd_genderWomen:nr_youth_cv_std         31050    14456
    ## rankingpointsyouthstd_genderMen:players_lic_log_std       26334    15202
    ## rankingpointsyouthstd_genderWomen:players_lic_log_std     20788    15585
    ## phi_rankingpointsyouthstd_genderMen                       23582    14423
    ## phi_rankingpointsyouthstd_genderWomen                     25649    15562
    ## 
    ## Samples were drawn using sampling(NUTS). For each parameter, Bulk_ESS
    ## and Tail_ESS are effective sample size measures, and Rhat is the potential
    ## scale reduction factor on split chains (at convergence, Rhat = 1).

### `nr_youth_senior_country_mod`

Used to model the effect of countries’ average number of youth national
team players per generation and within-country variation of number of
players between the different generations on the average number of
players that reach the senior national team in a generation (for each
gender).

    ##  Family: gaussian 
    ##   Links: mu = identity; sigma = identity 
    ## Formula: nr_senior_m ~ 1 + gender + gender:nr_youth_m_to_senior_std + gender:nr_youth_cv_to_senior_std 
    ##    Data: country_data (Number of observations: 70) 
    ## Samples: 4 chains, each with iter = 10000; warmup = 5000; thin = 1;
    ##          total post-warmup samples = 20000
    ## 
    ## Population-Level Effects: 
    ##                                       Estimate Est.Error l-95% CI u-95% CI Rhat
    ## Intercept                                 1.89      0.16     1.57     2.21 1.00
    ## genderWomen                              -0.03      0.26    -0.53     0.48 1.00
    ## genderMen:nr_youth_m_to_senior_std        0.13      0.14    -0.14     0.40 1.00
    ## genderWomen:nr_youth_m_to_senior_std     -0.20      0.21    -0.62     0.22 1.00
    ## genderMen:nr_youth_cv_to_senior_std      -0.14      0.16    -0.46     0.19 1.00
    ## genderWomen:nr_youth_cv_to_senior_std     0.07      0.13    -0.19     0.33 1.00
    ##                                       Bulk_ESS Tail_ESS
    ## Intercept                                20901    16481
    ## genderWomen                              16547    15628
    ## genderMen:nr_youth_m_to_senior_std       22800    15347
    ## genderWomen:nr_youth_m_to_senior_std     20546    15986
    ## genderMen:nr_youth_cv_to_senior_std      22996    15395
    ## genderWomen:nr_youth_cv_to_senior_std    26156    15702
    ## 
    ## Family Specific Parameters: 
    ##       Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
    ## sigma     0.74      0.07     0.62     0.88 1.00    23311    14143
    ## 
    ## Samples were drawn using sampling(NUTS). For each parameter, Bulk_ESS
    ## and Tail_ESS are effective sample size measures, and Rhat is the potential
    ## scale reduction factor on split chains (at convergence, Rhat = 1).

### `nr_youth_senior_lic_players_country_mod`

Used to model moderating effect of number of licensed players on the
effect of countries’ average number of youth national team players per
generation and within-country variation of number of players between the
different generations on the average number of players that reach the
senior national team in a generation (for each gender).

    ##  Family: gaussian 
    ##   Links: mu = identity; sigma = identity 
    ## Formula: nr_senior_m ~ gender + gender:nr_youth_m_to_senior_std + gender:nr_youth_cv_to_senior_std + gender:players_lic_log_std + gender:ranking_points_senior_std 
    ##    Data: country_data (Number of observations: 70) 
    ## Samples: 4 chains, each with iter = 10000; warmup = 5000; thin = 1;
    ##          total post-warmup samples = 20000
    ## 
    ## Population-Level Effects: 
    ##                                       Estimate Est.Error l-95% CI u-95% CI Rhat
    ## Intercept                                 1.86      0.26     1.35     2.37 1.00
    ## genderWomen                               0.21      0.42    -0.62     1.04 1.00
    ## genderMen:nr_youth_m_to_senior_std        0.09      0.18    -0.25     0.44 1.00
    ## genderWomen:nr_youth_m_to_senior_std     -0.17      0.28    -0.71     0.38 1.00
    ## genderMen:nr_youth_cv_to_senior_std      -0.13      0.17    -0.46     0.21 1.00
    ## genderWomen:nr_youth_cv_to_senior_std     0.07      0.14    -0.19     0.34 1.00
    ## genderMen:players_lic_log_std             0.06      0.22    -0.36     0.49 1.00
    ## genderWomen:players_lic_log_std           0.03      0.28    -0.52     0.57 1.00
    ## genderMen:ranking_points_senior_std       0.06      0.77    -1.46     1.57 1.00
    ## genderWomen:ranking_points_senior_std    -0.70      0.83    -2.33     0.96 1.00
    ##                                       Bulk_ESS Tail_ESS
    ## Intercept                                22966    15857
    ## genderWomen                              16850    14889
    ## genderMen:nr_youth_m_to_senior_std       24458    15959
    ## genderWomen:nr_youth_m_to_senior_std     18483    15118
    ## genderMen:nr_youth_cv_to_senior_std      29041    14547
    ## genderWomen:nr_youth_cv_to_senior_std    27885    13067
    ## genderMen:players_lic_log_std            24570    15277
    ## genderWomen:players_lic_log_std          18375    15337
    ## genderMen:ranking_points_senior_std      20366    15582
    ## genderWomen:ranking_points_senior_std    21517    15125
    ## 
    ## Family Specific Parameters: 
    ##       Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
    ## sigma     0.75      0.07     0.63     0.91 1.00    21771    14716
    ## 
    ## Samples were drawn using sampling(NUTS). For each parameter, Bulk_ESS
    ## and Tail_ESS are effective sample size measures, and Rhat is the potential
    ## scale reduction factor on split chains (at convergence, Rhat = 1).

### `nr_youth_senior_generation_mod`

Used to model the within-country effect of number of youth national team
players in a generation on the number of players tin the generation that
reach the senior national team (for each gender).

    ##  Family: poisson 
    ##   Links: mu = log 
    ## Formula: nr_senior ~ 1 + gender + gender:nr_youth_std + (1 + nr_youth_std || gender:country) 
    ##    Data: generation_data (Number of observations: 501) 
    ## Samples: 4 chains, each with iter = 10000; warmup = 5000; thin = 1;
    ##          total post-warmup samples = 20000
    ## 
    ## Group-Level Effects: 
    ## ~gender:country (Number of levels: 70) 
    ##                  Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
    ## sd(Intercept)        0.17      0.07     0.03     0.29 1.00     3855     4694
    ## sd(nr_youth_std)     0.08      0.05     0.00     0.20 1.00     4849     8949
    ## 
    ## Population-Level Effects: 
    ##                          Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS
    ## Intercept                    0.64      0.06     0.51     0.76 1.00    14652
    ## genderWomen                  0.10      0.09    -0.07     0.28 1.00    14282
    ## genderMen:nr_youth_std       0.12      0.05     0.01     0.22 1.00    15958
    ## genderWomen:nr_youth_std     0.12      0.06    -0.00     0.24 1.00    20146
    ##                          Tail_ESS
    ## Intercept                   14351
    ## genderWomen                 13559
    ## genderMen:nr_youth_std      11436
    ## genderWomen:nr_youth_std    15451
    ## 
    ## Samples were drawn using sampling(NUTS). For each parameter, Bulk_ESS
    ## and Tail_ESS are effective sample size measures, and Rhat is the potential
    ## scale reduction factor on split chains (at convergence, Rhat = 1).

### `nr_youth_senior_lic_players_generation_mod`

Used to model moderating effect of number of licensed players on the
effect of youth national team players in a generation on the number of
players tin the generation that reach the senior national team (for each
gender).

    ##  Family: poisson 
    ##   Links: mu = log 
    ## Formula: nr_senior ~ gender + (1 + nr_youth_std || gender:country) + gender:nr_youth_std + gender:players_lic_log_std + gender:ranking_points_senior_std 
    ##    Data: generation_data (Number of observations: 501) 
    ## Samples: 4 chains, each with iter = 10000; warmup = 5000; thin = 1;
    ##          total post-warmup samples = 20000
    ## 
    ## Group-Level Effects: 
    ## ~gender:country (Number of levels: 70) 
    ##                  Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
    ## sd(Intercept)        0.17      0.07     0.03     0.29 1.00     4051     4968
    ## sd(nr_youth_std)     0.08      0.05     0.00     0.20 1.00     5392     8950
    ## 
    ## Population-Level Effects: 
    ##                                       Estimate Est.Error l-95% CI u-95% CI Rhat
    ## Intercept                                 0.73      0.11     0.50     0.95 1.00
    ## genderWomen                               0.13      0.16    -0.19     0.46 1.00
    ## genderMen:nr_youth_std                    0.13      0.06     0.02     0.25 1.00
    ## genderWomen:nr_youth_std                  0.15      0.06     0.02     0.27 1.00
    ## genderMen:players_lic_log_std             0.02      0.09    -0.16     0.20 1.00
    ## genderWomen:players_lic_log_std          -0.11      0.10    -0.30     0.08 1.00
    ## genderMen:ranking_points_senior_std      -0.32      0.34    -0.97     0.35 1.00
    ## genderWomen:ranking_points_senior_std    -0.30      0.38    -1.06     0.44 1.00
    ##                                       Bulk_ESS Tail_ESS
    ## Intercept                                15874    15346
    ## genderWomen                              15619    14221
    ## genderMen:nr_youth_std                   23306    14922
    ## genderWomen:nr_youth_std                 23461    15523
    ## genderMen:players_lic_log_std            18346    14589
    ## genderWomen:players_lic_log_std          17821    14770
    ## genderMen:ranking_points_senior_std      15708    13687
    ## genderWomen:ranking_points_senior_std    17044    15541
    ## 
    ## Samples were drawn using sampling(NUTS). For each parameter, Bulk_ESS
    ## and Tail_ESS are effective sample size measures, and Rhat is the potential
    ## scale reduction factor on split chains (at convergence, Rhat = 1).
