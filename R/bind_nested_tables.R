#' Bind tables in a nested tibble
#'
#' The tables to bind must have a common naming pattern and disinguished by
#' either a prefix (e.g., milan_store and london_store)
#' or a suffix (e.g., revenue_2020 and revenue_2021).
#'
#' The name of the column where the table name is stored must be called
#' 'origin', while the name of the column where the table data is stored
#' must be called 'data'.
#'
#' @param nested_table A nested tibble.
#' @param pattern A naming pattern for the tables to bind.
#' @param prefix A vector of prefixes that distinguish the tables to bind.
#'
#' @return A tibble.
#'
#' @export
#'
#' @seealso
#' \code{\link[purrr]{map_dfr}}
#'
#' @examples
#' # Create 3 tibbles
#' fruit <- tibble::tibble(title = c("Apple", "Banana"), price = c(1.12, .98))
#' revenue2020 <- tibble::tibble(store = c("milan", "london"), revenue = c(100, 200))
#' revenue2021 <- tibble::tibble(store = c("milan", "london"), revenue = c(123, 222))
#' table_list <- list(fruit = fruit, revenue2020 = revenue2020, revenue2021 = revenue2021)
#'
#' # Create nested tibble
#' nst_tbl <- tibble::enframe(table_list, name = "origin", value = "data")
#'
#' # Bind the revenue tables
#' purrr::map_dfr(c(2020, 2021),
#' ~ bind_nested_tables_suf(nst_tbl, "revenue", suffix = .x))
bind_nested_tables_pre <- function(nested_table, pattern, prefix) {
  nested_table %>%
    grocerycart::unnest_table(paste0(prefix, pattern))
}

#' @rdname bind_nested_tables_pre
#'
#' @param suffix A vector suffixes that distinguish the tables to bind.
#'
#' @export
bind_nested_tables_suf <- function(nested_table, pattern, suffix) {
  nested_table %>%
    grocerycart::unnest_table(paste0(pattern, suffix))
}
