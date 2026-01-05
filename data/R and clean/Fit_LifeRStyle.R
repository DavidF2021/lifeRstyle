# 1. Generic S3 dispatcher

fit <- function(obj,
                data_type = NULL,
                fit_type  = c("lm", "anova", "mixed"),
                ...) {
  UseMethod("fit")
}

# 2. fit.data.frame(): models for CSO lifestyle data

fit.data.frame <- function(obj,
                           data_type = NULL,
                           fit_type  = c("lm", "anova", "mixed"),
                           ...) {

  fit_type <- match.arg(fit_type)

  # Basic sanity check: we expect at least these columns
  needed <- c("Year", "Sex", "Age.Group", "value")
  missing <- setdiff(needed, names(obj))
  if (length(missing) > 0) {
    stop("Data frame is missing required columns: ",
         paste(missing, collapse = ", "))
  }

  # Coerce to sensible types
  obj <- transform(
    obj,
    Year      = as.numeric(Year),
    Sex       = as.factor(Sex),
    Age.Group = as.factor(Age.Group)
  )

  # Fit the chosen model
  mod <- switch(
    fit_type,

    # Linear regression: value ~ Sex + Age.Group + Year
    lm = {
      stats::lm(value ~ Sex + Age.Group + Year, data = obj, ...)
    },

    # One-way ANOVA: value ~ Age.Group
    anova = {
      stats::aov(value ~ Age.Group, data = obj, ...)
    },

    # Mixed-effects model: value ~ Sex + Age.Group + (1 | table_name)
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

  class(out) <- c("st403_fit", "list")
  invisible(out)
}

# 3. Methods for class 'st403_fit'

# Print – concise model description + summary
print.st403_fit <- function(x, ...) {
  cat("-\n")
  cat("ST403", toupper(x$fit_type), "MODEL\n")
  cat("-\n\n")
  print(summary(x$model))
  invisible(x)
}

# Summary – just forwards to underlying model summary
summary.st403_fit <- function(object, ...) {
  summary(object$model, ...)
}

# Plot – basic diagnostics depending on model type
plot.st403_fit <- function(x, ...) {
  model <- x$model

  if (inherits(model, "lm")) {
    # Standard lm diagnostic plots
    op <- par(mfrow = c(2, 2))
    on.exit(par(op))
    plot(model, ...)

  } else if (inherits(model, "aov")) {
    # Convert to lm for diagnostics
    mod_lm <- stats::lm(model)
    op <- par(mfrow = c(2, 2))
    on.exit(par(op))
    plot(mod_lm, ...)

  } else if (inherits(model, "merMod")) {
    # Basic diagnostics for mixed models
    op <- par(mfrow = c(1, 2))
    on.exit(par(op))

    # Residuals vs fitted
    plot(
      fitted(model), resid(model),
      main = "Residuals vs Fitted",
      xlab = "Fitted values",
      ylab = "Residuals",
      ...
    )
    abline(h = 0, col = "red")

    # Normal Q-Q of residuals
    qqnorm(resid(model), main = "Normal Q-Q Plot")
    qqline(resid(model), col = "red")
  }

  invisible(x)
}

# 4. Helper: extract ANOVA table from st403_fit objects

anova_table <- function(fit_obj) {
  if (!inherits(fit_obj, "st403_fit")) {
    stop("anova_table() expects an object of class 'st403_fit'.")
  }

  mod <- fit_obj$model

  if (inherits(mod, "lm") || inherits(mod, "aov")) {
    tab <- stats::anova(mod)
    return(as.data.frame(tab))
  }

  if (inherits(mod, "merMod")) {
    # Use stats::anova(), which has a method for merMod objects
    tab <- stats::anova(mod)
    return(as.data.frame(tab))
  }

  stop("ANOVA table not supported for this model type.")
}
