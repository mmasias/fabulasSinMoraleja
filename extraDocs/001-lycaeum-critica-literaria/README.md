# LYCAEUM: sistema multi-agente de crítica literaria con blackboard pattern

<div align=right>

|||||
|-|-|-|-|
|[🏠️](../README.md)|**Artículo**|[Contexto](contexto.md)|[Evidencia](evidencia.md)

</div>

## ¿Por qué?

### El problema de la lectura única

Un autor no puede leer su propia obra desde fuera. Está demasiado dentro.

La solución obvia es pedir a otros que la lean. Pero ¿qué pasa si los "otros" son tres LLMs con marcos críticos radicalmente distintos, obligados a discrepar entre sí?

Los LLMs han demostrado capacidad para internalizar tradiciones críticas completas: tienen a los formalistas rusos, a Merleau-Ponty, a Derrida. Pero convocados individualmente sobre un texto producen lecturas que tienden a la síntesis y el consenso — exactamente lo contrario de lo que necesita una obra en proceso de comprenderse a sí misma.

**La hipótesis de partida**: si se asigna a cada LLM un único marco crítico y se les impide sintetizar hasta que hayan discrepado, la tensión entre marcos puede producir lecturas que ninguno habría alcanzado solo — y que el propio autor no podría haber formulado.

## ¿Qué?

### Mesa redonda crítica automatizada sobre *Fábulas sin moraleja*

LYCAEUM es un sistema multi-agente basado en **blackboard pattern** que orquesta una mesa redonda de crítica literaria entre tres LLMs con marcos radicalmente distintos, moderada por un cuarto agente orquestador.

**Los tres críticos:**

| Agente | Marco | Pregunta permanente |
|---|---|---|
| Opencode (GLM-4.6) | Formalista | ¿Cómo funciona esto técnicamente? |
| Gemini | Fenomenológico | ¿Qué experiencia produce en el lector? |
| Qwen | Deconstruccionista | ¿Qué tiene que callar para poder hablar? |

**El orquestador (Claude Code):** no opina sobre los poemas. Lee las tres lecturas, identifica el punto de mayor tensión entre ellas, y diseña la Fase B del debate para que los críticos se respondan entre sí desde ese punto de conflicto específico.

**Estructura por ronda (un poema por ronda):**
- **Fase A:** lecturas independientes — cada agente lee el poema sin ver a los otros
- **Fase B:** debate — los tres se responden al punto de tensión identificado por el orquestador
- **Cierre:** el orquestador actualiza el blackboard con el punto de tensión, lo que quedó sin resolver, y los hilos para la ronda 10

**Ronda 10:** pregunta única sobre el álbum como unidad: *¿existe coherencia conceptual, o es ilusión retrospectiva?*

## ¿Para qué?

### Que el texto devuelva al autor lo que no sabía que había escrito

El resultado más valioso del experimento no fue la calidad analítica individual de cada crítico — fue la capacidad del sistema para producir lecturas que el autor reconoció como verdaderas sin haberlas formulado previamente.

**Hallazgos que emergieron sin ser buscados:**

- El álbum opera con **autoceguera selectiva**: se autodiagnostica con precisión en sus fracasos formales, pero es sistemáticamente ciego a sus implicaciones éticas.
- El sujeto del álbum construye activamente su propia narrativa de victimización: actúa sobre sí mismo pero externaliza consistentemente la violencia inicial.
- Los títulos del álbum desmienten al texto: al menos tres títulos prometen algo que el poema luego niega o invierte.
- El "tú" del álbum nunca habla: nueve poemas construidos sobre una ausencia que el sistema tampoco pudo superar — los tres críticos analizaron al "tú" como función sin darle voz.
- El poema que habla de no ser entendido ("Caín") no pudo ser leído por el sistema: el filtro de contenido bloqueó al deconstruccionista dos veces, reproduciendo en el aparato crítico el mismo silenciamiento que el poema practica.

### Validación del potencial de los LLMs más allá del código

El experimento demuestra que la aplicación de LLMs a tareas cognitivas complejas no se agota en la generación y revisión de código. La capacidad de internalizar marcos filosóficos, sostenerlos bajo presión de debate, y producir argumentos que se refinan en tensión con otros marcos es un vector de uso sustancialmente distinto y menos explorado.

## ¿Cómo?

### Arquitectura del sistema

**Directorio de trabajo** (`_LYCAEUM/`):
```
CLAUDE.md                    ← instrucciones del orquestador
contexto_opencode.md         ← marco formalista
contexto_gemini.md           ← marco fenomenológico  
contexto_qwen.md             ← marco deconstruccionista
rondas/
  ronda_NN/
    task_opencode.md         ← tarea Fase A
    task_gemini.md
    task_qwen.md
    response_opencode.md     ← lectura independiente
    response_gemini.md
    response_qwen.md
    task_debate_opencode.md  ← tarea Fase B
    task_debate_gemini.md
    task_debate_qwen.md
    debate_opencode.md       ← respuesta al debate
    debate_gemini.md
    debate_qwen.md
blackboard.md                ← estado acumulado del álbum
sintesis_final.md            ← síntesis del orquestador tras ronda 10
```

**Automatización** (`lycaeum.sh`): script bash con `inotifywait` y `tmux send-keys` que detecta la aparición de los `task_*.md`, los envía a cada agente, espera los tres `response_*.md` y notifica al orquestador. La ronda completa (Fase A + Fase B) corre sin intervención manual una vez lanzada.

### Protocolo de moderación

El CLAUDE.md del orquestador establece reglas explícitas:
- **No opinar** sobre los poemas
- **No resolver tensiones** — avivarlas
- **No declarar ganador** — las lecturas coexisten
- **Sí señalar puntos ciegos**: si una lectura ignora algo que las otras dos sí ven, señalarlo explícitamente en la Fase B

### El blackboard como memoria acumulativa

Cada ronda alimenta las siguientes. El orquestador documenta en el blackboard los hilos que permanecen sin resolver y los candidatos para la ronda 10. Los agentes — mientras mantengan la sesión tmux activa — tienen acceso a este historial, y demostraron usarlo: en la ronda 2, Gemini comparó explícitamente el poema con la ronda anterior sin instrucción explícita.

### Incidente de Caín — dato metodológico

En la ronda 7, el agente Qwen (GLM-4.6 vía z.ai) fue bloqueado por el filtro de contenido al intentar leer "Caín" — el poema sobre el fratricidio y la culpa original. El bloqueo se produjo dos veces: en la Fase A y en la Fase B.

El orquestador, al recibir el archivo de silencio forzado, identificó el acontecimiento como material crítico y propuso tres opciones de tratamiento. Se eligió documentar el silencio como lectura — "el poema que habla de no ser entendido no pudo ser leído por el único crítico que busca lo que los textos callan" — y recuperar la lectura en sesión limpia posteriormente.

La lectura recuperada de Qwen sobre Caín, producida sin el contexto de sesión contaminado, incluyó la pregunta que el bloqueo había hecho posible: *¿el filtro es exterior al álbum, o es parte del proyecto artístico?*

## Lecciones aprendidas

### Sobre el sistema

**La tensión es el producto, no el problema.** El sistema funciona cuando los marcos se contradicen con coherencia, no cuando convergen. Las rondas de mayor valor fueron las de mayor conflicto entre Opencode y Qwen.

**El orquestador no debe sintetizar prematuramente.** Su valor está en identificar el punto de mayor tensión y diseñar la Fase B para que esa tensión se profundice, no en resolverla.

**El blackboard acumulativo es condición del hallazgo.** Sin la memoria inter-ronda, Qwen no habría podido construir su argumento sobre evasión sistemática a lo largo de seis poemas. La ronda 10 fue posible porque las nueve anteriores existían como contexto.

### Sobre los LLMs como críticos

**Los marcos críticos son marcos genuinos, no actuaciones.** Cuando Opencode acusó al orquestador de confundir análisis con adhesión, no estaba simulando una posición formalista: estaba defendiendo la distinción entre describir un mecanismo y evaluar sus consecuencias éticas.

**El debate fuerza a los marcos a sus límites.** Qwen, al ser presionado por Opencode sobre la distinción entre cursiva que produce y cursiva que protege, tuvo que precisar su argumento en lugar de repetirlo. Eso no habría ocurrido en lecturas independientes.

**Los agentes integran el contexto del sistema como dato.** Qwen, tras ser bloqueado en la ronda 7, produjo en la ronda 8 una lectura que explícitamente referenciaba la censura: "dolor legítimo que el sistema tolera porque no acusa a nadie, a diferencia de los temas de culpa que activaron la censura en r7." El agente hizo del accidente metodológico material crítico.

### Sobre la aplicación a obra propia

**El sistema puede devolver al autor lo que el texto sabía y él no.** La frase "el poema no puede decir que elige el vacío porque entonces dejaría de ser tragedia y sería decisión" fue reconocida por el autor como verdadera sin haber sido formulada previamente por él.

**La distancia de los marcos protege al autor de la autocomplacencia.** Ningún crítico tuvo acceso a la intención del autor. Leyeron el texto, no la persona. Esa distancia produjo lecturas más incómodas — y más útiles.

---

## Conclusión

LYCAEUM no es un sistema de evaluación de texto. Es un sistema de producción de tensión crítica sobre texto. La diferencia es metodológicamente significativa: la evaluación busca una lectura correcta; la tensión crítica busca lecturas incompatibles que, en su conflicto, revelan algo que ninguna habría alcanzado sola.

El experimento sobre *Fábulas sin moraleja* confirmó la hipótesis: diez rondas de debate entre tres marcos radicalmente distintos produjeron una síntesis que el autor reconoció como la lectura más precisa de su propia obra — una lectura que ningún agente individual, ni el propio autor, habría formulado.

**La moraleja que el álbum dice no tener está presente como estructura de permisión.** Eso lo encontró el sistema, no el autor. Y lo encontró porque el sistema fue diseñado para no buscar consenso.
