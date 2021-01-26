load("./inst/cdm_tables.RData")
diabetes <- readr::read_csv("./inst/diabetes_caliber.csv", col_types = "ccc")
usethis::use_data(cdm, diabetes, internal = TRUE, overwrite = TRUE)
