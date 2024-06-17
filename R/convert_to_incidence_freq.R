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
#' @return a list of vectors in the format as is expected by iNEXT when datatype is set to incidence_freq
#' @export
#'
#' @examples \dontrun{
#' convert_to_incidence_freq(warande, MicroMacro)
#' }
convert_to_incidence_freq <- function(input_dataframe, assemblage = NULL) {
  # assert that the input has the expected shape
  check_input_file(input_dataframe)

  # output should be a list, with the first element the number of sampling
  # units (how often did you look? howmany plots/days), and then elements
  # every element is a species en in howmany of the sampling units they were
  # found

  # handle case where no assemblage was provided ----------------------------

  if (is.null(assemblage)) {
    ## calculate number of sampling units --------------------------------------
    number_of_sampling_units <-
      dplyr::n_distinct(dplyr::pull(input_dataframe, date))
    ## calculate incidence frequencies -----------------------------------------
    incidence_frequencies <-
      dplyr::count(input_dataframe, species_name) %>%
      dplyr::pull(n)
    ## combine into output obj -------------------------------------------------
    list(c(number_of_sampling_units, incidence_frequencies)) %>%
      return()
  }
  # handle case where assemblage is provided --------------------------------


  ## group input dataframe ---------------------------------------------------

  grouped_df <- dplyr::group_by(input_dataframe, {{assemblage}})

  ## calculate number of sampling units --------------------------------------

  number_of_sampling_units <-
    grouped_df %>%
    dplyr::group_map(~ dplyr::n_distinct(dplyr::pull(.x, date))) %>%
    purrr::set_names(group_values(grouped_df))

  ## calculate incidence frequencies -----------------------------------------

  incidence_frequencies <-
    grouped_df %>%
    dplyr::group_map(~ dplyr::count(.x, species_name)) %>%
    purrr::map(~ dplyr::pull(.x, n)) %>%
    purrr::set_names(group_values(grouped_df))

  ## combine into output obj -------------------------------------------------

  # Take the values in the variable to group by, and look up the number of
  # sampling units and incidence frequencies for them. Combine them into a list
  # and name the elements after the values
  output_object <-
    group_values(grouped_df) %>%
    purrr::map(~ c(
      purrr::chuck(number_of_sampling_units, .x),
      purrr::chuck(incidence_frequencies, .x)
    )) %>%
    purrr::set_names(group_values(grouped_df))

    if (is.null(assemblage)) {
      # if assemblage was not provided, we are still grouping but place everything
      # in a single group with a dummy value, but we don't need to keep this dummy
      # value in the output
      return(unname(output_object))
    } else {
      (
        return(output_object)
      )
    }

}
