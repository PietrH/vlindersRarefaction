#' Convert a known input format to the individual based abundance format that iNEXT expects
#'
#' iNEXT expects `abundance` based data to be a list, with one child per
#' treatment/assemblage where the length of every child is equal to the number
#' of species in that treatment, and the sum of every child equal to the total
#' number of observed individuals.
#'
#' @param input_dataframe dataframe with exactly the same columns as `tblWarandepark.csv`
#' @param assemblage variable in `input_dataframe` to group by.
#' Every value in this column will result in a seperate curve in the iNEXT output.
#'
#' @return a list in the format as is expected by iNEXT when datatype is set to abundance
#' @export
#'
#' @examples \dontrun{convert_to_abundance(warande, MicroMacro)}
convert_to_abundance <- function(input_dataframe, assemblage) {
  # assert that the input has the expected shape
  check_input_file(input_dataframe)

  # group input dataframe ---------------------------------------------------

  grouped_df <- dplyr::group_by(input_dataframe, {{assemblage}})


  # calculate individual based abundance ------------------------------------

  output_object <-
    grouped_df %>%
    dplyr::group_by(.data$species_name, .add = TRUE) %>%
    dplyr::summarise(obs_ind = sum(.data$number), .keep = TRUE) %>%
    dplyr::group_map(~dplyr::pull(.x, obs_ind))

  # handle case where no assemblage was provided ----------------------------
  if(missing(assemblage)){
    return(output_object)
  } else {

  # add names to groups when assemblage is provided -------------------------
    return(
      purrr::set_names(output_object,
                       group_values(grouped_df))
    )
  }
}
