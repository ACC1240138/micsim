# _eps — Encuesta de Protección Social (EPS)

Microdatos **cifrados** en `eps.tar.xz.enc` (115 `.dta`, carpeta interna `eps/`, misma estructura de carpetas que el original). Se leen con `acc_data()`:

```r
source(here::here("_tools", "acc_data.R"))
eps_root <- acc_data("_eps/eps.tar.xz.enc")   # carpeta eps/ descifrada en tempdir()
```

`eps.tar.xz.enc.md5.csv` lista cada archivo con su tamaño y md5 (los mismos del original).

## Rondas

Terreno y tamaño según `__andres_control/eps_alcohol_prevalencia_persistencia_informe.md` (§2) y los informes de cada ronda (en `docs/`).

| Carpeta en el paquete | Ronda | Terreno | Entrevistados vivos | Nota |
|---|---|---|---|---|
| `2012/` (21 archivos) | V | — | 15.998 registros | No contiene F13–F15 (alcohol) en los archivos entregados; el dossier oficial desaconseja inferencia con esta ronda (p. 23) |
| `2015/` (17) | VI | marzo–agosto 2016 | 16.906 | Módulos A/F y `factor_EPS2015`; sin UPM/estratos públicos |
| `Bases y Documentos EPS 2020/2020/` (38) y `Factores de Expansion EPS 2020/` (10) | VII | presencial 14-dic-2019 a 22-mar-2020; telefónica (continuidad y reentrevista) 2.º semestre 2020 | presencial 7.800; continuidad 5.031; reentrevista 2.082 | Sin refresco: pesos calibrados a 23+. La telefónica mide «menos/igual/más de lo habitual». Reentrevista se solapa con presencial: no sumar las tres bases |
| `Bases de datos EPS VIII Ronda/` (29: `BBDD_VIVOS` 19, `BBDD_FALL` 3, `BBDD_PSD` 3, `FACT_EXP` 4) | VIII | 11-oct-2023 a 10-jun-2024 | 15.788 | Refresco, cobertura 18+, pesos XS y panel, UPM/estratos. «2023» no significa entrevistas solo en 2023 |

## Documentos (`docs/`, sin cifrar)

PDF, libros de códigos y diccionarios, con la misma estructura interna que el original:

- `2012/`: dossier de resultados, factores de expansión, guía técnica, informes (Casas, Heeringa, Marshall, supervisión STATCOM).
- `2015/instrucciones/`: cuestionarios, informes de campo, imputaciones, factores y manual de usuarios.
- `Bases y Documentos EPS 2020/`: libros de códigos (`.xlsx`), guía para usuario, informes de campo, imputación, codificación y metodología, y los cuestionarios de la VII ronda.
- `Bases de datos EPS VIII Ronda/Diccionario de variables VIII EPS.xlsx` y `Documentos EPS VIII Ronda/` (informe final, técnico, trabajo de campo, tratamiento de datos, cuadernillos).

## Notas (`notes/`)

Extracciones de texto de esos PDF (`tmp/eps_audit/*.txt`, numeradas) y `calvo_refinement.md`.
