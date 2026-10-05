# Safe wrapper for MicSim transition-rate lookup.
#
# MicSim::micSim calls user-supplied rate functions by name. In some IDE /
# notebook contexts those functions are not visible from inside the MicSim
# namespace, even when they exist in the caller's environment.
#
# This wrapper does not unlock or modify the MicSim namespace. It creates a
# private bridge environment whose parent is the MicSim namespace, copies the
# caller's rate functions into that bridge, and runs a copy of MicSim::micSim
# there. The wrapper is assigned only as .GlobalEnv$micSim.

if (!requireNamespace("MicSim", quietly = TRUE)) {
  stop("Package 'MicSim' must be installed before sourcing this patch.", call. = FALSE)
}

local({
  micSim_namespace <- asNamespace("MicSim")

  original_micSim <- getOption("patch_micSim.original_micSim")
  if (!is.function(original_micSim) ||
      !identical(environment(original_micSim), micSim_namespace)) {
    original_micSim <- get("micSim", envir = micSim_namespace)
    options(patch_micSim.original_micSim = original_micSim)
  }

  bridge_env <- new.env(parent = micSim_namespace)

  micSim_in_bridge <- function() NULL
  formals(micSim_in_bridge) <- formals(original_micSim)
  body(micSim_in_bridge) <- body(original_micSim)
  environment(micSim_in_bridge) <- bridge_env

  bridge_env$rate_cS <- function(allTr) {
    rates <- unique(allTr)
    form <- unique(unlist(lapply(rates, function(rate_name) {
      rate_fun <- get(rate_name, mode = "function", envir = bridge_env, inherits = TRUE)
      names(formals(rate_fun))
    })))

    depMatrix <- matrix(0, nrow = length(rates), ncol = length(form))
    colnames(depMatrix) <- form
    rownames(depMatrix) <- rates

    for (i in seq_len(nrow(depMatrix))) {
      rate_fun <- get(rates[i], mode = "function", envir = bridge_env, inherits = TRUE)
      args <- names(formals(rate_fun))

      if (all(args %in% colnames(depMatrix))) {
        for (k in seq_along(args)) {
          depMatrix[i, match(args[k], colnames(depMatrix))] <- 1
        }
      }
    }

    as.matrix(depMatrix)
  }

  collect_rate_names <- function(args) {
    candidates <- character()

    if (!is.null(args$transitionMatrix)) {
      candidates <- c(candidates, as.character(unlist(args$transitionMatrix, use.names = FALSE)))
    }

    candidates <- unique(candidates)
    candidates[!is.na(candidates) & nzchar(candidates) & candidates != "0"]
  }

  sync_rate_functions <- function(rate_names, caller_env) {
    for (rate_name in rate_names) {
      rate_fun <- get0(rate_name, envir = caller_env, mode = "function", inherits = TRUE)

      if (is.function(rate_fun)) {
        assign(rate_name, rate_fun, envir = bridge_env)
      }
    }

    invisible(NULL)
  }

  micSim_wrapper <- function(...) {
    caller_env <- parent.frame()
    args <- list(...)

    sync_rate_functions(
      rate_names = collect_rate_names(args),
      caller_env = caller_env
    )

    do.call(micSim_in_bridge, args = args)
  }

  assign("micSim", micSim_wrapper, envir = .GlobalEnv)
})

message("micSim wrapper loaded in .GlobalEnv. MicSim namespace was not modified.")
