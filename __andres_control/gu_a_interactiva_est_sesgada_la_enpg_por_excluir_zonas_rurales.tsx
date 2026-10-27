import React, { useState, useMemo } from 'react';
import {
  MapPin,
  Users,
  Wine,
  AlertTriangle,
  CheckCircle2,
  Info,
  Sliders,
  FileSpreadsheet,
  ArrowRight,
  TrendingUp,
  TrendingDown,
  Minus,
  HelpCircle,
  Scale,
  Compass,
  Layers,
  Filter,
  EyeOff,
  BarChart3,
  BookOpen,
  History,
  Layers3,
  Check,
  Database
} from 'lucide-react';

// ==========================================
// DATOS DE LAS TABLAS EXPLORATORIAS
// ==========================================

// Tabla 1: enpg_rural_coverage.csv + Tabla 2: enpg_rural_bias.csv (Total y desglose)
const COVERAGE_BY_YEAR = {
  2012: {
    year: 2012,
    population_total: 11998670,
    population_covered: 9222687,
    component_A: 2239021,
    component_B: 536962,
    excluded_pct: 23.13575587961,
    comunas_enpg: 108,
    comunas_total: 346,
    pct_pop_in_enpg_comunas: 81.3,
    pct_rural_pop_in_enpg_comunas: 37.2,
    enpg_pct_weight_comunas_r0: 25.6,
    enpg_mean: 4.6,
    pop_mean: 12.0,
    ratio_mean: 0.38,
    byGroup: {
      'Total 15-65': { enpg: 4.6, ine: 12.0, ratio: 0.38 },
      'Hombre 15-29': { enpg: 4.6, ine: 11.2, ratio: 0.41 },
      'Hombre 30-44': { enpg: 4.6, ine: 12.0, ratio: 0.38 },
      'Hombre 45-59': { enpg: 4.7, ine: 13.1, ratio: 0.36 },
      'Hombre 60-65': { enpg: 4.4, ine: 13.5, ratio: 0.33 },
      'Mujer 15-29': { enpg: 4.8, ine: 11.5, ratio: 0.42 },
      'Mujer 30-44': { enpg: 4.5, ine: 12.1, ratio: 0.37 },
      'Mujer 45-59': { enpg: 4.6, ine: 12.3, ratio: 0.37 },
      'Mujer 60-65': { enpg: 4.6, ine: 12.3, ratio: 0.37 },
    }
  },
  2014: {
    year: 2014,
    population_total: 12251374,
    population_covered: 9421653,
    component_A: 2282019,
    component_B: 547702,
    excluded_pct: 23.0971726110067,
    comunas_enpg: 108,
    comunas_total: 346,
    pct_pop_in_enpg_comunas: 81.4,
    pct_rural_pop_in_enpg_comunas: 37.7,
    enpg_pct_weight_comunas_r0: 24.9,
    enpg_mean: 4.5,
    pop_mean: 11.9,
    ratio_mean: 0.38,
    byGroup: {
      'Total 15-65': { enpg: 4.5, ine: 11.9, ratio: 0.38 },
      'Hombre 15-29': { enpg: 4.6, ine: 11.0, ratio: 0.42 },
      'Hombre 30-44': { enpg: 4.5, ine: 11.7, ratio: 0.38 },
      'Hombre 45-59': { enpg: 4.5, ine: 13.1, ratio: 0.34 },
      'Hombre 60-65': { enpg: 4.6, ine: 13.3, ratio: 0.35 },
      'Mujer 15-29': { enpg: 4.8, ine: 11.3, ratio: 0.42 },
      'Mujer 30-44': { enpg: 4.7, ine: 11.9, ratio: 0.39 },
      'Mujer 45-59': { enpg: 4.2, ine: 12.3, ratio: 0.34 },
      'Mujer 60-65': { enpg: 3.9, ine: 12.2, ratio: 0.32 },
    }
  },
  2016: {
    year: 2016,
    population_total: 12488678,
    population_covered: 9614859,
    component_A: 2318731,
    component_B: 555088,
    excluded_pct: 23.0113948009549,
    comunas_enpg: 108,
    comunas_total: 346,
    pct_pop_in_enpg_comunas: 81.4,
    pct_rural_pop_in_enpg_comunas: 38.1,
    enpg_pct_weight_comunas_r0: 23.6,
    enpg_mean: 4.7,
    pop_mean: 11.7,
    ratio_mean: 0.40,
    byGroup: {
      'Total 15-65': { enpg: 4.7, ine: 11.7, ratio: 0.40 },
      'Hombre 15-29': { enpg: 4.7, ine: 10.8, ratio: 0.44 },
      'Hombre 30-44': { enpg: 4.5, ine: 11.4, ratio: 0.39 },
      'Hombre 45-59': { enpg: 4.9, ine: 13.0, ratio: 0.38 },
      'Hombre 60-65': { enpg: 6.1, ine: 13.2, ratio: 0.46 },
      'Mujer 15-29': { enpg: 4.7, ine: 11.1, ratio: 0.42 },
      'Mujer 30-44': { enpg: 4.3, ine: 11.7, ratio: 0.37 },
      'Mujer 45-59': { enpg: 4.5, ine: 12.2, ratio: 0.37 },
      'Mujer 60-65': { enpg: 4.8, ine: 12.1, ratio: 0.40 },
    }
  },
  2018: {
    year: 2018,
    population_total: 12890070,
    population_covered: 9982173,
    component_A: 2336416,
    component_B: 571481,
    excluded_pct: 22.5592025489388,
    comunas_enpg: 109,
    comunas_total: 346,
    pct_pop_in_enpg_comunas: 81.9,
    pct_rural_pop_in_enpg_comunas: 38.9,
    enpg_pct_weight_comunas_r0: 20.6,
    enpg_mean: 5.5,
    pop_mean: 11.5,
    ratio_mean: 0.48,
    byGroup: {
      'Total 15-65': { enpg: 5.5, ine: 11.5, ratio: 0.48 },
      'Hombre 15-29': { enpg: 5.6, ine: 10.5, ratio: 0.53 },
      'Hombre 30-44': { enpg: 5.3, ine: 11.0, ratio: 0.48 },
      'Hombre 45-59': { enpg: 5.7, ine: 12.8, ratio: 0.45 },
      'Hombre 60-65': { enpg: 5.5, ine: 13.0, ratio: 0.42 },
      'Mujer 15-29': { enpg: 5.8, ine: 10.8, ratio: 0.54 },
      'Mujer 30-44': { enpg: 5.5, ine: 11.4, ratio: 0.48 },
      'Mujer 45-59': { enpg: 5.2, ine: 12.1, ratio: 0.43 },
      'Mujer 60-65': { enpg: 5.7, ine: 11.9, ratio: 0.48 },
    }
  },
  2020: {
    year: 2020,
    population_total: 13361656,
    population_covered: 10404214,
    component_A: 2372973,
    component_B: 584469,
    excluded_pct: 22.1337983854696,
    comunas_enpg: 108,
    comunas_total: 346,
    pct_pop_in_enpg_comunas: 82.2,
    pct_rural_pop_in_enpg_comunas: 39.4,
    enpg_pct_weight_comunas_r0: 31.1,
    enpg_mean: 4.6,
    pop_mean: 11.2,
    ratio_mean: 0.41,
    byGroup: {
      'Total 15-65': { enpg: 4.6, ine: 11.2, ratio: 0.41 },
      'Hombre 15-29': { enpg: 4.4, ine: 10.2, ratio: 0.43 },
      'Hombre 30-44': { enpg: 4.6, ine: 10.6, ratio: 0.43 },
      'Hombre 45-59': { enpg: 4.5, ine: 12.5, ratio: 0.36 },
      'Hombre 60-65': { enpg: 4.4, ine: 12.9, ratio: 0.34 },
      'Mujer 15-29': { enpg: 4.7, ine: 10.5, ratio: 0.45 },
      'Mujer 30-44': { enpg: 4.9, ine: 11.0, ratio: 0.45 },
      'Mujer 45-59': { enpg: 4.3, ine: 11.9, ratio: 0.36 },
      'Mujer 60-65': { enpg: 4.7, ine: 11.8, ratio: 0.40 },
    }
  },
  2022: {
    year: 2022,
    population_total: 13528576,
    population_covered: 10552521,
    component_A: 2388190,
    component_B: 587865,
    excluded_pct: 21.998287181149,
    comunas_enpg: 109,
    comunas_total: 346,
    pct_pop_in_enpg_comunas: 82.3,
    pct_rural_pop_in_enpg_comunas: 39.8,
    enpg_pct_weight_comunas_r0: 29.2,
    enpg_mean: 5.1,
    pop_mean: 11.0,
    ratio_mean: 0.46,
    byGroup: {
      'Total 15-65': { enpg: 5.1, ine: 11.0, ratio: 0.46 },
      'Hombre 15-29': { enpg: 5.2, ine: 10.1, ratio: 0.51 },
      'Hombre 30-44': { enpg: 5.0, ine: 10.4, ratio: 0.48 },
      'Hombre 45-59': { enpg: 5.0, ine: 12.3, ratio: 0.41 },
      'Hombre 60-65': { enpg: 4.9, ine: 12.7, ratio: 0.39 },
      'Mujer 15-29': { enpg: 4.9, ine: 10.4, ratio: 0.47 },
      'Mujer 30-44': { enpg: 4.9, ine: 10.8, ratio: 0.45 },
      'Mujer 45-59': { enpg: 5.3, ine: 11.8, ratio: 0.45 },
      'Mujer 60-65': { enpg: 5.4, ine: 11.7, ratio: 0.46 },
    }
  },
  2024: {
    year: 2024,
    population_total: 13619165,
    population_covered: 10630379,
    component_A: 2399620,
    component_B: 589166,
    excluded_pct: 21.945442323373,
    comunas_enpg: 109,
    comunas_total: 346,
    pct_pop_in_enpg_comunas: 82.4,
    pct_rural_pop_in_enpg_comunas: 40.0,
    enpg_pct_weight_comunas_r0: 29.5,
    enpg_mean: 4.2,
    pop_mean: 10.9,
    ratio_mean: 0.39,
    byGroup: {
      'Total 15-65': { enpg: 4.2, ine: 10.9, ratio: 0.39 },
      'Hombre 15-29': { enpg: 4.0, ine: 10.1, ratio: 0.40 },
      'Hombre 30-44': { enpg: 4.4, ine: 10.2, ratio: 0.43 },
      'Hombre 45-59': { enpg: 4.1, ine: 12.1, ratio: 0.34 },
      'Hombre 60-65': { enpg: 4.4, ine: 12.6, ratio: 0.35 },
      'Mujer 15-29': { enpg: 4.3, ine: 10.4, ratio: 0.41 },
      'Mujer 30-44': { enpg: 4.3, ine: 10.7, ratio: 0.40 },
      'Mujer 45-59': { enpg: 4.2, ine: 11.7, ratio: 0.36 },
      'Mujer 60-65': { enpg: 4.2, ine: 11.7, ratio: 0.36 },
    }
  }
};

// Tabla 3: rg_T1_ratios.csv
const T1_RATIOS = [
  // Principal: Wave VIII, region_FE = TRUE
  { outcome: 'Current drinker', label: 'Consumo actual (Prevalencia)', waves: 'VIII', exposure: 'rural_asg', region_FE: true, rr: 0.67, lo95: 0.42, hi95: 1.06, p: 0.086, desc: 'Un área 100% rural tendría ~33% menos bebedores actuales que una 100% urbana, aunque roza la significancia.' },
  { outcome: 'Grams/day (population)', label: 'Gramos de alcohol / día', waves: 'VIII', exposure: 'rural_asg', region_FE: true, rr: 0.96, lo95: 0.43, hi95: 2.14, p: 0.923, desc: 'A nivel agregado nacional casi no se ve diferencia (0,96), porque hombres y mujeres van en sentidos opuestos.' },
  { outcome: 'Risky', label: 'Consumo Riesgoso (≥20g M / ≥40g H)', waves: 'VIII', exposure: 'rural_asg', region_FE: true, rr: 0.28, lo95: 0.06, hi95: 1.33, p: 0.109, desc: 'Tendencia fuerte a menor consumo riesgoso promedio en zonas rurales (-72%), aunque con intervalo amplio en VIII.' },
  { outcome: 'HED 5+/4+', label: 'Consumo Intenso Episódico (HED 5+/4+)', waves: 'VIII', exposure: 'rural_asg', region_FE: true, rr: 1.31, lo95: 0.57, hi95: 2.99, p: 0.524, desc: 'Tendencia a más episodios de embriaguez (+31%) en zonas rurales, empujada por hombres de menor escolaridad.' },
  // Sin control regional (Wave VIII, region_FE = FALSE)
  { outcome: 'Current drinker', label: 'Consumo actual (Prevalencia)', waves: 'VIII', exposure: 'rural_asg', region_FE: false, rr: 0.87, lo95: 0.60, hi95: 1.26, p: 0.460, desc: 'Sin controlar por región, la diferencia rural/urbana se confunde con regiones del sur/centro que beben más.' },
  { outcome: 'Grams/day (population)', label: 'Gramos de alcohol / día', waves: 'VIII', exposure: 'rural_asg', region_FE: false, rr: 0.92, lo95: 0.42, hi95: 2.00, p: 0.830, desc: 'Promedio nacional cercano a 1 cuando se mezclan ambos sexos.' },
  { outcome: 'Risky', label: 'Consumo Riesgoso (≥20g M / ≥40g H)', waves: 'VIII', exposure: 'rural_asg', region_FE: false, rr: 0.35, lo95: 0.08, hi95: 1.52, p: 0.161, desc: 'Menor proporción de consumo riesgoso promedio sin control regional.' },
  { outcome: 'HED 5+/4+', label: 'Consumo Intenso Episódico (HED 5+/4+)', waves: 'VIII', exposure: 'rural_asg', region_FE: false, rr: 1.13, lo95: 0.51, hi95: 2.50, p: 0.760, desc: 'Leve tendencia positiva sin control regional.' },
  // 3 Rondas juntas (ALL, region_FE = TRUE)
  { outcome: 'Current drinker', label: 'Consumo actual (Prevalencia)', waves: 'ALL', exposure: 'rural_asg', region_FE: true, rr: 0.55, lo95: 0.41, hi95: 0.74, p: 0.001, desc: 'Al juntar las 3 rondas (2015–2024), el menor porcentaje de bebedores rurales es estadísticamente muy claro (-45%).' },
  { outcome: 'Grams/day (population)', label: 'Gramos de alcohol / día', waves: 'ALL', exposure: 'rural_asg', region_FE: true, rr: 0.48, lo95: 0.27, hi95: 0.86, p: 0.013, desc: 'Al unir las 3 rondas, los gramos promedio en zonas rurales son significativamente menores (-52%).' },
  { outcome: 'Risky', label: 'Consumo Riesgoso (≥20g M / ≥40g H)', waves: 'ALL', exposure: 'rural_asg', region_FE: true, rr: 0.34, lo95: 0.14, hi95: 0.82, p: 0.017, desc: 'Al juntar las 3 rondas, el consumo riesgoso es significativamente menor en lo rural (-66%, p=0.017).' },
  { outcome: 'HED 5+/4+', label: 'Consumo Intenso Episódico (HED 5+/4+)', waves: 'ALL', exposure: 'rural_asg', region_FE: true, rr: 1.13, lo95: 0.63, hi95: 2.00, p: 0.688, desc: 'En HED se mantiene la dirección >1 en lo rural pero con compensación entre hombres y mujeres.' },
];

// Comparación detallada de todas las especificaciones de rg_T1_ratios.csv para la Pestaña 4
const EPS_WAVES_COMPARISON = [
  {
    outcome: 'Current drinker',
    label: 'Consumo actual (Prevalencia)',
    shortDesc: 'Proporción que bebe actualmente',
    specs: {
      rural_asg_FE: {
        viii: { rr: 0.668, lo95: 0.421, hi95: 1.059, p: 0.086, sig: false },
        all: { rr: 0.553, lo95: 0.411, hi95: 0.743, p: 0.0001, sig: true },
        insight: 'Al unir las 3 olas (VI, VII y VIII), el intervalo se estrecha fuertemente y confirma un -45% menos de bebedores actuales en zonas rurales (p < 0.001).'
      },
      rural_asg_noFE: {
        viii: { rr: 0.870, lo95: 0.600, hi95: 1.260, p: 0.460, sig: false },
        all: { rr: 0.640, lo95: 0.500, hi95: 0.820, p: 0.0004, sig: true },
        insight: 'Incluso sin efectos fijos por región, las 3 olas juntas dan un RR de 0,64 altamente significativo.'
      },
      rural_exp_FE: {
        viii: { rr: 0.685, lo95: 0.435, hi95: 1.078, p: 0.102, sig: false },
        all: { rr: 0.568, lo95: 0.425, hi95: 0.759, p: 0.0001, sig: true },
        insight: 'Usar la ruralidad esperada entre comunas candidatas (`rural_exp`) entrega exactamente la misma conclusión que `rural_asg`.'
      },
      noncov_asg_FE: {
        viii: { rr: 0.752, lo95: 0.531, hi95: 1.065, p: 0.109, sig: false },
        all: { rr: 0.648, lo95: 0.512, hi95: 0.820, p: 0.0003, sig: true },
        insight: 'Midiendo todo lo que queda fuera del marco ENPG (rural + urbano fuera de comunas observadas), las 3 olas confirman menor prevalencia general (-35%).'
      }
    }
  },
  {
    outcome: 'Grams/day (population)',
    label: 'Gramos de alcohol puro / día',
    shortDesc: 'Promedio poblacional (incluyendo 0 en abstemios)',
    specs: {
      rural_asg_FE: {
        viii: { rr: 0.961, lo95: 0.431, hi95: 2.144, p: 0.923, sig: false },
        all: { rr: 0.482, lo95: 0.271, hi95: 0.856, p: 0.013, sig: true },
        insight: 'Cambio clave: en Ronda VIII da 0,96 (no sig.), pero al juntar las 3 rondas (`ALL`) baja a 0,48 [0,27–0,86] (p=0.013), significativamente menor (-52%).'
      },
      rural_asg_noFE: {
        viii: { rr: 0.920, lo95: 0.420, hi95: 2.000, p: 0.830, sig: false },
        all: { rr: 0.610, lo95: 0.380, hi95: 0.980, p: 0.041, sig: true },
        insight: 'Sin control regional (`region_FE=FALSE`), las 3 rondas dan RR 0,61 significativo.'
      },
      rural_exp_FE: {
        viii: { rr: 0.975, lo95: 0.440, hi95: 2.160, p: 0.950, sig: false },
        all: { rr: 0.495, lo95: 0.280, hi95: 0.875, p: 0.016, sig: true },
        insight: 'Total consistencia entre `rural_asg` y `rural_exp`.'
      },
      noncov_asg_FE: {
        viii: { rr: 0.980, lo95: 0.520, hi95: 1.845, p: 0.950, sig: false },
        all: { rr: 0.590, lo95: 0.375, hi95: 0.928, p: 0.022, sig: true },
        insight: 'Fuera del marco ENPG también se observa significativamente menos gramos promedio cuando se acumulan las 3 rondas.'
      }
    }
  },
  {
    outcome: 'Risky',
    label: 'Consumo Riesgoso (≥20g M / ≥40g H)',
    shortDesc: 'Prevalencia de consumo diario de riesgo',
    specs: {
      rural_asg_FE: {
        viii: { rr: 0.277, lo95: 0.058, hi95: 1.334, p: 0.109, sig: false },
        all: { rr: 0.340, lo95: 0.141, hi95: 0.822, p: 0.017, sig: true },
        insight: 'En Ronda VIII el efecto es muy fuerte (0,28) pero impreciso por pocos casos; al juntar las 3 rondas (`ALL`) da 0,34 [0,14–0,82] y se vuelve significativo (p=0.017).'
      },
      rural_asg_noFE: {
        viii: { rr: 0.350, lo95: 0.080, hi95: 1.520, p: 0.161, sig: false },
        all: { rr: 0.420, lo95: 0.190, hi95: 0.930, p: 0.032, sig: true },
        insight: 'Misma dirección: sustancialmente menor consumo promedio de alto volumen diario en lo rural.'
      },
      rural_exp_FE: {
        viii: { rr: 0.290, lo95: 0.062, hi95: 1.355, p: 0.116, sig: false },
        all: { rr: 0.352, lo95: 0.148, hi95: 0.838, p: 0.018, sig: true },
        insight: 'Robusto al método de imputación de comunas ambiguas.'
      },
      noncov_asg_FE: {
        viii: { rr: 0.410, lo95: 0.125, hi95: 1.345, p: 0.141, sig: false },
        all: { rr: 0.465, lo95: 0.225, hi95: 0.960, p: 0.038, sig: true },
        insight: 'Consistente para el conjunto de población fuera del marco ENPG.'
      }
    }
  },
  {
    outcome: 'HED 5+/4+',
    label: 'Consumo Intenso Episódico (HED 5+/4+)',
    shortDesc: 'Al menos una ocasión de 5+ tragos (H) / 4+ (M)',
    specs: {
      rural_asg_FE: {
        viii: { rr: 1.308, lo95: 0.572, hi95: 2.989, p: 0.524, sig: false },
        all: { rr: 1.126, lo95: 0.632, hi95: 2.003, p: 0.688, sig: false },
        insight: 'Es el único indicador con RR > 1 (+31% en VIII y +13% en ALL) porque el mayor HED de hombres rurales compensa el menor HED de mujeres rurales.'
      },
      rural_asg_noFE: {
        viii: { rr: 1.130, lo95: 0.510, hi95: 2.500, p: 0.760, sig: false },
        all: { rr: 0.980, lo95: 0.580, hi95: 1.650, p: 0.940, sig: false },
        insight: 'Sin separar por sexo y educación, la cancelación entre hombres (+) y mujeres (-) oculta el sesgo de HED.'
      },
      rural_exp_FE: {
        viii: { rr: 1.295, lo95: 0.568, hi95: 2.952, p: 0.538, sig: false },
        all: { rr: 1.118, lo95: 0.628, hi95: 1.990, p: 0.704, sig: false },
        insight: 'Dirección positiva estable en ambas especificaciones de ruralidad.'
      },
      noncov_asg_FE: {
        viii: { rr: 1.312, lo95: 1.005, hi95: 1.715, p: 0.046, sig: true },
        all: { rr: 1.185, lo95: 0.890, hi95: 1.578, p: 0.245, sig: false },
        insight: 'Al mirar toda la población fuera del marco ENPG (`noncov_asg`) en Ronda VIII, el exceso de HED alcanza significancia estadística (RR 1,31, p=0.046).'
      }
    }
  }
];

// Tabla 4: rg_T2_gaps.csv (Diferencias absolutas rural - urbano o fuera - dentro del marco ENPG)
const T2_GAPS = {
  rural_asg: [
    // Mujeres
    { sex: 'Mujeres', edu: 'Básica o menos (Prim)', current_delta: -0.008, current_lo: -0.250, current_hi: 0.234, sig_current: false, grams_delta: -0.05, grams_lo: -1.10, grams_hi: 1.00, sig_grams: false, hed_delta: -0.004, hed_lo: -0.080, hed_hi: 0.072, sig_hed: false, summary: 'Casi sin diferencia entre campo y ciudad en mujeres de educación básica.' },
    { sex: 'Mujeres', edu: 'Media (Sec)', current_delta: -0.241, current_lo: -0.440, current_hi: -0.042, sig_current: true, grams_delta: -1.25, grams_lo: -2.90, grams_hi: 0.40, sig_grams: false, hed_delta: -0.002, hed_lo: -0.085, hed_hi: 0.081, sig_hed: false, summary: 'En zonas rurales hay 24,1 puntos porcentuales MENOS de bebedoras actuales.' },
    { sex: 'Mujeres', edu: 'Superior completa (Tert)', current_delta: -0.349, current_lo: -0.620, current_hi: -0.078, sig_current: true, grams_delta: -4.76, grams_lo: -8.30, grams_hi: -1.22, sig_grams: true, hed_delta: -0.142, hed_lo: -0.260, hed_hi: -0.024, sig_hed: true, summary: 'Caída dramática en zonas rurales: -34,9 pp en bebedoras, -4,76 g/día y -14,2 pp en HED.' },
    // Hombres
    { sex: 'Hombres', edu: 'Básica o menos (Prim)', current_delta: 0.115, current_lo: -0.140, current_hi: 0.370, sig_current: false, grams_delta: 2.87, grams_lo: -3.50, grams_hi: 9.24, sig_grams: false, hed_delta: 0.090, hed_lo: 0.005, hed_hi: 0.175, sig_hed: true, summary: 'En zonas rurales tienen +9,0 puntos porcentuales MÁS de consumo intenso episódico (HED / borracheras).' },
    { sex: 'Hombres', edu: 'Media (Sec)', current_delta: 0.012, current_lo: -0.180, current_hi: 0.204, sig_current: false, grams_delta: 1.65, grams_lo: -3.10, grams_hi: 6.40, sig_grams: false, hed_delta: 0.099, hed_lo: 0.012, hed_hi: 0.186, sig_hed: true, summary: 'Misma cantidad de bebedores, pero +9,9 pp MÁS de consumo intenso episódico (HED) en lo rural.' },
    { sex: 'Hombres', edu: 'Superior completa (Tert)', current_delta: -0.085, current_lo: -0.390, current_hi: 0.220, sig_current: false, grams_delta: -0.20, grams_lo: -6.50, grams_hi: 6.10, sig_grams: false, hed_delta: -0.010, hed_lo: -0.160, hed_hi: 0.140, sig_hed: false, summary: 'Comportamiento muy parecido entre zonas urbanas y rurales.' },
  ],
  noncov_asg: [
    // Mujeres
    { sex: 'Mujeres', edu: 'Básica o menos (Prim)', current_delta: -0.005, current_lo: -0.180, current_hi: 0.170, sig_current: false, grams_delta: -0.03, grams_lo: -0.85, grams_hi: 0.79, sig_grams: false, hed_delta: -0.003, hed_lo: -0.060, hed_hi: 0.054, sig_hed: false, summary: 'Sin diferencia relevante fuera del marco ENPG.' },
    { sex: 'Mujeres', edu: 'Media (Sec)', current_delta: -0.195, current_lo: -0.340, current_hi: -0.050, sig_current: true, grams_delta: -1.05, grams_lo: -2.30, grams_hi: 0.20, sig_grams: false, hed_delta: -0.001, hed_lo: -0.065, hed_hi: 0.063, sig_hed: false, summary: 'Fuera del marco ENPG (rural + urbano fuera de comunas observadas) hay 19,5 pp menos de mujeres bebedoras.' },
    { sex: 'Mujeres', edu: 'Superior completa (Tert)', current_delta: -0.285, current_lo: -0.500, current_hi: -0.070, sig_current: true, grams_delta: -3.95, grams_lo: -6.80, grams_hi: -1.10, sig_grams: true, hed_delta: -0.118, hed_lo: -0.215, hed_hi: -0.021, sig_hed: true, summary: 'Fuera del marco ENPG beben muchísimo menos en los 3 indicadores.' },
    // Hombres
    { sex: 'Hombres', edu: 'Básica o menos (Prim)', current_delta: 0.092, current_lo: -0.110, current_hi: 0.294, sig_current: false, grams_delta: 2.35, grams_lo: -2.80, grams_hi: 7.50, sig_grams: false, hed_delta: 0.078, hed_lo: 0.008, hed_hi: 0.148, sig_hed: true, summary: 'Fuera del marco ENPG sube el consumo intenso episódico (HED) en +7,8 pp.' },
    { sex: 'Hombres', edu: 'Media (Sec)', current_delta: 0.008, current_lo: -0.140, current_hi: 0.156, sig_current: false, grams_delta: 1.32, grams_lo: -2.40, grams_hi: 5.04, sig_grams: false, hed_delta: 0.082, hed_lo: 0.014, hed_hi: 0.150, sig_hed: true, summary: 'Fuera del marco ENPG sube el HED en +8,2 pp.' },
    { sex: 'Hombres', edu: 'Superior completa (Tert)', current_delta: -0.068, current_lo: -0.310, current_hi: 0.174, sig_current: false, grams_delta: -0.15, grams_lo: -5.10, grams_hi: 4.80, sig_grams: false, hed_delta: -0.008, hed_lo: -0.125, hed_hi: 0.109, sig_hed: false, summary: 'Sin diferencias claras fuera del marco ENPG.' },
  ]
};

// Tabla 5: rg_T3_enpg_bias_cells.csv (24 celdas: 2 sexos x 4 edades x 3 niveles educativos)
const T3_CELLS = [
  // MUJERES - BÁSICA (Prim)
  {
    id: 'W_18-29_Prim', sex: 'Women', sexLabel: 'Mujeres', ageg: '18-29', edu: 'Prim', eduLabel: 'Básica o menos',
    n: 84, share_rural: 18.2, share_noncov: 31.5,
    mean_current: 0.310, mean_pop_grams: 1.15, mean_hed: 0.045,
    noncov: {
      current: { val: 0.5, lo: -17.2, hi: 18.2, str: '+0.5% [-17.2, +18.2]', sig: false },
      grams: { val: 0.8, lo: -21.5, hi: 23.1, str: '+0.8% [-21.5, +23.1]', sig: false },
      hed: { val: 2.1, lo: -38.0, hi: 42.2, str: '+2.1% [-38.0, +42.2]', sig: false }
    },
    rural: {
      current: { val: 0.5, lo: -13.8, hi: 14.8, str: '+0.5% [-13.8, +14.8]', sig: false },
      grams: { val: 0.8, lo: -16.6, hi: 18.2, str: '+0.8% [-16.6, +18.2]', sig: false },
      hed: { val: 1.6, lo: -29.1, hi: 32.3, str: '+1.6% [-29.1, +32.3]', sig: false }
    }
  },
  {
    id: 'W_30-44_Prim', sex: 'Women', sexLabel: 'Mujeres', ageg: '30-44', edu: 'Prim', eduLabel: 'Básica o menos',
    n: 162, share_rural: 19.5, share_noncov: 33.4,
    mean_current: 0.285, mean_pop_grams: 0.95, mean_hed: 0.038,
    noncov: {
      current: { val: 0.6, lo: -19.9, hi: 21.1, str: '+0.6% [-19.9, +21.1]', sig: false },
      grams: { val: 1.1, lo: -27.8, hi: 30.0, str: '+1.1% [-27.8, +30.0]', sig: false },
      hed: { val: 2.6, lo: -47.5, hi: 52.7, str: '+2.6% [-47.5, +52.7]', sig: false }
    },
    rural: {
      current: { val: 0.5, lo: -16.0, hi: 17.1, str: '+0.5% [-16.0, +17.1]', sig: false },
      grams: { val: 1.0, lo: -20.5, hi: 22.6, str: '+1.0% [-20.5, +22.6]', sig: false },
      hed: { val: 2.1, lo: -36.9, hi: 41.1, str: '+2.1% [-36.9, +41.1]', sig: false }
    }
  },
  {
    id: 'W_45-59_Prim', sex: 'Women', sexLabel: 'Mujeres', ageg: '45-59', edu: 'Prim', eduLabel: 'Básica o menos',
    n: 418, share_rural: 20.8, share_noncov: 35.2,
    mean_current: 0.242, mean_pop_grams: 0.72, mean_hed: 0.025,
    noncov: {
      current: { val: 0.7, lo: -24.7, hi: 26.2, str: '+0.7% [-24.7, +26.2]', sig: false },
      grams: { val: 1.5, lo: -38.6, hi: 41.6, str: '+1.5% [-38.6, +41.6]', sig: false },
      hed: { val: 4.2, lo: -76.0, hi: 84.5, str: '+4.2% [-76.0, +84.5]', sig: false }
    },
    rural: {
      current: { val: 0.7, lo: -20.1, hi: 21.5, str: '+0.7% [-20.1, +21.5]', sig: false },
      grams: { val: 1.4, lo: -28.9, hi: 31.8, str: '+1.4% [-28.9, +31.8]', sig: false },
      hed: { val: 3.3, lo: -59.9, hi: 66.6, str: '+3.3% [-59.9, +66.6]', sig: false }
    }
  },
  {
    id: 'W_60-65_Prim', sex: 'Women', sexLabel: 'Mujeres', ageg: '60-65', edu: 'Prim', eduLabel: 'Básica o menos',
    n: 265, share_rural: 22.1, share_noncov: 36.8,
    mean_current: 0.195, mean_pop_grams: 0.48, mean_hed: 0.012,
    noncov: {
      current: { val: 0.9, lo: -32.1, hi: 34.0, str: '+0.9% [-32.1, +34.0]', sig: false },
      grams: { val: 2.3, lo: -60.6, hi: 65.2, str: '+2.3% [-60.6, +65.2]', sig: false },
      hed: { val: 9.2, lo: -165.0, hi: 183.4, str: '+9.2% [-165.0, +183.4]', sig: false }
    },
    rural: {
      current: { val: 0.9, lo: -26.5, hi: 28.3, str: '+0.9% [-26.5, +28.3]', sig: false },
      grams: { val: 2.3, lo: -46.0, hi: 50.6, str: '+2.3% [-46.0, +50.6]', sig: false },
      hed: { val: 7.4, lo: -132.6, hi: 147.3, str: '+7.4% [-132.6, +147.3]', sig: false }
    }
  },

  // MUJERES - MEDIA (Sec)
  {
    id: 'W_18-29_Sec', sex: 'Women', sexLabel: 'Mujeres', ageg: '18-29', edu: 'Sec', eduLabel: 'Media',
    n: 612, share_rural: 11.4, share_noncov: 22.8,
    mean_current: 0.565, mean_pop_grams: 3.85, mean_hed: 0.112,
    noncov: {
      current: { val: 7.9, lo: 2.0, hi: 13.7, str: '+7.9% [+2.0, +13.7]', sig: true },
      grams: { val: 6.2, lo: -1.2, hi: 13.6, str: '+6.2% [-1.2, +13.6]', sig: false },
      hed: { val: 0.2, lo: -12.8, hi: 13.2, str: '+0.2% [-12.8, +13.2]', sig: false }
    },
    rural: {
      current: { val: 4.9, lo: 0.8, hi: 8.9, str: '+4.9% [+0.8, +8.9]', sig: true },
      grams: { val: 3.7, lo: -1.2, hi: 8.6, str: '+3.7% [-1.2, +8.6]', sig: false },
      hed: { val: 0.2, lo: -8.2, hi: 8.7, str: '+0.2% [-8.2, +8.7]', sig: false }
    }
  },
  {
    id: 'W_30-44_Sec', sex: 'Women', sexLabel: 'Mujeres', ageg: '30-44', edu: 'Sec', eduLabel: 'Media',
    n: 845, share_rural: 11.8, share_noncov: 23.5,
    mean_current: 0.610, mean_pop_grams: 4.20, mean_hed: 0.098,
    noncov: {
      current: { val: 7.5, lo: 1.9, hi: 13.1, str: '+7.5% [+1.9, +13.1]', sig: true },
      grams: { val: 5.9, lo: -1.1, hi: 12.9, str: '+5.9% [-1.1, +12.9]', sig: false },
      hed: { val: 0.2, lo: -15.1, hi: 15.6, str: '+0.2% [-15.1, +15.6]', sig: false }
    },
    rural: {
      current: { val: 4.7, lo: 0.8, hi: 8.5, str: '+4.7% [+0.8, +8.5]', sig: true },
      grams: { val: 3.5, lo: -1.1, hi: 8.1, str: '+3.5% [-1.1, +8.1]', sig: false },
      hed: { val: 0.2, lo: -9.8, hi: 10.2, str: '+0.2% [-9.8, +10.2]', sig: false }
    }
  },
  {
    id: 'W_45-59_Sec', sex: 'Women', sexLabel: 'Mujeres', ageg: '45-59', edu: 'Sec', eduLabel: 'Media',
    n: 790, share_rural: 12.1, share_noncov: 24.1,
    mean_current: 0.520, mean_pop_grams: 3.10, mean_hed: 0.065,
    noncov: {
      current: { val: 9.0, lo: 2.3, hi: 15.8, str: '+9.0% [+2.3, +15.8]', sig: true },
      grams: { val: 8.2, lo: -1.6, hi: 17.9, str: '+8.2% [-1.6, +17.9]', sig: false },
      hed: { val: 0.4, lo: -23.4, hi: 24.1, str: '+0.4% [-23.4, +24.1]', sig: false }
    },
    rural: {
      current: { val: 5.6, lo: 1.0, hi: 10.2, str: '+5.6% [+1.0, +10.2]', sig: true },
      grams: { val: 4.9, lo: -1.6, hi: 11.3, str: '+4.9% [-1.6, +11.3]', sig: false },
      hed: { val: 0.4, lo: -15.1, hi: 15.8, str: '+0.4% [-15.1, +15.8]', sig: false }
    }
  },
  {
    id: 'W_60-65_Sec', sex: 'Women', sexLabel: 'Mujeres', ageg: '60-65', edu: 'Sec', eduLabel: 'Media',
    n: 245, share_rural: 11.5, share_noncov: 23.0,
    mean_current: 0.495, mean_pop_grams: 2.65, mean_hed: 0.042,
    noncov: {
      current: { val: 9.1, lo: 2.3, hi: 15.8, str: '+9.1% [+2.3, +15.8]', sig: true },
      grams: { val: 9.1, lo: -1.7, hi: 20.0, str: '+9.1% [-1.7, +20.0]', sig: false },
      hed: { val: 0.5, lo: -34.5, hi: 35.6, str: '+0.5% [-34.5, +35.6]', sig: false }
    },
    rural: {
      current: { val: 5.6, lo: 1.0, hi: 10.2, str: '+5.6% [+1.0, +10.2]', sig: true },
      grams: { val: 5.4, lo: -1.7, hi: 12.6, str: '+5.4% [-1.7, +12.6]', sig: false },
      hed: { val: 0.5, lo: -22.2, hi: 23.3, str: '+0.5% [-22.2, +23.3]', sig: false }
    }
  },

  // MUJERES - SUPERIOR COMPLETA (Tert)
  {
    id: 'W_18-29_Tert', sex: 'Women', sexLabel: 'Mujeres', ageg: '18-29', edu: 'Tert', eduLabel: 'Superior completa',
    n: 320, share_rural: 8.2, share_noncov: 16.5,
    mean_current: 0.720, mean_pop_grams: 5.40, mean_hed: 0.135,
    noncov: {
      current: { val: 6.5, lo: 1.6, hi: 11.5, str: '+6.5% [+1.6, +11.5]', sig: true },
      grams: { val: 12.1, lo: 3.4, hi: 20.8, str: '+12.1% [+3.4, +20.8]', sig: true },
      hed: { val: 14.4, lo: 2.6, hi: 26.3, str: '+14.4% [+2.6, +26.3]', sig: true }
    },
    rural: {
      current: { val: 4.0, lo: 0.9, hi: 7.1, str: '+4.0% [+0.9, +7.1]', sig: true },
      grams: { val: 7.2, lo: 1.9, hi: 12.6, str: '+7.2% [+1.9, +12.6]', sig: true },
      hed: { val: 8.6, lo: 1.5, hi: 15.8, str: '+8.6% [+1.5, +15.8]', sig: true }
    }
  },
  {
    id: 'W_30-44_Tert', sex: 'Women', sexLabel: 'Mujeres', ageg: '30-44', edu: 'Tert', eduLabel: 'Superior completa',
    n: 540, share_rural: 8.5, share_noncov: 17.2,
    mean_current: 0.745, mean_pop_grams: 5.65, mean_hed: 0.128,
    noncov: {
      current: { val: 6.6, lo: 1.6, hi: 11.5, str: '+6.6% [+1.6, +11.5]', sig: true },
      grams: { val: 12.0, lo: 3.3, hi: 20.7, str: '+12.0% [+3.3, +20.7]', sig: true },
      hed: { val: 15.9, lo: 2.8, hi: 28.9, str: '+15.9% [+2.8, +28.9]', sig: true }
    },
    rural: {
      current: { val: 4.0, lo: 0.9, hi: 7.1, str: '+4.0% [+0.9, +7.1]', sig: true },
      grams: { val: 7.2, lo: 1.8, hi: 12.5, str: '+7.2% [+1.8, +12.5]', sig: true },
      hed: { val: 9.4, lo: 1.6, hi: 17.3, str: '+9.4% [+1.6, +17.3]', sig: true }
    }
  },
  {
    id: 'W_45-59_Tert', sex: 'Women', sexLabel: 'Mujeres', ageg: '45-59', edu: 'Tert', eduLabel: 'Superior completa',
    n: 285, share_rural: 8.8, share_noncov: 17.8,
    mean_current: 0.640, mean_pop_grams: 4.40, mean_hed: 0.122,
    noncov: {
      current: { val: 7.9, lo: 1.9, hi: 13.9, str: '+7.9% [+1.9, +13.9]', sig: true },
      grams: { val: 16.0, lo: 4.5, hi: 27.5, str: '+16.0% [+4.5, +27.5]', sig: true },
      hed: { val: 17.2, lo: 3.1, hi: 31.4, str: '+17.2% [+3.1, +31.4]', sig: true }
    },
    rural: {
      current: { val: 4.8, lo: 1.1, hi: 8.5, str: '+4.8% [+1.1, +8.5]', sig: true },
      grams: { val: 9.5, lo: 2.4, hi: 16.6, str: '+9.5% [+2.4, +16.6]', sig: true },
      hed: { val: 10.2, lo: 1.7, hi: 18.8, str: '+10.2% [+1.7, +18.8]', sig: true }
    }
  },
  {
    id: 'W_60-65_Tert', sex: 'Women', sexLabel: 'Mujeres', ageg: '60-65', edu: 'Tert', eduLabel: 'Superior completa',
    n: 68, share_rural: 8.0, share_noncov: 16.2,
    mean_current: 0.590, mean_pop_grams: 4.10, mean_hed: 0.000,
    noncov: {
      current: { val: 7.8, lo: 1.9, hi: 13.7, str: '+7.8% [+1.9, +13.7]', sig: true },
      grams: { val: 15.6, lo: 4.3, hi: 26.9, str: '+15.6% [+4.3, +26.9]', sig: true },
      hed: { val: null, lo: null, hi: null, str: '+Inf [media EPS = 0]', sig: false, isInf: true }
    },
    rural: {
      current: { val: 4.7, lo: 1.1, hi: 8.4, str: '+4.7% [+1.1, +8.4]', sig: true },
      grams: { val: 9.5, lo: 2.4, hi: 16.6, str: '+9.5% [+2.4, +16.6]', sig: true },
      hed: { val: null, lo: null, hi: null, str: '+Inf [media EPS = 0]', sig: false, isInf: true }
    }
  },

  // HOMBRES - BÁSICA (Prim)
  {
    id: 'M_18-29_Prim', sex: 'Men', sexLabel: 'Hombres', ageg: '18-29', edu: 'Prim', eduLabel: 'Básica o menos',
    n: 92, share_rural: 19.0, share_noncov: 32.8,
    mean_current: 0.580, mean_pop_grams: 9.20, mean_hed: 0.170,
    noncov: {
      current: { val: -5.2, lo: -16.6, hi: 6.2, str: '-5.2% [-16.6, +6.2]', sig: false },
      grams: { val: -8.4, lo: -26.7, hi: 10.0, str: '-8.4% [-26.7, +10.0]', sig: false },
      hed: { val: -15.0, lo: -28.6, hi: -1.5, str: '-15.0% [-28.6, -1.5]', sig: true }
    },
    rural: {
      current: { val: -3.8, lo: -12.1, hi: 4.6, str: '-3.8% [-12.1, +4.6]', sig: false },
      grams: { val: -5.9, lo: -19.1, hi: 7.2, str: '-5.9% [-19.1, +7.2]', sig: false },
      hed: { val: -10.1, lo: -19.6, hi: -0.6, str: '-10.1% [-19.6, -0.6]', sig: true }
    }
  },
  {
    id: 'M_30-44_Prim', sex: 'Men', sexLabel: 'Hombres', ageg: '30-44', edu: 'Prim', eduLabel: 'Básica o menos',
    n: 175, share_rural: 20.5, share_noncov: 34.5,
    mean_current: 0.610, mean_pop_grams: 8.50, mean_hed: 0.155,
    noncov: {
      current: { val: -5.2, lo: -16.6, hi: 6.2, str: '-5.2% [-16.6, +6.2]', sig: false },
      grams: { val: -9.5, lo: -30.4, hi: 11.4, str: '-9.5% [-30.4, +11.4]', sig: false },
      hed: { val: -17.4, lo: -32.9, hi: -1.8, str: '-17.4% [-32.9, -1.8]', sig: true }
    },
    rural: {
      current: { val: -3.9, lo: -12.4, hi: 4.7, str: '-3.9% [-12.4, +4.7]', sig: false },
      grams: { val: -6.9, lo: -22.3, hi: 8.4, str: '-6.9% [-22.3, +8.4]', sig: false },
      hed: { val: -11.9, lo: -23.1, hi: -0.7, str: '-11.9% [-23.1, -0.7]', sig: true }
    }
  },
  {
    id: 'M_45-59_Prim', sex: 'Men', sexLabel: 'Hombres', ageg: '45-59', edu: 'Prim', eduLabel: 'Básica o menos',
    n: 390, share_rural: 21.8, share_noncov: 36.2,
    mean_current: 0.560, mean_pop_grams: 6.80, mean_hed: 0.125,
    noncov: {
      current: { val: -5.9, lo: -19.0, hi: 7.1, str: '-5.9% [-19.0, +7.1]', sig: false },
      grams: { val: -12.5, lo: -39.9, hi: 14.9, str: '-12.5% [-39.9, +14.9]', sig: false },
      hed: { val: -22.6, lo: -42.9, hi: -2.3, str: '-22.6% [-42.9, -2.3]', sig: true }
    },
    rural: {
      current: { val: -4.5, lo: -14.4, hi: 5.5, str: '-4.5% [-14.4, +5.5]', sig: false },
      grams: { val: -9.2, lo: -29.6, hi: 11.2, str: '-9.2% [-29.6, +11.2]', sig: false },
      hed: { val: -15.7, lo: -30.5, hi: -0.9, str: '-15.7% [-30.5, -0.9]', sig: true }
    }
  },
  {
    id: 'M_60-65_Prim', sex: 'Men', sexLabel: 'Hombres', ageg: '60-65', edu: 'Prim', eduLabel: 'Básica o menos',
    n: 240, share_rural: 23.0, share_noncov: 37.5,
    mean_current: 0.540, mean_pop_grams: 5.50, mean_hed: 0.098,
    noncov: {
      current: { val: -6.4, lo: -20.4, hi: 7.6, str: '-6.4% [-20.4, +7.6]', sig: false },
      grams: { val: -16.0, lo: -51.1, hi: 19.1, str: '-16.0% [-51.1, +19.1]', sig: false },
      hed: { val: -29.8, lo: -56.6, hi: -3.1, str: '-29.8% [-56.6, -3.1]', sig: true }
    },
    rural: {
      current: { val: -4.9, lo: -15.8, hi: 6.0, str: '-4.9% [-15.8, +6.0]', sig: false },
      grams: { val: -12.0, lo: -38.6, hi: 14.6, str: '-12.0% [-38.6, +14.6]', sig: false },
      hed: { val: -21.1, lo: -41.1, hi: -1.2, str: '-21.1% [-41.1, -1.2]', sig: true }
    }
  },

  // HOMBRES - MEDIA (Sec)
  {
    id: 'M_18-29_Sec', sex: 'Men', sexLabel: 'Hombres', ageg: '18-29', edu: 'Sec', eduLabel: 'Media',
    n: 590, share_rural: 11.8, share_noncov: 23.2,
    mean_current: 0.710, mean_pop_grams: 7.20, mean_hed: 0.190,
    noncov: {
      current: { val: -0.3, lo: -5.1, hi: 4.6, str: '-0.3% [-5.1, +4.6]', sig: false },
      grams: { val: -4.3, lo: -16.2, hi: 7.7, str: '-4.3% [-16.2, +7.7]', sig: false },
      hed: { val: -10.0, lo: -18.3, hi: -1.7, str: '-10.0% [-18.3, -1.7]', sig: true }
    },
    rural: {
      current: { val: -0.2, lo: -3.4, hi: 3.0, str: '-0.2% [-3.4, +3.0]', sig: false },
      grams: { val: -2.7, lo: -10.5, hi: 5.1, str: '-2.7% [-10.5, +5.1]', sig: false },
      hed: { val: -6.1, lo: -11.6, hi: -0.7, str: '-6.1% [-11.6, -0.7]', sig: true }
    }
  },
  {
    id: 'M_30-44_Sec', sex: 'Men', sexLabel: 'Hombres', ageg: '30-44', edu: 'Sec', eduLabel: 'Media',
    n: 780, share_rural: 12.2, share_noncov: 24.0,
    mean_current: 0.740, mean_pop_grams: 6.80, mean_hed: 0.175,
    noncov: {
      current: { val: -0.3, lo: -5.1, hi: 4.5, str: '-0.3% [-5.1, +4.5]', sig: false },
      grams: { val: -4.7, lo: -17.8, hi: 8.5, str: '-4.7% [-17.8, +8.5]', sig: false },
      hed: { val: -11.2, lo: -20.6, hi: -1.9, str: '-11.2% [-20.6, -1.9]', sig: true }
    },
    rural: {
      current: { val: -0.2, lo: -3.4, hi: 3.0, str: '-0.2% [-3.4, +3.0]', sig: false },
      grams: { val: -3.0, lo: -11.5, hi: 5.6, str: '-3.0% [-11.5, +5.6]', sig: false },
      hed: { val: -6.9, lo: -13.0, hi: -0.8, str: '-6.9% [-13.0, -0.8]', sig: true }
    }
  },
  {
    id: 'M_45-59_Sec', sex: 'Men', sexLabel: 'Hombres', ageg: '45-59', edu: 'Sec', eduLabel: 'Media',
    n: 710, share_rural: 12.5, share_noncov: 24.5,
    mean_current: 0.690, mean_pop_grams: 6.40, mean_hed: 0.150,
    noncov: {
      current: { val: -0.3, lo: -5.5, hi: 5.0, str: '-0.3% [-5.5, +5.0]', sig: false },
      grams: { val: -5.1, lo: -19.3, hi: 9.2, str: '-5.1% [-19.3, +9.2]', sig: false },
      hed: { val: -13.4, lo: -24.5, hi: -2.3, str: '-13.4% [-24.5, -2.3]', sig: true }
    },
    rural: {
      current: { val: -0.2, lo: -3.7, hi: 3.3, str: '-0.2% [-3.7, +3.3]', sig: false },
      grams: { val: -3.2, lo: -12.5, hi: 6.1, str: '-3.2% [-12.5, +6.1]', sig: false },
      hed: { val: -8.3, lo: -15.5, hi: -1.0, str: '-8.3% [-15.5, -1.0]', sig: true }
    }
  },
  {
    id: 'M_60-65_Sec', sex: 'Men', sexLabel: 'Hombres', ageg: '60-65', edu: 'Sec', eduLabel: 'Media',
    n: 215, share_rural: 12.0, share_noncov: 23.8,
    mean_current: 0.650, mean_pop_grams: 5.90, mean_hed: 0.130,
    noncov: {
      current: { val: -0.3, lo: -5.7, hi: 5.1, str: '-0.3% [-5.7, +5.1]', sig: false },
      grams: { val: -5.3, lo: -20.3, hi: 9.7, str: '-5.3% [-20.3, +9.7]', sig: false },
      hed: { val: -15.0, lo: -27.5, hi: -2.6, str: '-15.0% [-27.5, -2.6]', sig: true }
    },
    rural: {
      current: { val: -0.2, lo: -3.8, hi: 3.3, str: '-0.2% [-3.8, +3.3]', sig: false },
      grams: { val: -3.4, lo: -13.0, hi: 6.3, str: '-3.4% [-13.0, +6.3]', sig: false },
      hed: { val: -9.1, lo: -17.2, hi: -1.1, str: '-9.1% [-17.2, -1.1]', sig: true }
    }
  },

  // HOMBRES - SUPERIOR COMPLETA (Tert)
  {
    id: 'M_18-29_Tert', sex: 'Men', sexLabel: 'Hombres', ageg: '18-29', edu: 'Tert', eduLabel: 'Superior completa',
    n: 290, share_rural: 8.5, share_noncov: 16.8,
    mean_current: 0.780, mean_pop_grams: 7.50, mean_hed: 0.185,
    noncov: {
      current: { val: 1.5, lo: -3.7, hi: 6.7, str: '+1.5% [-3.7, +6.7]', sig: false },
      grams: { val: 0.3, lo: -10.8, hi: 11.4, str: '+0.3% [-10.8, +11.4]', sig: false },
      hed: { val: 0.7, lo: -9.9, hi: 11.4, str: '+0.7% [-9.9, +11.4]', sig: false }
    },
    rural: {
      current: { val: 0.9, lo: -2.4, hi: 4.3, str: '+0.9% [-2.4, +4.3]', sig: false },
      grams: { val: 0.2, lo: -6.9, hi: 7.4, str: '+0.2% [-6.9, +7.4]', sig: false },
      hed: { val: 0.5, lo: -6.4, hi: 7.4, str: '+0.5% [-6.4, +7.4]', sig: false }
    }
  },
  {
    id: 'M_30-44_Tert', sex: 'Men', sexLabel: 'Hombres', ageg: '30-44', edu: 'Tert', eduLabel: 'Superior completa',
    n: 495, share_rural: 8.8, share_noncov: 17.5,
    mean_current: 0.810, mean_pop_grams: 8.10, mean_hed: 0.178,
    noncov: {
      current: { val: 1.5, lo: -3.8, hi: 6.7, str: '+1.5% [-3.8, +6.7]', sig: false },
      grams: { val: 0.3, lo: -10.4, hi: 11.0, str: '+0.3% [-10.4, +11.0]', sig: false },
      hed: { val: 0.8, lo: -10.7, hi: 12.3, str: '+0.8% [-10.7, +12.3]', sig: false }
    },
    rural: {
      current: { val: 0.9, lo: -2.4, hi: 4.2, str: '+0.9% [-2.4, +4.2]', sig: false },
      grams: { val: 0.2, lo: -6.6, hi: 7.1, str: '+0.2% [-6.6, +7.1]', sig: false },
      hed: { val: 0.5, lo: -6.9, hi: 7.9, str: '+0.5% [-6.9, +7.9]', sig: false }
    }
  },
  {
    id: 'M_45-59_Tert', sex: 'Men', sexLabel: 'Hombres', ageg: '45-59', edu: 'Tert', eduLabel: 'Superior completa',
    n: 260, share_rural: 9.0, share_noncov: 18.0,
    mean_current: 0.760, mean_pop_grams: 7.40, mean_hed: 0.145,
    noncov: {
      current: { val: 1.6, lo: -4.1, hi: 7.3, str: '+1.6% [-4.1, +7.3]', sig: false },
      grams: { val: 0.4, lo: -11.7, hi: 12.4, str: '+0.4% [-11.7, +12.4]', sig: false },
      hed: { val: 1.0, lo: -13.5, hi: 15.5, str: '+1.0% [-13.5, +15.5]', sig: false }
    },
    rural: {
      current: { val: 1.0, lo: -2.6, hi: 4.6, str: '+1.0% [-2.6, +4.6]', sig: false },
      grams: { val: 0.2, lo: -7.4, hi: 7.9, str: '+0.2% [-7.4, +7.9]', sig: false },
      hed: { val: 0.6, lo: -8.7, hi: 9.9, str: '+0.6% [-8.7, +9.9]', sig: false }
    }
  },
  {
    id: 'M_60-65_Tert', sex: 'Men', sexLabel: 'Hombres', ageg: '60-65', edu: 'Tert', eduLabel: 'Superior completa',
    n: 82, share_rural: 8.6, share_noncov: 17.2,
    mean_current: 0.720, mean_pop_grams: 6.80, mean_hed: 0.115,
    noncov: {
      current: { val: 1.6, lo: -4.2, hi: 7.4, str: '+1.6% [-4.2, +7.4]', sig: false },
      grams: { val: 0.4, lo: -12.1, hi: 12.9, str: '+0.4% [-12.1, +12.9]', sig: false },
      hed: { val: 1.2, lo: -16.3, hi: 18.7, str: '+1.2% [-16.3, +18.7]', sig: false }
    },
    rural: {
      current: { val: 1.0, lo: -2.6, hi: 4.7, str: '+1.0% [-2.6, +4.7]', sig: false },
      grams: { val: 0.3, lo: -7.7, hi: 8.2, str: '+0.3% [-7.7, +8.2]', sig: false },
      hed: { val: 0.7, lo: -10.5, hi: 12.0, str: '+0.7% [-10.5, +12.0]', sig: false }
    }
  }
];

export default function App() {
  const [activeTab, setActiveTab] = useState('tab1');

  // States for Tab 1
  const [selectedYear, setSelectedYear] = useState(2024);
  const [selectedGroupTab1, setSelectedGroupTab1] = useState('Total 15-65');

  // States for Tab 2
  const [t1Spec, setT1Spec] = useState('main'); // 'main' | 'no_fe' | 'all_waves'
  const [t2Exposure, setT2Exposure] = useState('noncov_asg'); // 'rural_asg' | 'noncov_asg'

  // States for Tab 3 (Bias Explorer)
  const [filterSex, setFilterSex] = useState('ALL'); // 'ALL' | 'Women' | 'Men'
  const [filterEdu, setFilterEdu] = useState('ALL'); // 'ALL' | 'Prim' | 'Sec' | 'Tert'
  const [filterAge, setFilterAge] = useState('ALL'); // 'ALL' | '18-29' | '30-44' | '45-59' | '60-65'
  const [biasExposure, setBiasExposure] = useState('noncov'); // 'noncov' | 'rural'

  // States for Tab 4 (All Waves Explorer)
  const [wavesSpecFilter, setWavesSpecFilter] = useState('rural_asg_FE'); // 'rural_asg_FE' | 'rural_asg_noFE' | 'rural_exp_FE' | 'noncov_asg_FE'
  const [matrixDisplayMode, setMatrixDisplayMode] = useState('pair'); // 'pair' | 'ratio' | 'diff'

  const currentYearData = COVERAGE_BY_YEAR[selectedYear];

  const filteredRatios = useMemo(() => {
    if (t1Spec === 'main') return T1_RATIOS.filter(r => r.waves === 'VIII' && r.region_FE === true);
    if (t1Spec === 'no_fe') return T1_RATIOS.filter(r => r.waves === 'VIII' && r.region_FE === false);
    return T1_RATIOS.filter(r => r.waves === 'ALL' && r.region_FE === true);
  }, [t1Spec]);

  const filteredCells = useMemo(() => {
    return T3_CELLS.filter(c => {
      if (filterSex !== 'ALL' && c.sex !== filterSex) return false;
      if (filterEdu !== 'ALL' && c.edu !== filterEdu) return false;
      if (filterAge !== 'ALL' && c.ageg !== filterAge) return false;
      return true;
    });
  }, [filterSex, filterEdu, filterAge]);

  // Helper to render bias badge and visual bar
  const renderBiasBar = (metricObj, label) => {
    if (metricObj.isInf) {
      return (
        <div className="p-2.5 rounded-lg bg-slate-100 border border-slate-200 text-xs flex flex-col justify-between">
          <div className="flex items-center justify-between font-medium text-slate-600 mb-1">
            <span>{label}</span>
            <span className="px-1.5 py-0.5 bg-amber-100 text-amber-800 rounded font-mono text-[11px]">+Inf</span>
          </div>
          <p className="text-[11px] text-slate-500">
            Prevalencia 0% en EPS para esta celda (n=68). No se puede dividir por cero.
          </p>
        </div>
      );
    }

    const val = metricObj.val;
    const isOver = val > 0;
    const isSig = metricObj.sig;

    // Clamp bar width up to 30% max for visual scale
    const pctWidth = Math.min(Math.abs(val) / 30 * 100, 100);

    let bgClass = 'bg-slate-50 border-slate-200';
    let badgeClass = 'bg-slate-200 text-slate-700';
    let barColor = 'bg-slate-400';

    if (isSig && isOver) {
      bgClass = 'bg-amber-50/80 border-amber-300 ring-1 ring-amber-200';
      badgeClass = 'bg-amber-600 text-white font-bold';
      barColor = 'bg-amber-500';
    } else if (isSig && !isOver) {
      bgClass = 'bg-teal-50/80 border-teal-300 ring-1 ring-teal-200';
      badgeClass = 'bg-teal-700 text-white font-bold';
      barColor = 'bg-teal-600';
    } else if (isOver) {
      barColor = 'bg-amber-300';
    } else {
      barColor = 'bg-teal-300';
    }

    return (
      <div className={`p-2.5 rounded-lg border transition-all ${bgClass}`}>
        <div className="flex items-center justify-between gap-1 mb-1.5">
          <span className="text-xs font-semibold text-slate-700">{label}</span>
          <span className={`px-2 py-0.5 rounded text-xs font-mono ${badgeClass}`}>
            {val > 0 ? `+${val.toFixed(1)}%` : `${val.toFixed(1)}%`}
            {isSig ? ' ★' : ' (ns)'}
          </span>
        </div>

        {/* Center-zero gauge bar */}
        <div className="relative h-2.5 bg-slate-200 rounded-full overflow-hidden my-1.5 flex items-center">
          <div className="absolute left-1/2 top-0 bottom-0 w-0.5 bg-slate-500 z-10" />
          {isOver ? (
            <div
              className={`h-full ${barColor} rounded-r-full`}
              style={{ marginLeft: '50%', width: `${pctWidth / 2}%` }}
            />
          ) : (
            <div
              className={`h-full ${barColor} rounded-l-full`}
              style={{ marginLeft: `${50 - pctWidth / 2}%`, width: `${pctWidth / 2}%` }}
            />
          )}
        </div>

        <div className="flex items-center justify-between text-[11px] text-slate-500 font-mono mt-1">
          <span>IC 95%: [{metricObj.lo > 0 ? `+${metricObj.lo}` : metricObj.lo}, {metricObj.hi > 0 ? `+${metricObj.hi}` : metricObj.hi}]</span>
          <span className="font-sans font-medium">
            {isSig ? (isOver ? 'Sobreestima' : 'Subestima') : 'Sin certeza'}
          </span>
        </div>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900 font-sans pb-16">
      {/* HEADER */}
      <header className="bg-slate-900 text-white border-b border-slate-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-indigo-500/20 text-indigo-300 text-xs font-semibold uppercase tracking-wider mb-2 border border-indigo-500/30">
                <Compass className="w-3.5 h-3.5" />
                Síntesis Metodológica • Octubre 2026
              </div>
              <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-white">
                Guía Interactiva: ¿Está sesgada la ENPG por excluir zonas rurales?
              </h1>
              <p className="mt-1.5 text-slate-300 text-sm sm:text-base max-w-3xl">
                Explicación «en fácil» de las 5 tablas exploratorias cruzando <strong>ENPG (SENDA)</strong>, proyecciones <strong>INE</strong> y la <strong>Encuesta de Protección Social (EPS)</strong>.
              </p>
            </div>

            {/* Veredicto rápido en el header */}
            <div className="bg-slate-800/90 border border-slate-700 rounded-xl p-4 max-w-md shrink-0">
              <div className="text-xs font-bold uppercase tracking-wider text-amber-400 mb-1 flex items-center gap-1.5">
                <CheckCircle2 className="w-4 h-4" />
                Respuesta Corta (El Veredicto)
              </div>
              <p className="text-xs sm:text-sm text-slate-200 leading-relaxed">
                <strong>Sí hay sesgo, y va en direcciones opuestas según sexo:</strong> la ENPG <span className="text-amber-300 font-semibold">sobreestima (+6% a +17%)</span> el consumo en mujeres de educación media/superior y <span className="text-teal-300 font-semibold">subestima (-10% a -30%)</span> las borracheras (HED) en hombres de educación básica/media.
              </p>
            </div>
          </div>

          {/* NAVIGATION TABS */}
          <div className="mt-6 flex flex-wrap gap-2 border-t border-slate-800 pt-4">
            {[
              { id: 'tab1', label: '1. El Punto Ciego (Tablas 1 y 2)', icon: EyeOff },
              { id: 'tab2', label: '2. ¿Se bebe distinto en lo rural? (Tablas 3 y 4)', icon: Wine },
              { id: 'tab3', label: '3. Explorador de Sesgo ENPG (Tabla 5)', icon: Sliders },
              { id: 'tab_waves', label: '4. ¿Se usaron todas las olas? (ENPG 12–24 y EPS VI–VIII)', icon: History },
              { id: 'tab4', label: '5. Guía de las 5 Tablas y Límites', icon: BookOpen },
            ].map(tab => {
              const Icon = tab.icon;
              const isActive = activeTab === tab.id;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center gap-2 px-4 py-2.5 rounded-lg text-sm font-medium transition-all ${
                    isActive
                      ? 'bg-indigo-600 text-white shadow-md shadow-indigo-950/50'
                      : 'bg-slate-800/70 text-slate-300 hover:bg-slate-800 hover:text-white'
                  }`}
                >
                  <Icon className="w-4 h-4" />
                  <span>{tab.label}</span>
                </button>
              );
            })}
          </div>
        </div>
      </header>

      {/* MAIN CONTENT */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-8">
        {/* ==========================================
            TAB 1: EL PUNTO CIEGO (TABLAS 1 Y 2)
           ========================================== */}
        {activeTab === 'tab1' && (
          <div className="space-y-8">
            {/* Explicación conceptual en fácil */}
            <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
              <div className="max-w-3xl">
                <h2 className="text-xl font-bold text-slate-900 flex items-center gap-2">
                  <MapPin className="w-5 h-5 text-indigo-600" />
                  ¿Cuál es el «punto ciego» del diseño muestral de la ENPG?
                </h2>
                <p className="mt-2 text-slate-600 text-sm sm:text-base leading-relaxed">
                  El informe ENPG 2024 define áreas urbanas de 109 comunas. Usamos las 109 comunas observadas como aproximación al marco y las proyecciones INE base 2017 para <strong>2024, edades 15–64</strong>. No todas las comunas ausentes tienen menos de 30.000 habitantes. Separamos dos componentes sin solapamiento:
                </p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
                <div className="p-4 rounded-xl bg-indigo-50/70 border border-indigo-200">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold uppercase tracking-wider text-indigo-700">Cobertura geográfica aproximada</span>
                    <span className="text-lg font-extrabold text-indigo-900">78,05% (15–64)</span>
                  </div>
                  <p className="mt-2 text-sm text-indigo-950 font-medium">
                    10.630.379 personas urbanas en las 109 comunas observadas
                  </p>
                  <p className="mt-1 text-xs text-indigo-700">
                    Ej: Santiago, Concepción, Antofagasta, o la parte urbana de Melipilla y Ovalle.
                  </p>
                </div>

                <div className="p-4 rounded-xl bg-amber-50/70 border border-amber-200">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold uppercase tracking-wider text-amber-800">A: Comunas no observadas</span>
                    <span className="text-lg font-extrabold text-amber-900">17,62% (15–64)</span>
                  </div>
                  <p className="mt-2 text-sm text-amber-950 font-medium">
                    2.399.620 personas urbanas y rurales en las otras 237 comunas
                  </p>
                  <p className="mt-1 text-xs text-amber-800">
                    Se consideran fuera en esta aproximación; la lista observada no sustituye un listado oficial del marco.
                  </p>
                </div>

                <div className="p-4 rounded-xl bg-rose-50/70 border border-rose-200">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold uppercase tracking-wider text-rose-800">B: Rural dentro de la lista</span>
                    <span className="text-lg font-extrabold text-rose-900">4,33% (15–64)</span>
                  </div>
                  <p className="mt-2 text-sm text-rose-950 font-medium">
                    589.166 personas rurales en las 109 comunas observadas
                  </p>
                  <p className="mt-1 text-xs text-rose-800">
                    El rural de las otras 237 comunas ya está en A. Sobre 13.619.165 personas de 15–64 años, <strong>A + B = 21,95% excluido provisional</strong>; coincide con 100 × (1 − población urbana cubierta / total).
                  </p>
                </div>
              </div>
            </div>

            <p className="text-sm text-slate-600">
              Cálculo fijo de 2024, independiente del selector histórico. La lista observada de 2022 da también 21,95%;
              el escenario hipotético de 135 comunas con ≥30.000 habitantes en 2024 da 18,62% y no reproduce el marco ENPG.
              No se cuantifican exclusiones de UPM especiales dentro del área urbana. No es un porcentaje de todas las edades
              ni una medida de pobreza, consumo o sesgo en alcohol. Sin intervalo de confianza artificial.
              Registro: README_enpg_geographic_coverage_2024.md; tabla: enpg_geographic_coverage_2024.csv.
            </p>

            {/* Selector Interactivo de Año (Tablas 1 y 2) */}
            <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 pb-6 border-b border-slate-100">
                <div>
                  <span className="text-xs font-bold uppercase tracking-wider text-indigo-600">
                    Explorador Histórico • Tablas 1 y 2
                  </span>
                  <h3 className="text-lg font-bold text-slate-900 mt-0.5">
                    Cobertura comunal de la ENPG vs. Realidad INE ({selectedYear})
                  </h3>
                </div>

                {/* Botones de año */}
                <div className="flex items-center gap-1.5 bg-slate-100 p-1.5 rounded-xl flex-wrap">
                  {Object.keys(COVERAGE_BY_YEAR).map(yr => (
                    <button
                      key={yr}
                      onClick={() => setSelectedYear(Number(yr))}
                      className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
                        selectedYear === Number(yr)
                          ? 'bg-indigo-600 text-white shadow-sm'
                          : 'text-slate-600 hover:bg-white'
                      }`}
                    >
                      {yr}
                    </button>
                  ))}
                </div>
              </div>

              <p className="mt-4 text-sm text-slate-600">
                Estimación provisional de {selectedYear}, edades 15–64: <strong>{currentYearData.excluded_pct.toFixed(2)}% excluido</strong>.
                A = {currentYearData.component_A.toLocaleString('es-CL')} personas fuera de las comunas observadas;
                B = {currentYearData.component_B.toLocaleString('es-CL')} rurales dentro de ellas.
                Población urbana cubierta: {currentYearData.population_covered.toLocaleString('es-CL')};
                total nacional: {currentYearData.population_total.toLocaleString('es-CL')}.
                Se usa la población INE del mismo año. Las comunas observadas aproximan el marco; A y B no se solapan.
              </p>

              {/* Métricas de `enpg_rural_coverage.csv` */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mt-6">
                <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
                  <div className="text-xs text-slate-500 font-medium">Comunas en muestra (`comunas_enpg`)</div>
                  <div className="mt-1 flex items-baseline gap-2">
                    <span className="text-2xl font-extrabold text-slate-900">{currentYearData.comunas_enpg}</span>
                    <span className="text-xs text-slate-500">de {currentYearData.comunas_total} comunas</span>
                  </div>
                  <div className="mt-2 w-full bg-slate-200 h-2 rounded-full overflow-hidden">
                    <div
                      className="bg-indigo-600 h-full"
                      style={{ width: `${(currentYearData.comunas_enpg / currentYearData.comunas_total) * 100}%` }}
                    />
                  </div>
                  <p className="mt-1.5 text-[11px] text-slate-500">
                    Solo el {((currentYearData.comunas_enpg / currentYearData.comunas_total) * 100).toFixed(1)}% de los municipios tiene encuestados.
                  </p>
                </div>

                <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
                  <div className="text-xs text-slate-500 font-medium">Población en comunas ENPG (`pct_pop...`)</div>
                  <div className="mt-1 flex items-baseline gap-2">
                    <span className="text-2xl font-extrabold text-indigo-600">{currentYearData.pct_pop_in_enpg_comunas}%</span>
                    <span className="text-xs text-slate-500">pob. 15–64 años</span>
                  </div>
                  <div className="mt-2 w-full bg-slate-200 h-2 rounded-full overflow-hidden">
                    <div
                      className="bg-indigo-600 h-full"
                      style={{ width: `${currentYearData.pct_pop_in_enpg_comunas}%` }}
                    />
                  </div>
                  <p className="mt-1.5 text-[11px] text-slate-500">
                    Esas comunas concentran {currentYearData.pct_pop_in_enpg_comunas}% de la población de 15–64 años, sumando áreas urbanas y rurales.
                  </p>
                </div>

                <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
                  <div className="text-xs text-slate-500 font-medium">Pob. rural en comunas ENPG (`pct_rural...`)</div>
                  <div className="mt-1 flex items-baseline gap-2">
                    <span className="text-2xl font-extrabold text-amber-600">{currentYearData.pct_rural_pop_in_enpg_comunas}%</span>
                    <span className="text-xs text-slate-500">del total rural</span>
                  </div>
                  <div className="mt-2 w-full bg-slate-200 h-2 rounded-full overflow-hidden">
                    <div
                      className="bg-amber-500 h-full"
                      style={{ width: `${currentYearData.pct_rural_pop_in_enpg_comunas}%` }}
                    />
                  </div>
                  <p className="mt-1.5 text-[11px] text-slate-500">
                    El {(100 - currentYearData.pct_rural_pop_in_enpg_comunas).toFixed(1)}% de la población rural de 15–64 vive fuera de las comunas observadas.
                  </p>
                </div>

                <div className="p-4 rounded-xl bg-slate-50 border border-slate-200">
                  <div className="text-xs text-slate-500 font-medium">Peso en comunas 0% rurales (`...comunas_r0`)</div>
                  <div className="mt-1 flex items-baseline gap-2">
                    <span className="text-2xl font-extrabold text-slate-800">{currentYearData.enpg_pct_weight_comunas_r0}%</span>
                    <span className="text-xs text-slate-500">del peso ENPG</span>
                  </div>
                  <div className="mt-2 w-full bg-slate-200 h-2 rounded-full overflow-hidden">
                    <div
                      className="bg-slate-700 h-full"
                      style={{ width: `${currentYearData.enpg_pct_weight_comunas_r0}%` }}
                    />
                  </div>
                  <p className="mt-1.5 text-[11px] text-slate-500">
                    Casi un tercio de la muestra vive en comunas 100% urbanas (ej. Providencia, Ñuñoa).
                  </p>
                </div>
              </div>

              {/* Comparación Tabla 2: enpg_rural_bias.csv */}
              <div className="mt-8 grid grid-cols-1 lg:grid-cols-12 gap-6 items-center bg-slate-50 p-5 rounded-xl border border-slate-200">
                <div className="lg:col-span-5 space-y-3">
                  <div className="inline-flex items-center gap-1.5 text-xs font-bold text-indigo-700 bg-indigo-100 px-2.5 py-1 rounded-md">
                    Tabla 2: `enpg_rural_bias.csv`
                  </div>
                  <h4 className="text-base font-bold text-slate-900">
                    ¿Qué tan rurales son las comunas que «ve» la ENPG comparado con el país real?
                  </h4>
                  <p className="text-xs sm:text-sm text-slate-600 leading-relaxed">
                    Si a cada encuestado le asignamos el <strong>% de ruralidad de su comuna</strong> según el INE, una persona promedio en Chile vive en una comuna con <strong>{currentYearData.byGroup[selectedGroupTab1].ine}%</strong> de población rural. Pero en la ENPG ese promedio cae a <strong>{currentYearData.byGroup[selectedGroupTab1].enpg}%</strong>.
                  </p>

                  <div>
                    <label className="block text-xs font-semibold text-slate-700 mb-1">
                      Filtrar grupo demográfico (Sexo × Edad):
                    </label>
                    <select
                      value={selectedGroupTab1}
                      onChange={e => setSelectedGroupTab1(e.target.value)}
                      className="w-full sm:w-64 rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm font-medium text-slate-800 shadow-sm focus:border-indigo-500 focus:outline-none"
                    >
                      {Object.keys(currentYearData.byGroup).map(g => (
                        <option key={g} value={g}>{g}</option>
                      ))}
                    </select>
                  </div>
                </div>

                <div className="lg:col-span-7 space-y-4 bg-white p-5 rounded-xl border border-slate-200">
                  <div className="flex items-center justify-between text-xs font-semibold text-slate-500 uppercase">
                    <span>Grupo: {selectedGroupTab1} ({selectedYear})</span>
                    <span>Razón ENPG / INE (`ratio_mean`): <strong className="text-indigo-600 text-sm">{currentYearData.byGroup[selectedGroupTab1].ratio.toFixed(2)}x</strong></span>
                  </div>

                  {/* Barra INE */}
                  <div>
                    <div className="flex justify-between text-sm font-medium mb-1">
                      <span className="text-slate-700">Promedio Real País (`pop_mean` INE)</span>
                      <span className="font-bold text-slate-900">{currentYearData.byGroup[selectedGroupTab1].ine}% ruralidad comunal</span>
                    </div>
                    <div className="w-full bg-slate-100 h-5 rounded-lg overflow-hidden border border-slate-200">
                      <div
                        className="bg-teal-600 h-full transition-all duration-300"
                        style={{ width: `${(currentYearData.byGroup[selectedGroupTab1].ine / 16) * 100}%` }}
                      />
                    </div>
                  </div>

                  {/* Barra ENPG */}
                  <div>
                    <div className="flex justify-between text-sm font-medium mb-1">
                      <span className="text-slate-700">Promedio Muestra ENPG (`enpg_mean`)</span>
                      <span className="font-bold text-indigo-600">{currentYearData.byGroup[selectedGroupTab1].enpg}% ruralidad comunal</span>
                    </div>
                    <div className="w-full bg-slate-100 h-5 rounded-lg overflow-hidden border border-slate-200">
                      <div
                        className="bg-indigo-600 h-full transition-all duration-300"
                        style={{ width: `${(currentYearData.byGroup[selectedGroupTab1].enpg / 16) * 100}%` }}
                      />
                    </div>
                  </div>

                  <p className="text-xs text-slate-500 pt-1">
                    <strong>Nota técnica:</strong> Se usa el promedio (`mean`) y no la mediana (`median`) porque la distribución está muy cargada a 0% (las medianas dan ~1% en ENPG y ~2% en INE y casi no discriminan).
                  </p>
                </div>
              </div>

              {/* Takeaway Box: Por qué esto es un PISO */}
              <div className="mt-6 bg-amber-50 border-l-4 border-amber-500 p-4 rounded-r-xl flex items-start gap-3">
                <AlertTriangle className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
                <div className="text-xs sm:text-sm text-amber-950 leading-relaxed">
                  <strong>El cociente ~0,39 no es un porcentaje de exclusión ni un piso del sesgo en alcohol.</strong> Compara promedios de ruralidad comunal. La exclusión geográfica se calcula por separado con A + B. La comparación histórica usa ENPG 15–65 frente a INE 15–64; no debe confundirse con el cálculo demográfico homogéneo de 2024.
                </div>
              </div>
            </div>
          </div>
        )}

        {/* ==========================================
            TAB 2: ¿SE BEBE DISTINTO EN LO RURAL? (TABLAS 3 Y 4)
           ========================================== */}
        {activeTab === 'tab2' && (
          <div className="space-y-8">
            {/* Explicación de la estrategia con la EPS y por qué el promedio nacional engaña */}
            <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
                <div className="lg:col-span-7">
                  <span className="text-xs font-bold uppercase tracking-wider text-indigo-600">
                    Tabla 3: `rg_T1_ratios.csv` • Resumen Nacional EPS
                  </span>
                  <h2 className="text-xl font-bold text-slate-900 mt-1">
                    ¿Por qué el promedio nacional rural vs. urbano parece «no significativo»?
                  </h2>
                  <p className="mt-2 text-sm text-slate-600 leading-relaxed">
                    Como la ENPG no tiene zonas rurales, usamos la <strong>Encuesta de Protección Social (EPS, Ronda VIII 2023/24)</strong> que sí visita zonas rurales. Comparamos áreas de muestreo más rurales vs. más urbanas <strong>dentro de cada celda de sexo × edad × educación</strong> y controlando por región (`region_FE = TRUE`) para no confundir «ruralidad» con regiones donde culturalmente se bebe más.
                  </p>

                  {/* Selector de especificación */}
                  <div className="mt-4 flex flex-wrap gap-2">
                    <button
                      onClick={() => setT1Spec('main')}
                      className={`px-3 py-1.5 rounded-lg text-xs font-semibold border transition-all ${
                        t1Spec === 'main'
                          ? 'bg-indigo-600 text-white border-indigo-600'
                          : 'bg-slate-50 text-slate-700 border-slate-300 hover:bg-slate-100'
                      }`}
                    >
                      Principal: Ronda VIII + Control Región (`region_FE=TRUE`)
                    </button>
                    <button
                      onClick={() => setT1Spec('no_fe')}
                      className={`px-3 py-1.5 rounded-lg text-xs font-semibold border transition-all ${
                        t1Spec === 'no_fe'
                          ? 'bg-indigo-600 text-white border-indigo-600'
                          : 'bg-slate-50 text-slate-700 border-slate-300 hover:bg-slate-100'
                      }`}
                    >
                      Sin control regional (`region_FE=FALSE`)
                    </button>
                    <button
                      onClick={() => setT1Spec('all_waves')}
                      className={`px-3 py-1.5 rounded-lg text-xs font-semibold border transition-all ${
                        t1Spec === 'all_waves'
                          ? 'bg-indigo-600 text-white border-indigo-600'
                          : 'bg-slate-50 text-slate-700 border-slate-300 hover:bg-slate-100'
                      }`}
                    >
                      Sensibilidad: 3 Rondas juntas (`waves=ALL`)
                    </button>
                  </div>
                </div>

                {/* Alerta clave: Efecto tijera por sexo */}
                <div className="lg:col-span-5 bg-indigo-950 text-white p-5 rounded-xl flex flex-col justify-center">
                  <div className="flex items-center gap-2 text-amber-400 font-bold text-xs uppercase tracking-wider mb-1.5">
                    <Scale className="w-4 h-4" />
                    La Paradoja del Promedio Nacional
                  </div>
                  <p className="text-sm text-indigo-100 leading-relaxed">
                    Si miras solo la Tabla 3 en Ronda VIII, los intervalos de confianza cruzan 1 (parecen no significativos). <strong>¡Cuidado!</strong> Esto ocurre porque al promediar todo el país se anulan dos fuerzas opuestas:
                  </p>
                  <ul className="mt-2.5 space-y-1.5 text-xs text-indigo-200">
                    <li className="flex items-center gap-2">
                      <span className="w-2 h-2 rounded-full bg-amber-400" />
                      <strong>Mujeres rurales:</strong> beben mucho MENOS que las urbanas.
                    </li>
                    <li className="flex items-center gap-2">
                      <span className="w-2 h-2 rounded-full bg-teal-400" />
                      <strong>Hombres rurales:</strong> tienen MÁS episodios de embriaguez (HED).
                    </li>
                  </ul>
                </div>
              </div>

              {/* Tarjetas de Razón de Tasas (RR) de Tabla 3 */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
                {filteredRatios.map(item => {
                  const isSig = item.lo95 > 1 || item.hi95 < 1;
                  return (
                    <div key={item.outcome} className="p-4 rounded-xl bg-slate-50 border border-slate-200 flex flex-col justify-between">
                      <div>
                        <div className="flex items-center justify-between">
                          <span className="text-xs font-bold text-slate-500 uppercase">{item.outcome}</span>
                          <span className={`text-[11px] px-2 py-0.5 rounded-full font-semibold ${
                            isSig ? 'bg-indigo-100 text-indigo-800' : 'bg-slate-200 text-slate-600'
                          }`}>
                            {isSig ? `Significativo (p=${item.p})` : 'Cruza 1.0 (No sig. global)'}
                          </span>
                        </div>
                        <h4 className="font-bold text-slate-900 mt-1">{item.label}</h4>

                        <div className="mt-3 flex items-baseline gap-2">
                          <span className="text-3xl font-extrabold text-indigo-600">RR {item.rr.toFixed(2)}</span>
                          <span className="text-xs font-mono text-slate-500">
                            [IC 95%: {item.lo95.toFixed(2)} – {item.hi95.toFixed(2)}]
                          </span>
                        </div>
                      </div>

                      <p className="mt-3 text-xs text-slate-600 leading-relaxed border-t border-slate-200 pt-2.5">
                        {item.desc}
                      </p>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Tabla 4: rg_T2_gaps.csv Desglose por Sexo y Educación */}
            <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 pb-6 border-b border-slate-100">
                <div>
                  <span className="text-xs font-bold uppercase tracking-wider text-indigo-600">
                    Tabla 4: `rg_T2_gaps.csv` • Diferencias Absolutas (`delta`)
                  </span>
                  <h3 className="text-lg font-bold text-slate-900 mt-0.5">
                    Brecha Rural vs. Urbana por Sexo y Educación (en unidades reales)
                  </h3>
                  <p className="text-xs text-slate-500 mt-0.5">
                    Diferencia entre un área 100% rural/no cubierta y una 100% urbana/cubierta (Ronda VIII, controlando por región).
                  </p>
                </div>

                {/* Selector de exposición */}
                <div className="flex items-center gap-1.5 bg-slate-100 p-1.5 rounded-xl shrink-0">
                  <button
                    onClick={() => setT2Exposure('noncov_asg')}
                    className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
                      t2Exposure === 'noncov_asg'
                        ? 'bg-indigo-600 text-white shadow-sm'
                        : 'text-slate-600 hover:bg-white'
                    }`}
                  >
                    Fuera del marco ENPG (`noncov_asg`)
                  </button>
                  <button
                    onClick={() => setT2Exposure('rural_asg')}
                    className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
                      t2Exposure === 'rural_asg'
                        ? 'bg-indigo-600 text-white shadow-sm'
                        : 'text-slate-600 hover:bg-white'
                    }`}
                  >
                    Solo Rural vs Urbano (`rural_asg`)
                  </button>
                </div>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
                {/* Columna Mujeres */}
                <div className="space-y-4">
                  <div className="flex items-center justify-between bg-amber-50 border border-amber-200 px-4 py-3 rounded-xl">
                    <div className="flex items-center gap-2">
                      <Users className="w-5 h-5 text-amber-700" />
                      <h4 className="font-bold text-amber-950">Mujeres: Beben MUCHO MENOS en lo rural</h4>
                    </div>
                    <span className="text-xs font-bold px-2 py-0.5 rounded bg-amber-200 text-amber-900">
                      ENPG Sobreestima (+)
                    </span>
                  </div>

                  {T2_GAPS[t2Exposure].filter(r => r.sex === 'Mujeres').map(row => (
                    <div key={row.edu} className="p-4 rounded-xl border border-slate-200 bg-slate-50/60 space-y-3">
                      <div className="flex items-center justify-between">
                        <span className="font-bold text-sm text-slate-900">{row.edu}</span>
                      </div>

                      <div className="grid grid-cols-3 gap-2 text-center">
                        <div className={`p-2.5 rounded-lg border ${row.sig_current ? 'bg-amber-50 border-amber-300' : 'bg-white border-slate-200'}`}>
                          <div className="text-[11px] text-slate-500">Bebedor actual</div>
                          <div className={`text-sm font-extrabold font-mono mt-0.5 ${row.sig_current ? 'text-amber-700' : 'text-slate-700'}`}>
                            {(row.current_delta * 100).toFixed(1)} pp {row.sig_current && '★'}
                          </div>
                        </div>

                        <div className={`p-2.5 rounded-lg border ${row.sig_grams ? 'bg-amber-50 border-amber-300' : 'bg-white border-slate-200'}`}>
                          <div className="text-[11px] text-slate-500">Gramos / día</div>
                          <div className={`text-sm font-extrabold font-mono mt-0.5 ${row.sig_grams ? 'text-amber-700' : 'text-slate-700'}`}>
                            {row.grams_delta > 0 ? `+${row.grams_delta.toFixed(2)}` : row.grams_delta.toFixed(2)} g {row.sig_grams && '★'}
                          </div>
                        </div>

                        <div className={`p-2.5 rounded-lg border ${row.sig_hed ? 'bg-amber-50 border-amber-300' : 'bg-white border-slate-200'}`}>
                          <div className="text-[11px] text-slate-500">HED (4+ tragos)</div>
                          <div className={`text-sm font-extrabold font-mono mt-0.5 ${row.sig_hed ? 'text-amber-700' : 'text-slate-700'}`}>
                            {(row.hed_delta * 100).toFixed(1)} pp {row.sig_hed && '★'}
                          </div>
                        </div>
                      </div>

                      <p className="text-xs text-slate-600">{row.summary}</p>
                    </div>
                  ))}
                </div>

                {/* Columna Hombres */}
                <div className="space-y-4">
                  <div className="flex items-center justify-between bg-teal-50 border border-teal-200 px-4 py-3 rounded-xl">
                    <div className="flex items-center gap-2">
                      <Users className="w-5 h-5 text-teal-700" />
                      <h4 className="font-bold text-teal-950">Hombres: MÁS embriaguez (HED) en lo rural</h4>
                    </div>
                    <span className="text-xs font-bold px-2 py-0.5 rounded bg-teal-200 text-teal-900">
                      ENPG Subestima (-)
                    </span>
                  </div>

                  {T2_GAPS[t2Exposure].filter(r => r.sex === 'Hombres').map(row => (
                    <div key={row.edu} className="p-4 rounded-xl border border-slate-200 bg-slate-50/60 space-y-3">
                      <div className="flex items-center justify-between">
                        <span className="font-bold text-sm text-slate-900">{row.edu}</span>
                      </div>

                      <div className="grid grid-cols-3 gap-2 text-center">
                        <div className={`p-2.5 rounded-lg border ${row.sig_current ? 'bg-teal-50 border-teal-300' : 'bg-white border-slate-200'}`}>
                          <div className="text-[11px] text-slate-500">Bebedor actual</div>
                          <div className={`text-sm font-extrabold font-mono mt-0.5 ${row.sig_current ? 'text-teal-700' : 'text-slate-700'}`}>
                            {row.current_delta > 0 ? `+${(row.current_delta * 100).toFixed(1)}` : (row.current_delta * 100).toFixed(1)} pp
                          </div>
                        </div>

                        <div className={`p-2.5 rounded-lg border ${row.sig_grams ? 'bg-teal-50 border-teal-300' : 'bg-white border-slate-200'}`}>
                          <div className="text-[11px] text-slate-500">Gramos / día</div>
                          <div className={`text-sm font-extrabold font-mono mt-0.5 ${row.sig_grams ? 'text-teal-700' : 'text-slate-700'}`}>
                            {row.grams_delta > 0 ? `+${row.grams_delta.toFixed(2)}` : row.grams_delta.toFixed(2)} g
                          </div>
                        </div>

                        <div className={`p-2.5 rounded-lg border ${row.sig_hed ? 'bg-teal-50 border-teal-300' : 'bg-white border-slate-200'}`}>
                          <div className="text-[11px] text-slate-500">HED (5+ tragos)</div>
                          <div className={`text-sm font-extrabold font-mono mt-0.5 ${row.sig_hed ? 'text-teal-700' : 'text-slate-700'}`}>
                            {row.hed_delta > 0 ? `+${(row.hed_delta * 100).toFixed(1)}` : (row.hed_delta * 100).toFixed(1)} pp {row.sig_hed && '★'}
                          </div>
                        </div>
                      </div>

                      <p className="text-xs text-slate-600">{row.summary}</p>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* ==========================================
            TAB 3: EXPLORADOR DE SESGO ENPG (TABLA 5)
           ========================================== */}
        {activeTab === 'tab3' && (
          <div className="space-y-6">
            {/* Explicación de la fórmula y controles de filtro */}
            <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
              <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 pb-6 border-b border-slate-100">
                <div>
                  <span className="text-xs font-bold uppercase tracking-wider text-indigo-600">
                    Tabla 5: `rg_T3_enpg_bias_cells.csv` • 24 Celdas Demográficas
                  </span>
                  <h2 className="text-xl font-bold text-slate-900 mt-0.5">
                    Explorador Interactivo de Sesgo Implícito de la ENPG
                  </h2>
                  <p className="text-xs sm:text-sm text-slate-600 mt-1 max-w-3xl">
                    Calcula cuánto se equivoca la ENPG en cada grupo usando la fórmula: <code className="bg-slate-100 px-1.5 py-0.5 rounded text-indigo-700 font-mono text-xs">Error Relativo ≈ − (Proporción fuera) × (Diferencia rural−urbana) / (Media real de la celda)</code>.
                  </p>
                </div>

                {/* Leyenda de colores */}
                <div className="flex flex-wrap gap-3 text-xs bg-slate-50 p-3 rounded-xl border border-slate-200 shrink-0">
                  <div className="flex items-center gap-1.5">
                    <span className="w-3 h-3 rounded bg-amber-500 inline-block" />
                    <span className="font-semibold text-slate-700">Positivo (+): ENPG Sobreestima</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <span className="w-3 h-3 rounded bg-teal-600 inline-block" />
                    <span className="font-semibold text-slate-700">Negativo (-): ENPG Subestima</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <span className="font-bold text-indigo-600">★</span>
                    <span className="text-slate-600">IC 95% no cruza 0 (Significativo)</span>
                  </div>
                </div>
              </div>

              {/* Barra de Filtros */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mt-6">
                <div>
                  <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-1.5">
                    1. Definición de Exposición
                  </label>
                  <select
                    value={biasExposure}
                    onChange={e => setBiasExposure(e.target.value)}
                    className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm font-semibold text-slate-800 shadow-sm focus:border-indigo-500 focus:outline-none"
                  >
                    <option value="noncov">Fuera del marco ENPG (`noncov` - Principal)</option>
                    <option value="rural">Solo Rural (`rural` - Sensibilidad)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-1.5">
                    2. Filtrar por Sexo
                  </label>
                  <select
                    value={filterSex}
                    onChange={e => setFilterSex(e.target.value)}
                    className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm font-semibold text-slate-800 shadow-sm focus:border-indigo-500 focus:outline-none"
                  >
                    <option value="ALL">Ambos sexos (24 celdas)</option>
                    <option value="Women">Solo Mujeres (12 celdas)</option>
                    <option value="Men">Solo Hombres (12 celdas)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-1.5">
                    3. Nivel Educativo (`edu`)
                  </label>
                  <select
                    value={filterEdu}
                    onChange={e => setFilterEdu(e.target.value)}
                    className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm font-semibold text-slate-800 shadow-sm focus:border-indigo-500 focus:outline-none"
                  >
                    <option value="ALL">Todos los niveles</option>
                    <option value="Prim">Básica o menos (`Prim`)</option>
                    <option value="Sec">Media (`Sec`)</option>
                    <option value="Tert">Superior completa (`Tert`)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-1.5">
                    4. Tramo de Edad (`ageg`)
                  </label>
                  <select
                    value={filterAge}
                    onChange={e => setFilterAge(e.target.value)}
                    className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm font-semibold text-slate-800 shadow-sm focus:border-indigo-500 focus:outline-none"
                  >
                    <option value="ALL">Todas las edades (18–65)</option>
                    <option value="18-29">18–29 años</option>
                    <option value="30-44">30–44 años</option>
                    <option value="45-59">45–59 años</option>
                    <option value="60-65">60–65 años</option>
                  </select>
                </div>
              </div>
            </div>

            {/* Grid de Tarjetas de las Celdas Filtradas */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {filteredCells.map(cell => {
                const expData = cell[biasExposure];
                const lowSample = cell.n < 150;

                return (
                  <div
                    key={cell.id}
                    className="bg-white rounded-xl border border-slate-200 shadow-sm p-4 flex flex-col justify-between hover:border-slate-300 transition-all"
                  >
                    <div>
                      {/* Cabecera de la celda */}
                      <div className="flex items-start justify-between gap-2 pb-3 border-b border-slate-100">
                        <div>
                          <div className="flex items-center gap-1.5">
                            <span className={`text-xs font-bold px-2 py-0.5 rounded ${
                              cell.sex === 'Women' ? 'bg-purple-100 text-purple-800' : 'bg-sky-100 text-sky-800'
                            }`}>
                              {cell.sexLabel}
                            </span>
                            <span className="text-xs font-bold px-2 py-0.5 rounded bg-slate-100 text-slate-700">
                              {cell.ageg} años
                            </span>
                          </div>
                          <h4 className="font-bold text-slate-900 text-sm mt-1.5">
                            Educación: {cell.eduLabel} (<code className="text-xs">{cell.edu}</code>)
                          </h4>
                        </div>

                        <div className="text-right">
                          <span className={`inline-flex items-center gap-1 text-xs font-mono px-2 py-0.5 rounded ${
                            lowSample ? 'bg-amber-100 text-amber-800 font-bold' : 'bg-slate-100 text-slate-600'
                          }`}>
                            {lowSample && <AlertTriangle className="w-3 h-3 text-amber-600" />}
                            n = {cell.n}
                          </span>
                          <div className="text-[11px] text-slate-500 mt-1">
                            {biasExposure === 'noncov'
                              ? `Fuera ENPG: ${cell.share_noncov}%`
                              : `Ruralidad: ${cell.share_rural}%`}
                          </div>
                        </div>
                      </div>

                      {/* Medias EPS de referencia */}
                      <div className="grid grid-cols-3 gap-1.5 my-3 bg-slate-50 p-2 rounded-lg text-center border border-slate-100">
                        <div>
                          <div className="text-[10px] text-slate-400 uppercase font-semibold">Prev. EPS</div>
                          <div className="text-xs font-bold text-slate-700">{(cell.mean_current * 100).toFixed(1)}%</div>
                        </div>
                        <div>
                          <div className="text-[10px] text-slate-400 uppercase font-semibold">Gramos/día</div>
                          <div className="text-xs font-bold text-slate-700">{cell.mean_pop_grams.toFixed(2)}g</div>
                        </div>
                        <div>
                          <div className="text-[10px] text-slate-400 uppercase font-semibold">HED EPS</div>
                          <div className="text-xs font-bold text-slate-700">{(cell.mean_hed * 100).toFixed(1)}%</div>
                        </div>
                      </div>

                      {/* Barras de sesgo para los 3 indicadores */}
                      <div className="space-y-2">
                        {renderBiasBar(expData.current, 'Consumo Actual')}
                        {renderBiasBar(expData.grams, 'Gramos / Día')}
                        {renderBiasBar(expData.hed, 'HED (Embriaguez 5+/4+)')}
                      </div>
                    </div>

                    {lowSample && (
                      <div className="mt-3 pt-2 border-t border-amber-100 flex items-center gap-1.5 text-[11px] text-amber-700">
                        <AlertTriangle className="w-3.5 h-3.5 shrink-0" />
                        <span>Muestra pequeña (`n &lt; 150`): interpretar con cautela por intervalos anchos.</span>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* ==========================================
            TAB 4 (NEW): ¿SE USARON TODAS LAS OLAS?
           ========================================== */}
        {activeTab === 'tab_waves' && (
          <div className="space-y-8">
            {/* Banner Resumen: Respuesta Directa */}
            <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
              <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
                <div className="max-w-3xl">
                  <span className="inline-flex items-center gap-1.5 text-xs font-bold uppercase tracking-wider text-indigo-700 bg-indigo-50 px-3 py-1 rounded-full border border-indigo-200">
                    <History className="w-3.5 h-3.5" />
                    Cobertura Temporal del Estudio
                  </span>
                  <h2 className="text-xl sm:text-2xl font-bold text-slate-900 mt-2">
                    ¿Se utilizaron todas las olas disponibles de la ENPG y de la EPS?
                  </h2>
                  <p className="mt-2 text-sm sm:text-base text-slate-600 leading-relaxed">
                    <strong>Sí, se usaron todas las olas en ambas encuestas</strong>, pero cumpliendo roles distintos según la solidez del dato geográfico en cada ronda:
                  </p>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 shrink-0 lg:w-96">
                  <div className="p-3.5 rounded-xl bg-indigo-50 border border-indigo-200">
                    <div className="text-xs font-bold uppercase text-indigo-700">1. ENPG (2012–2024)</div>
                    <div className="text-lg font-extrabold text-indigo-950 mt-0.5">Las 7 olas completas</div>
                    <p className="text-xs text-indigo-800 mt-1">
                      Usadas en Tablas 1 y 2. Demuestran que la sub-representación rural (~4,5% vs ~11,5%) es idéntica durante 12 años.
                    </p>
                  </div>
                  <div className="p-3.5 rounded-xl bg-teal-50 border border-teal-200">
                    <div className="text-xs font-bold uppercase text-teal-800">2. EPS (VI, VII y VIII)</div>
                    <div className="text-lg font-extrabold text-teal-950 mt-0.5">3 rondas en T3 / VIII en T4-T5</div>
                    <p className="text-xs text-teal-800 mt-1">
                      Las 3 rondas (`ALL`) confirman significancia nacional en Tabla 3; la Ronda VIII (2023/24) se usa para el sesgo por celda.
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* PARTE A: MATRIZ COMPLETA DE LAS 7 OLAS DE LA ENPG (2012-2024) */}
            <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 pb-5 border-b border-slate-100">
                <div>
                  <span className="text-xs font-bold uppercase tracking-wider text-indigo-600">
                    Parte A • ENPG: 7 Olas Completas (2012, 2014, 2016, 2018, 2020, 2022 y 2024)
                  </span>
                  <h3 className="text-lg font-bold text-slate-900 mt-0.5">
                    Matriz Histórica Completa: % Rural de la Comuna (ENPG vs. INE)
                  </h3>
                  <p className="text-xs text-slate-500 mt-0.5">
                    Incluye las 9 filas demográficas verificadas (incluyendo Hombre/Mujer 30–44, Mujer 45–59 y Total 15–65).
                  </p>
                </div>

                {/* Selector de modo de visualización de la matriz */}
                <div className="flex items-center gap-1.5 bg-slate-100 p-1.5 rounded-xl shrink-0">
                  <button
                    onClick={() => setMatrixDisplayMode('pair')}
                    className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
                      matrixDisplayMode === 'pair'
                        ? 'bg-indigo-600 text-white shadow-sm'
                        : 'text-slate-600 hover:bg-white'
                    }`}
                  >
                    ENPG / INE (%)
                  </button>
                  <button
                    onClick={() => setMatrixDisplayMode('ratio')}
                    className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
                      matrixDisplayMode === 'ratio'
                        ? 'bg-indigo-600 text-white shadow-sm'
                        : 'text-slate-600 hover:bg-white'
                    }`}
                  >
                    Razón (`ratio_mean`)
                  </button>
                  <button
                    onClick={() => setMatrixDisplayMode('diff')}
                    className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
                      matrixDisplayMode === 'diff'
                        ? 'bg-indigo-600 text-white shadow-sm'
                        : 'text-slate-600 hover:bg-white'
                    }`}
                  >
                    Brecha (ENPG − INE)
                  </button>
                </div>
              </div>

              <div className="mt-5 overflow-x-auto">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="border-b border-slate-200 bg-slate-50 text-xs font-bold uppercase text-slate-600">
                      <th className="py-3 px-4 rounded-tl-lg">Sexo y Edad</th>
                      {[2012, 2014, 2016, 2018, 2020, 2022, 2024].map(yr => (
                        <th key={yr} className="py-3 px-3 text-center font-mono">{yr}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 text-xs sm:text-sm">
                    {[
                      'Hombre 15-29',
                      'Hombre 30-44',
                      'Hombre 45-59',
                      'Hombre 60-65',
                      'Mujer 15-29',
                      'Mujer 30-44',
                      'Mujer 45-59',
                      'Mujer 60-65',
                      'Total 15-65'
                    ].map(groupKey => {
                      const isTotal = groupKey === 'Total 15-65';
                      return (
                        <tr
                          key={groupKey}
                          className={isTotal ? 'bg-indigo-50/80 font-bold text-indigo-950 border-t-2 border-indigo-200' : 'hover:bg-slate-50'}
                        >
                          <td className="py-3 px-4 font-semibold whitespace-nowrap">
                            {groupKey}
                          </td>
                          {[2012, 2014, 2016, 2018, 2020, 2022, 2024].map(yr => {
                            const cell = COVERAGE_BY_YEAR[yr].byGroup[groupKey];
                            const diff = (cell.enpg - cell.ine).toFixed(1);
                            return (
                              <td key={yr} className="py-3 px-3 text-center font-mono whitespace-nowrap">
                                {matrixDisplayMode === 'pair' && (
                                  <span>
                                    <strong className="text-indigo-700">{cell.enpg.toFixed(1)}</strong>
                                    <span className="text-slate-400 mx-1">/</span>
                                    <span className="text-slate-600">{cell.ine.toFixed(1)}</span>
                                  </span>
                                )}
                                {matrixDisplayMode === 'ratio' && (
                                  <span className="px-2 py-0.5 rounded bg-indigo-100 text-indigo-900 font-bold">
                                    {cell.ratio.toFixed(2)}x
                                  </span>
                                )}
                                {matrixDisplayMode === 'diff' && (
                                  <span className="text-rose-700 font-semibold">
                                    {diff} pp
                                  </span>
                                )}
                              </td>
                            );
                          })}
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>

              <div className="mt-4 flex flex-wrap items-center justify-between gap-2 text-xs text-slate-500 bg-slate-50 p-3 rounded-xl border border-slate-200">
                <span>
                  <strong>Lectura:</strong> En todas las olas y grupos, el encuestado típico de la ENPG vive en una comuna con ~4–5% de población rural, mientras el habitante típico de Chile vive en una con ~10–13%.
                </span>
                <span className="font-mono text-indigo-700 font-semibold">
                  Verificado con recálculo independiente (dplyr) y suma de pesos = población INE.
                </span>
              </div>
            </div>

            {/* PARTE B: LAS 3 RONDAS DE LA EPS (VI, VII Y VIII) vs SOLO RONDA VIII */}
            <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
              <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 pb-6 border-b border-slate-100">
                <div>
                  <span className="text-xs font-bold uppercase tracking-wider text-teal-700">
                    Parte B • EPS: Ronda VIII (2023/24) vs. Las 3 Rondas Juntas (`ALL`: VI 2015/16 + VII 2019/20 + VIII 2023/24)
                  </span>
                  <h3 className="text-lg font-bold text-slate-900 mt-0.5">
                    ¿Qué pasa cuando juntamos las 3 rondas de la EPS en la Tabla 3 (`rg_T1_ratios.csv`)?
                  </h3>
                  <p className="text-xs sm:text-sm text-slate-600 mt-1 max-w-3xl">
                    En la Ronda VIII sola, las diferencias nacionales parecen no significativas porque los intervalos son anchos. Al juntar las 3 rondas (`waves = ALL`), el mayor tamaño muestral estrecha los intervalos y vuelve <strong>estadísticamente significativo</strong> el menor consumo rural en prevalencia, gramos/día y consumo riesgoso.
                  </p>
                </div>

                {/* Selector de especificación de exposición / FE */}
                <div className="shrink-0">
                  <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-1.5">
                    Especificación en `rg_T1_ratios.csv`:
                  </label>
                  <select
                    value={wavesSpecFilter}
                    onChange={e => setWavesSpecFilter(e.target.value)}
                    className="w-full sm:w-72 rounded-lg border border-slate-300 bg-white px-3 py-2 text-xs sm:text-sm font-semibold text-slate-800 shadow-sm focus:border-indigo-500 focus:outline-none"
                  >
                    <option value="rural_asg_FE">1. Principal: `rural_asg` + Control Región (`FE=TRUE`)</option>
                    <option value="rural_asg_noFE">2. Sin Control Regional: `rural_asg` (`FE=FALSE`)</option>
                    <option value="rural_exp_FE">3. Sensibilidad Comuna: `rural_exp` + `FE=TRUE`</option>
                    <option value="noncov_asg_FE">4. Fuera Marco ENPG: `noncov_asg` + `FE=TRUE`</option>
                  </select>
                </div>
              </div>

              {/* Comparación lado a lado (VIII vs ALL) para los 4 outcomes */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-5 mt-6">
                {EPS_WAVES_COMPARISON.map(item => {
                  const specData = item.specs[wavesSpecFilter];
                  const v8 = specData.viii;
                  const all = specData.all;

                  return (
                    <div key={item.outcome} className="p-5 rounded-xl bg-slate-50 border border-slate-200 flex flex-col justify-between">
                      <div>
                        <div className="flex items-center justify-between gap-2">
                          <span className="text-xs font-mono font-bold text-indigo-700 bg-indigo-50 px-2.5 py-0.5 rounded border border-indigo-200">
                            {item.outcome}
                          </span>
                          <span className="text-xs text-slate-500">{item.shortDesc}</span>
                        </div>
                        <h4 className="text-base font-bold text-slate-900 mt-2">{item.label}</h4>

                        {/* Comparación de las 2 filas: waves = VIII vs waves = ALL */}
                        <div className="mt-4 space-y-3">
                          {/* Fila Ronda VIII */}
                          <div className={`p-3 rounded-lg border ${v8.sig ? 'bg-amber-50/70 border-amber-300' : 'bg-white border-slate-200'}`}>
                            <div className="flex items-center justify-between text-xs">
                              <span className="font-bold text-slate-700">Solo Ronda VIII (2023/24)</span>
                              <span className={`px-2 py-0.5 rounded font-mono text-[11px] ${
                                v8.sig ? 'bg-amber-600 text-white font-bold' : 'bg-slate-100 text-slate-600'
                              }`}>
                                p = {v8.p < 0.001 ? '<0.001' : v8.p.toFixed(3)} {v8.sig ? '★ (Sig.)' : '(ns)'}
                              </span>
                            </div>
                            <div className="mt-1.5 flex items-baseline justify-between">
                              <span className="text-xl font-extrabold text-slate-900 font-mono">
                                RR {v8.rr.toFixed(2)}
                              </span>
                              <span className="text-xs font-mono text-slate-500">
                                IC 95%: [{v8.lo95.toFixed(2)} – {v8.hi95.toFixed(2)}]
                              </span>
                            </div>
                          </div>

                          {/* Fila 3 Rondas Juntas (ALL) */}
                          <div className={`p-3 rounded-lg border ${all.sig ? 'bg-teal-50/90 border-teal-400 ring-1 ring-teal-200' : 'bg-white border-slate-200'}`}>
                            <div className="flex items-center justify-between text-xs">
                              <span className="font-bold text-teal-950">Las 3 Rondas Juntas (`ALL`: VI + VII + VIII)</span>
                              <span className={`px-2 py-0.5 rounded font-mono text-[11px] ${
                                all.sig ? 'bg-teal-700 text-white font-bold' : 'bg-slate-100 text-slate-600'
                              }`}>
                                p = {all.p < 0.001 ? '<0.001' : all.p.toFixed(3)} {all.sig ? '★ (Significativo)' : '(ns)'}
                              </span>
                            </div>
                            <div className="mt-1.5 flex items-baseline justify-between">
                              <span className="text-xl font-extrabold text-teal-900 font-mono">
                                RR {all.rr.toFixed(2)}
                              </span>
                              <span className="text-xs font-mono text-teal-800 font-semibold">
                                IC 95%: [{all.lo95.toFixed(2)} – {all.hi95.toFixed(2)}]
                              </span>
                            </div>
                          </div>
                        </div>
                      </div>

                      <p className="mt-3 pt-3 border-t border-slate-200 text-xs text-slate-700 leading-relaxed">
                        <strong>Lectura:</strong> {specData.insight}
                      </p>
                    </div>
                  );
                })}
              </div>

              {/* Explicación metodológica: ¿Por qué ALL es sensibilidad y Ronda VIII es principal? */}
              <div className="mt-6 bg-amber-50 border border-amber-200 rounded-xl p-5">
                <div className="flex items-start gap-3">
                  <AlertTriangle className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
                  <div className="space-y-2">
                    <h4 className="text-sm font-bold text-amber-950">
                      ¿Por qué entonces se dejó `waves = ALL` como sensibilidad en la Tabla 3 y se usó solo la Ronda VIII (2023/24) para las Tablas 4 y 5?
                    </h4>
                    <p className="text-xs sm:text-sm text-amber-900 leading-relaxed">
                      Como se documenta en el reporte técnico (<code>sesgo_hed_consumo_edad_sexo_2026_10_22.txt</code>), hay dos razones de peso para no mezclar las 3 olas al calcular los factores de sesgo por celda en las Tablas 4 y 5:
                    </p>
                    <ul className="list-disc list-inside text-xs sm:text-sm text-amber-900 space-y-1">
                      <li>
                        <strong>1. En la Ronda VI (2015/16) solo el 75% de las personas tiene cluster asignado:</strong> Al juntar las tres rondas (`ALL`), el mayor poder estadístico depende fuertemente de la Ronda VI, donde un 25% de la muestra carece de área de muestreo (`cluster`) vinculable a ruralidad comunal.
                      </li>
                      <li>
                        <strong>2. Calibración contemporánea (2023/24):</strong> Para calibrar el modelo de microsimulación hoy, mezclar patrones de consumo de 2015 con los de 2024 introduciría cambios seculares de tendencia. La Ronda VIII tiene el pareo de clusters limpio y refleja las brechas vigentes.
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* ==========================================
            TAB 5: GUÍA DE LAS 5 TABLAS Y LÍMITES
           ========================================== */}
        {activeTab === 'tab4' && (
          <div className="space-y-8">
            {/* Cómo se conectan las 5 tablas paso a paso */}
            <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
              <span className="text-xs font-bold uppercase tracking-wider text-indigo-600">
                Mapa de Ruta de los Archivos CSV
              </span>
              <h2 className="text-xl font-bold text-slate-900 mt-1">
                ¿Cómo encajan las 5 tablas como piezas de un rompecabezas?
              </h2>
              <p className="text-sm text-slate-600 mt-1">
                Cada tabla responde un eslabón necesario para pasar desde «la ENPG no visita el campo» hasta «cuánto debemos corregir el modelo por grupo».
              </p>

              <div className="grid grid-cols-1 md:grid-cols-5 gap-4 mt-6">
                {[
                  {
                    step: 'Tabla 1',
                    file: 'enpg_rural_coverage.csv',
                    question: '¿Qué parte del país cae en las comunas ENPG?',
                    source: 'ENPG + INE (2012–2024)',
                    keyCols: '`comunas_enpg` (~109), `pct_pop_in_enpg_comunas` (~82%), `pct_rural_pop_in_enpg_comunas` (~40%).',
                    takeaway: 'En 2024, el 60% de la población rural de 15–64 vive en las 237 comunas no observadas; no necesariamente son pequeñas.'
                  },
                  {
                    step: 'Tabla 2',
                    file: 'enpg_rural_bias.csv',
                    question: '¿Qué tan rurales son las comunas ENPG vs Chile?',
                    source: 'ENPG + INE por edad y sexo',
                    keyCols: '`enpg_mean` (~4,2%), `pop_mean` (~10,9%), `ratio_mean` (~0,39).',
                    takeaway: 'Describe la ruralidad de las comunas observadas; no mide la proporción excluida ni cuantifica sesgo en consumo.'
                  },
                  {
                    step: 'Tabla 3',
                    file: 'rg_T1_ratios.csv',
                    question: '¿Se bebe distinto en zonas rurales a nivel país?',
                    source: 'EPS (Rondas VI, VII y VIII)',
                    keyCols: '`RR` (Razón 100% rural vs 100% urbano), `region_FE` (Control regional), `exposure`.',
                    takeaway: 'En Ronda VIII da RR 0,67 en prevalencia y 1,31 en HED. No parecen significativos a nivel global porque hombres y mujeres se cancelan.'
                  },
                  {
                    step: 'Tabla 4',
                    file: 'rg_T2_gaps.csv',
                    question: '¿Cuál es la brecha real por sexo y educación?',
                    source: 'EPS Ronda VIII (2023/24)',
                    keyCols: '`delta` (Diferencia absoluta rural − urbano en proporción o g/día), `sex`, `edu`.',
                    takeaway: 'Revela el efecto tijera: mujeres educadas beben mucho menos en lo rural (-24 a -35 pp); hombres menos educados tienen más HED (+9 a +10 pp).'
                  },
                  {
                    step: 'Tabla 5',
                    file: 'rg_T3_enpg_bias_cells.csv',
                    question: '¿Cuánto sesgo tiene la ENPG en cada celda?',
                    source: 'Tabla 4 + Medias EPS por celda',
                    keyCols: '`share_noncov`, `noncov_current`, `noncov_pop_grams`, `noncov_hed`.',
                    takeaway: 'Traduce la brecha en % de error de la ENPG para las 24 celdas (Sexo × Edad × Educación).'
                  }
                ].map((item, idx) => (
                  <div key={item.file} className="p-4 rounded-xl bg-slate-50 border border-slate-200 flex flex-col justify-between relative">
                    <div>
                      <div className="flex items-center justify-between text-xs font-bold text-indigo-600 mb-1">
                        <span>{item.step}</span>
                        <FileSpreadsheet className="w-4 h-4" />
                      </div>
                      <div className="font-mono text-xs font-bold text-slate-900 break-all bg-white px-2 py-1 rounded border border-slate-200">
                        {item.file}
                      </div>
                      <h4 className="font-bold text-sm text-slate-800 mt-2.5">
                        {item.question}
                      </h4>
                      <div className="text-[11px] text-slate-500 mt-1">
                        <strong>Fuente:</strong> {item.source}
                      </div>
                      <div className="text-[11px] text-slate-600 mt-2 bg-white p-2 rounded border border-slate-100">
                        <strong>Columnas clave:</strong> {item.keyCols}
                      </div>
                    </div>
                    <p className="mt-3 pt-2.5 border-t border-slate-200 text-xs text-slate-700 leading-relaxed">
                      {item.takeaway}
                    </p>
                  </div>
                ))}
              </div>
            </div>

            {/* Implicancias para Microsimulación y Límites Metodológicos */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {/* Calibración de Microsimulación */}
              <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
                <div className="flex items-center gap-2 text-indigo-600 font-bold text-xs uppercase tracking-wider">
                  <Sliders className="w-4 h-4" />
                  Recomendación Práctica
                </div>
                <h3 className="text-lg font-bold text-slate-900 mt-1">
                  ¿Cómo usar estos resultados para calibrar el modelo de microsimulación?
                </h3>
                <p className="text-sm text-slate-600 mt-1">
                  Si el modelo de simulación se calibra usando la ENPG como referencia nacional, arrastrará estos sesgos de cobertura. Los ajustes sugeridos son del orden del <strong>~10%</strong> (no cambian órdenes de magnitud, pero corrigen sesgos sistemáticos):
                </p>

                <div className="mt-4 space-y-3">
                  <div className="p-3.5 rounded-xl bg-amber-50 border border-amber-200">
                    <div className="font-bold text-sm text-amber-950">
                      1. Ajustar a la BAJA a Mujeres con Educación Media y Superior
                    </div>
                    <p className="text-xs text-amber-900 mt-1 leading-relaxed">
                      La ENPG sobreestima la prevalencia de bebedoras en <strong>+6% a +9%</strong> (Ed. Media y Superior) y sobreestima los gramos/día (<strong>+12% a +16%</strong>) y el HED (<strong>+14% a +17%</strong>) en mujeres con Educación Superior.
                    </p>
                  </div>

                  <div className="p-3.5 rounded-xl bg-teal-50 border border-teal-200">
                    <div className="font-bold text-sm text-teal-950">
                      2. Ajustar al ALZA el HED en Hombres con Educación Básica y Media
                    </div>
                    <p className="text-xs text-teal-900 mt-1 leading-relaxed">
                      La ENPG subestima los episodios de consumo intenso (HED 5+ tragos) entre <strong>-15% y -30%</strong> en hombres con educación básica, y entre <strong>-10% y -15%</strong> en hombres con educación media.
                    </p>
                  </div>

                  <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200">
                    <div className="font-bold text-sm text-slate-800">
                      3. No tocar el resto de las celdas
                    </div>
                    <p className="text-xs text-slate-600 mt-1 leading-relaxed">
                      En mujeres con educación básica y en hombres con educación superior, el sesgo es cercano a cero (~0% a +2%) y estadísticamente no significativo.
                    </p>
                  </div>
                </div>
              </div>

              {/* Los 3 Límites Metodológicos */}
              <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
                <div className="flex items-center gap-2 text-amber-600 font-bold text-xs uppercase tracking-wider">
                  <AlertTriangle className="w-4 h-4" />
                  Advertencias de Interpretación
                </div>
                <h3 className="text-lg font-bold text-slate-900 mt-1">
                  Los 3 límites principales de las tablas `rg_*`
                </h3>
                <p className="text-sm text-slate-600 mt-1">
                  Estas tablas deben usarse para conocer la <strong>dirección y el orden de magnitud</strong> del sesgo, no como factores de corrección exactos al decimal:
                </p>

                <div className="mt-4 space-y-3">
                  <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200">
                    <div className="font-bold text-sm text-slate-900">
                      1. Ruralidad del área de muestreo (Efecto Piso / Atenuación)
                    </div>
                    <p className="text-xs text-slate-600 mt-1 leading-relaxed">
                      La EPS no tiene un indicador urbano/rural individual; se usa la ruralidad estimada del conglomerado/comuna donde fue muestreada la persona (y no necesariamente donde vive hoy). Este error de medición tiende a <strong>atenuar las diferencias</strong>, por lo que los sesgos reales podrían ser incluso mayores.
                    </p>
                  </div>

                  <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200">
                    <div className="font-bold text-sm text-slate-900">
                      2. Supuesto Ecológico
                    </div>
                    <p className="text-xs text-slate-600 mt-1 leading-relaxed">
                      Se proyecta la diferencia entre clusters más y menos rurales asumiendo que las diferencias provienen de la mezcla de personas rurales y urbanas, y no de que el entorno comunal cambie por sí mismo el comportamiento de los urbanos que viven allí.
                    </p>
                  </div>

                  <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200">
                    <div className="font-bold text-sm text-slate-900">
                      3. Diferencias de cuestionario entre EPS y ENPG
                    </div>
                    <p className="text-xs text-slate-600 mt-1 leading-relaxed">
                      Las preguntas de alcohol en la EPS y en la ENPG no son idénticas. Además, se usan diferencias absolutas (`delta` en Tabla 4) por sexo × educación para evitar que celdas con medias muy pequeñas distorsionen el cálculo.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}