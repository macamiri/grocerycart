#' Unnest a table from a nested tibble
#'
#' The name of the column where the table name is stored must be called
#' 'origin', while the name of the column where the table data is stored
#' must be called 'data'.
#'
#' @param nested_table The nested tibble containing the table to unnest.
#' @param table_name A character string indicating the name of the table to unnest.
#'
#' @return A tibble
#' @export
#'
#' @examples
#' # Create 2 tibbles
#' fruit <- tibble::tibble(title = c("Apple", "Banana"), price = c(1.12, .98))
#' store <- tibble::tibble(location = c("Milan", "London"), rating = c(4, 5))
#' table_list <- list(fruit = fruit, store = store)
#'
#' # Create nested tibble
#' nst_tbl <- tibble::enframe(table_list, name = "origin", value = "data")
#'
#' # Unnest the 'store' tibble
#' unnest_table(nested_table = nst_tbl, table_name = "store")
unnest_table <- function(nested_table, table_name) {
  nested_table$data[nested_table$origin == table_name] %>%
    purrr::pluck(1)
}
