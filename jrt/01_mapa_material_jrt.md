# Mapa inicial del material dejado por JRT

## 1. Repositorios identificados

### ACC1240138_private
Repositorio integrador del FONDECYT. Contiene tres módulos:
- Mortalidad
- Simulación
- Elasticidad

### Potentially Avoidable Injury Mortality
Repositorio asociado al paper de lesiones evitables por reducción de HED.
Contiene:
- ENPG_FULL.RDS
- mortality_injuries.rds
- PAF INJURIES.rds
- PAF INJURIES_SENS.rds
- PIF injuries.rds
- PIF-BINGE.R

### Sex and age differences in alcohol-attributable mortality
Repositorio asociado al paper de mortalidad atribuible 2008–2022.
Contiene:
- DATA PREPARATION ENPG.R
- Paper mortality trends.R
- Raw data con defunciones y ENPG

## 2. Hipótesis de dependencia

El paper de mortalidad general parece preparar ENPG, defunciones y estimaciones de mortalidad atribuible.
El paper de lesiones parece usar matrices PAF/PIF para estimar muertes evitables y YPLL bajo escenarios de reducción de HED.
El repositorio privado parece integrar esos objetos en el FONDECYT junto con simulación, elasticidades y calibración.

## 3. Objetos que debo entender primero

- PAF FINAL.rds
- PAF INJURIES.rds
- PIF injuries.rds
- YPLL.rds
- mortality_injuries.rds
- ENPG_FULL.RDS

## 4. Dudas para ACC/JRT

1. ¿Cuál de estos repositorios es la versión más actualizada?
2. ¿Las matrices PAF/PIF deben considerarse finales o recalculables?
3. ¿El PIF de HED aplica solo a injuries o se espera extenderlo?
4. ¿El módulo de simulación debe usar directamente estas matrices?
5. ¿Qué output esperan de mí en los próximos 30 días?