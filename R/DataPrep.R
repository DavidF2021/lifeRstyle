# Load packages
library(csodata)
library(dplyr)
library(readr)
library(ggplot2)
library(lme4) # For fitting mixed models


# Function to download and clean any table from csodata
download_and_clean_cso <- function(table_id,
                                   dest_file = NULL,
                                   filter_sex = "Both sexes",
                                   filter_age = "All ages",
                                   filter_years = c("2019", "2020", "2025")) {
  message("Downloading table: ", table_id)

  # Download table from CSO (tall gives long dataframe)
  df <- cso_get_data(table_id, pivot_format = "tall")
  message("Downloaded table has ", nrow(df), " rows and ", ncol(df), " columns.")

  # Inspect column names (If table structure changes)
  print(colnames(df))

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
                                       filter_years = c("2019","2020","2025"),
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
his15_cleaned <- download_and_clean_cso(
  table_id = "HIS15",
  dest_file = "data/clean/HIS15_cleaned.csv"
)

#View first few rows
head(his15_cleaned)

#For HIS09
his09_cleaned <- download_and_clean_cso(
  table_id = "HIS09",
  dest_file = "data/clean/HIS09_cleaned.csv"
)

#View first few rows
head(his09_cleaned)

#For HIS01
his01_cleaned <- download_and_clean_cso(
  table_id = "HIS01",
  dest_file = "data/clean/HIS01_cleaned.csv"
)
head(his01_cleaned)

#For HSPAO11
HSPAO11_cleaned <- download_and_clean_cso(
  table_id = "HSPAO11",
  dest_file = "data/clean/HSPAO11_cleaned.csv"
)

#Combined function
tables <- c("HIS15", "HIS01", "HIS09", "HSPAO11")  # Add more tables as needed
data_list <- download_clean_combine_cso(tables)

# Access individual cleaned tables
his15 <- data_list$individual$HIS15
his01 <- data_list$individual$HIS01

# Access combined dataset
combined_data <- data_list$combined

colnames(combined_data) #View columns
head(combined_data) #View rows
View(combined_data) #View dataset


##Plots
# Histogram by table
ggplot(combined_data, aes(x = value, fill = table_id)) +
  geom_histogram(binwidth = 10, color = "white") +
  facet_wrap(~table_id, scales = "free") +
  labs(title = "Histogram of Combined Tables",
       x = "Value",
       y = "Count") +
  theme_minimal()

#Boxplot of combined dataset
ggplot(combined_data, aes(x = table_id, y = value, fill = table_id)) +
  geom_boxplot() +
  labs(title = "Boxplot of Values by Table",
       x = "Table",
       y = "Value") +
  theme_minimal()


##Modelling
#lm to display how Sex, Year, Age Group influence values.
lm_model <- lm(value ~ Sex + Age.Group + Year, data = his15)
summary(lm_model)

#One-way ANOVA for Age Group
#Comparing age groups
anova_model <- aov(value ~ Age.Group, data = his15)
summary(anova_model)


#Mixed Effects model for fixed and random effects
mixed_model <- lmer(value ~ Sex + Age.Group + (1|table_id), data = combined_data)
summary(mixed_model)





