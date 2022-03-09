#' Names of 131 locations in UAE.
#'
#' A dataset contianing the names and links of 131 locations that have grocery
#' stores that provide online delivery services.
#'
#' @format A data frame with 131 rows and 2 variables:
#' \describe{
#'   \item{location}{name of location in UAE}
#'   \item{location_link}{link to view stores in location}
#' }
#' @source \url{https://www.elgrocer.com}
"eg_location"

#' Grocery stores that provide online delivery services.
#'
#' A dataset containing details for 184 grocery stores that provide online
#' delivery services.
#'
#' @format A data frame with 184 rows and 11 variables:
#' \describe{
#'   \item{location}{name of location in UAE}
#'   \item{city}{name of city in UAE}
#'   \item{store_name}{name of the store}
#'   \item{min_order_amount}{minimum order amount to qualify for delivery, in AED}
#'   \item{delivery_within}{time interval for delivery after placing order}
#'   \item{delivery_start}{time delivery service begins for the day}
#'   \item{delivery_end}{time delivery service ends for the day}
#'   \item{delivery_timezone}{timezone}
#'   \item{payment_method}{available payment methods}
#'   \item{store_link}{link to the store}
#'   \item{location_link}{link to view stores in location}
#' }
#' @source \url{https://www.elgrocer.com}
"eg_store"

#' Product categories available in different grocery stores.
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
#' @source \url{https://www.elgrocer.com}
"eg_category"

#' Product subcategories available in different grocery stores.
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
#' @source \url{https://www.elgrocer.com}
"eg_subcategory"

#' Details for 15,459 grocery products.
#'
#' A dataset containing the name, weight, price and image link of more
#' than 15,000 grocery products.
#'
#' @format A data frame with 15,459 rows and 5 variables:
#' \describe{
#'   \item{subcategory_link}{link to the subcategory in a store}
#'   \item{item}{product name}
#'   \item{weight}{product weight}
#'   \item{price}{product price, in AED}
#'   \item{item_image_link}{link to product image}
#' }
#' @source \url{https://www.elgrocer.com}
"eg_product"

#' Details for over 15,000 grocery products.
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
#'   \item{price}{product price, in AED}
#'   \item{category_image_link}{link to category image}
#'   \item{item_image_link}{link to product image}
#'   \item{store_link}{link to the store}
#' }
#' @source \url{https://www.elgrocer.com}
"eg_data"

#' Grocery products categories.
#'
#' A dataset containing 13 category names and links.
#'
#' @format A data frame with 13 rows and 2 variables:
#' \describe{
#'   \item{category}{category of products}
#'   \item{category_link}{link to the category}
#' }
#' @source \url{https://www.ocado.com}
"oc_category"

#' General information for 8,920 grocery products.
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
#' @source \url{https://www.ocado.com}
"oc_product_general"

#' Extra information for 992 grocery products.
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
#' @source \url{https://www.ocado.com}
"oc_product_extra"

#' Reviews for 944 grocery products.
#'
#' A dataset containing the reviews for almost 1,000 grocery products.
#'
#' @format A data frame with 944 rows and 2 variables:
#' \describe{
#'   \item{product_link}{link to product}
#'   \item{reviews}{text reviews for product}
#' }
#' @source \url{https://www.ocado.com}
"oc_product_review"

#' Nutrition table of 992 grocery products.
#'
#' A dataset containing the nutrition tables for almost 1,000 grocery products.
#'
#' @format A data frame with 992 rows and 2 variables:
#' \describe{
#'   \item{product_link}{link to product}
#'   \item{nutrition}{nutrition table for product}
#' }
#' @source \url{https://www.ocado.com}
"oc_nutrition_table"

#' Details for 8,920 grocery products.
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
#' @source \url{https://www.ocado.com}
"oc_data"