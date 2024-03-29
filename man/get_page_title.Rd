% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_page_title.R
\name{get_page_title}
\alias{get_page_title}
\alias{current_url}
\title{Get the title of the current page}
\usage{
get_page_title(remDr)

current_url(remDr)
}
\arguments{
\item{remDr}{Remote client driver}
}
\value{
A character string
}
\description{
Get the title of the current page
}
\examples{
\dontrun{
# Initiate server
remDr <- RSelenium::rsDriver(port = netstat::free_port(),
browser = "firefox", verbose = FALSE)$client

# Navigate to webpage & get title
remDr$navigate("https://duckduckgo.com")
get_page_title(remDr = remDr)

# Close the server
remDr$close()
gc(remDr)
rm(remDr)
}
}
