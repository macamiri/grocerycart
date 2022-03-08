##### 1: Load packages --------------------------------------------------------
# install.packages("pacman")
# pacman::p_install("grocerycart", "robotstxt", "RSelenium", "rvest", "purrr",
#                   "stringr", "readr", "dplyr", "tidyr", "fs", "here",
#                   "netstat", "tibble")
pacman::p_load(grocerycart, robotstxt, RSelenium, rvest, purrr, stringr, readr,
               dplyr, tidyr)

# Packages used with namespace: pacman, fs, here, netstat, tibble


##### 2: Initiate Selenium server ---------------------------------------------
# Set up remote client driver & open a session
remDr <- rsDriver(port = netstat::free_port(),
                  browser = "firefox",
                  verbose = FALSE)$client
remDr$open()


##### 3: Check robots.txt file for elgrocer.com -------------------------------
# Check which webpages are not bot friendly
url <- "https://www.elgrocer.com"

rtxt <- robotstxt(domain = url)
rtxt$comments
rtxt$crawl_delay
rtxt$permissions

# We can collect data from the webpages we are interested in
paths_allowed(domain = url, paths = c("/store", "/stores"))

# Navigate to website
remDr$navigate(url)

##### 4: Collect data ---------------------------------------------------------
### (A) Collect all location names and links
eg_location <- eg_collect_location_links(remDr, url)

# write_csv(eg_location, here::here("data/eg_location.csv"))

### (B) Collect all stores' 'i' details and links
eg_store <- eg_collect_stores_details(remDr, eg_location$location_link)

# write_csv(eg_store, here::here("data/eg_store.csv"))

### (C) Collect all categories data
# IMPORTANT: keep object name as 'eg_category'
# 'eg_category' is used internally in the eg_collect_subcategories function
eg_category <- eg_collect_categories(remDr, eg_store$store_link)

# write_csv(eg_category, here::here("data/eg_category.csv"))

### (D) Collect subcategories data from 300 random categories
random_category_links <- sample(1:length(eg_category$category_link),
                                300, replace = FALSE)

eg_subcategory <- eg_collect_subcategories(remDr,
                                               eg_category$category_link[random_category_links])

# write_csv(eg_subcategory, here::here("data/eg_subcategory.csv"))

### (E) Collect item data from 1000 random subcategories
### (from the 300 categories chosen above)
random_subcategory_links <- sample(1:length(eg_subcategory$subcategory_link),
                                   1000, replace = FALSE)

grocer_item <- eg_collect_items(remDr,
                                eg_subcategory$subcategory_link[random_subcategory_links])

# write_csv(grocer_item, here::here("data/grocer_item.csv"))

##### 5: Clean data -------------------------------------
### LOAD DATA
# # ...EITHER List the data files if the csv files from step 4 are in the
# # folder (i.e., downloaded from github)

# data_files <- fs::dir_ls(here::here("data-raw"),
#                          regexp = ".*data-raw/eg_.*\\.csv$")
#
# # Load them all together in a list
# data_list <-
#   data_files %>%
#   map(., ~ read_csv(.x, col_types = cols(.default = col_character()))) %>%
#   set_names(data_files %>% str_extract("[^/]*$") %>% str_remove(".csv"))

# ...OR continue from step 4 if the files are in global environment
data_list <- list(eg_category = eg_category,
                  eg_item = eg_item,
                  eg_location = eg_location,
                  eg_store = eg_store,
                  eg_subcategory = eg_subcategory)

# Convert list into a nested tibble...extract each one later
nested_grocery <-
  tibble::enframe(data_list, name = "origin", value = "data") %>%
  arrange("origin")

### Remove any extra whitespace in every column
nested_grocery <-
  nested_grocery %>%
  mutate(data = map(data, trim_nested_cols))

### LOCATION: No change to this table
clean_grocer_location <-
  nested_grocery %>%
  unnest_table("eg_location")
# write_csv(clean_eg_location, here::here("data/clean_eg_location.csv"))

### CATEGORY: Remove offer/promotion page since they contain products already
### available in other subcategories
clean_grocer_category <-
  nested_grocery %>%
  unnest_table("eg_category") %>%
  distinct(store_name, category, .keep_all = TRUE) %>%
  filter(!str_detect(category_link, "promotion")) %>%
  rename("category_image_link" = image_link)
# write_csv(clean_eg_category, here::here("data/clean_eg_category.csv"))

### SUBCATEGORY: No change to this table
clean_grocer_subcategory <-
  nested_grocery %>%
  unnest_table("eg_subcategory")
# write_csv(clean_eg_subcategory, here::here("data/clean_eg_subcategory.csv"))

### ITEM: Change price column to numeric
clean_grocer_product <-
  nested_grocery %>%
  unnest_table("eg_item") %>%
  mutate(price = parse_number(price))
# write_csv(clean_eg_product, here::here("data/clean_eg_product.csv"))

### STORE: separate details column
separator_detail <- paste("Min order amount", "Delivery within",
                          "Delivery hours", "Payment method",
                          sep = "|", collapse = "|")

new_col_names <- c("store_name", "min_order_amount", "delivery_within",
                   "delivery_hours", "payment_method")

new_delivery_names <- c("delivery_start", "delivery_end", "delivery_timezone")

separator_delivery <- paste(" - ", " ", sep = "|", collapse = "|")

clean_grocer_store <-
  nested_grocery %>%
  unnest_table("eg_store") %>%
  mutate(location = str_extract(location, "(?<= Stores in ).*")) %>%
  separate(location, into = c("location", "city"), sep = " , ") %>%
  separate(detail, into = new_col_names, sep = separator_detail) %>%
  separate(delivery_hours, into = new_delivery_names, sep = separator_delivery) %>%
  mutate(store_name = str_trim(store_name, "both"),
         min_order_amount = parse_number(min_order_amount),
         across(.cols = c("delivery_start", "delivery_end"),
                ~ hms::parse_hm(.)))
# write_csv(clean_eg_store, here::here("data/clean_eg_store.csv"))



#### usethis::use_data(raw_eg_data, overwrite = TRUE, )
