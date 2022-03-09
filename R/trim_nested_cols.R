#' Removes whitespace from start and end of every column of every table in a nested tibble
#'
#' @param nested_table A nested tibble.
#'
#' @return The nested table passed on to the argument.
#' @export
trim_nested_cols <- function(nested_table) {
  nested_table %>%
    dplyr::mutate(dplyr::across(.cols = tidyr::everything(),
                                ~ stringr::str_trim(.x, side = "both")))
}
