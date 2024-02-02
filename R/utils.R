#' Helper to check if input is exactly as expected csv
#'
#' @param input_dataframe csv with exactly the same columns as `tblWarandepark.csv`
#'
#' @return TRUE if all is well
#'
check_input_file <- function(input_dataframe) {
  # assert that the input has the expected shape

  ## the right datatype
  assertthat::assert_that(is.data.frame(input_dataframe))
  ## the right columns
  assertthat::assert_that(setequal(
    colnames(input_dataframe),
    c("date", "species_name", "year", "number", "MicroMacro")
  ), msg = glue::glue(
    "The columns in `input_dataframe` don't match the expected columns:",
    "we expected: {expected_columns_sep}", " but found: {actual_columns_sep}",
    expected_columns_sep =
      glue::glue_collapse(
        glue::backtick(
          "date",
          "species_name",
          "year",
          "number",
          "MicroMacro"
        ),
        sep = ",", last = "&"
      ),
    actual_columns_sep =
      glue::glue_collapse(
        glue::backtick(colnames(input_dataframe)),
        sep = ",", last = "&"
      )
  ))
}

#' Helper to get values from dplyr groups
#'
#' Extension on dplyr::group_data()
#' @inheritParams dplyr::group_data
#'
#' @return Character vector containing the values of the groups in `.data`
#'
#' @noRd
#' @examples
#' # example code
#' warande %>% dplyr::group_by(MicroMacro) %>% group_values()
group_values <- function(.data) {
  dplyr::group_data(.data) %>%
    dplyr::pull(1)
}
