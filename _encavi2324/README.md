# ENCAVI 2023–2024

Encuesta Nacional de Calidad de Vida y Salud, Ministerio de Salud, Departamento de Epidemiología
(<https://epi.minsal.cl/bases-de-datos>). El archivo lleva la fecha 2026-07-22 en el nombre; no está registrado de qué
página exacta se descargó.

| Copia interna | Contenido | Lectura |
|---|---|---|
| `20260722_ENCAVI_data.RData.tar.xz.enc` | `20260722_ENCAVI_data.RData` (3.576.155 bytes, md5 `71ddc9fd3e7c69051dc54dbd68d83c09`): objeto `encavi2`, 16.590 personas × 464 variables, 15–100 años, urbano y rural | `load(acc_data("_encavi2324/20260722_ENCAVI_data.RData.tar.xz.enc"))` |
| `manual_de_base_de_datos_encavi_2023_2024.pdf` | Manual de uso y libro de códigos (público, sin cifrar) | — |

Empaquetado con `acc_pack()` el 2026-10-27; la copia descifrada tiene el mismo md5 que el original. El `.RData` plano
queda fuera de git (`*.RData` en `.gitignore`); no subirlo.

**Diseño:** `w_personas_cal` (ponderador de personas calibrado a cuatro márgenes: sexo × edad, sexo × educación, región y
macrozona × área), `varunit` (pseudo-conglomerado) y `varstrat` (pseudo-estrato).

**Alcohol:** `p5_20` (alguna vez en la vida), `p5_21` (última vez: 30 días / más de un mes y menos de un año / más de un
año) y `p5_22`–`p5_31` (AUDIT). `p5_22` es el mismo ítem que `e3a1` de TSM, pero ENCAVI solo lo pregunta si `p5_21` es 1 o 2.
