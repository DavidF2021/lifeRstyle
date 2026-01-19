#' Download and clean any table from CSO
#'
#' This function downloads and cleans data downloaded from the CSO website.
#'
#'
#' @param table_id An array of numbers which corresponds to a specific data set on the CSO website.
#' @param dest_file The destination of the downloaded and cleaned data set.
#' @param filter_sex A parameter to filter the sex column of the data set.
#' @param filter_age A parameter to filter the age column of the data set.
#' @param filter_years A parameter to filter the years of which the data was.
#'
#' @returns An object of class \code{"lifeRstyle"} which is a list of \code{\link[tibble]{tibble}}s which
#' contain the downloaded and cleaned data from the CSO website.
#'
#' @importFrom dplyr "filter"
#' @importFrom readr "write_csv"
#' @importFrom magrittr %>%
#'
#' @examples
#' \dontrun{
#' alcohol <- download_and_clean_cso("HIS15_cleaned")
#' }
download_and_clean_cso <- function(table_id,
                                   dest_file = NULL,
                                   filter_sex = NULL,
                                   filter_age = NULL,
                                   filter_years = NULL) {

  if (missing(table_id) || !is.character(table_id) || length(table_id) != 1) {
    stop("table_id must be a single character string")
  }

  message("Downloading table: ", table_id)

  df <- csodata::cso_get_data(table_id, pivot_format = "tall")

  if (!is.data.frame(df)) {
    stop("Downloaded data is not a data frame")
  }

  if (!is.null(filter_sex)) {
    df <- df %>% dplyr::filter(Sex %in% filter_sex)
  }
  if (!is.null(filter_age)) {
    df <- df %>% dplyr::filter(Age.Group %in% filter_age)
  }
  if (!is.null(filter_years)) {
    df <- df %>% dplyr::filter(Year %in% filter_years)
  }

  if (!is.null(dest_file)) {
    if (!dir.exists(dirname(dest_file))) dir.create(dirname(dest_file), recursive = TRUE)
    readr::write_csv(df, dest_file)
  }

  return(df)
}

#' Download, clean, and combine multiple CSO tables
#'
#' This function downloads,cleans and combines data sets downloaded from the CSO website.
#'
#' @param table_ids An array of numbers which corresponds to a specific data
#' set on the CSO website.This parameter can accept multiple \code{table_id}'s.
#' @param filter_sex A parameter to filter the sex column of the data set.
#' @param filter_age A parameter to filter the age column of the data set.
#' @param filter_years A parameter to filter the years of which the data was.
#' @param combine An operator set to \code{"TRUE"} by default which combines all specified \code{table_ids}.
#' @param save_dir Directory where cleaned CSV files will be saved
#'
#' @returns An object of class \code{"lifeRstyle"} which is a list of \code{\link[tibble]{tibble}}s which
#' contain the downloaded,cleaned and combined data from the CSO website.
#'
#' @importFrom dplyr "bind_rows"
#' @importFrom readr "write_csv"
#'
#' @examples
#' \dontrun{
#' tables <- c(alcohol = "HIS15_cleaned", health = "HIS01", smoking = "HIS09")
#' data_list <- download_clean_combine_cso(tables)
#' }
download_clean_combine_cso <- function(table_ids,
                                       filter_sex = NULL,
                                       filter_age = NULL,
                                       filter_years = NULL,
                                       combine = TRUE,
                                       save_dir = "data/clean") {

  if (missing(table_ids) || !is.character(table_ids) || length(table_ids) < 1) {
    stop("table_ids must be a character vector")
  }

  if (!dir.exists(save_dir)) dir.create(save_dir, recursive = TRUE)

  if (is.null(names(table_ids))) {
    names(table_ids) <- table_ids
  }

  cleaned_list <- lapply(names(table_ids), function(name) {
    tid <- table_ids[[name]]
    dest_file <- file.path(save_dir, paste0(name, "_cleaned.csv"))
    download_and_clean_cso(
      table_id = tid,
      dest_file = dest_file,
      filter_sex = filter_sex,
      filter_age = filter_age,
      filter_years = filter_years
    )
  })

  names(cleaned_list) <- names(table_ids)

  combined_df <- NULL
  if (combine) {
    combined_df <- dplyr::bind_rows(cleaned_list, .id = "table_name")
    readr::write_csv(combined_df, file.path(save_dir, "combined_cleaned.csv"))
  }

  return(list(individual = cleaned_list, combined = combined_df))
}
