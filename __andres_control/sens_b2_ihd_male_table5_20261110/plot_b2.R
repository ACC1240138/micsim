# Figure: Table 5 IHD-male RR curves and mean volume PIF across the B2 precision range.
.t0 <- base::Sys.time()
B1 <- -0.046271
x <- base::seq(0.1, 150, by = 0.5)
b2 <- c(0.5e-6, 0.75e-6, 1e-6, 1.25e-6, 1.5e-6, 2e-6)
col <- c("#9ecae1", "#6baed6", "#08306b", "#fd8d3c", "#d94801", "#7f7f7f")
lty <- c(1, 1, 1, 1, 1, 3)
r <- utils::read.csv("b2_sens_pif_cells.csv")
grDevices::png("b2_sens_ihd_male.png", width = 2400, height = 1100, res = 200)
graphics::par(mfrow = c(1, 2), mar = c(4.2, 4.2, 2.5, 1))
graphics::plot(NA, xlim = c(0, 150), ylim = c(0, 4), xlab = "Average consumption (g/day)", ylab = "RR (IHD mortality, men)",
               main = "Table 5 IHD men: RR by B2", cex.main = 0.95)
graphics::abline(h = 1, lty = 2, col = "grey50")
for (i in base::seq_along(b2)) graphics::lines(x, base::exp(B1 * base::sqrt(x) + b2[i] * x^3), col = col[i], lwd = base::ifelse(i == 3, 2.6, 1.6), lty = lty[i])
graphics::legend("topleft", bty = "n", cex = 0.75, col = col, lty = lty, lwd = 2,
                 legend = c("0.50e-6 (rounding low)", "0.75e-6", "1.00e-6 (published)", "1.25e-6", "1.50e-6 (rounding high)", "2.00e-6 (truncation only)"))
sc <- c("volume_reduction_10", "volume_reduction_20", "volume_reduction_30")
m <- base::sapply(sc, function(s) base::sapply(b2, function(b) base::mean(r$pif[r$scenario_id == s & base::abs(r$b2 - b) < 1e-12])))
graphics::matplot(b2 * 1e6, m, type = "b", pch = 19, lty = 1, col = c("#c6dbef", "#6baed6", "#08306b"), log = "y",
                  xlab = "B2 (x 1e-6)", ylab = "Mean point PIF (28 cells, log scale)", main = "Volume scenarios: mean PIF by B2", cex.main = 0.95)
graphics::abline(v = c(0.5, 1.5), lty = 2, col = "grey60"); graphics::abline(v = 1, col = "#08306b", lty = 3)
graphics::legend("topleft", bty = "n", cex = 0.75, legend = c("Volume -10%", "Volume -20%", "Volume -30%"), col = c("#c6dbef", "#6baed6", "#08306b"), pch = 19)
grDevices::dev.off()
base::message(base::sprintf("plot_b2 elapsed minutes: %.2f", base::as.numeric(base::difftime(base::Sys.time(), .t0, units = "mins"))))
