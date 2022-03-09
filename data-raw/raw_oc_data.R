##### 1: Load packages --------------------------------------------------------
# Main packages loaded: robotstxt, RSelenium, rvest, purrr, stringr, readr
# Packages used with namespace: pacman, here, netstat, crayon, tibble, dplyr, beepr
# install.packages("pacman")
# pacman::p_install("robotstxt", "RSelenium", "rvest", "purrr", "stringr", "readr",
#                   "here", "netstat", "crayon", "tibble", "dplyr", "beepr")
pacman::p_load(robotstxt, RSelenium, rvest, purrr, stringr, readr)


##### 2: Collect country names (to clean data in step 6) ----------------------
# Country names & flags
country_names <-
  read_html("https://www.worldometers.info/geography/flags-of-the-world/") %>%
  html_elements(".col-md-4 > div[align='center'] > div") %>%
  html_text() %>%
  str_replace_all(c("U.S." = "USA", "U.K." = "UK", "U.A.E." = "UAE")) %>%
  c(., "United Kingdom", "United States", "United Arab Emirates", "England", "EU")

country_flags <-
  read_html("https://www.worldometers.info/geography/flags-of-the-world/") %>%
  html_elements(".col-md-4 > div[align='center'] > a") %>%
  html_attr("href") %>%
  paste0("https://www.worldometers.info", .)

##### 3: Initiate Selenium server ---------------------------------------------
# Set up remote client driver & open a session
remDr <- rsDriver(port = netstat::free_port(),
                  browser = "firefox",
                  verbose = FALSE)$client
remDr$open()


##### 4: Check robots.txt file for ocado.com ----------------------------------
# Check which webpages are not bot friendly
url <- "https://www.ocado.com"

rtxt <- robotstxt(domain = url)
rtxt$comments
rtxt$crawl_delay
rtxt$permissions

# We can collect data from the webpages we are interested in
paths_allowed(domain = url, paths = c("/browse"))

# Navigate to website
remDr$navigate(url)

##### 5: Collect data ----
### (A) Collect all category links
oc_category <- oc_collect_categories(remDr)
# write_csv(oc_category, here::here("data-raw/oc_category.csv"))

### (B) Collect general product data from 3 categories (~10,000 products)
chosen_category_links <- c(1, 3, 6)
oc_product_general <- oc_collect_product_general(remDr,
                                                 oc_category$link[chosen_category_links])
# write_csv(oc_product_general, here::here("data-raw/oc_product_general.csv"))

### (C) Collect extra product data for 1000 products from the 3 categories above
random_product_links <- sample(1:length(oc_product_general$product_link),
                               1000, replace = FALSE)

# Collect the details in 4 stages in case if error occurs at any point
oc_extra1 <- oc_collect_product_extra(remDr, oc_product_general$product_link[random_product_links[1:250]])
oc_extra2 <- oc_collect_product_extra(remDr, oc_product_general$product_link[random_product_links[251:500]])
oc_extra3 <- oc_collect_product_extra(remDr, oc_product_general$product_link[random_product_links[501:750]])
oc_extra4 <- oc_collect_product_extra(remDr, oc_product_general$product_link[random_product_links[751:1000]])

oc_product_extra <- bind_rows(oc_extra1, oc_extra2, oc_extra3, oc_extra4)
# write_csv(oc_product_extra, here::here("data-raw/oc_product_extra.csv"))

### (D) Collect product reviews, if available, for the same 1000 products
oc_review1 <- oc_collect_product_reviews(remDr, oc_product_general$product_link[random_product_links[1:250]])
oc_review2 <- oc_collect_product_reviews(remDr, oc_product_general$product_link[random_product_links[251:500]])
oc_review3 <- oc_collect_product_reviews(remDr, oc_product_general$product_link[random_product_links[501:750]])
oc_review4 <- oc_collect_product_reviews(remDr, oc_product_general$product_link[random_product_links[751:1000]])

oc_product_review <- bind_rows(oc_review1, oc_review2, oc_review3, oc_review4)
# write_csv(oc_product_review, here::here("data-raw/oc_product_review.csv"))

### (E) Collect product nutrition table, if available, for the same 1000 products
oc_nutrition_table <- oc_collect_nutrition_table(remDr,
                                                 oc_product_general$product_link[random_product_links])
# write_rds(oc_nutrition_table, here::here("data-raw/oc_nutrition_table.rds"))

##### 6: Clean data ------
### LOAD DATA
# # ...EITHER List the data files if the csv files from step 5 are in the
# # folder (i.e., downloaded from github)
# data_files <- fs::dir_ls(here::here("data-raw"), regexp = ".*data-raw/oc_.*csv$")
#
# # Load them all together in a list
# data_list <-
#   data_files %>%
#     map(., ~ read_csv(.x, col_types = cols(.default = col_character()))) %>%
#     set_names(data_files %>% str_extract("[^/]*$") %>% str_remove(".csv"))

# ...OR continue from step 5 if the files are in global environment
data_list <- list(oc_category = oc_category,
                  oc_product_extra = oc_product_extra,
                  oc_product_general = oc_product_general,
                  oc_product_review = oc_product_review)

# Convert list into a nested tibble...extract each one later
nested_grocery <-
  tibble::enframe(data_list, name = "origin", value = "data") %>%
  arrange("origin")

### Remove any extra whitespace in every column
nested_grocery <-
  nested_grocery %>%
  mutate(data = map(data, trim_nested_cols))

### CATEGORY: Turn category column into a factor
oc_category <-
  nested_grocery %>%
  unnest_table("oc_category") %>%
  mutate(category = forcats::as_factor(category)) %>%
  rename("category_link" = link)
# write_csv(oc_category, here::here("data-raw/oc_category_clean.csv"))

### PRODUCT GENERAL: convert price to # & shelf_life to factor
### Same product_link & different category_link = same product
### The reason to keep duplicate titles/product_link = different weight or price
### Remove duplicates
oc_product_general <-
  nested_grocery %>%
  unnest_table("oc_product_general") %>%
  mutate(price = parse_number(price),
         shelf_life = forcats::as_factor(shelf_life)) %>%
  rename("product" = title, "image_link" = images) %>%
  distinct(product, weight, price, product_link, .keep_all = TRUE)
# write_csv(oc_product_general, here::here("data-raw/oc_product_general_clean.csv"))

### PRODUCT REVIEW: Remove duplicates (e.g., the same product might have been
### collected more than once if it was listed in different categories on
### the ocado website ---> review will be repeated---> so, find distinct
### product - review pair)
### Then, nest the reviews data
oc_product_review <-
  nested_grocery %>%
  unnest_table("oc_product_review") %>%
  distinct(product_link, reviews) %>%
  nest(reviews = reviews)
# write_csv(oc_product_review, here::here("data-raw/oc_product_review_clean.csv"))

### PRODUCT EXTRA: extract the ingredients
### Same product_link = same product ---> remove duplicates
oc_product_extra <-
  nested_grocery %>%
  unnest_table("oc_product_extra") %>%
  mutate(ingredient = map_chr(ingredient, extract_ingredients)) %>%
  rename("num_of_reviews" = count) %>%
  distinct(product_link, .keep_all = TRUE)
# write_csv(oc_product_extra, here::here("data-raw/oc_product_extra_clean.csv"))

### NUTRITION: turn nutrition list into nested tibble
oc_nutrition_table <- read_rds(here::here("data-raw/oc_nutrition_table.rds"))

oc_nutrition_table <-
  oc_nutrition_table %>%
    tibble::enframe(name = "product_link", value = "nutrition") %>%
    distinct(product_link, .keep_all = TRUE) %>%
    left_join(clean_oc_product_general, by = "product_link") %>%
    select(product_link, nutrition)
# write_rds(oc_nutrition_table, here::here("data-raw/oc_nutrition_table_clean.rds"))

### JOIN ALL oc tables
oc_data <-
  oc_product_general %>%
  left_join(oc_product_extra, by = "product_link") %>%
  left_join(oc_category, by = "category_link") %>%
  left_join(oc_product_review, by = "product_link") %>%
  left_join(oc_nutrition_table, by = "product_link") %>%
  mutate(across(.cols = c(rating, num_of_reviews, recommend),
                ~ as.numeric(.x))) %>%
  select(category, brand, product, price, weight, badge, shelf_life,
         country, rating, num_of_reviews, recommend, ingredient,
         reviews, nutrition,
         image_link, product_link, category_link)
# write_rds(oc_data, here::here("data-raw/oc_data.rds"))


##### 7: Close Selenium server ------------------------------------------------
remDr$close()
system("kill /im java.exe /f")
gc(remDr)
rm(remDr)


##### 8: Add data files to package ------
usethis::use_data(oc_data, overwrite = TRUE, compress = "xz")
usethis::use_data(oc_category, overwrite = TRUE, compress = "xz")
usethis::use_data(oc_product_extra, overwrite = TRUE, compress = "xz")
usethis::use_data(oc_product_general, overwrite = TRUE, compress = "xz")
usethis::use_data(oc_product_review, overwrite = TRUE, compress = "xz")
usethis::use_data(oc_nutrition_table, overwrite = TRUE, compress = "xz")
