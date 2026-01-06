############################################################
# ST403 / climr unified modelling utilities
############################################################

lm_fit    <- fit(his15, fit_type = "lm")
anova_fit <- fit(his15, fit_type = "anova")
mixed_fit <- fit(combined_data, fit_type = "mixed")

## shouldn't have random pieces of code lying within the coding document
plot(lm_fit)
plot(mixed_fit)

library(lme4) # shouldn't call libraries within the coding document
# imports are stated within the description

############################################################
# 1. Generic fit() (shared by climr and data.frame objects)
############################################################

fit <- function(obj,
                data_type = c("yearly", "quarterly", "monthly"),
                fit_type  = c("lm", "loess", "smooth.spline"),
                ...) {
  UseMethod("fit")
}

############################################################
# 2. fit.climr()  (your climate object method)
############################################################


fit.climr <- function(obj,
                      data_type = c("yearly", "quarterly", "monthly"),
                      fit_type  = c("lm", "loess", "smooth.spline"),
                      ...) {

  if (!inherits(obj, "climr"))
    stop("This function only works on objects of class \"climr\"")

  ## Which data set to use
  data_type <- match.arg(data_type)
  fit_type  <- match.arg(fit_type)

  dat_choose <- switch(
    data_type,
    yearly    = "clim_year",
    quarterly = "clim_quarter",
    monthly   = "clim_month"
  )
  dat <- obj[[dat_choose]]

  mod <- switch(
    fit_type,
    lm = {
      dat |> stats::lm(temp ~ x, data = _, ...)
    },
    loess = {
      dat |> stats::loess(temp ~ x, data = _, ...)
    },
    smooth.spline = {
      dat |> (\(x) stats::smooth.spline(x$x, x$temp, ...))()
    }
  )

  ## Wrap output
  out <- list(
    model    = mod,
    data     = dat,
    data_type = data_type,
    fit_type  = fit_type
  )
  attr(out, "source") <- attr(obj, "source")
  class(out) <- c("climr_fit", "list")
  invisible(out)
}

## Optional: plot method for climr fits --------------------
plot.climr_fit <- function(x, ...) {
  if (inherits(x$model, "lm") || inherits(x$model, "loess")) {
    plot(x$data$x, x$data$temp, main = paste("climr", x$fit_type, "fit"),
         xlab = "x", ylab = "temp", ...)
    grid()
    xs <- seq(min(x$data$x), max(x$data$x), length.out = 200)
    preds <- predict(x$model, newdata = data.frame(x = xs))
    lines(xs, preds)
  } else if (inherits(x$model, "smooth.spline")) {
    plot(x$model, main = "climr smooth.spline fit", ...)
  }
  invisible(x)}

############################################################
# 3. fit.data.frame(): ST403 models on data frames
############################################################

fit.data.frame <- function(obj,
                           data_type = NULL,
                           fit_type  = c("lm", "anova", "mixed"),
                           ...) {

  fit_type <- match.arg(fit_type)

  mod <- switch(
    fit_type,

    ## Linear regression: value ~ Sex + Age.Group + Year
    lm = {
      stats::lm(value ~ Sex + Age.Group + Year, data = obj, ...)
    },

    ## One-way ANOVA: value ~ Age.Group
    anova = {
      stats::aov(value ~ Age.Group, data = obj, ...)
    },

    ## Mixed-effects: value ~ Sex + Age.Group + (1 | table_id)
    mixed = {
      if (!"table_id" %in% names(obj))
        stop("`mixed` model requires a 'table_id' column in the data.")
      lme4::lmer(value ~ Sex + Age.Group + (1 | table_id), data = obj, ...)
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

############################################################
# 4. Methods for st403_fit: print, summary, plot
############################################################

print.st403_fit <- function(x, ...) {
  cat("ST403", x$fit_type, "model\n\n")
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
    ## Basic diagnostics for mixed models
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
# 5. Example usage
############################################################

## Assume:
## his15         : data.frame with value, Sex, Age.Group, Year
## combined_data : data.frame with value, Sex, Age.Group, table_id
# Linear regression model
# lm_fit <- fit(his15, fit_type = "lm")
# lm_fit
# plot(lm_fit)
# One-way ANOVA model
# anova_fit <- fit(his15, fit_type = "anova")
# anova_fit
# plot(anova_fit)
# Mixed-effects model
# mixed_fit <- fit(combined_data, fit_type = "mixed")
# mixed_fit
# plot(mixed_fit)

