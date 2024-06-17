data(warande)

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
    length(convert_to_abundance(warande, MicroMacro)$Macro),
    number_of_macro_species
  )

  expect_identical(
    length(convert_to_abundance(warande, MicroMacro)$Micro),
    number_of_micro_species
  )
})

test_that("convert_to_abundance() returns right amount of individuals", {
 observed_individuals <-
   dplyr::group_by(warande, MicroMacro) %>%
   dplyr::summarise(total_obs_ind = sum(number))

 expect_identical(
   sum(convert_to_abundance(warande, MicroMacro)$Macro),
       dplyr::filter(observed_individuals,MicroMacro == "Macro")$total_obs_ind)


 expect_identical(
   sum(convert_to_abundance(warande, MicroMacro)$Micro),
       dplyr::filter(observed_individuals,MicroMacro == "Micro")$total_obs_ind)

})

test_that("convert_to_abundance() should return unnamed list when no assemblage is provided", {
  expect_named(
    convert_to_abundance(warande),
    NULL
  )
  })

test_that("convert_to_abundance() returns named list of new column when provided as assemblage", {
  warande_gebied <-
    warande %>%
    dplyr::mutate(gebied =
                    sample(
                      c("geb_a", "geb_b"),
                      nrow(warande),
                      replace = TRUE
                    )
    )

  expect_named(
    convert_to_abundance(warande_gebied, gebied),
    c("geb_a","geb_b")
  )
})
