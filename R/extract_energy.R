#' Extract the energy content of a product from the nutrition table
#'
#' Helper function to extra the energy content (e.g., kcal or kJ) from the
#' nutrition table of a product that was collected from the
#' \emph{oc_collect_nutrition_table} function.
#'
#' @param data Dataset that includes product and nutrition information.
#' @param item Product name column.
#' @param nutrition Nutrition table column.
#'
#' @return A tibble with product name and energy content, if available.
#' @export
#'
#' @seealso
#' \code{\link{oc_collect_nutrition_table}}
extract_energy <- function(data, item, nutrition) {

  oc_energy <-
    data %>%
    dplyr::select({{ item }}, {{ nutrition }})

  along <- 1:length(oc_energy$product)

  along %>%
    purrr::map_dfr(., function(.x) {
      tryCatch(
        expr = {

          product <-
            oc_energy %>%
            purrr::pluck(1) %>%
            purrr::pluck(.x)

          energy <-
            oc_energy %>%
            purrr::pluck(2) %>%
            purrr::pluck(.x) %>%
            dplyr::filter(stringr::str_detect(`Typical Values`,
                                              stringr::regex("energy(\\skcal)?", ignore_case = TRUE))) %>%
            dplyr::select(2) %>%
            .[[1, 1]] %>%
            as.character()

          cat(crayon::blue("Completed ", .x, "\n"))

          tibble::tibble(
            product = product,
            energy = energy
          )
        },
        error = function(e) {}
      )
    })
}

#' @rdname extract_energy
#'
#' @description Helper function to convert the energy content
#' (e.g., kcal or kJ) extracted from \emph{extract_energy} function
#' into kcal unit.
#'
#' @param data Output from \emph{extract_energy} function
#'
#' @return A tibble with product name, energy content (if available)
#' and energy content converted into kcal unit.
#' @export
extract_kcal <- function(data) {
  data %>%
    dplyr::mutate(energy = stringr::str_replace_all(energy, " ", ""),
                  kcal = purrr::map_chr(energy, function(.x) {
                    if(!is.na(.x)) {
                      if(stringr::str_detect(.x, "\\d$")) {
                        if(!is.na(as.numeric(.x) / 4.184)) {
                          as.numeric(.x) / 4.184
                        } else {
                          stringr::str_extract(.x, "(?<=/)\\d+")
                        }
                      } else if(stringr::str_detect(.x, "kcal")) {
                        stringr::str_extract(.x, "\\d+\\.\\d+(?=kcal)|\\d+(?=kcal)")
                      } else if(stringr::str_detect(.x, "\\d(?=(k|K)J$)")) {
                        as.numeric(stringr::str_extract(.x, "\\d+|\\d+\\.\\d+(?=kJ$)")) / 4.184
                      } else if(stringr::str_detect(.x, "\\)$")) {
                        stringr::str_extract(.x, "(?<=\\()\\d+(?=\\))")
                      } else {
                        NA
                      }
                    } else {
                      NA
                    }
                  }))
}
