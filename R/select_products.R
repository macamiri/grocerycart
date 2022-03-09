#' Randomly select products
#'
#' Randomly select products to include in customers' baskets, possible with
#' varying probabilities for different products. This function is meant to
#' randomize/stimulate a 'grocery shopping experience', assuming the number
#' of products per basket/order is randomly distributed.
#'
#' @param products Vector of products to select from.
#' @param probs Probabilities of selecting products.
#' @param customer_id Vector of customer id's.
#' @param min_products Minimum number of products per basket/order.
#' @param mean_products Average number of products per basket/order.
#' @param sd_products Standard deviation for number of products per basket/order.
#'
#' @return A vector of product names.
#' @export
#'
#' @examples
#' # 7 products to choose from
#' items <- c("apple", "orange", "tea", "coffee", "ice cream", "cookie", "jam")
#'
#' # 3 customers
#' c_id <- 1:3
#'
#' # All products are equally likely to be chosen
#' baskets <- select_products(items, rep(1/7, length(items)),
#' customer_id = c_id, min_products = 1, mean_products = 3, sd_products = 1)
#'
#' # Table of customers and their baskets
#' tibble::tibble(customer_id = c_id, order = baskets) %>%
#' tidyr::separate_rows(order, sep = "@")
select_products <- function(products, probs, customer_id, min_products,
                            mean_products, sd_products) {

  customer_id %>%
    purrr::map(., function(.x) {
      num_of_products <- round(stats::rnorm(1, mean = mean_products, sd = sd_products))

      if(num_of_products >= min_products) {
        sample(products,
               size = num_of_products,
               prob = probs,
               replace = FALSE)
      } else {
        num_of_products <- min_products
        sample(products,
               size = num_of_products,
               prob = probs,
               replace = FALSE)
      }
    }) %>%
    purrr::map(., ~ paste0(.x, collapse = "@")) %>%
    unlist()
}
