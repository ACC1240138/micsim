# Figure 1. State-transition diagram of the EPS alcohol transition model
# Base R, grayscale, journal style (states: N0, FD, C1, C2, C3+)

.t0 <- Sys.time()
out_dir <- "."
invisible(Sys.setlocale("LC_CTYPE", if (.Platform$OS.type == "windows") "English_United States.utf8" else "C.UTF-8"))
fam <- "Liberation Sans"

# Draw an elliptical state node
ell <- function(x, y, rx = .55, ry = .36, lab, lwd = 1.2) {
  t <- seq(0, 2 * pi, length.out = 200)
  graphics::polygon(
    x + rx * cos(t),
    y + ry * sin(t),
    col = "white",
    border = "black",
    lwd = lwd
  )
  graphics::text(
    x, y, lab,
    family = fam,
    cex = 1.30,
    font = 2
  )
}

# Straight arrow
head <- function(x0, y0, x1, y1) {
  graphics::arrows(
    x0, y0, x1, y1,
    length = .09,
    angle = 20,
    lwd = 1.1,
    col = "black"
  )
}

# Quadratic Bézier curve with arrowheads
bez <- function(p0, p1, p2, both = FALSE, lty = 1) {
  s <- seq(0, 1, length.out = 60)
  x <- (1 - s)^2 * p0[1] + 2 * s * (1 - s) * p1[1] + s^2 * p2[1]
  y <- (1 - s)^2 * p0[2] + 2 * s * (1 - s) * p1[2] + s^2 * p2[2]
  graphics::lines(x, y, lwd = 1.1, lty = lty)
  head(x[58], y[58], x[60], y[60])
  if (both) head(x[3], y[3], x[1], y[1])
}

# Self-transition loop
loop <- function(x, y, dir, ry = .36) {
  bez(
    c(x - .28, y + dir * ry * .95),
    c(x, y + dir * (ry + .85)),
    c(x + .28, y + dir * ry * .95)
  )
}

# Main figure
draw <- function() {

  graphics::layout(
    matrix(1:2, ncol = 1),
    heights = c(10, 0.01)
  )

  graphics::par(
    mar = c(0, 0, 0, 0),
    family = fam
  )

  graphics::plot(
    NA,
    xlim = c(0, 10),
    ylim = c(.1, 3.7),
    asp = 1,
    axes = FALSE,
    xlab = "",
    ylab = ""
  )

  # Dashed box containing current drinkers
  graphics::rect(
    3.3, .3, 9.0, 3.45,
    lty = 2,
    lwd = 1
  )

  graphics::text(
    6.15, .55,
    "Current drinkers",
    cex = 1.15,
    font = 3
  )

  # Current-drinker states
  cx <- c(
    C1 = 4.6,
    C2 = 6.4,
    "C3+" = 8.2
  )

  cy <- 1.9

  # Adjacent bidirectional transitions
  for (i in 1:2) {
    head(cx[i] + .55, cy, cx[i + 1] - .55, cy)
  }

  for (i in 1:2) {
    head(cx[i + 1] - .55, cy, cx[i] + .55, cy)
  }

  # C1 <-> C3+ (arco alto, separado del resto)
  bez(
    c(cx[1] - .10, cy + .36),  # punta izquierda más a la izquierda
    c(mean(cx[1:3]), cy + 2.15),
    c(cx[3] + .10, cy + .36),  # punta derecha más a la derecha
    both = TRUE
  )

  # C2 <-> C3+
  bez(
    c(cx[2], cy + .36),
    c(mean(cx[2:3]), cy + 0.95),
    c(cx[3], cy + .36),
    both = TRUE
  )
  # C1 <-> C2
  bez(
    c(cx[1], cy + .36),
    c(mean(cx[1:2]), cy + 0.85),
    c(cx[2], cy + .36),
    both = TRUE
  )

  # State nodes and self-transitions
  for (k in names(cx)) {
    loop(cx[[k]], cy, -1)
    ell(cx[[k]], cy, lab = k)
  }

  # Never drinkers
  ell(1.2, 3.0, lab = "N0")
  loop(1.2, 3.0, +1)

  # Former drinkers
  ell(1.2, .9, lab = "FD")
  loop(1.2, .9, -1)

  # Initiation
  head(1.7, 2.75, 4.05, 2.25)

  graphics::text(
    2.55, 2.70,
    "Initiation",
    cex = 1.00,
    srt = -12,
    adj = c(.5, .5)
  )

  # Relapse
  head(1.7, 1.15, 4.05, 1.65)

  graphics::text(
    2.55, 1.18,
    "Relapse",
    cex = 1.00,
    srt = 12,
    adj = c(.5, .5)
  )

  # Cessation
  head(4.05, .9, 1.75, .78)

  graphics::text(
    2.45, .55,
    "Cessation",
    cex = 1.00,
    adj = c(.5, .5)
  )

  # Blank panel retained for layout compatibility
  graphics::par(mar = c(0, 0, 0, 0))

  graphics::plot(
    NA,
    xlim = c(0, 1),
    ylim = c(0, 1),
    axes = FALSE,
    xlab = "",
    ylab = ""
  )
}

# Export PDF
grDevices::cairo_pdf(
  file.path(out_dir, "fig1_eps_transitions.pdf"),
  width = 7.5,
  height = 4.9
)
draw()
grDevices::dev.off()

# Export PNG
grDevices::png(
  file.path(out_dir, "fig1_eps_transitions.png"),
  width = 7.5,
  height = 4.9,
  units = "in",
  res = 300,
  type = "cairo"
)
draw()
grDevices::dev.off()

# Verify outputs
stopifnot(
  file.exists(
    file.path(
      out_dir,
      c(
        "fig1_eps_transitions.pdf",
        "fig1_eps_transitions.png"
      )
    )
  )
)

cat(
  sprintf(
    "Elapsed: %.2f minutes\n",
    as.numeric(
      difftime(
        Sys.time(),
        .t0,
        units = "mins"
      )
    )
  )
)