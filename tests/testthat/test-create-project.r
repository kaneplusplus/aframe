test_that("Analysis framework creation works.", {

  source("reference.r")

  expect_true(af_create_project("test-project-1", setwd = TRUE))

  expect_true(af_is_proj())
  
  expect_false(af_is_analysis())

  #expect_equal(af_ptree(), character())

  expect_error(af_atree())

  af_create_analysis("study-1", setwd = TRUE)

  af_create_component("data", setwd = TRUE)

  #expect_error(af_create_component("../../clean-data"))

  #af_create_component("../study-1/clean-data")

#  write_if_make_reference(site_yaml, "site_yaml.rds")

#  expect_equal(site_yaml, read_reference("site_yaml.rds"))
})
