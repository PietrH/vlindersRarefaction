#' Convert a known input format to the individual based abundance format that iNEXT expects
#'
#' iNEXT expects `abundance` based data to be a list, with one child per
#' treatment/assemblage where the length of every child is equal to the number
#' of species in that treatment, and the sum of every child equal to the total
#' number of observed individuals.
#'
#' @param input_dataframe
#'
#' @return a list in the format as is expected by iNEXT when datatype is set to abundance
#' @export
#'
#' @examples \dontrun{convert_to_abundance(warande)}
convert_to_abundance <- function(input_dataframe) {
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

  # group input dataframe ---------------------------------------------------

  grouped_df <- input_dataframe %>% dplyr::group_by(MicroMacro)


  # calculate individual based abundance ------------------------------------

  # grouped_df %>%
  #   dplyr::count(species_name) %>%
  #   dplyr::group_split() %>%
  #   purrr::map(~dplyr::pull(.x, n)) %>%
  #   purrr::set_names(c("Macro", "Micro"))

  grouped_df %>%
    dplyr::group_by(species_name, .add = TRUE) %>%
    dplyr::summarise(obs_ind = sum(number)) %>%
    dplyr::group_by(MicroMacro, .add = FALSE) %>%
    dplyr::group_map(~dplyr::pull(.x, obs_ind)) %>%
    purrr::set_names(c("Macro", "Micro"))
}
