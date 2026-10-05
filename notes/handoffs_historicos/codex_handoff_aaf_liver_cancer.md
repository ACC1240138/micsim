# Handoff Codex: AAF liver cancer / Shields / InterMAHP

## Contexto

Proyecto local:

- `c:\Users\nDP\Desktop\ACC1240138_private`
- Notebook activo: `__andres_control/revision_datos.ipynb`
- Scripts relevantes:
  - `__andres_control/confint_paf_parallel.R`
  - `__andres_control/confint_paf_hed_parallel.R`
  - `Sex-and-age-differences-in-alcohol-attributable-mortality-in-Chile-between-2008-and-2022-main/Paper mortality trends.R`
- Archivos AAF:
  - `__andres_control/aaf_male_ags.xlsx`
  - `__andres_control/aaf_female_ags.xlsx`
  - Originales JRT en carpeta `Sex-and-age-differences...`
- PDF clave:
  - `__andres_control/_bib/Material supplementario Shields.pdf`
  - `__andres_control/_bib/intermahp-guide.pdf`

## Problema original

En resultados nuevos AGS aparecen muchos `UL = 1`.

Confirmado:

- Male AGS: `UL = 1` para `Liver Cancer` y `Oesophagus Cancer`.
- Female AGS: `UL = 1` para `Liver Cancer`, `Oesophagus Cancer`, `Acute Pancreatitis`, y varios `Ischaemic Heart Disease`.
- Archivos originales JRT no tenían esos `UL = 1` exactos.

## Punto importante 1: función antigua de liver cancer tenía argumentos al revés

Código antiguo:

```r
rr_lican_fun <- function(betas, x){
  exp(betas[1]*x - betas[2]*x**2)
}
```

Pero `confint_paf_vcov()` llama así:

```r
rr_sim <- rr_function(x_vals, beta_sim)
```

Entonces la función antigua recibía:

- `betas = x_vals`
- `x = beta_sim`

Prueba mínima:

```r
x_vals <- seq(0.1, 150, length.out = 1500)
beta_sim <- c(0.00742949, 0.0000148593)

rr_old <- function(betas, x){
  exp(betas[1]*x - betas[2]*x^2)
}

rr_new <- function(x, betas){
  exp(betas[1]*x - betas[2]*x^2)
}

length(rr_old(x_vals, beta_sim)) # 2
length(rr_new(x_vals, beta_sim)) # 1500
```

Resultado:

- La versión vieja devuelve largo 2.
- La versión correcta devuelve largo 1500.
- R no siempre falla porque recicla vectores.

## Punto importante 2: si uso la versión correcta, los intervalos pueden explotar

La función correcta InterMAHP/Corrao es:

```r
rr_lican_fun <- function(x, betas){
  exp(betas[1] * x - betas[2] * x^2)
}
```

Eso usa toda la grilla de consumo.

Pero si además se usa esta matriz:

```r
cov_matrix_lican <- matrix(c(
  0.000003097, 0,
  0, 0.000003097
), nrow = 2, byrow = TRUE)
```

hay problema conceptual: esa varianza `0.000003097` viene de Shields/Turati para un modelo de un beta, no para la curva cuadrática InterMAHP/Corrao de dos betas.

## Punto importante 3: de dónde vienen los betas antiguos

Estos:

```r
b1_lican <- 0.00742949
b2_lican <- 0.0000148593
```

vienen de InterMAHP / Corrao et al. 2004.

Función:

```r
RR(x) = exp(0.00742949*x - 0.0000148593*x^2)
```

En el notebook aparece como:

```text
Corrao et al. 2004 via InterMAHP
```

InterMAHP además usa para former drinkers:

```r
RR_FD men = 1.54
RR_FD women = 2.28
```

## Punto importante 4: Shields usa otros parámetros

En el suplemento Shields, liver cancer dice:

```r
RR_CD = exp(x * beta1)
beta1 = 0.005041
Variance(beta1) = 0.000003097
```

Former drinkers:

```r
RR_FD male = 2.23
RR_FD female = 2.68
```

Entonces Shields liver cancer NO usa la curva cuadrática de InterMAHP.

Si se quiere usar Shields, usar:

```r
b_lican_shield <- 0.005041
var_lican_shield <- 0.000003097

rr_lican_fd_male <- 2.23
rr_lican_fd_fem <- 2.68

rr_lican_fun_shield <- function(x, b) {
  exp(x * b)
}
```

## Punto importante 5: error al correr código Shields

Había dos problemas de nombres.

La función antigua `confint_paf()` está definida como:

```r
confint_paf <- function(gamma, beta, var_beta, p_abs, rr_form, p_form, rr_function)
```

No acepta:

```r
betas
cov_matrix
rr_fd
```

Acepta:

```r
beta
var_beta
rr_form
```

Además `confint_paf()` devuelve:

```r
Point_Estimate
Lower_CI
Upper_CI
```

No devuelve:

```r
point_estimate
lower_ci
upper_ci
```

## Punto importante 6: posible razón por la que seguía fallando

En el proyecto hay más de una función llamada `confint_paf`.

Otra versión está en:

```text
FONDECYT-REGULAR--main/PAF calculation.R
```

y está definida así:

```r
confint_paf <- function(gamma, beta, var_beta, p_abs, p_form)
```

Esa versión NO acepta:

```r
rr_form
rr_function
```

Diagnóstico:

```r
args(confint_paf)
```

Si muestra:

```r
function(gamma, beta, var_beta, p_abs, p_form)
```

está cargada la función equivocada.

La correcta debería mostrar:

```r
function(gamma, beta, var_beta, p_abs, rr_form, p_form, rr_function)
```

## Recomendación práctica

Para evitar ambigüedad, usar `confint_paf_parallel()` desde:

```r
source("__andres_control/confint_paf_parallel.R")
```

Y llamar Shields así:

```r
result <- tryCatch({
  confint_paf_parallel(
    gamma = gamma_fit,
    beta = b_lican_shield,
    var_beta = var_lican_shield,
    p_abs = p_abs,
    p_form = p_form,
    rr_form = rr_lican_fd_fem,
    rr_function = rr_lican_fun_shield,
    x = x_vals,
    use_parallel = FALSE,
    rng_parallel = FALSE
  )
}, error = function(e) {
  message("ERROR: ", conditionMessage(e))
  NULL
})
```

Para hombres cambiar:

```r
rr_form = rr_lican_fd_male
```

Al guardar resultados:

```r
if (!is.null(result) && !is.null(result$Point_Estimate)) {
  lican_female4[i, paste0("Fem", j, "_point")] <- result$Point_Estimate
  lican_female4[i, paste0("Fem", j, "_lower")] <- result$Lower_CI
  lican_female4[i, paste0("Fem", j, "_upper")] <- result$Upper_CI
}
```

`confint_paf_parallel()` devuelve nombres con mayúsculas para el caso lineal:

```r
Point_Estimate
Lower_CI
Upper_CI
```

`confint_paf_vcov_parallel()` devuelve nombres con minúsculas:

```r
point_estimate
lower_ci
upper_ci
```

## Debug obligatorio

No usar esto mientras se depura:

```r
error = function(e) NULL
```

Porque esconde el error.

Usar:

```r
error = function(e) {
  message("ERROR: ", conditionMessage(e))
  NULL
}
```

## Resumen cavernícola

Hay dos mundos:

1. InterMAHP/Corrao:

```r
RR = exp(0.00742949*x - 0.0000148593*x^2)
RR_FD male = 1.54
RR_FD female = 2.28
```

2. Shields/Turati:

```r
RR = exp(0.005041*x)
Variance(beta) = 0.000003097
RR_FD male = 2.23
RR_FD female = 2.68
```

No mezclar:

- No usar la varianza de Shields con los dos betas de InterMAHP.
- No usar `confint_paf_vcov` si el modelo tiene un solo beta.
- No usar nombres minúsculos si la función devuelve mayúsculas.
- No confiar en `tryCatch(..., error = function(e) NULL)` porque tapa todo.

