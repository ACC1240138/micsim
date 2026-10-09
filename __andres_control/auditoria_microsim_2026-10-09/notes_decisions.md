# Notas del usuario: decisiones, abiertos y evidencia para el plan de 5 ítems (minado 2026-10-09)

Rutas relativas a la raíz del repo. `HO` = `__andres_control/codex_handoff_adam_rr_full_override_caveman.md`; `REG` = `__andres_control/expand_pif_registro_2026-10-06.md`; `PLAN` = `__andres_control/plan_trabajo_post_reunion_ACC_2026-09-17.md`; `RESP` = `__andres_control/microsim_respuestas_preguntas_2026-09-20.md`; `GUION` = `__andres_control/guion_reunion_ACC_2026-09-16_revision_critica.md`; `EXPL` = `__andres_control/microsim_base_ACC_2012_2024_explicacion.md`; `EPS` = `__andres_control/eps_alcohol_prevalencia_persistencia_informe.md`; `CAMB` = `__andres_control/expand_pif_cambios_hallazgos_2026-09-21.md`; `RECAL` = `__andres_control/microsim_recalib_ACC_2012_2024.ipynb`.

Etiquetas de verificación:
- **[run]**: lo comprobé ejecutando algo hoy (agregación de CSV guardados, `find`, lectura de CSV).
- **[code]**: lo comprobé leyendo código; no ejecuté el notebook.
- **[nota]**: lo dicen las notas; no lo volví a verificar.

Nada de lo siguiente se ejecutó con microdatos.

---

## 0. Hechos de contexto que cambian la lectura del plan

- **ACC no aprobó nada por escrito.** REG:111-115 (Q24, abierta) dice que el resultado de la reunión del 16-sep no quedó registrado: "Nothing can be treated as decided by ACC". Lo único atribuido a ACC son los lineamientos de PLAN:37-53, más SES "después" (HO:8118) y la regla de enmascarar sólo lo mostrado (HO:8201). Casi todas las decisiones de abajo son **del usuario** (2026-10-06/08) o **propuestas** de agentes. Tampoco hay registro de que ACC aprobara la prioridad de IB (retomar_proyecto_semana_2026-09-14_a_20.md:41).
- **Ninguna de las tareas de 21-sep §26 dejó salida en el repo [run].** RESP:662-668 y PLAN:129-135 listan cinco tareas; hoy no existe ninguno de estos archivos: `targets_never_former.csv`, `mortality_input_diagnostic.csv`, `sens_former_12m_2024.*`, `hed_definition_audit.*`. El rasgo+AR(1) tampoco está implementado [code]:
  - `RECAL` ms-setup l.10 sigue con `rho = 0.8`.
  - ms-annual-engine l.125-126 aplica el mismo AR(1) a `z_current`, `z_amount` y `z_hed`.
  - No hay `R/simulation/` ni tags git (los hitos v0 de PLAN:97 y PLAN:125 no se cumplieron en esa forma; el motor vive en notebooks, EXPL:71).
- **La exposición del motor y la de expand_pif se construyen igual [code].** Ambas usan tragos de 12 g, puntos medios de `audit2` 1/3,5/5,5/7,5/9 y episodios HED valorados en 5 tragos (H) / 4 (M):
  - motor: `RECAL` ms-survey-inputs l.80-85;
  - expand_pif: `expand_pif.ipynb` celda 7 l.26-38.
  - Consecuencia: `factor_CH` de `__andres_control/oms_factor_by_year.csv` (C4, ya exportado) se aplica directo a `gpd_survey`.
  - Magnitud [run]: `factor_CH` va de 4,35 (2016) a 5,97 (2024). El g/día de riesgo es 4 a 6 veces el de encuesta.
  - Tope: expand_pif integra en 0,1–150 g/día (REG:1100). En el motor, el RR individual debe evaluarse en `min(g × factor, 150)` para no desalinearse.
- **El sesgo HED se concentra en 2018 [run].** Agregué `__andres_control/microsim_recalib_outputs/reconstruction_comparison.csv` (metric = hed, 56 celdas):
  - El error es negativo en las 8 celdas y en las 7 olas; media −4,46 pp sobre un observado de 0,493.
  - **2018 = −11,0 pp**; las demás olas van de −2,3 a −4,8.
  - Por celda: hombres 15–59 entre −5,6 y −7,6; 60–65 cerca de −2,3.
  - Esto coincide con la sospecha REG:773-779 (Q26b): offset base-1 de `audit2` en 2018 y 204 bebedores con `db` pero sin g/día.

---

## 1. Decisiones YA tomadas que restringen los ítems 1-5

| # | Decisión | Fecha / quién / fuente | Estado | Ítems |
|---|---|---|---|---|
| D1 | Persistencia bebe/no bebe = rasgo + AR(1), λ=0,45, φ=0,65. Grilla λ∈{0;0,3;0,45;0,6} × φ∈{0,6;0,7;0,8}. λ=0 equivale al motor actual. Nombres `trait_share`/`ar_phi`, distintos del λ de expand_pif2 | 21-sep, chat Claude; PLAN:14, PLAN:82, PLAN:162; RESP:421-444; HO:8080-8082, HO:8100; CAMB:115 | **Sólo propuesta.** "falta visto ACC/CC" (HO:8080). No implementada [code] | 1 |
| D1b | No transferir el ρ de EPS a `z_amount`/`z_hed`. El rango 0,80–0,91 es exploratorio, no un IC | 21-sep Codex; HO:8045; EPS:99 | Regla de agente, aceptada en notas | 1, 2 |
| D2 | Mortalidad del motor: m = muertes DEIS / población INE a mitad de año; q = m/(1+0,5m); HMD sólo como control. La deriva −3,1 → +3,8 % es sistemática | 21-sep; PLAN:16, PLAN:80, PLAN:148, PLAN:163 (marcada ⚠, no discutida con ACC); RESP:492-556; HO:8086 | **Propuesta, no implementada.** El diagnóstico de dos cocientes no se corrió | 3 |
| D2b | Versión DEIS: 2024 idéntico byte a byte en 09-06/15-09/29-09/06-10. 2024 es preliminar (B14): re-correr cuando DEIS publique la oficial. No extrapolar | Usuario, 2026-10-06/07; HO:8185, HO:8220-8221, HO:8234, HO:8306 | Confirmado (usuario). Q19 "fijar `ACC_DEIS_VERSION`" sigue abierta (REG:914) | 3 |
| D3 | Factor OMS sólo dentro de RR/AAF/PIF (`g_riesgo = g × factor(año)`). La meta 5 (intensidad) se calibra **sin** factor. El factor se congela en 2025–2034 | Lineamiento ACC (PLAN:45: "para intensidad tal vez sí") reinterpretado el 21-sep (PLAN:15, PLAN:147, ⚠ "Confirmar con CC"); RESP:600-611; regla REG:1086 | Usuario/agentes: sí. **ACC/CC: no confirmado.** Hoy contradice la literalidad de ACC sobre la intensidad | 3, 4 |
| D3b | V1: el per cápita poblacional (ltabs/fd = 0) se ancla a 0,8×APC GHO total. Antes se anclaba la media de bebedores (bug). Muertes atribuibles +13,4 %; PIF de volumen ≈ ×2 | Usuario, 2026-10-06; HO:8218-8219, HO:8224, HO:8272, HO:8313; `__andres_control/hallazgos_expand_pif3_20261008.md`:161-166 | Confirmado e implementado en expand_pif. Kimi P1 marca como "débil" anclar con prevalencia de 30 días (p1kimi:15-16); no se corrigió | 3 |
| D4 | Exbebedor = último trago hace más de 30 días (heredado). RR_fd con varianza propagada. Sin sick-quitter por ahora | Usuario, 2026-10-06; HO:8225; Kimi P2 lo recomienda como principal (p2kimi:13) | Confirmado (usuario) | 3, 4 |
| D4b | Las historias simuladas (`ever`/`former`) **no** alimentan el RR de exbebedor. El reparto ltabs/fd sale de la encuesta | REG:1090; EXPL:23, EXPL:62; HO:7918 | Regla vigente | 1, 3 |
| D5 | HED = ítem SENDA 5+ (H) / 4+ (M) en 30 días, como proxy del umbral RR de 60 g, declarando gramos. Un faltante en HED **no** se recodifica "no": sale sólo del denominador del indicador. Sin MICE | Usuario, 2026-10-06; HO:8226, HO:8231; Kimi P3 D-a/D-b (p3kimi:13-19) | Confirmado (usuario) para AAF. **No auditado por ola**: Q26 abierta (REG:746-797); `hed_definition_audit` no existe [run] | 2 |
| D6 | Ola 2020 dentro del cálculo, marcada no comparable, sin sensibilidad sin 2020 (declarado como limitación). Factor de diseño 2020 tomado de 2018 | Usuario, 2026-10-07 (D3) y 2026-10-06 (C2); HO:8229-8230, HO:8321 | Confirmado para AAF. Para la pérdida de calibración de la microsim, abierto (PLAN:146, PLAN:167, pregunta CC c) | 1, 2 |
| D7 | Fuentes RR: IHD = OMS/Adam principal y Tabla 5 PUC como sensibilidad; IS = Tabla 5 PUC principal; demás causas OMS/Adam; RR de Adam Sherk | Usuario, 2026-10-07/08; HO:8238, HO:8364, HO:8381; `__andres_control/estado_ACC_expand_pif.md`:54 | Confirmado (usuario); implementado en expand_pif3; validación epidemiológica (GATE 2) pendiente | 3 |
| D8 | AAF=1 fuera del PIF: PIF "parcial". C16/C25 fuera del principal: 21 causas, 23 con complemento. X30-X39 fuera (S6 estricto) | Usuario, 2026-10-06/07; HO:8255, HO:8316, HO:8322-8323; Kimi P5 D-a | Confirmado (usuario) | 3, 4 |
| D9 | Muertes evitadas = muertes **totales** de la causa × PIF. Nunca AAF × PIF. Agregar sólo como suma/suma. PIF con signo, sin truncar. Neto + por causa | HO:8262, HO:8332, HO:8416; REG:1080-1082; GUION:232 | Confirmado (usuario) | 3, 4 |
| D10 | λ de salida de HED (expand_pif2): reportar λ = 0 / 0,5 / 1 con el cambio implícito de consumo. Principal sugerido λ=0 (Kimi P5). Antes "PROVISIONAL λ=0,5 principal" (HO:8247) | Usuario, 2026-10-06; HO:8256 | Reporte de 3 confirmado. **El principal es ambiguo** (HO:8247 vs HO:8256) | 2, 4 |
| D11 | Estado estacionario (sin rezagos) como principal del PIF. Rezagos y quitters inducidos se pasan a la microsim (regla SIMAH: quitter → exbebedor con RR_fd) | Usuario vía Kimi P5, 2026-10-06; HO:8257-8258 | Confirmado para expand_pif2. En la microsim, **diferido y abierto** (Q25, REG:1046-1050) | 4 |
| D12 | YLL: `yll_hmd` principal; GBD TMRLT como sensibilidad; edad de referencia (legacy) sólo para comparar. Sin claim WPP | Usuario, 2026-10-06 (Q8); HO:8261 | Confirmado (usuario). La sensibilidad con tabla fija 2019 (Kimi P10) está pendiente (HO:8336) | 3, 4 |
| D13 | Alcance 15–65 para AAF ("= motor microsim, cota inferior"). Sin ENS/EPS/carry-forward. Urbano→nacional declarado (D2) | Usuario, 2026-10-06; HO:8228-8229 | Confirmado (usuario) para AAF | 5 |
| D14 | Edades 66–76 = ENPG 60–65 × p_EPS(66–70)/p_EPS(60–65) por sexo, persistencia EPS 50+, mortalidad DEIS/INE | 21-sep; PLAN:18, PLAN:84, PLAN:165; RESP:479-488; HO:8101 ("decisión ACC") | **Sólo propuesta. Choca con D13.** Kimi P4 califica el puente EPS como "Débil" y recomienda ENS (p4kimi:12-13, p4kimi:72) | 5 |
| D15 | Base 2012–2024 = reconstrucción `interp_hold` con 7 olas. 2025+ = hold-last central; spline no más allá de 1 ola. **Ya no hay holdout intacto** | Agente, 18-sep; HO:8022-8026; EXPL:170-176; PLAN:8-9 | Propuesta (no ACC). La regla de holdout perdido es un hecho metodológico | 1 |
| D16 | Motor discreto anual (R base + dplyr), sin réplica MicSim ni data.table | Acordado entre agentes; HO:7948, HO:7987; EXPL:69. PLAN:160 lo marca ⚠, a decidir el 30-sep | De facto, no ACC | todos |
| D17 | Anualizar sin α=0,5 por probabilidad: raíz de matriz o `msm`; test Chapman–Kolmogorov | PLAN:82, PLAN:161; RESP:391-415; HO:7927 | Propuesta; no aplica al motor actual (no usa `polr`) | 1 |
| D18 | SES: después. Hoy no es prioridad | ACC, 22-sep; HO:8118 | **ACC** (único caso claro) | — |
| D19 | B12: punto plug-in con IC de percentiles MC, sin forzar el orden. Q13: piso 1 en el factor de diseño (contra Kimi P7) | Usuario, 2026-10-07; HO:8302, HO:8309 | Confirmado (usuario) | 4 |
| D20 | Prioridad política = tamizaje + IB en APS frente a atención habitual; precio en paralelo | GUION:17, GUION:293; PLAN:103 (como "política 1", ene–mar 2027) | Propuesta del usuario/agente. ACC no consta (retomar:41; REG:113) | 4 |

---

## 2. Decisiones abiertas para ACC/coautores

### A. Bloquean el entregable del lunes 12-oct

Cada una necesita al menos un supuesto provisional rotulado.

1. **Arquitectura del puente exposición → muerte.** Dos rutas que no se combinan (GUION:226-234; REG:1081):
   - (a) Agregada: muertes DEIS de la causa × PIF calculado con la exposición simulada.
   - (b) Individual: hazard ∝ RR / RR medio basal, con riesgos competitivos.
   - El problema 3 del plan pide (b) ("la probabilidad de morir no depende del consumo"). Para ser verificable el lunes, (a) es más barata. Decide: usuario/ACC.
2. **Escala y forma del efecto de IB.**
   - **Relativo**: −12,3 % de Angus/SAPM es invariante a la escala (RESP:606).
   - **Absoluto**: −20 g/semana de Kaner = −2,86 g/día (GUION:136). En escala de encuesta, × factor 4–6, equivale a −12 a −17 g/día de riesgo; en escala de riesgo, a −2,86. GUION:154 y GUION:220 prohíben aplicar la corrección de subreporte a un efecto clínico sin justificarlo.
   - Falta decidir la escala. Decide: usuario, con ACC/CC.
3. **Perfil temporal.** Opciones: Kaner es un punto a 12 meses; Fleming observó 48 meses (GUION:396); Sheffield usa retorno lineal en 7 años (GUION:393). Repetición sin acumulación (GUION:222). Decide: usuario.
4. **Efecto sobre HED.** GUION:137 dice "Pendiente de extracción compatible… sin asignar beneficio HED por defecto". GUION:398 advierte que frecuencia ≠ prevalencia. El plan pide efecto HED: o se deja en 0 en el escenario principal, o se rotula como supuesto.
5. **Elegibilidad y cascada.** La microsim no tiene AUDIT. El umbral debe ser un proxy en g/día o HED, rotulado (GUION:131, GUION:220).
   - Contacto, tamizaje, positividad y entrega figuran como "Pendiente local" (GUION:132-135). El lunes sólo pueden ir escenarios de cobertura declarados.
   - Hay que mantener un escenario de efecto nulo (GUION:153, GUION:268).
6. **Mortalidad basal.** D2 (DEIS/INE) frente al motor actual (HMD × multiplicador por sexo).
   - El plan dice "calibrar mortalidad basal con DEIS". Con D2 la concordancia es por construcción: es un insumo, no una calibración (RESP:511).
   - Fijar la versión DEIS (Q19, REG:914). 2024 es provisional (B14).
7. **Rezagos.** Hay dos convenciones:
   - estado estacionario (D11 y SIMAH, que usa consumo concurrente: p5kimi:22);
   - rezagos de Holmes 2012 Tab. 2: cánceres sin efecto antes de 10 años (p5kimi:37); latencia de cáncer de 10 años (p2kimi:34).
   - A 10 años cambia mucho las muertes evitadas. El principal no está decidido para la microsim.
8. **Año de inicio y horizonte de la IB.** GUION:179 recuerda que 2024–2034 son 10 intervalos y que empezar en 2024 sería retrospectivo.

### B. No bloquean el lunes

Bloquean la validación o el paper.

9. Valores de λ/φ (D1) y si las metas nunca/ex más EPS bastan para fijarlos (PLAN:152g). Las metas nunca/ex no están calculadas.
10. Definición HED por ola y Q26:
    - qué ítem alimenta `db` en cada ola;
    - el offset de `audit2` en 2018;
    - puntos medios 7,5/9 frente a categorías reales "7 a 9" / "10 o más" (REG:753-797; p3kimi:20-21). Decide: JRT (script de `ENPG_BINGE.RDS`).
11. Peso de 2020 y método de pérdida (SSE frente a χ²; optim frente a IMIS/ABC). Son las preguntas a–g para CC (PLAN:152).
12. Edades 66–76 (D14 contra D13) y su fuente: EPS frente a ENS (Kimi P4).
13. Q25: quitters inducidos por la política, ¿pasan a exbebedor con RR_fd? (REG:1046-1050; tensión con D4b).
14. Pesos 2022 y quiebre de marco: la caída 2022/24, ¿es conducta o medición? (EXPL:120, EXPL:174; Q20, REG:921-926).
15. Sensibilidades de exbebedor a 12 meses (V2; Kimi P2 B/C) y "sick quitter" con RR_fd=1 (p2kimi:16, p2kimi:154-158).
16. Tabla 5 IHD: B2 redondeado. Se envió un correo a Zitko (HO:8364).
17. YLL con tabla fija 2019 y WPP/INE como sensibilidades (HO:8336-8337).
18. Proyección: hold-last frente a cohortes (RESP:535).

---

## 3. Evidencia de intervención breve ya reunida

Todo viene de GUION §6.1-6.4 (l.111-163) y de su apéndice (l.386-408). Es búsqueda focalizada al 16-sep, no sistemática (GUION:107, GUION:370).

| Fuente | Parámetro y unidades | Uso y límite según las notas |
|---|---|---|
| **Kaner 2018, Cochrane** (CD004148.pub4) | −20 g/semana a 12 meses, IC95 % −28 a −12; I²=73 %; 34 ensayos; comparador mínimo o nada. Aritméticamente −2,86 g/día (−4,00 a −1,71) | Candidato de efecto absoluto. No es −20 % ni se acumula por año. Escala clínica (GUION:118, GUION:136, GUION:390) |
| **Barticevic 2021, Chile** (ASCP 16) | AUDIT 8–15; IB de 5 min por técnicos + folleto vs folleto; 5 CESFAM; 6 meses; 294/342 analizados; ~80 % vs 71 % en bajo riesgo; p=0,1 | Efecto incremental local incierto, contra un comparador activo. AUDIT no pasa a gramos. IC secundario discordante entre resumen y cuerpo (GUION:119, GUION:159, GUION:391) |
| **Poblete 2017, Chile** (ACC coautor) | ASSIST riesgo moderado; APS, urgencias y comisarías; sin diferencias a 3 meses; seguimiento 62 % | Contexto de factibilidad; no es parámetro (GUION:392; pregunta a ACC GUION:300) |
| **Angus 2014, SAPM Italia** | −12,3 % de consumo; retorno lineal a basal en 7 años; pesquisa AUDIT-C ≥4 (M) / ≥5 (H) | Escenario histórico de modelación, no estimación chilena (GUION:37, GUION:393) |
| **Angus 2019, ODHIN** (EJPH) | Cascada: tamizaje, positividad, entrega, capacidad | Referencia de cascada. Costos y persistencia europeos. No modela trayectorias individuales (GUION:103, GUION:117) |
| **Purshouse 2013** | ~40 % de cobertura a 10 años al registrarse vs 96 % en la consulta siguiente (Inglaterra) | Diseño y capacidad; no son tasas chilenas (GUION:394) |
| **Fleming 2002** | 48 meses observados con 2 visitas y 2 llamadas | Los 7 años de Sheffield son extrapolación (GUION:396) |
| **Lemp 2026, JAMA Health Forum** | Microsim de expansión SBI. Efecto aplicado sólo a receptores **adicionales** (la atención existente ya está en las tendencias basales). Elegibilidad en g/día. YPLL-75 sin tabla | Referencia principal de arquitectura (GUION:109, GUION:115). YPLL-75 confirmado en p10kimi y HO:8338 |
| **Manthey 2021** (PLOS ONE) | Steps 1–4 y código R en S1. Desenlaces de consumo y HED, no mortalidad | Implementación reproducible; código no auditado (GUION:116) |
| **Anderson 2021, SCALA** | IRR 9,8 (4,1–24,7) en cobertura de **medición** a 5 meses | Implementación, no eficacia (GUION:120, GUION:160) |
| **So 2025, BMJ Japón** | <1 min + folleto; sin superioridad a 24 semanas | Delimita modalidad; acceso parcial (GUION:121) |
| **Delphi ronda 1** | 97,3 % de acuerdo con tamizaje/IB (n=37; consenso ≥75 %) | Acuerdo del panel, no efectividad (GUION:36, GUION:43) |

Reglas fijadas en GUION:149-155 y GUION:402-406:
- no sumar −20 g/semana, −12,3 % y la OR chilena;
- no multiplicar de nuevo por adherencia;
- separar evolución basal y efecto de política, sin contar dos veces la atención habitual;
- escenario de efecto nulo obligatorio, sin truncar la incertidumbre al beneficio.

Arquitectura (GUION:169, GUION:197): población → contacto APS → tamizaje → elegibilidad → IB o derivación → Δ g/día y HED → RR por causa → muertes y YLL.

Fórmula de consumo (GUION:218): `max(0, consumo_ref + Δ(t))`, siempre contra la referencia contemporánea.

**Lo que falta:**
- todos los denominadores chilenos de la cascada (GUION:132-135, GUION:141; DIPRES 2023 no sirve, GUION:210);
- efecto sobre HED (GUION:137);
- persistencia y repetición (GUION:140);
- puente AUDIT ↔ g/día;
- comparador de "atención habitual" chileno;
- efecto en mujeres y en mayores.

Además:
- Los encargos Kimi/Gemini sobre IB **nunca se enviaron** (retomar:54).
- Los archivos enlazados no existen en el repo [run]: `encargo_kimi_arquitectura_IB_APS_2026-09-16.md` y `encargo_gemini_evidencia_IB_APS_2026-09-16.md` (GUION:335-336), y `plan_fase_siguiente_micsim_2026-07-04.md` (GUION:323; retomar:156).
- `research_notes/…/intervencion_breve.md` y sus hermanos están sin seguimiento en git, creados hoy 2026-10-09 por la investigación paralela. **No son notas del usuario**; no los miné.

---

## 4. Contradicciones y tensiones

### 4a. Plan nuevo frente a notas y calendarios anteriores

- **Calendario.**
  - PLAN:28-31 fijaba: v0 consumo calibrado al 30-sep; v0.5 con HED y exbebedores dinámicos y rasgo+AR(1) al 16/30-oct; v1 con mortalidad por causa al 30-nov; IB en ene–mar 2027 (PLAN:103).
  - El lunes 12-oct adelanta v1 (~7 semanas) y la política (~3–5 meses), con v0.5 sin hacer (§0).
  - GUION:250-257 preveía IB integrada en las semanas 7–8 desde el 16-sep (≈ 4–11 nov).
- **Muertes evitadas el lunes.** GUION:255 dice: si falta el puente AUDIT–exposición, "no inventar muertes evitadas". GUION:283 ("todavía no hay una cifra defendible") y GUION:380 (cerrar la especificación antes de producir cifras) van en la misma línea. El lunes deben ir como escenario ilustrativo con efecto nulo al lado.
- **Ítem 3, "calibrar mortalidad por causa con DEIS".**
  - Con D2 la mortalidad total es un insumo, no una calibración (RESP:511).
  - PLAN:149 define las muertes atribuibles como **validación**, "por construcción si la distribución calza".
  - "Atribuible compatible con Expand PIF" sólo es informativo si se compara la distribución de exposición simulada (Gamma por sexo×edad, ms-calibration-functions) con la de expand_pif (gamma por momentos ponderados, Q21, REG:928-931). Mismo constructo [code], distinta parametrización.
- **Ítem 2, "calibrar HED por sexo, edad y volumen".** Las notas piden definir HED antes de calibrarlo (RESP:573; PLAN:212). Hoy falla en tres cosas:
  - Q26 abierta;
  - el ítem por ola (5+/4+ frente a 6+, PLAN:146);
  - el umbral por sexo no verificado (RESP:321).
  - Además, la sobreestimación de "embriaguez" por faltantes (RESP:321) va en sentido contrario al sesgo −4,5 pp de la simulación. Son problemas distintos: medición frente a modelo.
- **Ítem 1, "EPS para persistencia".** La evidencia de EPS cubre sólo 50+, su pregunta F13 no tiene plazo, hay sesgo de supervivencia y son "órdenes de magnitud" (RESP:389; EPS:95-99). No informa a `z_amount`/`z_hed` (HO:8045). Por sexo es inestable (RESP:388).
- **Ítem 5 frente a D13.** El usuario cerró 15–65 para AAF sin EPS/ENS el 2026-10-06 (HO:8228). Kimi P4 califica el puente EPS como débil (p4kimi:12). El plan nuevo propone EPS. Además, la mayor parte de la mortalidad crónica atribuible ocurre después de los 65 (RESP:170; CAMB:124): las muertes evitadas del lunes serán una cota inferior.
- **"La simulación subestima HED" frente a calibración.** EXPL:156 y HO:8011 ya dicen que HED "no está calibrado a un margen".
  - El modelo HED se ajusta sin término de año (`hed ~ 0 + cell + log1p(gpd)`, ms-calibration-functions l.70-74 [code]). No puede seguir variaciones por ola.
  - Excluye bebedores con g/día NA, que sí entran en la meta (ms-survey-inputs l.124-143 [code]).
  - Ambas cosas son compatibles con el pico de 2018 [run]. Inferencia, no verificado ejecutando.

### 4b. `presentacion_micsim.qmd`: afirmaciones que el código o las notas contradicen

| qmd | Afirma | Lo que hay |
|---|---|---|
| l.198 | Motor "implementado con MicSim" | Motor discreto anual en R base + dplyr; MicSim no se ejecutó (HO:7948; EXPL:69) |
| l.211 | Grupo de edad "60+" | 15–65, sale a los 66 (`RECAL` ms-setup l.10; ms-annual-engine l.101-102 [code]) |
| l.219 | ENPG = "Encuesta Nacional de Presupuestos y Gastos" | Estudio Nacional de Drogas en Población General (GUION:325) |
| l.30 | Defunciones 1990–2021 en `.rds` | DEIS 2012–2023 corregido + 2024–2026 vía `acc_deis()` (HO:8150-8151) |
| l.88, l.333 | PAF 2008–2022 ✅ | Serie AAF 2012–2024, re-corrida el 06-oct con V1 (HO:8274-8275) |
| l.120, l.334-335 | PIF "solo injuries"; otras causas en desarrollo | PIF de 23 causas (21 principales), volumen/HED/combinados (`hallazgos_expand_pif2_20261008.md`:35-42; `hallazgos_expand_pif3_20261008.md`:41) |
| l.121-127 | Incorporar exbebedores al PIF | El término fd ya está; las políticas no lo mueven (`hallazgos_expand_pif2_20261008.md`:172; HO:8416) |
| l.274-278 | `alpha=0.5` controla stickiness | α=0,5 no anualiza una matriz bienal (HO:7927; RESP:405-413) |
| l.244-252 | Mortalidad Gompertz por nivel de consumo (MWE) | Parámetros ilustrativos; la mortalidad del motor real no depende del alcohol (EXPL:25) |
| l.306-309, l.338-339 | Pseudo-panel ✅, polr ✅, 3 esquemas de calibración ✅ | `Alcohol Transitions_CALIB.R` no parsea (GUION:61); el rank matching asume la persistencia máxima (RESP:401); el motor en uso no usa `polr` |
| l.337 | Elasticidades ✅ | Manuscrito no localizado ni verificado (GUION:57) |
| l.292 | Pérdida SSE | El plan propone SSE ponderada por varianza de diseño (PLAN:89) |

---

## 5. Lo que el plan nuevo omite y las notas exigían

1. **Controles de verificación** (GUION:350-358; retomar:137-145; REG:1077-1082):
   - reproducción basal;
   - **política nula = 0**, con escenarios emparejados y números aleatorios comunes (GUION:246; Kimi P7 D-d);
   - **balance de cascada**;
   - efecto y repetición (consumo ≥ 0, sin acumulación);
   - **sin doble escalamiento AAF/PIF**: muertes totales × PIF; misma escala `g × factor` en referencia y política.
2. **Escala del factor** (§0): aplicar `factor_CH` (no `factor_CHMS`) a `gpd_survey` y tope de 150 g/día. Si el per cápita simulado difiere del de la encuesta, reanclarlo.
3. **Metas nunca/ex** (RESP:448-475; PLAN:131) y **diagnóstico de mortalidad** (RESP:492-515; PLAN:133). Ninguno existe [run].
4. **HED por ola y Q26:**
   - offset de `audit2` 2018;
   - puntos medios 7,5/9;
   - origen de `db` (REG:746-797);
   - tragos de 12 g sin fuente chilena: Kimi P3 lo califica como "contrario" sin declarar (p3kimi:19), aunque B19 dice que se cancela en el volumen anclado (`expand_pif.ipynb` celda 7 l.90-91).
5. **Holdout perdido:** 2022/2024 ya son desarrollo. Cualquier "validación" requiere una ola nueva o una fuente independiente (EXPL:66, EXPL:176; GUION:260; RESP:238-254).
6. **Pesos 2022 y bandera 2020** (D6; EXPL:120; RESP:191-219; Q20).
7. **Universo urbano → nacional** (D2 de CAMB:125; HO:8229) y **2024 provisional** (B14). La caída de K70 de 37 % entre 2022 y 2023 no está explicada (`hallazgos_expand_pif2_20261008.md`:149-151).
8. **Exbebedores y quitters:** las historias no alimentan RR_fd (D4b). Q25 está abierta: una IB que induce abandono, ¿pasa a fd? (REG:1046-1050; HO:8257).
9. **Rezagos y latencias** (D11; HO:8258; Kimi P5 D-d).
10. **YLL** con `yll_hmd` (D12): el plan sólo habla de muertes, pero la propuesta y la IB piden años perdidos (GUION:242). Hay que armonizar con el YPLL-75 de Lemp.
11. **Incertidumbre:** separar ruido MC, incertidumbre de parámetros e incertidumbre estructural (GUION:246). Las 5 semillas no son incertidumbre científica (EXPL:68).
12. **Nombres:** `trait_share`/`ar_phi` frente al λ de expand_pif2 (CAMB:115; REG:1083).
13. **Q24:** registrar qué decidió ACC antes de presentar decisiones como acordadas.
14. **Entradas a los 15 años** desde la ENPG 15–17 de la ola más cercana: filtración de holdout (HO:7928).

---

Fuera del minado: no leí `encargos_kimi_cierre_expand_pif_2026-10-06.md`, `p6/p8/p9kimi`, `guion_reunion_ACC_2026-09-16.md` (borrador) ni `tabla_aaf_who2024_sexo_causa_ano.md`. Los Kimi P1, P2, P3, P4, P5, P7 y P10 sólo los hojeé (veredictos y recomendaciones).
