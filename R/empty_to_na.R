#' Convert empty and null strings to NA
#'
#' @param x A character string
#'
#' @return NA
#' @export
#'
#' @examples
#' x <- "this is text"
#' empty_to_na(x)
#'
#' y <- ""
#' empty_to_na(y)
#'
#' z <- NULL
#' empty_to_na(z)
empty_to_na <- function(x) {
  if(x == "" || is.na(x) || is.null(x) || purrr::is_empty(x)) {
    print(NA)
  } else {
    x
  }
}
