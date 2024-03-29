% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{oc_product_extra}
\alias{oc_product_extra}
\title{Extra information for 992 grocery products}
\format{
A data frame with 992 rows and 8 variables:
\describe{
\item{product_link}{link to product}
\item{badge}{organic, vegetarian, freezing, microwave status of product}
\item{ingredient}{product ingredients}
\item{brand}{product brand}
\item{country}{product country of origin}
\item{rating}{product rating}
\item{num_of_reviews}{number of reviews for product}
\item{recommend}{percent of customers that recommend product}
}
}
\source{
\url{https://www.ocado.com}
}
\usage{
data(oc_product_extra)
}
\description{
A dataset containing extra information (e.g., rating, brand)
for almost 1,000 grocery products.
}
\keyword{datasets}
