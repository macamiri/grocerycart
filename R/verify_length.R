#' Verify that elgrocer output length from selenium & rvest match - 2 objects
#'
#' @param sel selenium output length
#' @param rve rvest output length
#'
#' @return logical
#'
#' @export
verify_eg_length_match <- function(sel, rve) {
  if(sel == rve) {
    cat(crayon::green("Success! Lengths match: ",  rve, "\n"))
  } else {
    stop(crayon::red("Go Back! Lengths match DO NOT match:\n",
                     "From selenium:", sel, "\n",
                     "From rvest:", rve))
  }
}

#' @rdname verify_eg_length_match
#'
#' @param obj1 titles output length
#' @param obj2 weights output length
#' @param obj3 prices output length
#' @param obj4 images output length
#' @param obj5 links output length
#'
#' @return logical
#'
#' @export
verify_oc_length_match <- function(obj1, obj2, obj3, obj4, obj5) {
  if(obj1 == obj2 && obj2 == obj3 && obj3 == obj4 && obj4 == obj5) {
    cat(crayon::green("Success! All 5 lengths match: ",
                      obj1,
                      "items found", "\n"))
  } else {
    stop(crayon::red("Go Back! Lengths match DO NOT match:\n",
                     "Title:", obj1, "\n",
                     "Weight:", obj2, "\n",
                     "Price:", obj3, "\n",
                     "Images:", obj4, "\n",
                     "Links:", obj5, "\n"))
  }
}
