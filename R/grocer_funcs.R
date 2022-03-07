#' Collect elgrocer data
#'
#' @param remDr Remote client driver
#' @param url elgrocer url
#'
#' @return Tibble with the URL for each location
#' @export
#'
#' @examples
#' # Initiate server
#' remDr <- RSelenium::rsDriver(port = 4446L,
#' browser = "firefox", verbose = FALSE)$client
#'
#' # Collect all location links
#' grocer_location <- eg_collect_location_links(remDr = remDr, url = "https://www.elgrocer.com")
#'
#' # Collect store details from 2 locations
#' grocer_store <- eg_collect_stores_details(remDr, grocer_location$location_link[1:2])
#'
#' # Collect categories from 1 store
#' grocer_category <- eg_collect_categories(remDr, grocer_store$store_link[1])
#'
#' # Collect subcategories from 3 categories
#' random_category_links <- sample(1:length(grocer_category$category_link),
#' 3, replace = FALSE)
#' grocer_subcategory <- eg_collect_subcategories(grocer_category$category_link[random_category_links])
#'
#' # Collect product data from 4 subcategories
#' random_subcategory_links <- sample(1:length(grocer_subcategory$subcategory_link),
#' 4, replace = FALSE)
#' grocer_item <- eg_collect_items(grocer_subcategory$subcategory_link[random_subcategory_links])
#'
#' # Close the server
#' remDr$close()
#' gc(remDr)
#' rm(remDr)
eg_collect_location_links <- function(remDr = remDr, url = "https://www.elgrocer.com") {
  # Navigate to homepage
  remDr$navigate(url)
  grocerycart::nytnyt(c(5, 10),
                      crayon_col = crayon::blue,
                      "Make sure page loads \n")
  grocerycart::get_page_title(remDr)

  # 131 total locations
  locations <- grocerycart::get_html_elements(remDr,
                                              css = ".text-success",
                                              type = "text")

  # Collect 131 location links
  location_links_extensions <- grocerycart::get_html_elements(remDr,
                                                              css = ".text-success",
                                                              type = "attribute",
                                                              attribute_selector = "href")

  location_links <- paste0(url, location_links_extensions)

  tibble::tibble(location = locations, location_link = location_links)
}

#' @rdname eg_collect_location_links
#'
#' @param remDr Remote client driver
#' @param links_to_use Location links
#' @param sleep_min Minimum time to suspend executing R expressions
#' @param sleep_max Maximum time to suspend executing R expressions
#'
#' @return Tibble with store links
#' @export
eg_collect_stores_details <- function(remDr = remDr,
                                   links_to_use,
                                   sleep_min = 0, sleep_max = 1) {

  links_to_use %>%
    purrr::map_dfr(., function(.x) {
      # Navigate to the url
      remDr$navigate(.x)
      grocerycart::nytnyt(c(5, 10), crayon_col = crayon::blue, "Make sure page loads \n")
      grocerycart::current_url(remDr)

      # Scroll
      grocerycart::scroll_down_and_load(remDr)
      grocerycart::scroll_to_top(remDr)

      # Grab location title
      location_title <- grocerycart::get_html_element(remDr, css = "h1")

      # Number of stores - rvest
      num_of_stores_rvest <-
        grocerycart::get_html_elements(remDr, css = "h2.text-black") %>%
        length()

      # Click on the 'i' icon to reveal more data
      rem_store_info <- remDr$findElements(using = "class name",
                                           value = "store-info")

      rem_store_info %>%
        purrr::map(., ~ .$clickElement()) %>%
        unlist()

      # Number of stores - selenium
      num_of_stores_selenium <- length(rem_store_info)

      # Verify that all stores' 'i' icon was clicked
      if(num_of_stores_rvest == num_of_stores_selenium) {
        cat(crayon::green("Success! Lengths match: ",  num_of_stores_rvest, "\n"))
      } else {
        stop(crayon::red("Go Back! Lengths match DO NOT match:\n",
                         "From selenium:", num_of_stores_selenium, "\n",
                         "From rvest:", num_of_stores_rvest))
      }

      # Collect the extra 'i' icon data
      store_details <- grocerycart::get_html_elements(remDr, css = ".store-detail")

      grocerycart::nytnyt(c(sleep_min, sleep_max),
                          crayon_col = crayon::magenta,
                          "Got details. Grab links in location:",
                          which(.x == links_to_use),
                          " out of ",
                          length(links_to_use),
                          "\n")

      store_links <- grocerycart::get_html_elements(remDr,
                                                    css = ".store-grid",
                                                    type = "attribute",
                                                    attribute_selector = "href")

      # Play sound only at end - when work complete
      grocerycart::sound_work_complete(which(.x == links_to_use), length(links_to_use))

      # Store data in a tibble
      tibble::tibble(location = rep(location_title, num_of_stores_rvest),
                     detail = store_details,
                     store_link = paste0(url, store_links),
                     location_link = rep(.x, num_of_stores_rvest))
    }
    )
}

#' @rdname eg_collect_location_links
#'
#' @param remDr Remote client driver
#' @param links_to_use Store links
#' @param sleep_min Minimum time to suspend executing R expressions
#' @param sleep_max Maximum time to suspend executing R expressions
#'
#' @return Tibble with category links
#' @export
eg_collect_categories <- function(remDr = remDr,
                               links_to_use,
                               sleep_min = 0, sleep_max = 1) {
  # Category links
  links <- paste0(links_to_use, "/categories")
  unique_links <- unique(links)

  unique_links %>%
    purrr::map_dfr(., function(.x) {
      remDr$navigate(.x)
      grocerycart::nytnyt(c(5, 10), crayon_col = crayon::blue, "Make sure page loads \n")
      grocerycart::current_url(remDr)

      # Grab store name
      store_name <-
        grocerycart::get_html_element(remDr, css = "h2.text-black") %>%
        stringr::str_trim(side = "both") %>%
        stringr::str_remove(" Product Categories")

      # Scroll
      grocerycart::scroll_down_and_load(remDr)
      grocerycart::scroll_to_top(remDr)

      # Grab category image links
      category_image_links <- grocerycart::get_html_elements(remDr,
                                                             css = "img.center",
                                                             type = "attribute",
                                                             attribute_selector = "src")

      # Grab the category titles
      store_categories <-
        grocerycart::get_html_elements(remDr, css = "h3.text-black") %>%
        stringr::str_trim(side = "both")

      num_of_categories <- length(store_categories)

      # Grab the category links
      category_link_ext <- grocerycart::get_html_elements(remDr,
                                                          css = ".category-card",
                                                          type = "attribute",
                                                          attribute_selector = "href")

      category_links <- paste0(url, category_link_ext)

      # Verify that every category's link was collected
      verify_length_match <- function(sel, rve) {
        if(sel == rve) {
          cat(crayon::green("Success! Lengths match: ",  rve, "\n"))
        } else {
          stop(crayon::red("Go Back! Lengths match DO NOT match:\n",
                           "From selenium:", sel, "\n",
                           "From rvest:", rve))
        }
      }

      verify_length_match(sel = num_of_categories,
                          rve = if(category_links == url) {
                            0
                          } else {
                            length(category_links)
                          })

      # Sleep
      grocerycart::nytnyt(c(sleep_min, sleep_max),
                          crayon_col = crayon::magenta,
                          "Got category images, titles & links. Completed ",
                          which(.x == unique_links),
                          " out of ",
                          length(unique_links),
                          " links \n")

      # Play sound only at end - when work complete
      grocerycart::sound_work_complete(which(.x == unique_links), length(unique_links))

      # Store data in a tibble
      tibble::tibble(store_name = rep(store_name, num_of_categories),
                     category = store_categories,
                     category_link = category_links,
                     image_link = category_image_links,
                     store_link = rep(.x, num_of_categories))
    }
    )
}

#' @rdname eg_collect_location_links
#'
#' @param remDr Remote client driver
#' @param links_to_use Category links
#' @param sleep_min Minimum time to suspend executing R expressions
#' @param sleep_max Maximum time to suspend executing R expressions
#'
#' @return Tibble with subcategory links
#' @export
eg_collect_subcategories <- function(remDr = remDr,
                                  links_to_use,
                                  sleep_min = 0, sleep_max = 1) {

  links_to_use %>%
    purrr::map_dfr(., function(.x) {
      # Navigate to subcategory
      remDr$navigate(.x)
      grocerycart::nytnyt(c(5, 10), crayon_col = crayon::blue, "Make sure page loads \n")
      grocerycart::current_url(remDr)

      # Grab store name
      store_title <-
        grocerycart::get_html_element(remDr, css = "h1.store-name") %>%
        stringr::str_trim(side = "both")

      # Grab subcategory links /{all}
      num_of_categories_tibble <-
        grocer_category %>%
        dplyr::count(.data$store_name)


      tryCatch(
        expr = {
          num_of_categories <-
            num_of_categories_tibble %>%
            dplyr::filter(stringr::str_to_lower(.data$store_name) == stringr::str_to_lower(.data$store_title)) %>%
            .[[2]]

          num_of_categories <- num_of_categories + 1

          subcategory_link_extensions <-
            grocerycart::get_html_elements(remDr,
                                           css = "div.slider-item > a:nth-child(1)",
                                           type = "attribute",
                                           attribute_selector = "href") %>%
            .[-c(1:num_of_categories)]

          subcategory_links <- paste0(url, subcategory_link_extensions)

          # Count subcategories
          store_subcategories <-
            grocerycart::get_html_elements(remDr, css = ".text-primery-1") %>%
            stringr::str_trim(side = "both")

          num_of_subcategories <- length(store_subcategories)

          # Verify that every subcategory's link was collected
          verify_length_match <- function(sel, rve) {
            if(sel == rve) {
              cat(crayon::green("Success! Lengths match: ",  rve, "\n"))
            } else {
              stop(crayon::red("Go Back! Lengths match DO NOT match:\n",
                               "From selenium:", sel, "\n",
                               "From rvest:", rve))
            }
          }

          verify_length_match(sel = num_of_subcategories,
                              rve = if(subcategory_links == url) {
                                0
                              } else {
                                length(subcategory_links)
                              })

          # Sleep
          grocerycart::nytnyt(c(sleep_min, sleep_max),
                              crayon_col = crayon::magenta,
                              "Got subcategories. Completed ",
                              which(.x == links_to_use),
                              " out of ",
                              length(links_to_use),
                              " categories \n")

          # Play sound only at end - when work complete
          grocerycart::sound_work_complete(which(.x == links_to_use), length(links_to_use))

          # Store data in a tibble
          tibble::tibble(subcategory = store_subcategories,
                         subcategory_link = subcategory_links,
                         category_link = rep(.x, num_of_subcategories))
        },
        error = function(e) {}
      )
    }
    )
}

#' @rdname eg_collect_location_links
#'
#' @param remDr Remote client driver
#' @param links_to_use Subcategory links
#' @param sleep_min Minimum time to suspend executing R expressions
#' @param sleep_max Maximum time to suspend executing R expressions
#'
#' @return Tibble with product details
#' @export
eg_collect_items <- function(remDr,
                          links_to_use = grocer_subcategory$subcategory_link,
                          sleep_min = 0, sleep_max = 1) {

  links_to_use %>%
    purrr::map_dfr(., function(.x) {
      # Navigate to subcategory page
      remDr$navigate(.x)
      grocerycart::nytnyt(c(5, 10), crayon_col = crayon::blue, "Make sure page loads \n")
      grocerycart::current_url(remDr)

      # Scroll
      grocerycart::scroll_down_and_load(remDr)
      grocerycart::scroll_to_top(remDr)

      tryCatch(
        expr = {

          # Grab title
          item_title <- grocerycart::get_html_elements(remDr, css = "h2.text-black")

          # Grab weight
          item_weight <- grocerycart::get_html_elements(remDr, css = "div.item-label")

          # Grab price
          item_price <- grocerycart::get_html_elements(remDr, css = "div.item-price")

          # Grab image link
          item_image_links <- grocerycart::get_html_elements(remDr,
                                                             css = "img.center",
                                                             type = "attribute",
                                                             attribute_selector = "src")

          # Sleep
          subcategory_title <- grocerycart::get_html_element(remDr, css = "h2.ng-star-inserted")
          grocerycart::nytnyt(c(sleep_min, sleep_max),
                              crayon_col = crayon::magenta,
                              "Got items. Completed ",
                              which(.x == links_to_use),
                              " out of ",
                              length(links_to_use),
                              " sub-subcategories \n",
                              "Current subcategory:", subcategory_title, "\n")

          # Play sound only at end - when work complete
          grocerycart::sound_work_complete(which(.x == links_to_use), length(links_to_use))

          # Store data in a tibble
          tibble::tibble(subcategory_link = rep(.x, length(item_title)),
                         item = item_title,
                         weight = item_weight,
                         price = item_price,
                         item_image_link = item_image_links)

        },
        error = function(e) {}
      )
    }
    )
}
