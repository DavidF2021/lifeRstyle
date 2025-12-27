############################################################
# Fit_LifeRstyle.R (IMPROVED)
# - Adds helpers for HIS15/HIS01 CSV structure
# - Standardises names (VALUE -> value, Age Group -> Age.Group, Statistic Label -> Statistic.Label)
# - Adds combine_his_tables() to build combined_data with table_id
# - Adds anova_table() that returns a data.frame (perfect for View())
# - Keeps your existing S3 fit() structure
############################################################

suppressPackageStartupMessages(library(lme4))

############################################################
# 0. Helper: standardise CSO-style column names
############################################################

standardise_cso_names <- function(df) {
  # Normalize exact names that appear in CSO CSV exports
  nm <- names(df)

  rename_map <- c(
    "Age Group" = "Age.Group",
    "Statistic Label" = "Statistic.Label",
    "VALUE" = "value",
    "UNIT" = "unit"
  )

  for (old in names(rename_map)) {
    if (old %in% nm) nm[nm == old] <- rename_map[[old]]
  }
  names(df) <- nm

  # Light type cleanup
  if ("Year" %in% names(df)) {
    suppressWarnings(df$Year <- as.integer(df$Year))
  }
  if ("Sex" %in% names(df)) df$Sex <- as.factor(df$Sex)
  if ("Age.Group" %in% names(df)) df$Age.Group <- as.factor(df$Age.Group)
  if ("value" %in% names(df)) {
    suppressWarnings(df$value <- as.numeric(df$value))
  } # should we be suppressing warnings if it is part of the marking scheme

  df
}

############################################################
# 1. Helper: combine HIS15 + HIS01 into one combined_data
############################################################

combine_his_tables <- function(his15, his01,
                               table_ids = c(HIS15 = "HIS15", HIS01 = "HIS01")) {

  his15 <- standardise_cso_names(his15)
  his01 <- standardise_cso_names(his01)

  # Add table identifiers used by mixed model
  his15$table_id <- table_ids[["HIS15"]]
  his01$table_id <- table_ids[["HIS01"]]

  # A "table_name" is handy for plotting (your Plot_LifeRStyle.R expects it)
  his15$table_name <- "HIS15"
  his01$table_name <- "HIS01"

  # Ensure same columns exist in both; bind by common structure
  common_cols <- intersect(names(his15), names(his01))
  combined <- rbind(his15[common_cols], his01[common_cols])

  combined
}

############################################################
# 2. Generic fit() (S3 dispatch)
############################################################


# remove
fit <- function(obj,
                data_type = c("yearly", "quarterly", "monthly"),
                fit_type  = c("lm", "loess", "smooth.spline"),
                ...) {
  UseMethod("fit")
}

############################################################
# 3. fit.data.frame(): ST403 models on data frames
############################################################

fit.data.frame <- function(obj,
                           data_type = NULL,   # ignored; kept for compatibility
                           fit_type  = c("lm", "anova", "mixed"),
                           ...) {

  fit_type <- match.arg(fit_type)

  # Standardise names if needed (works with your CSO CSVs)
  obj <- standardise_cso_names(obj)

  # Common required cols
  required <- c("value", "Sex", "Age.Group")
  missing <- setdiff(required, names(obj))
  if (length(missing) > 0) {
    stop("Missing required columns: ", paste(missing, collapse = ", "))
  }

  mod <- switch(
    fit_type,
    lm = {
      if (!"Year" %in% names(obj)) stop("LM requires a 'Year' column.")
      stats::lm(value ~ Sex + Age.Group + Year, data = obj, ...)
    },
    anova = {
      stats::aov(value ~ Age.Group, data = obj, ...)
    },
    mixed = {
      if (!"table_id" %in% names(obj)) stop("Mixed model requires a 'table_id' column.")
      lme4::lmer(value ~ Sex + Age.Group + (1 | table_id), data = obj, ...)
    }
  )

  out <- list(model = mod, data = obj, fit_type = fit_type)
  class(out) <- c("st403_fit", "list")

  print(out) # auto-print full details to console
  invisible(out)
}

############################################################
# 4. print/summary/plot methods
############################################################

print.st403_fit <- function(x, ...) {
  cat("------------------------------------------------------------\n")
  cat("ST403", toupper(x$fit_type), "MODEL OUTPUT\n")
  cat("------------------------------------------------------------\n\n")
  print(summary(x$model))
  invisible(x)
}

summary.st403_fit <- function(object, ...) {
  summary(object$model, ...)
}

plot.st403_fit <- function(x, ...) {
  model <- x$model

  if (inherits(model, "lm")) {
    op <- par(mfrow = c(2, 2))
    on.exit(par(op))
    plot(model, ...)

  } else if (inherits(model, "aov")) {
    mod_lm <- lm(model)
    op <- par(mfrow = c(2, 2))
    on.exit(par(op))
    plot(mod_lm, ...)

  } else if (inherits(model, "merMod")) {
    op <- par(mfrow = c(1, 2))
    on.exit(par(op))

    plot(fitted(model), resid(model),
         main = "Residuals vs Fitted",
         xlab = "Fitted values", ylab = "Residuals", ...)
    abline(h = 0, col = "red")

    qqnorm(resid(model), main = "Normal Q-Q Plot")
    qqline(resid(model), col = "red")
  }

  invisible(x)
}

############################################################
# 5. NEW: ANOVA table extractor (for View())
############################################################

anova_table <- function(fit_obj) {
  if (!is.list(fit_obj) || is.null(fit_obj$model)) stop("Not a valid fit object.")
  mod <- fit_obj$model

  if (inherits(mod, "aov")) {
    tab <- summary(mod)[[1]]
    return(as.data.frame(tab))
  }
  if (inherits(mod, "lm")) {
    tab <- stats::anova(mod)
    return(as.data.frame(tab))
  }
  if (inherits(mod, "merMod")) {
    tab <- lme4::anova(mod)
    return(as.data.frame(tab))
  }

  stop("ANOVA table not supported for this model type.")
}


###fit

## how to view the anova table in this codes

# I need to add comments on these functions
# or add any other thing I need that will improve
