warande <-
  readr::read_delim("../../tblWarandepark.csv",
                    delim = ";",
                    show_col_types = FALSE)

test_that("convert_to_abundance() returns right amount of species", {
  number_of_macro_species <-
    dplyr::filter(warande, MicroMacro == "Macro") %>%
    dplyr::pull(species_name) %>%
    dplyr::n_distinct()
  number_of_micro_species <-
    dplyr::filter(warande, MicroMacro == "Micro") %>%
    dplyr::pull(species_name) %>%
    dplyr::n_distinct()

  expect_identical(
    length(convert_to_abundance(warande)$Macro),
    number_of_macro_species
  )

  expect_identical(
    length(convert_to_abundance(warande)$Micro),
    number_of_micro_species
  )
})

test_that("convert_to_abundance() returns right amount of individuals", {
 observed_individuals <-
   dplyr::group_by(warande, MicroMacro) %>%
   dplyr::summarise(total_obs_ind = sum(number))

 expect_identical(
   sum(convert_to_abundance(warande)$Macro),
       dplyr::filter(observed_individuals,MicroMacro == "Macro")$total_obs_ind)


 expect_identical(
   sum(convert_to_abundance(warande)$Micro),
       dplyr::filter(observed_individuals,MicroMacro == "Micro")$total_obs_ind)

})
