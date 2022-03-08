#' Scroll to dynamically load more of the webpage
#'
#' @param remDr Remote client driver
#'
#' @return A character string
#' @export
#'
#' @examples
#' \dontrun{
#' # Initiate server
#' remDr <- RSelenium::rsDriver(port = netstat::free_port(),
#' browser = "firefox", verbose = FALSE)$client
#'
#' # Navigate to webpage & scroll down incrementally
#' url <- "https://www.ocado.com/browse"
#' remDr$navigate(url)
#' scroll_down_page_perc(remDr = remDr, perc = seq(0, 1, .25))
#'
#' # Scroll to the top of the webpage
#' scroll_to_top(remDr = remDr)
#'
#' # Close the server
#' remDr$close()
#' gc(remDr)
#' rm(remDr)
#' }
scroll_down_and_load <- function(remDr = remDr){

  last_height <-
    remDr$executeScript("return document.body.scrollHeight") %>%
    unlist()

  new_height <- 0

  while(TRUE){
    remDr$executeScript(
      script = "window.scrollTo(0, document.body.scrollHeight)")

    nytnyt(c(2, 3),
           crayon_col = crayon::green,
           "Scrolling to the bottom of the page\n")

    new_height <-
      remDr$executeScript("return document.body.scrollHeight") %>%
      unlist()

    print(list(old = last_height, new = new_height))

    if(new_height == last_height){
      break
    }

    last_height <- new_height
  }
  grocerycart::nytnyt(period = c(2, 5))
  return(last_height)
}

#' @rdname scroll_down_and_load
#'
#' @param remDr Remote client driver
#'
#' @export
scroll_to_top <- function(remDr = remDr) {
  remDr$executeScript("window.scrollTo(0, 0);", args = list(1))
}

#' @rdname scroll_down_and_load
#'
#' @param remDr Remote client driver
#' @param perc Incrementally scroll down the page
#'
#' @export
scroll_down_page_perc <- function(remDr = remDr, perc = seq(0, 1, .005)) {

  grocerycart::scroll_to_top(remDr)

  last_height <-
    remDr$executeScript("return document.body.scrollHeight") %>%
    unlist()

  purrr::map(perc, function(.x) {
    last_height <- last_height * .x
    remDr$executeScript(
      script = stringr::str_glue("window.scrollTo({{
                                 left: 0,
                                 top: {last_height},
                                 behavior: 'smooth'
                                 }});"))

    grocerycart::nytnyt(c(4, 6), crayon_col = crayon::yellow, "Scrolled down ",
                        .x * 100, "%\n")
  }
  )
  cat(crayon::green("Reached bottom of page \n"))
}

#' @rdname scroll_down_and_load
#'
#' @param remDr Remote client driver
#' @param perc Incrementally scroll up the page
#'
#' @export
scroll_up_page_perc <- function(remDr = remDr, perc = seq(0, 1, .0025)) {

  grocerycart::scroll_down_and_load(remDr)

  last_height <-
    remDr$executeScript("return document.body.scrollHeight") %>%
    unlist()

  purrr::map(rev(perc), function(.x) {
    last_height <- last_height * .x
    remDr$executeScript(
      script = stringr::str_glue("window.scrollTo({{
                                 left: 0,
                                 top: {last_height},
                                 behavior: 'smooth'
                                 }});"))

    grocerycart::nytnyt(c(2, 3), crayon_col = crayon::yellow, "Scrolled up ",
                        100 - (.x * 100), "%\n")
  }
  )
  cat(crayon::green("Reached top of page \n"))
}

#' @rdname scroll_down_and_load
#' @export
click_show_more <- function(remDr = remDr) {
  i <- 0
  repeat({
    output_click <- tryCatch(
      expr = {
        remDr$findElement(using = "css",
                          value = "button.show-more")$clickElement()
        i <- i + 1
        cat(crayon::bgCyan("Clicked ", i, " times\n"))
        grocerycart::nytnyt(c(2, 5))
        paste("clicked")
      },
      error = function(e) {
        cat(crayon::bgYellow("No show more button. Time to scroll down and up the page to load all products.\n"))
      }
    )
    if(purrr::is_null(output_click)) {break}
  })
}
