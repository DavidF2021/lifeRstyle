#' Fit statistical models to LifeRstyle data
#'
#' Fits linear regression, ANOVA, or mixed-effects models to a cleaned
#' LifeRstyle data frame.
#'
#' @param obj A cleaned LifeRstyle data frame.
#' @param data_type Optional descriptor of the data type.
#' @param fit_type The type of model to fit: \code{"lm"}, \code{"anova"}, or \code{"mixed"}.
#' @param ... Additional arguments passed to the underlying model function.
#'
#' @return An object of class \code{"st403_fit"} containing the fitted model
#'   and associated metadata.
#' @export
#'
#' @examples
#' lm_fit <- fit_lifeRstyle(HIS15_cleaned, fit_type = "lm")
#' anova_fit <- fit_lifeRstyle(HIS15_cleaned, fit_type = "anova")
fit_lifeRstyle <- function(obj,
                           data_type = NULL,
                           fit_type  = c("lm", "anova", "mixed"),
                           ...) {

  fit_type <- match.arg(fit_type)

  needed <- c("Year", "Sex", "Age.Group", "value")
  missing <- setdiff(needed, names(obj))
  if (length(missing) > 0) {
    stop("Data frame is missing required columns: ",
         paste(missing, collapse = ", "))
  }

  obj <- transform(
    obj,
    Year      = as.numeric(Year),
    Sex       = as.factor(Sex),
    Age.Group = as.factor(Age.Group)
  )

  mod <- switch(
    fit_type,
    lm = stats::lm(value ~ Sex + Age.Group + Year, data = obj, ...),
    anova = stats::aov(value ~ Age.Group, data = obj, ...),
    mixed = {
      if (!"table_name" %in% names(obj)) {
        stop("Mixed model requires a 'table_name' column in the data.")
      }
      lme4::lmer(value ~ Sex + Age.Group + (1 | table_name), data = obj, ...)
    }
  )

  out <- list(
    model    = mod,
    data     = obj,
    fit_type = fit_type
  )

  class(out) <- "st403_fit"
  out
}

#' @export
print.st403_fit <- function(x, ...) {
  print(summary(x$model))
  invisible(x)
}

#' @export
summary.st403_fit <- function(object, ...) {
  summary(object$model, ...)
}

#' @export
plot.st403_fit <- function(x, ...) {
  model <- x$model

  if (inherits(model, "lm") || inherits(model, "aov")) {
    plot(model, ...)
  } else if (inherits(model, "merMod")) {
    plot(fitted(model), resid(model),
         xlab = "Fitted values",
         ylab = "Residuals")
    abline(h = 0, col = "red")
  }

  invisible(x)
}

#' Extract an ANOVA table from a fitted LifeRstyle model
#'
#' @param fit_obj A fitted model object of class \code{"st403_fit"}.
#'
#' @return A data frame containing the ANOVA table.
#' @export
#'
#' @examples
#' fit_obj <- fit_lifeRstyle(HIS15_cleaned, fit_type = "anova")
#' anova_table(fit_obj)
anova_table <- function(fit_obj) {
  if (!inherits(fit_obj, "st403_fit")) {
    stop("anova_table() expects an object of class 'st403_fit'.")
  }

  as.data.frame(stats::anova(fit_obj$model))
}
