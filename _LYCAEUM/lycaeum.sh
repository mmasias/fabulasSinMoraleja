#!/bin/bash
# LYCAEUM — Automatización de mesa redonda crítica
# Uso: ./lycaeum.sh [start|ronda]

REPO="$HOME/misRepos/fabulasSinMoraleja"
LYCAEUM="$REPO/_LYCAEUM"
SESSION_ORQUESTADOR="lycaeum_claude"
SESSION_OPENCODE="lycaeum_opencode"
SESSION_GEMINI="lycaeum_gemini"
SESSION_QWEN="lycaeum_qwen"

# ─────────────────────────────────────────────
# COMANDO: start
# Lanza las cuatro sesiones tmux con los CLIs
# ─────────────────────────────────────────────
cmd_start() {
    echo "Lanzando sesiones LYCAEUM..."

    # Matar sesiones previas si existen
    tmux kill-session -t $SESSION_ORQUESTADOR 2>/dev/null
    tmux kill-session -t $SESSION_OPENCODE 2>/dev/null
    tmux kill-session -t $SESSION_GEMINI 2>/dev/null
    tmux kill-session -t $SESSION_QWEN 2>/dev/null

    # Crear sesiones en background
    tmux new-session -d -s $SESSION_ORQUESTADOR -c "$REPO"
    tmux new-session -d -s $SESSION_OPENCODE -c "$REPO"
    tmux new-session -d -s $SESSION_GEMINI -c "$REPO"
    tmux new-session -d -s $SESSION_QWEN -c "$REPO"

    # Lanzar CLIs en cada sesión
    tmux send-keys -t $SESSION_ORQUESTADOR "claude" Enter
    sleep 1
    tmux send-keys -t $SESSION_OPENCODE "opencode" Enter
    sleep 1
    tmux send-keys -t $SESSION_GEMINI "gemini" Enter
    sleep 1
    tmux send-keys -t $SESSION_QWEN "qwen" Enter
    sleep 2

    # Cargar contextos en los subordinados
    echo "Cargando contextos..."
    tmux send-keys -t $SESSION_OPENCODE "@_LYCAEUM/contexto_opencode.md" Enter
    sleep 2
    tmux send-keys -t $SESSION_GEMINI "@_LYCAEUM/contexto_gemini.md" Enter
    sleep 2
    tmux send-keys -t $SESSION_QWEN "@_LYCAEUM/contexto_qwen.md" Enter

    echo ""
    echo "✅ Sesiones lanzadas:"
    echo "   tmux attach -t $SESSION_ORQUESTADOR   ← orquestador (Claude)"
    echo "   tmux attach -t $SESSION_OPENCODE      ← Opencode (formalista)"
    echo "   tmux attach -t $SESSION_GEMINI        ← Gemini (fenomenológico)"
    echo "   tmux attach -t $SESSION_QWEN          ← Qwen (deconstruccionista)"
    echo ""
    echo "Abre Terminator con 4 paneles y adjunta cada sesión."
    echo "Luego ejecuta: ./lycaeum.sh ronda [N] [A|B]"
}

# ─────────────────────────────────────────────
# COMANDO: ronda N [A|B]
# Vigila la carpeta de la ronda y automatiza
# el envío de tareas cuando aparecen los task_*.md
# ─────────────────────────────────────────────
cmd_ronda() {
    local N=$(printf "%02d" $1)
    local FASE=${2:-A}
    local RONDA_DIR="$LYCAEUM/rondas/ronda_$N"

    mkdir -p "$RONDA_DIR"

    echo "Vigilando ronda $N — Fase $FASE"
    echo "Directorio: $RONDA_DIR"
    echo ""

    if [ "$FASE" = "A" ]; then
        watch_fase_a "$RONDA_DIR" "$N"
    elif [ "$FASE" = "B" ]; then
        watch_fase_b "$RONDA_DIR" "$N"
    else
        echo "Fase desconocida: $FASE. Usa A o B."
        exit 1
    fi
}

# Fase A: espera task_*.md y los envía a los agentes
watch_fase_a() {
    local DIR=$1
    local N=$2

    echo "Esperando task_*.md en $DIR..."
    echo "(El orquestador debe escribir los tres archivos task_opencode.md, task_gemini.md, task_qwen.md)"
    echo ""

    # Esperar y enviar cada task cuando aparece
    for AGENTE in opencode gemini qwen; do
        local TASK="$DIR/task_${AGENTE}.md"
        local SESSION="lycaeum_${AGENTE}"

        if [ ! -f "$TASK" ]; then
            echo "⏳ Esperando $TASK..."
            inotifywait -e close_write --include "task_${AGENTE}\\.md" "$DIR" 2>/dev/null
        fi

        echo "📤 Enviando task a $AGENTE..."
        tmux send-keys -t $SESSION "@_LYCAEUM/rondas/ronda_${N}/task_${AGENTE}.md" Enter
        sleep 1
    done

    echo ""
    echo "✅ Tareas enviadas. Esperando respuestas..."
    wait_responses "$DIR" "response" "$N"
}

# Fase B: espera task_debate_*.md y los envía
watch_fase_b() {
    local DIR=$1
    local N=$2

    echo "Esperando task_debate_*.md en $DIR..."
    echo ""

    for AGENTE in opencode gemini qwen; do
        local TASK="$DIR/task_debate_${AGENTE}.md"
        local SESSION="lycaeum_${AGENTE}"

        if [ ! -f "$TASK" ]; then
            echo "⏳ Esperando $TASK..."
            inotifywait -e close_write --include "task_debate_${AGENTE}\\.md" "$DIR" 2>/dev/null
        fi

        echo "📤 Enviando debate a $AGENTE..."
        tmux send-keys -t $SESSION "@_LYCAEUM/rondas/ronda_${N}/task_debate_${AGENTE}.md" Enter
        sleep 1
    done

    echo ""
    echo "✅ Tareas de debate enviadas. Esperando respuestas..."
    wait_responses "$DIR" "debate" "$N"
}

# Espera a que los tres archivos de respuesta existan
wait_responses() {
    local DIR=$1
    local PREFIX=$2
    local N=$3

    local PENDIENTES=3

    while [ $PENDIENTES -gt 0 ]; do
        PENDIENTES=0
        for AGENTE in opencode gemini qwen; do
            local RESP="$DIR/${PREFIX}_${AGENTE}.md"
            if [ ! -f "$RESP" ]; then
                PENDIENTES=$((PENDIENTES + 1))
            fi
        done

        if [ $PENDIENTES -gt 0 ]; then
            # Esperar cambio en el directorio
            inotifywait -e close_write "$DIR" 2>/dev/null
        fi
    done

    echo ""
    echo "✅ Las tres respuestas están escritas."

    if [ "$PREFIX" = "response" ]; then
        echo "👉 Avisa al orquestador:"
        echo "   tmux send-keys -t $SESSION_ORQUESTADOR"
        echo "   \"Las tres lecturas de la Fase A están en rondas/ronda_${N}/. Lee los response_*.md y prepara la Fase B.\" Enter"
        echo ""
        echo "   O ejecuta: ./lycaeum.sh notify $N A"
    else
        echo "👉 Avisa al orquestador:"
        echo "   O ejecuta: ./lycaeum.sh notify $N B"
    fi
}

# ─────────────────────────────────────────────
# COMANDO: notify N [A|B]
# Avisa al orquestador que las respuestas están listas
# ─────────────────────────────────────────────
cmd_notify() {
    local N=$(printf "%02d" $1)
    local FASE=${2:-A}

    if [ "$FASE" = "A" ]; then
        tmux send-keys -t $SESSION_ORQUESTADOR \
            "Las tres lecturas de la Fase A de la ronda $N están escritas en _LYCAEUM/rondas/ronda_${N}/. Lee los response_*.md, identifica el punto de tensión y prepara las tareas de la Fase B (task_debate_*.md)." \
            Enter
        echo "✅ Orquestador notificado — Fase A ronda $N completa."
    else
        tmux send-keys -t $SESSION_ORQUESTADOR \
            "Las tres respuestas del debate de la Fase B de la ronda $N están escritas en _LYCAEUM/rondas/ronda_${N}/. Lee los debate_*.md, actualiza el blackboard y prepara la ronda $((10#$N + 1))." \
            Enter
        echo "✅ Orquestador notificado — Fase B ronda $N completa."
    fi
}

# ─────────────────────────────────────────────
# COMANDO: status
# Muestra el estado de todas las rondas
# ─────────────────────────────────────────────
cmd_status() {
    echo "Estado LYCAEUM — Fábulas sin moraleja"
    echo "======================================"
    for N in $(seq -f "%02g" 1 10); do
        local DIR="$LYCAEUM/rondas/ronda_$N"
        if [ -d "$DIR" ]; then
            local RA=$([ -f "$DIR/response_opencode.md" ] && [ -f "$DIR/response_gemini.md" ] && [ -f "$DIR/response_qwen.md" ] && echo "✅" || echo "⏳")
            local RB=$([ -f "$DIR/debate_opencode.md" ] && [ -f "$DIR/debate_gemini.md" ] && [ -f "$DIR/debate_qwen.md" ] && echo "✅" || echo "⏳")
            echo "  Ronda $N — Fase A: $RA  Fase B: $RB"
        fi
    done
}

# ─────────────────────────────────────────────
# DISPATCHER
# ─────────────────────────────────────────────
case "$1" in
    start)   cmd_start ;;
    ronda)   cmd_ronda "$2" "$3" ;;
    notify)  cmd_notify "$2" "$3" ;;
    status)  cmd_status ;;
    *)
        echo "LYCAEUM — Sistema de mesa redonda crítica automatizada"
        echo ""
        echo "Uso:"
        echo "  ./lycaeum.sh start              Lanza las 4 sesiones tmux con los CLIs"
        echo "  ./lycaeum.sh ronda N [A|B]      Vigila la ronda N y automatiza el envío"
        echo "  ./lycaeum.sh notify N [A|B]     Notifica al orquestador que las respuestas están listas"
        echo "  ./lycaeum.sh status             Muestra el estado de todas las rondas"
        echo ""
        echo "Flujo normal:"
        echo "  1. ./lycaeum.sh start"
        echo "  2. Adjunta las sesiones en Terminator"
        echo "  3. Dile al orquestador el objetivo y que prepare la ronda 1"
        echo "  4. ./lycaeum.sh ronda 1 A       (en otra terminal — vigila y envía automático)"
        echo "  5. ./lycaeum.sh ronda 1 B       (cuando el orquestador haya preparado la Fase B)"
        echo "  6. Repite para rondas 2-10"
        ;;
esac
