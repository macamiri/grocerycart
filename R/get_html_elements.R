#' Find html element(s) using a remote client driver
#'
#' @param remDr Remote client driver
#' @param ... Additional arguments passed on to \emph{rvest::html_elements}. Usually, a \emph{css} or \emph{xpath}.
#' @param type Choose 'text', 'attribute', 'attributes' or 'table' as they relate to the \emph{rvest:html_*} functions.
#' @param attribute_selector Name of attribute to find, using \emph{rvest::html_attr}
#'
#' @return html element(s)
#' @export
#'
#' @examples
#' remDr <- RSelenium::rsDriver(port = 4446L, browser = "firefox", verbose = FALSE)$client
#' remDr$navigate("https://duckduckgo.com")
#' get_html_element(remDr = remDr, css = ".content-info__title", type = "text")
#'
#' # Close the server
#' remDr$close()
#' gc(remDr)
#' rm(remDr)
get_html_element <- function(remDr, ..., type = "text", attribute_selector) {
  page <- remDr$getPageSource() %>%
    .[[1]] %>%
    rvest::read_html() %>%
    rvest::html_element(...)

  if(type == "text") {
    page %>%
      rvest::html_text()
  } else if(type == "attribute") {
    page %>%
      rvest::html_attr(attribute_selector)
  } else if(type == "attributes") {
    page %>%
      rvest::html_attrs()
  } else if(type == "table") {
    page %>%
      rvest::html_table()
  } else {
    cat(crayon::red("Type must be: text, attribute, attributes or table"))
  }
}


#' @rdname get_html_element
#' @export
get_html_elements <- function(remDr, ..., type = "text", attribute_selector) {
  page <- remDr$getPageSource() %>%
    .[[1]] %>%
    rvest::read_html() %>%
    rvest::html_elements(...)

  if(type == "text") {
    page %>%
      rvest::html_text()
  } else if(type == "attribute") {
    page %>%
      rvest::html_attr(attribute_selector)
  } else if(type == "attributes") {
    page %>%
      rvest::html_attrs()
  } else if(type == "table") {
    page %>%
      rvest::html_table()
  } else {
    cat(crayon::red("Type must be: text, attribute, attributes or table"))
  }
}
