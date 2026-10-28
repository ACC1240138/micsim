# -*- coding: utf-8 -*-
"""
make_figures_paper_outline.py

EN: Rebuilds the journal-style (BMC) figures of the paper outline for the
    FONDECYT 1240138 DIR microsimulation: Fig. 1 (study design), Fig. 2
    (model modules), Fig. 3 (annual process overview) and Fig. S1 (two routes
    for the mortality impact). Outputs SVG, PNG (about 450 dpi at 170 mm), PDF
    and an optional Word file with BMC-style titles and legends.
ES: Reconstruye las figuras en formato de revista (BMC) del outline del paper
    de la microsimulacion DIR (FONDECYT 1240138): Fig. 1 (diseno), Fig. 2
    (modulos), Fig. 3 (ciclo anual) y Fig. S1 (dos rutas para la mortalidad).
    Genera SVG, PNG (unos 450 dpi a 170 mm), PDF y un Word opcional con
    titulos y leyendas al estilo BMC.

HOW TO RUN / COMO CORRER
    python make_figures_paper_outline.py
    (from any folder; outputs go to ./output next to this script)
    (desde cualquier carpeta; las salidas quedan en ./output junto al script)

REQUIREMENTS / REQUISITOS
    - Python 3.8+ (standard library only for stages 0-6).
      Python 3.8+ (solo libreria estandar para las etapas 0-6).
    - Microsoft Edge or Google Chrome, used headless to turn SVG into PNG/PDF.
      Set FIG_BROWSER=<path to msedge.exe or chrome.exe> if it is not found.
      Edge o Chrome en modo headless para pasar de SVG a PNG/PDF.
      Defina FIG_BROWSER=<ruta> si no lo encuentra.
    - Optional, stage 7 only: python-docx (pip install python-docx).
      Opcional, solo etapa 7: python-docx.

ENCODING / CODIFICACION
    EN: This file is pure ASCII on purpose, so it opens the same way in any
        editor or Windows code page. Symbols in figure text are written as
        Python escapes and become the real character when the script runs:
            \\u2013 en dash (2012-2024)   \\u00d7 times (sex x age)
            \\u2265 greater or equal      \\u2192 arrow
            \\u2212 minus sign            \\u2032 prime (p')
            \\u03a3 capital sigma (sum)   \\u00b7 middle dot
        Accented Spanish letters in the Word note are escaped the same way.
        All output files are written as UTF-8.
    ES: Este archivo es solo ASCII a proposito, para que se abra igual en
        cualquier editor o pagina de codigos de Windows. Los simbolos del
        texto de las figuras van como escapes de Python (tabla de arriba) y se
        convierten en el caracter real al correr. Las salidas se escriben en
        UTF-8.

LINE STYLES / ESTILOS DE LINEA
    solid border  = estimated or calibrated with Chilean data
                    (estimado o calibrado con datos chilenos)
    dashed border = external parameter or modelling assumption
                    (parametro externo o supuesto de modelacion)

STAGES / ETAPAS
    0 settings and timer             / configuracion y cronometro
    1 SVG drawing helpers            / funciones de dibujo SVG
    2 Fig. 1 study design            / Fig. 1 diseno del estudio
    3 Fig. 2 model modules           / Fig. 2 modulos del modelo
    4 Fig. 3 annual process          / Fig. 3 ciclo anual
    5 Fig. S1 two mortality routes   / Fig. S1 dos rutas de mortalidad
    6 write SVG, render PNG and PDF  / escribir SVG, generar PNG y PDF
    7 Word file with legends         / Word con leyendas (opcional)
    8 self-checks                    / comprobaciones finales
"""

# =============================================================================
# STAGE 0. Settings and timer / Configuracion y cronometro
# =============================================================================
import html
import os
import pathlib
import shutil
import struct
import subprocess
import time

t_start = time.time()  # global timer / cronometro global
t0 = time.time()       # stage timer, reset at each stage / cronometro por etapa


def elapsed(stage):
    """EN: print minutes since t0 and reset it. ES: imprime minutos desde t0 y lo reinicia."""
    global t0
    print(f"[{stage}] Elapsed: {(time.time() - t0) / 60:.2f} min")
    t0 = time.time()


HERE = pathlib.Path(__file__).resolve().parent
OUT = HERE / "output"           # EN: all outputs go here / ES: todas las salidas van aqui
OUT.mkdir(exist_ok=True)

# EN: 1000 SVG units = 170 mm (BMC double column). Scale 3 gives 3000 px,
#     about 450 dpi at 170 mm (BMC asks for at least 300 dpi).
# ES: 1000 unidades SVG = 170 mm (doble columna BMC). Escala 3 da 3000 px,
#     unos 450 dpi a 170 mm (BMC pide al menos 300 dpi).
SCALE = 3

FONT = "Arial, 'Liberation Sans', Helvetica, sans-serif"
DASH = '6 4'  # EN: dash pattern for "external parameter or assumption" / ES: patron del borde punteado

elapsed("0 settings")

# =============================================================================
# STAGE 1. SVG drawing helpers / Funciones de dibujo SVG
#   EN: Each helper returns a piece of SVG markup as a string. Coordinates are
#       in SVG units (x to the right, y downwards). Figures are lists of these
#       pieces joined together.
#   ES: Cada funcion devuelve un trozo de SVG como texto. Coordenadas en
#       unidades SVG (x hacia la derecha, y hacia abajo). Cada figura es una
#       lista de estos trozos unidos.
#   - esc:        escape &, <, > in text / escapa &, <, > en el texto
#   - text:       one line of text / una linea de texto
#   - lines:      several lines, optional bold first line / varias lineas, primera en negrita opcional
#   - rect:       box; dashed=True for external parameters / caja; dashed=True para parametros externos
#   - arrow:      straight arrow / flecha recta
#   - path_arrow: arrow along an SVG path (loops) / flecha por un trazado (bucles)
#   - svg:        wraps the body with size, font and arrowhead / envuelve con tamano, fuente y punta de flecha
#   - key:        legend of line styles at the bottom / clave de estilos de linea abajo
#   - rowlab:     rotated row label (Aims, Inputs...) / rotulo de fila rotado
# =============================================================================
def esc(t): return html.escape(t, quote=False)

def text(x, y, s, size=16, weight='normal', anchor='start', style='normal', fill='#000'):
    return f'<text x="{x}" y="{y}" font-size="{size}" font-weight="{weight}" text-anchor="{anchor}" font-style="{style}" fill="{fill}">{esc(s)}</text>'

def lines(x, y, rows, size=16, lh=21, anchor='start', first_bold=False, style='normal', fill='#000'):
    out = []
    for i, r in enumerate(rows):
        out.append(text(x, y + i*lh, r, size, 'bold' if (first_bold and i == 0) else 'normal', anchor, style, fill))
    return ''.join(out)

def rect(x, y, w, h, dashed=False, fill='#fff', rx=3, stroke='#000', sw=1.4):
    d = f' stroke-dasharray="{DASH}"' if dashed else ''
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}/>'

def arrow(x1, y1, x2, y2, sw=1.4):
    return f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="#000" stroke-width="{sw}" marker-end="url(#ah)"/>'

def path_arrow(d):
    return f'<path d="{d}" fill="none" stroke="#000" stroke-width="1.4" marker-end="url(#ah)"/>'

def svg(w, h, body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}" font-family="{FONT}">'
            '<defs><marker id="ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">'
            '<path d="M0 0L10 5L0 10z" fill="#000"/></marker></defs>'
            f'<rect width="{w}" height="{h}" fill="#fff"/>{body}</svg>')

def key(x, y, size=15):
    return (f'<line x1="{x}" y1="{y-5}" x2="{x+34}" y2="{y-5}" stroke="#000" stroke-width="1.6"/>'
            + text(x+42, y, 'Estimated or calibrated with Chilean data', size)
            + f'<line x1="{x+390}" y1="{y-5}" x2="{x+424}" y2="{y-5}" stroke="#000" stroke-width="1.6" stroke-dasharray="{DASH}"/>'
            + text(x+432, y, 'External parameter or modelling assumption', size))

def rowlab(x, y, w, h, s):
    cx, cy = x + w/2, y + h/2
    return rect(x, y, w, h, fill='#fff') + f'<text x="{cx}" y="{cy}" font-size="16" font-weight="bold" text-anchor="middle" dominant-baseline="central" transform="rotate(-90 {cx} {cy})">{s}</text>'

elapsed("1 helpers")

# =============================================================================
# STAGE 2. Fig. 1 Study design / Diseno del estudio
#   EN: Adapted from Probst et al. 2023 (SIMAH, Fig. 1). Rows Aims, Inputs,
#       Analyses, Outputs; Objective 1 on the left (grey), Objective 2 on the
#       right. Inputs are a 2 x 2 grid per objective; dashed boxes are
#       external parameters. Edit the text lists (ins1, ins2 and the lines()
#       calls) to change content; keep lines short (about 26 characters in
#       input boxes, 48 in analysis boxes) so text stays inside the boxes.
#   ES: Adaptada de Probst et al. 2023 (SIMAH, Fig. 1). Filas Aims, Inputs,
#       Analyses, Outputs; objetivo 1 a la izquierda (gris), objetivo 2 a la
#       derecha. Los insumos van en una grilla 2 x 2 por objetivo; las cajas
#       punteadas son parametros externos. Para cambiar contenido, edite las
#       listas de texto (ins1, ins2 y las llamadas a lines()); mantenga lineas
#       cortas (unos 26 caracteres en insumos, 48 en analisis).
# =============================================================================
def fig1():
    b = []
    C1, C2, W = 56, 540, 460
    G1, G2 = '#f2f2f2', '#ffffff'
    # Aims
    b.append(rowlab(0, 10, 40, 62, 'Aims'))
    b.append(f'<polygon points="{C1},10 {C1+W+8},10 {C1+W+30},41 {C1+W+8},72 {C1},72" fill="#e0e0e0" stroke="#000" stroke-width="1.4"/>')
    b.append(lines(C1+W/2, 36, ['Objective 1', 'Dynamics of alcohol use'], 17, 22, 'middle', True))
    b.append(rect(C2+14, 10, W-14, 62, fill='#c8c8c8', rx=0))
    b.append(lines(C2+7+W/2, 36, ['Objective 2', 'Scale-up of the DIR programme'], 17, 22, 'middle', True))
    # Inputs: Objective 1 keeps ENPG, panels and INE (full width); APS enrolment sits with REM as its denominator
    bw, bh, y1, y2 = (W-12)/2, 116, 92, 220
    b.append(rowlab(0, y1, 40, y2+bh-y1, 'Inputs'))
    ins = [(C1, y1, bw, False, G1, ['ENPG 2012\u20132024', '7 waves, urban 12\u201365 y', 'post-stratified to CASEN', 'by sex, age, education']),
           (C1+bw+12, y1, bw, False, G1, ['EPS and TSM panels', 'EPS 2015\u20132023: 8,167 pairs', 'TSM 2023\u20132025: 4,160 pairs']),
           (C1, y2, W, False, G1, ['INE population stocks', '2012\u20132034, by sex and age', 'demographic reconciliation, not observed migration']),
           (C2, y1, bw, False, G2, ['DEIS death records', '2012\u20132024, ICD-10,', 'by sex and age', '(2024 provisional)']),
           (C2+bw+12, y1, bw, True, G2, ['Relative risks by cause', 'current, former drinker', 'and HED components']),
           (C2, y2, bw, False, G2, ['REM programme records', 'DIR screens and BIs', '2019\u20132024; calibration 2024', 'Denominator: \u22489.43 million\u2021', 'APS enrolees 15\u201364 (2023)']),
           (C2+bw+12, y2, bw, True, G2, ['Brief-intervention effect', 'meta-analysis: \u221220 g/week', '(Kaner et al. 2018)'])]
    for x, y, w, dsh, fill, rows in ins:
        b.append(rect(x, y, w, bh, dsh, fill))
        b.append(lines(x+10, y+24, rows, 15.5, 20, first_bold=True))
    ya, ha = y2+bh+32, 240
    for cx in (C1+W/2, C2+W/2): b.append(arrow(cx, y2+bh+2, cx, ya-2))
    # Analyses (marks: \u2020 planned, not yet implemented; \u2021 exploratory estimate)
    b.append(rowlab(0, ya, 40, ha, 'Analyses'))
    b.append(rect(C1, ya, W, ha, False, G1))
    b.append(lines(C1+14, ya+27, ['Multistate transition models',
        'States N0, FD, C1, C2, C3+ (WHO g/day, by sex)',
        'Strata: sex \u00d7 age \u00d7 education',
        'Annual probabilities (EPS\u2020, TSM\u2021) from ~4-year',
        'and 4\u20138-month intervals; IPW for loss to follow-up'], 16, 23, first_bold=True))
    b.append(rect(C1+14, ya+152, W-28, 72, True, '#fff'))
    b.append(lines(C1+26, ya+180, ['HED: latent persistence; scenarios\u2020', 'informed by TSM estimates\u2021'], 16, 22))
    b.append(rect(C2, ya, W, ha, False, G2))
    b.append(lines(C2+14, ya+27, ['Annual discrete-time microsimulation\u2020',
        'Entry 15\u201364; followed to 2034 (up to age 73)',
        'Scenarios S0\u2013S3, 2025\u20132034',
        'DIR cascade calibrated to REM 2024 by sex and age:',
        'screening \u2192 AUDIT positive \u2192 brief intervention',
        'Attributable deaths avoided = D_ref \u00d7 PIF'], 16, 23, first_bold=True))
    b.append(rect(C2+14, ya+152, W-28, 72, True, '#fff'))
    b.append(lines(C2+26, ya+180, ['New BIs only: \u22128% g/day, full for 1 year,', 'fading to zero by year 3\u20134'], 16, 22))
    b.append(arrow(C1+W, ya+120, C2-2, ya+120))
    yo, ho = ya+ha+32, 140
    for cx in (C1+W/2, C2+W/2): b.append(arrow(cx, ya+ha, cx, yo-2))
    # Outputs: every item carries its status mark
    b.append(rowlab(0, yo, 40, ho, 'Outputs'))
    b.append(rect(C1, yo, W, ho, False, G1))
    b.append(lines(C1+14, yo+28, ['Annual transition probabilities by sex, age and', 'education, with uncertainty\u2020',
                                  'Persistence of volume and HED\u2021', 'Comparison with ENPG 2026 or ENCAVI 2023\u201324\u2020'], 16, 23))
    b.append(rect(C2, yo, W, ho, False, G2))
    b.append(lines(C2+14, yo+28, ['Attributable deaths and years of life lost (YLL)', 'avoided per scenario, by sex and age\u2020',
                                  'YLL avoided per 1,000 brief interventions\u2020',
                                  'Sensitivity: effect size, scaling rule,', 'HED persistence, RR source\u2020'], 16, 23))
    yk = yo+ho+30
    b.append(key(56, yk))
    b.append(text(73, yk+26, '\u2020', 16, anchor='middle') + text(98, yk+26, 'Planned, not yet implemented', 15)
             + text(463, yk+26, '\u2021', 16, anchor='middle') + text(488, yk+26, 'Exploratory or provisional estimate', 15))
    return svg(1000, yk+40, ''.join(b))

elapsed("2 fig1")

# =============================================================================
# STAGE 3. Fig. 2 Model modules / Modulos del modelo
#   EN: Adapted from Card-Gowers et al. 2025. Narrow layout (780 units wide)
#       on purpose: data inputs (left), simulation cycle (thin centre column),
#       outputs (right). Each input line has a short vertical marker: solid =
#       Chilean data, dashed = external parameter or assumption.
#   ES: Adaptada de Card-Gowers et al. 2025. Diseno angosto (780 unidades) a
#       proposito: insumos (izquierda), ciclo (columna central delgada),
#       salidas (derecha). Cada linea de insumo lleva una marca vertical:
#       solida = datos chilenos, punteada = parametro externo o supuesto.
# =============================================================================
def fig2():
    b = []
    L, LW, M, MW, R, RW, T, H = 0, 340, 372, 140, 544, 236, 0, 560
    b.append(rect(L, T, LW, H, fill='#fff', rx=0))
    b.append(text(L+LW/2, 30, 'Data inputs', 17, 'bold', 'middle'))
    mods = [('1 Population', [(False, 'ENPG \u00d7 CASEN, 15\u201364 y'), (False, 'INE stocks (reconciliation)')]),
            ('2 Alcohol exposure', [(False, 'Transitions from EPS and TSM'), (True, 'HED persistence, TSM-informed')]),
            ('3 Mortality', [(False, 'DEIS reference deaths'), (True, 'Relative risks by cause')]),
            ('4 DIR programme', [(False, 'REM 2024 cascade, by sex and age'), (True, 'BI effect and its duration')])]
    y = 62
    for title, items in mods:
        b.append(text(18, y, title, 16, 'bold'))
        for k, (dsh, s) in enumerate(items):
            yy = y + 24 + k*23
            d = f' stroke-dasharray="4 3"' if dsh else ''
            b.append(f'<line x1="22" y1="{yy-14}" x2="22" y2="{yy+4}" stroke="#000" stroke-width="2"{d}/>')
            b.append(text(32, yy, s, 15.5))
        y += 98
    b.append(text(18, y, '5 Scenarios', 16, 'bold'))
    b.append(lines(32, y+24, ['S0 status quo (2024) \u00b7 S1 screening \u00d71.5', 'S2 brief intervention 80% \u00b7 S3 S1 + S2'], 15.5, 23))
    # middle
    b.append(rect(M, T, MW, H, fill='#e6e6e6', rx=0))
    cx = M + MW/2
    b.append(text(cx, 30, 'Simulation', 17, 'bold', 'middle'))
    b.append(lines(cx, 200, ['Annual cycle', '2025\u20132034'], 15.5, 21, 'middle'))
    b.append(f'<circle cx="{cx}" cy="290" r="44" fill="#fff" stroke="none"/>')
    b.append(f'<path d="M{cx-48} 286 A48 48 0 0 1 {cx+46} 280" fill="none" stroke="#000" stroke-width="1.4" marker-end="url(#ah)"/>')
    b.append(f'<path d="M{cx+48} 294 A48 48 0 0 1 {cx-46} 300" fill="none" stroke="#000" stroke-width="1.4" marker-end="url(#ah)"/>')
    b.append(lines(cx, 286, ['Virtual', 'population'], 14.5, 18, 'middle'))
    b.append(lines(cx, 372, ['ageing', 'drinking', 'DIR', 'mortality'], 15.5, 21, 'middle'))
    # right
    b.append(rect(R, T, RW, H, fill='#fff', rx=0))
    b.append(text(R+RW/2, 30, 'Model outputs', 17, 'bold', 'middle'))
    outs = [('Exposure', ['Prevalence by state and', 'HED; vs ENPG 2026', 'or ENCAVI 2023\u201324']),
            ('Mortality', ['Attributable deaths', 'avoided, by cause']),
            ('Years of life lost', ['YLL avoided (life table)']),
            ('Programme volume', ['Screens and BIs; YLL', 'avoided per 1,000 BIs'])]
    y = 62
    for t, rows in outs:
        b.append(f'<line x1="{R+16}" y1="{y-14}" x2="{R+16}" y2="{y+20*len(rows)+2}" stroke="#000" stroke-width="2"/>')
        b.append(lines(R+26, y, [t] + rows, 15.5, 22, first_bold=True))
        y += 112
    b.append(arrow(LW+2, 290, M-4, 290)); b.append(arrow(M+MW+2, 290, R-4, 290))
    b.append(f'<line x1="0" y1="{H+30}" x2="30" y2="{H+30}" stroke="#000" stroke-width="2"/>' + text(38, H+35, 'Chilean data', 15))
    b.append(f'<line x1="180" y1="{H+30}" x2="210" y2="{H+30}" stroke="#000" stroke-width="2" stroke-dasharray="4 3"/>' + text(218, H+35, 'External parameter or assumption', 15))
    return svg(780, H+48, ''.join(b))

elapsed("3 fig2")

# =============================================================================
# STAGE 4. Fig. 3 Annual process overview / Ciclo anual del motor
#   EN: Adapted from Kilian et al. 2025, Figure S1, but following the real
#       order of the Chilean engine: record (1), all-cause death (2),
#       attributable deaths by PIF (3, route A), ageing (4), demographic
#       reconciliation to INE stocks (5) and next-year exposure (6a-6f).
#       Step 5 is a demographic adjustment, not observed migration.
#   ES: Adaptada de Kilian et al. 2025, Figura S1, pero con el orden real del
#       motor chileno: registro (1), muerte por todas las causas (2), muertes
#       atribuibles por PIF (3, ruta A), envejecimiento (4), reconciliacion
#       demografica con stocks INE (5) y exposicion para el ciclo siguiente (6a-6f).
#       El paso 5 es un ajuste demografico, no migracion observada.
# =============================================================================
def fig3():
    b = []
    X, W = 320, 290; cx = X + W/2
    RX, RW = 670, 250
    def step(y, rows, dsh=False, fill='#fff', h=60):
        return rect(X, y, W, h, dsh, fill) + lines(cx, y+25, rows, 16.5, 22, 'middle', True)
    b.append(rect(X, 18, W, 62, False, '#e0e0e0', rx=10) + lines(cx, 43, ['Synthetic population', 'ENPG \u00d7 CASEN, 15\u201364 y'], 16.5, 22, 'middle', True))
    b.append(arrow(cx, 80, cx, 100))
    b.append(step(102, ['1. Record population', 'and alcohol exposure']))
    b.append(arrow(X+W, 132, RX-4, 132))
    b.append(f'<path d="M{RX} 104 H{RX+RW-16} L{RX+RW} 120 V160 H{RX} Z" fill="#f2f2f2" stroke="#000" stroke-width="1.4"/>')
    b.append(lines(RX+12, 128, ['Prevalence by state and HED;', 'BIs delivered'], 16, 21, style='italic'))
    b.append(arrow(cx, 162, cx, 182))
    b.append(step(184, ['2. All-cause mortality', 'reference rates, all scenarios']))
    b.append(text(X+W+12, 206, 'Died', 15.5))
    b.append(arrow(X+W, 214, RX-4, 214))
    b.append(f'<path d="M{RX} 180 H{RX+RW-16} L{RX+RW} 196 V250 H{RX} Z" fill="#f2f2f2" stroke="#000" stroke-width="1.4" stroke-dasharray="{DASH}"/>')
    b.append(lines(RX+12, 206, ['3. Attributable deaths and', 'YLL avoided: D_ref \u00d7 PIF\u2020'], 16, 22, style='italic'))
    b.append(arrow(RX+RW, 214, 958, 214)); b.append(text(962, 219, 'Exit', 15.5))
    b.append(text(cx+8, 264, 'Alive', 15.5)); b.append(arrow(cx, 244, cx, 280))
    b.append(step(282, ['4. Age +1 year', 'exposure held from 65 y\u2020'], True))
    b.append(text(X+W+12, 317, 'Oldest reach age 73 by 2034', 15.5, style='italic'))  # initial population 15-64, no entry after 64
    b.append(arrow(cx, 342, cx, 362))
    b.append(step(364, ['5. Reconciliation to INE', 'stocks, ages 15\u201364 y']))
    b.append(rect(40, 364, 190, 60, False, '#fff') + lines(135, 389, ['INE stocks', 'sex \u00d7 age \u00d7 year'], 16, 22, 'middle'))
    b.append(text(274, 386, 'Entrants', 14.5, anchor='middle')); b.append(arrow(230, 394, X-4, 394))
    b.append(arrow(cx, 424, cx, 452))
    # step 6 container
    b.append(rect(24, 454, 952, 190, False, '#f7f7f7', rx=8, stroke='#555', sw=1.2))
    b.append(text(40, 480, '6. Next-year exposure, ages 15\u201364 y', 16.5, 'bold'))
    boxes = [('6a Transitions\u2020', 'EPS and TSM', False), ('6b Grams/day', 'within state', False),
             ('6c DIR cascade\u2020', 'REM-calibrated', False), ('6d BI effect\u2020', 'new BIs only', True),
             ('6e HED\u2020', 'volume + latent', True), ('6f Recode', 'N0 to C3+', False)]
    bw, gap, x0, y0 = 138, 18, 40, 500
    for i, (t, s, dsh) in enumerate(boxes):
        x = x0 + i*(bw+gap)
        b.append(rect(x, y0, bw, 70, dsh, '#fff'))
        b.append(lines(x+bw/2, y0+29, [t, s], 15.5, 22, 'middle', True))
        if i < 5: b.append(arrow(x+bw, y0+35, x+bw+gap-2, y0+35))
    b.append(text(40, 618, 'Scenarios S1\u2013S3 differ from S0 only in steps 6c\u20136d; S0 is calibrated to ENPG margins.', 15, style='italic', fill='#333'))
    # loop
    b.append(path_arrow(f'M500 644 V676 H8 V49 H{X-4}'))
    b.append(text(254, 668, 'Next year', 15.5))
    b.append(key(40, 714))
    b.append(text(57, 740, '\u2020', 16, anchor='middle') + text(82, 740, 'Planned, not yet implemented in the engine', 15))
    return svg(1000, 756, ''.join(b))

elapsed("4 fig3")

# =============================================================================
# STAGE 5. Fig. S1 Two routes for the mortality impact / Dos rutas de mortalidad
#   EN: Route A (used): expected deaths avoided = reference deaths x PIF.
#       Route B (alternative, not used): individual hazard by scenario. Grey
#       text marks the route that is not used. They are not added together.
#   ES: Ruta A (usada): muertes esperadas evitadas = muertes de referencia x
#       PIF. Ruta B (alternativa, no usada): hazard individual por escenario,
#       en gris. No se suman.
# =============================================================================
def figS1():
    b = []
    cols = [(30, 'A. Aggregate impact (used)', '#000', ['Exposure trajectories', 'S0 vs DIR scenario'],
             ['Relative risks by cause', '\u2192 PIF by sex, age, cause, year'], ['Expected deaths avoided', 'D_ref \u00d7 PIF; YLL by age'],
             ['No additional survivors inside the model.', 'Example: 100 reference deaths \u00d7 PIF 0.10', '= 10 expected deaths avoided.']),
            (520, 'B. Individual survival (alternative, not used)', '#666', ['Exposure trajectories', 'S0 vs DIR scenario'],
             ['Individual hazard by cause', 'baseline rate \u00d7 RR(exposure)'], ['Death or survival by scenario', 'competing risks; new alive set'],
             ['Same individuals and random numbers;', 'deaths may differ. Example: U = 0.03,', 'p(S0) = 0.04, p(DIR) = 0.02.'])]
    for x, title, col, a, r, o, note in cols:
        w = 450; c = x + w/2
        b.append(text(x, 30, title, 17, 'bold', fill=col))
        for i, rows in enumerate((a, r, o)):
            y = 50 + i*110
            b.append(rect(x, y, w, 70, False, '#fff', stroke=col))
            b.append(lines(c, y+29, rows, 16, 22, 'middle', True, fill=col))
            if i < 2: b.append(arrow(c, y+70, c, y+108))
        b.append(lines(x, 400, note, 15.5, 22, fill=col))
    return svg(1000, 470, ''.join(b))

elapsed("5 figS1")

# =============================================================================
# STAGE 6. Write SVG, render PNG and PDF / Escribir SVG, generar PNG y PDF
#   EN: SVG is the editable master. PNG and PDF are produced by a headless
#       Edge or Chrome from a small HTML wrapper whose @page size equals the
#       figure size, so the PDF has no margins.
#   ES: El SVG es el original editable. PNG y PDF salen de Edge o Chrome en
#       modo headless, desde un HTML minimo cuyo @page mide lo mismo que la
#       figura, para que el PDF no tenga margenes.
# =============================================================================
FIGURES = [  # (file stem, builder) / (nombre de archivo, funcion)
    ("Fig1_study_design", fig1),
    ("Fig2_model_modules", fig2),
    ("Fig3_process_overview", fig3),
    ("FigS1_mortality_routes", figS1),
]


def find_browser():
    """EN: FIG_BROWSER first, then usual Windows paths, then PATH.
    ES: primero FIG_BROWSER, luego rutas habituales de Windows, luego el PATH."""
    candidates = [os.environ.get("FIG_BROWSER", ""),
                  r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
                  r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
                  r"C:\Program Files\Google\Chrome\Application\chrome.exe",
                  r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"]
    candidates += [shutil.which(n) or "" for n in ("msedge", "chrome", "google-chrome", "chromium")]
    for c in candidates:
        if c and pathlib.Path(c).exists():
            return c
    raise SystemExit("EN: Edge/Chrome not found; set FIG_BROWSER. ES: no encontre Edge/Chrome; defina FIG_BROWSER.")


BROWSER = find_browser()
print("Browser / Navegador:", BROWSER)
# EN: Linux containers running as root need --no-sandbox; Windows does not.
# ES: en Linux como root hace falta --no-sandbox; en Windows no.
BASE_FLAGS = ["--headless=new", "--disable-gpu", "--hide-scrollbars"] + (["--no-sandbox"] if os.name != "nt" else [])

sizes = {}
for stem, build in FIGURES:
    svg_text = build()
    w, h = map(int, svg_text.split('viewBox="0 0 ')[1].split('"')[0].split())
    sizes[stem] = (w, h)
    (OUT / f"{stem}.svg").write_text(svg_text, encoding="utf-8")
    wrapper = OUT / f"{stem}_wrapper.html"
    wrapper.write_text('<!doctype html><meta charset="utf-8"><style>'
                       f'@page{{size:{w}px {h}px;margin:0}}html,body{{margin:0;padding:0}}svg{{display:block}}'
                       f'</style>{svg_text}', encoding="utf-8")
    url = wrapper.as_uri()
    subprocess.run([BROWSER, *BASE_FLAGS, f"--window-size={w},{h}", f"--force-device-scale-factor={SCALE}",
                    f"--screenshot={OUT / (stem + '.png')}", url], check=True, capture_output=True, timeout=120)
    subprocess.run([BROWSER, *BASE_FLAGS, "--no-pdf-header-footer",
                    f"--print-to-pdf={OUT / (stem + '.pdf')}", url], check=True, capture_output=True, timeout=120)
    wrapper.unlink()  # EN: temporary file / ES: archivo temporal
    print("  ok", stem)

elapsed("6 render")

# =============================================================================
# STAGE 7. Word file with BMC titles and legends / Word con titulos y leyendas BMC
#   EN: BMC: title up to 15 words, legend up to 300 words, placed after the
#       references; each figure is also uploaded as a separate file. The
#       Spanish draft note at the top must be removed before submission.
#       Skipped (with a message) if python-docx is not installed.
#   ES: BMC: titulo de hasta 15 palabras y leyenda de hasta 300, despues de
#       las referencias; cada figura se sube ademas como archivo aparte. La
#       nota de borrador en espanol se borra antes de enviar. Se omite (con
#       aviso) si python-docx no esta instalado.
# =============================================================================
ABB1 = ('Abbreviations: APS, primary health care; AUDIT, Alcohol Use Disorders Identification Test; BI, brief intervention; CASEN, National Socioeconomic Characterisation Survey; '
        'DEIS, Department of Health Statistics and Information; DIR, Detection, brief Intervention and assisted Referral programme; '
        'D_ref, reference deaths; ENCAVI, National Survey of Quality of Life and Health; ENPG, National Drug Survey in the General Population; '
        'EPS, Social Protection Survey; FONASA, National Health Fund; '
        'HED, heavy episodic drinking; INE, National Statistics Institute; IPW, inverse probability weighting; PIF, potential impact fraction; '
        'REM, Monthly Statistical Records; TSM, Mental Health Thermometer (ACHS-UC); WHO, World Health Organization.')
figs = [
 ('Fig1_study_design.png', 17, 'Fig. 1', 'Study design: objectives, data sources, analyses and outputs',
  'Objective 1 estimates alcohol use transitions from two Chilean panels, with ENPG providing population margins; Objective 2 feeds them into a microsimulation '
  'of the alcohol-attributable deaths and years of life lost (YLL) avoided by expanding the DIR programme in 2025\u20132034. '
  'States: C1, C2 and C3+, WHO risk levels (women >0\u201320, >20\u201340 and >40 g of ethanol per day; men >0\u201340, >40\u201360 and >60 g/day; upper bounds inclusive; '
  '12 g per drink); FD, former drinker; N0, no current or earlier drinking observed. N0 and FD definitions differ between ENPG and panels; panel counts are interview pairs. '
  'Post-stratification corrects composition but does not identify rural drinking patterns. '
  'HED: TSM supports an annual correlation of 0.24\u20130.36; decay is weakly identified and 5\u201310-year persistence is assumed; comparison: Puka et al. 2023; '
  'the engine currently uses a common \u03c1 = 0.8 (to be replaced for HED). '
  'APS denominator: enrolees in FONASA groups A\u2013D, December 2023, apportioned to ages 15\u201364; equivalence with validated enrolment is unconfirmed, so coverage rates are approximate. '
  'Screening is any AUDIT; at ages 15\u201319 most screening uses CRAFFT (AUDIT 1.0% vs 18.5% with any instrument). '
  'Reference deaths are total cause-specific deaths, excluding wholly attributable causes; YLL use the Human Mortality Database life table for Chile. ' + ABB1),
 ('Fig2_model_modules.png', 14, 'Fig. 2', 'Model modules, annual simulation cycle and outputs',
  'Five input modules (left) feed an annual cycle applied to a synthetic population (centre), which produces exposure, mortality and programme outputs (right). '
  'Line markers: solid, Chilean data; dashed, external parameter or assumption. Population: ENPG respondents aged 15\u201364 years post-stratified with CASEN; nobody enters after age 64, so the oldest reach age 73 by 2034; INE stocks are used '
  'for demographic reconciliation, not to observe individual migration. Exposure: annual transition probabilities estimated from EPS and TSM; heavy episodic drinking assigned '
  'from volume plus a latent persistence term informed by TSM (the engine currently uses a common \u03c1 = 0.8). Mortality: reference deaths from DEIS and cause-specific relative risks for current drinking, former drinking and heavy episodic '
  'drinking. DIR programme: probabilities of screening, of a positive result and of brief intervention calibrated to REM 2024 by sex and age; coverage is approximate until the APS denominator is confirmed; the effect applies only to brief '
  'interventions additional to the status quo. Scenarios: S0, programme coverage held at 2024 levels; S1, screening coverage multiplied by 1.5 with an unchanged probability '
  'of brief intervention after a positive result; S2, brief intervention after 80% of AUDIT scores of 8\u201315; S3, S1 and S2 combined. Exposure is compared with ENPG 2026 or, alternatively, ENCAVI 2023\u201324. Implementation status is marked in Figs. 1 and 3. YLL computed from the Human Mortality Database life table for Chile; '
  'years of potential life lost (YPLL) before age 75 reported only for comparison with Lemp et al. AUDIT, Alcohol Use Disorders Identification Test; other abbreviations as in Fig. 1.'),
 ('Fig3_process_overview.png', 17, 'Fig. 3', 'Annual process overview of the microsimulation',
  'Each simulated year starts with the recording of population and exposure in January (step 1). All-cause deaths are drawn from reference rates that are identical across '
  'scenarios (step 2). Alcohol-attributable deaths and YLL avoided are computed as expected values by multiplying reference deaths by the potential impact fraction for each '
  'cause, sex, age group and year (step 3): PIF = 1 \u2212 \u03a3p\u2032RR / \u03a3pRR, where p and p\u2032 are the simulated exposure distributions under S0 and under the scenario; reference deaths are all DEIS deaths from each cause, 2012\u20132024, and fully attributable causes are excluded. Survivors age '
  'one year; baseline exposure is held constant from age 65, while the effect of an earlier brief intervention keeps fading; nobody enters the model after age 64, so the oldest members reach age 73 by 2034 (step 4). The population aged 15\u201364 is reconciled to INE stocks by sex and age; '
  'entrants, mainly people turning 15, receive exposure drawn from the ENPG distribution of their cell (step 5). Exposure for the next year is then updated for people aged '
  '15\u201364: annual transitions between states (6a); grams of ethanol per day drawn within the assigned state (6b); the DIR cascade calibrated to REM records (6c); the effect of '
  'new brief interventions, an 8% reduction in grams per day, full during the first year and fading to zero by year 3\u20134 (6d); heavy episodic drinking from volume and a '
  'latent persistence term to be informed by TSM (6e); and recoding of states (6f). The model is initialised in 2012; scenarios diverge from 2025 and run to 2034. Solid borders, Chilean data; '
  'dashed borders, external parameters or modelling assumptions; \u2020, not yet implemented in the engine. Adapted from Kilian et al. [ref]. Abbreviations as in Fig. 1.'),
 ('FigS1_mortality_routes.png', 16, 'Additional file 1: Fig. S1', 'Two routes to estimate the mortality impact of the scenarios',
  'Route A (used): the model projects exposure under each scenario; relative risks by cause convert the exposure distributions into potential impact fractions, and expected '
  'deaths avoided are reference deaths multiplied by the PIF. No additional survivors are simulated. Route B (not used): individual cause-specific hazards depend on exposure, '
  'so deaths differ between scenarios while individuals and random numbers are shared; it would require an alcohol-free baseline rate, no reconciliation to population stocks '
  'in the intervention arms and more Monte Carlo replicates. The routes are alternatives and are not added together. RR, relative risk; U, uniform random number; other '
  'abbreviations as in Fig. 1.'),
]

try:
    from docx import Document
    from docx.shared import Cm, Pt, RGBColor
    from docx.enum.text import WD_ALIGN_PARAGRAPH
except ImportError:
    Document = None
    print("EN: python-docx not installed, Word file skipped (pip install python-docx).")
    print("ES: python-docx no esta instalado, se omite el Word.")

if Document is not None:
    d = Document()
    st = d.styles['Normal']; st.font.name = 'Arial'; st.font.size = Pt(10.5)
    for s in d.sections:
        s.left_margin = s.right_margin = Cm(2); s.top_margin = s.bottom_margin = Cm(2)
    h = d.add_paragraph(); r = h.add_run('Figures for the DIR microsimulation manuscript (BMC format)'); r.bold = True; r.font.size = Pt(15)
    note = d.add_paragraph()
    r = note.add_run('Nota de borrador (27-oct-2026, retirar antes de enviar). '); r.bold = True
    note.add_run('Formato BMC: cada figura se sube como archivo aparte (PNG 450 dpi a 170 mm; SVG y PDF vectoriales en __andres_control/figures_paper_outline/output/). '
                 'T\u00edtulo de figura \u2264 15 palabras y leyenda \u2264 300 palabras, ubicados en el manuscrito despu\u00e9s de las referencias; abreviaturas definidas en cada leyenda. '
                 'Las citas dentro de las figuras van como autor-a\u00f1o y deben pasar a numeraci\u00f3n [n]. '
                 'Componentes que a\u00fan no est\u00e1n implementados en el motor: paso 3 (conexi\u00f3n PIF), 6a (matrices EPS/TSM), 6c\u20136d (m\u00f3dulo DIR), persistencia HED propia y seguimiento de la mortalidad despu\u00e9s de los 64 a\u00f1os '
                 '(poblaci\u00f3n inicial 15\u201364, edad m\u00e1xima 73 en 2034; muertes DEIS y RR de 65\u201373 por preparar; Calvo/EPS como posible sensibilidad del consumo despu\u00e9s de los 65). '
                 'Denominador APS provisional (\u22489,43 M, tramos A\u2013D repartidos por edad; se espera la v8 de Codex): las coberturas son aproximadas. '
                 'Comparaci\u00f3n de exposici\u00f3n con ENPG 2026 a\u00fan no implementada (se implementar\u00e1); alternativa: ENCAVI 2023\u201324.')
    for run in note.runs: run.font.color.rgb = RGBColor(0x66, 0x33, 0x00)
    for img, w, lab, title, legend in figs:
        d.add_page_break()
        p = d.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.add_run().add_picture(str(OUT / img), width=Cm(w))
        p = d.add_paragraph(); r = p.add_run(f'{lab} '); r.bold = True; r = p.add_run(title); r.bold = True
        d.add_paragraph(legend)
    d.save(str(OUT / 'DIR_microsim_figures_BMC.docx'))
    print("  ok DIR_microsim_figures_BMC.docx")

elapsed("7 word")

# =============================================================================
# STAGE 8. Self-checks / Comprobaciones finales
#   EN: fails loudly if something is off. ES: falla con mensaje si algo no cuadra.
# =============================================================================
# 8a. This file stays ASCII / este archivo sigue siendo ASCII
assert pathlib.Path(__file__).read_bytes().isascii(), "script has non-ASCII characters / el script tiene caracteres no ASCII"

# 8b. Every output exists and the PNG width is SCALE x SVG width
#     Cada salida existe y el ancho del PNG es SCALE x ancho del SVG
for stem, (w, h) in sizes.items():
    for ext in ("svg", "png", "pdf"):
        assert (OUT / f"{stem}.{ext}").stat().st_size > 0, f"missing / falta {stem}.{ext}"
    png_w, png_h = struct.unpack(">II", (OUT / f"{stem}.png").read_bytes()[16:24])  # PNG IHDR width, height
    assert (png_w, png_h) == (w * SCALE, h * SCALE), f"{stem}: PNG {png_w}x{png_h}, expected {w * SCALE}x{h * SCALE}"

# 8c. BMC limits: title <= 15 words, legend <= 300 words / limites BMC
for img, w, lab, title, legend in figs:
    assert len(title.split()) <= 15, f"{lab}: title too long / titulo largo"
    assert len(legend.split()) <= 300, f"{lab}: legend has {len(legend.split())} words / leyenda larga"

print("All checks passed / Todas las comprobaciones pasaron")
print(f"Total: {(time.time() - t_start) / 60:.2f} min. Outputs / Salidas: {OUT}")
