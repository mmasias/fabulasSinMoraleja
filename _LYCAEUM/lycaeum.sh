#!/bin/bash
# LYCAEUM — Automatización de mesa redonda crítica
# Uso: ./lycaeum.sh [start|ronda|status]

REPO="$HOME/misRepos/fabulasSinMoraleja"
LYCAEUM="$REPO/_LYCAEUM"
SESSION_ORQUESTADOR="lycaeum_claude"
SESSION_OPENCODE="lycaeum_opencode"
SESSION_GEMINI="lycaeum_gemini"
SESSION_QWEN="lycaeum_qwen"

# ─────────────────────────────────────────────
# UTILIDADES
# ─────────────────────────────────────────────

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

send_to() {
    local SESSION=$1
    local MSG=$2
    tmux send-keys -t "$SESSION" "$MSG"
    sleep 0.5
    tmux send-keys -t "$SESSION" "" C-m
}

wait_three() {
    local DIR=$1
    local PREFIX=$2
    local LABEL=$3
    echo ""
    echo "⏳ Esperando las tres respuestas ($LABEL)..."
    for AGENTE in opencode gemini qwen; do
        wait_for_file "$DIR/${PREFIX}_${AGENTE}.md" "${PREFIX}_${AGENTE}.md"
    done
    echo ""
    echo "✅ Las tres respuestas de $LABEL están escritas."
}

# ─────────────────────────────────────────────
# COMANDO: start
# ─────────────────────────────────────────────
cmd_start() {
    echo "🚀 Lanzando sesiones LYCAEUM..."

    for S in $SESSION_ORQUESTADOR $SESSION_OPENCODE $SESSION_GEMINI $SESSION_QWEN; do
        tmux kill-session -t $S 2>/dev/null
    done

    tmux new-session -d -s $SESSION_ORQUESTADOR -c "$REPO"
    tmux new-session -d -s $SESSION_OPENCODE    -c "$REPO"
    tmux new-session -d -s $SESSION_GEMINI      -c "$REPO"
    tmux new-session -d -s $SESSION_QWEN        -c "$REPO"

    send_to $SESSION_ORQUESTADOR "claude"
    sleep 2
    send_to $SESSION_OPENCODE "opencode"
    sleep 2
    send_to $SESSION_GEMINI "gemini"
    sleep 2
    send_to $SESSION_QWEN "qwen"
    sleep 3

    echo "📖 Cargando contextos..."
    send_to $SESSION_OPENCODE "@_LYCAEUM/contexto_opencode.md"
    sleep 3
    send_to $SESSION_GEMINI "@_LYCAEUM/contexto_gemini.md"
    sleep 3
    send_to $SESSION_QWEN "@_LYCAEUM/contexto_qwen.md"
    sleep 2

    echo ""
    echo "✅ Sesiones lanzadas. Adjunta en Terminator:"
    echo "   tmux attach -t $SESSION_ORQUESTADOR   ← Claude (orquestador)"
    echo "   tmux attach -t $SESSION_OPENCODE      ← Opencode (formalista)"
    echo "   tmux attach -t $SESSION_GEMINI        ← Gemini (fenomenológico)"
    echo "   tmux attach -t $SESSION_QWEN          ← Qwen (deconstruccionista)"
    echo ""
    echo "Luego dile al orquestador el objetivo y ejecuta:"
    echo "   ./lycaeum.sh ronda 1"
}

# ─────────────────────────────────────────────
# COMANDO: ronda N
# ─────────────────────────────────────────────
cmd_ronda() {
    local N=$(printf "%02d" $1)
    local RONDA_DIR="$LYCAEUM/rondas/ronda_$N"
    mkdir -p "$RONDA_DIR"

    echo ""
    echo "════════════════════════════════════════"
    echo "  LYCAEUM — Ronda $N"
    echo "════════════════════════════════════════"

    # ── FASE A ──
    echo ""
    echo "── FASE A — Lecturas independientes ──"

    for AGENTE in opencode gemini qwen; do
        wait_for_file "$RONDA_DIR/task_${AGENTE}.md" "task_${AGENTE}.md"
        echo "📤 Enviando tarea a $AGENTE..."
        send_to "lycaeum_${AGENTE}" "@_LYCAEUM/rondas/ronda_${N}/task_${AGENTE}.md"
        sleep 1
    done

    echo "✅ Tareas Fase A enviadas."
    wait_three "$RONDA_DIR" "response" "Fase A"

    echo "📣 Notificando al orquestador — Fase A completa..."
    send_to $SESSION_ORQUESTADOR "Las tres lecturas de la Fase A de la ronda $N están escritas en _LYCAEUM/rondas/ronda_${N}/. Lee los response_*.md, identifica el punto de tensión y escribe los task_debate_*.md para la Fase B."
    sleep 1

    # ── FASE B ──
    echo ""
    echo "── FASE B — Debate ──"

    for AGENTE in opencode gemini qwen; do
        wait_for_file "$RONDA_DIR/task_debate_${AGENTE}.md" "task_debate_${AGENTE}.md"
        echo "📤 Enviando debate a $AGENTE..."
        send_to "lycaeum_${AGENTE}" "Lee _LYCAEUM/rondas/ronda_${N}/task_debate_${AGENTE}.md y responde en _LYCAEUM/rondas/ronda_${N}/debate_${AGENTE}.md"
        sleep 1
    done

    echo "✅ Tareas Fase B enviadas."
    wait_three "$RONDA_DIR" "debate" "Fase B"

    echo "📣 Notificando al orquestador — Fase B completa..."
    send_to $SESSION_ORQUESTADOR "Las tres respuestas del debate de la Fase B de la ronda $N están escritas en _LYCAEUM/rondas/ronda_${N}/. Lee los debate_*.md, actualiza el blackboard.md y avísame cuando estés listo para continuar."
    sleep 1

    echo ""
    echo "════════════════════════════════════════"
    echo "  Ronda $N completa."
    echo "  Cuando el orquestador cierre la ronda:"
    echo "  ./lycaeum.sh ronda $((10#$N + 1))"
    echo "════════════════════════════════════════"
}

# ─────────────────────────────────────────────
# COMANDO: status
# ─────────────────────────────────────────────
cmd_status() {
    local POEMAS=("" "Av. Meridiana" "Plácida insurrección" "Las ventanas" "27, y sigue..." "Hay poesía" "Obituario" "Caín" "Que una línea traiga tu voz" "Diógenes" "Unidad conceptual")
    echo "Estado LYCAEUM — Fábulas sin moraleja"
    echo "═══════════════════════════════════════"
    for N in $(seq 1 10); do
        local NP=$(printf "%02d" $N)
        local DIR="$LYCAEUM/rondas/ronda_$NP"
        local FA="⏳" FB="⏳"
        if [ -d "$DIR" ]; then
            [ -f "$DIR/response_opencode.md" ] && [ -f "$DIR/response_gemini.md" ] && [ -f "$DIR/response_qwen.md" ] && FA="✅"
            [ -f "$DIR/debate_opencode.md" ]  && [ -f "$DIR/debate_gemini.md" ]  && [ -f "$DIR/debate_qwen.md" ]  && FB="✅"
            echo "  Ronda $NP — ${POEMAS[$N]} — Fase A: $FA  Fase B: $FB"
        else
            echo "  Ronda $NP — ${POEMAS[$N]} — [pendiente]"
        fi
    done
}

# ─────────────────────────────────────────────
# DISPATCHER
# ─────────────────────────────────────────────
case "$1" in
    start)   cmd_start ;;
    ronda)   cmd_ronda "$2" ;;
    status)  cmd_status ;;
    *)
        echo "LYCAEUM — Mesa redonda crítica automatizada"
        echo ""
        echo "Uso:"
        echo "  ./lycaeum.sh start      Lanza las 4 sesiones tmux"
        echo "  ./lycaeum.sh ronda N    Gestiona la ronda N completa (Fase A + B)"
        echo "  ./lycaeum.sh status     Estado de todas las rondas"
        echo ""
        echo "Flujo:"
        echo "  1. ./lycaeum.sh start"
        echo "  2. Adjunta las 4 sesiones en Terminator"
        echo "  3. Dile al orquestador el objetivo y que prepare la ronda N"
        echo "  4. ./lycaeum.sh ronda 1   (en terminal aparte)"
        echo "  5. Al terminar cada ronda: ./lycaeum.sh ronda N+1"
        ;;
esac
