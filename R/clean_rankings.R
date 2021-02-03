#' Clean ranking data
#'
#' Prepare country ranking data by matching with countries that match inclusion
#' criteria, and by standardizing ranking points to be used in modeling. The
#' ranking points are standardized to 0-1 range for modeling in beta-regression.
#' Further, youth ranking points are transformed by the formula (ranking points
#' * (n - 1) + .5)/n., to avoid 0's, as beta-regression cannot include them.
#'
#' @param rankings 
#' @param senior_max_rank
#' @param youth_max_rank
#' @param incl_countries
#'
#' @return
clean_rankings <- function(rankings, 
                           senior_max_rank, 
                           youth_max_rank, 
                           incl_countries) {
  
  # Merge Great-britain with England
  # (senior ranking from GB, youth ranking from England)
  ranking_renamed <- rankings %>% 
    dplyr::mutate(
      country = dplyr::if_else(country == "England", "Great Britain", country)
    )
  
  # Separate senior and youth ranking into different columns
  ranking_wide <- ranking_renamed %>% 
    tidyr::pivot_wider(
      names_from = category,
      values_from = c(ranking, ranking_points),
      values_fill = list(ranking_points = 0),
      values_fn = list(ranking = min, ranking_points = max)
    )
  
  # Match with list of countries to include
  ## Filter out only countries that should be included
  countries_included <- incl_countries %>% 
    filter(include == TRUE) %>% 
    distinct(gender, country)
  
  ## Join rankings into list of included countries
  rankings_included <- countries_included %>% 
    dplyr::left_join(ranking_wide, by = c("gender", "country"))
  
  # Prepare rnaking points for modeling
  # (standardize to 0-1 and convert to avoid 0's)
  rankings_std <- rankings_included %>% 
    mutate(
      # Divide by theoretical max points to create 0-1
      ranking_points_senior_std = ranking_points_senior / senior_max_rank,
      ranking_points_youth_std = ranking_points_youth / youth_max_rank,
      # Transformation to remove 0's
      ranking_points_youth_std = (ranking_points_youth_std * (n() - 1) + .5)/n()
    )
  
  # Return standardized rankings
  rankings_std
}