# IPW v2 EPS: predictores del modelo de atrición (2026-10-19)

| Constructo | EPS (origen) | TSM | Codificación |
|---|---|---|---|
| Estado de consumo en origen | F.13–F.15 | AUDIT-C | N0, FD, C1, C2, C3+C4 |
| Intensidad previa | F.14 × F.15 → g/día | e3a1 × e3a2 → g/día | log(g/día + 1); llevar ambas fuentes a g/día antes, nunca multiplicar códigos de respuesta |
| Sexo × grupo de edad | Sexo, edad | a2, edad | 2 × 4 |
| Educación | A.12.n + A.12.e (completitud) | b4a + b4b + b1 (b4a sola es nivel alcanzado, no completado) | 3 niveles completados |
| Macrozona | Región | Región | 4 macrozonas |
| Tenencia de vivienda | D.7 | f1 | Propia / no propia |
| Pareja | I.1 | a6 | Con / sin pareja |
| Trabajó la semana pasada | B.2 | c1 | Sí / No |
| Fuma actualmente | F.12.a | e4a | Sí / No |
| Síntomas depresivos | F.69 (PHQ-9) | f15a–i | ≥10 / <10 |
| Salud autopercibida | A.10 | f7a | Mala o regular / buena o mejor |
