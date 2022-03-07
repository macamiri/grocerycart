#' Play 'Work Complete' sound (from \emph{beepr} package) when the 2 expressions are equal
#'
#' @param expr1 First expression
#' @param expr2 Second expression to compare to the first expression
#'
#' @return Audio sound & a character string
#' @export
#'
#' @examples
#' # No audio
#' sound_work_complete(1, 4)
#' # Audio
#' sound_work_complete(1, 1)
#'
#' expr <- 1:10
#' sound_work_complete(1, length(expr))
#' sound_work_complete(10, length(expr))
sound_work_complete <- function(expr1, expr2) {

  if(expr1 == expr2) {
    beepr::beep(sound = "complete",
                expr = cat(crayon::bgWhite$green$bold("Work Complete!\n")))
  }
}
