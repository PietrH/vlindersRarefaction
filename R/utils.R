#' Helper to check if input is exactly as expected csv
#'
#' @param input_dataframe
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
