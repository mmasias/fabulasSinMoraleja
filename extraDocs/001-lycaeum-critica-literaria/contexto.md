# Contexto del Experimento - Artículo 001

<div align=right>

||||||
|-|-|-|-|-|
|[🏠️](../README.md)|[Artículo](README.md)|**Contexto**|[Lo más "técnico"](evidencia.md)|[Código completo](/_LYCAEUM/)

</div>

## Estado del Proyecto en el Momento del Experimento

**Fecha**: 2026-03-07  
**Duración**: Sesión continua de aproximadamente 8 horas  
**Conversación**: Claude Sonnet 4.6 con usuario (Morgan Bill / Manuel)  
**Fase del álbum**: Preproducción — proyecto de 24 años en curso

## El álbum

*Fábulas sin moraleja* es un álbum conceptual en preproducción que documenta deterioro psicológico a través del paisaje urbano de Barcelona. Nueve poemas escritos a lo largo de 24 años, publicados bajo el nombre artístico Morgan Bill.

**Los poemas, en orden de ronda:**

| Ronda | Título |
|---|---|
| 01 | Av. Meridiana |
| 02 | Plácida insurrección |
| 03 | Las ventanas |
| 04 | 27, y sigue... |
| 05 | Hay poesía |
| 06 | Obituario |
| 07 | Caín |
| 08 | Que una línea traiga tu voz |
| 09 | Diógenes |
| 10 | *(unidad conceptual del álbum)* |

## Contexto Tecnológico

### Infraestructura preexistente: bundungún

Antes de LYCAEUM existía bundungún — un script bash que lanzaba cuatro CLIs de IA en un grid de Terminator para debate multi-LLM. bundungún era orquestador estático: flujo rígido, sin razonamiento sobre el siguiente paso.

LYCAEUM surge de la pregunta: *¿y si designamos un jefe que decida a quién delegar, y qué le pregunta cada uno?*

### Agentes disponibles

| Agente | CLI | Modelo | Rol en LYCAEUM |
|---|---|---|---|
| Claude Code | `claude` | Claude Sonnet 4.6 | Orquestador / moderador |
| Opencode | `opencode` | GLM-4.6 (z.ai) | Crítico formalista |
| Gemini | `gemini` | Gemini (Google) | Crítico fenomenológico |
| Qwen | `qwen` | Qwen (Alibaba) | Crítico deconstruccionista |

### Entorno técnico

- **OS**: Fedora 43 / KDE / Wayland
- **Terminal**: Konsole con Terminator para grid de 4 paneles
- **Gestión de sesiones**: tmux (sin xdotool — incompatible con Wayland)
- **Vigilancia de archivos**: inotifywait (inotify-tools)
- **Repo**: `~/misRepos/fabulasSinMoraleja` — git

## Madurez del Sistema LYCAEUM en el Momento del Experimento

### Experiencia previa
LYCAEUM había sido desarrollado y probado previamente sobre el proyecto pySigHor — sistema de gestión de horarios universitarios. Esa experiencia estableció:
- El blackboard pattern como mecanismo de comunicación entre agentes
- El rol del orquestador como triangulador, no sintetizador
- La estructura de carpetas y archivos por ronda
- Los contextos de cada agente subordinado

### Adaptación para crítica literaria
El sistema fue reconvertido para un dominio completamente distinto:
- El orquestador pasa de analizar código a moderar debate crítico
- Los subordinados pasan de roles técnicos a marcos filosóficos
- El blackboard pasa de registrar deuda técnica a acumular tensiones críticas inter-ronda
- La ronda 10 no tiene poema — tiene el álbum completo como objeto

## Estado del Script de Automatización

El script `lycaeum.sh` fue desarrollado y corregido durante la sesión, con los siguientes bugs identificados y resueltos:

| Bug | Síntoma | Fix |
|---|---|---|
| Detección de `.tmp` | inotifywait disparaba con archivos temporales de Claude Code | `wait_for_file` con `-s` (contenido real) y `moved_to` |
| Enter no registrado en Gemini | El keystroke llegaba sin Enter | `C-m` en lugar de `Enter` |
| Enter no registrado en Opencode/Qwen | Misma causa, distinto CLI | Doble Enter con delay |
| Autocompletado de `@` en Opencode | El `@` activaba autocompletado interactivo | Texto plano para Opencode en Fase A |
| Sesión contaminada por Caín | GLM-4.6 bloqueó toda la sesión tras leer "Caín" | Nueva sesión tmux desde terminal externa |

## Incidente Crítico: Caín

El poema "Caín" (ronda 7) activó el filtro de contenido de z.ai/GLM-4.6 dos veces:
1. Al intentar Qwen leer el `task_opencode.md` en Fase A
2. Al intentar Qwen leer el `task_debate_qwen.md` en Fase B

El filtro contaminó toda la sesión tmux de Qwen, haciendo que incluso `/status` devolviera `DataInspectionFailed`. La solución fue abrir una nueva sesión desde terminal externa.

La lectura recuperada de Qwen sobre Caín, producida en sesión limpia, resultó ser la más filosóficamente densa de toda la ronda 7 — enriquecida precisamente por haber sido bloqueada.

## Condición del Autor Durante el Experimento

Primera lectura crítica sistemática del álbum desde marcos filosóficos formales. El autor reconoció durante la sesión múltiples hallazgos que describió como "lo que el texto sabía y yo no" — incluyendo la operación extractiva sobre el "tú" en "Hay poesía" y la estructura de autoceguera selectiva identificada por Qwen a partir de la ronda 3.

La síntesis final del orquestador fue leída por el autor al término de la sesión como la lectura más precisa del álbum que había recibido.
