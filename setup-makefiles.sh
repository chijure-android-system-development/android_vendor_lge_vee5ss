#!/bin/bash
#
# setup-makefiles.sh — LG L5 II (vee5ss)
#
# Regenera vee5ss-vendor-blobs.mk y proprietary/Android.mk leyendo
# los archivos presentes en vendor/lge/vee5ss/proprietary/.
#
# Ejecutar después de extract-files.sh o cada vez que se añada/quite
# un blob manualmente.

set -e

DEVICE=vee5ss
VENDOR=lge

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROPRIETARY_DIR="$SCRIPT_DIR/proprietary"
BLOBS_MK="$SCRIPT_DIR/${DEVICE}-vendor-blobs.mk"
PROPRIETARY_MK="$PROPRIETARY_DIR/Android.mk"

if [ ! -d "$PROPRIETARY_DIR" ]; then
    echo "Error: $PROPRIETARY_DIR no existe. Ejecuta extract-files.sh primero."
    exit 1
fi

# ---- Generar vee5ss-vendor-blobs.mk ----------------------------------------
# Solo van como PRODUCT_COPY_FILES los archivos que NO se declaran como
# módulos PREBUILT en Android.mk (hw/, egl/, modules/, etc/).
# lib/*.so y bin/* los instala Android.mk via BUILD_PREBUILT.

{
cat << 'HEADER'
# vee5ss-vendor-blobs.mk — generado por setup-makefiles.sh
# NO editar manualmente.

LOCAL_PATH := vendor/lge/vee5ss/proprietary

PRODUCT_COPY_FILES += \
HEADER

first=1
find "$PROPRIETARY_DIR" -type f | grep -v '/Android\.mk$' | sort | while read -r filepath; do
    rel="${filepath#$PROPRIETARY_DIR/}"

    # lib/*.so y bin/* los instala BUILD_PREBUILT en Android.mk — no duplicar
    case "$rel" in
        lib/hw/*)       dest="system/$rel" ;;
        lib/egl/*)      dest="system/$rel" ;;
        lib/modules/*)  dest="system/$rel" ;;
        lib/*.so)       continue ;;   # instalado por BUILD_PREBUILT
        bin/*)          continue ;;   # instalado por BUILD_PREBUILT
        etc/*)          dest="system/$rel" ;;
        *)              dest="system/$rel" ;;
    esac

    if [ "$first" = "1" ]; then
        printf '    $(LOCAL_PATH)/%s:%s' "$rel" "$dest"
        first=0
    else
        printf ' \\\n    $(LOCAL_PATH)/%s:%s' "$rel" "$dest"
    fi
done

printf '\n'
} > "$BLOBS_MK"

# ---- Generar proprietary/Android.mk -----------------------------------------

{
cat << 'HEADER'
# proprietary/Android.mk — generado por setup-makefiles.sh
# NO editar manualmente.

LOCAL_PATH := $(call my-dir)

HEADER

# Shared libraries (.so) — excepto lib/egl/ y lib/hw/ que van como PRODUCT_COPY_FILES
find "$PROPRIETARY_DIR/lib" -name "*.so" 2>/dev/null \
    | grep -v '/egl/' \
    | grep -v '/hw/' \
    | sort \
    | while read -r filepath; do
        rel="${filepath#$PROPRIETARY_DIR/}"
        module="${filepath##*/}"
        module="${module%.so}"

        cat << EOF
include \$(CLEAR_VARS)
LOCAL_MODULE        := $module
LOCAL_MODULE_SUFFIX := .so
LOCAL_MODULE_CLASS  := SHARED_LIBRARIES
LOCAL_MODULE_PATH   := \$(TARGET_OUT_SHARED_LIBRARIES)
LOCAL_SRC_FILES     := $rel
LOCAL_MODULE_TAGS   := optional
include \$(BUILD_PREBUILT)

EOF
    done

# Ejecutables
find "$PROPRIETARY_DIR/bin" -type f 2>/dev/null | sort | while read -r filepath; do
    rel="${filepath#$PROPRIETARY_DIR/}"
    module="${filepath##*/}"

    cat << EOF
include \$(CLEAR_VARS)
LOCAL_MODULE       := $module
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_PATH  := \$(TARGET_OUT_EXECUTABLES)
LOCAL_SRC_FILES    := $rel
LOCAL_MODULE_TAGS  := optional
include \$(BUILD_PREBUILT)

EOF
done
} > "$PROPRIETARY_MK"

echo "Generado: $BLOBS_MK"
echo "Generado: $PROPRIETARY_MK"
