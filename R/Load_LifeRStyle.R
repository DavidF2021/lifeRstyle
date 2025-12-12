# Load packages
library(csodata)
library(dplyr)
library(readr)
library(ggplot2)
library(lme4) # For mixed models

# Function to download and clean any table from CSO
download_and_clean_cso <- function(table_id,
                                   dest_file = NULL,
                                   filter_sex = NULL,
                                   filter_age = NULL,
                                   filter_years = NULL) {
  message("Downloading table: ", table_id)

  # Download table from CSO (tall format)
  df <- cso_get_data(table_id, pivot_format = "tall")
  message("Downloaded table has ", nrow(df), " rows and ", ncol(df), " columns.")

  # Apply filters only if specified
  if (!is.null(filter_sex)) {
    df <- df %>% filter(Sex %in% filter_sex)
  }
  if (!is.null(filter_age)) {
    df <- df %>% filter(Age.Group %in% filter_age)
  }
  if (!is.null(filter_years)) {
    df <- df %>% filter(Year %in% filter_years)
  }

  message("After cleaning: ", nrow(df), " rows remain.")

  # Save to CSV if requested
  if (!is.null(dest_file)) {
    if (!dir.exists(dirname(dest_file))) dir.create(dirname(dest_file), recursive = TRUE)
    readr::write_csv(df, dest_file)
    message("Cleaned data saved to: ", dest_file)
  }

  return(df)
}

# Function to download, clean, and combine multiple CSO tables
download_clean_combine_cso <- function(table_ids,
                                       filter_sex = NULL,
                                       filter_age = NULL,
                                       filter_years = NULL,
                                       combine = TRUE,
                                       save_dir = "data/clean") {

  if (!dir.exists(save_dir)) dir.create(save_dir, recursive = TRUE)

  # Ensure table_ids have names
  if (is.null(names(table_ids))) {
    names(table_ids) <- table_ids
  }

  # Download and clean each table
  cleaned_list <- lapply(names(table_ids), function(name) {
    tid <- table_ids[[name]]
    dest_file <- file.path(save_dir, paste0(name, "_cleaned.csv"))
    df <- download_and_clean_cso(
      table_id = tid,
      dest_file = dest_file,
      filter_sex = filter_sex,
      filter_age = filter_age,
      filter_years = filter_years
    )
    return(df)
  })

  # Name the list properly
  names(cleaned_list) <- names(table_ids)

  # Combine if requested
  combined_df <- NULL
  if (combine) {
    combined_df <- dplyr::bind_rows(cleaned_list, .id = "table_name")
    combined_file <- file.path(save_dir, "combined_cleaned.csv")
    readr::write_csv(combined_df, combined_file)
    message("Saved combined cleaned dataset with ", nrow(combined_df), " rows.")
  }

  return(list(individual = cleaned_list, combined = combined_df))
}

# Example usage:

# Named vector of tables
tables <- c(alcohol = "HIS15", health = "HIS01", smoking = "HIS09")

# Download, clean, and combine
data_list <- download_clean_combine_cso(
  tables,
  filter_sex = NULL,   # set to c("Both sexes") if you want
  filter_age = NULL,   # set to c("All ages") if needed
  filter_years = NULL  # set to c("2019", "2020") if needed
)

# Access combined dataset
combined_data <- data_list$combined
dim(combined_data)
head(combined_data)
