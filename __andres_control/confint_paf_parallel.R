.paf_resolve_cores <- function(n_cores, n_tasks, use_parallel = TRUE) {
  if (is.null(n_cores)) {
    detected <- parallel::detectCores(logical = TRUE)
    n_cores <- if (is.na(detected)) 1L else max(1L, detected - 1L)
  }
  n_cores <- max(1L, min(as.integer(n_cores), n_tasks))
  if (!isTRUE(use_parallel)) n_cores <- 1L
  n_cores
}

.paf_make_chunks <- function(n_tasks, n_cores, chunk_size = NULL) {
  if (is.null(chunk_size)) chunk_size <- max(1L, ceiling(n_tasks / (n_cores * 4L)))
  chunk_size <- max(1L, as.integer(chunk_size))
  split(seq_len(n_tasks), ceiling(seq_len(n_tasks) / chunk_size))
}

.paf_run_chunks <- function(chunks, calc_chunk, n_cores) {
  if (n_cores == 1L || length(chunks) == 1L) {
    unlist(lapply(chunks, calc_chunk), use.names = FALSE)
  } else if (.Platform$OS.type == "windows") {
    cl <- parallel::makeCluster(n_cores)
    on.exit(parallel::stopCluster(cl), add = TRUE)
    parallel::clusterExport(cl, ".paf_use_rng_stream", envir = .GlobalEnv)
    unlist(parallel::parLapply(cl, chunks, calc_chunk), use.names = FALSE)
  } else {
    unlist(parallel::mclapply(chunks, calc_chunk, mc.cores = n_cores), use.names = FALSE)
  }
}

.paf_make_rng_streams <- function(seed, n_streams) {
  if (is.null(seed)) stop("seed no puede ser NULL cuando rng_parallel = TRUE.")

  old_kind <- RNGkind()
  old_seed_exists <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (old_seed_exists) get(".Random.seed", envir = .GlobalEnv) else NULL
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (old_seed_exists) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)

  RNGkind("L'Ecuyer-CMRG")
  set.seed(seed)
  streams <- vector("list", n_streams)
  for (i in seq_len(n_streams)) {
    streams[[i]] <- .Random.seed
    .Random.seed <- parallel::nextRNGStream(.Random.seed)
  }
  streams
}

.paf_use_rng_stream <- function(stream) {
  assign(".Random.seed", stream, envir = .GlobalEnv)
}

confint_paf_parallel <- function(
    gamma,
    beta,
    var_beta,
    p_abs,
    rr_form,
    p_form,
    rr_function,
    x = x_vals,
    n_sim = 10000,
    n_pca = 1000,
    neff_prev = 1000,
    seed = 145,
    n_cores = NULL,
    chunk_size = NULL,
    use_parallel = TRUE,
    return_sims = FALSE,
    rng_parallel = FALSE
){
  n_sim <- as.integer(n_sim)
  n_pca <- as.integer(n_pca)
  if (!is.finite(n_sim) || n_sim < 1L) stop("n_sim debe ser >= 1.")
  if (!is.finite(n_pca) || n_pca < 2L) stop("n_pca debe ser >= 2.")
  if (length(x) < 2L) stop("x debe tener al menos dos puntos.")
  if (!is.null(seed)) set.seed(seed)

  force(gamma)
  force(beta)
  force(var_beta)
  force(p_abs)
  force(rr_form)
  force(p_form)
  force(rr_function)
  force(neff_prev)

  est <- gamma$estimate
  gamma_shape <- est[["shape"]]
  gamma_rate <- est[["rate"]]
  if (!is.finite(gamma_shape) || !is.finite(gamma_rate)) {
    stop("gamma$estimate debe tener 'shape' y 'rate'.")
  }

  dx <- x[2] - x[1]
  if (!is.finite(dx) || dx <= 0) stop("x debe ser creciente y finito.")

  beta_sd <- if (is.finite(var_beta) && var_beta > 0) sqrt(var_beta) else 0
  p_abs_sd <- sqrt(pmax(p_abs * (1 - p_abs) / neff_prev, 0))
  p_form_sd <- sqrt(pmax(p_form * (1 - p_form) / neff_prev, 0))

  if (isTRUE(rng_parallel)) {
    n_cores <- .paf_resolve_cores(n_cores, n_sim, use_parallel)
    chunks <- .paf_make_chunks(n_sim, n_cores, chunk_size)
    rng_streams <- .paf_make_rng_streams(seed, n_sim)

    calc_one_fast <- function(i) {
      tryCatch({
        .paf_use_rng_stream(rng_streams[[i]])

        pca_sim <- rgamma(n_pca, shape = gamma_shape, rate = gamma_rate)
        mean_sim <- mean(pca_sim)
        sd_sim <- sd(pca_sim)
        shape_i <- (mean_sim / sd_sim)^2
        rate_i <- mean_sim / (sd_sim^2)

        y_gamma_sim <- dgamma(x, shape = shape_i, rate = rate_i)
        if (any(is.nan(y_gamma_sim))) return(0)

        beta_i <- if (beta_sd > 0) rnorm(1, beta, beta_sd) else beta
        rr_sim <- rr_function(x, beta_i)
        prop_abs_i <- max(rnorm(1, mean = p_abs, sd = p_abs_sd), 0.001)
        prop_form_i <- max(rnorm(1, mean = p_form, sd = p_form_sd), 0.001)

        ncgamma <- sum(y_gamma_sim[-1] + y_gamma_sim[-length(x)]) * dx / 2
        normalized_y <- (1 - (prop_abs_i + prop_form_i)) * y_gamma_sim / ncgamma
        weighted_excess_rr <- normalized_y * (rr_sim - 1)
        numerator <- (rr_form - 1) * prop_form_i +
          sum((weighted_excess_rr[-1] + weighted_excess_rr[-length(x)]) / 2) * dx
        denominator <- numerator + 1
        round(numerator / denominator, 3)
      }, error = function(e) {
        if (isTRUE(getOption("paf.debug", FALSE))) stop(e)
        NA_real_
      })
    }

    calc_chunk_fast <- function(idx) vapply(idx, calc_one_fast, numeric(1))
    simulated_pafs <- .paf_run_chunks(chunks, calc_chunk_fast, n_cores)
    simulated_pafs <- simulated_pafs[!is.nan(simulated_pafs) & is.finite(simulated_pafs)]
    if (!length(simulated_pafs)) stop("Todas las simulaciones fallaron. Revisa insumos.")

    out <- list(
      Point_Estimate = round(mean(simulated_pafs), 3),
      Lower_CI = quantile(simulated_pafs, 0.025),
      Upper_CI = quantile(simulated_pafs, 0.975)
    )
    if (isTRUE(return_sims)) out$simulated_pafs <- simulated_pafs
    return(out)
  }

  # Pre-simulate in the same order as the original for-loop so the seed is reproducible.
  shape_sim <- numeric(n_sim)
  rate_sim <- numeric(n_sim)
  beta_sim <- numeric(n_sim)
  prop_abs_sim <- numeric(n_sim)
  prop_form_sim <- numeric(n_sim)
  skip_sim <- logical(n_sim)

  for (i in seq_len(n_sim)) {
    pca_sim <- rgamma(n_pca, shape = gamma_shape, rate = gamma_rate)
    mean_sim <- mean(pca_sim)
    sd_sim <- sd(pca_sim)

    shape_sim[i] <- (mean_sim / sd_sim)^2
    rate_sim[i] <- mean_sim / (sd_sim^2)

    # Match the original: if the simulated gamma is bad, leave this simulation as 0.
    y_check <- dgamma(x, shape = shape_sim[i], rate = rate_sim[i])
    if (any(is.nan(y_check))) {
      skip_sim[i] <- TRUE
      next
    }

    beta_sim[i] <- if (beta_sd > 0) rnorm(1, beta, beta_sd) else beta
    prop_abs_sim[i] <- max(rnorm(1, mean = p_abs, sd = p_abs_sd), 0.001)
    prop_form_sim[i] <- max(rnorm(1, mean = p_form, sd = p_form_sd), 0.001)
  }

  calc_one <- function(i) {
    if (skip_sim[i]) return(0)

    y_gamma_sim <- dgamma(x, shape = shape_sim[i], rate = rate_sim[i])
    rr_sim <- rr_function(x, beta_sim[i])

    ncgamma <- sum(y_gamma_sim[-1] + y_gamma_sim[-length(x)]) * dx / 2
    normalized_y <- (1 - (prop_abs_sim[i] + prop_form_sim[i])) * y_gamma_sim / ncgamma
    weighted_excess_rr <- normalized_y * (rr_sim - 1)

    numerator <- (rr_form - 1) * prop_form_sim[i] +
      sum((weighted_excess_rr[-1] + weighted_excess_rr[-length(x)]) / 2) * dx
    denominator <- numerator + 1

    round(numerator / denominator, 3)
  }

  calc_chunk <- function(idx) vapply(idx, calc_one, numeric(1))

  if (is.null(n_cores)) {
    detected <- parallel::detectCores(logical = TRUE)
    n_cores <- if (is.na(detected)) 1L else max(1L, detected - 1L)
  }
  n_cores <- max(1L, min(as.integer(n_cores), n_sim))
  if (!isTRUE(use_parallel)) n_cores <- 1L

  if (is.null(chunk_size)) chunk_size <- max(1L, ceiling(n_sim / (n_cores * 4L)))
  chunk_size <- max(1L, as.integer(chunk_size))
  chunks <- split(seq_len(n_sim), ceiling(seq_len(n_sim) / chunk_size))

  simulated_pafs <- if (n_cores == 1L || length(chunks) == 1L) {
    unlist(lapply(chunks, calc_chunk), use.names = FALSE)
  } else if (.Platform$OS.type == "windows") {
    cl <- parallel::makeCluster(n_cores)
    on.exit(parallel::stopCluster(cl), add = TRUE)
    unlist(parallel::parLapply(cl, chunks, calc_chunk), use.names = FALSE)
  } else {
    unlist(parallel::mclapply(chunks, calc_chunk, mc.cores = n_cores), use.names = FALSE)
  }

  simulated_pafs <- simulated_pafs[!is.nan(simulated_pafs)]

  out <- list(
    Point_Estimate = round(mean(simulated_pafs), 3),
    Lower_CI = quantile(simulated_pafs, 0.025),
    Upper_CI = quantile(simulated_pafs, 0.975)
  )
  if (isTRUE(return_sims)) out$simulated_pafs <- simulated_pafs
  out
}

confint_paf_vcov_parallel <- function(
    gamma,
    betas,
    cov_matrix,
    p_abs,
    p_form,
    rr_fd,
    rr_function,
    x = x_vals,
    n_sim = 10000,
    n_pca = 1000,
    neff_prev = 1000,
    seed = 145,
    n_cores = NULL,
    chunk_size = NULL,
    use_parallel = TRUE,
    return_sims = FALSE,
    rng_parallel = FALSE
){
  n_sim <- as.integer(n_sim)
  n_pca <- as.integer(n_pca)
  if (!is.finite(n_sim) || n_sim < 1L) stop("n_sim debe ser >= 1.")
  if (!is.finite(n_pca) || n_pca < 2L) stop("n_pca debe ser >= 2.")
  if (length(x) < 2L) stop("x debe tener al menos dos puntos.")
  if (!is.null(seed)) set.seed(seed)

  force(gamma)
  force(betas)
  force(cov_matrix)
  force(p_abs)
  force(p_form)
  force(rr_fd)
  force(rr_function)
  force(neff_prev)

  gamma_est <- gamma$estimate
  gamma_shape <- gamma_est[["shape"]]
  gamma_rate <- if ("rate" %in% names(gamma_est)) gamma_est[["rate"]] else NA_real_
  gamma_scale <- if ("scale" %in% names(gamma_est)) gamma_est[["scale"]] else NA_real_
  if (!is.finite(gamma_shape) || (!is.finite(gamma_rate) && !is.finite(gamma_scale))) {
    stop("gamma$estimate debe tener 'shape' y 'rate' o 'scale'.")
  }

  dx <- x[2] - x[1]
  if (!is.finite(dx) || dx <= 0) stop("x debe ser creciente y finito.")

  p_abs_sd <- sqrt(pmax(p_abs * (1 - p_abs) / neff_prev, 0))
  p_form_sd <- sqrt(pmax(p_form * (1 - p_form) / neff_prev, 0))
  n_betas <- length(betas)
  cov_matrix <- as.matrix(cov_matrix)
  if (n_betas < 1L) stop("betas debe tener al menos un coeficiente.")
  if (!identical(dim(cov_matrix), c(n_betas, n_betas))) {
    stop("cov_matrix debe tener una fila y una columna por cada beta.")
  }

  if (isTRUE(rng_parallel)) {
    n_cores <- .paf_resolve_cores(n_cores, n_sim, use_parallel)
    chunks <- .paf_make_chunks(n_sim, n_cores, chunk_size)
    rng_streams <- .paf_make_rng_streams(seed, n_sim)

    calc_one_fast <- function(i) {
      tryCatch({
        .paf_use_rng_stream(rng_streams[[i]])

        pca_sim <- if (is.finite(gamma_rate)) {
          rgamma(n_pca, shape = gamma_shape, rate = gamma_rate)
        } else {
          rgamma(n_pca, shape = gamma_shape, scale = gamma_scale)
        }
        mean_sim <- mean(pca_sim)
        sd_sim <- sd(pca_sim)
        shape_i <- (mean_sim / sd_sim)^2
        rate_i <- mean_sim / (sd_sim^2)

        y_gamma_sim <- dgamma(x, shape = shape_i, rate = rate_i)
        if (any(is.nan(y_gamma_sim))) return(0)

        beta_i <- MASS::mvrnorm(1, mu = betas, Sigma = cov_matrix)
        rr_sim <- rr_function(x, beta_i)
        prop_abs_i <- max(rnorm(1, mean = p_abs, sd = p_abs_sd), 0.001)
        prop_form_i <- max(rnorm(1, mean = p_form, sd = p_form_sd), 0.001)

        ncgamma <- sum(y_gamma_sim[-1] + y_gamma_sim[-length(x)]) * dx / 2
        normalized_y <- (1 - (prop_abs_i + prop_form_i)) * y_gamma_sim / ncgamma
        weighted_excess_rr <- normalized_y * (rr_sim - 1)
        numerator <- (rr_fd - 1) * prop_form_i +
          sum((weighted_excess_rr[-1] + weighted_excess_rr[-length(x)]) / 2) * dx
        denominator <- numerator + 1
        round(numerator / denominator, 3)
      }, error = function(e) NA_real_)
    }

    calc_chunk_fast <- function(idx) vapply(idx, calc_one_fast, numeric(1))
    simulated_pafs <- .paf_run_chunks(chunks, calc_chunk_fast, n_cores)
    simulated_pafs <- simulated_pafs[!is.nan(simulated_pafs) & is.finite(simulated_pafs)]
    if (!length(simulated_pafs)) stop("Todas las simulaciones fallaron. Revisa insumos.")

    out <- list(
      point_estimate = mean(simulated_pafs),
      lower_ci = quantile(simulated_pafs, 0.025),
      upper_ci = quantile(simulated_pafs, 0.975)
    )
    if (isTRUE(return_sims)) out$simulated_pafs <- simulated_pafs
    return(out)
  }

  # Pre-simulate in the same order as the original for-loop so the seed is reproducible.
  shape_sim <- numeric(n_sim)
  rate_sim <- numeric(n_sim)
  beta_sim <- matrix(NA_real_, nrow = n_sim, ncol = n_betas)
  colnames(beta_sim) <- names(betas)
  prop_abs_sim <- numeric(n_sim)
  prop_form_sim <- numeric(n_sim)
  skip_sim <- logical(n_sim)

  for (i in seq_len(n_sim)) {
    pca_sim <- if (is.finite(gamma_rate)) {
      rgamma(n_pca, shape = gamma_shape, rate = gamma_rate)
    } else {
      rgamma(n_pca, shape = gamma_shape, scale = gamma_scale)
    }
    mean_sim <- mean(pca_sim)
    sd_sim <- sd(pca_sim)

    shape_sim[i] <- (mean_sim / sd_sim)^2
    rate_sim[i] <- mean_sim / (sd_sim^2)

    # Match the original: if the simulated gamma is bad, leave this simulation as 0.
    y_check <- dgamma(x, shape = shape_sim[i], rate = rate_sim[i])
    if (any(is.nan(y_check))) {
      skip_sim[i] <- TRUE
      next
    }

    beta_sim[i, ] <- MASS::mvrnorm(1, mu = betas, Sigma = cov_matrix)
    prop_abs_sim[i] <- max(rnorm(1, mean = p_abs, sd = p_abs_sd), 0.001)
    prop_form_sim[i] <- max(rnorm(1, mean = p_form, sd = p_form_sd), 0.001)
  }

  calc_one <- function(i) {
    if (skip_sim[i]) return(0)

    y_gamma_sim <- dgamma(x, shape = shape_sim[i], rate = rate_sim[i])
    rr_sim <- rr_function(x, beta_sim[i, ])

    ncgamma <- sum(y_gamma_sim[-1] + y_gamma_sim[-length(x)]) * dx / 2
    normalized_y <- (1 - (prop_abs_sim[i] + prop_form_sim[i])) * y_gamma_sim / ncgamma
    weighted_excess_rr <- normalized_y * (rr_sim - 1)

    numerator <- (rr_fd - 1) * prop_form_sim[i] +
      sum((weighted_excess_rr[-1] + weighted_excess_rr[-length(x)]) / 2) * dx
    denominator <- numerator + 1

    round(numerator / denominator, 3)
  }

  calc_chunk <- function(idx) vapply(idx, calc_one, numeric(1))

  if (is.null(n_cores)) {
    detected <- parallel::detectCores(logical = TRUE)
    n_cores <- if (is.na(detected)) 1L else max(1L, detected - 1L)
  }
  n_cores <- max(1L, min(as.integer(n_cores), n_sim))
  if (!isTRUE(use_parallel)) n_cores <- 1L

  if (is.null(chunk_size)) chunk_size <- max(1L, ceiling(n_sim / (n_cores * 4L)))
  chunk_size <- max(1L, as.integer(chunk_size))
  chunks <- split(seq_len(n_sim), ceiling(seq_len(n_sim) / chunk_size))

  simulated_pafs <- if (n_cores == 1L || length(chunks) == 1L) {
    unlist(lapply(chunks, calc_chunk), use.names = FALSE)
  } else if (.Platform$OS.type == "windows") {
    cl <- parallel::makeCluster(n_cores)
    on.exit(parallel::stopCluster(cl), add = TRUE)
    unlist(parallel::parLapply(cl, chunks, calc_chunk), use.names = FALSE)
  } else {
    unlist(parallel::mclapply(chunks, calc_chunk, mc.cores = n_cores), use.names = FALSE)
  }

  simulated_pafs <- simulated_pafs[!is.nan(simulated_pafs)]

  out <- list(
    point_estimate = mean(simulated_pafs),
    lower_ci = quantile(simulated_pafs, 0.025),
    upper_ci = quantile(simulated_pafs, 0.975)
  )
  if (isTRUE(return_sims)) out$simulated_pafs <- simulated_pafs
  out
}

confint_paf_hed_parallel <- function(
    gammas,
    beta,
    cov_matrix,
    p_abs,
    p_form,
    rr_fd,
    rr_function_nhed,
    rr_function_hed,
    p_hed,
    x_60 = seq(0.1, 150, length.out = 1500),
    x_150 = seq(0.1, 150, length.out = 1500),
    n_sim = 10000,
    n_pca = 1000,
    neff_prev = 1000,
    seed = 145,
    n_cores = NULL,
    chunk_size = NULL,
    use_parallel = TRUE,
    return_sims = FALSE,
    rng_parallel = FALSE
){
  n_sim <- as.integer(n_sim)
  n_pca <- as.integer(n_pca)
  if (!is.finite(n_sim) || n_sim < 1L) stop("n_sim debe ser >= 1.")
  if (!is.finite(n_pca) || n_pca < 2L) stop("n_pca debe ser >= 2.")
  if (length(x_60) < 2L || length(x_150) < 2L) {
    stop("x_60 y x_150 deben tener al menos dos puntos.")
  }
  if (!is.null(seed)) set.seed(seed)

  force(gammas)
  force(beta)
  force(cov_matrix)
  force(p_abs)
  force(p_form)
  force(rr_fd)
  force(rr_function_nhed)
  force(rr_function_hed)
  force(p_hed)
  force(neff_prev)

  est_nhed <- gammas[[1]]$estimate
  est_hed <- gammas[[2]]$estimate
  shape_nhed <- est_nhed[["shape"]]
  rate_nhed <- est_nhed[["rate"]]
  shape_hed <- est_hed[["shape"]]
  rate_hed <- est_hed[["rate"]]
  if (!is.finite(shape_nhed) || !is.finite(rate_nhed) ||
      !is.finite(shape_hed) || !is.finite(rate_hed)) {
    stop("Cada gamma debe tener estimate['shape'] y estimate['rate'].")
  }

  beta_sd <- if (is.finite(cov_matrix) && cov_matrix > 0) sqrt(cov_matrix) else 0
  p_abs_sd <- sqrt(pmax(p_abs * (1 - p_abs) / neff_prev, 0))
  p_form_sd <- sqrt(pmax(p_form * (1 - p_form) / neff_prev, 0))
  p_hed_sd <- sqrt(pmax(p_hed * (1 - p_hed) / neff_prev, 0))

  shape_sim_nhed <- numeric(n_sim)
  rate_sim_nhed <- numeric(n_sim)
  shape_sim_hed <- numeric(n_sim)
  rate_sim_hed <- numeric(n_sim)
  beta_sim <- numeric(n_sim)
  prop_abs_sim <- numeric(n_sim)
  prop_form_sim <- numeric(n_sim)
  prop_hed_sim <- numeric(n_sim)

  # Pre-simulate in the same order as the original for-loop so the seed is reproducible.
  for (i in seq_len(n_sim)) {
    pca_sim_nhed <- rgamma(n_pca, shape = shape_nhed, rate = rate_nhed)
    pca_sim_hed <- rgamma(n_pca, shape = shape_hed, rate = rate_hed)

    mean_sim_nhed <- mean(pca_sim_nhed)
    sd_sim_nhed <- sd(pca_sim_nhed)
    mean_sim_hed <- mean(pca_sim_hed)
    sd_sim_hed <- sd(pca_sim_hed)

    shape_sim_nhed[i] <- (mean_sim_nhed / sd_sim_nhed)^2
    rate_sim_nhed[i] <- mean_sim_nhed / (sd_sim_nhed^2)
    shape_sim_hed[i] <- (mean_sim_hed / sd_sim_hed)^2
    rate_sim_hed[i] <- mean_sim_hed / (sd_sim_hed^2)

    beta_sim[i] <- if (beta_sd > 0) rnorm(1, mean = beta, sd = beta_sd) else beta
    prop_abs_sim[i] <- max(rnorm(1, mean = p_abs, sd = p_abs_sd), 0.001)
    prop_form_sim[i] <- max(rnorm(1, mean = p_form, sd = p_form_sd), 0.001)
    prop_hed_sim[i] <- max(rnorm(1, mean = p_hed, sd = p_hed_sd), 0.001)
  }

  trap_int_hed <- function(x, y, rr, prop_abs, rr_form, prop_form, p_hed) {
    dx <- x[2] - x[1]
    ncgamma <- sum((y[-1] + y[-length(y)]) / 2) * dx
    normalized_y <- ((1 - (prop_abs + prop_form)) * p_hed) * y / ncgamma
    weighted_excess_rr <- normalized_y * (rr - 1)
    numerator <- (rr_form - 1) * prop_form +
      sum((weighted_excess_rr[-1] + weighted_excess_rr[-length(weighted_excess_rr)]) / 2) * dx
    denominator <- numerator + 1
    round(numerator / denominator, 3)
  }

  paf_hed_one <- function(
      y_nhed, y_hed_60, y_hed_150,
      rr_nhed, rr_hed_60, rr_hed_150,
      rr_form, p_abs, p_form, p_hed
  ) {
    int_ri_nhed <- trap_int_hed(
      x = x_60,
      y = y_nhed,
      rr = rr_nhed,
      prop_abs = p_abs,
      rr_form = rr_form,
      prop_form = p_form,
      p_hed = 1 - p_hed
    )

    int_ri_hed1 <- trap_int_hed(
      x = x_60,
      y = y_hed_60,
      rr = rr_hed_60,
      prop_abs = p_abs,
      rr_form = rr_form,
      prop_form = p_form,
      p_hed = p_hed
    )

    int_ri_hed2 <- trap_int_hed(
      x = x_150,
      y = y_hed_150,
      rr = rr_hed_150,
      prop_abs = p_abs,
      rr_form = rr_form,
      prop_form = p_form,
      p_hed = p_hed
    )

    num <- int_ri_nhed + int_ri_hed1 + int_ri_hed2
    num / (num + 1)
  }

  calc_one <- function(i) {
    y_gamma_sim_nhed <- dgamma(x_60, shape = shape_sim_nhed[i], rate = rate_sim_nhed[i])
    y_gamma_sim_hed_60 <- dgamma(x_60, shape = shape_sim_hed[i], rate = rate_sim_hed[i])
    y_gamma_sim_hed_150 <- dgamma(x_150, shape = shape_sim_hed[i], rate = rate_sim_hed[i])

    rr_sim_nhed <- rr_function_nhed(x = x_60, b = beta_sim[i])
    rr_sim_hed_60 <- rr_function_hed(x = x_60, beta = beta_sim[i])
    rr_sim_hed_150 <- rr_function_hed(x = x_150, beta = beta_sim[i])

    paf_hed_one(
      y_nhed = y_gamma_sim_nhed,
      y_hed_60 = y_gamma_sim_hed_60,
      y_hed_150 = y_gamma_sim_hed_150,
      rr_nhed = rr_sim_nhed,
      rr_hed_60 = rr_sim_hed_60,
      rr_hed_150 = rr_sim_hed_150,
      rr_form = rr_fd,
      p_abs = prop_abs_sim[i],
      p_form = prop_form_sim[i],
      p_hed = prop_hed_sim[i]
    )
  }

  calc_chunk <- function(idx) vapply(idx, calc_one, numeric(1))

  if (is.null(n_cores)) {
    detected <- parallel::detectCores(logical = TRUE)
    n_cores <- if (is.na(detected)) 1L else max(1L, detected - 1L)
  }
  n_cores <- max(1L, min(as.integer(n_cores), n_sim))
  if (!isTRUE(use_parallel)) n_cores <- 1L

  if (is.null(chunk_size)) chunk_size <- max(1L, ceiling(n_sim / (n_cores * 4L)))
  chunk_size <- max(1L, as.integer(chunk_size))
  chunks <- split(seq_len(n_sim), ceiling(seq_len(n_sim) / chunk_size))

  simulated_pafs <- if (n_cores == 1L || length(chunks) == 1L) {
    unlist(lapply(chunks, calc_chunk), use.names = FALSE)
  } else if (.Platform$OS.type == "windows") {
    cl <- parallel::makeCluster(n_cores)
    on.exit(parallel::stopCluster(cl), add = TRUE)
    unlist(parallel::parLapply(cl, chunks, calc_chunk), use.names = FALSE)
  } else {
    unlist(parallel::mclapply(chunks, calc_chunk, mc.cores = n_cores), use.names = FALSE)
  }

  simulated_pafs <- simulated_pafs[!is.nan(simulated_pafs)]
  if (length(simulated_pafs) == 0) {
    stop("All simulations resulted in NaN values. Please check your input parameters.")
  }

  out <- list(
    point_estimate = round(mean(simulated_pafs), 3),
    lower_ci = round(quantile(simulated_pafs, 0.025), 3),
    upper_ci = round(quantile(simulated_pafs, 0.975), 3)
  )
  if (isTRUE(return_sims)) out$simulated_pafs <- simulated_pafs
  out
}

confint_paf_hed_parallelized <- function(
    gammas,
    beta,
    cov_matrix,
    p_abs,
    p_form,
    rr_fd,
    rr_function_nhed,
    rr_function_hed,
    p_hed,
    x_60 = seq(0.1, 150, length.out = 1500),
    x_150 = seq(0.1, 150, length.out = 1500),
    n_sim = 10000,
    n_pca = 1000,
    neff_prev = 1000,
    seed = 145,
    n_cores = NULL,
    chunk_size = NULL,
    use_parallel = TRUE,
    return_sims = FALSE,
    rng_parallel = FALSE
){
  # Simula n_sim escenarios del mundo alternativos, donde en cada uno
  # varian ligeramente las dos distribuciones gamma (nHED y HED), el beta
  # de riesgo relativo, y las proporciones poblacionales; luego calcula
  # el PAF en cada escenario y resume los resultados como promedio e IC 95%.

  n_sim <- as.integer(n_sim)
  n_pca <- as.integer(n_pca)
  if (!is.finite(n_sim) || n_sim < 1L) stop("n_sim debe ser >= 1.")
  if (!is.finite(n_pca) || n_pca < 2L) stop("n_pca debe ser >= 2.")
  if (length(x_60) < 2L || length(x_150) < 2L) {
    stop("x_60 y x_150 deben tener al menos dos puntos.")
  }

  # Reproducibilidad: todos los sorteos aleatorios se hacen aqui, antes
  # de entrar a la parte paralela. Asi el resultado no cambia si usas
  # 1, 2, o mas cores.
  if (!is.null(seed)) set.seed(seed)

  force(gammas)
  force(beta)
  force(cov_matrix)
  force(p_abs)
  force(p_form)
  force(rr_fd)
  force(rr_function_nhed)
  force(rr_function_hed)
  force(p_hed)
  force(neff_prev)

  get_gamma_par <- function(gamma_fit) {
    est <- gamma_fit$estimate
    shape <- est[["shape"]]
    rate <- if ("rate" %in% names(est)) est[["rate"]] else NA_real_
    scale <- if ("scale" %in% names(est)) est[["scale"]] else NA_real_
    if (!is.finite(shape) || (!is.finite(rate) && !is.finite(scale))) {
      stop("Cada gamma debe tener estimate['shape'] y estimate['rate'] o estimate['scale'].")
    }
    list(shape = shape, rate = rate, scale = scale)
  }

  gamma_nhed <- get_gamma_par(gammas[[1]])
  gamma_hed <- get_gamma_par(gammas[[2]])

  beta_var <- as.numeric(cov_matrix)
  if (length(beta_var) != 1L || !is.finite(beta_var) || beta_var < 0) {
    stop("cov_matrix debe ser una varianza escalar no negativa para beta.")
  }

  beta_sd <- sqrt(beta_var)
  p_abs_sd <- sqrt(pmax(p_abs * (1 - p_abs) / neff_prev, 0))
  p_form_sd <- sqrt(pmax(p_form * (1 - p_form) / neff_prev, 0))
  p_hed_sd <- sqrt(pmax(p_hed * (1 - p_hed) / neff_prev, 0))

  draw_gamma_pca <- function(pars) {
    if (is.finite(pars$rate)) {
      rgamma(n_pca, shape = pars$shape, rate = pars$rate)
    } else {
      rgamma(n_pca, shape = pars$shape, scale = pars$scale)
    }
  }

  if (isTRUE(rng_parallel)) {
    n_cores <- .paf_resolve_cores(n_cores, n_sim, use_parallel)
    chunks <- .paf_make_chunks(n_sim, n_cores, chunk_size)
    rng_streams <- .paf_make_rng_streams(seed, n_sim)

    calc_one_fast <- function(i) {
      tryCatch({
        .paf_use_rng_stream(rng_streams[[i]])

        pca_sim_nhed <- draw_gamma_pca(gamma_nhed)
        pca_sim_hed <- draw_gamma_pca(gamma_hed)

        mean_sim_nhed <- mean(pca_sim_nhed)
        sd_sim_nhed <- sd(pca_sim_nhed)
        mean_sim_hed <- mean(pca_sim_hed)
        sd_sim_hed <- sd(pca_sim_hed)

        shape_nhed_i <- (mean_sim_nhed / sd_sim_nhed)^2
        rate_nhed_i <- mean_sim_nhed / (sd_sim_nhed^2)
        shape_hed_i <- (mean_sim_hed / sd_sim_hed)^2
        rate_hed_i <- mean_sim_hed / (sd_sim_hed^2)

        y_gamma_sim_nhed <- dgamma(x_60, shape = shape_nhed_i, rate = rate_nhed_i)
        y_gamma_sim_hed_60 <- dgamma(x_60, shape = shape_hed_i, rate = rate_hed_i)
        y_gamma_sim_hed_150 <- dgamma(x_150, shape = shape_hed_i, rate = rate_hed_i)
        if (any(is.nan(y_gamma_sim_nhed)) ||
            any(is.nan(y_gamma_sim_hed_60)) ||
            any(is.nan(y_gamma_sim_hed_150))) {
          return(NA_real_)
        }

        beta_i <- if (beta_sd > 0) rnorm(1, mean = beta, sd = beta_sd) else beta
        rr_sim_nhed <- rr_function_nhed(x = x_60, b = beta_i)
        rr_sim_hed_60 <- rr_function_hed(x = x_60, beta = beta_i)
        rr_sim_hed_150 <- rr_function_hed(x = x_150, beta = beta_i)

        prop_abs_i <- max(rnorm(1, mean = p_abs, sd = p_abs_sd), 0.001)
        prop_form_i <- max(rnorm(1, mean = p_form, sd = p_form_sd), 0.001)
        prop_hed_i <- max(rnorm(1, mean = p_hed, sd = p_hed_sd), 0.001)

        trap_one <- function(x, y, rr, segment_weight) {
          dx <- x[2] - x[1]
          ncgamma <- sum((y[-1] + y[-length(y)]) / 2) * dx
          if (!is.finite(ncgamma) || ncgamma <= 0) return(NA_real_)
          normalized_y <- ((1 - (prop_abs_i + prop_form_i)) * segment_weight) * y / ncgamma
          weighted_excess_rr <- normalized_y * (rr - 1)
          numerator <- (rr_fd - 1) * prop_form_i +
            sum((weighted_excess_rr[-1] +
                   weighted_excess_rr[-length(weighted_excess_rr)]) / 2) * dx
          denominator <- numerator + 1
          if (!is.finite(numerator) || !is.finite(denominator) || denominator == 0) {
            return(NA_real_)
          }
          round(numerator / denominator, 3)
        }

        int_ri_nhed <- trap_one(x_60, y_gamma_sim_nhed, rr_sim_nhed, 1 - prop_hed_i)
        int_ri_hed1 <- trap_one(x_60, y_gamma_sim_hed_60, rr_sim_hed_60, prop_hed_i)
        int_ri_hed2 <- trap_one(x_150, y_gamma_sim_hed_150, rr_sim_hed_150, prop_hed_i)
        num <- int_ri_nhed + int_ri_hed1 + int_ri_hed2
        den <- num + 1
        if (!is.finite(num) || !is.finite(den) || den == 0) return(NA_real_)
        num / den
      }, error = function(e) NA_real_)
    }

    calc_chunk_fast <- function(idx) vapply(idx, calc_one_fast, numeric(1))
    simulated_pafs <- .paf_run_chunks(chunks, calc_chunk_fast, n_cores)
    simulated_pafs <- simulated_pafs[!is.nan(simulated_pafs) & is.finite(simulated_pafs)]
    if (length(simulated_pafs) == 0) {
      stop("All simulations resulted in NaN values. Please check your input parameters.")
    }

    out <- list(
      point_estimate = round(mean(simulated_pafs), 3),
      lower_ci = round(quantile(simulated_pafs, 0.025), 3),
      upper_ci = round(quantile(simulated_pafs, 0.975), 3)
    )
    if (isTRUE(return_sims)) out$simulated_pafs <- simulated_pafs
    return(out)
  }

  shape_sim_nhed <- numeric(n_sim)
  rate_sim_nhed <- numeric(n_sim)
  shape_sim_hed <- numeric(n_sim)
  rate_sim_hed <- numeric(n_sim)
  beta_sim <- numeric(n_sim)
  prop_abs_sim <- numeric(n_sim)
  prop_form_sim <- numeric(n_sim)
  prop_hed_sim <- numeric(n_sim)

  for (i in seq_len(n_sim)) {
    # Para cada simulacion, genera n_pca consumos ficticios de cada grupo:
    # NHED y HED usando la distribucion gamma ajustada.
    # "Si la ENPG tuviera n_pca personas mas, cuanto beberian segun
    # nuestra distribucion estimada?"
    pca_sim_nhed <- draw_gamma_pca(gamma_nhed)
    pca_sim_hed <- draw_gamma_pca(gamma_hed)

    # Calcula el promedio y la desviacion estandar de esos consumos simulados.
    mean_sim_nhed <- mean(pca_sim_nhed)
    sd_sim_nhed <- sd(pca_sim_nhed)
    mean_sim_hed <- mean(pca_sim_hed)
    sd_sim_hed <- sd(pca_sim_hed)

    # Recalcula shape y rate usando method of moments.
    # Cada simulacion produce una gamma ligeramente distinta, reflejando que
    # no conocemos la distribucion exacta.
    shape_sim_nhed[i] <- (mean_sim_nhed / sd_sim_nhed)^2
    rate_sim_nhed[i] <- mean_sim_nhed / (sd_sim_nhed^2)
    shape_sim_hed[i] <- (mean_sim_hed / sd_sim_hed)^2
    rate_sim_hed[i] <- mean_sim_hed / (sd_sim_hed^2)

    # Simula un beta alternativo de una distribucion normal.
    # Como el beta estimado tiene error estandar, aqui le das "juego":
    # a veces sale un poco mas alto, a veces mas bajo.
    beta_sim[i] <- if (beta_sd > 0) rnorm(1, mean = beta, sd = beta_sd) else beta

    # Simula tres proporciones poblacionales con incertidumbre.
    # max evita 0 y negativos. Con n = neff_prev y proporciones intermedias,
    # la normal es una aproximacion practica al error estandar de una proporcion.
    prop_abs_sim[i] <- max(rnorm(1, mean = p_abs, sd = p_abs_sd), 0.001)
    prop_form_sim[i] <- max(rnorm(1, mean = p_form, sd = p_form_sd), 0.001)
    prop_hed_sim[i] <- max(rnorm(1, mean = p_hed, sd = p_hed_sd), 0.001)
  }

  trap_int_hed <- function(x, y, rr, prop_abs, rr_form, prop_form, p_hed) {
    # Step size of the consumption grid // Interval width.
    dx <- x[2] - x[1]

    # y es la densidad gamma cruda. El area debajo de la curva no
    # necesariamente suma 1 en la grilla discreta, asi que calculamos el
    # area usando la regla trapezoidal.
    ncgamma <- sum((y[-1] + y[-length(y)]) / 2) * dx
    if (!is.finite(ncgamma) || ncgamma <= 0) return(NA_real_)

    # Scale density to this subgroup's share in the total population:
    # (1 - prop_abs - prop_form) = current drinkers; p_hed = segment weight.
    normalized_y <- ((1 - (prop_abs + prop_form)) * p_hed) * y / ncgamma

    # Risk in excess of the abstainer baseline (RR = 1).
    excess_rr <- rr - 1

    # Weight the excess risk by how many people drink at each level.
    weighted_excess_rr <- normalized_y * excess_rr

    # Integrate weighted excess risk over all consumption levels and add
    # the contribution of former drinkers. If rr_form = 1, they do not add risk.
    numerator <- (rr_form - 1) * prop_form +
      sum((weighted_excess_rr[-1] +
             weighted_excess_rr[-length(weighted_excess_rr)]) / 2) * dx

    # Total population risk = attributable risk + baseline risk of 1.
    denominator <- numerator + 1
    if (!is.finite(numerator) || !is.finite(denominator) || denominator == 0) {
      return(NA_real_)
    }

    # Population Attributable Fraction for this segment.
    round(numerator / denominator, 3)
  }

  paf_hed_one <- function(
      y_nhed, y_hed_60, y_hed_150,
      rr_nhed, rr_hed_60, rr_hed_150,
      rr_form, p_abs, p_form, p_hed
  ) {
    # Sumamos las tres integrales (nHED + HED_1 + HED_2).
    int_ri_nhed <- trap_int_hed(
      x = x_60,       # Curva gamma de nHED en la grilla baja.
      y = y_nhed,
      rr = rr_nhed,
      prop_abs = p_abs,
      rr_form = rr_form,
      prop_form = p_form,
      p_hed = 1 - p_hed
    )

    int_ri_hed1 <- trap_int_hed(
      x = x_60,       # HED en el rango bajo, usualmente 0-60g.
      y = y_hed_60,
      rr = rr_hed_60,
      prop_abs = p_abs,
      rr_form = rr_form,
      prop_form = p_form,
      p_hed = p_hed
    )

    int_ri_hed2 <- trap_int_hed(
      x = x_150,      # HED en el rango alto, usualmente >60-150g.
      y = y_hed_150,
      rr = rr_hed_150,
      prop_abs = p_abs,
      rr_form = rr_form,
      prop_form = p_form,
      p_hed = p_hed
    )

    # Se integran por separado porque usan diferentes grillas (x_60 vs x_150)
    # y potencialmente diferentes funciones/curvas de riesgo relativo.
    num <- int_ri_nhed + int_ri_hed1 + int_ri_hed2
    den <- num + 1
    if (!is.finite(num) || !is.finite(den) || den == 0) return(NA_real_)

    num / den
  }

  calc_one <- function(i) {
    tryCatch({
      # Con los parametros simulados, genera las tres curvas gamma.
      y_gamma_sim_nhed <- dgamma(x_60, shape = shape_sim_nhed[i], rate = rate_sim_nhed[i])
      y_gamma_sim_hed_60 <- dgamma(x_60, shape = shape_sim_hed[i], rate = rate_sim_hed[i])
      y_gamma_sim_hed_150 <- dgamma(x_150, shape = shape_sim_hed[i], rate = rate_sim_hed[i])

      if (any(is.nan(y_gamma_sim_nhed)) ||
          any(is.nan(y_gamma_sim_hed_60)) ||
          any(is.nan(y_gamma_sim_hed_150))) {
        return(NA_real_)
      }

      # Calcula tres curvas de riesgo relativo: nHED, HED <60 y HED >=60.
      rr_sim_nhed <- rr_function_nhed(x = x_60, b = beta_sim[i])
      rr_sim_hed_60 <- rr_function_hed(x = x_60, beta = beta_sim[i])
      rr_sim_hed_150 <- rr_function_hed(x = x_150, beta = beta_sim[i])

      # Con todos los valores simulados (gammas, beta, proporciones),
      # calcula un PAF. Esta parte es deterministica y por eso se paraleliza.
      paf_hed_one(
        y_nhed = y_gamma_sim_nhed,
        y_hed_60 = y_gamma_sim_hed_60,
        y_hed_150 = y_gamma_sim_hed_150,
        rr_nhed = rr_sim_nhed,
        rr_hed_60 = rr_sim_hed_60,
        rr_hed_150 = rr_sim_hed_150,
        rr_form = rr_fd,
        p_abs = prop_abs_sim[i],
        p_form = prop_form_sim[i],
        p_hed = prop_hed_sim[i]
      )
    }, error = function(e) NA_real_)
  }

  calc_chunk <- function(idx) vapply(idx, calc_one, numeric(1))

  if (is.null(n_cores)) {
    detected <- parallel::detectCores(logical = TRUE)
    n_cores <- if (is.na(detected)) 1L else max(1L, detected - 1L)
  }
  n_cores <- max(1L, min(as.integer(n_cores), n_sim))
  if (!isTRUE(use_parallel)) n_cores <- 1L

  if (is.null(chunk_size)) chunk_size <- max(1L, ceiling(n_sim / (n_cores * 4L)))
  chunk_size <- max(1L, as.integer(chunk_size))
  chunks <- split(seq_len(n_sim), ceiling(seq_len(n_sim) / chunk_size))

  simulated_pafs <- if (n_cores == 1L || length(chunks) == 1L) {
    unlist(lapply(chunks, calc_chunk), use.names = FALSE)
  } else if (.Platform$OS.type == "windows") {
    cl <- parallel::makeCluster(n_cores)
    on.exit(parallel::stopCluster(cl), add = TRUE)
    unlist(parallel::parLapply(cl, chunks, calc_chunk), use.names = FALSE)
  } else {
    unlist(parallel::mclapply(chunks, calc_chunk, mc.cores = n_cores), use.names = FALSE)
  }

  # Resumen final: media, percentil 2.5 y percentil 97.5.
  simulated_pafs <- simulated_pafs[!is.nan(simulated_pafs) & is.finite(simulated_pafs)]
  if (length(simulated_pafs) == 0) {
    stop("All simulations resulted in NaN values. Please check your input parameters.")
  }

  out <- list(
    point_estimate = round(mean(simulated_pafs), 3),
    lower_ci = round(quantile(simulated_pafs, 0.025), 3),
    upper_ci = round(quantile(simulated_pafs, 0.975), 3)
  )
  if (isTRUE(return_sims)) out$simulated_pafs <- simulated_pafs
  out
}
