# Evidencia y Referencias - Artículo 001

<div align=right>

|||||
|-|-|-|-|
|[🏠️](../README.md)|[Artículo](README.md)|[Contexto](contexto.md)|**Evidencia**

</div>

## Artefactos del Sistema

### Archivos de configuración

**`_LYCAEUM/CLAUDE.md`** — instrucciones del orquestador. Establece el rol de moderador (no crítico), el protocolo de dos fases, las reglas de moderación (no resolver tensiones, no declarar ganador) y el criterio de profundidad.

**`_LYCAEUM/contexto_opencode.md`** — marco formalista. Pregunta permanente: *¿cómo está hecho esto?* Regla central: leer solo lo que el poema dice, no lo que podría querer decir.

**`_LYCAEUM/contexto_gemini.md`** — marco fenomenológico. Pregunta permanente: *¿qué me hace vivir este poema?* Regla central: no resumir el poema, describir la experiencia de leerlo.

**`_LYCAEUM/contexto_qwen.md`** — marco deconstruccionista. Pregunta permanente: *¿qué tiene que callar este poema para poder hablar?* Regla central: el poema no merece protección, merece lectura.

**`_LYCAEUM/lycaeum.sh`** — script de automatización completo. Comandos: `start` (lanza las 4 sesiones tmux), `ronda N` (gestiona Fase A + Fase B sin intervención), `status` (estado de todas las rondas).

### Script lycaeum.sh — fragmentos técnicos clave

#### wait_for_file — fix del bug .tmp
```bash
wait_for_file() {
    local FILE=$1
    local LABEL=$2
    echo "⏳ Esperando $LABEL..."
    while [ ! -s "$FILE" ]; do
        inotifywait -q -e moved_to,close_write,create "$(dirname $FILE)" 2>/dev/null
        sleep 0.5
    done
    echo "✅ $LABEL listo."
}
```
El `-s` verifica que el archivo tenga contenido real (no es el `.tmp` vacío que Claude Code escribe antes de renombrar). Los eventos `moved_to,close_write,create` cubren todos los patrones de escritura de los distintos CLIs.

#### send_to — fix del Enter en Wayland
```bash
send_to() {
    local SESSION=$1
    local MSG=$2
    tmux send-keys -t "$SESSION" "$MSG"
    sleep 0.5
    tmux send-keys -t "$SESSION" "" Enter
    sleep 0.2
    tmux send-keys -t "$SESSION" "" Enter
}
```
El doble Enter con delay resolvió el problema de que Opencode y Qwen no registraban el keystroke en Wayland. Gemini requirió `C-m` en versiones intermedias; el doble Enter funcionó para los tres.

#### Fase A — tratamiento diferencial para Opencode
```bash
for AGENTE in opencode gemini qwen; do
    wait_for_file "$RONDA_DIR/task_${AGENTE}.md" "task_${AGENTE}.md"
    if [ "$AGENTE" = "opencode" ]; then
        send_to "lycaeum_opencode" "Lee el archivo _LYCAEUM/rondas/ronda_${N}/task_opencode.md y escribe tu respuesta en _LYCAEUM/rondas/ronda_${N}/response_opencode.md"
    else
        send_to "lycaeum_${AGENTE}" "@_LYCAEUM/rondas/ronda_${N}/task_${AGENTE}.md"
    fi
    sleep 1
done
```
Opencode activa autocompletado interactivo con `@` — necesita instrucción en texto plano. Gemini y Qwen resuelven la referencia `@` correctamente.

## Hallazgos Críticos por Ronda

### Ronda 1 — Av. Meridiana
Primera demostración de divergencia productiva. Convergencia inicial Opencode-Gemini sobre la cursiva como "prótesis de voz". Qwen detectó que la cursiva podía ser también coartada — el poema pidiendo complicidad al lector.

### Ronda 2 — Plácida insurrección
Gemini comparó espontáneamente con la ronda anterior ("si en Meridiana habitábamos una soledad traída, aquí observamos la construcción de una fortaleza de indiferencia") sin instrucción explícita. Primera evidencia de que el contexto acumulado funcionaba.

### Ronda 3 — Las ventanas
Hallazgo más denso hasta ese momento. Qwen: *"El poema no puede decir que elige el vacío porque entonces dejaría de ser tragedia y sería decisión."* El orquestador formuló la distinción vacío formal / vacío moral como hilo para la ronda 10.

### Ronda 4 — 27, y sigue...
Qwen detectó la operación del título como contraseña cultural (Club de los 27) y el cierre lógico: *"el suicidio fallido es su único acto fallido."* Patrón de títulos que desmienten al texto consolidado: tres en cuatro rondas.

### Ronda 5 — Hay poesía
Primera convergencia de los tres marcos en diagnóstico compartido: dependencia disfrazada de poder. Qwen: *"el colonizador necesita al colonizado."* El orquestador identificó que los tres nombres del diagnóstico (expansión / estrategia / apropiación colonial) implican éticas incompatibles — el acuerdo encubría el desacuerdo más profundo.

### Ronda 6 — Obituario
Qwen construyó el arco narrativo del álbum en cinco verbos: *"repite → normaliza → estetiza → poetiza → trivializa."* El orquestador formuló la pregunta que atravesaría las rondas restantes: *¿está el álbum llegando a un punto de reconocimiento o perpetuando la misma evasión?*

### Ronda 7 — Caín
Qwen bloqueado dos veces por `DataInspectionFailed` de z.ai/GLM-4.6. El filtro detectó contenido inapropiado en el poema sobre fratricidio. La sesión tmux quedó contaminada — incluso `/status` devolvió el mismo error. Nueva sesión desde terminal externa.

Opencode, en su debate, teorizó el silencio: *"La forma no solo esconde contenido; controla acceso."* Postuló una séptima función de la cursiva: silenciamiento selectivo extendido al texto entero.

Lectura recuperada de Qwen (sesión limpia): *"¿El filtro es exterior al álbum, o es parte del proyecto artístico? Si es parte del proyecto, la evasión es aún más sofisticada de lo que documenté."*

### Ronda 8 — Que una línea traiga tu voz
Qwen, en sesión limpia, integró la censura de r7 como dato crítico sin instrucción: *"dolor legítimo que el sistema tolera porque no acusa a nadie, a diferencia de los temas de culpa que activaron la censura en r7."*

El task_debate_qwen.md de esta ronda también activó el filtro — el task incluía referencias a Caín en el resumen de rondas anteriores. El orquestador reformuló el task eliminando esas referencias.

### Ronda 9 — Diógenes
Convergencia más amplia del corpus. Los tres aceptaron el "doble movimiento" (disolución + persistencia) como estructura del cierre. Gemini lanzó la categoría más original del corpus: "vulnerabilidad de la carne" — anterior a cualquier construcción de poder o lenguaje. Ni Qwen ni Opencode respondieron: límite compartido de los tres marcos.

### Ronda 10 — Unidad conceptual
Qwen formuló el eje: *"¿Es Fábulas sin moraleja honesto sobre su falta de moraleja, o es la última fábula con moraleja — la que niega tenerla?"*

La síntesis final del orquestador respondió: el álbum es honesto sobre sus fracasos formales; no es honesto sobre las condiciones de su silencio. La moraleja que dice no tener está presente como estructura de permisión: hay dolores que el álbum puede habitar; hay un dolor que no puede habitar sin que el sistema se detenga. Ese dolor se llama Caín.

## Métricas del Experimento

| Métrica | Valor |
|---|---|
| Rondas completadas | 10 (9 poemas + unidad conceptual) |
| Archivos generados | ~60 (tasks, responses, debates, blackboard, síntesis) |
| Rondas con intervención manual mínima | 7/10 |
| Intervenciones manuales requeridas | Enter en paneles (r1-r2), task reformulado (r8), sesión nueva Qwen (r7+) |
| Poema bloqueado por filtro | 1 (Caín — ronda 7) |
| Lecturas recuperadas post-bloqueo | 1 (response_qwen_recuperada.md + debate_qwen_recuperado.md) |
| Hallazgos no buscados explícitamente | ≥5 (ver README) |

## Decisiones de Diseño y sus Consecuencias

### Decisión 1: orquestador como moderador, no crítico
**Alternativa considerada**: que el orquestador también produjera una lectura.
**Consecuencia de la decisión**: el orquestador pudo identificar los puntos ciegos de cada marco sin estar comprometido con ninguno. Cuando Opencode no respondió a la observación de Qwen sobre el disfrute de la jaula, el orquestador lo señaló explícitamente en la Fase B.

### Decisión 2: no resolver tensiones en el blackboard
**Alternativa considerada**: que el orquestador sintetizara las tres lecturas en una posición consolidada.
**Consecuencia de la decisión**: las tensiones acumuladas entre rondas alimentaron el argumento de Qwen sobre evasión sistemática. La ronda 10 tuvo material porque las tensiones no habían sido resueltas en las nueve anteriores.

### Decisión 3: tratar la censura de Caín como acontecimiento, no como error
**Alternativa considerada**: reformular el task hasta que pasara el filtro (Opción B del orquestador).
**Consecuencia de la decisión**: Qwen produjo en la ronda 8 una lectura enriquecida por la experiencia del bloqueo. La lectura recuperada de Caín incluyó preguntas que solo el bloqueo había hecho posibles.

### Decisión 4: blackboard acumulativo visible para el orquestador en cada ronda
**Consecuencia**: el orquestador pudo conectar explícitamente la ronda 6 con la ronda 3, y formular el patrón de cinco verbos de Qwen como hilo para la ronda 10. Sin blackboard, cada ronda habría sido lectura aislada.

## Referencias Técnicas

- **inotify-tools**: `inotifywait` para vigilancia de sistema de archivos en Linux
- **tmux**: gestión de sesiones de terminal persistentes y envío de keystrokes
- **GLM-4.6**: modelo de z.ai/Zhipu, usado en Opencode. Filtro de contenido activado por "Caín"
- **Claude Code**: CLI de Anthropic, usado como orquestador. Escribe archivos con extensión `.tmp` antes de renombrar — requiere `moved_to` en lugar de `CLOSE_WRITE`
- **blackboard pattern**: patrón de arquitectura multi-agente donde los agentes se comunican a través de un espacio de memoria compartido (sistema de archivos), sin comunicación directa entre ellos
