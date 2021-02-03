#' Make data of countries and generations to include
#'
#' Creates a data frame with all gender-country-generation combinations and
#' indicate if they should be included or not, based on if the generation has
#' enough tournaments played, and the country has enough generations.
#'
#' @param country_participations Data frame containing one row for each
#'   participation in a youth championship by a country. Must contain the
#'   columns `gender`, `country`, `category` (U16, U18, U20), and `year`.
#' @param min_nr_champs The minimum number of championships a generation have to
#'   have played to be included.
#' @param min_generations The minimum number of generations that have to have
#'   played for the country to be included.
#'
#' @return A tibble with a row for each gender-country-generation combination,
#'   containing information of the number and which youth championship it has
#'   participated in, if the generation participated in enough  championhips to
#'   be included, if the country has enough generations to be included .
make_inclusion_data <- function(country_participations, 
                                min_nr_champs,
                                min_generations){
  
  # Clean country youth participation data
  # (calculate how many youth championships generation participated in,
  # and if it is enough to be included).
  country_gen_incl <- clean_country_participations(
    country_participations = country_participations, 
    min_nr_champs = min_nr_champs
  )
  
  country_gen_incl %>% 
    dplyr::group_by(gender, country) %>% 
    dplyr::mutate(
      incl_country = sum(incl_gen) >= min_generations,
      include = incl_gen & incl_country
    ) %>% 
    dplyr::ungroup()
}



#' Clean country youth championship participation data
#'
#' @param country_participations 
#' @param min_nr_champs 
#'
#' @return
#' @export
#'
#' @examples
clean_country_participations <- function(country_participations, min_nr_champs) {
  
  # Add column of 1's for each championship participated in (all rows)
  # Recode England to Great Britain
  raw_data <- country_participations %>% 
    dplyr::mutate(
      count = 1,
      country = case_when(
        country == "England" ~ "Great Britain",
        TRUE ~ country
      )
    )
  
  # Expand the data frame to one row per gender, country birth year and age.
  # Create a column marking which category (e.g. U18) each age belong to.
  countries <- raw_data %>% 
    tidyr::expand(gender, country, birth_year = 1988:1999, age = 16:20) %>% 
    mutate(
      year = birth_year + age,
      category = paste0("U", round((age + .1)/2) * 2)
    )
  
  # Add the column containing 1 for each participated championship, 
  # and fill the rest with 0.
  country_generation_count <-  countries %>% 
    dplyr::left_join(
      raw_data,
      by = c("country", "gender", "year", "category")
    ) %>% 
    tidyr::replace_na(list(count = 0))
  
  # Put in wide format, with one row per gender, country and generation,
  # with separate columns for each possible championship
  country_generation_wide <- country_generation_count %>% 
    dplyr::group_by(gender, country, birth_year, category) %>%
    dplyr::mutate(category = paste(category, row_number(), sep = "_")) %>%
    tidyr::pivot_wider(
      id_cols = c(gender, country, birth_year), 
      names_from = category, values_from = count
    )
  
  # Sum up the total number of championships for each gender, country, generation
  country_gender_clean <- country_generation_wide %>% 
    dplyr::rowwise() %>%
    dplyr::mutate(
      nr_champs = sum(c(U16_1, U18_1, U18_2, U20_1, U20_2)),
      incl_gen = nr_champs >= min_nr_champs
    ) %>% 
    dplyr::ungroup()
  
  country_gender_clean
}
