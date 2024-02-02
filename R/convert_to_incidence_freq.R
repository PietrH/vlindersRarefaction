#' Convert a known input format to the incidence frequency format that iNEXT expects
#'
#' iNEXT expects incidence frequency data to be a list, with one child per
#' assemblage. Every child of this list starts with an integer equal to the
#' total number of sampling units (days, plots, ...), followed by one element
#' per species equal to the number of sampling units this species was observed
#' in.
#'
#' @param input_dataframe dataframe with exactly the same columns as `tblWarandepark.csv`
#' @param assemblage variable in `input_dataframe` to group by.
#' Every value in this column will result in a seperate curve in the iNEXT output.
#'
#' @return a list in the format as is expected by iNEXT when datatype is set to incidence_freq
#' @export
#'
#' @examples \dontrun{convert_to_incidence_freq(warande, MicroMacro)}
convert_to_incidence_freq <- function(input_dataframe, assemblage) {
  # assert that the input has the expected shape
  check_input_file(input_dataframe)

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

  grouped_df <- input_dataframe %>% dplyr::group_by({{assemblage}})



  # calculate number of sampling units --------------------------------------

  number_of_sampling_units <-
    grouped_df %>%
      dplyr::group_map(~dplyr::n_distinct(dplyr::pull(.x,date))) %>%
      purrr::set_names(group_values(.))


  # calculate incidence frequencies -----------------------------------------

  incidence_frequencies <-
    grouped_df %>%
      dplyr::group_map(~dplyr::count(.x, species_name)) %>%
      purrr::map(~dplyr::pull(.x, n)) %>%
      purrr::set_names(group_values(.))


  # combine into output obj -------------------------------------------------

  list(
    Macro = c(number_of_sampling_units$Macro, incidence_frequencies$Macro),
    Micro = c(number_of_sampling_units$Micro, incidence_frequencies$Micro)
  )

}
