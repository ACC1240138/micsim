# Handoff caveman para Codex casa

Fecha: 2026-05-15

Proyecto local original:

```text
c:\Users\nDP\Desktop\ACC1240138_private
```

Notebook principal:

```text
__andres_control/revision_datos.ipynb
```

Scripts importantes:

```text
Sex-and-age-differences-in-alcohol-attributable-mortality-in-Chile-between-2008-and-2022-main/Paper mortality trends.R
__andres_control/confint_paf_parallel.R
__andres_control/confint_paf_hed_parallel.R
__andres_control/compare_aaf_against_xlsx.R
```

Archivo JRT importante:

```text
Sex-and-age-differences-in-alcohol-attributable-mortality-in-Chile-between-2008-and-2022-main/Mortality Estimates.xlsx
```

## Problema grande

Se compararon estimaciones nuevas AGS contra estimaciones JRT.

Resultado:

```text
different     1163
only_in_mine    14
same            11
```

Esto NO parece redondeo.

Esto parece mezcla de:

1. Correcciones reales del codigo.
2. Cambios en AAF/RR.
3. Cambios en definiciones ICD-10.
4. Duplicados en pipeline original.
5. Posibles errores viejos de JRT que AGS corrigio.

## Respuesta corta para Andres

Las diferencias son grandes, pero no son automaticamente malas.

Son demasiado grandes para decir "solo redondeo".

Hay que decir:

```text
Las diferencias con JRT no corresponden a errores de redondeo.
Las mayores discrepancias se concentran en causas donde se corrigieron
funciones de riesgo relativo, parametros de ex-bebedores o definiciones
ICD-10, especialmente enfermedad hipertensiva, enfermedad isquemica del
corazon y cancer colorrectal. Por tanto, estos resultados son una version
revisada/corregida del pipeline, no una reproduccion exacta de JRT.
```

## Comparacion por enfermedad

Mayores diferencias:

```text
Ischaemic Heart Disease       mean_abs_diff 62.2, max 632
Hypertensive Heart Disease    mean_abs_diff 57.8, max 605
Colon and rectum Cancer       mean_abs_diff 55.8, max 445
Liver Cancer                  mean_abs_diff 44.1, max 204
Oesophagus Cancer             mean_abs_diff 19.4, max 144
Liver Cirrhosis               mean_abs_diff 14.2, max 82
```

Diferencias chicas:

```text
Epilepsy
Ischaemic Stroke
HIV
Lip and Oral Cavity Cancer
Tuberculosis
Intentional Injuries
```

Pero ojo: ninguna enfermedad queda 100% igual.

## Bug 1: loop por sexo no filtraba sexo

Codigo problematico en `Paper mortality trends.R`:

```r
for (disease_name in names(disease_filters)) {
  filter_info <- disease_filters[[disease_name]]
  filter_col <- filter_info$filter_col
  genders <- filter_info$genders

  for (gender in genders) {
    mortality_result <- def %>%
      group_by(year, gender, age_group) %>%
      count(.data[[filter_col]]) %>%
      filter(.data[[filter_col]] == 1) %>%
      left_join(aaf_long[aaf_long$disease == disease_name, ],
                by = c("year", "age_group", "gender")) %>%
      mutate(
        mort = point * n,
        ll_mort = lower * n,
        up_mort = upper * n,
        disease = disease_name
      ) %>%
      select(year, age_group, gender, disease, mort, ll_mort, up_mort)

    all_mortality_results[[paste(disease_name, gender, sep = "_")]] <- mortality_result
  }
}
```

Problema:

```text
El loop dice "voy por sexo", pero no filtra sexo.
Entonces en cada vuelta calcula hombres y mujeres juntos.
Resultado: filas repetidas.
```

Impacto:

```text
Si despues haces distinct por year/age/gender/disease: bajo impacto en punto.
Si despues sumas sin deduplicar: alto impacto, infla totales.
```

Version mas segura:

```r
mortality_results <- purrr::imap_dfr(disease_filters, function(filter_info, disease_name) {
  filter_col <- filter_info$filter_col

  purrr::map_dfr(filter_info$genders, function(gender_i) {
    def |>
      dplyr::filter(
        gender == gender_i,
        year %in% unique(aaf_long$year)
      ) |>
      dplyr::group_by(year, gender, age_group) |>
      dplyr::summarise(
        n = sum(.data[[filter_col]] == 1, na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::filter(n > 0) |>
      dplyr::inner_join(
        aaf_long |>
          dplyr::filter(disease == disease_name, gender == gender_i) |>
          dplyr::distinct(year, age_group, gender, disease, .keep_all = TRUE),
        by = c("year", "age_group", "gender")
      ) |>
      dplyr::mutate(
        mort = point * n,
        ll_mort = lower * n,
        up_mort = upper * n,
        disease = disease_name
      ) |>
      dplyr::select(year, age_group, gender, disease, mort, ll_mort, up_mort)
  })
})
```

## Bug 2: anos pares vs impares

`def` tiene anos anuales.

`aaf_long` tiene anos:

```text
2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022
```

Si haces `left_join`, anos impares quedan con AAF = NA.

Mejor:

```r
year %in% unique(aaf_long$year)
```

y/o usar:

```r
inner_join(...)
```

## Bug 3: aaf1 con columnas por posicion es fragil

Codigo viejo:

```r
def <- def %>% mutate(aaf1 = rowSums(def[,6:14]))
```

Problema:

```text
Si cambia orden de columnas, se rompe silencioso.
```

Mejor:

```r
def <- def %>%
  dplyr::mutate(
    aaf1 = rowSums(
      dplyr::across(c(
        des_men, deg_nerv, polineu, cardiomio, pancreati_oh,
        gastrit, enven_acc, enven_int, enven_indet
      )),
      na.rm = TRUE
    )
  )
```

## Bug 4: ri_inj tenia DIAG2 dos veces

Viejo:

```r
ri_inj = if_else(DIAG2 %in% ri_codes | DIAG2 %in% ri_codes, 1, 0)
```

Correcto:

```r
ri_inj = if_else(DIAG1 %in% ri_codes | DIAG2 %in% ri_codes, 1, 0)
```

Impacto:

```text
Afecta Road Injuries.
Si se quiere reproducir JRT exacto, dejar bug.
Si se quiere pipeline corregido, corregir y documentar.
```

## Bug 5: crcan_codes mal escrito

Viejo:

```r
crcan_codes <- c(paste0("C18, 0:9"), "C19X", "C20X")
```

Eso produce literal:

```text
"C18, 0:9"
```

Correcto:

```r
crcan_codes <- c(paste0("C18", 0:9), "C19X", "C20X")
```

Impacto:

```text
Muy alto para Colon and rectum Cancer.
Puede explicar diferencias gigantes, porque C180-C189 quedan fuera si codigo esta malo.
```

## AAF / RR: errores importantes

### Other pharyngeal cancer / opcan

JRT calcula `opcan` usando parametros `locan`.

Ahora mismo impacto numerico bajo si los parametros son identicos.

Impacto de trazabilidad alto:

```text
Parece copiar/pegar.
Documentar.
```

### Oesophagus cancer

Matriz original JRT no simetrica:

```r
cov_matrix_oescan <- matrix(c(
  1.525706e-7, -6.885205e-13,
  -0.0000000127, 0.000002953
), nrow = 2, byrow = TRUE)
```

Version corregida simetrica:

```r
cov_matrix_oescan <- matrix(c(
  1.525706e-7, -6.885205e-13,
  -6.885205e-13, 2.953e-6
), nrow = 2, byrow = TRUE)
```

Impacto:

```text
Principalmente IC.
Alto si se simulan betas con matriz conjunta.
```

### Epilepsy female

JRT no tenia 2020 en `epi_female`.

AGS agrego 2020.

Impacto:

```text
Solo aparece diferencia/only_in_mine para Epilepsy female 2020.
```

### HHD mujeres

JRT tenia cosas muy sospechosas:

```r
result[x >= 0 & x < 18.9517] <- exp(1)
result[x >= 75] <- exp(-0.9649937)
```

AGS cambio a:

```r
result[x >= 0 & x < 18.9517] <- exp(0)
```

y para 75+ usa expresion de Shield.

Impacto:

```text
Muy alto.
Explica grandes diferencias en Hypertensive Heart Disease mujeres.
```

### IHD mujeres

JRT:

```r
rr_ihd_fem <- function(betas, x){
  exp(-betas[1]*x + betas[2]*x*log(x))
}
```

Pero `b1_ihd_fem` ya es negativo:

```r
b1_ihd_fem <- -0.0525288
```

Entonces `-betas[1]` vuelve positivo el primer termino.

AGS:

```r
rr_ihd_fem <- function(x, betas){
  exp(betas[1] * x + betas[2] * x * log(x))
}
```

Impacto:

```text
Muy alto.
Explica grandes diferencias en Ischaemic Heart Disease mujeres.
```

Ademas JRT uso SE como varianza:

```r
cov_ihd_fem <- matrix(c(0.032510, 0, 0, 0.007925), ...)
```

AGS usa cuadrados:

```r
cov_ihd_fem <- matrix(c(0.032510^2, 0, 0, 0.007925^2), ...)
```

Impacto:

```text
Mas en IC que en punto.
```

### Colorrectal cancer FD RR swapped

JRT:

```r
rr_crcan_fd_fem <- 1.05
rr_crcan_fd_male <- 2.19
```

AGS:

```r
rr_crcan_fd_fem <- 2.19
rr_crcan_fd_male <- 1.05
```

Impacto:

```text
Alto en punto.
Pero diferencia gigante de colon/rectum probablemente tambien viene de crcan_codes.
```

### Diabetes male vcov

JRT/AGS usan misma vcov que female:

```r
vcov_diabetes_male <- matrix(c(
  0.1681525, -0.2240129,
  -0.2240129, 0.29964479
), nrow = 2, byrow = TRUE)
```

Impacto:

```text
Probablemente mas en IC que en punto.
Revisar fuente.
```

### Acute pancreatitis female

JRT funcion vieja tenia indexaciones mezcladas dentro de tramos.

AGS reescribio `rr_panc_fem`.

Impacto:

```text
Medio/alto en mujeres.
Revisar contra fuente antes de defender fuerte.
```

### Road injuries / var_b1_ri

JRT:

```r
var_b1_ri <- 0.001687^2
```

AGS:

```r
var_b1_ri <- 0
```

Razon:

```text
No se encontro SE verificable para beta = 0.00455 en esa escala.
```

Impacto:

```text
Principalmente IC.
El punto deberia cambiar poco, salvo simulacion.
```

## Liver cancer: dos mundos, no mezclar

### Mundo InterMAHP / Corrao

```r
RR = exp(0.00742949*x - 0.0000148593*x^2)
RR_FD male = 1.54
RR_FD female = 2.28
```

Funcion correcta:

```r
rr_lican_fun <- function(x, betas){
  exp(betas[1] * x - betas[2] * x^2)
}
```

### Mundo Shields / Turati

```r
RR = exp(0.005041*x)
Variance(beta) = 0.000003097
RR_FD male = 2.23
RR_FD female = 2.68
```

Funcion:

```r
rr_lican_fun_shield <- function(x, b) {
  exp(x * b)
}
```

Regla:

```text
No usar varianza de Shields con dos betas de InterMAHP.
No usar confint_paf_vcov si el modelo tiene un solo beta.
```

## Confint: nombres de salida diferentes

`confint_paf_parallel()` devuelve:

```text
Point_Estimate
Lower_CI
Upper_CI
```

`confint_paf_vcov_parallel()` devuelve:

```text
point_estimate
lower_ci
upper_ci
```

Esto rompe guardado de resultados si se revisa el nombre equivocado.

## Debug importante

No usar:

```r
error = function(e) NULL
```

Porque tapa todo.

Usar:

```r
error = function(e) {
  message("ERROR: ", conditionMessage(e))
  NULL
}
```

## Como diagnosticar fuente de diferencia

Pregunta clave:

```text
La diferencia viene de AAF o de conteo de muertes?
```

Funcion util:

```r
audit_mort_row <- function(disease_i, gender_i, age_i, year_i) {
  filter_col <- disease_filters[[disease_i]]$filter_col

  n_deaths <- def |>
    dplyr::filter(year == year_i, gender == gender_i, age_group == age_i) |>
    dplyr::summarise(n = sum(.data[[filter_col]] == 1, na.rm = TRUE)) |>
    dplyr::pull(n)

  comparison |>
    dplyr::ungroup() |>
    dplyr::filter(
      year == year_i,
      age_group == age_i,
      gender == gender_i,
      disease == disease_i
    ) |>
    dplyr::mutate(
      deaths = n_deaths,
      implied_aaf_mine = mort_mine / deaths,
      implied_aaf_jrt = mort_jrt / deaths
    )
}
```

Interpretacion:

```text
Si implied_aaf_mine != implied_aaf_jrt:
  diferencia viene de AAF/RR.

Si implied_aaf_mine parecido a implied_aaf_jrt pero mort cambia:
  diferencia viene de conteo ICD/deaths.
```

## Para ver enfermedades sin diferencias

```r
comparison |>
  dplyr::group_by(disease) |>
  dplyr::summarise(
    n_same = sum(status == "same"),
    n_diff = sum(status == "different"),
    n_only_mine = sum(status == "only_in_mine"),
    n_only_jrt = sum(status == "only_in_jrt"),
    .groups = "drop"
  ) |>
  dplyr::arrange(n_diff)
```

Para ver filas iguales:

```r
comparison |>
  dplyr::filter(status == "same") |>
  dplyr::arrange(disease, year, gender, age_group)
```

## Comparacion OMS 2024 vs reporte 2016 corregida

Fecha: 2026-05-29.

Archivos usados:

```text
tabla_aaf_who2024_sexo_causa_ano.csv
tabla_apa_aaf_cancer_sexo_edad.md
```

Se compararon solo celdas comunes entre ambas tablas:

```text
416 celdas comunes
7 canceres
8 anos
4 grupos etarios
sexo cuando aplica
```

Diferencia definida como:

```text
OMS 2024 - reporte 2016
```

Resumen actual:

| Causa / sexo | OMS 2024 | Reporte 2016 | Delta medio |
|---|---:|---:|---:|
| Breast, mujeres | 0.03-0.07 | 0.15-0.22 | -0.139 |
| Stomach, mujeres | 0.06-0.12 | 0.16-0.27 | -0.116 |
| Stomach, hombres | 0.06-0.09 | 0.08-0.11 | -0.020 |
| Liver, mujeres | 0.21-0.35 | 0.15-0.20 | +0.114 |
| Liver, hombres | 0.20-0.29 | 0.16-0.19 | +0.068 |
| Colorectal, mujeres | 0.04-0.10 | 0.14-0.20 | -0.110 |
| Colorectal, hombres | 0.25-0.32 | 0.16-0.19 | +0.113 |
| Oesophagus, mujeres | 0.08-0.21 | 0.16-0.26 | -0.073 |
| Oesophagus, hombres | 0.28-0.38 | 0.26-0.35 | +0.018 |
| Oral cavity/pharynx, mujeres | 0.15-0.36 | 0.21-0.36 | -0.036 |
| Oral cavity/pharynx, hombres | 0.48-0.60 | 0.39-0.52 | +0.073 |
| Pancreatic, mujeres | 0.07-0.13 | 0.13-0.17 | -0.048 |
| Pancreatic, hombres | 0.07-0.09 | 0.08-0.11 | -0.016 |

Conclusion:

```text
La narrativa general casi no cambio despues de corregir la tabla.
Los signos y magnitudes principales se mantienen.
```

Lo que sigue fuerte:

```text
Breast mujeres baja mucho con OMS 2024.
Stomach mujeres baja mucho con OMS 2024.
Liver sube con OMS 2024 en ambos sexos, mas en mujeres.
Colorectal cambia en direccion opuesta por sexo:
  mujeres bajan aprox -0.11
  hombres suben aprox +0.11
Oral cavity/pharynx:
  hombres suben aprox +0.07
  mujeres bajan aprox -0.04
Oesophagus mujeres baja aprox -0.07.
Pancreatic mujeres baja aprox -0.05.
```

Lo que hay que matizar respecto al texto antiguo:

```text
Stomach hombres:
  diferencia pequena, promedio -0.02, no presentarlo como cambio mayor.

Oesophagus hombres:
  diferencia pequena, promedio +0.018, IC solapan completamente.

Pancreatic hombres:
  diferencia minima, promedio -0.016.
```

Frase corta:

```text
No cambio la conclusion central. Lo que si cambia es el enfasis:
Stomach hombres, Oesophagus hombres y Pancreatic hombres deben describirse
como diferencias pequenas o marginales. Las diferencias grandes actuales son
Breast mujeres, Stomach mujeres, Liver y Colorectal con patron opuesto por
sexo.
```

## Decision metodologica

Hay dos caminos.

### Camino A: reproducir JRT exacto

Mantener bugs JRT:

```text
No corregir crcan_codes.
No corregir ri_inj.
No corregir HHD/IHD mujeres.
No corregir swaps FD RR.
No sacar duplicados.
Usar funciones originales JRT.
```

Sirve para:

```text
Reproduccion exacta historica.
```

### Camino B: pipeline corregido AGS

Corregir bugs:

```text
Filtrar sexo en loop.
Deduplicar.
Corregir crcan_codes.
Corregir ri_inj.
Corregir funciones RR sospechosas.
Separar InterMAHP de Shields.
Documentar cambios.
```

Sirve para:

```text
Estimacion revisada y defendible.
```

## Frase recomendada para paper

Spanish:

```text
Las diferencias entre nuestras estimaciones y las de JRT no son atribuibles
a redondeo. Las mayores discrepancias se concentraron en causas especificas,
especialmente enfermedades cardiovasculares y canceres seleccionados. Algunas
diferencias se explican por correcciones en las definiciones ICD-10 de causa
de muerte, mientras que otras reflejan correcciones en funciones de riesgo
relativo, parametros de ex-bebedores y matrices de incertidumbre. En
consecuencia, los resultados deben interpretarse como estimaciones obtenidas
mediante un pipeline revisado/corregido, no como una reproduccion exacta de
los resultados originales de JRT.
```

English:

```text
Differences between our estimates and JRT's estimates were not attributable
to rounding. The largest discrepancies were concentrated in selected causes,
especially cardiovascular diseases and selected cancers. Some differences
arose from corrections to ICD-10 cause definitions, while others reflect
corrections to relative-risk functions, former-drinker parameters, and
uncertainty matrices. Therefore, results should be interpreted as estimates
from a revised/corrected attribution pipeline rather than an exact
reproduction of JRT's original outputs.
```

## Prompt para Codex casa

Pegar esto al inicio:

```text
Estoy trabajando en un pipeline de mortalidad atribuible a alcohol en Chile.
Quiero comparar y depurar diferencias entre mis estimaciones AGS y las de JRT.
No asumas que JRT es gold standard: puede tener bugs. Primero separa si la
diferencia viene de AAF/RR o de conteo ICD/deaths. Mantener dos modos mentales:
1) reproducir JRT exacto, 2) pipeline corregido defendible.

Usa el archivo de handoff caveman como contexto. Prioriza:
- HHD mujeres
- IHD mujeres
- Colon and rectum Cancer
- Liver Cancer
- Oesophagus Cancer
- Road Injuries
- duplicates por loop de sexo
```
