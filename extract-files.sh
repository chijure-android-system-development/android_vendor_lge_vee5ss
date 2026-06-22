#!/bin/bash
#
# extract-files.sh — LG L5 II (vee5ss)
#
# Extrae los blobs propietarios del dispositivo conectado por ADB
# y los deposita en vendor/lge/vee5ss/proprietary/.
#
# Uso:
#   adb root && adb remount     (o desde recovery con /system montado)
#   ./extract-files.sh [serial]
#
# El argumento opcional es el serial ADB del dispositivo (útil si hay
# más de uno conectado).

set -e

DEVICE=vee5ss
VENDOR=lge

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ANDROID_ROOT="$SCRIPT_DIR/../../.."
PROPRIETARY_LIST="$ANDROID_ROOT/device/$VENDOR/$DEVICE/proprietary-files.txt"
OUTPUT_DIR="$SCRIPT_DIR/proprietary"

if [ ! -f "$PROPRIETARY_LIST" ]; then
    echo "Error: no se encontró $PROPRIETARY_LIST"
    exit 1
fi

# Serial ADB opcional
ADB_ARGS=""
if [ -n "$1" ]; then
    ADB_ARGS="-s $1"
fi

# Verificar que el dispositivo esté accesible
if ! adb $ADB_ARGS get-state > /dev/null 2>&1; then
    echo "Error: no hay dispositivo ADB disponible."
    echo "Conecta el LG-E450g y ejecuta: adb root && adb remount"
    exit 1
fi

echo "Extrayendo blobs de $DEVICE..."

PULLED=0
FAILED=0

while IFS= read -r line; do
    # Ignorar comentarios y líneas vacías
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    FILE="$line"
    DEST="$OUTPUT_DIR/$FILE"
    DEST_DIR="$(dirname "$DEST")"

    mkdir -p "$DEST_DIR"

    if adb $ADB_ARGS pull "/system/$FILE" "$DEST" > /dev/null 2>&1; then
        echo "  OK  $FILE"
        PULLED=$((PULLED + 1))
    else
        echo "  --  $FILE  (no encontrado en el dispositivo)"
        FAILED=$((FAILED + 1))
    fi

done < "$PROPRIETARY_LIST"

echo ""
echo "Extraídos: $PULLED  |  No encontrados: $FAILED"
echo ""
echo "Regenera los makefiles con:"
echo "  ./setup-makefiles.sh"
