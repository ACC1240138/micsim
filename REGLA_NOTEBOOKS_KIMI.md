# REGLA DURA PARA ASISTENTES DE IA (Kimi, Claude, Codex, etc.)

**NO edites, modifiques, reescribas, borres, renombres, guardes, exportes, renders ni toques de ninguna forma archivos de notebook** (`.ipynb`, `.qmd`, `.Rmd`, `.nb.html`, `.quarto_ipynb`, etc.), **a menos que el usuario te lo pida de manera EXPLÍCITA y DIRECTA.**

## Qué NO cuenta como permiso

- Frases como: "actualízalo", "corrélo", "mejóralo", "revísalo", "arreglalo", "dame el código", "¿podrías...?", "hazlo", "explícamelo", "audítalo".
- Indirectas, sugerencias, contextos o necesidades implícitas.
- Que el usuario haya aprobado otras acciones en la misma conversación.
- Que técnicamente tengas capacidad de editar el archivo.

## Qué HACER si no estás seguro

1. **DETENTE.**
2. **Pregunta explícitamente:** "¿Quieres que edite el archivo de notebook directamente, o prefieres que te dé el código/script para que lo pegues tú?"
3. **Espera una respuesta clara.** Respuestas como "sí", "dale", "hazlo" NO son suficientes; debe ser algo como "sí, edita el notebook", "modifícalo tú", "guárdalo en el archivo".

## Comportamiento por defecto

- Entrega código en bloques copiar/pegar.
- Entrega scripts `.R`, `.py`, `.md` o similares aparte.
- Explica, audita, revisa y sugiere, pero **no reescribas el notebook**.

## Cuándo SÍ puedes editar

Solo si el usuario dice algo equivalente a:

> "Sí, edita el notebook."  
> "Modifícalo tú directamente."  
> "Guarda los cambios en el archivo."  
> "Escribe la respuesta dentro del `.ipynb`/`.qmd`/`.Rmd`."

## Motivo

Los asistentes de IA suelen destruir notebooks: pierden metadatos, celdas, outputs, formato, encoding o el orden de ejecución. Sé defensivo con esta regla.
