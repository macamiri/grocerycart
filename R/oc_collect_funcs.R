#' Collect ocado data
#'
#' The 5 \code{oc_collect_*} functions scrape the \emph{ocado} website
#' and return the data indicated by each function name.
#'
#' @section Note:
#' In order to play nice with the website, the scraper functions have
#' a built in 'sleep functionality'. This means that the functions will
#' suspend execution (i.e., go to sleep) for a random time interval, usually
#' less than 11 seconds whenever the sleep function, \emph{nytnyt}, is
#' called. See the \emph{vignette} for more information.
#'
#' These functions are verbose, allowing the user to get a sense of progress.
#'
#' @seealso
#' \code{\link{eg_collect_location_links}} for ocado data collection.
#' \code{\link{nytnyt}} for sleep functionality.
#'
#' @param remDr Remote client driver
#' @param url ocado url
#'
#' @return \code{*_categories}: Tibble with category links
#' @export
#'
#' @examples
#' \dontrun{
#' # Initiate server
#' remDr <- RSelenium::rsDriver(port = netstat::free_port(),
#' browser = "firefox", verbose = FALSE)$client
#'
#' # (A) Collect category links
#' oc_category <- oc_collect_categories(remDr = remDr)
#'
#' # (B) Collect product data from 1 category
#' chosen_category_links <- 7
#' oc_product_general <- oc_collect_product_general(
#' oc_category$link[chosen_category_links])
#'
#' # (C) Collect extra product data for 3 products
#' set.seed(132)
#' random_product_links <- sample(1:length(oc_product_general$product_link),
#' 3, replace = FALSE)
#' oc_product_extra <- oc_collect_product_extra(
#' oc_product_general$product_link[random_product_links[1:3]])
#'
#' # (D) Collect product reviews, if available, for the same 3 products
#' oc_product_review <- oc_collect_product_reviews(
#' oc_product_general$product_link[random_product_links[1:3]])
#'
#' # (E) Collect product nutrition table, if available, for the same 3 products
#' oc_nutrition_table <- oc_collect_nutrition_table(
#' oc_product_general$product_link[random_product_links[1:3]])
#'
#' # Close the server
#' remDr$close()
#' gc(remDr)
#' rm(remDr)
#' }
oc_collect_categories <- function(remDr = remDr,
                                  url = "https://www.ocado.com") {
  # Visit website
  remDr$navigate(url)

  # Accept all cookies
  grocerycart::nytnyt(c(5, 10))
  remDr$findElement(using = "xpath",
                    value = "//*[@id='onetrust-accept-btn-handler']")$clickElement()

  # Click on 'Browse Shop' menu
  grocerycart::nytnyt(c(5,10))
  remDr$findElement(using = "link text",
                    value = "Browse Shop")$clickElement()

  # Get categories info
  grocerycart::nytnyt(c(5,10))
  oc_category_name <- grocerycart::get_html_elements(remDr,
                                                        css = ".level-item-link")

  nytnyt(c(5,10))
  oc_category_ext <- grocerycart::get_html_elements(remDr,
                                                       css = ".level-item-link",
                                                       type = "attribute",
                                                       attribute_selector = "href")

  oc_category_link <- paste0(url, oc_category_ext)

  tibble::tibble(category = oc_category_name,
                 link = oc_category_link)
}

#' @rdname oc_collect_categories
#'
#' @param remDr Remote client driver
#' @param links_to_use Category links
#' @param sleep_min Minimum time to suspend executing R expressions
#' @param sleep_max Maximum time to suspend executing R expressions
#'
#' @return \code{*_product_general}: Tibble with general product data
#' @export
oc_collect_product_general <- function(remDr = remDr,
                                       links_to_use,
                                       sleep_min = 0, sleep_max = 1,
                                       url = "https://www.ocado.com") {

  links_to_use %>%
    purrr::map_dfr(.data, function(.x) {

      # Navigate to page
      remDr$navigate(.x)
      grocerycart::nytnyt(c(3, 5), crayon_col = crayon::blue, "Make sure page loads \n")
      grocerycart::current_url(remDr)

      # Count number of items written on top of page
      oc_category_count <-
        grocerycart::get_html_element(remDr,
                                      css = ".total-product-number") %>%
        readr::parse_number()

      # Page title
      grocerycart::get_page_title(remDr)
      cat(crayon::blue("Collecting data from:",
                       oc_category$category[which(.x == links_to_use)],
                       "\n",
                       "Total products:", oc_category_count, "\n"))

      # Click on 'show more' until there's no more 'show more'
      grocerycart::click_show_more(remDr = remDr)

      # Slowly scroll down then up to load all products
      grocerycart::scroll_down_page_perc(remDr = remDr)
      grocerycart::scroll_up_page_perc(remDr = remDr)

      # Grab title
      product_title <-
        grocerycart::get_html_elements(remDr,
                                       css = "h4.fop-title",
                                       type = "attribute",
                                       attribute_selector = "title") %>%
        .data[-c(1:3)]

      grocerycart::nytnyt(c(6, 11), crayon_col = crayon::yellow, "Got titles\n")

      # Grab weight
      product_weight <-
        grocerycart::get_html_elements(remDr,
                                       css = ".fop-catch-weight") %>%
        .data[-c(1:3)]

      grocerycart::nytnyt(c(6, 11), crayon_col = crayon::cyan, "Got weights\n")

      # Grab price
      product_price <-
        grocerycart::get_html_elements(remDr,
                                       css = ".fop-price") %>%
        .data[-c(1:3)]

      grocerycart::nytnyt(c(6, 11), crayon_col = crayon::silver, "Got prices\n")

      # Grab shelf life
      product_shelf_life <-
        grocerycart::get_html_elements(remDr,
                                       css = ".fop-pack-info") %>%
        dplyr::na_if("") %>%
        .data[-c(1:3)]

      # Grab images
      product_images <-
        grocerycart::get_html_elements(remDr,
                                       css = "img.fop-img",
                                       type = "attribute",
                                       attribute_selector = "src") %>%
        paste0(url, .data) %>%
        .data[-c(1:3)]

      grocerycart::nytnyt(c(6, 11), crayon_col = crayon::blue, "Got images\n")

      # Grab product links
      product_links <-
        grocerycart::get_html_elements(remDr,
                                       css = "li.fops-item > div:nth-child(2) > div:nth-child(1) > a:nth-child(1)",
                                       type = "attribute",
                                       attribute_selector = "href") %>%
        paste0(url, .data)

      grocerycart::nytnyt(c(6, 11), crayon_col = crayon::green, "Got product links\n")

      # Verify lenghts match
      grocerycart::verify_oc_length_match(
        length(product_title),
        length(product_weight),
        length(product_price),
        length(product_images),
        length(product_links)
      )

      # Sleep
      grocerycart::nytnyt(c(sleep_min, sleep_max),
                          crayon_col = crayon::magenta,
                          "Got items from ",
                          oc_category$category[which(.x == links_to_use)],
                          "\n",
                          "Completed ",
                          which(.x == links_to_use),
                          " out of ",
                          length(links_to_use),
                          "\n")

      # Play sound only at end - when work complete
      grocerycart::sound_work_complete(which(.x == links_to_use), length(links_to_use))

      # Store data in a tibble
      tibble::tibble(title = product_title,
                     weight = product_weight,
                     price = product_price,
                     shelf_life = product_shelf_life,
                     images = product_images,
                     product_link = product_links,
                     category_link = rep(.x, length(product_title)))
    }
    )
}

#' @rdname oc_collect_categories
#'
#' @param remDr Remote client driver
#' @param links_to_use Product Links
#' @param sleep_min Minimum time to suspend executing R expressions
#' @param sleep_max Maximum time to suspend executing R expressions
#'
#' @return \code{*_product_extra}: Tibble with extra product data
#' @export
oc_collect_product_extra <- function(remDr = remDr,
                                     links_to_use,
                                     sleep_min = 0, sleep_max = 1) {

  links_to_use %>%
    purrr::map_dfr(.data, function(.x) {
      # Navigate to page
      remDr$navigate(.x)
      grocerycart::nytnyt(c(3, 5), crayon_col = crayon::blue, "Make sure page loads \n")
      grocerycart::current_url(remDr)

      # Page title
      grocerycart::get_page_title(remDr)

      # Grab bop badges: vegetarian, etc...
      product_badges <-
        grocerycart::get_html_elements(remDr,
                                       css = ".bop-badges > img",
                                       type = "attribute",
                                       attribute_selector = "title") %>%
        paste(.data, sep = ", ", collapse = ", ") %>%
        grocerycart::empty_to_na()
      cat(crayon::yellow("Got badges\n"))

      # Grab ingredients
      product_ingredients <-
        grocerycart::get_html_elements(remDr,
                                       css = "#productInformation") %>%
        stringr::str_extract("(?<=IngredientsIngredients).*$") %>%
        grocerycart::empty_to_na()
      cat(crayon::yellow("Got ingredients\n"))


      # Grab brand
      product_brand <-
        grocerycart::get_html_elements(remDr,
                                       css = ".bop-tags") %>%
        stringr::str_subset("(?<=Brands).*$") %>%
        stringr::str_extract("(?<=Brands).*$") %>%
        grocerycart::empty_to_na()
      cat(crayon::yellow("Got brand\n"))

      # Grab country of origin
      product_country <-
        grocerycart::get_html_elements(remDr,
                                       css = "#productInformation") %>%
        stringr::str_extract("(?<=Country of Origin).{100}") %>%
        stringr::str_extract(country_names) %>%
        purrr::keep(.p = ~ !is.na(.)) %>%
        paste(.data, sep = ", ", collapse = ", ") %>%
        grocerycart::empty_to_na()
      cat(crayon::yellow("Got country of origin\n"))

      # Grab rating
      prodcut_rating <-
        grocerycart::get_html_elements(remDr,
                                       css = ".bop-reviewSummary__kpiBall[itemprop='ratingValue']") %>%
        grocerycart::empty_to_na()
      cat(crayon::yellow("Got rating\n"))

      # Grab count
      product_count <-
        grocerycart::get_html_elements(remDr,
                                       css = ".bop-reviewSummary__kpiBall[itemprop='ratingCount']") %>%
        grocerycart::empty_to_na()
      cat(crayon::yellow("Got count\n"))

      # Grab recommend %
      product_recommend <-
        grocerycart::get_html_elements(remDr,
                                       css = ".bop-reviewSummary__recommendationsNumber") %>%
        readr::parse_number() %>%
        grocerycart::empty_to_na()
      cat(crayon::yellow("Got recommend %\n"))

      # Sleep

      grocerycart::nytnyt(c(sleep_min, sleep_max),
                          crayon_col = crayon::magenta,
                          "Adding new data to tibble\n",
                          "Completed ",
                          tryCatch(
                            expr = {
                              which(.x == links_to_use)
                              },
                            warning = function(w) {
                              cat(crayon::blue("Duplicate of product found\n"))
                              }),
                          " out of ",
                          length(links_to_use),
                          "\n")

      # Play sound only at end - when work complete
      grocerycart::sound_work_complete(which(.x == links_to_use), length(links_to_use))

      # Store data in a list
      tibble::tibble(
        product_link = .x,
        badge = product_badges,
        ingredient = product_ingredients,
        brand = product_brand,
        country = product_country,
        rating = prodcut_rating,
        count = product_count,
        recommend = product_recommend)
    })
}

#' @rdname oc_collect_categories
#'
#' @param remDr Remote client driver
#' @param links_to_use Product Links
#' @param sleep_min Minimum time to suspend executing R expressions
#' @param sleep_max Maximum time to suspend executing R expressions
#'
#' @return \code{*_product_reviews}: Tibble with product reviews
#' @export
oc_collect_product_reviews <- function(remDr = remDr,
                                       links_to_use,
                                       sleep_min = 0, sleep_max = 1) {

  links_to_use %>%
    purrr::map_dfr(.data, function(.x) {

      # Navigate to page
      remDr$navigate(.x)
      grocerycart::nytnyt(c(3, 5), crayon_col = crayon::blue, "Make sure page loads \n")
      grocerycart::current_url(remDr)

      # Grab reviews based on: (A) any reviews?, (B) # of review pages
      product_review_count <-
        grocerycart::get_html_elements(remDr,
                                       css = ".bop-reviewSummary__kpiBall[itemprop='ratingCount']")

      if(purrr::is_empty(product_review_count)) {
        cat(crayon::silver("No reviews for this product\n"))
        product_reviews <- NA
      } else {
        if(purrr::is_empty(get_html_elements(remDr, css = ".bop-reviews__paginationText"))) {
          cat(crayon::silver("No click next for this product \n"))

          product_reviews <-
            grocerycart::get_html_elements(remDr,
                                           css = ".bop-reviews__review > p") %>%
            tibble::tibble(reviews = .data)
        } else {
          num_page_reviews <-
            grocerycart::get_html_elements(remDr,
                                           css = ".bop-reviews__paginationText") %>%
            .data[[1]] %>%
            readr::parse_number()

          cat(crayon::silver(num_page_reviews, " pages of reviews for this product \n"))

          product_review_p1 <-
            grocerycart::get_html_elements(remDr,
                                           css = ".bop-reviews__review > p") %>%
            tibble::tibble(reviews = .data)

          if(num_page_reviews > 1) {
            first_right_button <- remDr$findElement(using = "css",
                                                    value = ".bop-reviews__paginationButton")

            grocerycart::nytnyt(c(1, 2))

            first_right_button$clickElement()

            product_review_p2 <-
              grocerycart::get_html_elements(remDr,
                                             css = ".bop-reviews__review > p") %>%
              tibble::tibble(reviews = .data)

            if(num_page_reviews > 2) {
              product_reviews <-
                purrr::map_dfr(1:(num_page_reviews - 2),
                               function(.y) {

                                 right_button <-
                                   remDr$findElement(using = "css",
                                                     value = "div.bop-reviews__paginationWrapper:nth-child(2) > button:nth-child(4)")

                                 grocerycart::nytnyt(c(1, 2))

                                 right_button$clickElement()

                                 product_review_ps <-
                                   grocerycart::get_html_elements(remDr,
                                                                  css = ".bop-reviews__review > p")

                                 cat(crayon::blue("Collected review page ", .y + 2,
                                                  " out of ", num_page_reviews, "\n"))

                                 tibble::tibble(reviews = product_review_ps)
                                 }) %>%
                dplyr::bind_rows(product_review_p1, product_review_p2, .data)
              } else {
                product_reviews <- dplyr::bind_rows(product_review_p1, product_review_p2)
              }
          }
        }
        }

      # Sleep
      grocerycart::nytnyt(c(sleep_min, sleep_max),
                          crayon_col = crayon::magenta,
                          "Adding new data to tibble\n",
                          "Completed ",
                          which(.x == links_to_use),
                          " out of ",
                          length(links_to_use),
                          "\n")

      # Play sound only at end - when work complete
      grocerycart::sound_work_complete(which(.x == links_to_use), length(links_to_use))

      # Store data in a tibble
      if(purrr::is_empty(product_review_count)) {
        dplyr::bind_cols(product = .x,
                         reviews = NA)
      } else {
        dplyr::bind_cols(product_link = rep(.x, length(product_reviews$reviews)),
                         reviews = product_reviews)
      }
    })
}


#' @rdname oc_collect_categories
#'
#' @param remDr Remote client driver
#' @param links_to_use Product Links
#' @param sleep_min Minimum time to suspend executing R expressions
#' @param sleep_max Maximum time to suspend executing R expressions
#'
#' @return \code{*_nutrition_table}: List with products' nutrition tables
#' @export
oc_collect_nutrition_table <- function(remDr = remDr,
                                       links_to_use,
                                       sleep_min = 0, sleep_max = 1) {

  links_to_use %>%
    purrr::map(.data, function(.x) {
      # Navigate to page
      remDr$navigate(.x)
      grocerycart::nytnyt(c(3, 5), crayon_col = crayon::blue, "Make sure page loads \n")
      grocerycart::current_url(remDr)

      # Page title
      grocerycart::get_page_title(remDr)

      # Grab nutrition table
      nutrition_table <-
        grocerycart::get_html_elements(remDr,
                                       css = ".bop-nutritionData__origin",
                                       type = "table") %>%
        grocerycart::empty_to_na() %>%
        purrr::pluck(1)
      cat(crayon::yellow("Got nutrition table\n"))

      # Sleep
      grocerycart::nytnyt(c(sleep_min, sleep_max),
                          crayon_col = crayon::magenta,
                          "Completed ",
                          which(.x == links_to_use),
                          " out of ",
                          length(links_to_use),
                          "\n")

      # Play sound only at end - when work complete
      grocerycart::sound_work_complete(which(.x == links_to_use), length(links_to_use))

      tibble::tibble(nutrition_table)
    }) %>%
    purrr::set_names(links_to_use)
}
