#' Extract ingredients from data collected with \emph{oc_collect_product_extra}
#'
#' @param column The column that contains the ingredients, if available.
#'
#' @return A character string.
#'
#' @export
extract_ingredients <- function(column) {
  column %>%
    as.character() %>%
    stringr::str_split("(?<=[a-z]|\\u2122)[A-Z][a-z]+", n = 2) %>%
    .[[1]] %>%
    .[1]
}
