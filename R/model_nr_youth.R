# nr_youth_draws <- function(model) {
#   
#   model %>% 
#     tidybayes::spread_draws(
#       b_genderMen,
#       b_genderWomen,
#       sigma,
#       `r_gender:country`[country]
#     ) %>% 
#     
#     dplyr::summarise(prob_pos = mean(r_country > 0)) %>% 
#     dplyr::mutate(
#       country = stringr::str_replace_all(country, "\\.", " ")
#     )
# }
# # 
# library(tidybayes)
# library(dplyr)
# # 
# nr_youth_mod3 %>%
#   tidybayes::spread_draws(
#     b_genderMen, b_genderWomen,
#     `r_gender:country`[country, int], `r_gender:country__sigma`[country, int],
#     b_sigma_genderMen, b_sigma_genderWomen,
#     `sd_gender:country__Intercept`, `sd_gender:country__sigma_Intercept`
#   ) %>%
#   tidyr::separate(col = country, into = c("gender", "country"), sep = "_") %>%
#   dplyr::mutate(
#     value = dplyr::if_else(gender == "Men", b_genderMen + `r_gender:country`, b_genderWomen + `r_gender:country`),
#     sd = dplyr::if_else(
#       gender == "Men", 
#       b_sigma_genderMen + `r_gender:country__sigma`, 
#       b_sigma_genderWomen + `r_gender:country__sigma`,
#     ),
#     cv = 100 * sd / value
#   ) %>%
#   group_by(gender) %>%
#   summarise(across(c(value, sd, cv), mean))
# #
# #
# # get_variables()
# #
# generation_data %>%
#   tidyr::expand(tidyr::nesting(gender, country)) %>%
#   tidybayes::add_predicted_draws(nr_youth_mod) %>%
#   group_by(gender) %>%
#   summarize(mean = mean(.prediction))
