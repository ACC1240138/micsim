# Plan revisado de la microsimulación: integración consumo → IB → RR → muertes

> **2026-10-09.** Revisión del plan de 5 ítems y especificación del entregable mínimo del lunes 12-oct.
>
> - **Datos y verificación.** Los diagnósticos se corrieron con datos reales (ENPG, EPS, DEIS, INE y HMD) en una sesión en la nube, con R 4.3.3 instalado desde apt y fuera de renv, porque allí Posit PPM está bloqueado. Un verificador independiente re-chequeó [PE], [HD], [MO] y [RB]. El prototipo del motor [MT] y las notas [NT] **no tienen verificación independiente**.
> - **Repo.** No se cambió código, notebooks ni salidas del repo. Se agregaron este archivo, los anexos de [auditoria_microsim_2026-10-09/](auditoria_microsim_2026-10-09/) y el informe y las notas de investigación (`reports/`, `research_notes/`).
> - **Antes de citar.** Toda cifra de la nube debe re-correrse localmente con renv.

**Etiquetas**

- **[verificado con datos]**: corrido sobre microdatos reales el 09-oct y confirmado por el verificador. Cuando un `*_verify.md` corrige su informe, prevalece el verify.
- **[prototipo, sin verificar]**: corrido en el prototipo del motor [MT]; nadie lo re-corrió.
- **[leído, no re-corrido]**: comprobado leyendo código o CSV guardados.
- **[propuesta]**: diseño recomendado, aún no decidido.
- **[supuesto]**: valor que ningún dato chileno identifica; siempre va con sensibilidad.
- **M** = mujeres, **H** = hombres. Decimales con coma; miles con punto.

**Glosario**

- **Abstemios de por vida** (*stayers*): no bebedores fijos de por vida. *Movers*: el resto.
- **s**: fracción de abstemios de por vida. s_EPS = la del panel EPS 50+ (0,20, supuesto). s_entrada = la de quienes entran a los 15–24 años (≈12 % H / 18 % M).
- **λ (`trait_share`) y φ (`ar_phi`)**: peso del rasgo estable y persistencia anual del AR(1) en `z_current`. No es el λ de salida de HED de expand_pif2 (D10).
- **Cresta**: borde de la región de ajuste EPS (pares λ, φ con ajuste casi igual).
- **Telescopado**: la edad de inicio recordada se corre hacia arriba.
- **Hold-last**: mantener hacia adelante el último valor observado (2024).
- **Fix A / Fix B**: offset del intercepto HED por celda × ola / ley empírica de g/día en lugar de la Gamma.
- **CRN**: números aleatorios comunes entre brazos.
- **R̄_w**: RR medio de la celda ponderado por hazard (normalizador).
- **TMREL**: nivel de exposición de riesgo mínimo teórico.
- **WLS/GLS**: ajuste EPS por mínimos cuadrados ponderados/generalizados. **UPM**: conglomerado de muestreo.
- **Bundle**: archivo cifrado `*.tar.xz.enc` (AGENTS §7). **Scratch**: código de la nube, fuera del repo.
- **ACC, JRT, CC; Kimi P1–P10; B9, B14; Q19–Q26; D1–D20**: siglas, encargos y entradas de tus notas y del registro de expand_pif ([NT]).

**Fuentes** (enlaces al pie)

| Sigla | Archivo |
|---|---|
| [MT] | [engine_ponytail.md](auditoria_microsim_2026-10-09/engine_ponytail.md): motor y prototipo (sin verify) |
| [PE] / [PE-v] | persistencia y su verificación |
| [HD] / [HD-v] | HED y su verificación |
| [MO] / [MO-v] | mortalidad y su verificación |
| [RB] / [RB-v] | puente RR y su verificación |
| [NT] | tus notas y decisiones (sin verify; nada corrido con microdatos) |
| [INV] | [informe de investigación](../reports/Microsimulaci%C3%B3n%20de%20alcohol%20y%20mortalidad.md) |
| [HO] | handoff canónico |
| GUION / PLAN | [guion_reunion_ACC_2026-09-16_revision_critica.md](guion_reunion_ACC_2026-09-16_revision_critica.md) / [plan_trabajo_post_reunion_ACC_2026-09-17.md](plan_trabajo_post_reunion_ACC_2026-09-17.md), citados por línea vía [NT] |

## Veredicto

1. **La dirección del plan es correcta.** El lunes es alcanzable: casi todas las piezas ya corrieron en un prototipo con datos reales [MT], aunque sin verificación independiente.
2. **Ítem 1.** El cambio año a año no está identificado por la EPS. Robusto: faltan abstemios de por vida (por eso "nunca" cae a 6,3 %) y memoria larga en la cantidad (r plana 0,32 / 0,40 / 0,35; el motor da 0,18 a 7,7 años). La memoria larga en participación (0,18 frente a 0,478) sólo se identifica condicional a s [PE-v].
3. **Ítem 2, respondido en promedio.** La causa principal es la forma Gamma de la ley de g/día, no la definición (−0,12 pp) ni la dinámica (no cambia con ρ) [HD-v]. Siguen abiertos 2018 (−6,7 pp aun con Fix B, sin simular) y la definición por ola (Q26). La definición sí explica la brecha de la meta con SENDA.
4. **Ítem 3.** La deriva viene del denominador (la exposición de HMD frente a los stocks del INE), no de las muertes. Con m = DEIS/INE y R̄_w, "calibrar" la mortalidad basal total es una identidad [MO-v]. Por causa, el lunes usa tendencias suavizadas: se reporta la desviación, no se calibra.
5. **Puente RR.** En una población sintética con los insumos de expand_pif (no el motor), la AAF/PIF persona-nivel reproduce expand_pif: 3.257,4 frente a 3.258,0 muertes atribuibles en 2024 (DEIS semanal) [RB-v]. En el motor sólo se probó con 2 causas: |ΔAAF| ≤ 0,02 y ΔPIF relativa media 5,9 % [prototipo, sin verificar]. El lunes compara por celda en 4 causas.
6. **Ítem 4.** La IB es una función pequeña; lo difícil es el contraste: brazos pareados con muertes **esperadas** (el ruido de las sorteadas es ~4.200/año frente a unidades a decenas de evitadas), cobertura incremental y escenario nulo [MT].
7. **El ítem 5 no es "posterior" para interpretar.** A los 66+ ocurre el 66–80 % de todas las muertes, pero en las causas del lunes la proporción es menor (cirrosis 50,9 % M / 32,7 % H; lesiones 9,5–77,1 %). El lunes trunca beneficios a los 66+; la dirección neta es incierta, porque el estado estacionario sobrestima cirrosis [MO].
8. **Lunes.** 4 causas (3 de lesiones agudas y cirrosis sin rezago), S0–S3 y la prueba V, 3 archivos de código nuevos; los notebooks quedan intactos. Se puede afirmar "componentes conectados y verificados"; la validación queda pendiente.
9. **El lunes se adelanta a tus notas.** Adelanta v1 (~7 semanas) y la IB (~3–5 meses) respecto de PLAN:28-31, y choca con GUION:255 y :283 ("no inventar muertes evitadas"; "todavía no hay una cifra defendible"). Las evitadas se muestran como escenario ilustrativo y prueba de conexión (S0/S3 = 0; S2 > S1 > 0), no como cifra citable 2025–2034 [NT] §4a.
10. **Nada está aprobado por ACC (Q24).** Todo valor por defecto aquí es **[propuesta]** [NT].

**Siguiente acción:** hoy viernes, en la máquina local con R en la raíz (activa renv), crear `__andres_control/microsim_engine.R` a partir de los scripts del prototipo (§2.3) y `__andres_control/test_microsim_engine.R` con la guarda de locale (T12) y la regresión `identical()` contra las celdas del notebook evaluadas en sólo lectura (§2.7), antes de tocar cualquier gancho.

---

## 1. Tu plan, ítem por ítem

### Ítem 1 — Trayectorias de consumo

Tu premisa ("rho = 0,8 es un supuesto; el AR(1) no reproduce la EPS") **se confirma sólo sin abstemios de por vida**. Con s_EPS = 0,25–0,30 el AR(1) 0,8 no se rechaza: la decisión clave es s, y λ/φ (incluido tu D1 0,45/0,65) quedan como sensibilidad.

**Diagnóstico con datos** [verificado con datos salvo donde se indica]
- **EPS** ([PE], [PE-v] 1–4).
  - Tetracóricas: 0,566 / 0,588 / 0,478 a ~3,7 / 4,0 / 7,7 años (las mismas 1.744 personas, 50+). El motor implica 0,44 / 0,41 / **0,18**.
  - Rasgo + AR(1), sin abstemios de por vida: λ = 0,453, φ = 0,679 (tu 0,45/0,65 cae dentro). El bootstrap por conglomerados da λ 0,27–0,54 y φ 0,40–0,81 (103 UPM).
  - AR(1) puro sin abstemios de por vida: rechazado (ΔWLS 7,2; GLS 10,8).
- **Paso anual no identificado.** Todos los rezagos son ≥3,7 años, y un cambio anual de 15,6–32,7 % es compatible. El ~20 % del motor queda "no contradicho", no validado. r(10 años) es una extrapolación.
- **Error estructural** ([PE-v] 7–8).
  - En 2024 el motor da 6,3 % nunca / 57,5 % ex; la ENPG 2014–2022 da 16,4–20,8 % / 30,8–38,6 %. Con un latente compartido, todos terminan cruzando el umbral.
  - "Nunca" es un estado reportado: dentro de cada cohorte sube en 2012 (mediana +7,0 pp) y en 2024 (+8,3 pp). En 2018 también sube en mujeres (+4,6 pp).
- **s no identificada** ([PE-v] 11–12).
  - La EPS sólo acota s a 0–35 % (H) / 0–62 % (M). Con s_EPS = 0,25, ni siquiera el AR(1) 0,8 se rechaza (Δ 4,5); con abstemios de por vida, el rasgo entre movers está débilmente identificado.
  - El ajuste nunca/ex de 2,8/2,9 pp del prototipo muestra (dentro de muestra, 1 semilla) que los abstemios de por vida detienen la erosión de "nunca". No valida λ/φ: AR(1) 0,8 con abstemios de por vida da lo mismo (2,78/2,92), y asignar a cada celda el "nunca" agrupado da 2,75 pp.
- **Iniciación y cantidad** ([PE] §3–4, [PE-v] 9, 13a).
  - `OH_2` es inusable: 88,5–94,6 % inconsistente.
  - Según `OH_3` (retrospectivo, telescopado), el inicio mediano es 17 (H) / 18 (M) años; después de los 25 inicia el 1,8–2,7 % (H) y el 7,0–9,2 % (M) de los que alguna vez bebieron. El prototipo deja 5–15 pp de más "nunca" a los 18–24 [prototipo, sin verificar].
  - La correlación del g/día es plana (0,32 / 0,40 / 0,35; mismas 446 personas, EPS 18+): la cantidad es un rasgo estable.
  - No se detectan diferencias por sexo, edad o educación, lo que no prueba homogeneidad.

**Problema reformulado.** Faltan (a) abstemios de por vida (robusto) y (b) memoria larga en la cantidad (robusto). La memoria larga en participación sólo se identifica condicional a s. Sin (a), ningún λ/φ reproduce nunca/ex.
- La memoria de **participación** no bloquea el lunes: el RR usa el estado **reportado** de cada año, no la historia simulada (regla de SIMAH y tu D4b).
- La memoria de **cantidad** sí afecta las evitadas del lunes: los receptores de IB, elegidos por beber mucho, vuelven a la media con ρ = 0,8. Se corre ρ_cantidad {0,5; 0,8; 0,95} sobre S1 [supuesto].

**Acción**
1. **[lunes]** Estado RR transversal [propuesta] ([MT] §3).
   - Entre no bebedores, `nunca` si `u_never < base::pmin(1, p_nunca/(1 − p_actual))`, con `u_never` fijo y `p_nunca` = `p_abs` de expand_pif. La línea no corrió tal cual en el prototipo.
   - `p_abs` sólo existe en las 7 olas: interpolación logit entre olas y mantenido desde 2024 (como `interp_hold`).
   - Aserción: "nunca" simulado en 2024 = `p_abs` ± 2 DE MC.
   - `ever` queda sólo como diagnóstico. ρ = 0,8, rotulado "legado".
2. **[semanas 1–2]** `z_current` = abstemios de por vida + rasgo + AR(1) en movers [propuesta] ([PE] §6). Reemplaza tu D1 (0,45/0,65, pendiente de visto ACC/CC) y revisa D1b (HO:8045: la EPS no informa a `z_amount`).
   - `trait_share` 0,32 y `ar_phi` 0,66, condicionales a s_EPS = 0,20.
   - s_entrada = nunca ENPG a los 25–29 años, 2014–2022: ≈12 % H / 18 % M.
   - Cantidad: `trait_share_a` 0,40 y `ar_phi_a` 0,5 (g/día EPS).
3. **[después]** Hazard de iniciación 15–24; s por cohorte; 65+ con EPS VIII.

**Listo cuando**
- **Regresión.** λ = 0 sin abstemios de por vida reproduce los márgenes y nunca/ex actuales dentro del error MC. La prevalencia a 30 días por ola × sexo × edad cambia |Δ| < 2 DE MC.
- **EPS.** Panel simulado de 50–57 y de 18–49 años (rezagos 4/8): WLS ≤ 5,99 frente a la EPS, y r(8) > r(4)².
- **ENPG.** Nunca/ex 2014–2022 (40 celdas): |desvío| medio ≤ 3 pp y ≥80 % de celdas dentro de ±5 pp, rotulado "dentro de muestra"; las celdas de mujeres 2018 se marcan.
- **Absorción.** "Nunca" cae ≤2 pp/década después de los 25 en las cohortes simuladas.
- **Cantidad.** Correlaciones dentro de los IC de la EPS (0,15–0,43 / 0,31–0,49 / 0,25–0,44). Cada sensibilidad es una fila con evitadas de S1 en el CSV de resultados.

**Sensibilidades.**
- s × 0,75 / 1,25.
- Cresta (0,12; 0,80) y (0,40; 0,52).
- Sin abstemios de por vida (0,45; 0,68). Legado (0; 0,8).
- ρ de cantidad {0,5; 0,8; 0,95}.
- Confiabilidad EPS 0,9 (λ 0,489, φ 0,729).

Condicionamiento: sobrevivientes de 50+, F13 sin período de referencia, atrición ~60 %.

**Qué NO hacer.**
- Ajustar λ/φ a los márgenes ENPG.
- Construir las entradas con `OH_2`/`init12` u `OH_3` retrospectivo (telescopado: 85 % vs 46 % "nunca" a los 16 años en hombres).
- Usar 2012/2024 como metas.
- Transferir λ/φ a cantidad o HED.
- Presentar 2,8/2,9 pp como validación.
- Usar α = 0,5 o el rank-matching de JRT.

### Ítem 2 — Consumo episódico excesivo (HED)

Tu premisa ("no está claro si falla la asignación según volumen, la definición o la dinámica") **está respondida en promedio**: falla la ley de g/día que alimenta la asignación. Siguen abiertos 2018 y la definición por ola (Q26).

**Diagnóstico con datos** [verificado con datos salvo donde se indica]
- **Tamaño** ([HD-v] 3). −4,50 pp es la media **no ponderada** de 56 celdas. Ponderado por población: −5,3 pp. 2018 agrupado: −11,0 pp. 2024 agrupado: −2,4 pp (la media no ponderada de 8 celdas en la corrida guardada, con DEIS viejo, es −2,26 pp).
- **Ni la definición ni la dinámica** ([HD-v] 7, 9).
  - 481 de 45.361 bebedores tienen HED sin g/día: −0,12 pp. El código coincide con el ítem crudo en el 100 % de los casos [leído, no re-corrido].
  - El sesgo es −4,44 / −4,50 / −4,45 pp con ρ = 0 / 0,8 / 0,95.
- **La Gamma de g/día** ([HD-v] 5–6).
  - Bajo 1 g/día quedan el 44 % de las bebedoras y el 29 % de los bebedores (observado: 33 % / 16 %).
  - Bajo 0,4 g/día, el mínimo posible en ENPG, quedan 30 % / 19 %.
  - El glm actual sobre la distribución **empírica** da −0,22 pp (analítico, sin simular): su pendiente compensa el sesgo, no lo causa.
- **2018** ([HD]). Sin término de tiempo, el sesgo es −4,93 pp. El pico (59,7 % vs 53,4 % en 2016) también aparece en la serie SENDA leída de p3kimi (no verificada contra SENDA) y no tiene explicación.
- **Definición** ([HD-v] 8, 15).
  - La meta excluye el HED desconocido y SENDA lo cuenta como "no", así que la meta queda 2,2–5,9 pp sobre la serie oficial (SENDA no verificada).
  - Quiebres: la exclusión de feriados cambia en 2016, 2020 y 2024; en 2018 los faltantes son 888/999; desde 2020 la tarjeta femenina de 4 tragos muestra volúmenes masculinos.
- **Efecto en el RR** ([RB-v] 10).
  - Hombres en 20–40 g/día: 7,3 % simulado vs 4,3 % observado.
  - El sesgo de 2024 resta ~27,6 muertes atribuibles en IHD + IS + lesiones (21 causas). En las 3 lesiones del lunes, la AAF baja 0,8–0,9 % en H y 7,3–7,9 % en M.
  - Las cifras originales (−84 muertes; −6,6 %) están mal.

**Problema reformulado.** La ley de g/día tiene la media correcta y la forma incorrecta. Daña el HED y la forma de la exposición del RR (hombres en 20–40 g/día); el efecto de corregirla sobre el RR no se probó. Antes de calibrar, hay que fijar la meta por escrito.

**Acción**
1. **[lunes, soltable] Fix A** [verificado con datos] ([HD] "B_wave", [HD-v] 10, 12).
   - Offset del intercepto por celda × ola: `uniroot` sobre la ley del motor, ~15 líneas en `ms_drivers`.
   - Da sesgo +0,06 pp, RMSE 0,65 y 48/48 **por construcción**.
   - Con 2022/2024 retenidos baja |sesgo| de 2,22 a 1,25 pp, pero no mejora el RMSE retenido del motor sin corregir (4,99 vs 5,39 pp): es lo mismo que mantener la ola 2020.
2. **[lunes, antes de Fix A] Meta escrita** [propuesta].
   - Casos completos entre bebedores actuales con g/día > 0: D5 (faltantes fuera del denominador) más una restricción nueva, g/día > 0 [propuesta]. Sobre ese subconjunto coincide con el `p_hed` de expand_pif.
   - La meta actual incluye, en 2024, 60 de 5.528 bebedores sin g/día: hasta 0,6 pp de diferencia ([RB-v] 5c).
   - Al lado, la serie comparable con SENDA.
3. **[semana 1] Fix B** [propuesta].
   - Reemplazar `qgamma` por la distribución empírica ponderada de g/día por sexo × edad, reescalada a la media anual.
   - Da −0,22 pp (analítico, sin simular). El efecto sobre la exposición del RR no se probó, y una ley empírica agrupada se aleja de la Gamma por ola de expand_pif (T5b sin evaluar).
   - 2018 queda en −6,7 pp, así que se suma el offset.
4. **[después]** Pedir a JRT el origen de `db` por ola (`audit2` 2018, puntos medios 7,5/9) ([NT] §2).

**Listo cuando**
- Sesgo ponderado por población, por ola, en la reconstrucción `interp_hold` con 7 olas ("por construcción"), media de las semillas 2125–2129: |sesgo| < 0,5 pp en cada ola.
- Tras Fix B:
  - ≤1 % de bebedores bajo 0,4 g/día;
  - proporción por tramo de g/día ([0,1), [1,2), [2,5), [5,10), [10,20), [20,40), 40+) dentro de ±3 pp por sexo;
  - HED por tramo dentro de ±10 pp.
- Se reporta el RMSE retenido 2022/2024 (~5 pp) sin umbral, más un párrafo con la definición y los quiebres.

**Sensibilidades.**
- ρ_HED ∈ {0; 0,5; 0,8; 0,95}: P(HED t+1 | HED) va de 0,67 a 0,83 (motor base, ρ_HED 0–1) [HD-v] 13.
  - La EPS no tiene ítem HED.
  - NESARC/Puka 2022: 72–98 % sigue a 1 año y 42–63 % a 5, con HED a 12 meses por estado de frecuencia, no la bandera de 30 días.
- HED después de 2024 con hold-last, ±5 pp [supuesto].
- 12 g/trago = 60 g (H) / 48 g (M), frente a 60 g en la OMS: declararlo.

**Qué NO hacer.**
- Mover ρ para arreglar el margen.
- Recodificar faltantes como "no" en la AAF (choca con D5).
- Llamar validación al 48/48.
- Adoptar E_bins: es una identidad por rango que deja mal el g/día absoluto ([HD-v] 17).

### Ítem 3 — Mortalidad y riesgos relativos

Tus dos premisas se confirman: la muerte no depende del consumo (`ms-annual-engine` L85) y hay deriva. Cambian la causa de la deriva y lo que significa "calibrar".

**Diagnóstico con datos** [verificado con datos salvo donde se indica]
- **Denominador** ([MO-v] 1–5).
  - Las muertes HMD coinciden con DEIS (0,014–0,02 %). La exposición HMD, en cambio, queda bajo el stock INE de junio: 2,5 → 6,3 % en M y 4,1 → 9,5 % en H entre 2012 y 2024.
  - Por eso qx HMD × INE deriva de −1,56 / −2,98 % a +1,96 / +3,46 %, y un multiplicador por sexo no puede corregirlo.
  - Las salidas guardadas usan un DEIS viejo, con 1.815 muertes infantiles mal clasificadas por edad. Los multiplicadores correctos son 0,9645 / 0,9413, no 0,970 / 0,945.
- **Tasas** ([MO-v] 7).
  - m = DEIS / stock INE de junio por edad simple, con q_jan(a) = 1 − exp(−½[m(a) + m(a+1)]). Calza la meta cohorte-consistente a −0,22…+0,05 %.
  - Esa meta está 2,5–3,6 % sobre DEIS 15–65: es el error que absorbía el multiplicador.
- **Causas** ([MO-v] 10–11, 16–17).
  - El mapeo coincide con expand_pif en 1.188/1.188 celdas, sin dobles banderas.
  - 798 de 2.652 celdas (30 %) tienen menos de 10 muertes, y 214 tienen cero.
  - Por tramo (LOYO): la tendencia sin 2020–21 da desviación retenida 1,65 por celda (piso de ruido 1,007: 64 % sobre el ruido), frente a 2,57 de la media plana.
  - Por edad simple: el spline de Poisson da 1,03 (piso 0,90; 29–39 % sobre el ruido en las 3 lesiones), frente a 2,19 de la tasa plana por tramo. Las desviaciones por tramo y por edad simple no son comparables entre sí.
  - K70 cae 37 % en un año (1.270 → 802, 2022 → 2023) sin explicación; 2021–2022 fue un pico de pandemia ([NT] §5.7).
- **Normalizador** ([MO-v] 19). Con la media **simple** del RR, la AAF simulada (0,0826) no coincide con 1 − 1/R̄ (0,0795) y la identidad falla por 3,5e-3. Con R̄_w ponderado por hazard el error es 0 y coinciden.
- **Cadena verificada** en una población sintética hecha con los insumos de expand_pif, no en el motor ([RB-v] 1, 6–7).
  - AAF a 5,8e-4 en 196 celdas (el residuo es la cuadratura de expand_pif). PIF(−10 %) a 1,4e-4.
  - 2024, 15–65 años, 21 causas: 16.306 muertes (archivo DEIS semanal); atribuibles 3.257,4 vs 3.258,0; evitadas 217,4 vs 217,5. 5 celdas con AAF negativa aportan −3,7.
- **Prototipo en el motor** (población fresca 2024, 200.000 personas, 2 causas) [prototipo, sin verificar]. Truncando como expand_pif: |ΔAAF| ≤ 0,02 y ΔPIF relativa media 5,9 %. Con tope en 150, la AAF masculina sube hasta +0,09.

**Problema reformulado.** No hay nada que "calibrar" en el total.
- Las tasas DEIS/INE son un insumo, y reproducir DEIS es una identidad.
- El RR entra como `h_ic = h_c × RR_ic / R̄_c`, con R̄_c = Σh·RR / Σh por sexo × tramo × año, calculado en el **control**.
- Por causa, las tasas suavizadas difieren de DEIS por diseño: se reporta la desviación.
- La paridad con expand_pif es verificación. Su brecha en la población del motor mide la exposición Gamma: es un hallazgo que se reporta, no algo que se ajusta.

**Acción**
1. **[lunes, soltable]** Mortalidad total DEIS/INE con q_jan, por edad simple 15–66; reemplaza la fórmula q = m/(1+0,5m) de tu D2 por la de paralelogramo (aplicar la q de edad al morir al stock de enero queda 0,8–1,6 % bajo DEIS 15–65, [MO] §1.4). HMD queda sólo como comparador. Para 2025–2034 se mantiene 2024 [supuesto: sin mejora].
2. **[lunes]** Causas del lunes [propuesta].
   - Conteos: `ypll_deaths_long(ypll_build_deaths())` (`ypll_icd_defs.R`:205, 273): 2012–2024 anual por sexo × tramo, regla DIAG1/DIAG2 de expand_pif, vía `acc_data()`/`acc_deis()`, protegido por `test_ypll_death_base.R`. `ypll_pipeline_deaths()` sólo cubre las 7 olas.
   - Tendencia por tramo sin 2020–21, mantenida desde el valor suavizado de 2024 (el observado es provisional). Cirrosis con y sin 2022.
   - Dentro del tramo, la forma por edad de la mortalidad total [supuesto, no probado en el LOYO]. [MO] §2.3 recomienda el spline por edad simple (después).
   - "Otras" = total − Σ causas, con aserción ≥ 0.
3. **[lunes]** RR con `rr_individual(pop, cause, spec)` de `audit/rr_bridge_lib.R` (`pop`: `sex`, `age_group`, `status`, `gpd_apc`, `hed`; [RB] (a)).
   - `gpd_apc = gpd_survey × factor_CH[año]`, con 2024 = 5,972, mantenido e idéntico entre brazos. Años impares: interpolación lineal entre olas [propuesta] (el prototipo usó un escalón).
   - Tope en 150 en el motor; truncamiento sólo en la paridad.
4. **[lunes]** Normalizador R̄_w ponderado por hazard, calculado en el control y reutilizado tal cual en el brazo IB. AAF = 1 fuera del PIF (D8) y fuera de las salidas del lunes.
5. **[después]**
   - Spline de Poisson para las 21 causas.
   - AAF = 1: la propuesta de pesos de [MO] (0 en nunca, g/día en actuales, 0,5 × media en ex) **reabre D8 y no tiene fuente** ([MO-v] 21). Alternativas de [INV]: funciones de riesgo absoluto (SAPM/STAPM) o el recurso de SIMAH para AUD.
   - Sorteos de RR con CRN.
   - Rezagos.

**Listo cuando**
- **Identidad.** Σ_i h_ic = N·h̄_c, con error relativo < 1e-10.
- **Mortalidad basal (T4).** Muertes esperadas del control frente a la meta cohorte-consistente (DEIS 15–65 − ½D15 + ½D66), por año × sexo 2012–2024: < 0,5 %. Por tramo [a0, a1], meta = DEIS(a0..a1) − ½D(a0) + ½D(a1+1): < 2 %. Se rotula "calibración por construcción".
- **Por causa.** Esperadas del control por causa × sexo × tramo frente a DEIS observadas 2012–2024: se reporta la desviación por celda y 2024 suavizado frente a observado (p. ej. tránsito 1.224), rotulado "suavizado, no calibrado"; sin umbral.
- **AAF y PIF (T5a, T5b, T6).** Ver §2.5.
- **Signos.** Evitadas ≥ 0 con RR monótono. Sorteadas vs esperadas: |z| ≤ 3 por año × sexo (T10).
- **Salidas viejas.** README en `microsim_recalib_outputs/` y `microsim_base_outputs/`: "DEIS previo al 05-oct"; re-exportarlas requiere correr el notebook y tu permiso.

**Sensibilidades.**
- **Tope vs truncamiento.** Máx. 0,103 de AAF (TB, H 45–59); 62/164 celdas con |Δ| > 0,01. En 2024 supera 150 g/día de riesgo el 4,3 % de los bebedores y el 1,2 % de las bebedoras.
- **Gamma agrupada vs mezcla NHED/HED.** Hasta 0,03.
- **Exbebedor a 30 días vs 12 meses** ([RB-v] 8).
  - El 42,1 % de los ex de 2024 bebió en el año.
  - Con RR(0,1), la AAF de cáncer hepático en hombres baja de 0,341 a 0,248 (media no ponderada de tramos; no acota IHD).
- **INE alternativo.** +0,9 % M / +1,6 % H en 2020.
- **R99 de 2024**, reasignado a causas externas.
- **IHD con Tabla 5** (D7).

**Qué NO hacer.**
- Re-ajustar multiplicadores sobre HMD por sexo (sí por sexo × año, sólo como respaldo).
- Renormalizar en el brazo IB: anula el efecto.
- Re-anclar `factor_CH` al brazo IB.
- Usar la media simple del RR.
- Comparar brazos con muertes sorteadas.
- Citar 0,970 / 0,945.
- Llamar validación a reproducir DEIS.
- Usar `15_plus` con edades simples.

### Ítem 4 — Intervención breve (IB)

Tu premisa ("no existe un mecanismo integrado") es cierta en el repo. En scratch existe y funcionó, y lo difícil no fue la función sino el contraste.

**Diagnóstico con datos** [prototipo, sin verificar] ([MT] §2.6, §3). El prototipo usó normalizador de media simple, tope en 150, mortalidad HMD × multiplicador, denominador "todos los elegibles" y 2 causas; no se re-corrió con el diseño del lunes.
- **Prototipo** (cirrosis + tránsito, 2025–2034, 25k agentes, 5 semillas).
  - Una corrida lleva ambos brazos, con supervivencia compartida y muertes esperadas. El nulo da 0 exacto, y el control queda a 14 de ~35.500 muertes/año.
  - 35.000 IB/año (−12,3 %, retorno lineal en 7 años, >20/>40 g/día de riesgo, sin re-tratar en 7 años) → **52 evitadas** acumuladas (DE entre semillas 2,8; 2,5–7/año).
  - 350.000/año → 407 (13,5).
- **Ruido.**
  - Muertes sorteadas: DE ~4.200/año con 25k agentes (2.100 con 100k).
  - Muertes evitadas: DE entre semillas de 3–6 % del efecto.
  - Contexto: expand_pif3 da ~265 evitadas/año con −10 % de volumen poblacional (media de las 7 olas 2012–2024, 21 causas); 217,4 en 2024 [RB-v] 7.
- **Bugs.**
  - Aplicar la IB por separado a sobrevivientes y entradas duplicó la entrega: 69k para una meta de 35k.
  - Con "todos los elegibles" como denominador se entregaron 32,6–37,0k para 35k y sólo 234–354k para 350k: ~1,6 M de elegibles con 7 años sin re-tratar se saturan.
  - Con 25k agentes, 35.000 IB son sólo 63–73 agentes (peso unitario 481–552). Sortear con `u < p` da una DE binomial de ~12 %: las medias de 5 semillas ya llegan a +5,6 % y −7,0 %, así que un ±5 % por año falla por diseño.
- **HED** ([HD]).
  - Para que la IB mueva el HED hay que re-evaluarlo explícitamente con el g/día nuevo, o aplicarlo como desplazamiento directo (Lemp, DR −0,07). Bajar el g/día después del sorteo no mueve el HED.
  - Con log1p, la respuesta es más empinada que la observada.
- **Estado** [verificado con datos] ([RB-v] 9). Dejar de beber no siempre sube el riesgo; depende de la causa y la dosis. "La IB cambia el g/día, no el estado" es una **decisión de diseño**.

**Problema reformulado.** La IB es un efecto de **margen intensivo**, sólo en receptores **incrementales**, con escala y duración declaradas. Se mide como diferencia de hazards esperados sobre la misma población, siempre junto al nulo.
- Los dos ensayos chilenos no fueron superiores al folleto en el desenlace primario (Barticevic: AUDIT −0,86, d = 0,21) [INV].
- El −12,3 % de SAPM viene de una IB de 24,9 minutos (Kaner 2007); la IB chilena dura 5 minutos.

**Acción**
1. **[lunes]** `ms_bi(pop, year + 1L, drivers, bi, unit_weight, factor)` una vez al año, **después** de `bind_rows(pop, new)` y de la exposición de t+1, y una vez tras la exposición inicial. Sortea su uniforme para todos aunque esté apagada [propuesta].
2. **[lunes]** Valores por defecto [supuesto].
   - Elegibles: >20 g/día (M) / >40 (H) en escala de riesgo (en 2024, >3,35 / >6,7 g/día en escala de encuesta); sólo incrementales. Choca con GUION:220 (no asignar elegibilidad a gramos corregidos por ventas); falta el puente AUDIT ↔ g/día.
   - Efecto: −12,3 % proporcional, con retorno lineal en 7 años.
   - Sin re-tratar en 7 años; una IB nueva reinicia el reloj, sin acumular. Sin cambio de estado.
   - HED sin cambio (`hed_bi = hed_control`): sin beneficio HED por defecto (GUION:137).
   - Secuencia AGENTS §3: efecto → g/día → `alc_cat` (escala de encuesta, sólo diagnóstico) → RR, sin participación.
3. **[lunes]** Entrega por cuota: `k = round(n_target / unit_weight)` agentes abiertos con menor `u`; el uniforme se sigue sorteando para todos, así que los CRN quedan intactos. `new <- open & base::rank(base::ifelse(open, u, Inf), ties.method = "first") <= k`. Denominador "abiertos"; en S2, reportar entregadas vs meta.
4. **[después]** Cascada chilena (APS → tamizaje → positividad → entrega); efecto sorteado desde su IC; YLL con `yll_hmd` (D12).

**Listo cuando**
- **Nulos y entrega.** S0 y S3: evitadas `identical()` a 0. S1 (T7): |entregadas − 35.000| ≤ 0,5 × peso unitario cada año mientras `sum(open)` ≥ k; si no, se reporta saturación. S2: entregadas/meta por año y primer año con `sum(open)` × peso < meta.
- **Aplicación.** En el año de entrega, el g/día de riesgo de los receptores es 0,877 × el del control (1e-12).
  - No receptores y estado sin cambio. g/día ≥ 0.
  - Principal: `hed_bi == hed_control`. Sensibilidad HED: `hed_bi ≤ hed_control`, con el ΔHED implícito reportado frente a −0,07.
- **Orden y semillas.** Evitadas(S2) > evitadas(S1) > 0. La DE entre semillas del acumulado de S1 es ≤ 10 % de la media (prototipo: 5,4 %).

**Sensibilidades.**
- **Escala.**
  - Kaner ≈ −8 % (−20 g/semana sobre 244).
  - Manthey −12,0 % (H) / −15,8 % (M).
  - Lemp −2,86 g/día **en escala de riesgo**, aplicado plano (la fórmula de escalamiento de Lemp está en los eMethods, no leídos). Nunca × factor sobre la escala de encuesta sin justificarlo.
- **Duración.** 4 años plenos y luego lineal a 0 al año 10; SAPM pesimista (−5,9 %, retorno en 3 años, o ambos); 1 año; nulo.
- **Comparador chileno.** 50 % del efecto, porque el comparador es el folleto.
- **HED.** Re-evaluado con el g/día nuevo y el mismo `z_hed`; DR −0,07. S1 se reporta con y sin efecto HED.
- **Elegibilidad.** Umbral en escala de encuesta.
- **Persistencia de la cantidad.** ρ_cantidad {0,5; 0,8; 0,95}: controla cuánto dura el efecto en g/día absolutos.

**Qué NO hacer.**
- Aplicar la IB antes de la reconciliación, o dos veces.
- Acumular −12,3 % por repetición.
- Crear abstemios.
- Dar efecto a la cobertura existente. Las 75.854 IB de 2018 ya están en la ENPG basal (cifra reportada en Barticevic 2021; verificar antes de citar).
- Sumar Kaner, SAPM y la OR chilena, o volver a multiplicar por adherencia.
- Publicar evitadas sin el nulo al lado.

### Ítem 5 — Envejecimiento y recambio poblacional (posterior)

Tu premisa es correcta. El tamaño es mayor de lo que sugiere "posterior".

**Diagnóstico con datos** [verificado con datos] ([MO] §3.1, [MO-v] 12–13; [MT] §2.4)

- **Peso de los 66+ años.** Concentran:
  - 79,5 % (mujeres) / 66,2 % (hombres) de todas las muertes de 15+;
  - 78,0 % / 58,4 % de las causas parcialmente atribuibles;
  - 26,1 % / 30,5 % de las AAF = 1.
- **En las causas del lunes** (2012–2024): cirrosis 50,9 % / 32,7 %; tránsito 25,0 % / 16,0 %; otras no intencionales 77,1 % / 35,3 %; intencionales 9,5 % / 11,2 %.
- **Atribuible a los 66+ (68 % / 44,5 %).** Es aritmética sobre un supuesto (la AAF de 60–65 arrastrada), no una estimación.
- **Reconciliación INE de enero.** Agrega y quita personas al azar. En un diseño de supervivencia divergente borra a los sobrevivientes.

**Problema reformulado.** El lunes trunca los beneficios a los 66+, y la salida a los 66 corta los beneficios rezagados. La dirección neta es incierta, porque el estado estacionario sobrestima cirrosis. Este ítem está en la ruta crítica de cualquier paper, aunque no del lunes.

**Acción**

1. **[lunes]** Población cerrada 15–65, rotulada "trunca a los 66+".
2. **[semanas 2–4]** Abrir hasta ~80 años [propuesta].
   - Cambios: `ms_cfg$max_age`; los filtros `15:65` de `ms-demography-inputs` (L29, 47, 59, 69–70); los `51L` de L39, 52, 79 y 83.
   - `ms_age_group` ya asigna ≥60 al grupo 4, así que arrastrar los drivers de 60–65 no requiere código nuevo.
   - El bundle DEIS ya cubre 15+. Hay RR 65+ para IHD/IS; `aaf_age_band_mapping` necesita un 5.º grupo.
   - Extender el motor rompe la equivalencia "AAF (15–65) = motor microsim" de D13: exige reabrir D13 o declarar que dejan de tener el mismo alcance (AGENTS §5).
3. **[decisión]** Consumo sobre 65 años. Opciones:
   - arrastre de 60–65 [supuesto] (choca con D13: "sin ENS/EPS/carry-forward");
   - puente EPS (D14, que choca con D13; Kimi P4 lo califica de débil);
   - ENS.

   No hay precedente publicado de imputación sobre el tope de edad de una encuesta [INV].
4. **[después]** Tasas de migración, o los flujos del control reproducidos, en vez de la reconciliación.

**Listo cuando**

- Nadie sale a los 66 salvo por muerte o por el nuevo tope.
- N(t+1) = N(t) + entradas − muertes − salidas ± flujos, exacto por sexo × edad.
- Las muertes 66+ quedan dentro de 0,5 % de DEIS (calibración).
- Las muertes evitadas se reportan por opción de exposición.

**Supuesto.** El arrastre sobrestima: la prevalencia cae después de los 60 y el RR de IHD se atenúa con la edad.

**Qué NO hacer.** Citar 68 % / 44,5 % como estimaciones, o extender el modelo antes del lunes.

---

## 2. Entregable del lunes (12-oct)

### 2.1 Alcance

- **Motor.** El de `microsim_recalib_ACC_2012_2024.ipynb`: reconstrucción `interp_hold` 2012–2024 y hold-last 2025–2034.
- **Población.** 15–65 años; n_sim 25.000; semillas 2125–2129.
- **Causas:**
  - lesiones de tránsito, otras lesiones no intencionales y lesiones intencionales: agudas (100 % el año 1, STAPM);
  - cirrosis hepática (K70, K74), sin rezago y rotulada "cota superior de corto plazo" (STAPM: 20,2 % del efecto el año 1, ~49 % al año 3, ~90 % al año 10). Pesos de Holmes como sensibilidad.
- **Frente a Lemp 2026.** Se adoptan sólo los receptores incrementales y la exclusión de cánceres. Difieren:
  - escala del efecto (SAPM −12,3 %, no −2,86 g/día escalado);
  - sin re-tratamiento en 7 años (Lemp re-selecciona cada año);
  - HED sin cambio (Lemp: DR −0,07);
  - "lesiones intencionales" incluye violencia interpersonal (X85–Y09, Y87.1; Lemp: sólo suicidio), y no hay AUD (AAF = 1).
- **AAF = 1.** Fuera del PIF (D8) y de las salidas.
- **Fuera del lunes.** 21 causas, 100k agentes, filas AAF = 1, spline por edad simple, rasgo/abstemios de por vida, Fix B, YLL, cascada, sorteos de RR, re-exportar salidas viejas, notebook nuevo.

### 2.2 Escenarios (una corrida lleva el control y la IB sobre la misma población)

| ID | Escenario | Parámetros | Para qué |
|---|---|---|---|
| S0 | Sin intervención | IB apagada; el uniforme se sortea igual | Control; referencia de T13 |
| S1 | IB incremental | 35.000/año desde 2025; −12,3 %; retorno lineal en 7 años; elegibles >20/>40 g/día de riesgo; sin re-tratar en 7 años; HED sin cambio | Ilustrativo: ≈46 % del volumen público de 2018 (75.854 según Barticevic 2021 [INV], a verificar) |
| S2 | IB × 10 | 350.000/año; el resto igual | Dosis-respuesta y saturación de elegibles |
| S3 | Efecto nulo | Entrega de S1 con efecto 0 | Cota inferior obligatoria (ensayos chilenos no superiores al folleto) |
| V | Paridad | 2024: g/día × 0,9 en bebedores actuales; HED y estado sin cambio; R̄_w del control | Prueba frente a pif2 (T6); no es una política |

### 2.3 Archivos (AGENTS §4, §7)

Todos van en `__andres_control/`.

- **`microsim_engine.R`.**
  - Parte de los scripts del prototipo en `scripts_nube_2026-10-09.tar.gz`: `work/run/proto_integration.R` y `proto2.R` (brazos pareados), `audit/rr_bridge_lib.R` (`rr_individual`, `bridge_load`), `audit/hed_06_fix.R` (Fix A), `audit/05_hazard_formula_selfcheck.R` y `audit/verify_hed/v0_loader.R`. Se reemplazan los marcadores `<repo>`/`<scratch>` por `here::here()` y la lectura de parquet por Python por `arrow::read_parquet`. El encabezado anota el origen (tar.gz + ruta).
  - Se aplican las 3 correcciones conocidas: R̄_w ponderado por hazard, denominador "abiertos" con cuota, e IB una vez al año en t+1.
  - Las celdas `ms-setup`, `ms-survey-inputs`, `ms-demography-inputs`, `ms-calibration-functions` y `ms-annual-engine` van como código de nivel superior, sin envolver (`ms_simulate` lee globales): `ms_table <- function(...) base::invisible(NULL)`; `here::i_am()` del .R nuevo; `base::Sys.time()`; sin `ms-wave-comparability`.
  - Carga del registro como en los tests: `source(rr_registry_adam.R)` y `source(aaf_unified.R)` (Tabla 5 no hace falta para las 4 causas); luego `base::stopifnot()` sobre `names(formals())` de `rr_individual`, `aaf_age_band_mapping` y `ms_simulate` (AGENTS §5). `ms_rel_risk()` llama a `rr_individual()`.
  - Ganchos: `never_rr`, offset HED, mortalidad DEIS/INE, `ms_rel_risk` con R̄_w, `ms_bi` y `ms_simulate` de dos brazos.
- **`microsim_bi_demo.R`.** `base::Sys.setenv(ACC_DEIS_VERSION = "06102026")` antes de cargar datos. Corre S0–S3 y V, y escribe las salidas y las aserciones de corrida completa (T4–T7, T10-DE, T10-z, T14).
- **`test_microsim_engine.R`.** Sólo invariantes deterministas (T1-S3, T2, T3, T8, T9, T10-identidad, T11, T12, T13) con 2024–2025, `bi$start = 2024L` y 5.000 agentes. El cargador sigue descifrando ENPG/DEIS, así que no es instantáneo.

Reglas:
- `package::function`; `.t0` al inicio y minutos al final; comentarios en inglés.
- Datos sólo vía `acc_data()` / `acc_deis()`.
- Sin carpeta ni paquetes nuevos. La carpeta ya tiene el `.Rprofile` de renv.
- Notebooks intactos. Con tu permiso, después podrán hacer `source()` del motor.

### 2.4 Salidas (agregadas, CSV plano en `__andres_control/`)

| Archivo | Columnas |
|---|---|
| `microsim_integracion_resultados_2026-10-12.csv` | `year, sex, age_group, cause, scenario, seed, n_sim, expected_control, expected_bi, avoided, sampled_control, mc_variance, bi_target, bi_new, bi_active, gpd_risk_control, gpd_risk_bi, hed_control, hed_bi`; cada sensibilidad es un `scenario` |
| `microsim_integracion_paridad_2026-10-12.csv` | `year, cause, sex, age_group, aaf_engine, aaf_expand_pif, diff, pif10_engine, pif10_pif2, rel_diff, convention` |
| `microsim_integracion_checks_2026-10-12.csv` | `check_id, description, value, tolerance, pass, seed` |
| `microsim_integracion_procedencia_2026-10-12.csv` | archivo, md5, commit git, `R.version.string`, hash de `renv.lock` (como `ms_exposure_provenance`) |

### 2.5 Aserciones

| ID | Aserción | Tolerancia | Archivo |
|---|---|---|---|
| T1 | S0 y S3: `avoided` = 0 en todas las celdas | `identical()` | test (S3) / demo |
| T2 | Todos los RR = 1 ⇒ AAF = 0 y evitadas = 0 | exacto | test |
| T3 | Σ_i h_ic = N·h̄_c (ponderado por hazard); el brazo IB usa el normalizador del control | < 1e-10; `identical()` | test |
| T4 | Muertes esperadas totales del control frente a la meta DEIS cohorte-consistente, por año × sexo; por tramo con la meta de §1 Ítem 3 | < 0,5 % (por tramo < 2 %) | demo |
| T5a | Cableado: `rr_individual` sobre la población sintética de los insumos de expand_pif (cuantiles estratificados del bundle `aaf_engine_inputs_bundle_20261007.rds`, como [RB] (b)), truncando [0,1; 150]: \|ΔAAF\| y \|ΔPIF10\| en 4 causas × 8 celdas | ≤ 1e-3 ([RB-v]: 5,8e-4 / 1,4e-4) | demo |
| T5b | AAF del motor (su propia población) frente a expand_pif, 2024, truncando | sólo se reporta; marcar > 0,05 | demo |
| T6 | PIF(−10 %) del motor (escenario V) frente a pif2 | sólo se reporta; marcar celda > 25 % | demo |
| T7 | IB entregadas en S1 por año (cuota) | ≤ 0,5 × peso unitario mientras `sum(open)` ≥ k | demo |
| T8 | Receptores = 0,877 × control en el año de entrega; no receptores y estado idénticos; g/día ≥ 0; `hed_bi == hed_control` (principal) | 1e-12 / exacto | test |
| T9 | Σ causas + otras = total; N(t+1) = N(t) + entradas − muertes − salidas ± reconciliación | 1e-10 / entero exacto | test |
| T10 | Misma semilla ⇒ salidas idénticas; DE entre semillas ≤ 10 % de las evitadas acumuladas en S1; sorteadas frente a esperadas por año × sexo (todas las causas, brazo control, por semilla, con `mc_variance`) | `identical()`; ≤ 10 %; \|z\| ≤ 3 | test / demo |
| T11 | `factor_CH` idéntico entre brazos; elegibilidad en la escala elegida | exacto | test |
| T12 | Guarda de locale: 6.963 exbebedores en 2024 | exacto; falla rápido en locale C | test |
| T13 | Por semilla, `expected_control` (año × sexo × edad × causa) idéntico entre S0, S1, S2 y S3 | `identical()` | test / demo |
| T14 | Efecto = 1 (g/día → 0, sin cambio de estado), todos los elegibles tratados ⇒ 0 ≤ evitadas ≤ esperadas_control × AAF, por causa × celda | exacto | demo |

### 2.6 Qué se puede afirmar (texto literal)

> "componentes conectados y verificados; transiciones, persistencia HED, efecto IB y su duración son supuestos; validación epidemiológica pendiente"

Las evitadas se presentan como escenario ilustrativo, nunca como cifra 2025–2034 citable (Veredicto 9). Van siempre con seis rótulos:
- "15–65: trunca beneficios a los 66+ (dirección neta incierta)";
- "estado estacionario; cirrosis sin rezago";
- "DEIS 2024 provisional";
- "supervivencia compartida: evitadas = suma anual de diferencias de riesgo esperado sobre la población control; sin ganancia acumulada de supervivencia";
- "exposición ENPG urbana aplicada a la población nacional (D13)";
- "corrida en la nube fuera de renv" mientras no exista la corrida local (AGENTS §6).

### 2.7 Orden de trabajo, viernes a lunes

| Cuándo | Paso | Listo si |
|---|---|---|
| Vie | 0. En la máquina local, R en la raíz (activa renv; `renv.lock` fija R 4.4.1): cargador + T12 + `ms_simulate` de 2 años. Todo el desarrollo posterior va bajo renv | Corre bajo renv |
| Vie | 1. `microsim_engine.R` desde los scripts del prototipo (§2.3). Regresión: `identical()` entre `ms_simulate(ms_fit(2024, "interp_hold"), 2012:2014, 1500L, 2125L)` del archivo nuevo y el de las celdas evaluadas en sólo lectura desde el .ipynb en la misma sesión (patrón `v0_loader.R`), antes de los ganchos. Contra las salidas exportadas sólo se comparan columnas de consumo, a nivel de error MC y rotuladas "DEIS viejo" | Pasan T12 y la regresión |
| Sáb AM | 2. `never_rr`, `factor_CH`, `ms_rel_risk` → `rr_individual()` con R̄_w, sobre la mortalidad actual con un multiplicador por sexo × año (una línea en `ms_fit`) | Pasan T2, T3 y T5a |
| Sáb PM | 3. `ms_bi` (cuota, una vez al año en t+1) y brazos pareados; S0/S1/S3 × 5 semillas. La demo completa existe el sábado en la noche | Pasan T1, T7–T11, T13 y T14 |
| Dom | 4. V (T6), DEIS/INE con q_jan (T4), meta HED escrita + Fix A, S2; se re-corre todo | Pasan T4 y Listo cuando del Ítem 2; T5b/T6 reportados |
| Lun AM | 5. Sólo la corrida final: 4 CSV, nota de 1 página, entrada en el [HO] | Rótulos de 2.6 |

**Si falta tiempo, soltar en este orden:**

1. S2.
2. Fix A. El sesgo HED de 2024 (−2,4 pp ponderado) pasa a limitación; en las lesiones del lunes, la AAF baja 0,8–0,9 % (H) y 7,3–7,9 % (M).
3. DEIS/INE. Se queda el multiplicador HMD por sexo × año (no 0,9645 / 0,9413 por sexo); T4 pasa a "DEIS 15–65 por año × sexo, por construcción".

**Respaldo si fallan T3 o T5a:** ruta (a) de D9, muertes DEIS × PIF(control vs IB) con la exposición simulada.

**No se suelta nunca:**

- T1 y T13;
- la supervivencia compartida con muertes esperadas;
- el normalizador del control;
- T5a;
- la IB aplicada una vez al año, después de la reconciliación.

---

## 3. Evaluación del código (ponytail)

**Sólido; conservar**

- **Motor.** Anual discreto, en R base + dplyr, y es el mismo en base y recalib.
- **Márgenes.** `interp_hold` reproduce exactamente los márgenes de la ENPG.
- **Exposición.** Se evalúa a la edad alcanzada [MT].
- **Cópula con umbrales.** Conserva los márgenes con cualquier λ/φ [PE].
- **Muertes esperadas.** Ya se calculan (`ms-annual-engine` L88–93) [MO-v].
- **Escala de encuesta.** Es idéntica a la de expand_pif: `gpd_survey × factor_CH` reproduce los gamma del bundle a 1e-16 en 2024 [RB-v] 5b (en 2014 los pesos difieren hasta 7,8 %); el HED coincide 100 % con el ítem crudo [HD, leído, no re-corrido].
- **Tests.** Pasan los 5 tests del registro RR [RB-v] 2. `test_pif3_primary_rr_sources` y `test_hed_exit_knobs` pasaron en la corrida de [RB]; el verificador no los re-corrió. Todo fuera de renv.
- **Mapa CIE-10.** Igual al de expand_pif [MO-v].

**Bugs y riesgos, ordenados**

| # | Problema | Dónde | Efecto → arreglo |
|---|---|---|---|
| 1 | Salidas obsoletas | `microsim_recalib_outputs/`, `microsim_base_outputs/` (`input_provenance.csv`: md5 `edb4f608…`) | 1.815 muertes de más; multiplicadores errados → no citar; README "DEIS previo al 05-oct"; re-exportar sólo con tu permiso [MO-v] |
| 2 | Reconciliación INE frente a los brazos | `ms-annual-engine` L103–120 | Borra sobrevivientes; `sample.int` desalinea el RNG → lunes: supervivencia compartida; después: flujos reproducidos |
| 3 | Normalizador con media simple (bosquejo) | `ms_rel_risk` en [MT] §3 | Error 3,5e-3 → ponderar por hazard [MO-v] 19 |
| 4 | Ley Gamma de g/día | `ms-annual-engine` L20–27; `ms-calibration-functions` L49–54 | Sesgo HED → Fix A para el lunes (soltable); Fix B en la semana 1 |
| 5 | `alc_cat` en escala de encuesta | `ms-annual-engine` L35–39 | cat2/cat3 casi vacías; nada de la cadena del lunes lo lee → diagnóstico, recodificado tras la IB; reescalarlo choca con D3 (después) |
| 6 | Locale | `ms-survey-inputs`; `enpg-consolidate` de expand_pif | En locale C, 4.244 de 6.963 exbebedores pasan en silencio a "desconocido" → guarda T12 [RB-v] 14 |
| 7 | `ever` irreversible; un solo ρ | L30–33, L125–126 | "Nunca" = 6,3 % → ítem 1 |
| 8 | HMD × multiplicador; q a la edad de enero | `ms-calibration-functions` L78–85; L82–87 | Deriva; ~3 % de error de nivel; sin mejora después de 2024 → DEIS/INE + q_jan |
| 9 | `histories` con 12 ids | `ms-annual-engine` L61 | El chequeo cubre 12 mujeres de 15 años → aserción poblacional |
| 10 | Tests rotos (B9) | `test_aaf_compute.R:24`, `test_aaf_unified.R:60` | Falta `ihd_is_binge_aaf.R` → restaurar o quitar la dependencia [RB] |
| 11 | Dos vintages INE | `ine_proyecciones_rebuild/ine_proyecciones.xlsx` frente a `ine_basedatos.xlsx` | Hasta +1,6 % en 2020 → fijar `ine_basedatos.xlsx`, hoja `BBDD_EEPP-2024_0101` |
| 12 | DEIS 2024 provisional | `FUENTE_DEIS_2024_2026_06102026` | R99: 810 frente a 609; tránsito: 1.224 frente a 1.363–1.659; 41 duplicados → suavizar; fijar `ACC_DEIS_VERSION` |
| 13 | Exbebedor a 30 días frente a RR a 12 meses | ambos pipelines | 42,1 % de los ex reciben RR_FD → declarar; sensibilidad a 12 meses |
| 14 | Pesos 2014 ≠ `exp` (hasta 7,8 %) | ENPG 2014 | La identidad del factor vale año por año → chequearla en cada ola [RB-v] 5b |

**Congelar.** Es [propuesta]: borrar o editar notebooks requiere tu permiso.

- `microsim_base_ACC_2012_2024.ipynb` y `microsim_base_outputs/`, ya superados.
- `jrt/simulacion/` (`MWE.R`, `Alcohol Transitions*.R`, `patch_micSim.R`): queda como procedencia, sin `source()`.
- La maquinaria de especificaciones de recalib (static2012, linear_all, spline_shared, rolling origin, fuga 4×4): queda como evidencia y no se porta.

**No construir ahora** ([MT] §4):

- data.table o MicSim;
- SES, bebidas, precios, costos ni optimizaciones de velocidad;
- *history matching*;
- incertidumbre de parámetros;
- rezagos de Holmes (salvo como sensibilidad de cirrosis);
- AAF = 1 en el PIF;
- la cohorte 66+;
- brazos divergentes;
- Gamma por ola.

Para el lunes, además, lo de "Fuera del lunes" en §2.1.

La única excepción es la intensidad empírica (Fix B, semana 1), contra el "no construir" de [MT]: el verificador identificó la Gamma como causa [HD-v]. Fix B es prometedor sólo analíticamente: no se simuló, y su efecto en la paridad T5b no se evaluó.

---

## 4. Qué enseñan los modelos similares ([INV])

1. **SIMAH.** Se leyó `charlotteprobst/simah` v1.0.1, commit `2fd8c1ea8c95de0a7137e31db2560a5ceb60339d`.
   - No se verificó que sea equivalente a Zenodo 0.1.1 (DOI 10.5281/zenodo.15641639).
   - No trae los módulos de IB ni de precio por bebida.
   - → Sirve de plantilla de **estructura**, no de parámetros.
2. **Kilian 2025 modela sólo mortalidad por todas las causas.** El precedente de IB + RR por causa es **Lemp 2026** (DOI 10.1001/jamahealthforum.2026.2348). → No citar a Kilian para RR por causa.
3. **Lemp 2026.**
   - Efecto sólo en receptores **incrementales**: −2,86 (EE 0,58) g/día, "scaled using each individual's current level of consumption" (fórmula en los eMethods, no leídos).
   - HED: DR −0,07, sorteado aparte.
   - Re-selección en cualquier año. El decaimiento no se describe en el texto principal.
   - Sin cánceres. Causas: AUD, hígado, tránsito, otras no intencionales y suicidio.
   - → El lunes adopta sólo los receptores incrementales y la exclusión de cánceres; el resto difiere (§2.1).
4. **SIMAH: riesgo = RR × tasa a TMREL**, "ajustada" a las estadísticas vitales.
   - Las causas no modeladas salen de conteos observados.
   - Sin rezagos. Edades 18–79.
   - En v1.0.1 y Lemp 2026 el HED modifica sólo lesiones; Kilian 2025 no tiene HED (conflicto declarado en [INV]).
   - → Hazard × RR normalizado, con "otras" desde DEIS.
5. **SIMAH re-sortea a los exbebedores cada año** según las proporciones observadas; no sigue su historia. → Estado transversal para el RR (D4b).
6. **IMPACTncd: m0 = mu × (1 − PARF)**, con la media simple del RR y factores de calibración (`clbtrend`, `clbons` = 1,45); su código advierte que el producto no tiene por qué igualar lo observado. → Aquí, con R̄_w ponderado por hazard, reproducir DEIS sí es una identidad [MO-v] 19, y la paridad de AAF es una prueba unitaria.
7. **STAPM (`tobalcepi::AlcLags`).**
   - Agudas: 100 % el año 1.
   - Cánceres: 0 durante 10 años.
   - IHD/ACV: ~10 años. Cirrosis: 20,23 % el año 1, hasta 20 años.
   - → El estado estacionario es una cota superior de corto plazo para las crónicas, cirrosis incluida.
8. **Números aleatorios comunes (CRN).** Bajan 82 % la varianza de las diferencias, contra 71 % si se usa una cohorte 10 veces mayor (Stout y Goldie 2008). Krijkamp 2018 pide una semilla por individuo. → Brazos pareados con muertes esperadas.
9. **Magnitud de la IB.**
   - Kaner 2018: −20 g/semana (−28 a −12), ≈ −8 %; reporta reducción en ambos sexos.
   - Manthey: −12,0 % (H) / −15,8 % (M), con 4 años plenos y luego lineal hasta el año 10.
   - SAPM: −12,3 % (IB de 24,9 minutos, Kaner 2007) con retorno lineal en 7 años; pesimistas: −5,9 %, retorno en 3 años, o ambos.
10. **Chile.**
    - Barticevic 2021 (80 % vs 71 % a bajo riesgo; aOR 0,6, IC 0,34–1,05; AUDIT −0,86, IC 0,06–1,66, d = 0,21) y Poblete 2017 no son superiores al folleto en el desenlace primario. Las notas marcan un IC secundario discordante entre resumen y cuerpo.
    - En Alemania, el consumo cambió significativamente sólo con tamizaje ≥50 % (−11,4 %); no se reporta un resultado a 25 % (el ≳25 % de las notas es inferencia).
    - → Escenario nulo obligatorio. La pregunta útil es qué volumen de IB haría falta.
11. **América Latina.** No se encontró ninguna microsimulación individual de mortalidad por alcohol en la región, ni precedente de imputación sobre el tope de edad de una encuesta.
12. **Verificación.** ISPOR-SMDM y TECH-VER dan el marco; las pruebas V1–V8 (nulo, RR = 1, extremos, contabilidad, reproducción analítica, semillas y pruebas unitarias) y sus tolerancias son una propuesta de los investigadores, sin estándar publicado. Reproducir DEIS tras escalar es calibración. → "Verificado y calibrado, aún no validado".

---

## 5. Decisiones que necesitas (y propuesta por defecto)

ACC no aprobó ninguna por escrito (Q24) [NT].

| Decisión | ¿Bloquea el lunes? | Por defecto [propuesta] | Evidencia | Quién |
|---|---|---|---|---|
| Puente exposición → muerte | Sí | (b) individual: hazard × RR/R̄_w del control; supervivencia compartida. Alternativa (a), D9: muertes DEIS × PIF(control vs IB); también respaldo si fallan T3/T5a | [NT] §2 A.1, D9; [RB-v]; [MO-v] 19 | usuario/ACC |
| Escala del efecto IB | Sí | −12,3 % relativo. Sensibilidades: Kaner ≈ −8 %, Manthey, Lemp −2,86 g/día **en escala de riesgo**. Nunca aplicar el factor APC a un efecto clínico sin justificarlo | [INV], [NT] §3 | usuario + ACC/CC |
| Duración y decaimiento | Sí | Retorno lineal en 7 años, sin acumular. Sensibilidades: 4+6 años; −5,9 %, 3 años o ambos; 1 año | [INV] | usuario |
| Elegibilidad | Sí | >20 (M) / >40 (H) g/día en escala de riesgo (= >3,35 / >6,7 de encuesta en 2024). Choca con GUION:220; alternativa: escala de encuesta. Falta el puente AUDIT ↔ g/día | [MT] §2.7; [NT] §2 A.5, §3 | usuario + ACC |
| Cobertura | Sí | Sólo incremental; 35k y 350k como ilustración | Lemp; [NT] §3 | usuario/ACC |
| Efecto sobre HED | Sí | Sin cambio (GUION:137); vía g/día y DR −0,07 como sensibilidades | [NT] §2 A.4; [HD] | usuario |
| ¿La IB cambia el estado? | Sí | No (decisión de diseño) | [RB-v] 9; Q25 | usuario |
| Escala de riesgo (D3) | Sí | Factor OMS sólo en RR/AAF/PIF y elegibilidad; congelado tras 2024 | [NT] D3: ACC/CC no confirmado; contradice "para intensidad tal vez sí" (PLAN:45) | usuario + ACC/CC |
| Tope o truncamiento en 150 g/día | Sí | Tope en el motor; truncamiento sólo en la paridad | [RB-v] 12a | usuario |
| Estacionario o rezagos | Sí | Estacionario; 3 lesiones agudas + cirrosis rotulada "sin rezago: cota superior de corto plazo"; pesos de Holmes como sensibilidad | STAPM; D11 | usuario/ACC |
| Inicio y horizonte | Sí | Base 2024; IB 2025–2034 | [NT] §2 | usuario |
| Vintage INE | Sí | `ine_basedatos.xlsx`; el otro como sensibilidad | [MO-v] 9 | usuario |
| Versión DEIS | Sí | `ACC_DEIS_VERSION` = 06102026, fijada en el script; 2024 suavizado | [MO-v] 14; Q19 | usuario |
| Mortalidad y drivers tras 2024 | Sí | Mantener 2024 (hold-last); tendencia log suave como alternativa | [MT] §2.5; [INV]; [NT] B.18 | usuario |
| Meta HED | Sí, si corre Fix A | Casos completos entre bebedores con g/día > 0 (D5 + restricción nueva g/día > 0); serie SENDA al lado | [HD-v], [RB-v] 5c; D5 | usuario; JRT por ola |
| Definición de exbebedor | No (D4) | 30 días, con la advertencia del 42,1 % | [RB-v] 8b | usuario (confirmado) |
| AAF = 1 | No (D8) | Fuera del PIF | [MO-v] 21 | usuario (confirmado) |
| Olas 2020 y 2022 (D6, Q20) | No | 2020 marcada no comparable (Fix A la ajusta por construcción); pesos 2022 y quiebre de marco 2024 sin resolver | [NT] D6, B.11, B.14 | usuario/CC |
| Fracción de abstemios de por vida s | No | s_entrada = "nunca" a los 25–29, 2014–2022, ±25 % [PE]. La EPS sólo acota s a 0–35 % (H) / 0–62 % (M) | [PE] §6; [PE-v] 11 | usuario/CC |
| λ/φ y ρ de cantidad y HED | No | Legado el lunes. Después `trait_share` 0,32 / `ar_phi` 0,66 (condicional a s_EPS = 0,20) en lugar de D1, y cantidad `trait_share_a` 0,40 / `ar_phi_a` 0,5 (revisa D1b) | [PE]; D1, D1b | usuario/CC |
| λ de salida de HED (D10) | No | Sólo si se usa la sensibilidad HED: mismo mecanismo que expand_pif2; el principal es ambiguo (HO:8247 vs HO:8256) | [NT] D10 | usuario |
| YLL | No | `yll_hmd` (D12) frente al YPLL-75 de Lemp; los YLL más allá de la primera década requieren brazos divergentes | [NT] D12; [MT] §4 | usuario |
| Consumo sobre 65 | No | Arrastre de 60–65; EPS/ENS como sensibilidad. Choca con D13 (sin ENS/EPS/carry-forward; AAF = motor 15–65) y con D14 | D13, D14 | usuario/ACC |

---

## 6. Riesgos y lo que no hay que afirmar el lunes

- **Calibración no es validación.** Reproducir DEIS, los márgenes ENPG, el HED 48/48, el nunca/ex 2,8/2,9 pp y la AAF de expand_pif son ajustes dentro de muestra o identidades.
- **No queda holdout.** 2022/2024 ya se usaron (D15). En HED, el error retenido (~5 pp) es igual al de mantener la última ola, y Fix A no mejora el RMSE retenido del motor sin corregir (4,99 vs 5,39 pp).
- **15–65 trunca beneficios a los 66+.** El 66–80 % de todas las muertes ocurre a los 66+, pero en las causas del lunes la proporción es menor (9,5–77,1 %), y la cirrosis sin rezago sobrestima el corto plazo: la dirección neta es incierta ([MO] §3.1, [MO-v] 12).
- **2024 es provisional.** R99 +33 %; tránsito bajo el rango 2012–2023; archivo semanal ([MO-v] 14). K70 cae 37 % entre 2022 y 2023 sin explicación (¿codificación?): preguntar a DEIS.
- **Exposición urbana.** La ENPG es urbana (≈70 % de la población en 2014/2016 [INV]) y se aplica a la población nacional INE/DEIS (D13).
- **Las semillas no son incertidumbre científica.** No se propagan:
  - los RR;
  - el IC de la IB (−28 a −12 g/semana);
  - el decaimiento;
  - el factor APC (4,35–5,97). Si se omite el factor, la AAF queda en una mediana de 0,53× ([RB-v] 12b).
- **Transferibilidad.** Kaner compara contra una intervención mínima o nula; en Chile el comparador es el folleto, y los dos ECA chilenos no fueron superiores a él en el desenlace primario. El −12,3 % viene de una IB de 24,9 minutos; la chilena dura 5. No hay evidencia chilena por sexo ni en mayores.
- **Magnitud.** Las muertes evitadas son unidades a decenas al año (prototipo, 2 causas: 2,5–7/año con 35k IB; 25–44 con 350k), frente a 16.306 muertes en las 21 causas (2024, 15–65). El escenario nulo va siempre al lado.
- **`presentacion_micsim.qmd` está desactualizada.** Dice "MicSim" y "60+", nombra mal la ENPG, dice "PIF sólo lesiones" y afirma que α = 0,5 controla la persistencia. No presentar desde ella sin corregirla; editarla requiere tu permiso.
- **ACC no aprobó nada por escrito (Q24).**

---

## 7. Trazabilidad

- [engine_ponytail.md](auditoria_microsim_2026-10-09/engine_ponytail.md): mapa frente a SIMAH, bugs, ganchos probados y archivos propuestos. Sin verificación independiente.
- [persistence.md](auditoria_microsim_2026-10-09/persistence.md) / [persistence_verify.md](auditoria_microsim_2026-10-09/persistence_verify.md): ajuste EPS, metas nunca/ex y modelo mover–stayer. El verify corrige la identificación de s y el ajuste dentro de muestra.
- [hed_diagnostic.md](auditoria_microsim_2026-10-09/hed_diagnostic.md) / [hed_diagnostic_verify.md](auditoria_microsim_2026-10-09/hed_diagnostic_verify.md): descomposición del sesgo, Fix A y definición por ola. El verify ubica la raíz en la Gamma y descarta E_bins.
- [mortality_deis.md](auditoria_microsim_2026-10-09/mortality_deis.md) / [mortality_deis_verify.md](auditoria_microsim_2026-10-09/mortality_deis_verify.md): deriva, DEIS/INE, causas y 66+. El verify corrige el normalizador, los vintages INE y el piso de ruido.
- [rr_bridge.md](auditoria_microsim_2026-10-09/rr_bridge.md) / [rr_bridge_verify.md](auditoria_microsim_2026-10-09/rr_bridge_verify.md): contrato RR, paridad, locale y tests. El verify corrige el impacto del sesgo HED y la regla de abandono.
- [notes_decisions.md](auditoria_microsim_2026-10-09/notes_decisions.md): decisiones D1–D20 con su estado, puntos abiertos y matriz de evidencia de la IB. No se minaron `encargos_kimi_cierre_expand_pif_2026-10-06.md`, p6/p8/p9kimi (p6kimi trata urbano y DEIS 2024) ni el borrador `guion_reunion_ACC_2026-09-16.md`.
- `auditoria_microsim_2026-10-09/scripts_nube_2026-10-09.tar.gz`: scripts de scratch de la nube (`audit/`, `audit/verify_*`, `work/`). Usan rutas de marcador de posición y leen parquet con Python; no corren tal cual. Sólo escriben agregados.
- [Informe de investigación](../reports/Microsimulaci%C3%B3n%20de%20alcohol%20y%20mortalidad.md) y sus [notas](../research_notes/Microsimulaci%C3%B3n%20de%20alcohol%20y%20mortalidad/): arquitectura, trayectorias, HED, mortalidad/RR, IB y verificación.
- Código externo leído, no vendorizado:
  - SIMAH `charlotteprobst/simah` v1.0.1, commit `2fd8c1ea8c95de0a7137e31db2560a5ceb60339d`;
  - tobalcepi, commit `054ca37190ad901aa5028bd6222e831083472eaa`;
  - IMPACTncd_Engl, commit `3c44cbf4a6ec974b0730c181381d6ebfcb0d0ba4`.
- Registrar este plan en el [handoff canónico](codex_handoff_adam_rr_full_override_caveman.md) con un enlace, sin copiar su contenido.

[MT]: auditoria_microsim_2026-10-09/engine_ponytail.md
[PE]: auditoria_microsim_2026-10-09/persistence.md
[PE-v]: auditoria_microsim_2026-10-09/persistence_verify.md
[HD]: auditoria_microsim_2026-10-09/hed_diagnostic.md
[HD-v]: auditoria_microsim_2026-10-09/hed_diagnostic_verify.md
[MO]: auditoria_microsim_2026-10-09/mortality_deis.md
[MO-v]: auditoria_microsim_2026-10-09/mortality_deis_verify.md
[RB]: auditoria_microsim_2026-10-09/rr_bridge.md
[RB-v]: auditoria_microsim_2026-10-09/rr_bridge_verify.md
[NT]: auditoria_microsim_2026-10-09/notes_decisions.md
[INV]: ../reports/Microsimulaci%C3%B3n%20de%20alcohol%20y%20mortalidad.md
[HO]: codex_handoff_adam_rr_full_override_caveman.md
