.t0 <- Sys.time()

# Self-contained English diagrams for the second TSM notebook.
# Only ggplot2 and grid are required. Functions return plots without saving.
# Suggested display sizes: flow 12 x 8 inches; DAG and hurdle 12 x 7 inches.

v2_diagram_theme <- function() {
  ggplot2::theme_void(base_family = "sans", base_size = 12) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.title = ggplot2::element_text(
        face = "bold", size = 17, colour = "#17324D", hjust = 0, vjust = 1,
        margin = ggplot2::margin(t = 8, b = 9)
      ),
      plot.subtitle = ggplot2::element_text(
        size = 11, colour = "#516274", margin = ggplot2::margin(b = 12)
      ),
      plot.caption = ggplot2::element_text(
        size = 10, colour = "#516274", hjust = 0,
        lineheight = 1.15, margin = ggplot2::margin(t = 12)
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.margin = ggplot2::margin(28, 24, 20, 24)
    )
}

v2_diagram_box <- function(x, y, width, height, title, body,
                           fill = "#EAF3FB", border = "#B4C9DB",
                           title_size = 3.8, body_size = 3.3,
                           title_offset = 0.29, body_offset = -0.12) {
  list(
    ggplot2::annotate(
      "rect", xmin = x - width / 2, xmax = x + width / 2,
      ymin = y - height / 2, ymax = y + height / 2,
      fill = fill, colour = border, linewidth = 0.55
    ),
    ggplot2::annotate(
      "text", x = x, y = y + height * title_offset, label = title,
      size = title_size, fontface = "bold", family = "sans",
      colour = "#17324D", lineheight = 1.05
    ),
    ggplot2::annotate(
      "text", x = x, y = y + height * body_offset, label = body,
      size = body_size, family = "sans", colour = "#253F53",
      lineheight = 1.1
    )
  )
}

v2_diagram_arrow <- function(x, y, xend, yend, colour = "#58758C",
                             dashed = FALSE, head = TRUE) {
  # Omit arrow rather than passing NULL: annotate can otherwise drop rows.
  args <- list(
    geom = "segment", x = x, y = y, xend = xend, yend = yend,
    colour = colour, linewidth = 0.65,
    linetype = if (dashed) "dashed" else "solid", lineend = "round"
  )
  if (head) args$arrow <- grid::arrow(
    angle = 24, length = grid::unit(2.5, "mm"), type = "closed"
  )
  do.call(ggplot2::annotate, args)
}

v2_flow_plot <- function() {
  ggplot2::ggplot() +
    ggplot2::coord_cartesian(xlim = c(0, 12), ylim = c(1.2, 10.1), clip = "off") +
    v2_diagram_theme() +
    ggplot2::labs(
      title = "From repeated interviews to conditional transition probabilities",
      subtitle = "Direct person links, explicit measurement assumptions, and person-held-out prediction checks.",
      caption = paste0(
        "The study targets ages 15\u201365; observed TSM transitions cover ages 18\u201365 at origin."
      )
    ) +
    v2_diagram_box(
      1.9, 8.9, 3.6, 1.85, "1. Link the same people",
      "R7\u2192R8 through R10\u2192R11\n18\u201365 years at origin\nNew and returning observed IDs"
    ) +
    v2_diagram_box(
      6, 8.9, 3.6, 1.85, "2. Past-only history",
      "No future interviews used\nND_unknown or observed FD\nRetain first-observation uncertainty",
      fill = "#E8F5F1", border = "#A7CCC0", body_size = 3.15
    ) +
    v2_diagram_box(
      10.1, 8.9, 3.6, 1.85, "3. Reconstruct quantity",
      "Calvo-style frequency \u00d7 quantity\nDrinks/day = f_week \u00d7 q / 7\nResponse bins remain uncertain",
      fill = "#E8F5F1", border = "#A7CCC0", body_size = 3.15
    ) +
    v2_diagram_box(
      10.1, 5.8, 3.6, 1.85, "4. Separate dose scenarios",
      "Main: 12 g per drink\nSensitivity: 15.7 g per drink\nRaw scale, before APC calibration",
      fill = "#FFF4DE", border = "#DDC28D", body_size = 3.15
    ) +
    v2_diagram_box(
      6, 5.8, 3.6, 1.85, "5. Weights and follow-up",
      "Origin Fact_Exp and response IPW\nAccount for repeated people\nNo verified original PSU/strata",
      fill = "#FFF4DE", border = "#DDC28D", body_size = 3.15
    ) +
    v2_diagram_box(
      1.9, 5.8, 3.6, 1.85, "6. Compare candidate models",
      "Weighted empirical baseline\nGamma / lognormal hurdle\nOrdinal category model",
      fill = "#F0EDFA", border = "#C6BCDF", title_size = 3.6
    ) +
    v2_diagram_box(
      1.9, 2.7, 3.6, 1.85, "7. Person-held-out validation",
      "Categorical predictive scores\nNo shared IDs across folds\nCompare within each dose scenario",
      fill = "#F0EDFA", border = "#C6BCDF", title_size = 3.45, body_size = 3.15
    ) +
    v2_diagram_box(
      6, 2.7, 3.6, 1.85, "8. Predicted matrices",
      "Education-specific predictions\nIntegrate category probabilities\nReport support and uncertainty",
      fill = "#F0EDFA", border = "#C6BCDF", body_size = 3.15
    ) +
    v2_diagram_box(
      10.1, 2.7, 3.6, 1.85, "Later: ENPG / APC",
      "Assess source comparability\nThen consider calibration\nDeferred from this analysis",
      fill = "#F3F5F7", border = "#BBC5CE"
    ) +
    v2_diagram_arrow(3.7, 8.9, 4.2, 8.9) +
    v2_diagram_arrow(7.8, 8.9, 8.3, 8.9) +
    v2_diagram_arrow(10.1, 7.975, 10.1, 6.725) +
    v2_diagram_arrow(8.3, 5.8, 7.8, 5.8) +
    v2_diagram_arrow(4.2, 5.8, 3.7, 5.8) +
    v2_diagram_arrow(1.9, 4.875, 1.9, 3.625) +
    v2_diagram_arrow(3.7, 2.7, 4.2, 2.7) +
    v2_diagram_arrow(7.8, 2.7, 8.3, 2.7, colour = "#7E8F9D", dashed = TRUE)
}

v2_hurdle_plot <- function() {
  ggplot2::ggplot() +
    ggplot2::coord_cartesian(xlim = c(0, 14), ylim = c(0.8, 9.7), clip = "off") +
    v2_diagram_theme() +
    ggplot2::labs(
      title = "Predict outcome probabilities and map the drinking history",
      subtitle = "Continuous and ordinal models produce probability vectors for the same outcome categories.",
      caption = paste0(
        "Dose cut-points use the chosen 12 or 15.7 g/drink scenario. Positive probabilities are integrated over intervals.\n",
        "ND_unknown does not identify lifetime abstention; FD requires observed drinking at the origin or earlier."
      )
    ) +
    v2_diagram_box(
      7, 8.75, 12.7, 1.2, "Information available at the origin",
      "ND_unknown | observed FD | current drinking; reconstructed quantity, past history and baseline covariates",
      fill = "#E8F5F1", border = "#A7CCC0", body_size = 3.25,
      title_offset = 0.21, body_offset = -0.2
    ) +
    v2_diagram_box(
      3.45, 6.75, 5.7, 1.35, "Gamma / lognormal hurdle",
      "p = P(drinking at the next wave)\nD > 0: conditional positive distribution",
      fill = "#EAF3FB", title_offset = 0.29, body_offset = -0.16
    ) +
    v2_diagram_box(
      10.55, 6.75, 5.7, 1.35, "Ordinal category model",
      "One ordered zero-consumption category\nThen cat1 < cat2 < cat3 < cat4",
      fill = "#FFF4DE", border = "#DDC28D",
      title_offset = 0.29, body_offset = -0.16
    ) +
    v2_diagram_box(
      3.45, 4.55, 5.7, 1.5, "Integrate the full distribution",
      "P(cat k) = p \u00d7 [F(upper) \u2212 F(lower)]\nP(zero) = 1 \u2212 p\nEach interval receives a probability",
      fill = "#F0EDFA", border = "#C6BCDF",
      title_offset = 0.33, body_offset = -0.13
    ) +
    v2_diagram_box(
      10.55, 4.55, 5.7, 1.5, "Keep the probability vector",
      "P(zero), P(cat1), \u2026, P(cat4)\nFD and ND_unknown share the ordered zero\nHistory determines their later split",
      fill = "#FFF4DE", border = "#DDC28D",
      title_offset = 0.33, body_offset = -0.13
    ) +
    v2_diagram_box(
      7, 2.1, 12.7, 1.55, "Map zero consumption using observed history",
      "Prior observed drinking, including the origin \u2192 FD\nNo prior observed drinking \u2192 ND_unknown\nPositive probability remains in cat1\u2013cat4",
      fill = "#E8F5F1", border = "#A7CCC0",
      title_offset = 0.33, body_offset = -0.12
    ) +
    v2_diagram_arrow(4.8, 8.15, 3.45, 7.425) +
    v2_diagram_arrow(9.2, 8.15, 10.55, 7.425) +
    v2_diagram_arrow(3.45, 6.075, 3.45, 5.3) +
    v2_diagram_arrow(10.55, 6.075, 10.55, 5.3) +
    v2_diagram_arrow(3.45, 3.8, 4.8, 2.875) +
    v2_diagram_arrow(10.55, 3.8, 9.2, 2.875)
}

v2_dag_plot <- function() {
  # The joint baseline node avoids imposing a causal order among its components.
  # Dashed U paths describe possible violations of the response-model assumption.
  ggplot2::ggplot() +
    ggplot2::coord_cartesian(xlim = c(0, 14), ylim = c(0.85, 8.8), clip = "off") +
    v2_diagram_theme() +
    ggplot2::labs(
      title = "DAG for observed follow-up and inverse-probability weighting",
      subtitle = "L contains only information available at the origin interview; R records next-wave response.",
      caption = paste0(
        "HED uses a 5+/4+ proxy; it is not an observed last-30-day indicator.\n",
        "Dashed U paths represent possible violations of MAR. Weighted covariate balance cannot establish MAR."
      )
    ) +
    ggplot2::annotate(
      "rect", xmin = 0.5, xmax = 5.5, ymin = 1.55, ymax = 6.95,
      fill = "#E8F5F1", colour = "#A7CCC0", linewidth = 0.55
    ) +
    ggplot2::annotate(
      "text", x = 3, y = 6.5, label = "L: information at the origin",
      fontface = "bold", size = 4.1, colour = "#17324D", family = "sans"
    ) +
    ggplot2::annotate(
      "text", x = 3, y = 5.65,
      label = "Age, sex and education\nEmployment, region and PHQ-2",
      size = 3.55, colour = "#253F53", family = "sans", lineheight = 1.15
    ) +
    ggplot2::annotate(
      "segment", x = 0.95, xend = 5.05, y = 4.85, yend = 4.85,
      colour = "#BDD9CF", linewidth = 0.45
    ) +
    ggplot2::annotate(
      "text", x = 3, y = 4.15,
      label = "State, quantity and past drinking\n5+/4+ HED proxy",
      size = 3.55, colour = "#253F53", family = "sans", lineheight = 1.15
    ) +
    ggplot2::annotate(
      "segment", x = 0.95, xend = 5.05, y = 3.45, yend = 3.45,
      colour = "#BDD9CF", linewidth = 0.45
    ) +
    ggplot2::annotate(
      "text", x = 3, y = 2.65,
      label = "Origin wave and interval length\nPrior panel participation",
      size = 3.55, colour = "#253F53", family = "sans", lineheight = 1.15
    ) +
    v2_diagram_box(
      8.3, 8, 3.5, 1.1, "U: unmeasured causes",
      "Potential residual selection",
      fill = "#FCEFEA", border = "#D8AE9B", body_size = 3.2,
      title_offset = 0.23, body_offset = -0.2
    ) +
    v2_diagram_box(
      8.3, 5.7, 3.5, 1.3, "R: next-wave response",
      "Follow-up interview\nobserved",
      fill = "#FFF4DE", border = "#DDC28D",
      title_offset = 0.29, body_offset = -0.16
    ) +
    v2_diagram_box(
      8.3, 2.9, 3.5, 1.3, "Y: next-wave consumption",
      "Drinking participation\nand positive quantity",
      fill = "#EAF3FB", border = "#B4C9DB", title_size = 3.5,
      title_offset = 0.29, body_offset = -0.16
    ) +
    v2_diagram_box(
      12.15, 4.3, 2.7, 1.7, "Observed outcome",
      "Y is available\nonly when\nR = 1",
      fill = "#F0EDFA", border = "#C6BCDF", title_size = 3.6,
      title_offset = 0.31, body_offset = -0.12
    ) +
    v2_diagram_arrow(5.5, 5.25, 6.55, 5.7) +
    v2_diagram_arrow(5.5, 3.35, 6.55, 2.9) +
    v2_diagram_arrow(8.3, 7.45, 8.3, 6.35, colour = "#B77C61", dashed = TRUE) +
    v2_diagram_arrow(6.55, 8, 6.05, 8, colour = "#B77C61", dashed = TRUE, head = FALSE) +
    v2_diagram_arrow(6.05, 8, 6.05, 3.25, colour = "#B77C61", dashed = TRUE, head = FALSE) +
    v2_diagram_arrow(6.05, 3.25, 6.55, 3.25, colour = "#B77C61", dashed = TRUE) +
    v2_diagram_arrow(10.05, 5.7, 10.8, 4.7) +
    v2_diagram_arrow(10.05, 2.9, 10.8, 3.9)
}

message(sprintf(
  "TSM v2 diagram functions loaded in %.3f minutes.",
  as.numeric(difftime(Sys.time(), .t0, units = "mins"))
))
