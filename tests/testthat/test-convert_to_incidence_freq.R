data(warande)

test_that("convert_to_incidence_freq() returns number of sampling units in first element", {
  n_macro_sampling_units <-
    warande %>%
    dplyr::filter(MicroMacro == "Macro") %>%
    dplyr::pull(date) %>%
    dplyr::n_distinct()

  expect_identical(
    convert_to_incidence_freq(warande)$Macro[[1]],
    n_macro_sampling_units
  )
})

test_that("convert_to_incidence_freq() returns number of species + 1 as number of elements", {

  number_of_macro_species <-
    dplyr::filter(warande, MicroMacro == "Macro") %>%
    dplyr::pull(species_name) %>%
    dplyr::n_distinct() %>%
    as.double() # to match output of convert_to_incidence_freq()

  expect_identical(
    length(convert_to_incidence_freq(warande)$Macro) - 1,
    number_of_macro_species
  )
})
