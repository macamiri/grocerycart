#' Names of location areas in UAE
#'
#' A dataset contianing the names and links of 131 locations that have grocery
#' stores that provide online delivery services. A location may contain
#' several stores. The stores may overlap among different locations.
#'
#' @format A data frame with 131 rows and 2 variables:
#' \describe{
#'   \item{location}{name of location in UAE}
#'   \item{location_link}{link to view stores in location}
#' }
#'
#' @name eg_location
#' @usage data(eg_location)
#'
#' @source \url{https://www.elgrocer.com}
"eg_location"

#' Grocery stores that provide online delivery services
#'
#' A dataset containing details for 184 grocery stores that provide online
#' delivery services.
#'
#' @format A data frame with 184 rows and 11 variables:
#' \describe{
#'   \item{location}{name of location in UAE}
#'   \item{city}{name of city in UAE}
#'   \item{store_name}{name of the store}
#'   \item{min_order_amount}{minimum order amount to qualify for delivery, in GBP}
#'   \item{delivery_within}{time interval for delivery after placing order}
#'   \item{delivery_start}{time delivery service begins for the day}
#'   \item{delivery_end}{time delivery service ends for the day}
#'   \item{delivery_timezone}{timezone}
#'   \item{payment_method}{available payment methods}
#'   \item{store_link}{link to the store}
#'   \item{location_link}{link to view stores in location}
#' }
#'
#' @name eg_store
#' @usage data(eg_store)
#'
#' @source \url{https://www.elgrocer.com}
"eg_store"

#' Product categories available in different grocery stores
#'
#' A dataset containing 3,278 product categories in different grocery stores.
#'
#' @format A data frame with 3,278 rows and 5 variables:
#' \describe{
#'   \item{store_name}{name of the store}
#'   \item{category}{category of products}
#'   \item{category_link}{link to the category in a store}
#'   \item{category_image_link}{link to category image}
#'   \item{store_link}{link to the store}
#' }
#'
#' @name eg_category
#' @usage data(eg_category)
#'
#' @source \url{https://www.elgrocer.com}
"eg_category"

#' Product subcategories available in different grocery stores
#'
#' A dataset containing 1,156 product subcategories chosen randomly from 300
#' categories in different grocery stores.
#'
#' @format A data frame with 156 rows and 3 variables:
#' \describe{
#'   \item{subcategory}{subcategory of products}
#'   \item{subcategory_link}{link to the subcategory in a store}
#'   \item{category_link}{link to the category in a store}
#' }
#'
#' @name eg_subcategory
#' @usage data(eg_subcategory)
#'
#' @source \url{https://www.elgrocer.com}
"eg_subcategory"

#' Details for 15,459 grocery products
#'
#' A dataset containing the name, weight, price and image link of more
#' than 15,000 grocery products.
#'
#' @format A data frame with 15,459 rows and 5 variables:
#' \describe{
#'   \item{subcategory_link}{link to the subcategory in a store}
#'   \item{item}{product name}
#'   \item{weight}{product weight}
#'   \item{price}{product price, in GPB}
#'   \item{item_image_link}{link to product image}
#' }
#'
#' @name eg_product
#' @usage data(eg_product)
#'
#' @source \url{https://www.elgrocer.com}
"eg_product"

#' Details for over 15,000 grocery products
#'
#' A dataset containing the names and other attributes of over 15,000 grocery
#' products. This table was built by joining \emph{eg_product},
#' \emph{eg_subcategory} and \emph{eg_category}.
#'
#' @format A data frame with 15,459 rows and 9 variables:
#' \describe{
#'   \item{store_name}{name of the store}
#'   \item{category}{category of products}
#'   \item{subcategory}{subcategory of products}
#'   \item{item}{product name}
#'   \item{weight}{product weight}
#'   \item{price}{product price, in GBP}
#'   \item{category_image_link}{link to category image}
#'   \item{item_image_link}{link to product image}
#'   \item{store_link}{link to the store}
#' }
#'
#' @name eg_data
#' @usage data(eg_data)
#'
#' @source \url{https://www.elgrocer.com}
"eg_data"

#' Grocery products categories
#'
#' A dataset containing 13 category names and links.
#'
#' @format A data frame with 13 rows and 2 variables:
#' \describe{
#'   \item{category}{category of products}
#'   \item{category_link}{link to the category}
#' }
#'
#' @name oc_category
#' @usage data(oc_category)
#'
#' @source \url{https://www.ocado.com}
"oc_category"

#' General information for 8,920 grocery products
#'
#' A dataset containing the general information for almost 9,000 grocery
#' products.
#'
#' @format A data frame with 8,920 rows and 7 variables:
#' \describe{
#'   \item{product}{product name}
#'   \item{weight}{product weight}
#'   \item{price}{product price}
#'   \item{shelf_life}{product shelf life time}
#'   \item{image_link}{link to product image}
#'   \item{product_link}{link to product}
#'   \item{category_link}{link to category}
#' }
#'
#' @name oc_product_general
#' @usage data(oc_product_general)
#'
#' @source \url{https://www.ocado.com}
"oc_product_general"

#' Extra information for 992 grocery products
#'
#' A dataset containing extra information (e.g., rating, brand)
#' for almost 1,000 grocery products.
#'
#' @format A data frame with 992 rows and 8 variables:
#' \describe{
#'   \item{product_link}{link to product}
#'   \item{badge}{organic, vegetarian, freezing, microwave status of product}
#'   \item{ingredient}{product ingredients}
#'   \item{brand}{product brand}
#'   \item{country}{product country of origin}
#'   \item{rating}{product rating}
#'   \item{num_of_reviews}{number of reviews for product}
#'   \item{recommend}{percent of customers that recommend product}
#' }
#'
#' @name oc_product_extra
#' @usage data(oc_product_extra)
#'
#' @source \url{https://www.ocado.com}
"oc_product_extra"

#' Reviews for 944 grocery products
#'
#' A dataset containing the reviews for almost 1,000 grocery products.
#'
#' @format A data frame with 944 rows and 2 variables:
#' \describe{
#'   \item{product_link}{link to product}
#'   \item{reviews}{text reviews for product}
#' }
#'
#' @name oc_product_review
#' @usage data(oc_product_review)
#'
#' @source \url{https://www.ocado.com}
"oc_product_review"

#' Nutrition table of 992 grocery products
#'
#' A dataset containing the nutrition tables for almost 1,000 grocery products.
#'
#' @format A data frame with 992 rows and 2 variables:
#' \describe{
#'   \item{product_link}{link to product}
#'   \item{nutrition}{nutrition table for product}
#' }
#'
#' @name oc_nutrition_table
#' @usage data(oc_nutrition_table)
#'
#' @source \url{https://www.ocado.com}
"oc_nutrition_table"

#' Details for 8,920 grocery products
#'
#' A dataset containing the names and other attributes of almost 9,000 grocery
#' products. This table was built by joining \emph{oc_product_general},
#' \emph{oc_product_extra}, \emph{oc_category}, and \emph{oc_product_review}
#' and \emph{oc_nutrition_table}.
#'
#' @format A data frame with 8,920 rows and 17 variables:
#' \describe{
#'   \item{category}{category of products}
#'   \item{brand}{product brand}
#'   \item{product}{product name}
#'   \item{price}{product price}
#'   \item{weight}{product weight}
#'   \item{badge}{organic, vegetarian, freezing, microwave status of product}
#'   \item{shelf_life}{product shelf life time}
#'   \item{country}{product country of origin}
#'   \item{rating}{product rating}
#'   \item{num_of_reviews}{number of reviews for product}
#'   \item{recommend}{percent of customers that recommend product}
#'   \item{ingredient}{product ingredients}
#'   \item{reviews}{text reviews for product}
#'   \item{nutrition}{nutrition table for product}
#'   \item{image_link}{link to product image}
#'   \item{product_link}{link to product}
#'   \item{category_link}{link to category}
#' }
#'
#' @name oc_data
#' @usage data(oc_data)
#'
#' @source \url{https://www.ocado.com}
"oc_data"

#' Customer database (4,996 customers)
#'
#' A dataset containing customer id, name, age, household size and location.
#' Almost 5,000 customer entries were randomly generated with the help of
#' the packages \emph{charlatan}, \emph{fabricatr}, \emph{randomNames}
#' and \emph{wakefield}.
#'
#' Not all of the customers necessarily placed an order. For example, some
#' customers might have signed up (i.e., input their name,
#' email address, age, location, etc) and browsed the app, causing
#' them to be added to the customers' database, but they never actually
#' completed checkout, so there is no order with their customer id in
#' the \emph{order_db_funmart} table.
#'
#' @format A data frame with 4,996 rows and 6 variables:
#' \describe{
#'   \item{customer_id}{unique customer id}
#'   \item{customer_name}{customer name generated via \emph{randomNames}}
#'   \item{customer_age}{customer age generated via \emph{wakefield}, 18 to 75}
#'   \item{household_size}{household size generated via \emph{wakefield}, 1 to 7}
#'   \item{long}{longitude of customers' delivery address in the UAE
#'   generated via \emph{charlatan}}
#'   \item{lat}{latitude of customers' delivery address in the UAE
#'   generated via \emph{charlatan}}
#' }
#'
#' @name customer_db_funmart
#' @usage data(customer_db_funmart)
"customer_db_funmart"

#' Order database (12,000 orders)
#'
#' A dataset containing order id, customer id, order date, payment method
#' and order time. 12,000 orders were randomly generated with the help of
#' the packages \emph{fabricatr} and \emph{wakefield}. Not every customer
#' from the \emph{customer_db_funmart} table might have placed an order.
#'
#' For example, some customers might have signed up (i.e., input their name,
#' email address, age, location, etc) and browsed the app, causing
#' them to be added to the customers' database, but they never actually
#' completed checkout, so there is no order with their customer id in
#' the \emph{order_db_funmart} table.
#'
#' @format A data frame with 12,500 rows and 6 variables:
#' \describe{
#'   \item{order_id}{unique order id}
#'   \item{customer_id}{customer id foreign key related to \emph{customer_db_funmart}}
#'   \item{order_date}{order date}
#'   \item{order_time}{order time}
#'   \item{payment_method}{1 of 3 methods used to pay for the order}
#'   \item{store}{grocery store}
#' }
#'
#' @name order_db_funmart
#' @usage data(order_db_funmart)
"order_db_funmart"

#' Grocery basket database (144,159 line items)
#'
#' A dataset containing basket id, order id, products purchased in each basket
#' and price of products. There were 200 products, with different
#' probabilities for each, to select from in the fake grocery
#' store, 'funmart'. Over 140,000 products were bought in all baskets
#' combined. The customer ids were sampled
#' from the \emph{order_db_funmart} table (not \emph{customer_db_funmart})
#' to ensure that only customers that actually placed an order appear
#' in the \emph{basket_db_funmart} table.
#'
#' The product names and prices were collected
#' from \url{https://www.ocado.com} and \url{https://www.elgrocer.com}.
#'
#' @format A data frame with 144,159 rows and 4 variables:
#' \describe{
#'   \item{basket_id}{unique basket id}
#'   \item{order_id}{order id foreign key related to \emph{order_db_funmart}}
#'   \item{product}{product name}
#'   \item{price}{product price}
#' }
#'
#' @name basket_db_funmart
#' @usage data(basket_db_funmart)
"basket_db_funmart"

#' Grocery data ready for analysis (12,000 orders)
#'
#' A dataset created by joining the 3 databases associated with this package:
#' \emph{customer_db_funmart}, \emph{order_db_funmart}
#' and \emph{basket_db_funmart}. View the example section below to see how
#' this dataset was created.
#'
#' The product names and prices were collected
#' from \url{https://www.ocado.com} and \url{https://www.elgrocer.com}.
#'
#' @format A data frame with 12,000 rows and 13 variables:
#' \describe{
#'   \item{basket_id}{unique basket id}
#'   \item{order_id}{order id foreign key related to \emph{order_db_funmart}}
#'   \item{cost}{total price of an order}
#'   \item{customer_id}{unique customer id}
#'   \item{order_date}{order date}
#'   \item{order_time}{order time}
#'   \item{payment_method}{1 of 3 methods used to pay for the order}
#'   \item{store}{grocery store}
#'   \item{customer_name}{customer name generated via \emph{randomNames}}
#'   \item{customer_age}{customer age generated via \emph{wakefield}, 18 to 75}
#'   \item{household_size}{household size generated via \emph{wakefield}, 1 to 7}
#'   \item{long}{longitude of customers' delivery address in the UAE
#'   generated via \emph{charlatan}}
#'   \item{lat}{latitude of customers' delivery address in the UAE
#'   generated via \emph{charlatan}}
#' }
#'
#' @name grocery_data
#' @usage data(grocery_data)
#'
#' @seealso
#' \code{\link{customer_db_funmart}}, \code{\link{order_db_funmart}},
#' and \code{\link{basket_db_funmart}}.
#'
#' @examples
#' \dontrun{
#' grocery_data <-
#' basket_db_funmart %>%
#' group_by(basket_id, order_id) %>%
#' summarise(cost = sum(price)) %>%
#' ungroup() %>%
#' inner_join(order_db_funmart, by = "order_id") %>%
#' inner_join(customer_db_funmart, by = "customer_id")
#' }
"grocery_data"
