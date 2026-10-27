"""Build a standalone coverage explainer from published aggregate inputs."""
from pathlib import Path
import csv
import hashlib
import html
import json
import time

t0 = time.perf_counter()
root = Path(__file__).resolve().parent
while not (root / ".acc_root").exists():
    if root == root.parent:
        raise RuntimeError("Project root marker not found")
    root = root.parent
out = root / "__andres_control"
ine_path, = out.glob("*EEPP comuna area*.csv")
with ine_path.open(encoding="utf-8-sig", newline="") as f:
    ine = list(csv.DictReader(f, delimiter=";"))
with (out / "enpg_geographic_coverage_2012_2024.csv").open() as f:
    national = [{k: (v if k == "age" else float(v) if "pct" in k else int(v))
                 for k, v in row.items()} for row in csv.DictReader(f)]
with (out / "enpg_geographic_coverage_2012_2024_communes.csv").open() as f:
    lists = list(csv.DictReader(f))
years = [r["year"] for r in national]
region_order = [15, 1, 2, 3, 4, 5, 13, 6, 7, 16, 8, 9, 14, 10, 11, 12]
names = dict(zip(region_order, ["Arica y Parinacota", "Tarapacá", "Antofagasta", "Atacama",
    "Coquimbo", "Valparaíso", "Metropolitana", "O’Higgins", "Maule", "Ñuble", "Biobío",
    "La Araucanía", "Los Ríos", "Los Lagos", "Aysén", "Magallanes"]))
age_groups = {f"De {i} a {i + 4} años" for i in range(15, 65, 5)}
rows = [r for r in ine if r["Grupo edad"] in age_groups]
keys = [(r["Comuna"], r["Sexo (1=Hombre 2=Mujer)"], r["Area (1=Urbano 2=Rural)"], r["Grupo edad"]) for r in rows]
assert len(keys) == len(set(keys)) == 346 * 2 * 2 * 10
regional = []
for year in years:
    ids = {int(r["comuna"]) for r in lists if int(r["year"]) == year}
    for region in region_order:
        counts = dict(population_total=0, population_covered=0, component_A=0, component_B=0)
        for r in rows:
            if int(r["Region"]) != region:
                continue
            n = int(r[f"Poblacion {year}"])
            assert n >= 0
            inside = int(r["Comuna"]) in ids
            category = "component_A" if not inside else "component_B" if r["Area (1=Urbano 2=Rural)"] == "2" else "population_covered"
            counts["population_total"] += n
            counts[category] += n
        total = counts["population_total"]
        assert total == sum(counts[k] for k in ("component_A", "component_B", "population_covered"))
        pct = 100 * (counts["component_A"] + counts["component_B"]) / total
        assert abs(pct - 100 * (1 - counts["population_covered"] / total)) < 1e-12
        regional.append(dict(year=year, age="15-64", region=region, name=names[region], **counts, excluded_pct=pct))
    ref = next(r for r in national if r["year"] == year)
    for k in counts:
        assert sum(r[k] for r in regional if r["year"] == year) == ref[k], (year, k)
with (out / "enpg_geographic_coverage_regions_2012_2024.csv").open("w", encoding="utf-8-sig", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(regional[0]))
    writer.writeheader()
    writer.writerows(regional)

def number(v):
    return f"{v:,.0f}".replace(",", ".")

def percent(v, digits=1):
    return f"{v:.{digits}f}".replace(".", ",") + "%"

# A zero-based axis avoids exaggerating the small change in the national share.
svg = ['<svg id="trend-svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 980 400" role="img" aria-labelledby="trend-title trend-desc">',
       '<title id="trend-title">Población fuera de cobertura geográfica, Chile, 15–64 años</title>',
       '<desc id="trend-desc">Barras apiladas con A, población de comunas no observadas, y B, rural de comunas observadas. La suma baja de 23,14% en 2012 a 21,95% en 2024.</desc>',
       '<rect width="980" height="400" fill="white"/>',
       '<g font-family="Arial, sans-serif" font-size="16" fill="#192f43">',
       '<text x="55" y="25">% de la población nacional de 15–64 años</text>']
for tick in range(0, 31, 5):
    y = 335 - tick * 9
    svg += [f'<line x1="58" x2="960" y1="{y}" y2="{y}" stroke="#dce3e8"/>',
            f'<text x="47" y="{y+5}" text-anchor="end">{tick}</text>']
for i, r in enumerate(national):
    x = 90 + i * 125
    a = 100 * r["component_A"] / r["population_total"]
    b = 100 * r["component_B"] / r["population_total"]
    svg += [f'<rect x="{x}" y="{335-9*a}" width="75" height="{9*a}" fill="#a65908"/>',
            f'<rect x="{x}" y="{335-9*(a+b)}" width="75" height="{9*b}" fill="#087b80"/>',
            f'<text x="{x+37.5}" y="{335-9*(a+b)-12}" text-anchor="middle" font-weight="bold">{percent(a+b,2)}</text>',
            f'<text x="{x+37.5}" y="{335-9*a/2+5}" text-anchor="middle" fill="white">{percent(a)}</text>',
            f'<text x="{x+37.5}" y="{335-9*a-9*b/2+5}" text-anchor="middle" fill="white">{percent(b)}</text>',
            f'<text x="{x+37.5}" y="365" text-anchor="middle">{r["year"]}</text>']
svg.append('</g></svg>')
svg = "".join(svg)

heat = '<table class="heat"><caption>Porcentaje excluido dentro de cada región · edades 15–64</caption><thead><tr><th scope="col">Región · norte → sur</th>'
heat += ''.join(f'<th scope="col">{y}</th>' for y in years) + '</tr></thead><tbody>'
for region in region_order:
    heat += f'<tr><th scope="row">{html.escape(names[region])}</th>'
    for year in years:
        r = next(r for r in regional if r["region"] == region and r["year"] == year)
        v = r["excluded_pct"]
        # A fixed 0-100 scale is identical across all years and regions.
        rgb = tuple(round(a + (b-a)*v/100) for a, b in zip((245, 247, 250), (74, 39, 117)))
        color = "white" if v >= 55 else "#172b3d"
        label = f'{names[region]}, {year}: {percent(v)} excluido. Ver desglose.'
        heat += f'<td style="background:rgb{rgb};color:{color}"><button data-region="{region}" data-year="{year}" aria-label="{html.escape(label)}">{percent(v)}</button></td>'
    heat += '</tr>'
heat += '</tbody></table>'
table = '<table><caption>Resultados nacionales · población de 15–64 años</caption><thead><tr><th>Año</th><th>Total</th><th>Urbana cubierta</th><th>A</th><th>B</th><th>A + B (%)</th></tr></thead><tbody>'
for r in national:
    table += '<tr><th scope="row">'+str(r['year'])+'</th>'+''.join('<td>'+number(r[k])+'</td>' for k in ['population_total','population_covered','component_A','component_B'])+'<td>'+percent(r['excluded_pct'],2)+'</td></tr>'
table += '</tbody></table>'
for r in national:
    r.update(region=0, name="Chile")
data = json.dumps(national + regional, ensure_ascii=False).replace('</', r'<\/')
sources = ['enpg_geographic_coverage_2012_2024.csv', 'enpg_geographic_coverage_2012_2024_communes.csv', ine_path.name]
hashes = '<ul>'+''.join('<li><code>'+html.escape(s)+'</code><br>SHA256: <code>'+hashlib.sha256((out/s).read_bytes()).hexdigest()+'</code></li>' for s in sources)+'</ul>'

page = r'''<!doctype html>
<html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>ENPG · Cobertura geográfica 2012–2024 · 15–64 años</title>
<style>
:root{color-scheme:light;--ink:#192f43;--muted:#4c6070;--a:#a65908;--b:#087b80;--c:#dce6ee}
*{box-sizing:border-box}body{margin:0;background:#f3f6f8;color:var(--ink);font:17px/1.55 system-ui,Arial,sans-serif}
main{max-width:1160px;margin:auto;padding:35px 28px 60px}h1{font-size:clamp(28px,4vw,43px);line-height:1.15;max-width:850px;margin:12px 0 18px}h2{font-size:25px;line-height:1.25;margin:0 0 12px}h3{font-size:18px;margin:0 0 8px}p{margin:10px 0}.eyebrow{font-size:13px;letter-spacing:.1em;font-weight:750;color:var(--b)}.intro{max-width:900px;color:var(--muted)}section{background:white;padding:26px;margin:24px 0;border-radius:12px}.note{background:#e8eff4;padding:15px 18px;border-left:4px solid #536e83;border-radius:4px}.small{font-size:14px;color:var(--muted)}.tools,.controls,.legend{display:flex;gap:12px;flex-wrap:wrap;align-items:center}.tools{margin-top:22px}button,select{font:inherit;border:1px solid #b7c5cf;border-radius:6px;background:white;color:var(--ink);padding:8px 12px;cursor:pointer}button:hover{background:#edf3f6}button:focus-visible,select:focus-visible,summary:focus-visible{outline:3px solid #187fb0;outline-offset:3px}.legend{font-size:15px;margin:12px 0}.swatch{display:inline-block;width:15px;height:15px;margin-right:7px;vertical-align:-2px}.chart-scroll,.table-scroll{overflow-x:auto}#trend-svg{width:100%;min-width:700px;display:block}.heat{min-width:780px;width:100%;border-collapse:separate;border-spacing:4px;font-size:15px}.heat th{text-align:left;white-space:nowrap}.heat thead th:not(:first-child){text-align:center}.heat td{padding:0;text-align:center;border-radius:4px}.heat button{background:transparent;color:inherit;border:0;padding:9px 5px;border-radius:4px;width:100%;min-height:44px;font-size:15px;font-weight:650}.heat button[aria-pressed="true"]{outline:3px solid #1684bc;outline-offset:-2px}.scale{width:260px;height:13px;background:linear-gradient(to right,#f5f7fa,#4a2775);margin:8px 0 2px}.scale-labels{width:260px;display:flex;justify-content:space-between;font-size:13px}.controls label{display:flex;flex-direction:column;font-size:14px;gap:4px}#detail-title{margin:20px 0 10px}.parts{display:grid;grid-template-columns:repeat(3,1fr);gap:15px;margin:18px 0}.part{padding:15px;background:#f5f7f9;border-top:5px solid var(--c)}.part.a{border-color:var(--a)}.part.b{border-color:var(--b)}.value{font-size:28px;font-weight:750}.stack{display:flex;height:32px;border-radius:5px;overflow:hidden;margin-top:16px}.stack span{display:block}.equation{font-family:ui-monospace,monospace;font-size:14px;overflow-wrap:anywhere}.outcome{font-size:21px;font-weight:650}.heat-hint{color:var(--muted);font-size:14px}table{border-collapse:collapse;width:100%;font-size:15px}caption{text-align:left;margin-bottom:10px;font-weight:650}th,td{padding:9px;text-align:right;border-bottom:1px solid #e0e7ec}th:first-child{text-align:left}details{margin:14px 0}summary{cursor:pointer;font-weight:650}li{margin:8px 0}code{font-size:12px;overflow-wrap:anywhere}a{color:#126b94}footer{font-size:14px;color:var(--muted)}
@media(max-width:650px){main{padding:22px 14px}section{padding:20px 14px}.parts{grid-template-columns:1fr}.controls>*{max-width:100%}select{max-width:100%}.value{font-size:25px}.tools button{font-size:14px}.note{font-size:15px}}
@media print{body{background:white;font-size:11pt}main{max-width:none;padding:0}.tools,.controls,.heat-hint,.no-print{display:none}section{padding:15px 0;margin:12px 0;border-radius:0;break-inside:avoid}h1{font-size:25pt}h2{font-size:18pt}.table-scroll,.chart-scroll{overflow:visible}.heat{min-width:0;font-size:9pt}.heat button{font-size:9pt;min-height:0;padding:5px}.heat th{white-space:normal}#trend-svg{min-width:0}.parts{grid-template-columns:repeat(3,1fr)}*{print-color-adjust:exact;-webkit-print-color-adjust:exact}details{break-inside:avoid}@page{size:A4 landscape;margin:13mm}}
</style></head><body><main>
<header><div class="eyebrow">CHILE · ENPG + INE · ESTIMACIÓN PROVISIONAL</div>
<h1>¿Qué población queda fuera de la cobertura geográfica de ENPG?</h1>
<p class="intro">Entre 2012 y 2024, la proporción estimada pasa de <strong>23,14% a 21,95%</strong>: una disminución de <strong>1,19 puntos porcentuales</strong>. En 2024 equivale a unos <strong>22 de cada 100 habitantes de 15–64 años</strong>.</p>
<p class="note"><strong>Subcobertura no significa subestimación del consumo.</strong> Estos gráficos muestran cuántas personas viven fuera de las áreas aproximadas de cobertura. No indican si ENPG sobreestima o subestima el alcohol ni en qué magnitud.</p>
<p class="small">Edades 15–64 en todos los numeradores y denominadores. Ambos sexos. Proyecciones INE base 2017 del mismo año de cada ola. Comunas observadas usadas como aproximación al marco.</p>
<div class="tools"><button id="save-html">Guardar este HTML</button><button id="print">Imprimir / PDF</button><button id="save-csv">Descargar datos CSV</button><button id="save-svg">Descargar gráfico nacional SVG</button></div></header>
<section aria-labelledby="national-title"><h2 id="national-title">1. La proporción nacional cambia poco</h2>
<p>Cada barra suma dos componentes excluyentes. Su altura muestra el porcentaje fuera de cobertura, con eje desde cero.</p>
<div class="legend"><span><i class="swatch" style="background:var(--a)"></i><strong>A:</strong> urbano + rural en comunas no observadas</span><span><i class="swatch" style="background:var(--b)"></i><strong>B:</strong> rural en comunas observadas</span></div>
<div class="chart-scroll">__SVG__</div>
<p class="small">La proporción disminuye, pero el número de personas excluidas aumenta: de 2.775.983 en 2012 a 2.988.786 en 2024, mientras crece la población nacional del rango. Son cambios descriptivos, no efectos de una política.</p></section>
<section aria-labelledby="heat-title"><h2 id="heat-title">2. La cobertura difiere entre regiones</h2>
<p>Cada celda usa como denominador la población de <strong>su propia región</strong>. Un color más oscuro significa mayor proporción fuera de cobertura, no necesariamente más personas.</p>
<div class="scale" aria-hidden="true"></div><div class="scale-labels"><span>0% excluido</span><span>100% excluido</span></div>
<p class="heat-hint">Selecciona una celda para ver las personas y los componentes en el desglose siguiente. En pantallas pequeñas, desplaza la tabla horizontalmente.</p>
<div class="table-scroll">__HEAT__</div>
<p class="small">Regiones ordenadas de norte a sur. Se usa la división territorial de la tabla INE en toda la serie: Ñuble se muestra por separado también antes de su creación administrativa. Los porcentajes regionales no se promedian sin ponderar para obtener Chile.</p></section>
<section id="detail" aria-labelledby="detail-heading"><h2 id="detail-heading">3. El desglose, sin contar a nadie dos veces</h2>
<div class="controls"><label>Territorio<select id="region"><option value="0">Chile</option>__OPTIONS__</select></label><label>Año<select id="year">__YEARS__</select></label></div>
<div id="detail-output" aria-live="polite"><h3 id="detail-title"></h3><p id="detail-total"></p><div class="stack" aria-hidden="true"><span id="seg-c" style="background:var(--c)"></span><span id="seg-a" style="background:var(--a)"></span><span id="seg-b" style="background:var(--b)"></span></div>
<div class="parts"><div class="part"><h3>Urbana cubierta</h3><div class="value" id="c-pct"></div><div id="c-n"></div><p class="small">En comunas observadas.</p></div><div class="part a"><h3>A · Fuera de las comunas</h3><div class="value" id="a-pct"></div><div id="a-n"></div><p class="small">Incluye su población urbana y rural.</p></div><div class="part b"><h3>B · Rural dentro</h3><div class="value" id="b-pct"></div><div id="b-n"></div><p class="small">Solo rural de comunas observadas.</p></div></div>
<p class="outcome" id="detail-result"></p><p class="equation" id="detail-check"></p></div>
<p class="note">El rural de las comunas no observadas ya está en A. Si sumáramos A y todo el rural, lo contaríamos dos veces. En Chile 2024 esa duplicación añadiría indebidamente 883.244 personas.</p></section>
<section><h2>Fuentes, supuestos y datos</h2><div class="table-scroll">__TABLE__</div>
<ul><li><strong>INE:</strong> Estimaciones y proyecciones 2002–2035, comuna y área urbana/rural, base 2017. Se suman los grupos 15–19 a 60–64. Son proyecciones, no conteos del Censo 2024. <a href="https://www.ine.gob.cl/estadisticas-por-tema/demografia-y-poblacion/estimaciones-y-proyecciones-de-poblacion">Fuente INE</a>.</li>
<li><strong>ENPG:</strong> comunas observadas de cada ola del cache de diseño del proyecto: 108 en 2012–2016 y 109 desde 2018. Se armoniza Chillán (8401 → 16101). Las listas no sustituyen directorios oficiales del marco verificados para cada año. El informe 2024 define áreas urbanas de 109 comunas.</li>
<li><strong>Aproximación geográfica:</strong> se considera cubierta toda la población urbana de esas comunas. No se cuantifican UPM especiales excluidas ni otras restricciones de elegibilidad. Ausencia en la lista no implica población comunal menor de 30.000.</li>
<li><strong>Edades:</strong> se conserva 15–64, sin imputar personas de 65 años. No es el porcentaje de toda la población chilena ni un resultado exacto para 15–65.</li>
<li><strong>Validación:</strong> A + B + cubierta = total en las 112 combinaciones región × año; las sumas regionales reproducen los siete resultados nacionales. Ambas fórmulas del porcentaje coinciden. Sin intervalo de confianza artificial.</li></ul>
<details><summary>Cómo reproducir y comprobar los insumos</summary><p class="small">Cálculo nacional: <code>__andres_control/calculate_enpg_geographic_coverage_series.R</code>. HTML y regiones: <code>python __andres_control/build_enpg_coverage_html.py</code>. Registro completo: <code>__andres_control/README_enpg_geographic_coverage_2024.md</code>.</p>__HASHES__</details>
</section><footer>Preparado el 26 de octubre de 2026 · Funciona sin conexión: datos, gráficos y controles incluidos en este archivo. No contiene microdatos ni ejecuta modelos de consumo.</footer>
<noscript><p class="note">Los gráficos y tablas se pueden leer sin JavaScript. Para el desglose interactivo y las descargas, habilita JavaScript.</p></noscript>
</main><script id="coverage-data" type="application/json">__DATA__</script><script>
const data = JSON.parse(document.getElementById('coverage-data').textContent);
const nf = new Intl.NumberFormat('es-CL');
const pf = new Intl.NumberFormat('es-CL',{minimumFractionDigits:2,maximumFractionDigits:2});
const reg = document.getElementById('region'), year = document.getElementById('year');
function render(){
 const r=data.find(d=>d.region===Number(reg.value)&&d.year===Number(year.value));
 document.getElementById('detail-title').textContent=`${r.name} · ${r.year} · 15–64 años`;
 document.getElementById('detail-total').textContent=`Población total de referencia: ${nf.format(r.population_total)} personas.`;
 for(const [id,key] of [['a','component_A'],['b','component_B'],['c','population_covered']]){
  const p=100*r[key]/r.population_total;
  document.getElementById(id+'-pct').textContent=pf.format(p)+'%';
  document.getElementById(id+'-n').textContent=nf.format(r[key])+' personas';
  document.getElementById('seg-'+id).style.width=p+'%';
 }
 document.getElementById('detail-result').textContent=`Fuera de cobertura: ${nf.format(r.component_A+r.component_B)} personas · ${pf.format(r.excluded_pct)}%.`;
 document.getElementById('detail-check').textContent=`100 × (${nf.format(r.component_A)} + ${nf.format(r.component_B)}) / ${nf.format(r.population_total)} = 100 × (1 − ${nf.format(r.population_covered)} / ${nf.format(r.population_total)}) = ${pf.format(r.excluded_pct)}%`;
 document.querySelectorAll('.heat button').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.region===reg.value&&b.dataset.year===year.value)));
}
reg.addEventListener('change',render);year.addEventListener('change',render);
document.querySelectorAll('.heat button').forEach(b=>b.addEventListener('click',()=>{
 reg.value=b.dataset.region;year.value=b.dataset.year;render();document.getElementById('detail').scrollIntoView({behavior:'smooth',block:'start'});
}));
function download(name,content,type){const url=URL.createObjectURL(new Blob([content],{type}));const a=document.createElement('a');a.href=url;a.download=name;a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);}
document.getElementById('save-html').onclick=()=>download('enpg-cobertura-15-64.html','<!doctype html>\n'+document.documentElement.outerHTML,'text/html;charset=utf-8');
document.getElementById('print').onclick=()=>window.print();
document.getElementById('save-svg').onclick=()=>download('enpg-cobertura-nacional-15-64.svg',new XMLSerializer().serializeToString(document.getElementById('trend-svg')),'image/svg+xml;charset=utf-8');
document.getElementById('save-csv').onclick=()=>{const keys=['year','age','region','name','population_total','population_covered','component_A','component_B','excluded_pct'];const quote=x=>'"'+String(x).replaceAll('"','""')+'"';download('enpg-cobertura-nacional-regional-15-64.csv','\ufeff'+keys.join(',')+'\r\n'+data.map(r=>keys.map(k=>quote(r[k])).join(',')).join('\r\n'),'text/csv;charset=utf-8');};
render();
</script></body></html>'''
for key, value in {"SVG": svg, "HEAT": heat, "TABLE": table, "HASHES": hashes, "DATA": data,
    "OPTIONS": ''.join(f'<option value="{k}">{html.escape(names[k])}</option>' for k in region_order),
    "YEARS": ''.join(f'<option value="{y}"'+(' selected' if y == 2024 else '')+f'>{y}</option>' for y in years)}.items():
    page = page.replace('__'+key+'__', value)
assert '__SVG__' not in page and '<script src=' not in page and '<link ' not in page
destination = out / "enpg_cobertura_geografica_15_64.html"
destination.write_text(page, encoding="utf-8")
print(f"Wrote {destination.name} ({destination.stat().st_size:,} bytes); validated {len(regional)} regional cells.")
print(f"Elapsed: {(time.perf_counter()-t0)/60:.2f} min")
