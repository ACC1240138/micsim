# Sensibilidad al redondeo de B2, Tabla 5 (PUC), mortalidad IHD hombres

Fecha: 2026-11-10. Script aparte; no modifica notebooks ni cambia la fuente principal (IHD: OMS/Adam).

## Qué se evaluó

- Función: `RR(x) = exp(B1*sqrt(x) + B2*x^3)`, x en g/día, B1 = −0,046271, B2 publicado = 0,000001.
- Valores de B2: 0,50e-6; 0,75e-6; 1,00e-6 (publicado); 1,25e-6; 1,50e-6. El 2,00e-6 aparece aparte, solo como cota en caso de truncamiento.
- Todo lo demás queda idéntico a `expand_pif2`: B1, RR de exbebedor 1,25, modo cap para HED, grilla x 0,1–150, exposición (`aaf_engine_inputs_bundle_20261007.rds`), 22 escenarios con λ = 0 / 0,5 / 1, 7 años × 4 tramos de edad.
- Fact = 1/3 se guarda pero no se aplica (convención actual). **No está validado.**
- PIF puntual con `aaf_unified.R::pif_point()`. Con el B2 publicado reproduce los 616 PIF guardados en `pif2_pif_results_table5_full_20261008.rds` (diferencia máxima 2,8e-16).

## Precisión impresa

- En el PDF (p. 61) B2 aparece como `0,000001` (se corta en dos líneas: «0,00000» y «1»), con 6 decimales y una sola cifra significativa. EE2 aparece como `0,000000`.
- Con redondeo convencional, B2 ∈ [0,5e-6; 1,5e-6) y EE2 < 0,5e-6. Con truncamiento, B2 ∈ [1e-6; 2e-6).
- El informe no dice cuál de los dos se usó. La tabla tampoco permite distinguirlo.
- EE2 = 0 refleja la precisión impresa; no demuestra que no haya incertidumbre.

## Resultados

Curva (RR):

| B2 | Nadir (g/día) | RR vuelve a 1 (g/día) | RR a 100 g | RR a 125 g | RR a 150 g |
|---|---|---|---|---|---|
| 0,50e-6 | 47 | 97 | 1,04 | 1,58 | 3,1 |
| 1,00e-6 (pub.) | 36 | 73 | 1,71 | 4,20 | 16,6 |
| 1,50e-6 | 31 | 62 | 2,82 | 11,2 | 89,6 |
| 2,00e-6 (trunc.) | 27 | 56 | 4,65 | 29,6 | 485 |

- Bajo ~30 g/día las curvas casi coinciden (RR a 20 g: 0,816–0,823). La diferencia está toda en el tramo alto.
- En hombres que hacen HED, el 26–32 % de la densidad de consumo está sobre 60 g/día y el 8–13 % sobre 100 g/día (2024). Ese tramo pesa mucho en el resultado.

PIF puntual medio (28 celdas, sin ponderar):

| Escenario | 0,50e-6 | 0,75e-6 | 1,00e-6 (pub.) | 1,25e-6 | 1,50e-6 | OMS/Adam |
|---|---|---|---|---|---|---|
| Volumen −10 % | 0,008 | 0,023 | 0,050 | 0,100 | 0,181 | 0,004 |
| Volumen −30 % | 0,012 | 0,038 | 0,083 | 0,154 | 0,262 | 0,006 |
| HED −50 %, λ = 0 | 0,020 | 0,017 | 0,015 | 0,012 | 0,010 | 0,016 |
| HED −50 %, λ = 1 | 0,022 | 0,033 | 0,052 | 0,083 | 0,129 | 0,019 |
| Combinado 30/50, λ = 0 | 0,032 | 0,057 | 0,099 | 0,168 | 0,274 | 0,024 |

AAF basal media: 0,064 / 0,092 / 0,138 / 0,210 / 0,317 en el rango de redondeo (0,610 con 2e-6).

- **Signo:** ninguna celda da un PIF negativo con ningún B2 (0 de 588 celdas fuera de la línea base).
- **Magnitud:** en el rango de redondeo, el PIF de una misma celda cambia una mediana de 8,3 veces entre los extremos (rango 0,44–54). El valor publicado queda ~3 veces sobre el extremo bajo y ~2,8 veces bajo el alto. En volumen −10 %, el PIF medio va de 0,008 a 0,18 (×23).
- **Conclusiones:** el orden de los escenarios cambia dentro del rango de redondeo. Con 0,5e-6, HED −50 % (λ = 0) supera a volumen −30 % (0,020 frente a 0,012); con el publicado es al revés (0,015 frente a 0,083). El PIF de HED con λ = 0 baja cuando B2 sube, mientras que los de volumen suben. Así, la política que la Tabla 5 señala como más efectiva en IHD hombres depende del redondeo.
- Lo que sí se mantiene en todo el rango: Tabla 5 da PIF de volumen mayores que OMS/Adam (×1,9 a ×49).

## Recomendación

Tabla 5 en IHD hombres **no permite una sensibilidad interpretable** con la precisión publicada. El signo es estable, pero la magnitud cambia un orden de magnitud y el ranking de políticas se invierte dentro del rango de redondeo. Sugerencias:

1. Mantener OMS/Adam como fuente principal de IHD (sin cambios).
2. No reportar cifras de Tabla 5 para IHD hombres como sensibilidad sustantiva. Si se muestran, que sea como banda de precisión (0,5e-6 a 1,5e-6) y con la advertencia explícita de que dependen del redondeo.
3. Pedir a los autores B2 con todos sus decimales, junto con Fact y vcov.
4. No elegir un B2 para acercar el resultado a OMS ni para forzar monotonía.

## Notas

- Es una sensibilidad a la precisión publicada. No corrige B2, no le asigna una distribución y no es un IC 95 %.
- El −0,99 de rho en IHD mujeres también es un supuesto de sensibilidad, no una covarianza recuperada.
- Dato de contexto (no se usó para elegir B2): la función base OMS/Adam de IHD hombres en `GENERAL_ihd_RR_2018_03_16.R` tiene la misma forma, sobre (x + 0,01)/100. Llevada a x en g/día da B1 ≈ −0,0487 y B2 ≈ 1,55e-6, multiplicados por un factor de edad (beta3). Como el B1 no coincide con el de la Tabla 5 (−0,0463), no es el mismo ajuste. En mujeres, la función base OMS reparametrizada da B1 = −0,05253, que sí coincide con la Tabla 5 (−0,052526), pero B2 difiere (0,01539 frente a 0,01470). Sugiere que la Tabla 5 viene de la misma familia de funciones (Roerecke y Rehm), con algún ajuste propio.
- Los PIF medios no están ponderados por carga; las conclusiones sobre el orden de los escenarios se basan en medias simples.
- Solo PIF puntual; no se corrió el Monte Carlo.

## Archivos

- `sens_b2_ihd_male_table5.R`: cálculo y validación contra los resultados guardados.
- `summarise_b2.R`, `plot_b2.R`: resúmenes y figura.
- `b2_sens_pif_cells.csv`, `b2_sens_aaf_cells.csv`, `b2_sens_rr_curves.csv`, `b2_sens_rr_landmarks.csv`.
- `b2_sens_ihd_male.png`.
