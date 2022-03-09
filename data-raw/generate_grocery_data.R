##### 1: Load packages --------------------------------------------------------
# Main packages loaded:fabricatr, wakefield, randomNames, charlatan, magrittr, purrr
# Packages used with namespace: pacman, readr, here, tibble, dplyr
# install.packages("pacman")
# pacman::p_install("fabricatr", "wakefield", "randomNames", "charlatan",
#                   "magrittr", "purrr", "readr", "here", "tibble", "dplyr")
pacman::p_load(fabricatr, wakefield, randomNames, charlatan, magrittr, purrr)

##### 2: Load grocery data to sample from -----
data("eg_store")
data("eg_product")
data("eg_data")
data("oc_data")

##### 3: Rules related to how data is generated -----
### order_db
## order_date:
# 40% of orders from 2020 & 60% of orders from 2021
# 30% 1st half of the year, 70% second half of the year
# (.4*.3)/183 #1-183
# (.4*.7)/183 #184-366
# (.6*.3)/183 #367-549
# (.6*.7)/182 #550-731

## order_time: probability
# 5% of orders from 00:00 to 8:00 am - .05/80 (1-81)
# 20% of orders from 8:00 to 10:00 am - .20/20 (81-101)
# 25% of orders from 10:00 to 12:00 pm - .25/20 (101-121)
# 25% of orders from 12:00 to 6:00 pm - .25/60 (121-181)
# 15% of orders from 6:00 to 10:00 pm - .15/40 (181-221)
# 10% of orders from 10:00 to 12:00 am - .1/20 (221-241)

### store
# prob of ordering from each store according the the # of products in store
# more product ---> higher probability to select store
store_prob <-
  eg_data %>%
  dplyr::left_join(eg_store, by = "store_name") %>%
  dplyr::group_by(store_name) %>%
  dplyr::summarise(products = dplyr::n()) %>%
  dplyr::mutate(probs = products / sum(products)) %>%
  dplyr::arrange(desc(products))

### basket_db
# num of unique products, across all stores
eg_num_of_products <-
  eg_product %>%
    dplyr::distinct(item) %>%
    nrow()

# give random score for each product for probability calculation
eg_scores <-
  sample(1:39, size = eg_num_of_products, replace = TRUE) %>%
    tibble::tibble(score = .) %>%
    dplyr::bind_cols(eg_product %>% dplyr::distinct(item, .keep_all = TRUE)) %>%
    dplyr::rename("product" = item) %>%
    dplyr::select(product, price, score)

# prob of ordering a product is based on num of reviews + % recommend
oc_scores <-
  oc_data %>%
    dplyr::group_by(product) %>%
    dplyr::summarise(product = product,
                     price = price,
                     score = ceiling((as.numeric(num_of_reviews) + as.numeric(recommend)) * .5)) %>%
    dplyr::filter(!is.na(score)) %>%
    dplyr::ungroup()

product_prob <-
  oc_scores %>%
  dplyr::bind_rows(eg_scores) %>%
  dplyr::mutate(probs = score / sum(score)) %>%
  dplyr::arrange(desc(score))

### For 1 store (funmart): 100 products with random probabilities
product_prob_funmart <-
  tibble::tibble(
    product = sample(product_prob$product, size = 200, replace = FALSE)) %>%
    dplyr::mutate(probs = probs(j = 200))


##### 4: Generate large fake random customer data -----
# num_of_customers <- 100000
# num_of_orders <- 250000
#
# # Customer database table - keep distinct names
# customer_db <- fabricate(
#   N = num_of_customers,
#   customer_name = randomNames(n = N, name.sep = " ", name.order = "first.last"),
#   customer_age = wakefield::age(n = N, x = 18:75, prob = c(rep(.3, 13), rep(.6, 30), rep(.1, 15))),
#   household_size = wakefield::children(n = N, x = 0:7, prob = c(.17, .25, .25, .2, .05, .05, .01, .01)),
#   long = ch_position(n = N, bbox = c(51, 22.50, 56.25, 26)) %>% purrr::map_chr(., ~ .[1]),
#   lat = ch_position(n = N, bbox = c(51, 22.50, 56.25, 26)) %>% purrr::map_chr(., ~ .[2]),
# ) %>%
#   tibble::as_tibble() %>%
#   dplyr::distinct(customer_name, .keep_all = TRUE) %>%
#   dplyr::rename("customer_id" = ID)
# # readr::write_csv(customer_db, here::here("data/customer_db.csv"))
#
#
# # Orders database table
# order_db <- fabricate(
#   N = num_of_orders,
#   customer_id = as.character(sample(customer_db$customer_id, size = N, replace = TRUE)),
#   order_date = date_stamp(n = N,
#                           start = as.Date("2020-01-01"),
#                           k = 731,
#                           by = "1 day",
#                           prob = c(rep(0.0006557377, 183),
#                                    rep(0.001530055, 183),
#                                    rep(0.0009836066, 183),
#                                    rep(0.002307692, 182))),
#   order_time = hour(n = N,
#                     x = seq(from = 0, to = 23.9, by = .1),
#                     prob = c(rep(0.000625, 80),
#                              rep(0.01, 20),
#                              rep(0.0125, 20),
#                              rep(0.004166667, 60),
#                              rep(0.00375, 40),
#                              rep(0.005, 20))),
#   store = sample(store_prob$store_name,
#                  prob = store_prob$probs,
#                  size = N,
#                  replace = TRUE),
# ) %>%
#   tibble::as_tibble() %>%
#   dplyr::rename("order_id" = ID)
# # readr::write_csv(order_db, here::here("data/order_db.csv"))


# Basket line item database table - join later if need more product info
basket_db <- fabricate(
  N = length(customer_db$customer_id),
  order_id = as.character(sample(order_db$order_id, size = N, replace = FALSE)),
  product = grocerycart::select_products(products = product_prob$product,
                                         customer_id = customer_db$customer_id,
                                         probs = product_prob$probs,
                                         min_products = 10,
                                         mean_products = 26,
                                         sd_products = 4),
) %>%
  tibble::as_tibble() %>%
  tidyr::separate_rows(product, sep = "@") %>%
  dplyr::left_join(product_prob, by = "product") %>%
  dplyr::select(ID, order_id, product, price) %>%
  dplyr::rename("basket_id" = ID) %>%
  dplyr::distinct(basket_id, product, .keep_all = TRUE)

# readr::write_csv(basket_db, here::here("data/basket_db.csv"))

##### 5: Generate fake random customer data for 1 store (funmart) ----
num_of_customers <- 5000
num_of_orders <- 12500

# Customer database table - keep distinct names
customer_db_funmart <- fabricate(
  N = num_of_customers,
  customer_name = randomNames(n = N, name.sep = " ", name.order = "first.last"),
  customer_age = wakefield::age(n = N, x = 18:75, prob = c(rep(.3, 13), rep(.6, 30), rep(.1, 15))),
  household_size = wakefield::children(n = N, x = 0:7, prob = c(.17, .25, .25, .2, .05, .05, .01, .01)),
  long = ch_position(n = N, bbox = c(51, 22.50, 56.25, 26)) %>% purrr::map_chr(., ~ .[1]),
  lat = ch_position(n = N, bbox = c(51, 22.50, 56.25, 26)) %>% purrr::map_chr(., ~ .[2]),
) %>%
  tibble::as_tibble() %>%
  dplyr::distinct(customer_name, .keep_all = TRUE) %>%
  dplyr::rename("customer_id" = ID)
# readr::write_csv(customer_db_funmart, here::here("data/customer_db_funmart.csv"))

# Orders database table
order_db_funmart <- fabricate(
  N = num_of_orders,
  customer_id = as.character(sample(customer_db$customer_id, size = N, replace = TRUE)),
  order_date = date_stamp(n = N,
                          start = as.Date("2020-01-01"),
                          k = 731,
                          by = "1 day",
                          prob = c(rep(0.0006557377, 183),
                                   rep(0.001530055, 183),
                                   rep(0.0009836066, 183),
                                   rep(0.002307692, 182))),
  order_time = hour(n = N,
                    x = seq(from = 0, to = 23.9, by = .1),
                    prob = c(rep(0.000625, 80),
                             rep(0.01, 20),
                             rep(0.0125, 20),
                             rep(0.004166667, 60),
                             rep(0.00375, 40),
                             rep(0.005, 20))),
  store = rep("funmart", N),
) %>%
  tibble::as_tibble() %>%
  dplyr::rename("order_id" = ID)
# readr::write_csv(order_db_funmart, here::here("data/order_db_funmart.csv"))


# Basket line item database table - join later if need more product info
basket_db_funmart <- fabricate(
  N = length(customer_db_funmart$customer_id),
  order_id = as.character(sample(order_db_funmart$order_id, size = N, replace = FALSE)),
  product = grocerycart::select_products(products = product_prob_funmart$product,
                                         customer_id = customer_db_funmart$customer_id,
                                         probs = product_prob_funmart$probs,
                                         min_products = 3,
                                         mean_products = 12,
                                         sd_products = 3),
) %>%
  tibble::as_tibble() %>%
  tidyr::separate_rows(product, sep = "@") %>%
  dplyr::left_join(product_prob, by = "product") %>%
  dplyr::select(ID, order_id, product, price) %>%
  dplyr::rename("basket_id" = ID) %>%
  dplyr::distinct(basket_id, product, .keep_all = TRUE)

# readr::write_csv(basket_db_funmart, here::here("data/basket_db_funmart.csv"))

##### 6: Add data files to package ------
# usethis::use_data(customer_db, overwrite = TRUE, compress = "xz")
# usethis::use_data(order_db, overwrite = TRUE, compress = "xz")
# usethis::use_data(basket_db, overwrite = TRUE, compress = "xz")
usethis::use_data(customer_db_funmart, overwrite = TRUE, compress = "xz")
usethis::use_data(order_db_funmart, overwrite = TRUE, compress = "xz")
usethis::use_data(basket_db_funmart, overwrite = TRUE, compress = "xz")
