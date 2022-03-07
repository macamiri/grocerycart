#' Suspend execution of functions for a random time interval
#'
#' @param period Lower and upper limits of time interval (seconds) to suspend execution for. Uses \emph{stats::runif} to pick time.
#' @param crayon_col Uses the \emph{crayon} package to select color of character string
#' @param ... Additional vectors or character strings passed to the end of the returned string
#'
#' @return A character string
#' @export
#'
#' @examples
#' nytnyt(period = c(2, 5), crayon_col = crayon::blue, "An example of a new string\n")
nytnyt <- function(period = c(1, 2), crayon_col = crayon::green, ...){
  tictoc <- stats::runif(1, period[1], period[2])
  cat(crayon_col(paste0(">>> Sleeping for ",
                        round(tictoc, 2),
                        " seconds\n", ...)))
  Sys.sleep(tictoc)
}
