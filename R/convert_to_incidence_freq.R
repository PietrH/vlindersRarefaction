#' Convert a known input format to the incidence frequency format that iNEXT expects
#'
#' iNEXT expects incidence frequency data to be a list, with one child per
#' assemblage. Every child of this list starts with an integer equal to the
#' total number of sampling units (days, plots, ...), followed by one element
#' per species equal to the number of sampling units this species was observed
#' in.
#'
#' @param input_dataframe dataframe with exactly the same columns as `tblWarandepark.csv`
#'
#' @return a list in the format as is expected by iNEXT when datatype is set to incidence_freq
#' @export
#'
#' @examples \dontrun{convert_to_incidence_freq(warande)}
convert_to_incidence_freq <- function(input_dataframe) {
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
  ## MicroMacro can only have Macro or Micro as values
  assertthat::assert_that(
    setequal(unique(input_dataframe$MicroMacro), c("Macro", "Micro")),
    msg = "the column `MicroMacro` can only have the values `Macro` or `Micro`"
  )


    # output should be a list, with the first element the number of sampling
    # units (how often did you look? howmany plots/days), and then elements
    # every element is a species en in howmany of the sampling units they were
    # found


  # group input dataframe ---------------------------------------------------

  grouped_df <- input_dataframe %>% dplyr::group_by(MicroMacro)



  # calculate number of sampling units --------------------------------------

  number_of_sampling_units <-
    grouped_df %>%
      dplyr::group_map(~dplyr::n_distinct(dplyr::pull(.x,date))) %>%
      purrr::set_names(c("Macro", "Micro"))


  # calculate incidence frequencies -----------------------------------------

  incidence_frequencies <-
    grouped_df %>%
      dplyr::group_map(~dplyr::count(.x, species_name)) %>%
      purrr::map(~dplyr::pull(.x, n)) %>%
      purrr::set_names(c("Macro", "Micro"))


  # combine into output obj -------------------------------------------------

  list(
    Macro = c(number_of_sampling_units$Macro, incidence_frequencies$Macro),
    Micro = c(number_of_sampling_units$Micro, incidence_frequencies$Micro)
  )

}
