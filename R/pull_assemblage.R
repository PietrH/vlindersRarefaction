#' Function to learn how to use data masking
#'
#' @param input_dataframe the input dataframe
#' @param assemblage the variable to group by
#'
#' @return assemblage values
#' @export
#'
pull_assemblage <- function(input_dataframe, assemblage = NULL) {
  # dplyr::pull(input_dataframe, {{assemblage}})
  dplyr::group_by(input_dataframe, {{assemblage}})
}
