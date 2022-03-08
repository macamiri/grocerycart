#' Get the title of the current page
#'
#' @param remDr Remote client driver
#'
#' @return A character string
#' @export
#'
#' @examples
#' remDr <- RSelenium::rsDriver(port = 4446L, browser = "firefox", verbose = FALSE)$client
#' remDr$navigate("https://duckduckgo.com")
#' get_page_title(remDr = remDr)
#'
#' # Close the server
#' remDr$close()
#' gc(remDr)
#' rm(remDr)
get_page_title <- function(remDr) {
  cat(crayon::blue(remDr$getTitle(), "\n"))
}

#' @rdname get_page_title
#' @export
current_url <- function(remDr) {
  url <- remDr$getCurrentUrl() %>%
    unlist()

  cat(crayon::bgCyan("Currently on:", url, "\n"))
}