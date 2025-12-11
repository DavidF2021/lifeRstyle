# Load packages
library(csodata)
library(dplyr)
library(readr)
library(ggplot2)
library(lme4) # For fitting mixed models


# Function to download and clean any table from csodata
#' Loads in and cleans any specified table from the CSO
#'
#' @param table_id
#' @param dest_file
#' @param filter_sex
#' @param filter_age
#' @param filter_years
#'
#' @returns
#' @export
#'
#' @examples
download_and_clean_cso <- function(table_id,
                                   dest_file = NULL,
                                   filter_sex = "Both sexes",
                                   filter_age = "All ages",
                                   filter_years = c("2019", "2020")) {
  message("Downloading table: ", table_id)

  # Download table from CSO (tall gives long dataframe)
  df <- cso_get_data(table_id, pivot_format = "tall")
  message("Downloaded table has ", nrow(df), " rows and ", ncol(df), " columns.")



  # Clean table: filter out Sex, Age.Group, Year
  df_cleaned <- df %>%
    filter(!Sex %in% filter_sex) %>%
    filter(!Age.Group %in% filter_age) %>%
    filter(!Year %in% filter_years)

  message("After cleaning: ", nrow(df_cleaned), " rows remain.")

  # Save to CSV
  if (!is.null(dest_file)) {
    if (!dir.exists(dirname(dest_file))) dir.create(dirname(dest_file), recursive = TRUE)
    readr::write_csv(df_cleaned, dest_file)
    message("Cleaned data saved to: ", dest_file)
  }

  return(df_cleaned)
}


#Function to download, clean, and optionally combine multiple CSO tables
download_clean_combine_cso <- function(table_ids,
                                       filter_sex = "Both sexes",
                                       filter_age = "All ages",
                                       filter_years = c("2019","2020"),
                                       combine = TRUE,
                                       save_dir = "data/clean") {
  if (!dir.exists(save_dir)) dir.create(save_dir, recursive = TRUE)

  #Download and clean each table
  cleaned_list <- lapply(table_ids, function(tid) {
    dest_file <- file.path(save_dir, paste0(tid, "_cleaned.csv"))
    df <- download_and_clean_cso(
      table_id = tid,
      dest_file = dest_file,
      filter_sex = filter_sex,
      filter_age = filter_age,
      filter_years = filter_years
    )
    return(df)
  })

  names(cleaned_list) <- table_ids

  #Combine datasets
  combined_df <- NULL
  if (combine) {
    combined_df <- dplyr::bind_rows(cleaned_list, .id = "table_id")
    combined_file <- file.path(save_dir, "combined_cleaned.csv")
    readr::write_csv(combined_df, combined_file)
    message("Saved combined cleaned dataset with ", nrow(combined_df), " rows.")
  }

  return(list(individual = cleaned_list, combined = combined_df))
}

#For HIS15
alcohol_cleaned <- download_and_clean_cso(
  table_id = "alcohol_cleaned",
  dest_file = "data/clean/alcohol_cleaned.csv"
)

#For HIS09
smoking_cleaned <- download_and_clean_cso(
  table_id = "smoking_cleaned",
  dest_file = "data/clean/smoking_cleaned.csv"
)

#For HIS01
health_cleaned <- download_and_clean_cso(
  table_id = "health",
  dest_file = "data/clean/health_cleaned.csv"
)


#Combined function
tables <- c("alcohol_cleaned", "health_cleaned", "smoking_cleaned")  # Add more tables as needed
data_list <- download_clean_combine_cso(tables)
